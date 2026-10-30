import Flutter
import UIKit

/// iOS bridge stub (DEC-010): the contract is locked by the generated
/// `ShellApi.g.swift`, but every HostApi method throws UNIMPLEMENTED and the
/// event stream errors immediately. iOS is NOT built, tested or claimed
/// usable in v0 (docs/01 §13, docs/04 §9).
public class NativeBridgePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    ShellHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: ShellHostApiStub()
    )
    TicksStreamHandler.register(
      with: registrar.messenger(),
      streamHandler: TicksStreamHandlerStub()
    )
    // FlutterApi proxy is not called by the stub: no native screen exists on
    // iOS yet, so there is nothing to send back.
  }
}

/// All methods deliberately fail with UNIMPLEMENTED.
class ShellHostApiStub: ShellHostApi {
  func getSystemInfo() async throws -> SystemInfo {
    throw PigeonError(
      code: "UNIMPLEMENTED",
      message: "iOS bridge not implemented",
      details: nil
    )
  }

  func openNativeScreen(title: String, message: String) async throws -> Bool {
    throw PigeonError(
      code: "UNIMPLEMENTED",
      message: "iOS bridge not implemented",
      details: nil
    )
  }
}

/// Errors immediately on listen; never produces data.
class TicksStreamHandlerStub: TicksStreamHandler {
  override func onListen(
    withArguments arguments: Any?,
    sink: PigeonEventSink<Int64>
  ) {
    sink.error(
      code: "UNIMPLEMENTED",
      message: "iOS bridge not implemented",
      details: nil
    )
  }
}
