import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsCardTile extends StatefulWidget {
  final DashboardController? data;
  final int? index;
  const StatsCardTile({Key? key, this.index, this.data}) : super(key: key);

  @override
  _StatsCardTileState createState() => _StatsCardTileState();
}

class _StatsCardTileState extends State<StatsCardTile> {
  @override
  void initState() {
    super.initState();
    updateLawyersCount();
    updateUsersCount();
    updateAdminsCount();
    updateAllUsersCount();
  }

  void updateLawyersCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role',
            isEqualTo: 1) // Assuming 'role' field is used to identify lawyers
        .get();
    final count = snapshot.docs.length.toString();
    setState(() {
      widget.data?.dashboardList[0].value = count;
    });
  }

  void updateUsersCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role',
            isEqualTo: 0) // Assuming 'role' field is used to identify lawyers
        .get();
    final count = snapshot.docs.length.toString();
    setState(() {
      widget.data?.dashboardList[1].value = count;
    });
  }

  void updateAdminsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role',
            isEqualTo: 2) // Assuming 'role' field is used to identify lawyers
        .get();
    final count = snapshot.docs.length.toString();
    setState(() {
      widget.data?.dashboardList[2].value = count;
    });
  }

  void updateAllUsersCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        // Assuming 'role' field is used to identify lawyers
        .get();
    final count = snapshot.docs.length.toString();
    setState(() {
      widget.data?.dashboardList[3].value = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          if (widget.index == 0) {
            GoRouter.of(context).go("/home/profile/lawyers");
          } else if (widget.index == 1) {
            GoRouter.of(context).go("/home/profile/users");
          } else if (widget.index == 2) {
            GoRouter.of(context).go("/home/profile/admins");
          }else if (widget.index == 3) {
            GoRouter.of(context).go("/home/profile/allusers");
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Commons.dashColor[widget.index!],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.data!.dashboardList[widget.index!].icon,
                  color: Colors.white,
                  size: 40,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextBuilder(
                      text: widget.data!.dashboardList[widget.index!].value!,
                      fontSize: 17.0,
                      color: Colors.white,
                    ),
                    TextBuilder(
                      text: widget.data!.dashboardList[widget.index!].title!,
                      textOverflow: TextOverflow.clip,
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardController {
  final dashboardList = [
    DashboardModel(
      icon: Icons.verified,
      title: 'Lawyers',
      value: '0',
    ),
    DashboardModel(
      icon: Icons.groups_outlined,
      title: 'Users',
      value: '0',
    ),
    DashboardModel(
      icon: Icons.groups_outlined,
      title: 'Admins',
      value: '0',
    ),
    DashboardModel(
      icon: Icons.groups_outlined,
      title: 'All users',
      value: '0',
    ),
  ];
}

class DashboardModel {
  final String? title;
  String? value; // Update to non-final

  final IconData? icon;

  DashboardModel({this.title, this.value, this.icon});
}

class TextBuilder extends StatefulWidget {
  final String? text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final double? latterSpacing;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final double? height;
  final double? wordSpacing;
  final TextDecoration? textDecoration;
  final FontStyle? fontStyle;
  const TextBuilder({
    Key? key,
    this.text,
    this.fontSize,
    this.color,
    this.textOverflow,
    this.fontWeight,
    this.latterSpacing,
    this.maxLines,
    this.textAlign,
    this.height,
    this.wordSpacing,
    this.textDecoration,
    this.fontStyle,
  }) : super(key: key);

  @override
  State<TextBuilder> createState() => _TextBuilderState();
}

class _TextBuilderState extends State<TextBuilder> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text!,
      style: GoogleFonts.lato(
        fontSize: widget.fontSize,
        color: widget.color,
        fontWeight: widget.fontWeight,
        letterSpacing: widget.latterSpacing,
        height: widget.height,
        wordSpacing: widget.wordSpacing,
        decoration: widget.textDecoration,
        fontStyle: widget.fontStyle,
      ),
      maxLines: widget.maxLines,
      overflow: widget.textOverflow,
      textAlign: widget.textAlign,
    );
  }
}

class Commons {
  static const tileBackgroundColor = const Color(0xFFF1F1F1);
  static const chuckyJokeBackgroundColor = const Color(0xFFF1F1F1);
  static const chuckyJokeWaveBackgroundColor = const Color(0xFFA8184B);
  static const gradientBackgroundColorEnd = const Color(0xFF601A36);
  static const gradientBackgroundColorWhite = const Color(0xFFFFFFFF);
  static const mainAppFontColor = const Color(0xFF4D0F29);
  static const appBarBackGroundColor = const Color(0xFF4D0F28);
  static const categoriesBackGroundColor = const Color(0xFFA8184B);
  static const hintColor = const Color(0xFF4D0F29);
  static const mainAppColor = const Color(0xFF4D0F29);
  static const gradientBackgroundColorStart = const Color(0xFF4D0F29);
  static const popupItemBackColor = const Color(0xFFDADADB);
  static List<Color> dashColor = [
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Color(0xff1AB0B0),
    Color(0xff1AB0B0),
    Color(0xff1AB0B0),
    Color(0xff1AB0B0)
  ];

  static void showError(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: TextBuilder(text: message),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15)),
              actions: <Widget>[
                TextButton(
                  child: TextBuilder(text: "Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}
