import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mysql1/mysql1.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../data/pickup_data.dart';
import '../data/report_data.dart';
import 'detailed_pickup.dart';
import 'detailed_report.dart';

dynamic conn;

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final List<ReportDetails> _reports = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: '34.93.37.194',
          port: 3306,
          user: 'root',
          password: 'root',
          db: 'greenage',
        ),
      );

      final results = await conn
          .query('SELECT * FROM REPORTS WHERE `status` = "SUBMITTED"');
      print(results);
      for (var row in results) {
        ReportDetails obj = ReportDetails();
        obj.report_id = await row['report_id'];
        obj.user_id = await row['user_id'];
        final res = await conn.query(
            'SELECT name FROM SIGNEDUP_USERS WHERE `id` = ${obj.user_id}');
        for (var r in res) {
          obj.name = await r['name'];
        }
        String textData = await row['comment'].toString();
        String base64String = base64Encode(utf8.encode(textData));
        obj.comment = base64String;

        obj.latitude = await row['latitude'];
        obj.longitude = await row['longitude'];
        obj.priority = await row['priority'];

        textData = row['title'].toString();
        base64String = base64Encode(utf8.encode(textData));
        obj.title = utf8.decode(base64.decode(base64String));

        print(obj.title);

        //  obj.decodedBytes = await row['image'];

        // textData = await row['title'].toString();
        obj.reportImageAsStr = row['image'].toString();
        Uint8List bytes = base64Decode(obj.reportImageAsStr);
        String tempPath =
            await getTemporaryDirectory().then((value) => value.path);
        String filePath =
            '$tempPath/${DateTime.now().millisecondsSinceEpoch}.jpeg';
        await File(filePath).writeAsBytes(bytes);
        obj.reportImageFile = XFile(filePath);

        _reports.add(obj);
      }
    });
  }

  void _loadData() async {
    final results = await conn.query(
        'SELECT * FROM REPORTS WHERE `status` = "SUBMITTED" and report_id > ${_reports.last.report_id}');
    print(results);
    if (results.toString() != "()") {
      for (var row in results) {
        ReportDetails obj = ReportDetails();
        obj.report_id = await row['report_id'];
        obj.user_id = await row['user_id'];
        final res = await conn.query(
            'SELECT name FROM SIGNEDUP_USERS WHERE `id` = ${obj.user_id}');
        for (var r in res) {
          obj.name = await r['name'];
        }
        String textData = await row['comment'].toString();
        String base64String = base64Encode(utf8.encode(textData));
        obj.comment = base64String;

        obj.latitude = await row['latitude'];
        obj.longitude = await row['longitude'];
        obj.priority = await row['priority'];

        textData = await row['title'].toString();
        base64String = base64Encode(utf8.encode(textData));
        obj.title = utf8.decode(base64.decode(base64String));
        print(obj.title);

        obj.reportImageAsStr = row['image'].toString();
        Uint8List bytes = base64Decode(obj.reportImageAsStr);
        String tempPath =
            await getTemporaryDirectory().then((value) => value.path);
        String filePath =
            '$tempPath/${DateTime.now().millisecondsSinceEpoch}.jpeg';
        await File(filePath).writeAsBytes(bytes);
        obj.reportImageFile = XFile(filePath);

        _reports.add(obj);
      }
    } else {
      return;
    }
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadData();
      setState(() {});
    });

    return Scaffold(
      appBar: AppBar(title: const Text('REPORTS')),
      body: _reports.isEmpty
          ? const Center(child: Text('No Reports'))
          : ListView.builder(
              itemBuilder: (context, index) {
                Future.delayed(Duration.zero, () async {
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                      _reports[index].latitude, _reports[index].longitude);
                  Placemark placemark = placemarks.first;

                  String areaName = placemark.subAdministrativeArea ??
                      placemark.administrativeArea ??
                      "";
                  _reports[index].address = areaName;
                  setState(() {});
                });

                return ListTile(
                  horizontalTitleGap: 20,
                  minVerticalPadding: 20,
                  minLeadingWidth: 70,
                  // isThreeLine: true,
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        _reports[index].priority.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  title: Text(
                    _reports[index].title,
                    textAlign: TextAlign.left,
                  ),
                  subtitle: Text(_reports[index].address),
                  trailing: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailedReportPage(
                                      report: _reports[index],
                                    )));
                      },
                      child: const Text(
                        'ACCEPT',
                        style: TextStyle(color: Colors.green),
                      )),
                );
              },
              itemCount: _reports.length,
            ),
    );
  }
}
