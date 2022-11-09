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
  ShareItem? _currentFetch;
  
  _MyHomePageState() {
    CobiFlutterShare.instance.onShareReceived.listen((event) async {
      setState(() {
        _data = event;
      });
      for (ShareItem item in event.items) {
        print("receiving item: ${item.basename}, type: ${item.type}, mimeType: ${item.mimeType}");
        DateTime start = DateTime.now();
        print("Start: $start");
        setState(() {
          _currentFetch = item;
        });
        item.getContents()?.listen((chunk) {
          print("${item.basename}: received chunk ${chunk.index}");
        },
        onDone: () {
          DateTime end = DateTime.now();
          Duration diff = end.difference(start);
          print("End: $end");
          print("It took $diff");
          setState(() {
            _currentFetch = null;
          });
        },);
      }
    });
  }

  void _addShareTargets() async{
    var data = await rootBundle.load('assets/24.bmp');
    // Directory dir = await getApplicationSupportDirectory();
    // String filename = dir.path + "/image.png";
    var buffer = data.buffer;
    // await File(filename).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    await CobiFlutterShare.instance.addShareTarget(
      ShareTarget(
        id: "hello",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Hello!",
        shortLabel: "Hello",
        imageBytes: buffer.asUint8List()
      )
    );
    await CobiFlutterShare.instance.addShareTarget(
      ShareTarget(
        id: "world",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "World!",
        shortLabel: "World",
        imageBytes: buffer.asUint8List()
      )
    );
  }
  
  void _addMultipleShareTargets() async {
    var data = await rootBundle.load('assets/24.bmp');
    // Directory dir = await getApplicationSupportDirectory();
    // String filename = dir.path + "/image.png";
    var buffer = data.buffer;
    // await File(filename).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    var targets = [
      ShareTarget(
        id: "foo",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Foo!",
        shortLabel: "Foo",
        imageBytes: buffer.asUint8List()
      ),
      ShareTarget(
        id: "bar",
        categories: ["de.cobinja.CATEGORY_ONE"],
        longLabel: "Bar!",
        shortLabel: "Bar",
        imageBytes: buffer.asUint8List()
      )
    ];
    await CobiFlutterShare.instance.addShareTargets(targets);
  }
  
  void _removeSingleShareTarget() async {
    await CobiFlutterShare.instance.removeShareTarget("hello");
    setState(() {
      _data = null;
    });
  }
  
  void _removeMultipleShareTargets() async {
    await CobiFlutterShare.instance.removeShareTargets(["foo", "bar"]);
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
  
  void _pauseCurrentFetch() {
    _currentFetch?.pauseFetch();
  }
  
  void _continueCurrentFetch() {
    _currentFetch?.continueFetch();
  }
  
  void _abortCurrentFetch() {
    _currentFetch?.abortFetch();
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
              onPressed: _addShareTargets,
              child: Text("Publish share targets\n'hello' and 'world'\nin two single steps", textAlign: TextAlign.center)
            ),
            Divider(),
            ElevatedButton(
              onPressed: _addMultipleShareTargets,
                child: Text("Publish share targets\n'foo' and 'bar'\nin one step", textAlign: TextAlign.center)
            ),
            Divider(),
            ElevatedButton(
              onPressed: _removeSingleShareTarget,
              child: Text("Remove share target 'hello'")
            ),
            Divider(),
            ElevatedButton(
              onPressed: _removeMultipleShareTargets,
              child: Text("Remove share targets 'foo' and 'bar'")
            ),
            Divider(),
            ElevatedButton(
              onPressed: _removeAllShareTargets,
              child: Text("Remove all share targets")
            ),
            Divider(),
            ElevatedButton(
              onPressed: _currentFetch != null ? _pauseCurrentFetch : null,
              child: Text("Pause current fetch")
            ),
            ElevatedButton(
              onPressed: _currentFetch != null ? _continueCurrentFetch : null,
              child: Text("Continue current fetch")
            ),
            ElevatedButton(
              onPressed: _currentFetch != null ? _abortCurrentFetch : null,
              child: Text("Abort current fetch")
            ),
            Divider(),
            Divider(),
            Text("Data:"),
            Text(_data?.toJson().toString() ?? "No data received"),
          ],
        ),
      ),
    );
  }
}
