import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// import 'package:dropdown_search/dropdown_search.dart';
import 'package:lawyers/screens/pdfapi.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:africas_talking/africas_talking.dart';
import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/authentication.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final item;
  AppointmentDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool isSubmitted = false;
  bool isSuccessfully = false;
  String message = "";
  String _responseText = '';

  static const String key =
      '1f507e2ab04069cb665a0ae33f4b5ffe6a239d3dc68cf1258d30ae36ebfe5306';
  final db = FirebaseFirestore.instance;

  TextEditingController selectedBookingDateController = TextEditingController();
  TextEditingController selectedBookingDateController2 =
      TextEditingController();
  TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid:
          'AC654dd3a61b0d9fd1826ac251752995cb', // replace *** with Account SID
      authToken:
          'd94431e5df6dac77262a2f007e0d934f', // replace xxx with Auth Token
      twilioNumber: '+18573746722' // replace .... with Twilio Number
      );

  String categoryValue = "09:00AM - 10:00AM";
  // final docFile = DefaultCacheManager().getSingleFile(docUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lawyer Details")),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: ListView(children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
              child: widget.item.get('lawyer_photo') == ""
                  ? ClipRRect(
                      child: Image.asset("assets/images/avatar.png",
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(10))
                  : ClipRRect(
                      child: Image.network(widget.item.get("lawyer_photo"),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(10))),
          SizedBox(
            height: 16,
          ),
          FutureBuilder(
              future: db.collection("appointments").doc(widget.item.id).get(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snap) {
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

                return Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.item.get('user_name'),
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.blue)),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Date: ${widget.item.get('date')}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black)),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                        "Time: ${widget.item.get('time') != null ? widget.item.get('time') : ''}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black)),
                    SizedBox(
                      height: 16,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                    ),
                    checkStatus(snap.data!.get('status')),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              onPressed: snap.data!.get('status') == 0
                                  ? () {
                                      db
                                          .collection("appointments")
                                          .doc(widget.item.id)
                                          .update({"status": 2}).then(
                                              (value) async {
                                        // twilioFlutter.sendSMS(
                                        //     toNumber:
                                        //         widget.item.get('user_number'),
                                        //     messageBody:
                                        //         'LAYWER APPOINMENT APP - Your appointment has been denied.');
                                        fetchData('denied', '',
                                            widget.item.get('user_number'));
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: ((context) {
                                          return AppointmentDetailScreen(
                                              item: widget.item);
                                        })));
                                      }).onError((error, stackTrace) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "There was an error. Try Again later"),
                                          backgroundColor: Colors.red,
                                        ));
                                      });
                                    }
                                  : null,
                              child: Text("Deny")),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              onPressed: snap.data!.get('status') == 0
                                  ? () {
                                      db
                                          .collection("appointments")
                                          .doc(widget.item.id)
                                          .update({"status": 1}).then((value) {
                                        // sendFeedback(
                                        //     widget.item.get('user_number'),
                                        //     // '+255719401594',
                                        //     "LAYWER APPOINMENT APP - Your appointment has been accepted. You can contact the Lawyer through: ${widget.item.get('lawyer_number')}");
                                        fetchData(
                                            'accepted',
                                            widget.item.get('lawyer_number'),
                                            widget.item.get('user_number'));
                                        // twilioFlutter.sendSMS(
                                        //     toNumber:
                                        //         widget.item.get('user_number'),
                                        //     messageBody:
                                        //         'LAYWER APPOINMENT APP - Your appointment has been accepted. You can contact the Lawyer through: ${widget.item.get('lawyer_number')}');
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: ((context) {
                                          return AppointmentDetailScreen(
                                              item: widget.item);
                                        })));
                                      }).onError((error, stackTrace) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "There was an error. Try Again later"),
                                          backgroundColor: Colors.red,
                                        ));
                                      });
                                    }
                                  : null,
                              child: Text("Accept")),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // ElevatedButton(
                        //     onPressed: () {
                        //       // Navigator.push(
                        //       //     context,
                        //       //     MaterialPageRoute(
                        //       //         builder: (context) => MyWidget()));
                        //       // sendFeedback(
                        //       //     // widget.item.get('user_number'),
                        //       //     '+255719401594',
                        //       //     "LAYWER APPOINMENT APP - Your appointment has been accepted. You can contact the Lawyer through: ${widget.item.get('lawyer_number')}");
                        //     },
                        //     child: Text('Test Button'))
                      ],
                    ),
                  ],
                ));
              }),
        ]),
      ),
    );
  }

  // Future<void> sendFeedback(phone, message) async {
  //   try {
  //     var africasTalking = AfricasTalking('sandbox', key);

  //     // set to false when testing
  //     // africasTalking.isLive = false;

  //     // *****************************SMS************************************
  //     // initialize sms; Takes your registered short code or alphanumeric, defaults to AFRICASTKNG

  //     Sms sms = africasTalking.sms('13888');
  //     print(sms);
  //     print(africasTalking);
  //     print(key);

  //     // send sms
  //     sms.send(message: message, to: [phone]);

  //     print("i have send the message");
  //     print(phone);
  //   } catch (e) {
  //     print(e);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           e.toString(),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<void> fetchData(String state, String phoneL, String phoneC) async {
    print("1");
    final response = await http.get(
      Uri.parse(
          // 'http://192.168.0.104:8000/demo?phoneC=${phoneC}&phoneL=${phoneL}&state=$state'),i f);
          'http://192.168.43.68:8000/demo?phoneC=${phoneC}&phoneL=${phoneL}&state=$state'),
    );

    print("2");

    if (response.statusCode == 200) {
      // Successful GET request

      final jsonResponse = jsonDecode(response.body);
      setState(() {
        _responseText = jsonResponse['message'];
      });
      print("3");
    } else {
      // Error handling
      setState(() {
        _responseText = 'Error: ${response.statusCode}';
      });
      print("4");
    }
  }

  Future<void> _showSelectDate(BuildContext context) async {
    var dateSelect = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020, 1),
        lastDate: DateTime(2040));
    if (dateSelect != null) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      final selctedFormatedDate = dateFormat.format(dateSelect);
      setState(() {
        selectedBookingDateController.text = selctedFormatedDate;
      });
    }
    if (selectedBookingDateController.text != null) {
      // setState(() {
      //   dataFilter = true;
      // });
    }
  }

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
