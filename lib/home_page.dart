import 'dart:async';

import 'package:akkhara_gpt/api/api.dart';
import 'package:akkhara_gpt/theme/appcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isUser;
  final Widget? sender;

  Message({required this.text, required this.isUser, this.sender});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool isLoading = false;
  StreamController<String> _typingController = StreamController<String>();

  Future<void> _generateText() async {
    final prompt = _controller.text;
    setState(() {
      _messages.add(Message(text: prompt, isUser: true));
      isLoading = true;
    });
    _controller.clear();
    final response = await GeminiApi.generativeText(prompt);
    _startTypingAnimation(response ?? '');
  }

  void _startTypingAnimation(String response) {
    _typingController = StreamController<String>();
    _messages.add(Message(
      text: '',
      isUser: false,
      sender: const CircleAvatar(
        backgroundImage: AssetImage('assets/akkharagpt.jpg'),
      ),
    ));
    int index = _messages.length - 1;
    int charIndex = 0;

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (charIndex < response.length) {
        _typingController.add(response.substring(0, charIndex + 1));
        charIndex++;
      } else {
        timer.cancel();
        setState(() {
          isLoading = false;
        });
      }
    });

    _typingController.stream.listen((partialText) {
      setState(() {
        _messages[index] = Message(
          text: partialText,
          isUser: false,
          sender: const CircleAvatar(
            backgroundImage: AssetImage('assets/akkharagpt.jpg'),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _typingController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          'AkkharaGPT',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: message.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!message.isUser && message.sender != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: message.sender!,
                        ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? AppColors.blackblur
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      filled: true,
                      fillColor: AppColors.blackblur,
                      prefixIcon: const RotationTransition(
                        turns: AlwaysStoppedAnimation(270 / 360),
                        child: Icon(
                          Icons.attachment,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      suffixIcon: isLoading
                          ? Container(
                              margin: const EdgeInsets.all(10),
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'assets/think.gif',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: _generateText,
                              icon: const Icon(
                                CupertinoIcons.arrow_up_circle_fill,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      hintText: 'Message AkkharaGPT',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
