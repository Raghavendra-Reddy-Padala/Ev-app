import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable, camel_case_types
class paymentWeb extends StatefulWidget {
  final url;
  const paymentWeb({super.key, required this.url});

  @override
  State<paymentWeb> createState() => _paymentWebState();
  String get getUrl => url;
}

class _paymentWebState extends State<paymentWeb> {
  late var controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
