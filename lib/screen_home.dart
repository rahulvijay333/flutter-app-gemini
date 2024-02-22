import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemni_app/chat_model.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final TextEditingController chatTextEditingController =
      TextEditingController();

  final List<MessageModel> messagelist = [];
  bool loading = false;
  bool errorHappened = false;
  String errorMessage = '';

  final gemini = Gemini.instance;
  ScrollController scrollController = ScrollController();

  askGemini(String query) {
    gemini.text(query).then((value) {
      final message = MessageModel(
          name: 'gemini', message: value!.content!.parts![0].text!);

      setState(() {
        messagelist.add(message);
        loading = false;
        errorHappened = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll to the bottom after the ListView updates
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
      });
    }).catchError((e) {
      final message = MessageModel(
          name: 'gemini', message: 'Error occured , please try again');
      setState(() {
        errorMessage = e.toString();
        errorHappened = true;
        loading = false;
        messagelist.add(message);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Gemini'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  messagelist.clear();
                });
              },
              icon: const Icon(Icons.clear_all))
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: messagelist.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(10),
                      controller: scrollController,
                      itemCount: messagelist.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messagelist[index].name,
                                style: TextStyle(
                                    color: messagelist[index].name == 'user'
                                        ? Colors.blue
                                        : Colors.green),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                messagelist[index].message,
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('Ask Gemini'),
                    )),
          loading == true
              ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  ),
                )
              : errorHappened == true
                  ? const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    )
                  : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextFormField(
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      controller: chatTextEditingController,
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: 'type questions here....',
                          focusedBorder: InputBorder.none),
                    ),
                  ),
                ),
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final message = MessageModel(
                          name: 'user',
                          message: chatTextEditingController.text);

                      setState(() {
                        messagelist.add(message);
                        loading = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollController.jumpTo(
                          scrollController.position.maxScrollExtent,
                        );
                      });
                      askGemini(chatTextEditingController.text.trim());
                      chatTextEditingController.clear();
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }
}
