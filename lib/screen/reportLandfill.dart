import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:myapp/network_utils/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as lct;

import 'chooseLocation.dart';


class HomePage extends StatefulWidget {
  @override 
  _HomePageState createState() => _HomePageState(); 
}

class _HomePageState extends State<HomePage> {
  // zadefinovvanie premenných a states pre radio buttny
  final _formKey = GlobalKey<FormState>();
  File _image;
  double longitude;
  double latitude;
  LatLng _mapData;
  String size;
  String access;
  String description;
  List<int> types = List<int>();
  int _radioValue1 = -1;
  int _radVal1, _radVal2, _radVal3 = 0;
  int _radioValue2 = -1;
  int _accVal1, _accVal2, _accVal3 = 0;
  int _radioValue3 = -1;
  int _posVal1, _posVal2 = 0;
  bool paper = false;
  bool plastic = false;
  bool iron = false;
  bool glass = false;
  bool mixed = false;
  bool construction = false;
  bool radioactiv = false;
  bool comunnal = false;
  bool wood = false;

  // funkcia na zobrazenie a handling vybrania fotky z galerie
  Future<void> _showPhotoLibrary() async {
    // ignore: deprecated_member_use
    final file = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 20 );
    setState(() {
      _image = file;
    });
  }

  // funkcia na zobrazenie a handling vybrania fotky z fotáku
  Future<void> _showCamera() async {
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 20 );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _image = imageFile;
    });
  }

  // funkcia na získanie dát aktuálnej polohy
  void _getCurrentPosition() async{
    lct.LocationData currentLocation;
    var location = new lct.Location();
    try {
      currentLocation = await location.getLocation();
      setState(() {
         longitude = currentLocation.longitude;
         latitude = currentLocation.latitude;
      });
    } on Exception {
      currentLocation = null;
      latitude = null;
      longitude = null;
    }
  }

  // inicializácia počiatočného stavu
  @override
  void initState() {
    _getCurrentPosition();
  }

  // modal okno pre zobrazenie menu na výber fotky camera/galéria
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 150,
          child: Column(children: <Widget>[
            ListTile(
              onTap: () {
                Navigator.pop(context); 
                _showCamera(); 
              },
              leading: Icon(Icons.photo_camera),
              title: Text("Odfotiť fografiu skládky")
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context); 
                _showPhotoLibrary(); 
              },
              leading: Icon(Icons.photo_library),
              title: Text("Vybrať fotografiu z galérie")
            )
          ])
        );
      }
    );
  }

  //TODO: doplnenie dizajnu
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
      child: Container(
          color: Colors.teal,
          child: Form(
            key: _formKey,
            child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,16,10,5),
                    child: Row(
                        children: [
                          Container(
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back, size: 30),
                            ),
                          ),
                            Expanded(
                              child : Center(
                                child: Container(
                                  child: Center(
                                    child: Text("Nahlás skládku", textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  )
                            ),
                          ),
                              ),
                        ),]
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Flexible(
                          child: ListTile(
                            title: const Text('Aktualna poloha'),
                            leading: Radio(value: _posVal1,
                              groupValue: _radioValue3,
                              autofocus: true,
                              onChanged: (value) {
                                _posVal1 = -1;
                                _posVal2 = 0;
                              _getCurrentPosition();
                              },
                            ),
                          ),
                        ),
                        new Flexible(
                          child: ListTile(
                            title: const Text('Vybrat inu polohu'),
                            leading: Radio(value: _posVal2,
                              groupValue: _radioValue3,
                              onChanged: (value) {
                                _posVal1 = 0;
                                _posVal2 = -1;
                                _awaitReturnOfPosition(context);
                              },
                            ),
                          ),
                        ),
                    ]
                  ),
                  Row(
                    children: <Widget> [
                      Container(
                        width: 400, // do it in both Container
                        child: Card(
                          elevation: 4.0,
                          color: Colors.white,
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 4,
                                    style: TextStyle(color: Color(0xFF000000),decoration: TextDecoration.underline),
                                    cursorColor: Color(0xFF9b9b9b),
                                    decoration: InputDecoration(
                                      border: new UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black87,
                                            width: 1.0, style: BorderStyle.solid)),
                                      hintText: "popis",
                                      hintStyle: TextStyle(
                                          color: Color(0xFF9b9b9b),
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    validator: (emailValue) {
                                      if (emailValue.isEmpty) {
                                        return 'Prosim vlozte popis';
                                      }
                                      setState(() {
                                        description = emailValue;
                                      });
                                      return null;
                                      },
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ]
                  ),
                  Row(
                    children: [
                      SafeArea(
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                constraints: BoxConstraints(minWidth: 300, maxWidth: 400, minHeight: 200, maxHeight: 220),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Container(
                                        child: _image == null ? Image.asset("assets/images/place-holder.jpg",width: 350, height: 210, fit: BoxFit.cover) :  Image.file(_image,width: 350, height: 210, fit: BoxFit.cover)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        Center(
                          child: FlatButton(
                            child: Text("Take Picture", style: TextStyle(color: Colors.white)),
                            color: Colors.green,
                            onPressed: () {
                              _showOptions(context);
                              },
                          ),
                        ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                      children: [
                        Container(
                            padding: EdgeInsets.only(left:16),
                            alignment: Alignment.topLeft,
                            child: Text("Velkost skladky")
                        ),
                        Row(
                          children: [
                            new Flexible(
                              child: ListTile(
                                title: const Text('do vreca'),
                                leading: Radio(value: _radVal1,
                                  groupValue: _radioValue1,
                                  autofocus: true,
                                  onChanged: (value) {
                                  setState(() {
                                    _radVal2 = 0;
                                    _radVal1 = -1;
                                    _radVal3 = 0;
                                    size = "do vreca";
                                  });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            new Flexible(
                              child: ListTile(
                                title: const Text('do furika'),
                                leading: Radio(value: _radVal2,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                  setState(() {
                                    _radVal2 = -1;
                                    _radVal1 = 0;
                                    _radVal3 = 0;
                                    size = "do furika";
                                  });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            new Flexible(
                              child: ListTile(
                                title: const Text('treba auto'),
                                leading: Radio(value: _radVal3,
                                  groupValue: _radioValue1,
                                  onChanged: (value) {
                                  setState(() {
                                    _radVal2 = 0;
                                    _radVal1 = 0;
                                    _radVal3 = -1;
                                    size = "treba auto";
                                  });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  Column(
                    children: [
                      Container(
                          padding: EdgeInsets.only(left:16),
                          alignment: Alignment.topLeft,
                          child: Text("Typ odpadu")
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Plast'),
                              value: plastic,
                              onChanged: (bool value) {
                                setState(() {
                                  plastic = value;
                                  if(plastic){
                                    types.add(2);
                                  }
                                  if(!plastic){
                                    types.remove(2);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Papier'),
                              value: paper,
                              onChanged: (bool value) {
                                setState(() {
                                  paper = value;
                                  if(paper){
                                    types.add(1);
                                  }
                                  if(!paper){
                                    types.remove(1);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Sklo'),
                              value: glass,
                              onChanged: (bool value) {
                                setState(() {
                                  glass = value;
                                  if(glass){
                                    types.add(3);
                                  }
                                  if(!glass){
                                    types.remove(3);
                                  }
                                });
                              },
                            ),
                          ),
                      ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Železo'),
                              value: iron,
                              onChanged: (bool value) {
                                setState(() {
                                  iron = value;
                                  if(iron){
                                    types.add(4);
                                  }
                                  if(!iron){
                                    types.remove(4);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Zmiešaný odpad'),
                              value: mixed,
                              onChanged: (bool value) {
                                setState(() {
                                  mixed = value;
                                  if(mixed){
                                    types.add(5);
                                  }
                                  if(!mixed){
                                    types.remove(5);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Stavebný odpad'),
                              value: construction,
                              onChanged: (bool value) {
                                setState(() {
                                  construction = value;
                                  if(construction){
                                    types.add(6);
                                  }
                                  if(!construction){
                                    types.remove(6);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Komunálny odpad'),
                              value: comunnal,
                              onChanged: (bool value) {
                                setState(() {
                                  comunnal = value;
                                  if(comunnal){
                                    types.add(7);
                                  }
                                  if(!comunnal){
                                    types.remove(7);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Rádioaktívny odpad'),
                              value: radioactiv,
                              onChanged: (bool value) {
                                setState(() {
                                  radioactiv = value;
                                  if(radioactiv){
                                    types.add(8);
                                  }
                                  if(!radioactiv){
                                    types.remove(8);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Lesnícky a poľnohospodársky odpad'),
                              value: wood,
                              onChanged: (bool value) {
                                setState(() {
                                  wood = value;
                                  if(wood){
                                    types.add(9);
                                  }
                                  if(!wood){
                                    types.remove(9);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                          padding: EdgeInsets.only(left:16),
                          alignment: Alignment.topLeft,
                          child: Text("Dostupnost")
                      ),
                      Row(
                        children: [
                          new Flexible(
                            child: ListTile(
                              title: const Text('Pešo'),
                              leading: Radio(value: _accVal1,
                                groupValue: _radioValue2,
                                onChanged: (value) {
                                  setState(() {
                                    _accVal2 = 0;
                                    _accVal1 = -1;
                                    _accVal3 = 0;
                                    access = "Pešo";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          new Flexible(
                            child: ListTile(
                              title: const Text('Autom'),
                              leading: Radio(value: _accVal2,
                                groupValue: _radioValue2,
                                onChanged: (value) {
                                  setState(() {
                                    _accVal2 = -1;
                                    _accVal1 = 0;
                                    _accVal3 = 0;
                                    access = "Autom";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          new Flexible(
                            child: ListTile(
                              title: const Text('Pešo do kopca'),
                              leading: Radio(value: _accVal3,
                                groupValue: _radioValue2,
                                onChanged: (value) {
                                  setState(() {
                                    _accVal2 = 0;
                                    _accVal1 = 0;
                                    _accVal3 = -1;
                                    access = "Pešo do kopca";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 8, bottom: 8, left: 10, right: 10),
                        child: Text('Odoslať',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      color: Colors.teal,
                      disabledColor: Colors.grey,
                      shape: new RoundedRectangleBorder(
                          borderRadius:
                          new BorderRadius.circular(20.0)),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _sendData();
                        }
                      },
                    ),
                  ),
                ]
            ),
          ),
        ),
        ),
    );
  }

  // handling vrátenia dát zo screenu chooseLocation
  void _awaitReturnOfPosition(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChooseLocation(),
        ));
    setState(() {
      _mapData = result;
      longitude = _mapData.longitude;
      latitude = _mapData.latitude;
    });
  }

  //funkcia na spracovanie dát z formuláru, odoslanie dát do databázy a spracovanie dát response
  // TODO: dokončenie post requestu na db
void _sendData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userId = localStorage.getInt("id");
    List<int> imageBytes = await _image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    var data = {
      "user_id": userId,
      "latitude": latitude,
      "longitude": longitude,
      "size": size,
      "access": access,
      "description": description,
      "junk_types": types,
      "image": base64Image
    };
    print(data);
    var res = await Network().addReportLandfill(data);
    print(res.statusCode);

    //var res = await Network().(data,"register");
    // if (res.statusCode == 201) {
    //   Navigator.push(
    //     context,
    //     new MaterialPageRoute(
    //         builder: (context) => Home()
    //     ),
    //   );
    // } else {
      // throw Exception(res.statusCode);
    // }

  }

}