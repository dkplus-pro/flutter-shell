/// Mock guest binding (PRD D8).
///
/// Fixed demo room; no login, not persisted. The guest display name is part
/// of the ARB copy (it must localize), so only the room number lives here.
class GuestProfile {
  const new({required this.roomNo});

  final String roomNo;
}
