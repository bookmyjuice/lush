import 'package:flutter/material.dart';
import 'package:lush/main.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class Subscription extends StatefulWidget {
  static const routeName = '/subscriptions';
  final SubscriptionPageUrlArgument args;

  const Subscription(this.args, {super.key});

// Subscription({super.key, required this.premium_page_url, required this.delight_page_url, required this.signature_page_url});

  @override
  SubscriptionState createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription> {
  late final String url;
  late WebViewController _controller;
  int _selectedIndex = 0; // Track selected toggle switch

  int _loadingProgress = 0; // Add this variable to track progress

  @override
  void initState() {
    super.initState();
    url = widget
        .args.premium_page_url; // Set the initial URL to the premium page URL

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
        padding: const EdgeInsets.all(2.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
              child: Expanded(
                  // height: MediaQuery.of(context).size.height - 136,
                  child: WebViewWidget(controller: _controller)),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ToggleSwitch(
                borderColor: [Colors.black45],
                borderWidth: 2.0,
                fontSize: 14.0,
                customWidths: [110, 110, 110],
                dividerColor: Colors.orangeAccent,
                centerText: true,
                dividerMargin: 10.0,
                animate: true,
                animationDuration: 300,
                cornerRadius: 20.0,
                activeBgColor: [Colors.orange.shade400],
                activeFgColor: Colors.black,
                inactiveBgColor: Colors.grey[300],
                initialLabelIndex: _selectedIndex,
                totalSwitches: 3,
                labels: const ['Premium', 'Signature', 'Delight'],
                onToggle: (index) {
                  setState(() {
                    _selectedIndex = index!;
                  });
                  switch (index) {
                    case 0:
                      _controller
                          .loadRequest(Uri.parse(widget.args.premium_page_url));
                      break;
                    case 1:
                      _controller.loadRequest(
                          Uri.parse(widget.args.signature_page_url));
                      break;

                    case 2:
                      _controller
                          .loadRequest(Uri.parse(widget.args.delight_page_url));
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
