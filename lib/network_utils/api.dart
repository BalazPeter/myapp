import 'dart:convert';
import 'dart:async' as async;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Network{
  final String url = 'http://cleanway.sk/api/user/';
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
  }

  Future<http.Response> userRegistration(data, endUrl) async  {
    var finalUrl = url + endUrl;
    final http.Response response = await http.post(finalUrl,
      headers: _setHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<http.Response> loginUser(data, endUrl) async {
    var finalUrl = url + endUrl;
    final http.Response response = await http.post(finalUrl,
        headers: {'Content-type' : 'application/json', 'Accept' : 'application/json'},
        body: jsonEncode(data)
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(response.statusCode);
    }
  }


  Future<http.Response> logoutUser(data, apiUrl) async {
    var fullUrl = url + apiUrl;
    final http.Response response = await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: {'Content-type' : 'application/json',
          'Accept' : 'application/json'}
          );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(response.statusCode);
    }
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };

}