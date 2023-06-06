import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mysql1/mysql1.dart';
import '../data/bin_level_dataModel.dart';
import '../data/smart_bins_loc.dart';
import '../widgets/home.dart';
import 'package:http/http.dart' as http;

class SmartBin extends StatefulWidget {
  const SmartBin({super.key});

  @override
  State<SmartBin> createState() => _SmartBinState();
}

class _SmartBinState extends State<SmartBin> {
  StreamController<DataModel> _streamController = StreamController();
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

      // Setting up Smart Bin data
      final results = await _conn.query('SELECT * FROM SMART_BINS');

      for (var row in results) {
        print(row.toString());
        binID.add(row['Bin_No']);
        latitudes.add(row['latitude']);
        longtitudes.add(row['longitude']);
        area.add(row['Area']);
        markers.add(Marker(
          markerId: MarkerId("Smart Bin #${row['Bin_No']}"),
          position: LatLng(row['latitude'], row['longitude']),
        ));
      }
    }

    Position position = await _determinePosition();
    // print(position.latitude.toString());
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

  Future<void> getBinLevel() async {
    var url = Uri.parse(
        'https://api.thingspeak.com/channels/2099558/feeds.json?api_key=HVK20G1KCK3UC698&results=1');
    final response = await http.get(url);
    final databody = json.decode(response.body);
    DataModel dataModel = DataModel.fromJson(databody);
    // add API response to stream controller sink
    _streamController.sink.add(dataModel);
  }

  @override
  void initState() {
    super.initState();
    //sleep(Duration(seconds: 5));
    Future.delayed(Duration.zero, () async {
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

        // Setting up Smart Bin data
        final results = await _conn
            .query('SELECT * FROM SMART_BINS WHERE INSTALLED = "YES"');

        for (var row in results) {
          print(row.toString());
          binID.add(row['Bin_No']);
          latitudes.add(row['latitude']);
          longtitudes.add(row['longitude']);
          area.add(row['Area']);
          markers.add(Marker(
            markerId: MarkerId("Smart Bin #${row['Bin_No']}"),
            position: LatLng(row['latitude'], row['longitude']),
          ));
        }
      }

      Position position = await _determinePosition();
      // print(position.latitude.toString());
      await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17)));

      setState(() {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 17)));
      });
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      getBinLevel();
    });

    // callFunc();
  }

  @override
  Widget build(BuildContext context) {
    //sleep(Duration(seconds: 2));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: (MediaQuery.of(context).size.height) * (0.5),
        child: GoogleMap(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.42),
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
      const Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 2),
        child: Text("Smart Bin Levels Near You",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 0),
        child: Divider(
          thickness: 2,
          color: Colors.black38,
        ),
      ),
      Expanded(
        child: StreamBuilder<DataModel>(
          stream: _streamController.stream,
          builder: (context, snapdata) {
            switch (snapdata.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapdata.hasError) {
                  return const Text('Please Wait....');
                } else {
                  return BuildBinLevelTile(snapdata.data!);
                }
            }
          },
        ),
      ),
    ]);
  }

  Widget BuildBinLevelTile(DataModel dataModel) {
    return ListView.builder(
      // shrinkWrap: true,
      itemCount: markers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListTile(
            tileColor: int.parse(dataModel.binLevel) >= 90
                ? Colors.red.shade400
                : (int.parse(dataModel.binLevel) >= 40
                    ? Colors.orange.shade200
                    : Colors.green.shade400),
            horizontalTitleGap: 2,
            title: Text('Smart Bin #${binID[index]}'),
            subtitle: Text(area[index]),
            trailing: Text('${dataModel.binLevel}%'),
          ),
        );
      },
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
