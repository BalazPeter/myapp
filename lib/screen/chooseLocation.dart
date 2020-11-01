import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as lct;

class ChooseLocation extends StatefulWidget {
  @override
  _ChooseLocation createState() => _ChooseLocation();
}

class _ChooseLocation extends State<ChooseLocation> {
  // inicializácia premených, inštancií pre kontroler
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(49, 21);
  LatLng _lastMapPosition = _center;
  double longitude;
  double latitude;

  // handling pohybu po mape
  _onCameraMove(CameraPosition position) async{
    var targetpos = position.target;
    print(_lastMapPosition);
    setState(() {
      longitude = targetpos.longitude;
      latitude = targetpos.latitude;
      _lastMapPosition = targetpos;
    });
  }

  // funkcia na získanie aktuálnej polohy
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

// TODO: dokončenie dizajnu výmena icons buttnov
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
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
                  child: const Icon(Icons.location_searching, size: 36.0),
                ),
              ),
            ),
            Center(
              child: Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  heroTag: "GetNewPosition",
                  onPressed: () {
                    _sendDataBack(context);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  child: const Icon(Icons.zoom_out_map, size: 36.0)
                ),
              ),
            )
          ]
      ),
    );
  }

  // funkcia na odoslanie dát pre nashlásenie skládky do screenu reportLandfill
  void _sendDataBack(BuildContext context) {
    Navigator.pop(context, _lastMapPosition);
  }

}
