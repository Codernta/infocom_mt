import 'package:flutter/material.dart';
import 'package:infocom_mt/Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewcontroller;

  String filePath = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _webViewcontroller = WebViewController();
    getPrefData();
  }

  getPrefData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    filePath = sharedPreferences.getString('filePath').toString();
    _webViewcontroller.loadFile(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        toolbarHeight: 70,
        title: const Text(
          'WebView',
          style: primaryStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: webViewBody(),
    );
  }

  webViewBody() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: WebViewWidget(controller: _webViewcontroller),
    );
  }
}
