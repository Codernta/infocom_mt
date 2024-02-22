import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infocom_mt/Utils/utils.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final WebViewController _webViewController;
  bool _downloading = false;
  String? _dir;
  bool isDownloaded = false;
  List<String> _content = [];
  List<String> _tempContent = [];
  final String _zipPath =
      'https://gametesting.in/flutter_test/Machine_test_build_V01.zip';
  final String _localZipFileName = 'content.zip';
  String filePath = '';

  @override
  void initState() {
    super.initState();
    _downloading = false;
    _webViewController = WebViewController();
    _initDir();
  }

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<File> _downloadFile(String url, String fileName) async {
    var req = await http.Client().get(Uri.parse(url));
    var file = File('$_dir/$fileName');
    return file.writeAsBytes(req.bodyBytes);
  }

  Future<void> _downloadZip() async {
    setState(() {
      _downloading = true;
    });
    _content.clear();
    var zippedFile = await _downloadFile(_zipPath, _localZipFileName);
    await unarchiveAndSave(zippedFile);

    setState(() {
      _content.addAll(_tempContent);
      _content.map((value) {
        if(value.contains("index.html")){
          saveFilePath(value);
        } else {
          print('not found');
        }
      }).toList();
      _downloading = false;
      isDownloaded = true;
    });
  }

  unarchiveAndSave(var zippedFile) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);
        _tempContent.add(outFile.path);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
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
      body: homeBody(),
    );
  }

  homeBody() {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: isDownloaded ? webView() : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            divideSizedBox(),
            hiText(),
            divideSizedBox(),
            downloadButton()
          ],
        ),
      ),
    );
  }

  hiText() {
    return const Text(
      'Hi,\nPress The Button To Download\nThe Zip File To View.',
      style: primaryStyle,
    );
  }

  divideSizedBox() {
    return const SizedBox(
      height: 100,
    );
  }

  downloadButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          bool hasInternetConnection = await InternetConnectionChecker()
              .hasConnection;
          if(hasInternetConnection){
            _downloadZip();
          }
          else{
           Get.snackbar('', 'No Internet Connection!');
          }
        } ,
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: Colors.purple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          padding: const EdgeInsets.all(25.0),
        ),

        child: _downloading ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.purple,)) :const Text(
          'Download',
          style: primaryStyle,
        ),
      ),
    );
  }

  webView() {

     return WebViewWidget(controller: _webViewController);

  }

  void saveFilePath(filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('filePath', filePath);
    prefs.setBool('isData', true);
    _webViewController.loadFile(filePath);
  }
}
