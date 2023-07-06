// import 'dart:convert';
// import 'dart:io';

// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;

// import '../utils/authentication.dart';




import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
// import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../utils/authentication.dart';

class LawyerDetailsUpdate extends StatefulWidget {
  LawyerDetailsUpdate({Key? key}) : super(key: key);

  @override
  State<LawyerDetailsUpdate> createState() => _LawyerDetailsUpdateState();
}

class _LawyerDetailsUpdateState extends State<LawyerDetailsUpdate> {
  bool isEditable = false;
  bool isDocumentUploaded = false;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  TextEditingController yearController = TextEditingController();
  TextEditingController avaialabilityController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController documentUrlController = TextEditingController();

  Future futureStore() async {
    DocumentSnapshot doc =
        await db.collection("users").doc(AuthenticationHelper().user.uid).get();
    final data = doc.data() as Map<String, dynamic>;
    return data;
  }

  GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lawyer Information")),
      body: Container(
        child: FutureBuilder(
          future: futureStore(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Text("There was an error -- ${snapshot.error}");
            if (!snapshot.hasData) return Text("No data found");

            final data = snapshot.data as Map<String, dynamic>;
            yearController.text = data['years'] == null ? '' : data['years'];
            aboutController.text = data['about'] == null ? '' : data['about'];
            avaialabilityController.text =
                data['availability'] == null ? '' : data['availability'];

            return Form(
              key: _key,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(children: [
                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditable = true;
                          });
                        },
                        child: Text("Edit Details"),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: aboutController,
                    maxLines: 5,
                    enabled: isEditable,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "About",
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: yearController,
                    enabled: isEditable,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Years of Experience",
                    ),
                  ),
                  SizedBox(height: 20),
                  StatefulBuilder(builder: (context, setStateNew) {
                    return DropdownSearch<String>(
                      enabled: isEditable,
                      items: ["true", "false"],
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Availability",
                        ),
                      ),
                      onChanged: (data) {
                        setStateNew(() {
                          avaialabilityController.text = data!;
                        });
                      },
                      selectedItem: avaialabilityController.text,
                    );
                  }),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isEditable ? pickDocument : null,
                    child: Text("Pick Document"),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: documentUrlController,
                    enabled: isEditable && isDocumentUploaded,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Document URL",
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isEditable ? updateLawyerDetails : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text("Update Details"),
                  ),
                  SizedBox(height: 20),
                  
                 
                  //   Expanded(
                  //     child: PDFView(
                  //       filePath: documentUrlController.text,
                  //       // enableSwipeNavigation: true,
                  //       swipeHorizontal: true,
                  //     ),
                  //   ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> pickDocument() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      final File file = File(result.files.first.path!);
      final String fileName = path.basename(file.path);
      final Reference storageRef =
          storage.ref().child('documents/$fileName');

      try {
        final UploadTask uploadTask = storageRef.putFile(file);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          documentUrlController.text = downloadUrl;
          isDocumentUploaded = true;
        });

        showSnackbar('Document uploaded successfully');
      } catch (error) {
        print('Error uploading document: $error');
        showSnackbar('Failed to upload document');
      }
    }
  }

  void updateLawyerDetails() {
    db
        .collection("users")
        .doc(AuthenticationHelper().user!.uid)
        .update({
      'availability': avaialabilityController.text,
      'years': yearController.text,
      'about': aboutController.text,
      'documentUrl': documentUrlController.text,
    }).then((value) {
      setState(() {
        isEditable = false;
      });
      showSnackbar('Details updated successfully');
    }).catchError((error) {
      print('Error updating details: $error');
      showSnackbar('Failed to update details');
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

















// class LawyerDetailsUpdate extends StatefulWidget {
//   LawyerDetailsUpdate({Key? key}) : super(key: key);

//   @override
//   State<LawyerDetailsUpdate> createState() => _LawyerDetailsUpdateState();
// }

// class _LawyerDetailsUpdateState extends State<LawyerDetailsUpdate> {
//   bool isEditable = false;
//   bool isDocumentUploaded = false;

//   final db = FirebaseFirestore.instance;
//   final storage = FirebaseStorage.instance;

//   TextEditingController yearController = TextEditingController();
//   TextEditingController avaialabilityController = TextEditingController();
//   TextEditingController aboutController = TextEditingController();
//   TextEditingController documentUrlController = TextEditingController();

//   Future futureStore() async {
//     DocumentSnapshot doc =
//         await db.collection("users").doc(AuthenticationHelper().user.uid).get();
//     final data = doc.data() as Map<String, dynamic>;
//     return data;
//   }

//   GlobalKey _key = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Lawyer Information")),
//       body: Container(
//         child: FutureBuilder(
//           future: futureStore(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError)
//               return Text("There was an error -- ${snapshot.error}");
//             if (!snapshot.hasData) return Text("No data found");

//             final data = snapshot.data as Map<String, dynamic>;
//             yearController.text = data['years'] == null ? '' : data['years'];
//             aboutController.text = data['about'] == null ? '' : data['about'];
//             avaialabilityController.text =
//                 data['availability'] == null ? '' : data['availability'];

//             return Form(
//               key: _key,
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                 child: Column(children: [
//                   Row(
//                     children: [
//                       Spacer(),
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             isEditable = true;
//                           });
//                         },
//                         child: Text("Edit Details"),
//                       ),
//                     ],
//                   ),
//                   TextFormField(
//                     controller: aboutController,
//                     maxLines: 5,
//                     enabled: isEditable,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: "About",
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     controller: yearController,
//                     enabled: isEditable,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: "Years of Experience",
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   StatefulBuilder(builder: (context, setStateNew) {
//                     return DropdownSearch<String>(
//                       enabled: isEditable,
//                       items: ["true", "false"],
//                       dropdownDecoratorProps: DropDownDecoratorProps(
//                         dropdownSearchDecoration: InputDecoration(
//                           labelText: "Availability",
//                         ),
//                       ),
//                       onChanged: (data) {
//                         setStateNew(() {
//                           avaialabilityController.text = data!;
//                         });
//                       },
//                       selectedItem: avaialabilityController.text,
//                     );
//                   }),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: isEditable ? pickDocument : null,
//                     child: Text("Pick Document"),
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     controller: documentUrlController,
//                     enabled: isEditable && isDocumentUploaded,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: "Document URL",
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: isEditable ? updateLawyerDetails : null,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(50),
//                     ),
//                     child: Text("Update Details"),
//                   ),
//                 ]),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> pickDocument() async {
//     final FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'doc', 'docx'],
//     );

//     if (result != null && result.files.isNotEmpty) {
//       final File file = File(result.files.first.path!);
//       final String fileName = path.basename(file.path);
//       final Reference storageRef =
//           storage.ref().child('documents/$fileName');

//       try {
//         final UploadTask uploadTask = storageRef.putFile(file);
//         final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
//         final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

//         setState(() {
//           documentUrlController.text = downloadUrl;
//           isDocumentUploaded = true;
//         });

//         showSnackbar('Document uploaded successfully');
//       } catch (error) {
//         print('Error uploading document: $error');
//         showSnackbar('Failed to upload document');
//       }
//     }
//   }

//   void updateLawyerDetails() {
//     db
//         .collection("users")
//         .doc(AuthenticationHelper().user!.uid)
//         .update({
//       'availability': avaialabilityController.text,
//       'years': yearController.text,
//       'about': aboutController.text,
//       'documentUrl': documentUrlController.text,
//     }).then((value) {
//       setState(() {
//         isEditable = false;
//       });
//       showSnackbar('Details updated successfully');
//     }).catchError((error) {
//       print('Error updating details: $error');
//       showSnackbar('Failed to update details');
//     });
//   }

//   void showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }






















// class LawyerDetailsUpdate extends StatefulWidget {
//   LawyerDetailsUpdate({Key? key}) : super(key: key);

//   @override
//   State<LawyerDetailsUpdate> createState() => _LawyerDetailsUpdateState();
// }

// class _LawyerDetailsUpdateState extends State<LawyerDetailsUpdate> {
//   bool isEditable = false;
//   File? uploadedDocument;
//   bool isDocumentUploaded = false;

//   final db = FirebaseFirestore.instance;

//   TextEditingController yearController = TextEditingController();
//   TextEditingController avaialabilityController = TextEditingController();
//   TextEditingController aboutController = TextEditingController();
//   // TextEditingController storeNameController = TextEditingController();
//   // TextEditingController storeNameController = TextEditingController();
//   // TextEditingController storeLocationController = TextEditingController();

// void chooseDocument() async {
//   final result = await FilePicker.platform.pickFiles();
//   if (result != null) {
//     setState(() {
//       uploadedDocument = File(result.files.single.path!);
//     });
//     uploadDocument();
//   }
// }
// void uploadDocument() async {
//   if (uploadedDocument != null) {
//     try {
//       final String fileName = 'documents/${AuthenticationHelper().user!.uid}/${DateTime.now().millisecondsSinceEpoch}.pdf';
//       final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
//       final UploadTask uploadTask = storageRef.putFile(uploadedDocument!);
//       final TaskSnapshot taskSnapshot = await uploadTask;
//       final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
//       setState(() {
//         isDocumentUploaded = true;
//       });
      
//       // Use the downloadUrl as needed (e.g., save it to Firestore)
//       // ...
//     } catch (e) {
//       print('Error uploading document: $e');
//       setState(() {
//         isDocumentUploaded = false;
//       });
//     }
//   }
// }



//   Future futureStore() async {
//     DocumentSnapshot doc =
//         await db.collection("users").doc(AuthenticationHelper().user.uid).get();
//     // print(doc['email']);
//     // print("doc");
//     final data = doc.data() as Map<String, dynamic>;
//     // print(data);
//     // print(jsonDecode(doc.toString()));
//     return data;
//   }

//   GlobalKey _key = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Lawyer Information")),
//       body: Container(
//         child: FutureBuilder(
//             future: futureStore(),
//             builder: (context, snapshot) {
//               // print(snapshot);
//               if (snapshot.hasError)
//                 return Text("There was an error -- ${snapshot.error}");
//               if (!snapshot.hasData) return Text("No data found");

//               // print("snapshot");

//               final data = snapshot.data as Map<String, dynamic>;
//               // print(data['email']);
//               // print(snapshot.data['email']);
//               // print(snapshot.data['email']);
//               yearController.text = data['years'] == null ? '' : data['years'];
//               aboutController.text = data['about'] == null ? '' : data['about'];
//               avaialabilityController.text =
//                   data['availability'] == null ? '' : data['availability'];

//               return Form(
//                 key: _key,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                   child: Column(children: [
//                     Row(
//                       children: [
//                         Spacer(),
//                         ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 isEditable = true;
//                               });
//                             },
//                             child: Text("Edit Details"))
//                       ],
//                     ),
//                     TextFormField(
//                       controller: aboutController,
//                       maxLines: 5,
//                       enabled: isEditable,
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(), label: Text("About")),
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     TextFormField(
//                       controller: yearController,
//                       enabled: isEditable,
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           label: Text("Years of Experience")),
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     StatefulBuilder(builder: (context, setStateNew) {
//                       return DropdownSearch<String>(
//                         enabled: isEditable,

//                         // popupBarrierColor: Colors.white,
//                         popupProps: PopupProps.menu(
//                           showSelectedItems: true,
//                           menuProps: MenuProps(
//                             backgroundColor: Colors.white,
//                           ),
//                         ),
//                         items: ["true", "false"],

//                         dropdownDecoratorProps: DropDownDecoratorProps(
//                           dropdownSearchDecoration:
//                               InputDecoration(labelText: "Availability"),
//                         ),
//                         // popupItemDisabled: (String s) => s.startsWith('I'),
//                         onChanged: (data) {
//                           setStateNew(() {
//                             avaialabilityController.text = data!;
//                           });
//                         },
//                         selectedItem: avaialabilityController.text,
//                       );
//                     }),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     ElevatedButton(
//                       onPressed: isEditable ? chooseDocument : null,
//                       child: Text("Choose Document"),
//                     ),
//                     Spacer(),
//                     ElevatedButton(
//                         onPressed: isEditable
//                             ? () {
//                                 db
//                                     .collection("users")
//                                     .doc(AuthenticationHelper().user!.uid)
//                                     .update({
//                                   'availability': avaialabilityController.text,
//                                   'years': yearController.text,
//                                   'about': aboutController.text,
                                  
//     // 'documentUrl': documentUrl,
//                                 }).then((value) => {
//                                           setState(() => {isEditable = false})
//                                         });
//                               }
//                             : null,
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50), // NEW
//                           // enabled: isEditable,
//                         ),
//                         child: Text("Update Details"))
//                   ]),
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// }
