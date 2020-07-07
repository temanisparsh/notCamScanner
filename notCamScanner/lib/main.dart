import 'dart:convert';
import 'dart:io';

import 'package:flutter_image/choosescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/displaycropped.dart';
import 'package:flutter_image/exportscreen.dart';
import 'package:http/http.dart';

import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Document Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> files = [];
  int count = 0;
  dynamic currentFile;
  dynamic currentFilePath;

  final String baseURL = "127.0.0.1:5000";
  // Switch to "http://ameyabhamare.pythonanywhere.com" to test the deployed web server;

  addFile(dynamic file) {
    setState(() {
      files.add(file);
      count += 1;
    });
  }

  getCount() {
    return count;
  }

  updateFile(dynamic image) {
    setState(() {
      currentFile = base64Decode(image);
    });
  }

  setCurrentFile(
      ImageSource source, BuildContext ctx, Function toggleLoading) async {
    toggleLoading();

    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(source: source);

    if (image == null) {
      toggleLoading();
      return;
    }

    setState(() {
      currentFilePath = image;
    });

    List<int> imageBuffer = image.readAsBytesSync();
    String imageBase64 = base64Encode(imageBuffer);

    setState(() {
      currentFile = base64Decode(imageBase64);
    });

    toggleLoading();
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (BuildContext context) => DisplayCropper(
        getCurrentFilePath,
        getCurrentFile,
        addFile,
        setCurrentFile,
        getCount,
        exportFinal,
        updateFile,
        resetSystem,
      ),
    ));
  }

  resetSystem() {
    setState(() {
      count = 0;
      files = [];
      currentFile = '';
      currentFilePath = '';
    });
  }

  exportFinal(Function toggleLoading, BuildContext context) {
    toggleLoading();
    dynamic temp_files = files.map((file) => base64Encode(file)).toList();
    post(
      "$baseURL/getExport",
      body: json.encode({
        "images": temp_files,
      }),
      headers: <String, String>{
        "Content-Type": "application/json",
      },
    ).then((response) {
      print("HERE");
      toggleLoading();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => ExportScreen(
              base64Decode(response.body), resetSystem, removeLast),
        ),
      );
    });
  }

  removeLast() {
    setState(() {
      count -= 1;
      files.removeLast();
    });
  }

  dynamic getCurrentFile() {
    return currentFile;
  }

  dynamic getCurrentFilePath() {
    return currentFilePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RaisedButton(
            child:
                Text('Start Scanning', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ChooseScreen(
                      setCurrentFile, getCount, exportFinal, resetSystem)));
            },
            color: Colors.blue),
      ),
    );
  }
}
