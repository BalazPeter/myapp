import 'dart:convert';
import 'dart:async' as async;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Network{
  // zadefinované globálne premenné v triede
  final String url = 'http://cleanway.sk/api/user/';
  final String urlJunkjard = 'http://cleanway.sk/api/junkjard';
  var token;

  // funkcia na ziskanie tokenu z pamäte telefónu
  // TODO: overenie proti null
  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
  }
  // post request na registráciu používateľa
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
  // post request na prihlásenie používateľa
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

  // post request na odhlásenie používateľa
  Future<http.Response> logoutUser(data, apiUrl) async {
    var fullUrl = url + apiUrl;
    final http.Response response = await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: {'Content-type' : 'application/json',
          'Accept' : 'application/json'}
          );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(response.statusCode);
    }
  }
  // Odosielanie/nahlásovanie skládky do databázy
  Future<http.Response> addReportLandfill (data) async {
    _getToken();
    print(token);
    final http.Response response = await http.post(
        urlJunkjard,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception(response.statusCode);
    }
  }
  //getter pre nastavenie headru s autorizáciou
  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };

}