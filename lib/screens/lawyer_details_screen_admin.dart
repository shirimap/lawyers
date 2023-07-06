// import 'dart:html';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:lawyers/screens/pdfview.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
// import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:dio/dio.dart';
import '../utils/authentication.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
class LawyerDetailAdminScreen extends StatefulWidget {
  final item;

  LawyerDetailAdminScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<LawyerDetailAdminScreen> createState() => _LawyerDetailAdminScreenState();
}

class _LawyerDetailAdminScreenState extends State<LawyerDetailAdminScreen> {
  bool isSubmitted = false;
  bool isSuccessfully = false;
  String doc = '';
  String message = "";
  var appointments = [];
 final User? user = FirebaseAuth.instance.currentUser;
  


  final db = FirebaseFirestore.instance;

  TextEditingController selectedBookingDateController = TextEditingController();
  TextEditingController selectedBookingDateController2 =
      TextEditingController();
  TextEditingController url = TextEditingController();

  double? _progress;

  TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid:
          'AC654dd3a61b0d9fd1826ac251752995cb', // replace *** with Account SID
      authToken:
          'd94431e5df6dac77262a2f007e0d934f', // replace xxx with Auth Token
      twilioNumber: '+18573746722' // replace .... with Twilio Number
      );

  // String categoryValue = "09:00AM - 10:00AM";
  String categoryValue = "";

  List<String> allTimes = [
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 AM",
    "12:00 AM - 13:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM"
  ];

  List<String> _availableTimes = [];

  Map<String, List<String>> appointmentMap = {};

  getLaywerAppointments() async {
    await db
        .collection("appointments")
        .where("lawyer", isEqualTo: widget.item.get('uid'))
        .get()
        .then((appoints) {
      for (int i = 0; i < appoints.docs.length; i++) {
        // add data to list you want to return.
        // print(appoints.docs[i].data());
        print("the extracted appointments");
        addAppointment(
            appoints.docs[i].data()['date'], appoints.docs[i].data()['time']);
        // print(appoints.docs[i].data()['date']);
        // appointments[appoints.docs[i].data()['date']].add(appoints.docs[i].data()['time']);
      }
    });

    print(appointmentMap);
  }

  void addAppointment(String date, String appointment) {
    if (appointmentMap.containsKey(date)) {
      // Date already exists, append the appointment
      appointmentMap[date]!.add(appointment);
    } else {
      // Date doesn't exist, create a new list and add the appointment
      appointmentMap[date] = [appointment];
    }
  }

  Future<void>? _launched;

  Future<void> _launchInBrowser(url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  String? downloadedFilePath;

  String? pdfFlePath;

  // Future<void> downloadAndOpenFile(String url) async {
  //   try {
  //     final String fileName = widget.item['name'] + ' CV.pdf';
  //     final Directory? appDocDir = await getExternalStorageDirectory();
  //     final String downloadPath = '${appDocDir!.path}/lawyers/$fileName';

  //     await FileDownloader.downloadFile(
  //       url: url,
  //       saveAsName: fileName,
  //       directory: '${appDocDir.path}/lawyers',
  //       showNotification: true,
  //       openFileFromNotification: false,
  //     );

  //     setState(() {
  //       downloadedFilePath = downloadPath;
  //     });
  //   } catch (e) {
  //     print('DOWNLOAD ERROR: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    getLaywerAppointments();
    return Scaffold(
      appBar: AppBar(title: Text("Lawyer Details")),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: ListView(children: [
          widget.item.get('photo') == ""
              ? ClipRRect(
                  child: Image.asset("assets/images/avatar.png",
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10))
              : ClipRRect(
                  child: Image.network(widget.item.get("photo"),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10)),
          SizedBox(
            height: 20,
          ),
          // widget.item.get('documentUrl') == ""
          //     ? Text("No CV yet")
          //     : Container(
          //         height: 100,
          //         child: Text(
          //           widget.item.get('documentUrl'),
          //         ),
          //       ), 

             widget.item.get('documentUrl') == ""
                  ? const Text("No CV Uploaded")
                  // : MaterialButton(
                  //     onPressed: () {
                  //       downloadAndOpenFile();
                  //     },
                  //     child: Text("View Cv"),
                  //   ),

                  : MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerFromUrl(
                              url: widget.item.get('documentUrl'),
                              username: widget.item.get('name'),
                            ),
                          ),
                        );
                        print(widget.item.get('documentUrl'));
                      },
                      color: Colors.blue,
                      child: Text("View Cv"),
                    ),
             
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.item.get('name'),
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.blue)),
              SizedBox(
                height: 20,
              ),
              Text("Specialization: ${widget.item.get('category')}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.black)),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Years of Experience: ${widget.item.get('years') != null ? widget.item.get('years') : ''}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.black)),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Availability: ${widget.item.get('availability') == 'true' ? "available" : 'not available'}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.black)),
              SizedBox(
                height: 10,
              ),
              //  widget.item.get('userRole')== "2"
              //       ? Container(
              //         child: Text(''),
              //       )
              //       :
              FutureBuilder(
                  future: db
                      .collection("users")
                      .doc(AuthenticationHelper().user.uid)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
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
                    if (snap.hasData) {
                      print("Data of lawyer");
                      print(snap.data?.data());
                    }
                    final int role = snap.data?.get('role') ?? 0;
                    // this checks the role of logged in user if == o mean is a nomral user he  can view the button
                    return role == 0
                        ? ElevatedButton(
                            onPressed: widget.item.get('availability') ==
                                        'true' &&
                                    !AuthenticationHelper().isAdmin
                                ? !isSubmitted
                                    ? AuthenticationHelper().user.uid !=
                                            widget.item.id
                                        ? () async {
                                            // setState(() {
                                            //   isSubmitted = !isSubmitted;
                                            // });

                                            var result = await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                title:
                                                    Text('Request Appointment'),
                                                content: StatefulBuilder(
                                                    // You need this, notice the parameters below:
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                          onTap: () =>
                                                              _showSelectDate(
                                                                  context,
                                                                  setState),
                                                          keyboardType:
                                                              TextInputType
                                                                  .none,
                                                          controller:
                                                              selectedBookingDateController,
                                                          decoration:
                                                              InputDecoration(
                                                                  label: Text(
                                                                      "Date"))),
                                                      Container(
                                                        child: DropdownSearch<
                                                            String>(
                                                          items:
                                                              _availableTimes,

                                                          popupProps:
                                                              PopupProps.menu(
                                                            showSelectedItems:
                                                                true,
                                                            menuProps:
                                                                MenuProps(
                                                              backgroundColor:
                                                                  Colors.white,
                                                            ),
                                                          ),

                                                          dropdownDecoratorProps:
                                                              DropDownDecoratorProps(
                                                            dropdownSearchDecoration:
                                                                InputDecoration(
                                                                    labelText:
                                                                        "Time"),
                                                          ),
                                                          // popupItemDisabled: (String s) => s.startsWith('I'),
                                                          onChanged: (data) {
                                                            setState(() {
                                                              categoryValue =
                                                                  data!;
                                                            });
                                                          },
                                                          selectedItem:
                                                              categoryValue,
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                }),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      // setState(() {
                                                      //   isSubmitted = !isSubmitted;
                                                      // });
                                                      setState(() {
                                                        isSuccessfully = true;
                                                      });
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      bool hasItems = false;
                                                      // performFilter();

                                                      // QuerySnapshot data = await db.collection("appointments").where("user_requested", )

                                                      QuerySnapshot lists = await db
                                                          .collection(
                                                              "appointments")
                                                          .where(
                                                              "user_requested",
                                                              isEqualTo:
                                                                  AuthenticationHelper()
                                                                      .user
                                                                      .uid)
                                                          .where("status",
                                                              isEqualTo: 1)
                                                          .where("lawyer",
                                                              isEqualTo: widget
                                                                  .item.id)
                                                          .where("time",
                                                              isEqualTo:
                                                                  categoryValue)
                                                          .where("date",
                                                              isEqualTo:
                                                                  selectedBookingDateController
                                                                      .text)
                                                          .get();
                                                      QuerySnapshot lists2 = await db
                                                          .collection(
                                                              "appointments")
                                                          .where(
                                                              "user_requested",
                                                              isEqualTo:
                                                                  AuthenticationHelper()
                                                                      .user
                                                                      .uid)
                                                          .where("lawyer",
                                                              isEqualTo: widget
                                                                  .item.id)
                                                          .where("status",
                                                              isEqualTo: 0)
                                                          .get();

                                                      if (lists.docs.length >
                                                          0) {
                                                        hasItems = true;
                                                        setState(() {
                                                          isSuccessfully =
                                                              false;
                                                          message =
                                                              "Already booked on that time";
                                                        });
                                                        Navigator.pop(
                                                            context, false);
                                                      }
                                                      if (lists2.docs.length >
                                                          0) {
                                                        hasItems = true;
                                                        setState(() {
                                                          isSuccessfully =
                                                              false;
                                                          message =
                                                              "You already booked";
                                                        });
                                                        Navigator.pop(
                                                            context, false);
                                                      }

                                                      if (selectedBookingDateController
                                                              .text ==
                                                          "") {
                                                        // hasItems = true;
                                                        setState(() {
                                                          isSuccessfully =
                                                              false;
                                                          message =
                                                              "Did not request, no date selected";
                                                        });
                                                        Navigator.pop(
                                                            context, false);
                                                      }

                                                      if (!hasItems) {
                                                        db
                                                            .collection(
                                                                "appointments")
                                                            .add({
                                                          "user_requested":
                                                              AuthenticationHelper()
                                                                  .user
                                                                  .uid,
                                                          "lawyer":
                                                              widget.item.id,
                                                          "date":
                                                              selectedBookingDateController
                                                                  .text,
                                                          "time": categoryValue,
                                                          "lawyer_name": widget
                                                              .item
                                                              .get("name"),
                                                          "user_number": snap
                                                              .data!
                                                              .get("phone"),
                                                          "user_name": snap
                                                              .data!
                                                              .get("name"),
                                                          "lawyer_number":
                                                              widget.item
                                                                  .get("phone"),
                                                          "lawyer_photo": widget
                                                              .item
                                                              .get("photo"),
                                                          "status": 0,
                                                          "datetime": FieldValue
                                                              .serverTimestamp()
                                                        }).then((value) {
                                                          setState(() {
                                                            isSuccessfully =
                                                                true;
                                                          });
                                                          twilioFlutter.sendSMS(
                                                              toNumber: widget
                                                                  .item
                                                                  .get("phone"),
                                                              messageBody:
                                                                  'LAYWER APPOINMENT APP - You have new appointment requested on the system');
                                                          Navigator.pop(
                                                              context, true);
                                                        }).onError((error,
                                                                stackTrace) {
                                                          setState(() {
                                                            isSuccessfully =
                                                                false;
                                                          });
                                                          Navigator.pop(
                                                              context, false);
                                                        });
                                                      }
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (isSuccessfully) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Appointment Requested")));
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(message),
                                                backgroundColor: Colors.red,
                                              ));
                                            }
                                          }
                                        : null
                                    : null
                                : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // NEW
                              // enabled: isSubmitted,
                            ),
                            child: Text("Request Appointment"),
                          )
                        : Container();
                  })
            ],
          )
        ]),
      ),
    );
  }

  // Future openFile({required String url, String? filename}) async {
  //   final name = filename ?? url.split('%2F').last;
  //   final file = await downloadFile(url, name);
  //   if (file == null) return;
  //   print('path: ${file.path}');

  //   OpenFile.open(file.path);
  // }

// private storage
  // Future<File?> downloadFile(String Url, String name) async {
  //   final appStorage = await getApplicationDocumentsDirectory();
  //   final file = File('${appStorage.path}/$name');
  //   try {
  //     final response = await Dio().get(url as String,
  //         options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           receiveTimeout: Duration(seconds: 0),
  //         ));
  //     final raf = file.openSync(mode: FileMode.write);
  //     raf.writeFromSync(response.data);
  //     await raf.close();
  //     return file;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<void> _showSelectDate(BuildContext context, stateSetter) async {
    var dateSelect = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 1)),
        // firstDate: DateTime(2020, 1),
        firstDate: DateTime.now().add(Duration(days: 1)),
        lastDate: DateTime(2040));
    if (dateSelect != null) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      final selctedFormatedDate = dateFormat.format(dateSelect);
      selectedBookingDateController.text = selctedFormatedDate;

      _availableTimes = List.from(allTimes);
      if (appointmentMap.containsKey(selctedFormatedDate)) {
        print("remove items");
        _availableTimes.removeWhere((element) =>
            appointmentMap[selctedFormatedDate]!.contains(element));
      }
      stateSetter(() {});
    }
    if (selectedBookingDateController.text != null) {
      // setState(() {
      //   dataFilter = true;
      // });
    }
  }
}

//  : MaterialButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PDFViewerFromCachedUrl(
//           url: widget.item.get('documentUrl'),
//         ),
//       ),
//     );
//   },
//   child: Text("View Cv"),
// ),
// : MaterialButton(
//     onPressed: () {
//       FileDownloader.downloadFile(
//           url: widget.item.get('documentUrl'),
//           name: "${widget.item.get('name')} CV",
//           onDownloadCompleted: (String path) async {
//             // final Directory? appDocDir =
//             //     await getExternalStorageDirectory();
//             // path = '${appDocDir!.path}/lawyers/${name}';

//             // openFile(url: path);
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //     builder: (context) => PDFViewerPage(path: path),
//             //   ),
//             // );
//             try {
//               print(path);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       PowerFileViewPage(downloadUrl: path,downloadPath: path),
//                 ),
//               );
//               // PDFView(
//               //   filePath: path!,
//               //   enableSwipe: true,
//               //   swipeHorizontal: true,
//               // );
//               print('FILE DOWNLOADED TO PATH: $path');
//             } catch (e) {
//               print(e);
//             }
//             // setState(() {
//             //   downloadedFilePath = path;
//             // });
//             // print('FILE DOWNLOADED TO PATH: $path');
//             // if (downloadedFilePath != null) {
//             //   try {
//             //     PDFView(
//             //       filePath: downloadedFilePath,
//             //       enableSwipe: true,
//             //       swipeHorizontal: true,
//             //     );
//             //   } catch (e) {
//             //     print(e.toString());
//             //   }
//             // }
//           },
//           onDownloadError: (String error) {
//             print('DOWNLOAD ERROR: $error');
//           });
//     },
//     child: Text("View Cv"),
//   ),

// : MaterialButton(
//   child: Text(
//     "View CV"
//   ),
//     onPressed: () => setState(() {
//           _launched =
//               _launchInBrowser(widget.item.get('documentUrl'));
//         })),

// : MaterialButton(
//     onPressed: () => openFile(
//       url: widget.item.get('photo'),
//       // filename: 'mastra.jpg',
//     ),
//     child: Text("Download Cv"),
//   ),

//  widget.item.get('documentUrl') == ""
//  ? Container(
//   child:SfPdfViewer.asset('assets/images/pdf.pdf'),
//  )
//  :Container(
//   // height: 200,
//   child:SfPdfViewer.network(widget.item.get()) ,
//  ),
//  ,

// widget.item.get('documentUrl') == ""
//     ? SizedBox(
//         child:PdfView(path: 'assets/images/pdf.pdf'),
//       )
//     : Container(
//         height: 200,
//         // width: 100,
//         child: PdfView(
//           path: 'assets/images/pdf.pdf',
//           // path: widget.item.get("documentUrl"),
//         ),
//       ),
