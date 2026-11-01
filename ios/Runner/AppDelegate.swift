import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let registrar = self.registrar(forPlugin: "AppleVisionOcrHandler") {
      AppleVisionOcrHandler.register(with: registrar.messenger())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppleVisionOcrHandler") {
      AppleVisionOcrHandler.register(with: registrar.messenger())
    }
  }
}

class AppleVisionOcrHandler {
  private static var isRegistered = false

  static func register(with messenger: FlutterBinaryMessenger) {
    guard !isRegistered else { return }
    isRegistered = true

    let channel = FlutterMethodChannel(name: "receipt_record/apple_vision", binaryMessenger: messenger)
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "recognizeText" {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Image path is required", details: nil))
          return
        }
        recognizeText(at: path, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func recognizeText(at path: String, result: @escaping FlutterResult) {
    guard FileManager.default.fileExists(atPath: path) else {
      result(FlutterError(code: "FILE_NOT_FOUND", message: "File does not exist at \(path)", details: nil))
      return
    }

    let fileURL = URL(fileURLWithPath: path)

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let requestHandler = VNImageRequestHandler(url: fileURL, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        try requestHandler.perform([request])

        guard let observations = request.results, !observations.isEmpty else {
          DispatchQueue.main.async {
            result("")
          }
          return
        }

        let extractedText = processObservations(observations)
        DispatchQueue.main.async {
          result(extractedText)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private static func processObservations(_ observations: [VNRecognizedTextObservation]) -> String {
    let candidates: [(box: CGRect, text: String)] = observations.compactMap { obs in
      guard let candidate = obs.topCandidates(1).first else { return nil }
      let str = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
      return str.isEmpty ? nil : (obs.boundingBox, str)
    }

    if candidates.isEmpty { return "" }

    // Vision coordinates: origin is at bottom-left, y=1 is top, y=0 is bottom
    // Sort descending by vertical midpoint (top of image to bottom)
    let sortedByY = candidates.sorted { $0.box.midY > $1.box.midY }

    var lines: [[(box: CGRect, text: String)]] = []
    for item in sortedByY {
      var placed = false
      for i in 0..<lines.count {
        let lineMinY = lines[i].map { $0.box.minY }.min() ?? item.box.minY
        let lineMaxY = lines[i].map { $0.box.maxY }.max() ?? item.box.maxY
        let lineHeight = max(lines[i].map { $0.box.height }.reduce(0, +) / CGFloat(lines[i].count), 0.005)

        // Check vertical overlap with this line
        let overlap = min(item.box.maxY, lineMaxY) - max(item.box.minY, lineMinY)
        if overlap > 0 && overlap > min(item.box.height, lineHeight) * 0.4 {
          lines[i].append(item)
          placed = true
          break
        }
      }
      if !placed {
        lines.append([item])
      }
    }

    // Sort observations in each line horizontally (left to right)
    let lineStrings = lines.map { line -> String in
      let sortedInLine = line.sorted { $0.box.minX < $1.box.minX }
      return sortedInLine.map { $0.text }.joined(separator: " ")
    }

    return lineStrings.joined(separator: "\n")
  }
}
