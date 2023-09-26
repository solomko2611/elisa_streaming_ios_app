import AVFoundation

#if canImport(SwiftPMSupport)
import SwiftPMSupport
#endif

//-START SPRII
import RxSwift
//-END SPRII

final class IOAudioUnit: NSObject, IOUnit {
	//-START SPRII
	private var disposeBag: DisposeBag?
	//-END SPRII
    lazy var codec: AudioCodec = {
        var codec = AudioCodec()
        codec.lockQueue = lockQueue
        return codec
    }()
    let lockQueue = DispatchQueue(label: "com.haishinkit.HaishinKit.AudioIOComponent.lock")
    var soundTransform: SoundTransform = .init() {
        didSet {
            soundTransform.apply(mixer?.mediaLink.playerNode)
        }
    }
    var muted = false
    weak var mixer: IOMixer?
    var isMonitoringEnabled = false {
        didSet {
            if isMonitoringEnabled {
                monitor.startRunning()
            } else {
                monitor.stopRunning()
            }
        }
    }

    var settings: AudioCodecSettings = .default {
        didSet {
            codec.settings = settings
            resampler.settings = settings
        }
    }

    private lazy var resampler: IOAudioResampler<IOAudioUnit> = {
        var resampler = IOAudioResampler<IOAudioUnit>()
        resampler.delegate = self
        return resampler
    }()
    private var monitor: IOAudioMonitor = .init()
    #if os(iOS) || os(macOS)
    private(set) var capture: IOAudioCaptureUnit = .init()
    #endif

    #if os(iOS) || os(macOS)
    func attachAudio(_ device: AVCaptureDevice?, automaticallyConfiguresApplicationAudioSession: Bool) throws {
        guard let mixer else {
            return
        }
        mixer.session.beginConfiguration()
        defer {
            mixer.session.commitConfiguration()
        }
        guard let device else {
            try capture.attachDevice(nil, audioUnit: self)
            return
        }
        try capture.attachDevice(device, audioUnit: self)
        #if os(iOS)
        mixer.session.automaticallyConfiguresApplicationAudioSession = automaticallyConfiguresApplicationAudioSession
        #endif
    }
    #endif

	//-START SPRII
	
	//    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
	//        resampler.appendSampleBuffer(sampleBuffer.muted(muted))
	//    }
	
	private func subscribeToAudioEmitter() {
		guard let mixer, mixer.syncDiff > .zero, disposeBag == nil else { return }
		disposeBag = DisposeBag()
		let delay = Int(mixer.syncDiff.seconds * 1000)
		
		mixer.audioBufferEmitter
			.delay(RxTimeInterval.milliseconds(delay), scheduler: MainScheduler.asyncInstance)
			.subscribe { [weak self] sampleBuffer in
				self?.resampler.appendSampleBuffer(sampleBuffer)
			}.disposed(by: disposeBag!)
	}
	
	func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
		let sampleBuffer = sampleBuffer.muted(muted)
		mixer?.recorder.appendSampleBuffer(sampleBuffer)
 
		subscribeToAudioEmitter()
		mixer?.audioBufferEmitter.onNext(sampleBuffer)
	}
	//-START SPRII
}

extension IOAudioUnit: IOUnitEncoding {
    // MARK: IOUnitEncoding
    func startEncoding(_ delegate: any AVCodecDelegate) {
        codec.delegate = delegate
        codec.startRunning()
    }

    func stopEncoding() {
        codec.stopRunning()
        codec.delegate = nil
    }
}

extension IOAudioUnit: IOUnitDecoding {
    // MARK: IOUnitDecoding
    func startDecoding() {
        if let playerNode = mixer?.mediaLink.playerNode {
            mixer?.audioEngine?.attach(playerNode)
        }
        codec.delegate = self
        codec.startRunning()
    }

    func stopDecoding() {
        if let playerNode = mixer?.mediaLink.playerNode {
            mixer?.audioEngine?.detach(playerNode)
        }
        codec.stopRunning()
        codec.delegate = nil
    }
}

#if os(iOS) || os(macOS)
extension IOAudioUnit: AVCaptureAudioDataOutputSampleBufferDelegate {
    // MARK: AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard mixer?.useSampleBuffer(sampleBuffer: sampleBuffer, mediaType: AVMediaType.audio) == true else {
            return
        }
        appendSampleBuffer(sampleBuffer)
    }
}
#endif

extension IOAudioUnit: AudioCodecDelegate {
    // MARK: AudioConverterDelegate
    func audioCodec(_ codec: AudioCodec, errorOccurred error: AudioCodec.Error) {
    }

    func audioCodec(_ codec: AudioCodec, didOutput audioFormat: AVAudioFormat) {
        do {
            mixer?.audioFormat = audioFormat
            if let audioEngine = mixer?.audioEngine, audioEngine.isRunning == false {
                try audioEngine.start()
            }
        } catch {
            logger.error(error)
        }
    }

    func audioCodec(_ codec: AudioCodec, didOutput audioBuffer: AVAudioBuffer, presentationTimeStamp: CMTime) {
        guard let audioBuffer = audioBuffer as? AVAudioPCMBuffer else {
            return
        }
        if let mixer {
            mixer.delegate?.mixer(mixer, didOutput: audioBuffer, presentationTimeStamp: presentationTimeStamp)
        }
        mixer?.mediaLink.enqueueAudio(audioBuffer)
    }
}

extension IOAudioUnit: IOAudioResamplerDelegate {
    // MARK: IOAudioResamplerDelegate
    func resampler(_ resampler: IOAudioResampler<IOAudioUnit>, errorOccurred error: AudioCodec.Error) {
    }

    func resampler(_ resampler: IOAudioResampler<IOAudioUnit>, didOutput audioFormat: AVAudioFormat) {
        codec.inSourceFormat = audioFormat.formatDescription.audioStreamBasicDescription
        monitor.inSourceFormat = audioFormat.formatDescription.audioStreamBasicDescription
    }

    func resampler(_ resampler: IOAudioResampler<IOAudioUnit>, didOutput audioBuffer: AVAudioPCMBuffer, presentationTimeStamp: CMTime) {
        if let mixer {
            mixer.delegate?.mixer(mixer, didOutput: audioBuffer, presentationTimeStamp: presentationTimeStamp)
            if mixer.recorder.isRunning.value, let sampleBuffer = audioBuffer.makeSampleBuffer(presentationTimeStamp) {
                mixer.recorder.appendSampleBuffer(sampleBuffer)
            }
        }
        monitor.appendAudioPCMBuffer(audioBuffer)
        codec.appendAudioBuffer(audioBuffer, presentationTimeStamp: presentationTimeStamp)
    }
}
