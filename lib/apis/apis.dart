import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:code_gri/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class Apis {
  String lang = 'tr-TR';
  String baseUrl = 'https://system.codegri.com:8443', serviceName = 'User';
  Future login(String email, String password) async {
    String finalUrl = '$baseUrl/Login';
    var params = {
      'userName': email.toString(),
      'password': md5.convert(utf8.encode(password.toString())).toString()
    };
    var result = await http.post(Uri.parse(finalUrl),
        body: jsonEncode(params),
        headers: {'Content-Type': 'application/json', 'lang': lang});
    var body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      return body;
    } else {
      showToast("something went wrong");
      throw Exception("Something went wrong");
    }
  }

  Future getAllDomains() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/clean-domains-full';
    var result = await http.post(Uri.parse(finalUrl), headers: {
      'Content-Type': 'application/json',
      'Authorization': pref.getString('token').toString()
    });
    var body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      return body;
    } else {
      showToast("something went wrong");
      throw Exception("Something went wrong");
    }
  }

  Future sendBanList(dynamic banList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String finalUrl = '$baseUrl/ban-domain-full';

    var params = {"domains": banList};

    var result = await http
        .post(Uri.parse(finalUrl), body: jsonEncode(params), headers: {
      'Content-Type': 'application/json',
      'Authorization': pref.getString('token').toString()
    });
    print(result.body);
    var body = jsonDecode(result.body);
    if (result.statusCode == 200) {
      return body;
    } else {
      showToast("something went wrong");
      throw Exception("Something went wrong");
    }
  }
}
