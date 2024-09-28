import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:code_gri/apis/apis.dart';
import 'package:code_gri/screens/main.dart';
import 'package:code_gri/screens/splash_screen.dart';
import 'package:code_gri/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../constants.dart';

class Login extends StatefulWidget {
  const Login(Key? key) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }

  Apis apis = Apis();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool isPermissionDenied = false;
  onLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await apis.login(email.text, password.text).then((value) {
      pref.setString('token', value['token']);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SplashScreen()));
    });
  }

  Timer? _timer;
  checkLocationPermitted() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (Platform.isAndroid) {
          PermissionStatus
              permissionStatus; // note do not use PermissionStatus? permissionStatus;
          permissionStatus = await Permission.locationWhenInUse.request();
          if (permissionStatus != PermissionStatus.granted) {
            isPermissionDenied = true;
            setState(() {});
            _timer?.cancel();
          }
        } else {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            isPermissionDenied = false;
            setState(() {});
            _timer?.cancel();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
          centerTitle: true,
          backgroundColor: kPrimaryColor,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(25),
                child: Image.asset("assets/images/logo-big.png"),
              ),
              TextFormField(
                controller: email,
                obscureText: false,
                decoration: const InputDecoration(
                  hintText: 'User Name',
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: kPrimaryColor,
                ),
                onPressed: () => this.onLogin(),
                child: Ink(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    width: 200,
                    alignment: Alignment.center,
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
