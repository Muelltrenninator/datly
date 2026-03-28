import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../registry.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/snackbar.dart';

final _rng = math.Random.secure();

typedef PayloadData = ({
  String category,
  String displayCategory,
  List<String> items,
  List<String> knownNegatives,
});
typedef Payload = ({
  Completer<String> payload,
  Completer<PayloadData> payloadData,
  List<String> shown,
  List<String> clicked,
  List<List<NetworkImage?>> images,
});

final _skeletonOptions = SwitchAnimationConfig(
  duration: Durations.medium1,
  switchInCurve: Curves.easeInOutCubicEmphasized,
  switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
);
PaintingEffect _skeletonEffect(BuildContext context) {
  final colorScheme = ColorScheme.of(context);
  return ShimmerEffect(
    baseColor: colorScheme.surfaceContainerLow,
    highlightColor: colorScheme.surfaceContainer,
  );
}

@RoutePage()
class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage>
    with TickerProviderStateMixin {
  final confettiController = ConfettiController();

  bool error = false;
  bool allDone = false;
  bool disableRefresh = false;

  bool _loadLock = false;
  Completer<void> clickBlocker = Completer()..complete();
  ({int x, int y})? lastClickedCoordinate;

  final List<Payload> payloads = [];
  final List<String> backlogIsLoadingFor = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadPayload(false));
  }

  NetworkImage _img(BuildContext context, String id) {
    final scale = MediaQuery.devicePixelRatioOf(context);
    return NetworkImage("${ApiManager.baseUri}/assets/$id", scale: scale);
  }

  Future<void> loadPayload([bool delay = true]) async {
    if (_loadLock) return;
    _loadLock = true;

    if (payloads.isNotEmpty) {
      payloads.removeAt(0);
      if (mounted) setState(() {});
    }
    for (var i = 0; i < (2 - payloads.length); i++) {
      final payload = Completer<String>();
      final payloadData = Completer<PayloadData>();
      payloads.add((
        payload: payload,
        payloadData: payloadData,
        shown: [],
        clicked: [],
        images: List.generate(3, (_) => []),
      ));

      await Future.delayed(delay ? Durations.extralong1 : Durations.medium1);

      final data = await _loadPayloadInternal();
      if (data == null) {
        payloads.removeAt(payloads.length - 1);
        continue;
      }

      if (!mounted) return;
      for (var s in data.payloadData.items) {
        await precacheImage(_img(context, s), context);
      }

      final selected = [];
      for (var i = 0; i < 4; i++) {
        String? imageId;
        while (imageId == null || selected.contains(imageId)) {
          imageId =
              data.payloadData.knownNegatives[_rng.nextInt(
                data.payloadData.knownNegatives.length,
              )];
        }
        selected.add(imageId);
      }
      for (var i = 0; i < 5; i++) {
        String? imageId;
        while (imageId == null ||
            selected.contains(imageId) ||
            data.payloadData.knownNegatives.contains(imageId)) {
          imageId = data
              .payloadData
              .items[_rng.nextInt(data.payloadData.items.length)];
        }
        selected.add(imageId);
      }

      selected.shuffle(_rng);
      if (!mounted) return;
      payloads.singleWhere((p) => p.payload == payload).images
        ..[0] = [for (var i = 0; i < 3; i++) _img(context, selected[i])]
        ..[1] = [for (var i = 3; i < 6; i++) _img(context, selected[i])]
        ..[2] = [for (var i = 6; i < 9; i++) _img(context, selected[i])];
      for (var s in selected) {
        payloads.singleWhere((p) => p.payload == payload).shown.add(s);
      }
      clickBlocker = Completer()..complete();
      payload.complete(data.payload);
      payloadData.complete(data.payloadData);

      if (mounted) setState(() {});
    }
    _loadLock = false;
  }

  Future<({String payload, PayloadData payloadData})?>
  _loadPayloadInternal() async {
    final response = await AuthManager.instance.fetch(
      http.Request(
        "POST",
        Uri.parse("${ApiManager.baseUri}/validation/create"),
      ),
    );
    if (response?.statusCode != 200) {
      if (response?.statusCode == 409) {
        allDone = true;
      } else {
        error = true;
      }
      if (mounted) setState(() {});
      return null;
    }
    allDone = false;
    error = false;

    try {
      final body = jsonDecode(response!.body);
      final jwt = JWT.decode(body["payload"]);

      if (!mounted) return null;
      final preDisplayCategory = CategoryData.preName(
        context: context,
        name: jwt.payload["category"],
      );
      final displayCategory =
          preDisplayCategory ??
          (await CategoryRegistry.instance.get(
            jwt.payload["category"],
          ))?.resolveDisplayName() ??
          jwt.payload["category"] as String;

      return (
        payload: body["payload"] as String,
        payloadData: (
          category: jwt.payload["category"] as String,
          displayCategory: displayCategory,
          items: List<String>.from(jwt.payload["items"] as List),
          knownNegatives: List<String>.from(
            jwt.payload["knownNegatives"] as List,
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _fillBacklog() async {
    final response = await AuthManager.instance.fetch(
      http.Request("POST", Uri.parse("${ApiManager.baseUri}/validation/extend"))
        ..body = jsonEncode({"payload": await payloads.first.payload.future}),
    );
    if (response?.statusCode != 200) {
      if (response?.statusCode == 409) {
        allDone = true;
      } else {
        error = true;
      }
      if (mounted) setState(() {});
      return;
    }
    allDone = false;
    error = false;

    try {
      final body = jsonDecode(response!.body);
      final jwt = JWT.decode(body["payload"]);

      final newId = (jwt.payload["items"] as List).firstWhere(
        (item) => !payloads.first.shown.contains(item),
        orElse: () => null,
      );
      if (!mounted) return;
      if (newId == null) {
        setState(() {});
        return;
      }

      backlogIsLoadingFor.add(newId);
      precacheImage(_img(context, newId), context).then((_) {
        backlogIsLoadingFor.remove(newId);
        if (mounted) setState(() {});
      });

      payloads.first = (
        payload: Completer()..complete(body["payload"]),
        payloadData: Completer()
          ..complete((
            category: jwt.payload["category"] as String,
            displayCategory:
                (await payloads.first.payloadData.future).displayCategory,
            items: List<String>.from(jwt.payload["items"] as List),
            knownNegatives: List<String>.from(
              jwt.payload["knownNegatives"] as List,
            ),
          )),
        shown: payloads.first.shown,
        clicked: payloads.first.clicked,
        images: payloads.first.images,
      );
    } catch (e) {
      error = true;
    }
    if (mounted) setState(() {});
  }

  Future<void> _reportSubmission(({int x, int y}) coordinates) async {
    if (payloads.first.images[coordinates.x][coordinates.y] == null) {
      return;
    }

    final id = (payloads.first.images[coordinates.x][coordinates.y])!.url
        .split("/")
        .last;
    final payload = payloads.first.payload.future;

    final appLocalizations = AppLocalizations.of(context);
    if (!(await showConfirmationDialog(
      context: context,
      icon: Icon(Icons.flag),
      title: appLocalizations.validationReportDialogTitle,
      description: appLocalizations.validationReportDialogMessage,
    ))) {
      return;
    }
    if (!context.mounted) return;
    loadPayload();

    final response = await AuthManager.instance.fetch(
      http.Request(
        "POST",
        Uri.parse("${ApiManager.baseUri}/validation/report/$id"),
      )..body = jsonEncode({"payload": await payload}),
    );

    if (response?.statusCode == 200) {
      if (!mounted) return;
      showBetterSnackbar(context, appLocalizations.validationReported);
    }
  }

  Future<void> _submitValidation(
    Payload payload, [
    bool isRetry = false,
  ]) async {
    if (!isRetry) loadPayload();
    if (payload.clicked.isEmpty) return;

    final response = await AuthManager.instance.fetch(
      http.Request("POST", Uri.parse("${ApiManager.baseUri}/validation/submit"))
        ..body = jsonEncode({
          "payload": await payload.payload.future,
          "shown": payload.shown,
          "clicked": payload.clicked,
        }),
    );
    if (mounted) confettiController.launch();

    if (response?.statusCode != 200) {
      if (!mounted) return;
      final appLocalizations = AppLocalizations.of(context);
      showBetterSnackbar(
        context,
        appLocalizations.validationSubmissionFailed,
        actionLabel: appLocalizations.retry,
        onAction: () => _submitValidation(payload, true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height;
    final windowSizeClass = WindowSizeClass.of(context);

    Widget allDoneWidget() => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_add_check, size: 48),
          SizedBox(height: 16),
          Text(
            appLocalizations.validationAllDone,
            textAlign: TextAlign.center,
            style: TextTheme.of(context).headlineSmall!.copyWith(height: 1),
          ),
          SizedBox(height: 2),
          Text(
            appLocalizations.validationAllDoneDescription,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              allDone = false;
              if (mounted) setState(() {});
              loadPayload(false);
            },
            label: Text(AppLocalizations.of(context).validationAllDoneRecheck),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
    );

    Widget child() {
      Widget itemBuilder(BuildContext context, ({int x, int y}) coordinate) {
        Widget tmp = Skeleton.leaf(
          key: ValueKey(
            (payloads.firstOrNull?.payloadData.isCompleted ?? false) &&
                    payloads.first.images[coordinate.x][coordinate.y] != null
                ? payloads.first.images[coordinate.x][coordinate.y]!.url
                : "none",
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(2),
            child:
                (payloads.firstOrNull?.payloadData.isCompleted ?? false) &&
                    payloads.first.images[coordinate.x][coordinate.y] != null
                ? Image(
                    image: payloads.first.images[coordinate.x][coordinate.y]!,
                    fit: BoxFit.cover,
                    width: 128,
                    height: 128,
                  )
                : SizedBox(width: 128, height: 128),
          ),
        );

        tmp = AnimatedSwitcher(
          duration: Durations.long2,
          switchInCurve: Curves.easeInOutCubic.flipped,
          switchOutCurve: Curves.easeInOutCubic,
          child: tmp,
        );
        return Skeletonizer(
          enabled:
              !(payloads.firstOrNull?.payloadData.isCompleted ?? false) ||
              backlogIsLoadingFor.contains(
                payloads.firstOrNull?.images[coordinate.x][coordinate.y]?.url
                    .split("/")
                    .last,
              ),
          enableSwitchAnimation: true,
          switchAnimationConfig: _skeletonOptions,
          effect: _skeletonEffect(context),
          child: tmp,
        );
      }

      void onTap(({int x, int y}) value) async {
        if (payloads.first.images[value.x][value.y] == null ||
            (!clickBlocker.isCompleted && lastClickedCoordinate == value)) {
          return;
        }
        lastClickedCoordinate = value;
        final completer = Completer();
        clickBlocker = completer;

        final id = (payloads.first.images[value.x][value.y])!.url
            .split("/")
            .last;
        if (payloads.first.clicked.contains(id)) return;
        payloads.first.clicked.add(id);

        if (payloads.first.shown.length ==
            (await payloads.first.payloadData.future).items.length) {
          // giving up on filling the backlog
          payloads.first.images[value.x][value.y] = null;
          clickBlocker.complete();
          if (mounted) setState(() {});
          return;
        }

        final items = (await payloads.first.payloadData.future).items;
        String? newId;
        while (newId == null || payloads.first.shown.contains(newId)) {
          newId = items[_rng.nextInt(items.length)];
        }

        if (!context.mounted) return;
        payloads.first.images[value.x][value.y] = _img(context, newId);
        payloads.first.shown.add(newId);

        _fillBacklog();
        if (mounted) setState(() {});

        await Future.delayed(Durations.medium3);
        if (clickBlocker == completer) {
          clickBlocker.complete();
        }
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: windowSizeClass < WindowSizeClass.medium ? 0 : 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: height <= 800
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, 4),
              child: Text(
                appLocalizations.validationPleaseSelect,
                style: theme.textTheme.titleMedium!.copyWith(
                  height: 1,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            FutureBuilder(
              future: payloads.firstOrNull?.payloadData.future,
              builder: (context, snapshot) => Skeletonizer(
                enabled:
                    snapshot.data?.displayCategory == null ||
                    !(payloads.firstOrNull?.payloadData.isCompleted ?? false),
                enableSwitchAnimation: true,
                switchAnimationConfig: _skeletonOptions,
                effect: _skeletonEffect(context),
                child: Text(
                  snapshot.data?.displayCategory ?? "Stand In",
                  style: theme.textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            SizedBox(height: windowSizeClass < WindowSizeClass.medium ? 8 : 24),
            Flexible(
              child: FittedBox(
                fit: BoxFit.contain,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 28 + 3 * 128),
                  child: Card.outlined(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValidationPageGrid(
                            itemBuilder: itemBuilder,
                            onTap: onTap,
                            onLongPress: _reportSubmission,
                          ),
                          SizedBox(height: 6),
                          DefaultTextStyle(
                            style: theme.textTheme.labelMedium!.copyWith(
                              color: theme.disabledColor,
                            ),
                            child: Builder(
                              builder: (context) => Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: appLocalizations.privacyPolicy,
                                      style: DefaultTextStyle.of(context).style
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => context.pushRoute(
                                          MarkdownDialogPrivacyPolicyRoute(),
                                        ),
                                    ),
                                    TextSpan(text: " • "),
                                    TextSpan(
                                      text: appLocalizations.termsOfService,
                                      style: DefaultTextStyle.of(context).style
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => context.pushRoute(
                                          MarkdownDialogTermsOfServiceRoute(),
                                        ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (windowSizeClass <= WindowSizeClass.medium)
              SizedBox(height: math.max((height - 800) / 2 + 36, 0)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: Durations.medium1,
          switchInCurve: Curves.easeInOutCubicEmphasized,
          switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
          child: !error
              ? (allDone && payloads.isEmpty
                    ? Center(key: ValueKey("allDone"), child: allDoneWidget())
                    : SizedBox.expand(child: child()))
              : Center(
                  key: ValueKey("error"),
                  child: Icon(Icons.error_outline, size: 48),
                ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Transform.translate(
            offset: Offset(-16, -16),
            child: AnimatedSwitcher(
              duration: Durations.extralong1,
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic.flipped,
              transitionBuilder: (child, animation) => SlideTransition(
                position: (Tween<Offset>(
                  begin: Offset(0, 1.1),
                  end: Offset(0, 0),
                )).animate(animation),
                child: child,
              ),
              child:
                  !error &&
                      (payloads.firstOrNull?.payloadData.isCompleted ?? false)
                  ? (windowSizeClass < WindowSizeClass.medium
                        ? Row.new
                        : Column.new)(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: disableRefresh
                              ? null
                              : () async {
                                  disableRefresh = true;
                                  if (mounted) setState(() {});

                                  await Future.wait([
                                    loadPayload(),
                                    Future.delayed(Durations.extralong1),
                                  ]);
                                  disableRefresh = false;
                                  if (mounted) setState(() {});
                                },
                          child: Icon(Icons.refresh),
                        ),
                        SizedBox.square(dimension: 8),
                        FloatingActionButton.large(
                          onPressed: () => _submitValidation(payloads.first),
                          child: Icon(Icons.send),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        IgnorePointer(
          child: SizedBox.expand(
            child: Confetti(
              controller: confettiController,
              options: ConfettiOptions(x: 1, y: 1, angle: 115),
            ),
          ),
        ),
      ],
    );
  }
}

class ValidationPageGrid extends StatelessWidget {
  final Widget Function(BuildContext context, ({int x, int y}) coordinate)
  itemBuilder;
  final ValueChanged<({int x, int y})>? onTap;
  final ValueChanged<({int x, int y})>? onLongPress;

  const ValidationPageGrid({
    super.key,
    required this.itemBuilder,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxHeight, constraints.maxWidth);
          return Stack(
            children: [
              for (var x = 0; x < 3; x++)
                for (var y = 0; y < 3; y++)
                  Positioned(
                    left: x * size / 3,
                    top: y * size / 3,
                    width: size / 3,
                    height: size / 3,
                    child: GestureDetector(
                      onTap: () => onTap?.call((x: x, y: y)),
                      onLongPress: () => onLongPress?.call((x: x, y: y)),
                      child: itemBuilder(context, (x: x, y: y)),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
