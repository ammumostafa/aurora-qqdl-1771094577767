import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFF000000),
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QQDL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFFffffff),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WebViewScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0a0a0a),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF00DC82),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Color(0xFF00DC82).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
                ),
                child: Icon(Icons.rocket_launch, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text('QQDL', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text('The easiest way to stream Hi-Res lossless FLACs.', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  // Custom CSS to inject for content blocking
  static const String _customCss = '''''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color(0xFFffffff))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onProgress: (p) => setState(() => _progress = p / 100),
        onPageFinished: (_) {
          setState(() => _isLoading = false);
          // Inject custom CSS to block content
          if (_customCss.isNotEmpty) {
            _controller.runJavaScript("""
              (function() {
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = `$_customCss`;
                document.head.appendChild(style);
              })();
            """);
          }
        },
      ))
      ..loadRequest(Uri.parse('https://tidal.qqdl.site/'));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (await _controller.canGoBack()) await _controller.goBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading) Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(value: _progress, backgroundColor: Colors.transparent, color: Color(0xFF00DC82))),
            ],
          ),
        ),
      ),
    );
  }
}