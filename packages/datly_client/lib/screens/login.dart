import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../widgets/title_bar.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController tokenController = TextEditingController();
  final FocusNode tokenFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    tokenController.addListener(() => setState(() {}));
    AuthManager.instance.initializeCompleter.future.then((_) {
      if (AuthManager.instance.authToken != null && mounted) {
        context.router.canPop()
            ? context.router.pop()
            : context.router.replacePath("/");
      }
    });
  }

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }

  bool submitLoading = false;
  String? submitErrorText;
  void submit() async {
    submitErrorText = null;
    final String token = tokenController.text;
    if (token.length != 6) {
      tokenFocusNode.requestFocus();
      return;
    }

    submitLoading = true;
    setState(() {});

    await AuthManager.instance.fetchAuthenticatedUser(token: token);

    submitLoading = false;
    submitErrorText = "Invalid token.";
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TitleBarTitle(),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 124),
          child: TextField(
            enabled: !submitLoading,
            onSubmitted: (_) => submit(),
            controller: tokenController,
            focusNode: tokenFocusNode,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9A-Za-z]")),
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    newValue.copyWith(text: newValue.text.toUpperCase()),
              ),
            ],
            maxLength: 6,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              errorText: submitErrorText,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  disabledColor: Theme.of(context).disabledColor,
                  onPressed: tokenController.text.length == 6 ? submit : null,
                  icon: Icon(Icons.chevron_right),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
