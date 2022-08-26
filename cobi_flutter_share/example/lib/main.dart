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
        id: "hello",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Hello!",
        shortLabel: "Hello",
        imageBytes: buffer.asUint8List()
      )
    );
    await CobiFlutterShare.instance.addDirectShareTarget(
      DirectShareTarget(
        id: "world",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "World!",
        shortLabel: "World",
        imageBytes: buffer.asUint8List()
      )
    );
  }
  
  void addMultipleShareTargets() async {
    var data = await rootBundle.load('assets/24.bmp');
    // Directory dir = await getApplicationSupportDirectory();
    // String filename = dir.path + "/image.png";
    var buffer = data.buffer;
    // await File(filename).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    var targets = [
      DirectShareTarget(
        id: "foo",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Hello!",
        shortLabel: "Hello",
        imageBytes: buffer.asUint8List()
      ),
      DirectShareTarget(
        id: "bar",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Hello!",
        shortLabel: "Hello",
        imageBytes: buffer.asUint8List()
      )
    ];
    await CobiFlutterShare.instance.addDirectShareTargets(targets);
  }
  
  void _removeShareTarget() async {
    await CobiFlutterShare.instance.removeShareTarget("hello");
    setState(() {
      _data = null;
    });
  }
  
  void _removeAllShareTargets() async {
    await CobiFlutterShare.instance.removeAllShareTargets();
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
              child: Text("Publish 2 share targets")
            ),
            ElevatedButton(
              onPressed: _removeShareTarget,
              child: Text("Remove share target 'hello'")
            ),
            ElevatedButton(
              onPressed: _removeAllShareTargets,
              child: Text("Remove all share targets")
            ),
            Text("Data:"),
            Text(_data?.toJson().toString() ?? "No data received"),
          ],
        ),
      ),
    );
  }
}
