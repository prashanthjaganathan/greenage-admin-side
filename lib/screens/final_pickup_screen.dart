import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greeanage_employee/data/global.dart';
import 'package:greeanage_employee/data/smart_bins_loc.dart';
import 'package:greeanage_employee/screens/pick_up.dart';
import 'package:greeanage_employee/widgets/home.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mysql1/mysql1.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/pickup_data.dart';

import 'package:geocoding/geocoding.dart';

class FinalPickUp extends StatefulWidget {
  final PickUpDetails pickup;

  const FinalPickUp({Key? key, required this.pickup}) : super(key: key);

  @override
  _FinalPickUpState createState() => _FinalPickUpState();
}

class _FinalPickUpState extends State<FinalPickUp> {
  dynamic _conn;
  Set<Marker> markers = {};
  int _binID = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _itemCheckBox = false;
  bool _arrivedCheckBox = false;
  bool _disposedCheckBox = false;
  PickUpDetails get _pickup => widget.pickup;
  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(13.0159044, 77.63786189999996), zoom: 12.0);

  getCurrentLocationAndData() async {
    {
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
      // Setting up Smart Bin data

      _conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: '34.93.37.194',
          port: 3306,
          user: 'root',
          password: 'root',
          db: 'greenage',
        ),
      );
      final results =
          await _conn.query('SELECT * FROM SMART_BINS WHERE installed = "YES"');
      var row = await results.first;
      print(row.toString());
      _binID = await row['Bin_No'];
      _latitude = await row['latitude'];
      _longitude = await row['longitude'];

      Position position = await _determinePosition();
      // print(position.latitude.toString());
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17)));

      markers.add(Marker(
        markerId: MarkerId("${_pickup.name}'s Pickup Location"),
        position: LatLng(_latitude, _longitude),
      ));

      setState(() {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 17)));
      });
    });
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
        ListTile(
          subtitle: const Text(
            'Upload pictures of the bin',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
          leading: IconButton(
              onPressed: () {}, icon: Icon(Icons.camera_alt, size: 25)),
          title: Text(
            "${_pickup.disposalSize} Item Collected",
            style: const TextStyle(fontSize: 15),
          ),
          trailing: Checkbox(
            value: _itemCheckBox,
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() {
                _itemCheckBox = val!;
                if (val == true) {
                  _itemCheckBox = val;
                }
              });
            },
          ),
        ),
        ListTile(
          subtitle: const Text(
            'Any defects?',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.directions,
              size: 25,
              color: Colors.blue,
            ),
            onPressed: () => MapsLauncher.launchCoordinates(_latitude,
                _longitude, 'Greenage Waste Management - Smart Bin # $_binID '),
          ),
          title: Text(
            "Arrived at Smart Bin #${_binID}",
            style: const TextStyle(fontSize: 15),
          ),
          trailing: Checkbox(
            value: _arrivedCheckBox,
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() {
                _arrivedCheckBox = val!;
                if (val == true) {
                  _arrivedCheckBox = val;
                }
              });
            },
          ),
        ),
        ListTile(
          subtitle: const Text(
            'Scan QR',
            style: TextStyle(
                fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.qr_code, size: 25),
            onPressed: () {},
          ),
          title: const Text(
            "Item Disposed",
            style: TextStyle(fontSize: 15),
          ),
          trailing: Checkbox(
            value: _disposedCheckBox,
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() {
                _disposedCheckBox = val!;
                if (val == true) {
                  _disposedCheckBox = val;
                }
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5, top: 5),
          child: ElevatedButton(
              onPressed: () async {
                if (_arrivedCheckBox && _disposedCheckBox && _itemCheckBox) {
                  var res = await _conn.query(
                      "UPDATE PICKUPS SET status = 'COMPLETED' where pickup_id = ${_pickup.pickup_id}");
                  print(_pickup.id);
                  // print('Finished pickup');
                  //  print(res);
                  // ignore: use_build_context_synchronously
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: ((context) => const Home())),
                      (route) => false);
                  Fluttertoast.showToast(msg: 'Pickup completed successfully!');
                } else {
                  Fluttertoast.showToast(msg: 'Please complete all the tasks!');
                }
              },
              child: const Center(child: Text('PICKUP COMPLETE'))),
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
