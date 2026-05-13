import 'package:flutter/material.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  static const routeName = '/checkout';

  const CheckoutScreen({super.key, required this.checkoutUrl});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _loadingProgress = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingProgress = 100;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.confirmExit(
          context,
          title: 'Leave Checkout?',
          message: 'You have an active checkout in progress. Are you sure you want to leave?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          bottom: _loadingProgress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4.0),
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orangeAccent,
                  ),
                )
              : null,
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
