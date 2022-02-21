import 'package:autoussdflutter/autoussdflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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

  // TODO #1: Declare AutoUssd SDK reference
  late final AutoUssdFlutter sdk;
  bool ready = true;

  _MyHomePageState() {
    // TODO #2 Setup AutoUssd SDK instance
    sdk = AutoUssdFlutter(
      (int count) {
        setState(() {
          ready = count > 0;
        });
      },
      (Result result) {
        if (result.status == ResultStatus.COMPLETED) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(result.lastContent ?? "Completed!"),
              );
            },
          );
        } else {
          debugPrint("Something went wrong! ${result.status}");
        }
      },
    );
  }

  void completeTransaction(BuildContext context) {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;
      final number = values["recipientNumber"] as String;
      final amount = int.tryParse(values["amount"]) ?? 0;
      final reference = values["reference"] as String;

      debugPrint("${{
        "Recipient number": number,
        "Amount": amount,
        "Reference": reference,
      }}");

      // TODO #3: Call execute method on the AutoUssd SDK instance
      sdk.executeSession(
        "60a53f240000000000000000",
        [number, amount.toString(), reference],
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
                                // TODO #3: Call execute method on the AutoUssd SDK instance
                                completeTransaction(context);
                              },
                              child: const Text(
                                "Complete Transaction",
                              ),
                            ),
                          ),
                        ),
                      )
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
