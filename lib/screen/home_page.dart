import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:myapp/network_utils/api.dart';
import 'package:myapp/screen/take_picture_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  @override 
  _HomePageState createState() => _HomePageState(); 
}

class _HomePageState extends State<HomePage> {
  String _path;
  final _formKey = GlobalKey<FormState>();
  File _image;

  void _showPhotoLibrary() async {
    // ignore: deprecated_member_use
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    // List<int> imageBytes = await file.readAsBytes();
    // String base64Image = base64Encode(imageBytes);
    setState(() {
      _image = file;
    });
  }

  // void _showCamera() async {
  //   File file = await ImagePicker.pickImage(source: ImageSource.camera , imageQuality: 20 );
  //   print(file);
  //   // List<int> imageBytes = await file.readAsBytes();
  //   // String base64Image = base64Encode(imageBytes);
  //   // var res = await Network().userRegistration(data);
  //   // print(res);
  //
  //   setState(() {
  //     _image = file;
  //   });
  // }

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
              title: Text("Take a picture from camera")
            ), 
            ListTile(
              onTap: () {
                Navigator.pop(context); 
                _showPhotoLibrary(); 
              },
              leading: Icon(Icons.photo_library),
              title: Text("Choose from photo library")
            )
          ])
        );
      }
    );
  }
  // Widget build(BuildContext context) {
  //   return DefaultTextStyle(
  //       style: Theme
  //           .of(context)
  //           .textTheme
  //           .bodyText2,
  //       child: LayoutBuilder(
  //           builder: (BuildContext context,
  //               BoxConstraints viewportConstraints) {
  //             return SingleChildScrollView(
  //               child: ConstrainedBox(
  //                 constraints: BoxConstraints(
  //                   minHeight: viewportConstraints.maxHeight,
  //
  //                 ),
  //               ),
  //             );
  //           }
  //       )
  //   );
  // }
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
                            leading: Radio(value: 0,
                              autofocus: true,
                              onChanged: (value) {
                              },
                              groupValue: 0,
                            ),
                          ),
                        ),
                        new Flexible(
                          child: ListTile(
                            title: const Text('Vybrat inu polohu'),
                            leading: Radio(value: 1,
                              groupValue: 0,
                              onChanged: (value) {
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
                                leading: Radio(value: 0,
                                  autofocus: true,
                                  onChanged: (value) {
                                  },
                                  groupValue: 0,
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
                                leading: Radio(value: 1,
                                  groupValue: 0,
                                  onChanged: (value) {
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
                                leading: Radio(value: 2,
                                  groupValue: 0,
                                  onChanged: (value) {
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

                      ),
                    ],
                  ),

                ]
            ),
          ),
        ),
        ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       body: Container(
  //         color: Colors.teal,
  //         child: SafeArea(
  //           child: Column(children: <Widget>[
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(0,30.0,0,0),
  //               child: Form(
  //                 key: _formKey,
  //                 child: Column(
  //                 children: <Widget>[
  //                   Card(
  //                     elevation: 4.0,
  //                     color: Colors.white,
  //                     margin: EdgeInsets.only(left: 20, right: 20, top: 20),
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(15)),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(10.0),
  //                       child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: <Widget>[
  //                             TextFormField(
  //                               style: TextStyle(color: Color(0xFF000000)),
  //                               cursorColor: Color(0xFF9b9b9b),
  //                               keyboardType: TextInputType.text,
  //                               decoration: InputDecoration(
  //                                 prefixIcon: Icon(
  //                                   Icons.house,
  //                                   color: Colors.grey,
  //                                 ),
  //                                 hintText: "popis",
  //                                 hintStyle: TextStyle(
  //                                     color: Color(0xFF9b9b9b),
  //                                     fontSize: 15,
  //                                     fontWeight: FontWeight.normal),
  //                               ),
  //                               validator: (emailValue) {
  //                                 if (emailValue.isEmpty) {
  //                                   return 'Prosim vlozte popis';
  //                                 }
  //                                 return null;
  //                               },
  //                             ),
  //                           ]),
  //                     ),
  //                   ),
  //                   Center(
  //                     child: Container(
  //                       constraints: BoxConstraints(minWidth: 450, maxWidth: 500, minHeight: 200, maxHeight: 220),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(16.0),
  //                         child: Center(
  //                           child: Container(
  //                               child: _image == null ? Image.asset("assets/images/place-holder.jpg",width: 450, height: 210, fit: BoxFit.cover) :  Image.file(_image,width: 450, height: 210, fit: BoxFit.cover)
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   FlatButton(
  //                     child: Text("Take Picture", style: TextStyle(color: Colors.white)),
  //                     color: Colors.green,
  //                     onPressed: () {
  //                       _showOptions(context);
  //                     },
  //                   ),
  //                 ]
  //                 ),
  //               ),
  //             ),
  //         ]),
  //     ),
  //       )
  //   );
  // }

}