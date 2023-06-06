import 'dart:typed_data';
import 'package:greeanage_employee/widgets/test_report_image.dart';
import 'package:greeanage_employee/widgets/yolov5.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'package:tflite/tflite.dart';
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

import '../data/report_data.dart';

class DetailedReportPage extends StatefulWidget {
  final ReportDetails report;

  const DetailedReportPage({Key? key, required this.report}) : super(key: key);

  @override
  _DetailedReportPageState createState() => _DetailedReportPageState();
}

class _DetailedReportPageState extends State<DetailedReportPage> {
  var _recognitions, _imageWidth, _imageHeight;
  List<Location> _locations = [];
  Set<Marker> markers = {};
  bool _loading = true;

  late File _imageInput;
  late File _imageOutput;

  final picker = ImagePicker();
  ReportDetails get _report => widget.report;
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
    //  print(position.latitude.toString());
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

  // classifyImage(File image) async {
  //   var output = await Tflite.runModelOnImage(
  //     path: _imageInput.path,
  //     threshold: 0.5,
  //     numResults: 2,
  //     imageMean: 127.5,
  //     imageStd: 127.5,
  //   );
  //   print(output);
  //   setState(() {
  //     _imageOutput = output as File;
  //     _loading = false;
  //   });
  // }

  void callFunc() async {
    await getCurrentLocationAndData();
    setState(() {});
  }

  detectObject(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, // required
        model: "yolov5",
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4, // defaults to 0.1
        // numResultsPerClass: 10,// defaults to 5
        asynch: true // defaults to true
        );
    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
          });
        })));
    setState(() {
      _recognitions = recognitions;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        // ignore: unnecessary_string_escapes
        model: "assets/best-fp16.tflite",
        labels: 'assets/labels.txt');
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageInput = File(pickedFile.path);
      } else {
        print("No image Selected");
      }
    });
    detectObject(_imageInput);
  }

  @override
  void initState() {
    super.initState();

    // //sleep(Duration(seconds: 5));
    // loadModel().then((val) {
    //   setState(() {});
    // });
    // callFunc();
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;

    Color blue = Colors.blue;

    return _recognitions.map((re) {
      return Container(
        child: Positioned(
            left: re["rect"]["x"] * factorX,
            top: re["rect"]["y"] * factorY,
            width: re["rect"]["w"] * factorX,
            height: re["rect"]["h"] * factorY,
            child: ((re["confidenceInClass"] > 0.50))
                ? Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: blue,
                      width: 3,
                    )),
                    child: Text(
                      "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        background: Paint()..color = blue,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  )
                : Container()),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // print(_report.imageBytes);
    File file = File(_report.reportImageFile.path);
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height) * (0.5),
          child: file != null
              ? Image.file(
                  file,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey, // Placeholder color
                  child: const Center(
                    child: Text('Image not found'),
                  ),
                ),
          // child: GoogleMap(
          //   padding:
          //       EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.57),
          //   myLocationEnabled: true,
          //   myLocationButtonEnabled: true,
          //   initialCameraPosition: initialCameraPosition,
          //   markers: markers,
          //   zoomControlsEnabled: false,
          //   mapType: MapType.normal,
          //   onMapCreated: (GoogleMapController controller) async {
          //     googleMapController = controller;
          //   },
          // ),
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
              _report.name,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.start,
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.phone,
              ),
              onPressed: () {},
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
                        Expanded(flex: 3, child: Text(_report.address)),
                        Expanded(
                          //flex: 1,
                          child: IconButton(
                              onPressed: () => MapsLauncher.launchCoordinates(
                                  _locations.first.latitude,
                                  _locations.first.longitude,
                                  "Report location"),
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
        GestureDetector(
          onTap: () {
            print('Clicked');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ObjectDetectionScreen()));
            ObjectDetectionScreen();

            // CameraFeed();
            //Navigator.push(CameraFeed();
          },
          child: Container(
            child: const Text('Take A Photo'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
          child: ElevatedButton(
              onPressed: () {}, child: const Center(child: Text('Cleared'))),
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
