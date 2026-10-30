# native_bridge

Pigeon-based Flutter <-> native bridge plugin for the shell.

- Contract (single source of truth): `pigeons/shell_api.dart`, generated with Pigeon 29.1.0 by `tool/gen.sh`.
- Public Dart API: `NativeBridge`, `BridgeException`, `SystemInfo`, `NativeScreenResult`.
- Android: fully implemented (Kotlin + Compose demo screen). iOS: UNIMPLEMENTED stub, not compiled in v0.
- Details: `docs/02-bridge-contract.md`.
