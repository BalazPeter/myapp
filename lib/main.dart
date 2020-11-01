import 'package:flutter/material.dart';
import 'package:myapp/screen/login.dart';
import 'package:myapp/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // Tento widget je root aplikácie
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleanway',
      debugShowCheckedModeBanner: false,
      home: CheckAuth(),
    );
  }
}
// Volanie triedy v konštruktore checkauth
class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }
// načítanie tokenu z pamäte telefónu ak je null tak sa nič nestane
  void _checkIfLoggedIn() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if(token != null){
      setState(() {
        isAuth = true;
      });
    }
  }
  // vytvorenie build metody na presmerovanie
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      child = Home();
    } else {
      child = Login();
    }
    return Scaffold(
      body: child,
    );
  }
}