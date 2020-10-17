import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screen/login.dart';
import 'package:myapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lct;

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
    print(_currentMapType);
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
    print(user);
    if(user != null) {
      setState(() {
        name = user;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CleanWay')),
        backgroundColor: Colors.green,
      ),
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
              child: Column(
                children: <Widget> [
                  new FloatingActionButton(
                    heroTag: "btn1",
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.map, size: 36.0),
                  ),
                  SizedBox(height: 16.0),
                  new FloatingActionButton(
                    heroTag: "btn2",
                    onPressed: () => _onAddMarkerButtonPressed(),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add_location, size: 36.0),
                  ),
                  SizedBox(height: 16.0),
                  new FloatingActionButton(
                    heroTag: "btn3",
                    onPressed: _currentLocation,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.location_on, size: 36.0),
                  ),
                ],
              ),
            ),
          ),
        ],
        )
    );
  }

  //     Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Text('Hi, $name',
  //             style: TextStyle(
  //                 fontWeight: FontWeight.bold
  //             ),
  //           ),
  //           Center(
  //             child: RaisedButton(
  //               elevation: 10,
  //               onPressed: (){
  //                 logout();
  //               },
  //               color: Colors.teal,
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
  //               child: Text('Logout'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

    void logout() async{
      var userObjectId = await Network().getUserObject();
      Map<String,dynamic> list = json.decode(userObjectId.body);
      var prd = list['results'];
      print(prd[1]);
      final finalUser = prd.firstWhere((e) => e['username'] == name );
      if(finalUser['username']==name){
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('user');
        localStorage.remove('objectId');
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>Login()));
      }
  }
}

