// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class MyWidget extends StatefulWidget {
//   @override
//   _MyWidgetState createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   String _responseText = '';

//   Future<void> fetchData(String state, String phoneL, String phoneC) async {
//     print("1");
//     final response = await http.get(Uri.parse('http://192.168.0.104:8000/demo?phoneC=${phoneC}&phoneL=${phoneL}&state=$state'));
//     print("2");

//     if (response.statusCode == 200) {
//       // Successful GET request
      
//       final jsonResponse = jsonDecode(response.body);
//       setState(() {
//         _responseText = jsonResponse['message'];
//       });
//     print("3");

//     } else {
//       // Error handling
//       setState(() {
//         _responseText = 'Error: ${response.statusCode}';
//       });
//     print("4");

//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('GET Request Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: fetchData,
//               child: const Text('Make GET Request'),
//             ),
//             const SizedBox(height: 20),
//             Text('Response: $_responseText'),
//           ],
//         ),
//       ),
//     );
//   }
// }
