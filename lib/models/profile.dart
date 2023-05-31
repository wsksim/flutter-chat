/// Profile model
///
/// This model represents a profile in the chat.
///
/// Examples:
/// ```dart
/// final profile = Profile(
///   id: '{uuid}',
///   username: 'John Doe',
///   createdAt: DateTime.now(),
/// );
/// ```
///
/// ```dart
/// final profile = Profile.fromMap({
///   'id': '{uuid}',
///   'username': 'John Doe',
///   'created_at': '2021-08-01T00:00:00.000Z',
/// });
///```
///
class Profile {
  /// Creates a profile
  ///
  /// [id]        is the ID of the profile.
  /// [username]  is the username of the profile.
  /// [createdAt] is the date and time when the profile was created.
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  /// Creates a profile from a map
  ///
  /// [map] is a map that contains the profile data.
  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']);
}
