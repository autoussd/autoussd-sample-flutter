import 'package:autoussdflutter/autoussdflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey();
  bool ready = true;

  _MyHomePageState() {
    // TODO #1 Setup AutoUssd listeners
    AutoUssdFlutter.getInstance().registerSessionCountListener((count) {
      debugPrint("Session count: $count");
    });

    AutoUssdFlutter.getInstance().registerSessionResultListener((result) {
      debugPrint(result.status.toString());

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
      }
    });
  }

  void completeTransaction(BuildContext context) {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;
      final number = values["recipientNumber"] as String;
      final amount = int.tryParse(values["amount"]) ?? 0;
      final reference = values["reference"] as String;

      // TODO #2: Call execute method on the AutoUssd SDK instance
      AutoUssdFlutter.getInstance().executeSession(
        "629e05e1751c102d57c53c0d",
        {
          "number": number,
          "amount": amount.toString(),
          "reference": reference,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AutoUssd Sample (Flutter)'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "AutoUssd Sample",
                  style: theme.textTheme.headline3?.copyWith(
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll be using this sample starting app to illustrate how to use the AutoUssd platform",
                  style: theme.textTheme.bodyText2,
                ),
                const SizedBox(height: 24),
                FormBuilder(
                  key: _formKey,
                  initialValue: const {
                    "recipientNumber": "",
                    "amount": "",
                    "reference": "",
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        name: "recipientNumber",
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          label: Text(
                            "Recipient number",
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: "Required",
                          ),
                        ]),
                        autofocus: true,
                      ),
                      const SizedBox(height: 24),
                      FormBuilderTextField(
                        name: "amount",
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          label: Text(
                            "Amount",
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: "Required",
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      FormBuilderTextField(
                        name: "reference",
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          label: Text(
                            "Reference",
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: "Required",
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      IgnorePointer(
                        ignoring: !ready,
                        child: AnimatedOpacity(
                          opacity: ready ? 1 : 0.5,
                          duration: const Duration(milliseconds: 350),
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                completeTransaction(context);
                              },
                              child: const Text(
                                "Complete Transaction",
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<List<Network>>(
                        future: AutoUssdFlutter.getInstance().getDeviceSimNetworks(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return const Text("None");
                            case ConnectionState.waiting:
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            case ConnectionState.active:
                              return const Text("Active");
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return Text(
                                  snapshot.error!.toString(),
                                  style: theme.textTheme.bodyText2?.copyWith(
                                    color: Colors.red,
                                  ),
                                );
                              } else {
                                final networks = snapshot.data!;
                                return Text(
                                  networks.fold(
                                    "Count: ${networks.length}",
                                    (acc, network) {
                                      return acc + " " + network.toMap().toString();
                                    },
                                  ),
                                );
                              }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
