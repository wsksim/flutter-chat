/// Message model
///
/// This model represents a message in the chat.
///
/// Examples:
/// ```dart
/// final message = Message(
///   id: '{uuid}',
///   profileId: '{uuid}',
///   content: 'Hello World!',
///   createdAt: DateTime.now(),
///   isMine: true,
/// );
/// ```
///
/// ```dart
/// final message = Message.fromMap({
///   'id': '{uuid}',
///   'profile_id': '{uuid}',
///   'content': 'Hello World!',
///   'created_at': '2021-08-01T00:00:00.000Z',
///   'is_mine': true,
/// });
/// ```
class Message {
  /// Creates a message
  ///
  /// [id]        is the ID of the message.
  /// [profileId] is the ID of the profile that sent the message.
  /// [content]   is the content of the message.
  /// [createdAt] is the date and time when the message was created.
  /// [isMine]    is a boolean that indicates if the message was sent by the current user.
  Message({
    required this.id,
    required this.profileId,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  /// ID of the message (UUID)
  final String id;

  /// ID of the profile that sent the message (UUID)
  final String profileId;

  /// Content of the message
  final String content;

  /// Date and time when the message was created
  final DateTime createdAt;

  /// Boolean that indicates if the message was sent by the current user
  final bool isMine;

  /// Creates a message from a map
  ///
  /// [map]      is the map that contains the message data.
  /// [myUserId] is the ID of the current user.
  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        profileId = map['profile_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['profile_id'];
}
