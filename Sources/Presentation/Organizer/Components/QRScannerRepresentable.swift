import AVFoundation
import SwiftUI

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

struct QRScannerRepresentable: UIViewRepresentable {
    var onCode: (String) -> Void

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black

        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else {
            return view
        }

        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill

        context.coordinator.session = session

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return view
    }

    func updateUIView(_: PreviewView, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCode: onCode)
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var onCode: (String) -> Void
        var session: AVCaptureSession?
        private var hasScanned = false

        init(onCode: @escaping (String) -> Void) {
            self.onCode = onCode
        }

        func metadataOutput(
            _: AVCaptureMetadataOutput,
            didOutput objects: [AVMetadataObject],
            from _: AVCaptureConnection
        ) {
            guard !hasScanned,
                  let obj = objects.first as? AVMetadataMachineReadableCodeObject,
                  let code = obj.stringValue else { return }

            hasScanned = true
            DispatchQueue.global(qos: .userInitiated).async {
                self.session?.stopRunning()
            }
            onCode(code)
        }
    }
}
