import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import '../models/subscriptionPlan.dart';
import 'package:http/http.dart' as http;

class Subscription extends StatefulWidget {
  static const routeName = '/subscriptions';
  final String url;
  const Subscription(this.url, {super.key});

  @override
  SubscriptionState createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription> {
  late final String url;
  late WebViewController _controller;

  int _loadingProgress = 0; // Add this variable to track progress

  @override
  void initState() {
    super.initState();
    url = widget.url;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress; // Update the loading progress
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            // final finalUrl = await getFinalUrl(request.url);
            return await getFinalUrl(request.url).then((finalUrl) {
              // debugPrint('Initial URL: ${request.url}');
              // debugPrint('Final URL: $finalUrl');
              if (!finalUrl.startsWith('https://')) {
                return NavigationDecision.prevent;
              } else if (request.url != finalUrl) {
                _controller.loadRequest(Uri.parse(finalUrl));
                return NavigationDecision.navigate;
              } else {
                _controller.loadRequest(Uri.parse(request.url));
                return NavigationDecision.navigate;
              }
            }).catchError((error) {
              // Handle any errors and prevent navigation
              return NavigationDecision.prevent;
            });
          },
          onPageStarted: (String finalUrl) {
            setState(() {
              _loadingProgress =
                  0; // Reset progress when a new page starts loading
            });
          },
          onPageFinished: (String finalUrl) {
            setState(() {
              _loadingProgress =
                  100; // Set progress to 100 when the page finishes loading
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  Future<String> getFinalUrl(String initialUrl) async {
    final response = await http.get(Uri.parse(initialUrl));
    return response.request?.url.toString() ?? initialUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: url.contains("portal")
            ? const Text('My Accout')
            : const Text('Subscription plans'),
        bottom: _loadingProgress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(23.0),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100.0,
                  backgroundColor: Colors.grey[200],
                  color: Colors.orangeAccent,
                ),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
