import 'package:cobi_flutter_share/cobi_flutter_share.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "Flutter Demo Home Page"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  ShareData? _data;
  
  _MyHomePageState() {
    CobiFlutterShare.instance.onShareReceived.listen((event) {
      setState(() {
        _data = event;
      });
    });
  }

  void _addShareTarget() async{
    var data = await rootBundle.load('assets/24.bmp');
    // Directory dir = await getApplicationSupportDirectory();
    // String filename = dir.path + "/image.png";
    var buffer = data.buffer;
    // await File(filename).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    await CobiFlutterShare.instance.addDirectShareTarget(
      DirectShareTarget(
        id: "hallo",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Hallo, Welt!",
        shortLabel: "Hallo",
        imageBytes: buffer.asUint8List()
      )
    );
  }
  
  void _removeShareTarget() async {
    await CobiFlutterShare.instance.removeShareTarget("hallo");
    setState(() {
      _data = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _addShareTarget,
              child: Text("Publish share target")
            ),
            ElevatedButton(
              onPressed: _removeShareTarget,
              child: Text("Remove sharet target")
            ),
            Text("Data:"),
            Text(_data?.toJson().toString() ?? "No data received"),
          ],
        ),
      ),
    );
  }
}
