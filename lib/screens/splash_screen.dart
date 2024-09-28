import 'dart:async';

import 'package:code_gri/toast.dart';
import 'package:flutter/material.dart';
import 'package:code_gri/apis/apis.dart';
import 'package:code_gri/constants.dart';
import 'package:code_gri/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Apis apis = Apis();
  var dataList = [];
  var bannedList = [];
  var token = null;
  @override
  void initState() {
    super.initState();
    checkToken();
  }

  checkToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString("token");

    if (token == null)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login(null)));

    setState(() {});
  }

  int domainCount = 0,
      bannedDomainCount = 0,
      notBannedDomainCount = 0,
      checkedDomainCount = 0;
  var isLocationFailed = false;
  /*Future<void> makeRequest(String domain) async {
    try {
      final response = await http
          .get(Uri.parse(domain))
          .timeout(Duration(seconds: 30)); // Set a timeout of 10 seconds
      print("Domain == " + domain + " Resp ==" + response.body.toString());
      if (response.body.toString().contains("Code")) {
        notBannedDomainCount++;
      } else {
        bannedDomainCount++;
        addDomainToBanned(domain);
      }
      checkedDomainCount++;
      setState(() {});
    } on TimeoutException catch (e) {
      checkedDomainCount++;
      bannedDomainCount++;
      addDomainToBanned(domain);
      setState(() {});
    } catch (e) {
      checkedDomainCount++;
      bannedDomainCount++;
      addDomainToBanned(domain);
      setState(() {});
    }
  }*/
  Future<void> sendRequestsSequentially(List<dynamic> domains) async {
    for (String domain in domains) {
      var response = null;
      print(domain);
      try {
        response = await http
            .get(Uri.parse('http://${domain}'))
            .timeout(Duration(seconds: 30)); // Set a timeout of 10 seconds
        print(response.body!.toString());
        if (response.body!.toString().length > 5) {
          notBannedDomainCount++;
        } else {
          bannedDomainCount++;
          addDomainToBanned(domain);
        }
        checkedDomainCount++;
        setState(() {});
      } on TimeoutException catch (e) {
        checkedDomainCount++;
        bannedDomainCount++;
        addDomainToBanned(domain);
        setState(() {});
      } catch (e) {
        checkedDomainCount++;
        if (e.toString().indexOf("Failed host lookup:") != -1)
          bannedDomainCount++;
        else
          notBannedDomainCount++;
        addDomainToBanned(domain);
        setState(() {});
      }
    }
  }

  checkDomains() async {
    bannedDomainCount = 0;
    notBannedDomainCount = 0;
    checkedDomainCount = 0;
    dataList.clear();
    setState(() {});
    await apis.getAllDomains().then((value) {
      dataList = value['domains'];
      domainCount = dataList.length;
      setState(() {});
      if (dataList.length == 0) {
        showToast("Domains not found");
      }
      sendRequestsSequentially(dataList);
    });
  }

  addDomainToBanned(a) {
    var domainArr = a.toString().split('.');
    var bannedUrl = "";
    if (domainArr.length > 1) {
      bannedUrl = "${domainArr[1]}.${domainArr[2]}";
      if (bannedList.where((a) => a == bannedUrl).isEmpty) {
        bannedList.add(bannedUrl);
      }
    } else if (bannedList.where((d) => d == a).isEmpty) {
      bannedList.add(a);
    }
  }

  sendDomains() async {
    await apis.sendBanList(bannedList).then((value) {
      showToast("Saved successfully");
      bannedDomainCount = 0;
      notBannedDomainCount = 0;
      checkedDomainCount = 0;
      domainCount = 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Gri'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: token != null
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Image.asset("assets/images/logo-big.png"),
                        Text(
                            "To check the domains, please wait by pressing the button below."),
                      ],
                    ),
                  ),
                  if (checkedDomainCount < domainCount)
                    const SizedBox(
                      width: 30.0, // Set the desired width
                      height: 30.0, // Set the desired height
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text("${checkedDomainCount}/${domainCount} Checked"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("${bannedDomainCount} Banned"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("${notBannedDomainCount} Clean"),
                  const SizedBox(
                    height: 15,
                  ),
                  if (domainCount == 0 || checkedDomainCount == domainCount)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                          ),
                          onPressed: () {
                            checkDomains();
                          },
                          child: Text("Check"),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if (bannedDomainCount > 0)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            onPressed: () {
                              sendDomains();
                            },
                            child: Text("Send"),
                          )
                      ],
                    )
                ],
              ),
            )
          : Image.asset("assets/images/logo-big.png"),
      floatingActionButton: token != null
          ? FloatingActionButton(
              child: const Icon(Icons.logout),
              backgroundColor: kPrimaryColor,
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.clear();
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const Login(null))))
                    .then((value) {});
              },
            )
          : Text(""),
    );
  }
}
