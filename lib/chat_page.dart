import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({Key? key, required String contact}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    print(args);
      return Scaffold(
        appBar: AppBar(
          title:  Text("Це чатик $args"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(FontAwesomeIcons.rightFromBracket),
              tooltip: 'Вихїд',
              onPressed: () {
                Navigator.of(context)
                    .pushReplacementNamed('/auth')
                // we dont want to pop the screen, just replace it completely
                    .then((_) => false);
              },
            )
          ],
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 60.2,
          toolbarOpacity: 0.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)),
          ),
          elevation: 0.00,
          backgroundColor: Colors.greenAccent[400],
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.leftRight),
            tooltip: 'Спiсок',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Chat(
          l10n: const ChatL10nUk(),
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      );
}
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }
}

