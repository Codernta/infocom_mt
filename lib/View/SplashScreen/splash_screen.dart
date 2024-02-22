


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infocom_mt/View/HomeScreen/home_screen.dart';
import 'package:infocom_mt/View/WebViewScreen/web_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<Timer> loadData() async {
    return Timer(const Duration(milliseconds: 100), onDoneLoading);
  }


  onDoneLoading() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    bool dataVale = mPref.getBool('isData') ?? false;
    if (dataVale) {
      Get.to(() => const WebViewScreen());
    } else {
      Get.to(const HomeScreen());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xffF0FDFB),
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: const Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(color: Colors.purple,),
            ),
          ),
        ),
      ),
    );
  }
}

