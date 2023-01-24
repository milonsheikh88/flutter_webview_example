import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WebViewExample(),
      ),
    );

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;
  final String URL = 'https://flutter.dev/';

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(URL))
      ..addJavaScriptChannel('Toaster', onMessageReceived: (JavaScriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('Page started loading===>>> $url');
        },
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress===>>> $progress%)');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading===>>> $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Page resource error code===>>> ${error.errorCode}');
          debugPrint('description===>>> ${error.description}');
          debugPrint('errorType===>>> ${error.errorType}');
          debugPrint('isForMainFrame===>>> ${error.isForMainFrame}');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://m.youtube.com/') || request.url.startsWith('https://m.facebook.com/')) {
            debugPrint('Blocking navigation to===>>> ${request.url}');
            return NavigationDecision.prevent;
          }
          debugPrint('Allowing navigation to===>>> ${request.url}');
          return NavigationDecision.navigate;
        },
      ));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dev Tool'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
