import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'terms.dart';

typedef ValidatePageGridCoordinate = ({int x, int y});

@RoutePage()
class ValidatePage extends StatefulWidget {
  const ValidatePage({super.key});

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final List<String> imageIds = [
    "4372912a13f14e84844dfd5714b4a41f",
    "0192af9f2e4847958ecf93b24050644e",
    "1cecb8606227425eb713c0d154e9ec79",
    "5e9c5eff1d3f4ab698d6d738328804af",
    "11505faf99394aaf91bb1a2d4d810adc",
    "4a86eaf786fd4378a90ea07d6343d59f",
    "2537de5d47f44225852c06e5b844e795",
    "0488fd942bcb45b1b730aab5adff8d1b",
    "4a86eaf786fd4378a90ea07d6343d59f",
    "0192af9f2e4847958ecf93b24050644e",
    "0488fd942bcb45b1b730aab5adff8d1b",
    "1a258243dcc84d21a927f47833999359",
    "2f85f92d5d89478c9334eec37665fb54",
    "7da3b46e30a349098bb240f7d5edd5d5",
    "f976a3502acc4fb4b9624c63ae0ed4e8",
    "4372912a13f14e84844dfd5714b4a41f",
    "ca5afaa7f1ac42ebbbe2550b3dc5324b",
    "d874634d221944998db0db9583b44b9e",
    "659a79e758ef4534b0c7ca32776113b7",
    "59c52103458b46aa98108ad7e29ddb1c",
    "8ccbf3c2645447f4ae2461c87ab7b40e",
    "49300491e3964bacb242a20c656efe82",
  ];
  late final List<List<String>> images;

  @override
  void initState() {
    super.initState();
    images = List.generate(
      3,
      (_) => List.generate(
        3,
        (_) => imageIds[math.Random().nextInt(imageIds.length)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height;
    final windowSizeClass = WindowSizeClass.of(context);

    final child = Padding(
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
              appLocalizations.validatePleaseSelect,
              style: theme.textTheme.titleMedium!.copyWith(
                height: 1,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Text(
            "Biomüll",
            style: theme.textTheme.displayMedium!.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.1,
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
                        ValidatePageGrid(
                          itemBuilder: (context, coordinate) => Card(
                            clipBehavior: Clip.antiAlias,
                            margin: EdgeInsets.all(2),
                            child: Image.network(
                              "https://datly.con.bz/api/assets/${images[coordinate.x][coordinate.y]}.png",
                              fit: BoxFit.cover,
                              scale: MediaQuery.devicePixelRatioOf(context),
                              width: 128,
                              height: 128,
                            ),
                          ),
                          onTap: (value) {
                            images[value.x][value.y] =
                                imageIds[math.Random().nextInt(
                                  imageIds.length,
                                )];
                            if (mounted) setState(() {});
                          },
                        ),
                        SizedBox(height: 4),
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
                                        .copyWith(fontWeight: FontWeight.bold),
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
                                    style: DefaultTextStyle.of(context).style
                                        .copyWith(fontWeight: FontWeight.bold),
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
        ],
      ),
    );

    return Stack(
      children: [
        SizedBox.expand(child: child),
        Align(
          alignment: Alignment.bottomRight,
          child: Transform.translate(
            offset: Offset(-16, -16),
            child: AnimatedSwitcher(
              duration: Durations.medium1,
              switchInCurve: Curves.easeInOutCubicEmphasized,
              switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
              transitionBuilder: (child, animation) => SlideTransition(
                position: (Tween<Offset>(
                  begin: Offset(0, 1.1),
                  end: Offset(0, 0),
                )).animate(animation),
                child: child,
              ),
              child:
                  true // controller != null
                  ? (windowSizeClass < WindowSizeClass.medium
                        ? Row.new
                        : Column.new)(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: null,
                          child: Icon(Icons.refresh),
                        ),
                        SizedBox.square(dimension: 8),
                        FloatingActionButton.large(
                          onPressed: () {},
                          child: Icon(Icons.send),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class ValidatePageGrid extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ValidatePageGridCoordinate coordinate,
  )
  itemBuilder;
  final ValueChanged<ValidatePageGridCoordinate>? onTap;

  const ValidatePageGrid({super.key, required this.itemBuilder, this.onTap});

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
