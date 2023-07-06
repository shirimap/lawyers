import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
// import 'package:power_file_view/power_file_view.dart';


class PDFViewerFromUrl extends StatelessWidget {
  const PDFViewerFromUrl({Key? key, required this.url,required this.username}) : super(key: key);

  final String url;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('${username} CV'),
      ),
      body: const PDF().fromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}














class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached PDF From Url'),
      ),
      body: const PDF().cachedFromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
















// class PowerFileViewPage extends StatefulWidget {
//   final String downloadUrl;
//   final String downloadPath;

//   const PowerFileViewPage(
//       {Key? key, 
//       required this.downloadUrl, 
//       required this.downloadPath})
//       : super(key: key);

//   @override
//   State<PowerFileViewPage> createState() => _PowerFileViewPageState();
// }

// class _PowerFileViewPageState extends State<PowerFileViewPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('File Preview'),
//       ),
//       body: PowerFileViewWidget(
//         downloadUrl: widget.downloadUrl,
//         filePath: widget.downloadPath,
//       ),
//     );
//   }
// }
