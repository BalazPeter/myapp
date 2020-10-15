import 'dart:convert';
import 'dart:async' as async;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Network{
  final String url = 'http://bb9d8bb80904.ngrok.io/api/user/register';
  final headers = {    "Content-Type": "application/json",  };

  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
  }

  // authData(data) async {
  //   http.post(url,
  //       headers: headers,
  //       body: jsonEncode(data),
  //   );
  //   print(data);
  // }

  Future<http.Response> senData(data) async  {
    print(jsonEncode(data));
    final http.Response response = await http.post(url,
        headers: _setHeaders(),
        body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print("Haloooooooooo");
      print(response.body);
    } else {
      throw Exception(response.body);
    }
  }


  // Future<http.Response> LoginUser(data) async  {
  //   final http.Response response = await http.post('http://bb9d8bb80904.ngrok.io/api/user/login',
  //     headers: _setHeaders(),
  //     body: jsonEncode(data),
  //   );
  //   if (response.statusCode == 200) {
  //     print("Haloooooooooo");
  //     print(response.body);
  //   } else {
  //     throw Exception(response.body);
  //   }
  // }

  Future<http.Response> prd() async  {
    final http.Response response = await http.post('http://bb9d8bb80904.ngrok.io/api/test',
      headers: _setHeaders(),
      // body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print("Haloooooooooo");
      print(response.body);
    } else {
      throw Exception(response.body);
    }
  }


  // Future<http.Response> creatUsr(data) {
  //   return http.post(url,
  //     headers: headers,
  //     body: jsonEncode(data),
  //   );
  // }

  // makePostRequest(data) async {
  //   Response response = await post( url,
  //     headers: headers,
  //     body: jsonEncode(data));
  //   int statusCode = response.statusCode;
  //   String body = response.body;
  // }

  getData(apiUrl) async {
    var fullUrl = url;
    await _getToken();
    return await http.get(
        fullUrl,
        headers: _setHeaders()
    );

  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMDY2YTQ2NDcwYzdlY2I0ZWYzMDVmOTU4NGY2ZTQ0N2YxMDA3YjY3MDVmOTZmNjU0OWQ5NDg4MmQxMjQ2ZjQ1ZDQwMGJjYzUwNzY3NTE4NmIiLCJpYXQiOjE2MDI3NTEzODgsIm5iZiI6MTYwMjc1MTM4OCwiZXhwIjoxNjM0Mjg3Mzg4LCJzdWIiOiIxMSIsInNjb3BlcyI6W119.KlAWK5_QJfXl5I-FdYiADmghGx7OO7xfu6_hs8jNBHpc91dONEaamUlvsMeSeW3JTWzhmnkA8bCQvESvt7kI6dZQpg-HdmU3wT650ehDCI5g1bGNkSfdAtSS4J4-_xnz1R-QAh-y0oCU4tsG6g1HiXxAab0EQk6QNC4gVganDW6ylruluxWRTEq4Rh1PaIDWc8jetkYpPaiK77X_YhQzUuk1jPipjmcOe7XN3DcJmASw6m1lqOmLfoXiW_DN7POBpAWslO55mMyrS4Muk7AEIKL1P8pa3G0_LmXUXAw9IuEj5r7dRJ765QXNQwACLqA99RvSPpjBPBSOgjXruGH1gXeHRwJfcovRxgZx3hfHi7IO2LXDIXq6TkWOP4nsSqTB_FiIG4-RdXlEQ8J7vKzM0z8JbLRk-y0dE3aOittvb89VZN4kLIiglqHpRL_ka1fS1fJJKY8TpN7jlTpe9VC--8PLxAmM7gK32B09hbrasonqmLbSwtTbkRAL0H2-W96Lx5CaviQc2nUmS5AAkuSKc3CwYQ8-uezOjN7sF7ErSbUv8v'
  };

}