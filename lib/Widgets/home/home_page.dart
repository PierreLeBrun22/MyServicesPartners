import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:myservicespartners/Widgets/DetailPage/DetailPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String barcode = "";

  Future<bool> _getUsedOrNot(String qrCode) async {
    bool used;
     final qr = jsonDecode(qrCode);
    final userId = qr[0];
    final serviceId = qr[1];
    CollectionReference ref = Firestore.instance.collection('userServices');
    QuerySnapshot eventsQuery = await ref.getDocuments();
    eventsQuery.documents.forEach((document) {
      if (document.data.containsValue(userId) &&
          document.data.containsValue(serviceId)) {
          used = document.data['used'];
      }
    });
    return used;
  }

  @override
  initState() {
    super.initState();
  }

  Container _getAppBar() {
    return new Container(
      height: 60.0,
      color: Color(0xFF673AB7),
    );
  }

  Container _getAppbarWhite() {
    return new Container(
      margin: const EdgeInsets.only(top: 24.0, right: 12.0, left: 12.0),
      height: 55,
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4.0),
        color: Color(0xFFf7f7f7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(
            FontAwesomeIcons.handshake,
            color: Color(0xFF673AB7),
            size: 40.0,
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: Text('MyServices',
                style: TextStyle(
                    fontFamily: 'Satisfy',
                    fontSize: 30,
                    color: Color(0xFF4B4954))),
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: new Icon(
              FontAwesomeIcons.handshake,
              color: Color(0xFF673AB7),
              size: 40.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new Container(
            padding: EdgeInsets.only(top: 60.0),
            child: new Column(children: <Widget>[
              new Expanded(
                child: new Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF302f33),
                  ),
                  child: new Center(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: RaisedButton(
                            animationDuration: Duration(milliseconds: 1000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.all(0),
                            child: Text(
                              "Scan !",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontFamily: 'Satisfy',
                              ),
                            ),
                            onPressed: () {
                              scan();
                            },
                            elevation: 4,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
          _getAppBar(),
          _getAppbarWhite()
        ],
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      bool used = await _getUsedOrNot(barcode);
       Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DetailPage(qrCode: barcode, used: used)));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
