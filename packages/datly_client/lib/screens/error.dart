import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../main.gr.dart';

@RoutePage()
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.call_missed_outgoing, size: 48),
              SizedBox(height: 8),
              Text(
                "Unknown Route",
                style: TextTheme.of(context).headlineSmall!.copyWith(height: 1),
              ),
              Text(
                "The route \"${context.router.currentPath}\" does not exist.",
                maxLines: 3,
              ),
              SizedBox(height: 16),
              context.router.canPop()
                  ? FilledButton.icon(
                      onPressed: () => context.router.pop(),
                      label: Text("Go Back"),
                      icon: Icon(Icons.arrow_back),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => context.router.navigate(MainRoute()),
                      label: Text("Go Home"),
                      icon: Icon(Icons.home),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
