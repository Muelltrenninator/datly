import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.router.navigatePath("/upload2"),
        child: Text("Hello, World!"),
      ),
    );
  }
}

@RoutePage()
class Upload2Page extends StatelessWidget {
  const Upload2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.router.navigatePath("/"),
        child: Text("Hello, World!"),
      ),
    );
  }
}
