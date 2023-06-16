import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greeanage_employee/screens/final_pickup_screen.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mysql1/mysql1.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/pickup_data.dart';

import 'package:geocoding/geocoding.dart';

class DetailedPickUpPage extends StatefulWidget {
  final PickUpDetails pickup;

  const DetailedPickUpPage({Key? key, required this.pickup}) : super(key: key);

  @override
  _DetailedPickUpPageState createState() => _DetailedPickUpPageState();
}

class _DetailedPickUpPageState extends State<DetailedPickUpPage> {
  List<Location> _locations = [];
  Set<Marker> markers = {};
  PickUpDetails get _pickup => widget.pickup;
  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(13.0159044, 77.63786189999996), zoom: 12.0);

  getCurrentLocationAndData() async {
    {
      var _conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: '34.93.37.194',
          port: 3306,
          user: 'root',
          password: 'root',
          db: 'greenage',
        ),
      );

      //   for (var row in results) {
      //     print(row.toString());
      //     binID.add(row['Bin_No']);
      //     latitudes.add(row['latitude']);
      //     longtitudes.add(row['longitude']);
    }

    Position position = await _determinePosition();
    print(position.latitude.toString());
    await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 17)));

    setState(() {
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17)));
    });
  }

  void callFunc() async {
    await getCurrentLocationAndData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //sleep(Duration(seconds: 5));
    Future.delayed(Duration.zero, () async {
      _locations = await locationFromAddress(_pickup.address);
      print(_pickup.address);
      Position position = await _determinePosition();
      // print(position.latitude.toString());
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17)));

      markers.add(Marker(
        markerId: MarkerId("${_pickup.name}'s Pickup Location"),
        position: LatLng(_locations.first.latitude, _locations.first.longitude),
      ));

      setState(() {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 17)));
      });
    });
    
    // callFunc();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height) * (0.5),
          child: GoogleMap(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.57),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) async {
              googleMapController = controller;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
          child: Card(
              child: ListTile(
            leading: const Icon(
              Icons.person,
              size: 30,
            ),
            title: Text(
              _pickup.name,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.start,
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.phone,
              ),
              onPressed: () {
                _makePhoneCall(_pickup.number);
              },
            ),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: Text(_pickup.address)),
                        Expanded(
                          //flex: 1,
                          child: IconButton(
                              onPressed: () => MapsLauncher.launchCoordinates(
                                  _locations.first.latitude,
                                  _locations.first.longitude,
                                  "${_pickup.name}'s pickup location"),
                              icon: const Icon(
                                Icons.directions,
                                color: Colors.blue,
                                size: 40,
                              )),
                        )
                      ],
                    ),
                  ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FinalPickUp(
                              pickup: _pickup,
                            )));
              },
              child: const Center(child: Text('Reached Location'))),
        ),
      ]),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
