import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MyAccountPage extends StatefulWidget {
  static const routeName = '/myaccount';
  final String url;

  const MyAccountPage(this.url, {super.key});

// Subscription({super.key, required this.premium_page_url, required this.delight_page_url, required this.signature_page_url});

  @override
  MyAccountPageState createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  late final String url;
  late WebViewController _controller;
  int _selectedIndex = 0; // Track selected toggle switch

  int _loadingProgress = 0; // Add this variable to track progress

  @override
  void initState() {
    super.initState();
    url = widget.url; // Set the initial URL to the premium page URL

    // if (!url.contains("http")) {
    //   toastification.show(
    //     icon: const Icon(Icons.error),
    //     closeButton: ToastCloseButton(),
    //     alignment: Alignment.center,
    //     title: Text(url),
    //     description: Text(url),
    //     type: ToastificationType.error,
    //   );
    // } else {
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
    // }
  }

  Future<String> getFinalUrl(String initialUrl) async {
    final response = await http.get(Uri.parse(initialUrl));
    return response.request?.url.toString() ?? initialUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accout'),
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
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Expanded(
                // height: MediaQuery.of(context).size.height - 136,
                child: WebViewWidget(controller: _controller))
          ],
        ),
      ),
    );
  }
}
