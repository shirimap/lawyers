import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawyers/components/snapshot_state.dart';
import 'package:app_popup_menu/app_popup_menu.dart';
import 'package:lawyers/screens/appointment_detail_screen.dart';
import 'package:lawyers/utils/authentication.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' show Table, TableRow, TableCell;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppointmentsScreen extends StatefulWidget {
  AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final db = FirebaseFirestore.instance;
  // final logo
  // final whoIs = "";

  @override
  void initState() {
    super.initState();
    // checkUser();
  }

  // void checkUser(){
  //   if(AuthenticationHelper().user.)
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments"),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.add_circle,
          //   ),
          //   onPressed: () {
          //     generateAppointmentReport();
          //   },
          // )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection("appointments")
            .where("lawyer", isEqualTo: AuthenticationHelper().user.uid)
            .snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitDancingSquare(
              color: Colors.blueGrey,
              size: 50.0,
            );
          }
          if (!snapshot.hasData) {
            return Text("No Dat found");
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
          if (snapshot.hasData) {
            print(snapshot.data);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data!.docs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: ((context) {
                          return AppointmentDetailScreen(item: item);
                        })));
                      },
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(6),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: item.get('lawyer_photo') == ""
                                        ? ClipRRect(
                                            child: Image.asset(
                                                "assets/images/avatar.png",
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover),
                                            borderRadius:
                                                BorderRadius.circular(10))
                                        : ClipRRect(
                                            child: Image.network(
                                                item.get("lawyer_photo"),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                SizedBox(
                                  width: 16,
                                ),
                                FutureBuilder(
                                    future: db
                                        .collection("users")
                                        .doc(item.get("user_requested"))
                                        .get(),
                                    builder: (context,
                                        AsyncSnapshot<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            snap) {
                                      if (snap.connectionState ==
                                          ConnectionState.waiting) {
                                        return SpinKitDancingSquare(
                                          color: Colors.blueGrey,
                                          size: 50.0,
                                        );
                                      }
                                      if (!snap.hasData) {
                                        return Text("No Dat found");
                                      }
                                      if (snap.hasError) {
                                        return Text("There was an Error");
                                      }

                                      print(snap.data.toString());

                                      return Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(item!.get('user_name'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .copyWith(
                                                      color: Colors.blue)),
                                          Text("Date: ${item.get('date')}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Colors.black)),
                                          Text(
                                              "Time: ${item.get('time') != null ? item.get('time') : ''}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Colors.black)),
                                          checkStatus(item.get('status')),
                                        ],
                                      ));
                                    }),
                                SizedBox(
                                  width: 40,
                                  child: AppPopupMenu(
                                    menuItems: const [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    // initialValue: 2,
                                    onSelected: (int value) {
                                      // print("selected");
                                      // print(item.id);
                                      if (value == 1) {
                                        db
                                            .collection("appointments")
                                            .doc(snapshot.data!.docs[index].id)
                                            .delete();
                                      }
                                    },
                                    icon: Icon(Icons.more_vert_outlined),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  );
                }),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // generateAndSavePDF();
          generatePDF();
          // saveAndOpenPDF(pdf);
        },
        child: Icon(Icons.picture_as_pdf),
      ),
    );
  }

  void generateAppointmentReport() {
    // Perform the necessary operations to generate the report
    // For example, you can fetch the appointments data and create a table widget

    // Fetch the appointments data from Firestore
    db
        .collection("appointments")
        .where("lawyer", isEqualTo: AuthenticationHelper().user.uid)
        .get()
        .then((querySnapshot) async {
      // Create a table widget using the fetched data
      List<TableRow> rows = [];
      rows.add(
        TableRow(
          children: [
            TableCell(child: Text("Client Name")),
            TableCell(child: Text("Time")),
            TableCell(child: Text("Date")),
          ],
        ),
      );
      for (var doc in querySnapshot.docs) {
        rows.add(
          TableRow(
            children: [
              TableCell(child: Text(doc["user_name"])),
              TableCell(child: Text(doc["time"])),
              TableCell(child: Text(doc["date"])),
            ],
          ),
        );
      }

      // Display the table widget
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Appointment Report"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Table(
                    border: TableBorder.all(),
                    children: rows,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // generateAndSavePDF();
                    },
                    child: Text("Print PDF"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      print("Error fetching appointments: $error");
    });
  }

  Future<pw.Document> generatePDF() async {
    // Fetch the appointments data from Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection("appointments")
        .where("lawyer", isEqualTo: AuthenticationHelper().user.uid)
        .get();
    final user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get();
    final lawyerName = userDoc.get('name') ?? 'Unknown';

    print(lawyerName);

    // Create a list of appointment widgets using the fetched data
    List<pw.Widget> appointmentWidgets = [];
    // appointmentWidgets.add(
    //   // pw.Text(
    //   //   "Appointments",
    //   //   style: pw.TextStyle(
    //   //     fontSize: 18,
    //   //     fontWeight: pw.FontWeight.bold,
    //   //   ),
    //   // ),
    // );
    for (var doc in querySnapshot.docs) {
      // appointmentWidgets.add(pw.Column(
      //     // mainAxisAlignment: pw.MainAxisAlignment.end,
      //     children: [
      //       pw.Text("${doc["user_name"]}"),
      //     ]));

      // appointmentWidgets.add(pw.Row(children: [
      //   pw.SizedBox(width: 100),
      // ]));

      appointmentWidgets.add(pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // pw.SizedBox(width: 20),
            pw.Text("${doc["user_name"]}"),

            pw.Text("${doc["time"]}"),
            pw.Text("${doc["date"]}"),

            // pw.Text(" "),
            // pw.SizedBox(width: 20),
          ]));

      // appointmentWidgets.add(
      //   pw.Column(
      //     // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      //     children: [
      //       // pw.Text("Date:"),
      //       // pw.SizedBox(width: 50),

      //       pw.Text("${doc["date"]}"),
      //       // pw.SizedBox(width: 20),

      //       // pw.Text(" "),
      //     ],
      //   ),
      // );
      appointmentWidgets.add(pw.Divider(height: 1, thickness: 1));
      appointmentWidgets.add(pw.SizedBox(height: 10));
    }

    // Create the PDF document
    final pdf = pw.Document();
    // final image = pw.MemoryImage(
    //   File('assets/images/LAWYERS.png').readAsBytesSync(),
    // );

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // pw.Row(
                //   mainAxisAlignment: pw.MainAxisAlignment.center,
                //   children: [
                //   pw.Container(
                //     height: 50,
                //     width: 50,
                //     child: pw.Image(image),
                //   ),
                // ]),
                pw.Text(
                  'Appointment Report',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(height: 2, thickness: 4),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Client Name",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        "Time",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        "Date",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ]),
                pw.Divider(height: 1, thickness: 2),
                pw.SizedBox(height: 20),
                pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: appointmentWidgets),

                // pw.Positioned(
                //     bottom: 0,
                //     left: 0,
                //     child: pw.Row(children: [pw.Text("Laywer name:")])),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getExternalStorageDirectory();
    final String customPath = '/storage/emulated/0/Documents/lawyersreport';

    final Directory customDirectory = Directory(customPath);
    if (!customDirectory.existsSync()) {
      // Create the custom directory if it doesn't exist
      customDirectory.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'appointment_report_$timestamp.pdf';
    final String filePath = '${customDirectory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF saved at: ${file.path}');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("PDF saved at: ${file.path}"),
      backgroundColor: Colors.green,
    ));

    if (Platform.isAndroid) {
      OpenFile.open(filePath);
    } else if (Platform.isIOS) {}

    return pdf;
  }

  // Future<pw.Document> generatePDF() async {
  //   // Fetch the appointments data from Firestore
  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collection("appointments")
  //       .where("lawyer", isEqualTo: AuthenticationHelper().user.uid)
  //       .get();

  //   // Create a list of appointment widgets using the fetched data
  //   List<pw.Widget> appointmentWidgets = [];
  //   appointmentWidgets.add(
  //     pw.Text(
  //       "Appointments",
  //       style: pw.TextStyle(
  //         fontSize: 18,
  //         fontWeight: pw.FontWeight.bold,
  //       ),
  //     ),
  //   );
  //   for (var doc in querySnapshot.docs) {
  //     appointmentWidgets.add(
  //       pw.Text("Client Name: ${doc["user_name"]}"),
  //     );
  //     appointmentWidgets.add(
  //       pw.Text("Time: ${doc["time"]}"),
  //     );
  //     appointmentWidgets.add(
  //       pw.Text("Date: ${doc["date"]}"),
  //     );
  //     appointmentWidgets.add(pw.SizedBox(height: 10));
  //   }

  //   // Create the PDF document
  //   final pdf = pw.Document();

  //   // Add content to the PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Text(
  //                 'Appointment Report',
  //                 style: pw.TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: pw.FontWeight.bold,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 20),
  //               pw.Column(children: appointmentWidgets),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //   final directory = await getExternalStorageDirectory();
  //   final String customPath =
  //       '/storage/emulated/0/Documents/lawyersreport';

  //   final Directory customDirectory = Directory(customPath);
  //   if (!customDirectory.existsSync()) {
  //     // Create the custom directory if it doesn't exist
  //     customDirectory.createSync(recursive: true);
  //   }

  //   final timestamp = DateTime.now().millisecondsSinceEpoch;
  //   final fileName = 'appointment_report_$timestamp.pdf';
  //   final String filePath = '${customDirectory.path}/$fileName';
  //   // final filePath = '${downloadsDirectory.path}/$fileName';
  //   final file = File(filePath);
  //   await file.writeAsBytes(await pdf.save());

  //   // print('PDF saved at: $filePath');

  //   print('PDF saved at: ${file.path}');

  //   return pdf;
  // }

  Future<void> saveAndOpenPDF(pw.Document pdf) async {
    final directory = await getDownloadsDirectory();
    final downloadsDirectory = Directory('${directory!.path}');

    if (!downloadsDirectory.existsSync()) {
      downloadsDirectory.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'appointment_report_$timestamp.pdf';

    final filePath = '${downloadsDirectory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF saved at: $filePath');

    if (Platform.isAndroid) {
      OpenFile.open(filePath);
    } else if (Platform.isIOS) {}
  }

  // Future<void> generateAndSavePDF(
  //     List<Map<String, dynamic>> appointments) async {
  //   final pdf = pw.Document();

  //   // Add content to the PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Text(
  //                 'Appointment Report',
  //                 style: pw.TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: pw.FontWeight.bold,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 20),
  //               pw.Table.fromTextArray(
  //                 context: context,
  //                 data: appointments.map((appointment) {
  //                   return [
  //                     appointment['user_name'],
  //                     appointment['time'],
  //                     appointment['date'],
  //                   ];
  //                 }).toList(),
  //                 headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //                 border: pw.TableBorder.all(),
  //                 headerDecoration: pw.BoxDecoration(
  //                   color: PdfColors.grey300,
  //                 ),
  //                 cellAlignment: pw.Alignment.center,
  //                 defaultColumnWidth: pw.FlexColumnWidth(1.0),
  //                 // defaultVerticalAlignment:
  //                 //     pw.TableCellVerticalAlignment.middle,
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   // Get the downloads directory path
  //   final directory = await getDownloadsDirectory();
  //   final downloadsDirectory = Directory('${directory!.path}/lawyersreport/');

  //   // Create the directory if it doesn't exist
  //   if (!downloadsDirectory.existsSync()) {
  //     downloadsDirectory.createSync(recursive: true);
  //   }

  //   // Generate a unique filename based on the current timestamp
  //   final timestamp = DateTime.now().millisecondsSinceEpoch;
  //   final fileName = 'appointment_report_$timestamp.pdf';

  //   // Save the PDF file
  //   final filePath = '${downloadsDirectory.path}/$fileName';
  //   final file = File(filePath);
  //   await file.writeAsBytes(await pdf.save());

  //   print('PDF saved at: $filePath');
  // }
  // Future<void> generateAndSavePDF() async {
  //   final pdf = pw.Document();

  //   // Add content to the PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Text('Appointments Report',
  //               style:
  //                   pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //         );
  //       },
  //     ),
  //   );

  // // Get the downloads directory path
  // final directory = await getDownloadsDirectory();
  // final downloadsDirectory = Directory('${directory!.path}/lawyersreport/');

  // // Create the directory if it doesn't exist
  // if (!downloadsDirectory.existsSync()) {
  //   downloadsDirectory.createSync(recursive: true);
  // }

  // // Generate a unique filename based on the current timestamp
  // final timestamp = DateTime.now().millisecondsSinceEpoch;
  // final fileName = 'appointment_report_$timestamp.pdf';

  // // Save the PDF file
  // final filePath = '${downloadsDirectory.path}/$fileName';
  // final file = File(filePath);
  // await file.writeAsBytes(await pdf.save());

  // print('PDF saved at: $filePath');

  //   // print('PDF saved at: $path');

  // print('PDF saved at: $filePath');
  // }

  Widget checkStatus(status) {
    var text = "";
    Color color = Colors.grey;
    switch (status) {
      case 0:
        text = "pending";
        color = Colors.grey;

        break;
      case 1:
        text = "accepted";
        color = Colors.green;
        break;

      case 2:
        text = "denied";
        color = Colors.red;
        break;

      default:
        text = "pending";
        color = Colors.grey;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          child: Text("status: $text",
              style: TextStyle(fontSize: 12, color: Colors.white)),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        ),
      ],
    );
  }
}
