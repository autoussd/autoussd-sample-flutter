import 'package:autoussdflutter/autoussdflutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AutoUssdFlutter sdk;
  bool ready = false;

  _MyHomePageState() {
    sdk = AutoUssdFlutter(
      (count) {
        setState(() {
          ready = count > 0;
        });
      },
      (result) {
        if (result.status == ResultStatus.COMPLETED) {
          Future.microtask(() {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                    result.lastContent ?? "Please wait for a confirmation message",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Ok"),
                    ),
                  ],
                );
              },
            );
          });
        } else {
          debugPrint("AutoUssd SDK Result Status: ${result.status}");
          debugPrint("AutoUssd SDK Result Session Id: ${result.sessionId}");
          debugPrint("AutoUssd SDK Result Description: ${result.description}");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AutoUssd Flutter Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 300,
                child: Text(
                  "Flutter app demonstrating the use of the AutoUssd Flutter plugin",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                width: 300,
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 36,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Tap on the button to check the remaining balance on your ",
                                ),
                                TextSpan(
                                  text: "Vodafone Cash wallet",
                                  style: theme.textTheme.bodyText2?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ready
                  ? SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          // Execute the session with this id
                          sdk.executeSession(
                            "60a53f240000000000000000",
                          );
                        },
                        child: const Text(
                          "Check Vodafone Momo Balance",
                        ),
                      ),
                    )
                  : const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
