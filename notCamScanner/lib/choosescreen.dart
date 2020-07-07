import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';

class ChooseScreen extends StatefulWidget {
  final Function setCurrentFile;
  final Function getCount;
  final Function exportFinal;
  final Function reset;

  ChooseScreen(this.setCurrentFile, this.getCount, this.exportFinal, this.reset);

  @override
  _ChooseScreenState createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
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
        title: Text('Choose Image'),
      ),
      body: Center(
          child: this.loading
              ? Container(
                  child: LoadingFlipping.circle(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Click from Camera'),
                      onPressed: () {
                        this.widget.setCurrentFile(ImageSource.camera, context, toggleLoading);
                      },
                    ),
                    RaisedButton(
                      child: Text('Choose from Storage'),
                      onPressed: () {
                        this.widget.setCurrentFile(
                            ImageSource.gallery, context, toggleLoading);
                      },
                    ),
                    this.widget.getCount() == 0 ? Container() : RaisedButton(
                      child: Text('Export Document'),
                      onPressed: () {
                        this.widget.exportFinal(toggleLoading, context);
                      },
                    ),
                    this.widget.getCount() == 0 ? Container() : RaisedButton(
                      child: Text('Discard All'),
                      onPressed: () {
                        this.widget.reset();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                    
                  ],
                )),
    );
  }
}
