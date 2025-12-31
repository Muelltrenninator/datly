import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../widgets/title_bar.dart';
import 'terms.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController sizeAnimationController;
  final TextEditingController tokenController = TextEditingController();
  final FocusNode tokenFocusNode = FocusNode();
  final List<String> disallowedTokens = [];

  @override
  void initState() {
    super.initState();
    tokenController.addListener(() {
      if (!disallowedTokens.contains(tokenController.text)) {
        submitErrorText = null;
      }
      if (mounted) setState(() {});
    });
    sizeAnimationController = AnimationController(
      vsync: this,
      duration: Durations.extralong4,
    )..forward();
  }

  @override
  void dispose() {
    tokenController.dispose();
    tokenFocusNode.dispose();
    sizeAnimationController.dispose();
    super.dispose();
  }

  bool submitLoading = false;
  String? submitErrorText;
  void submit() async {
    submitErrorText = null;
    final String token = tokenController.text;
    if (token.length != 8) {
      tokenFocusNode.requestFocus();
      return;
    }

    submitLoading = true;
    if (mounted) setState(() {});

    await AuthManager.instance.fetchAuthenticatedUser(token: token);
    if (!mounted) return;

    final appLocalizations = AppLocalizations.of(context);

    submitLoading = false;
    submitErrorText = AuthManager.instance.wasLastFetchNetworkError
        ? appLocalizations.loginError
        : appLocalizations.loginUnknown;
    disallowedTokens.add(token);
    setState(() {});

    Future.delayed(Duration(seconds: 3)).then((_) {
      disallowedTokens.remove(token);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(scale: 2, child: TitleBarTitle()),
              SizedBox(height: 24),
              Card.filled(
                child: SizeTransition(
                  sizeFactor: CurveTween(
                    curve: Curves.easeInOutCubicEmphasized,
                  ).animate(sizeAnimationController),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: 12,
                    ),
                    child: TextField(
                      enabled: !submitLoading,
                      autofocus: true,
                      onSubmitted: (_) => submit(),
                      controller: tokenController,
                      focusNode: tokenFocusNode,
                      autocorrect: false,
                      autofillHints: [],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp("[0-9A-Za-z]"),
                        ),
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                          ),
                        ),
                      ],
                      maxLength: 8,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context).loginCodeLabel,
                        errorText: submitErrorText,
                        errorMaxLines: 3,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            disabledColor: Theme.of(context).disabledColor,
                            onPressed:
                                tokenController.text.length == 8 &&
                                    !disallowedTokens.contains(
                                      tokenController.text,
                                    ) &&
                                    !submitLoading
                                ? submit
                                : null,
                            icon: Icon(Icons.chevron_right),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Builder(
                builder: (context) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${AppLocalizations.of(context).loginNewHere} ",
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context).loginNewHereRequest,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            Uri.parse(
                              // "mailto:me@jhubi1.com"
                              "https://docs.google.com/forms/d/e/1FAIpQLScFCNKhmlUcuR6qzyj0fR09a4BOwp4ZGzur9GvR0orLtP0rzg/viewform?usp=dialog",
                            ),
                          ),
                      ),
                      TextSpan(text: "\n"),
                      TextSpan(
                        text: AppLocalizations.of(context).loginPrivacyPolicy,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => showMarkdownDialog(
                            context: context,
                            origin: Uri.parse(
                              "${ApiManager.baseUri.replace(path: "")}/legal/privacy",
                            ),
                          ),
                      ),
                      TextSpan(text: " • "),
                      TextSpan(
                        text: AppLocalizations.of(context).loginTermsOfService,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => showMarkdownDialog(
                            context: context,
                            origin: Uri.parse(
                              "${ApiManager.baseUri.replace(path: "")}/legal/terms",
                            ),
                          ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
