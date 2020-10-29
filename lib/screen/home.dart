import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screen/addEvent.dart';
import 'package:myapp/screen/login.dart';
import 'package:myapp/network_utils/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lct;

import 'home_page.dart';
import 'listOfEvents.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;
  String name;
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(22.521563, -125.677433);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool dumps = false;
  bool collectionYard = false;
  bool cleanEvents = false;


  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*Checking if your App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }


  void _onMapTypeButtonPressed() async {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed (){
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'This is the title',
          snippet: 'This is the snippet',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
      );
    });
  }

  _onCameraMove(CameraPosition position) async{
    var prd = position.target;
    setState(() {
      _lastMapPosition = prd;
    });
  }


  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    lct.LocationData currentLocation;
    var location = new lct.Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }


  @override
  void initState(){
    _loadUserData();
    requestLocationPermission();
    super.initState();
    _currentLocation();
    _markers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(40.7128, -74.0060)));
  }

  _loadUserData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('username'));
    if(user != null) {
      setState(() {
        name = user;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 10.0,
            ),
            onCameraMove: _onCameraMove,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "CurrentLocation",
                onPressed: _currentLocation,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: const Icon(Icons.location_searching, size: 36.0),
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: new FloatingActionButton(
                heroTag: "MaptypeButton",
                onPressed: () {
                  _showFilterMenu(context);
                },
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: const Icon(Icons.filter_alt_outlined, size: 36.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
                child: FloatingActionButton(
                  heroTag: "MenuButton",
                  onPressed: _openEndDrawer,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  child: const Icon(Icons.menu_rounded, size: 36.0),
                ),
            ),)
         ],
        ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80.0,
              child: Center(
                child: DrawerHeader(
                  child: Text('Drawer Header'),
                  decoration: BoxDecoration(
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_pin_rounded),
              title: Text('Profil'),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.mail),
              title: Text('Kontakt'),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(Icons.login_outlined),
              title: Text('Odhlásiť sa'),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
    bottomNavigationBar: BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: SizedBox(
        height: 48,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.free_breakfast_rounded, size: 36,),
              onPressed: () {},
            ),
            IconButton(
                icon: Icon(Icons.view_module, size: 36,),
              onPressed: () {},
            ),
            IconButton(
                icon: Icon(Icons.map, size: 36,),
              onPressed: () {
                _onAddMarkerButtonPressed();
              },
            ),
            IconButton(
              icon: Icon(Icons.add_a_photo, size: 36,),
              onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> HomePage()));
                  }
            )
          ],
        ),
      ),
    ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 600,
              child: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, size: 30),
                      ),
                    ),
                    Container(
                      child: Center(
                          child: Text("Filter", textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )
                      ),
                    ),
                    Container(
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.done, size: 30),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: const Text('Mapa'),
                  leading: Radio(value: 0,
                    autofocus: true,
                    onChanged: (value) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    groupValue: 0,
                  ),
                ),
                ListTile(
                  title: const Text('Zoznam'),
                  leading: Radio(value: 1,
                    groupValue: 0,
                    onChanged: (value) {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ListOfEvents()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                  child: Divider(
                    color: Colors.teal,
                    thickness: 2,
                  ),
                ),
                Row(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                              value: dumps,
                              onChanged: (value) {
                                setState(() {
                                  dumps = value;
                                });
                                _onDumpEvents(dumps);
                              }
                          ),
                          Text("Skladky"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                              value: collectionYard,
                              onChanged: (value) {
                                setState(() {
                                  collectionYard = value;
                                });
                                _onCollectionYard(collectionYard);
                              }                          ),
                          Text("Zberne dvory"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                              value: cleanEvents,
                              onChanged: (value) {
                                setState(() {
                                  cleanEvents = value;
                                });
                                _onCleanEvents(cleanEvents);
                              }                          ),
                          Text("Clean eventy")
                        ],
                      ),
                    ])
              ]),
            );
          }
          );
        });
  }

  void _onDumpEvents(bool newValue) => setState(() {
    dumps = newValue;

    if (dumps) {
      // TODO: Here goes your functionality that remembers the user.
      print("prd");
    } else {
      // TODO: Forget the user
      print("prd2");
    }

  });
  void _onCollectionYard(bool newValue) => setState(() {
    collectionYard = newValue;

    if (collectionYard) {
      // TODO: Here goes your functionality that remembers the user.
      print("prd");

    } else {
      // TODO: Forget the user
      print("prd2");
    }
  });
  void _onCleanEvents(bool newValue) => setState(() {
    cleanEvents = newValue;

    if (cleanEvents) {
      // TODO: Here goes your functionality that remembers the user.
      print("prd");
    } else {
      // TODO: Forget the user
      print("prd2");
    }
  });

    void logout() async {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var userId = localStorage.getInt("id");
      var data = {'id': userId};
      var res = await Network().logoutUser(data, "logout");
      if (res.statusCode == 200) {
        localStorage.remove('id');
        localStorage.remove('name');
        localStorage.remove('token');
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()));
      }
      else
        throw Exception(res.body);
    }

}
