import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.gr.dart';
import '../widgets/title_bar.dart';
import 'terms.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  final String? initialEmail;
  const LoginScreen({super.key, @QueryParam("email") this.initialEmail});

  static ValueNotifier<double> childHeight = ValueNotifier(148);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _childHeightKey = GlobalKey();
  late final bool hasInitialEmail;

  final emailController = TextEditingController();
  String emailControllerTextOld = "";
  final emailFocusNode = FocusNode();

  final passwordController = TextEditingController();
  String passwordControllerTextOld = "";
  final passwordFocusNode = FocusNode();
  bool passwordObscured = true;

  final List<AuthUser> disallowedTokens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      final before = LoginScreen.childHeight.value;
      LoginScreen.childHeight.value =
          _childHeightKey.currentContext?.size?.height ?? before;
      if (LoginScreen.childHeight.value != before && kDebugMode) {
        if (kDebugMode) {
          print("LoginScreen.childHeight: ${LoginScreen.childHeight.value}");
        }
      }
    });

    if (widget.initialEmail != null &&
        emailRegex.hasMatch(Uri.decodeQueryComponent(widget.initialEmail!))) {
      hasInitialEmail = true;
      emailController.text = Uri.decodeQueryComponent(widget.initialEmail!);
    } else {
      hasInitialEmail = false;
    }

    emailController.addListener(() {
      final text = emailController.text;
      if (text == emailControllerTextOld) return;
      emailControllerTextOld = text;

      if (!AuthManager.instance.wasLastFetchNetworkError &&
          !disallowedTokens.map((u) => u.email).contains(text)) {
        submitErrorText = null;
        emailErrorText = null;
        if (mounted) setState(() {});
      }
    });
    passwordController.addListener(() {
      final text = passwordController.text;
      if (text == passwordControllerTextOld) return;
      passwordControllerTextOld = text;

      if (!AuthManager.instance.wasLastFetchNetworkError &&
          !disallowedTokens.map((u) => u.password).contains(text)) {
        submitErrorText = null;
        if (mounted) setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLocalizations = AppLocalizations.of(context);
      if (AuthManager.instance.wasLastFetchNetworkError) {
        submitErrorText = appLocalizations.loginError;
        if (mounted) setState(() {});
      } else if (AuthManager.instance.wasLastFetchAccountDisabledError) {
        submitErrorText = appLocalizations.loginAccountDisabled;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  bool submitLoading = false;
  String? submitErrorText;
  String? emailErrorText;

  void submit() async {
    final appLocalizations = AppLocalizations.of(context);

    submitErrorText = null;
    emailErrorText = null;
    if (mounted) setState(() {});

    final String email = emailController.text;
    final String password = passwordController.text;
    final authUser = (email: email, password: password);

    if (email.isEmpty) {
      emailFocusNode.requestFocus();
      return;
    } else if (password.isEmpty) {
      passwordFocusNode.requestFocus();
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      emailErrorText = appLocalizations.loginInvalidEmail;
      if (mounted) setState(() {});
      emailFocusNode.requestFocus();
      return;
    }

    submitLoading = true;
    if (mounted) setState(() {});

    // animation smoothing
    await Future.delayed(Durations.medium3);

    await AuthManager.instance.fetchAuthenticatedUser(user: authUser);
    if (!mounted || AuthManager.instance.authenticatedUser != null) return;

    submitLoading = false;
    submitErrorText = AuthManager.instance.wasLastFetchNetworkError
        ? appLocalizations.loginError
        : AuthManager.instance.wasLastFetchAccountDisabledError
        ? appLocalizations.loginAccountDisabled
        : appLocalizations.loginUnknown;
    disallowedTokens.add(authUser);

    setState(() {});
    (hasInitialEmail ? passwordFocusNode : emailFocusNode).requestFocus();

    Future.delayed(Duration(seconds: 3)).then((_) {
      disallowedTokens.remove(authUser);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final textFieldEmail = TextField(
      enabled: !submitLoading && !hasInitialEmail,
      autofocus: !hasInitialEmail,
      onSubmitted: (_) => submit(),
      controller: emailController,
      focusNode: emailFocusNode,
      autofillHints: [AutofillHints.email],
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: appLocalizations.loginEmailLabel,
        error: submitErrorText != null ? SizedBox.shrink() : null,
        errorText: emailErrorText,
        errorMaxLines: 3,
      ),
    );
    final textFieldPassword = TextField(
      enabled: !submitLoading,
      autofocus: hasInitialEmail,
      onSubmitted: (_) => submit(),
      controller: passwordController,
      focusNode: passwordFocusNode,
      autofillHints: [AutofillHints.password],
      obscureText: passwordObscured,
      maxLength: 128,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: appLocalizations.loginPasswordLabel,
        error: submitErrorText != null ? SizedBox.shrink() : null,
        counter: SizedBox.shrink(),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: () {
              passwordObscured = !passwordObscured;
              if (mounted) setState(() {});
            },
            icon: passwordObscured
                ? Icon(Icons.visibility_off_outlined)
                : Icon(Icons.visibility),
          ),
        ),
      ),
    );

    return Column(
      key: _childHeightKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4),
        textFieldEmail,
        SizedBox(height: 8),
        textFieldPassword,
        SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: Durations.medium1,
            curve: Curves.easeInOutCubicEmphasized,
            child: submitErrorText != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    child: Text(
                      submitErrorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  )
                : SizedBox(height: 8),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: submitLoading ? null : submit,
            icon: Icon(Icons.login),
            label: Text(appLocalizations.loginSubmit),
          ),
        ),
      ],
    );
  }
}

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static ValueNotifier<double> childHeight = ValueNotifier(215);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _childHeightKey = GlobalKey();

  final usernameController = TextEditingController();
  String usernameControllerTextOld = "";
  final usernameFocusNode = FocusNode();

  final emailController = TextEditingController();
  String emailControllerTextOld = "";
  final emailFocusNode = FocusNode();

  bool termsAcceptedState = false;

  final List<AuthUser> disallowedTokens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      final before = RegisterScreen.childHeight.value;
      RegisterScreen.childHeight.value =
          _childHeightKey.currentContext?.size?.height ?? before;
      if (RegisterScreen.childHeight.value != before && kDebugMode) {
        if (kDebugMode) {
          print(
            "RegisterScreen.childHeight: ${RegisterScreen.childHeight.value}",
          );
        }
      }
    });

    usernameController.addListener(() {
      final text = usernameController.text;
      if (text == usernameControllerTextOld) return;
      usernameControllerTextOld = text;

      if (!AuthManager.instance.wasLastFetchNetworkError &&
          !disallowedTokens.map((u) => u.password).contains(text)) {
        submitErrorText = null;
        usernameErrorText = null;
      }
      if (mounted) setState(() {});
    });
    emailController.addListener(() {
      final text = emailController.text;
      if (text == emailControllerTextOld) return;
      emailControllerTextOld = text;

      if (!AuthManager.instance.wasLastFetchNetworkError &&
          !disallowedTokens.map((u) => u.email).contains(text)) {
        submitErrorText = null;
        emailErrorText = null;
      }
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLocalizations = AppLocalizations.of(context);
      if (AuthManager.instance.wasLastFetchNetworkError) {
        submitErrorText = appLocalizations.loginError;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    usernameFocusNode.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  bool submitLoading = false;
  bool submitSuccess = false;
  String? submitErrorText;
  String? usernameErrorText;
  String? emailErrorText;

  void submit() async {
    final appLocalizations = AppLocalizations.of(context);

    submitErrorText = null;
    usernameErrorText = null;
    emailErrorText = null;
    if (mounted) setState(() {});

    final String username = usernameController.text;
    final String email = emailController.text;

    if (username.isEmpty) {
      usernameFocusNode.requestFocus();
      return;
    } else if (email.isEmpty) {
      emailFocusNode.requestFocus();
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9_]{3,16}$").hasMatch(username)) {
      usernameErrorText = appLocalizations.registerInvalidUsername;
      if (mounted) setState(() {});
      usernameFocusNode.requestFocus();
      return;
    } else if (!emailRegex.hasMatch(email)) {
      emailErrorText = appLocalizations.loginInvalidEmail;
      if (mounted) setState(() {});
      emailFocusNode.requestFocus();
      return;
    }

    submitLoading = true;
    if (mounted) setState(() {});

    // animation smoothing
    // await Future.delayed(Durations.medium3);
    if (!mounted) return;

    final String captchaToken;
    final turnstile = CloudflareTurnstile.invisible(
      siteKey: ApiManager.turnstileKey,
      baseUrl: Uri.base.toString(),
    );
    try {
      captchaToken = (await turnstile.getToken())!;
    } catch (_) {
      submitLoading = false;
      submitErrorText = appLocalizations.registerErrorCaptcha;
      if (mounted) setState(() {});
      return;
    } finally {
      turnstile.dispose();
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiManager.baseUri}/user/$username"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "projects": null,
          "role": null,
          "locale": appLocalizations.localeName,
          "captcha": captchaToken,
        }),
      );
      if (response.statusCode == 201) {
        submitLoading = false;
        submitSuccess = true;
        setState(() {});
        return;
      } else if (response.statusCode == 409) {
        if (response.body.toLowerCase().contains("username")) {
          usernameErrorText = appLocalizations.registerErrorConflictUsername;
        } else {
          emailErrorText = appLocalizations.registerErrorConflictEmail;
        }
      } else {
        submitErrorText = appLocalizations.loginUnknown;
      }
    } catch (_) {
      submitErrorText = appLocalizations.loginError;
    }

    submitLoading = false;
    setState(() {});
    emailFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final textFieldUsername = TextField(
      enabled: !submitLoading,
      autofocus: true,
      onSubmitted: termsAcceptedState ? (_) => submit() : null,
      controller: usernameController,
      focusNode: usernameFocusNode,
      autofillHints: [AutofillHints.newUsername],
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: appLocalizations.registerUsernameLabel,
        error: submitErrorText != null ? SizedBox.shrink() : null,
        errorText: usernameErrorText,
        errorMaxLines: 3,
      ),
    );
    final textFieldEmail = TextField(
      enabled: !submitLoading,
      onSubmitted: termsAcceptedState ? (_) => submit() : null,
      controller: emailController,
      focusNode: emailFocusNode,
      autofillHints: [AutofillHints.email],
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: appLocalizations.registerEmailLabel,
        error: submitErrorText != null ? SizedBox.shrink() : null,
        errorText: emailErrorText,
        errorMaxLines: 3,
      ),
    );
    final termsCheckbox = MediaQuery.removePadding(
      context: context,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text.rich(
          TextSpan(
            children: () {
              final text = appLocalizations.consentPolicy(
                "{privacyPolicy}",
                "{termsOfService}",
              );
              final matches = RegExp(
                r"(\{privacyPolicy\})|(\{termsOfService\})",
              ).allMatches(text);

              final children = <InlineSpan>[];
              var cursor = 0;
              for (final match in matches) {
                if (match.start > cursor) {
                  children.add(
                    TextSpan(text: text.substring(cursor, match.start)),
                  );
                }
                final isPrivacy = match.group(0) == "{privacyPolicy}";
                children.add(
                  TextSpan(
                    text: isPrivacy
                        ? appLocalizations.privacyPolicy
                        : appLocalizations.termsOfService,
                    style: TextStyle(
                      color: ColorScheme.of(context).primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => showMarkdownDialog(
                        context: context,
                        source: MarkdownDialogHttpSource(
                          Uri.parse(
                            "${ApiManager.baseUri.replace(path: "")}/legal/${isPrivacy ? "privacy" : "terms"}",
                          ),
                        ),
                      ),
                  ),
                );
                cursor = match.end;
              }
              if (cursor < text.length) {
                children.add(TextSpan(text: text.substring(cursor)));
              }
              return children;
            }(),
          ),
          style: TextTheme.of(context).bodyMedium!.copyWith(height: 1.2),
        ),
        value: termsAcceptedState,
        onChanged: (value) {
          termsAcceptedState = value ?? false;
          if (mounted) setState(() {});
        },
      ),
    );

    final form = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4),
        textFieldUsername,
        SizedBox(height: 8),
        textFieldEmail,
        SizedBox(height: 4),
        termsCheckbox,
        SizedBox(
          width: double.infinity,
          child: AnimatedSize(
            duration: Durations.medium1,
            curve: Curves.easeInOutCubicEmphasized,
            child: submitErrorText != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: Text(
                      submitErrorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  )
                : SizedBox(height: 4),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: submitLoading || !termsAcceptedState ? null : submit,
            icon: Icon(Icons.send),
            label: Text(appLocalizations.registerSubmit),
          ),
        ),
      ],
    );
    final success = Padding(
      padding: EdgeInsetsGeometry.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.lightGreen[900]!,
          ),
          SizedBox(height: 12),
          Text(
            appLocalizations.registerSuccess,
            style: TextTheme.of(context).titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            appLocalizations.registerSuccessDescription,
            style: TextTheme.of(context).labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return AnimatedSwitcher(
      key: _childHeightKey,
      duration: Durations.medium1,
      switchInCurve: Curves.easeInOutCubicEmphasized,
      switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
      child: submitSuccess ? success : form,
    );
  }
}

@RoutePage()
class LoginRegisterParentPage extends StatefulWidget {
  const LoginRegisterParentPage({super.key});

  @override
  State<LoginRegisterParentPage> createState() =>
      _LoginRegisterParentPageState();
}

class _LoginRegisterParentPageState extends State<LoginRegisterParentPage>
    with TickerProviderStateMixin {
  late final AnimationController sizeAnimationController;
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    sizeAnimationController = AnimationController(
      vsync: this,
      duration: Durations.extralong4,
    )..forward();

    LoginScreen.childHeight.addListener(onUpdate);
    RegisterScreen.childHeight.addListener(onUpdate);
  }

  @override
  void dispose() {
    sizeAnimationController.dispose();
    LoginScreen.childHeight.removeListener(onUpdate);
    RegisterScreen.childHeight.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => AutoTabsRouter.builder(
    homeIndex: 0,
    routes: [LoginRoute(), RegisterRoute()],
    builder: (context, children, pageController) {
      final tabsRouter = AutoTabsRouter.of(context);
      final appLocalizations = AppLocalizations.of(context);

      FadeTransition transitionBuilder(child, animation) {
        final oldIndex = tabsRouter.previousIndex;
        final newIndex = tabsRouter.activeIndex;
        final isNew = child.key == ValueKey(tabsRouter.activeIndex);
        if (oldIndex == null) return child;

        double offsetX = (oldIndex < newIndex) ? -0.5 : 0.5;
        if (isNew) offsetX = -offsetX;

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(offsetX, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      }

      final childHeight = tabsRouter.activeIndex == 0
          ? LoginScreen.childHeight.value
          : RegisterScreen.childHeight.value;
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(scale: 2, child: TitleBarTitle()),
                SizedBox(height: 24),
                Flexible(
                  child: AnimatedContainer(
                    duration: Durations.medium1,
                    curve: Curves.easeInOutCubicEmphasized,
                    constraints: BoxConstraints(
                      maxHeight: childHeight + 12 + 16,
                    ),
                    child: Card.filled(
                      margin: EdgeInsets.zero,
                      child: SizeTransition(
                        sizeFactor: CurveTween(
                          curve: Curves.easeInOutCubicEmphasized,
                        ).animate(sizeAnimationController),
                        child: AnimatedSwitcher(
                          duration: Durations.medium1,
                          switchInCurve: Curves.easeInOutCubicEmphasized,
                          switchOutCurve:
                              Curves.easeInOutCubicEmphasized.flipped,
                          transitionBuilder: transitionBuilder,
                          child: Padding(
                            key: ValueKey(tabsRouter.activeIndex),
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 12,
                              bottom: 16,
                            ),
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: childHeight,
                                ),
                                child: OverflowBox(
                                  alignment: Alignment.topCenter,
                                  maxHeight: double.infinity,
                                  child: children[tabsRouter.activeIndex],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ClipRRect(
                  child: AnimatedSwitcher(
                    duration: Durations.medium1,
                    switchInCurve: Curves.easeInOutCubicEmphasized,
                    switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
                    transitionBuilder: transitionBuilder,
                    child: ConstrainedBox(
                      key: ValueKey(tabsRouter.activeIndex),
                      constraints: BoxConstraints(maxWidth: 360 - 16 * 2),
                      child: SizedBox(
                        width: double.infinity,
                        child: tabsRouter.activeIndex == 0
                            ? OutlinedButton.icon(
                                onPressed: () => tabsRouter.setActiveIndex(1),
                                icon: Icon(Icons.chevron_right),
                                iconAlignment: IconAlignment.end,
                                label: Text(appLocalizations.loginRegister),
                              )
                            : OutlinedButton.icon(
                                onPressed: () => tabsRouter.setActiveIndex(0),
                                icon: Icon(Icons.chevron_left),
                                iconAlignment: IconAlignment.start,
                                label: Text(appLocalizations.registerLogin),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Builder(
                  builder: (context) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: appLocalizations.privacyPolicy,
                          style: TextStyle(fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => showMarkdownDialog(
                              context: context,
                              source: MarkdownDialogHttpSource(
                                Uri.parse(
                                  "${ApiManager.baseUri.replace(path: "")}/legal/privacy",
                                ),
                              ),
                            ),
                        ),
                        TextSpan(text: " • "),
                        TextSpan(
                          text: appLocalizations.termsOfService,
                          style: TextStyle(fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => showMarkdownDialog(
                              context: context,
                              source: MarkdownDialogHttpSource(
                                Uri.parse(
                                  "${ApiManager.baseUri.replace(path: "")}/legal/terms",
                                ),
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
    },
  );
}
