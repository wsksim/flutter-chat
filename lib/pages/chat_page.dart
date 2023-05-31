import 'dart:async';

import 'package:flutter/material.dart';

import 'package:chatgram/models/message.dart';
import 'package:chatgram/models/profile.dart';
import 'package:chatgram/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

/// Chat page to display messages
///
/// This page is the main page of the app. It displays the messages in a list
/// and allows the user to send new messages.
///
/// Examples:
/// ```dart
/// Navigator.of(context).push(ChatPage.route());
/// ```
///
/// ```dart
/// Navigator.of(context).pushAndRemoveUntil(ChatPage.route(), (route) => false);
/// ```
///
class ChatPage extends StatefulWidget {
  /// Creates a chat page
  const ChatPage({Key? key}) : super(key: key);

  /// Creates a route for the chat page
  ///
  /// This is used to navigate to the chat page.
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  /// Creates the mutable state for this widget
  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// Creates the mutable state for this widget
///
/// This is where the messages are loaded from Supabase and displayed in a list.
///
/// The messages are loaded from Supabase using a stream. This means that the
/// messages will be updated in real time.
///
/// The messages are displayed in a [ListView] with a [StreamBuilder]. The
/// [StreamBuilder] will listen to the stream and rebuild the [ListView] when
/// new messages are received.
///
class _ChatPageState extends State<ChatPage> {
  /// The stream of messages
  late final Stream<List<Message>> _messagesStream;
  /// Cache of profiles
  final Map<String, Profile> _profileCache = {};

  /// The controller for the message text field
  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myUserId))
            .toList());
    super.initState();
  }

  /// Loads the profile from Supabase and caches it
  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = Profile.fromMap(data);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  /// Creates the mutable state for this widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('Start your conversation now :)'),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            /// I know it's not good to include code that is not related
                            /// to rendering the widget inside build method, but for
                            /// creating an app quick and dirty, it's fine 😂
                            _loadProfileCache(message.profileId);

                            return _ChatBubble(
                              message: message,
                              profile: _profileCache[message.profileId],
                            );
                          },
                        ),
                ),
                const _MessageBar(),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
///
/// This widget is used to display the text field and button to submit a new
/// message.
///
/// The text field is a [TextFormField] with a [TextEditingController]. The
/// controller is used to get the text from the text field.
///
/// The button is a [TextButton] that calls [_submitMessage] when pressed.
///
/// Examples:
/// ```dart
/// const _MessageBar();
/// ```
///
class _MessageBar extends StatefulWidget {
  /// Creates a message bar
  const _MessageBar({
    Key? key,
  }) : super(key: key);

  /// Creates the mutable state for this widget
  @override
  State<_MessageBar> createState() => _MessageBarState();
}

/// Creates the mutable state for this widget
///
/// This is where the message is submitted to Supabase.
///
/// The message is submitted to Supabase when the send button is pressed.
///
class _MessageBarState extends State<_MessageBar> {
  /// The controller for the message text field
  late final TextEditingController _textController;

  /// Submits the message
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the mutable state for this widget
  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  /// Disposes the controller
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Submits the message
  ///
  /// This method submits the message to Supabase.
  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'content': text,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

/// A widget that displays a message
///
/// This widget is used to display a message in the chat.
class _ChatBubble extends StatefulWidget {
  /// Creates a chat bubble
  ///
  /// [message] is the message to display
  /// [profile] is the profile of the message sender
  const _ChatBubble({
    Key? key,
    required this.message,
    required this.profile,
  }) : super(key: key);

  /// The message to display
  final Message message;

  /// The profile of the message sender
  final Profile? profile;

  /// Creates the mutable state for this widget
  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

/// Creates the mutable state for this widget
///
/// This is where the messages are loaded from Supabase and displayed in a list.
///
class _ChatBubbleState extends State<_ChatBubble> {
  /// Deletes the message
  void _deleteMessage() async {
    if (widget.message.isMine && !widget.message.isDeleted) {
      try {
        await supabase.from('messages').update({
          'is_deleted': true,
        }).eq('id', widget.message.id);
      } on PostgrestException catch (error) {
        context.showErrorSnackBar(message: error.message);
      } catch (_) {
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }
  /// Creates the mutable state for this widget
  @override
  Widget build(BuildContext context) {
    if (widget.message.isDeleted) {
      return const SizedBox();
    }
    List<Widget> chatContents = [
      if (!widget.message.isMine)
        CircleAvatar(
          child: widget.profile == null
              ? preloader
              : const Icon(
                  Icons.person,
                  color: Colors.white,
          )
        ),
      /// add option to delete message
      const SizedBox(width: 12),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: (){
                if (widget.message.isMine) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Message'),
                        content: const Text('Are you sure you want to delete this message?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteMessage();
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.message.isMine
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.message.content),
              ),
            ),
            Text(
              widget.message.isMine ? 'You' : widget.profile?.username ?? 'Unknown',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Text(format(widget.message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (widget.message.isMine) {
      chatContents = chatContents.reversed.toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
        widget.message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
