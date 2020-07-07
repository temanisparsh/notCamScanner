import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image/choosescreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:loading_animations/loading_animations.dart';

class DisplayCropper extends StatefulWidget {
  final Function getCurrentFilePath;
  final Function getCurrentFile;
  final Function addFile;
  final Function updateFile;
  final Function setCurrentFile;
  final Function getCount;
  final Function exportFinal;
  final Function reset;

  DisplayCropper(this.getCurrentFilePath, this.getCurrentFile, this.addFile,
      this.setCurrentFile, this.getCount, this.exportFinal, this.updateFile, this.reset);

  @override
  _DisplayCropperState createState() => _DisplayCropperState();
}

class _DisplayCropperState extends State<DisplayCropper> {
  bool loading = false;

  toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cropped Image'),
      ),
      body: this.loading
          ? Center(
              child: Container(
                child: LoadingFlipping.circle(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.05),
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Image.memory(widget.getCurrentFile()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            RaisedButton(
                              child: Text('Crop Manually'),
                              onPressed: () async {
                                dynamic res = await getCroppedImage();
                                if (res != null) {
                                  this.widget.updateFile(res);
                                  setState(() {});
                                }
                              },
                            ),
                            RaisedButton(
                              child: Text('Save & Continue'),
                              onPressed: () {
                                this
                                    .widget
                                    .addFile(this.widget.getCurrentFile());
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChooseScreen(
                                          this.widget.setCurrentFile,
                                          this.widget.getCount,
                                          this.widget.exportFinal,
                                          this.widget.reset,
                                        )));
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            RaisedButton(
                              child: Text('Save & Export'),
                              onPressed: () {
                                widget.addFile(widget.getCurrentFile());
                                this.widget.exportFinal(toggleLoading, context);
                              },
                            ),
                            RaisedButton(
                              child: Text('Discard Image'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  dynamic getCroppedImage() async {
    dynamic image = widget.getCurrentFilePath();
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          lockAspectRatio: false,
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "RPS Cropper",
          statusBarColor: Colors.deepOrange.shade900,
          backgroundColor: Colors.white,
        ),
      );
      if (cropped == null) {
        return cropped;
      } else {
        List<int> imageBuffer = cropped.readAsBytesSync();
        String imageBase64 = base64Encode(imageBuffer);
        return imageBase64;
      }
    }
  }
}
