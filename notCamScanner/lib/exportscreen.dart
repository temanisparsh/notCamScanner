import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';

class ExportScreen extends StatefulWidget {
  final dynamic image;
  Function reset;
  Function removeLast;

  ExportScreen(this.image, this.reset, this.removeLast);
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Final Document'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Share'),
                    onPressed: () async {
                      await Share.files(
                          'esys images',
                          {
                            'export.jpeg': this.widget.image,
                          },
                          '*/*',
                          text: 'My Scanned Image');
                      this.widget.reset();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  RaisedButton(
                    child: Text('Discard All'),
                    onPressed: () async {
                      this.widget.reset();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  RaisedButton(
                    child: Text('Add More'),
                    onPressed: () {
                      this.widget.removeLast();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Container(
                  child: Center(child: Image.memory(this.widget.image)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
