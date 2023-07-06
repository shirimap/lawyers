import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyers/components/custom_home_drawer.dart';
import 'package:lawyers/utils/authentication.dart';
import 'package:lawyers/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AllUsersScreen extends StatefulWidget {
  AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("users").snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitDancingSquare(
              color: Colors.blueGrey,
              size: 50.0,
            );
          }
          if (!snapshot.hasData) {
            return Text("No Data found");
          }
          if (snapshot.hasError) {
            return Text("There was an Error");
          }

          if (snapshot.data!.docs.length < 1) {
            return Padding(
              padding: const EdgeInsets.all(28.0),
              child: Text("No data found"),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.docs.map((doc) {
                  var item = doc.data() as Map<String, dynamic>?;
            
                  if (item == null) {
                    return DataRow(cells: []);
                  }
            
                  String rolName = '';
                  if (item['role'] == 1) {
                    rolName = 'Lawyer';
                  } else if (item['role'] == 0) {
                    rolName = 'User';
                  } else if (item['role'] == 2) {
                    rolName = 'Admin';
                  }
            
                  return DataRow(
                    cells: [
                      DataCell(Text(item['name']?.toString() ?? '')),
                      DataCell(Text(item['email']?.toString() ?? '')),
                      DataCell(Text(item['phone']?.toString() ?? '')),
                      // DataCell(Text(item['role']?.toString() ?? '')),
                      DataCell(Text(rolName)),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            db.collection("users").doc(doc.id).delete();
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ),
    );
  }
}
