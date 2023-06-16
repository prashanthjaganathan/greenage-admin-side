import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../data/pickup_data.dart';
import 'detailed_pickup.dart';

dynamic conn;

class PickUp extends StatefulWidget {
  const PickUp({super.key});

  @override
  State<PickUp> createState() => _PickUpState();
}

class _PickUpState extends State<PickUp> {
  final List<PickUpDetails> _pickups = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: '34.93.225.253',
          port: 3306,
          user: 'root',
          password: 'root',
          db: 'greenage',
        ),
      );
      // print('connected');
      final results =
          await conn.query('SELECT * FROM PICKUPS WHERE `status` = "PLACED"');
      print(results);
      for (var row in results) {
        PickUpDetails obj = PickUpDetails();
        obj.pickup_id = await row['pickup_id'];
        obj.id = await row['user_id'];
        final res = await conn.query(
            'SELECT name, phone_number FROM SIGNEDUP_USERS WHERE `id` = ${obj.id}');
        for (var r in res) {
          obj.number = await r['phone_number'];
          obj.name = await r['name'];
        }
        obj.disposalSize = await row['disposal_size'];
        obj.address = await row['address'];
        obj.bill = await row['total_bill'];

        _pickups.add(obj);
      }
      setState(() {});
      //  _loadData();
    });
  }

  void _loadData() async {
    final results = await conn.query(
        'SELECT * FROM PICKUPS WHERE `status` = "PLACED" and pickup_id > ${_pickups.last.pickup_id}');
    print(results);
    if (results.toString() != "()") {
      for (var row in results) {
        PickUpDetails obj = PickUpDetails();
        obj.id = await row['user_id'];
        final res = await conn.query(
            'SELECT name, phone_number FROM SIGNEDUP_USERS WHERE `id` = ${obj.id}');
        for (var r in res) {
          obj.number = await r['phone_number'];
          obj.name = await r['name'];
        }
        obj.disposalSize = await row['disposal_size'];
        obj.address = await row['address'];
        obj.bill = await row['total_bill'];

        _pickups.add(obj);
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadData();
      //  setState(() {});
    });

    return Scaffold(
      appBar: AppBar(title: const Text('PICKUPS')),
      body: _pickups.isEmpty
          ? const Center(child: Text('No Pickups'))
          : ListView.builder(
              itemBuilder: (context, index) {
                List<String> _words = _pickups[index].address.split(" ");
                var _addressBrief = _words[_words.length - 1];

                return ListTile(
                  leading: Text('₹${_pickups[index].bill}'),
                  title: Text('${_pickups[index].disposalSize} Waste Pickup'),
                  subtitle: Text(_addressBrief),
                  trailing: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailedPickUpPage(
                                      pickup: _pickups[index],
                                    )));
                      },
                      child: const Text(
                        'ACCEPT',
                        style: TextStyle(color: Colors.green),
                      )),
                );
              },
              itemCount: _pickups.length,
            ),
    );
  }
}
