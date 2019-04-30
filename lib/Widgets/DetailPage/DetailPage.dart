import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:async';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.qrCode, this.used}) : super(key: key);

  final String qrCode;
  final bool used;

  @override
  State<StatefulWidget> createState() => new _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  int _state = 0;
  Animation _animation;
  AnimationController _controller;
  GlobalKey _globalKey = GlobalKey();
  double _width = double.maxFinite;

  List<NewItem> items = <NewItem>[
    new NewItem(
      true,
      'SERVICE',
      new Icon(FontAwesomeIcons.infoCircle, color: Color(0xFF673AB7)),
    )
  ];

  void _pushServiceActivation() async {
    final qr = jsonDecode(widget.qrCode);
    final userId = qr[0];
    final serviceId = qr[1];
    CollectionReference ref1 = Firestore.instance.collection('userServices');
    QuerySnapshot eventsQuery = await ref1.getDocuments();
    eventsQuery.documents.forEach((document) {
      if (document.data.containsValue(userId) &&
          document.data.containsValue(serviceId)) {
        Firestore.instance
            .collection('userServices')
            .document(document.documentID)
            .updateData(
          {'used': true},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        constraints: new BoxConstraints.expand(),
        color: Colors.white,
        child: new Stack(
          children: <Widget>[
            _getContent(),
            _getToolbar(context),
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot> _getContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('user').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Column(children: <Widget>[
            new Expanded(
                child: new Container(
              decoration: BoxDecoration(
                color: Color(0xFF302f33),
              ),
              child: Center(child: CircularProgressIndicator()),
            )),
          ]);
        final qr = jsonDecode(widget.qrCode);
        final userId = qr[0];
        final record = snapshot.data.documents
            .where((data) => data.data.containsKey(userId))
            .single
            .data[userId];
        if (widget.used || widget.used == null) {
          return new Column(children: <Widget>[
            new Expanded(
              child: new Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF302f33),
                  ),
                  child: Center(
                    child: Text("You already use this service or cancel it",
                        style: TextStyle(
                            fontFamily: 'Satisfy',
                            color: Colors.white,
                            fontSize: 25)),
                  )),
            ),
          ]);
        } else {
          return new Column(children: <Widget>[
            new Expanded(
                child: new Container(
                    color: Color(0xFF302f33),
                    child: new ListView(children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Hero(
                              tag: 'assets/img/user.png',
                              child: Container(
                                height: 125.0,
                                width: 125.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(62.5),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image:
                                            AssetImage('assets/img/user.png'))),
                              ),
                            ),
                          ),
                          SizedBox(height: 25.0),
                          Text(
                            record['firstName'] + " " + record['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 25.0),
                          ),
                          Text(
                            record['company'],
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFF673AB7),
                                fontSize: 20.0),
                          ),
                          new StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection('services')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return new Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF302f33),
                                  ),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              final qr = jsonDecode(widget.qrCode);
                              final serviceId = qr[1];
                              final record = snapshot.data.documents
                                  .where((data) => data.documentID == serviceId)
                                  .single;
                              List<Widget> panelList = [];
                              panelList.add(Text(record['name'],
                                  style: TextStyle(
                                      color: Color(0xFF4B4954),
                                      fontSize: 25.0,
                                      fontFamily: 'Satisfy')));
                              panelList.add(new Container(
                                  margin:
                                      new EdgeInsets.symmetric(vertical: 8.0),
                                  height: 2.0,
                                  width: 18.0,
                                  color: Color(0xFF673AB7)));
                              panelList.add(Text(record['description'],
                                  style: TextStyle(
                                      color: Color(0xFF4B4954),
                                      fontSize: 16.0,
                                      fontFamily: 'Poppins')));
                              return new Padding(
                                padding: new EdgeInsets.only(
                                    top: 30.0,
                                    left: 10.0,
                                    right: 10.0,
                                    bottom: 10.0),
                                child: new ExpansionPanelList(
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    setState(() {
                                      items[index].isExpanded =
                                          !items[index].isExpanded;
                                    });
                                  },
                                  children: items.map((NewItem item) {
                                    return new ExpansionPanel(
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return new ListTile(
                                            leading: item.iconpic,
                                            title: new Text(
                                              item.header,
                                              textAlign: TextAlign.left,
                                              style: new TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w200,
                                                fontFamily: 'Poppins',
                                              ),
                                            ));
                                      },
                                      isExpanded: item.isExpanded,
                                      body: new Padding(
                                          padding:
                                              new EdgeInsets.only(bottom: 20.0),
                                          child:
                                              new Column(children: panelList)),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          _buttonCancel(context),
                        ],
                      )
                    ]))),
          ]);
        }
      },
    );
  }

  Center _buttonCancel(BuildContext context) {
    return new Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 30,
        ),
        child: Align(
          alignment: Alignment.center,
          child: PhysicalModel(
            elevation: 8,
            shadowColor: Colors.black12,
            color: Color(0xFF43e97b),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              key: _globalKey,
              height: 48,
              width: _width,
              child: RaisedButton(
                animationDuration: Duration(milliseconds: 1000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.all(0),
                child: setUpButtonChild(),
                onPressed: () {
                  setState(() {
                    if (_state == 0) {
                      animateButton();
                      _pushServiceActivation();
                    }
                  });
                },
                elevation: 4,
                color: Color(0xFF673AB7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  setUpButtonChild() {
    if (_state == 0) {
      return Text(
        "Confirm payment",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30.0,
          fontFamily: 'Satisfy',
        ),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      Navigator.maybePop(context);
    }
  }

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animation = Tween(begin: 0.0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        _state = 2;
      });
    });
  }

  Container _getToolbar(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: new BackButton(color: Colors.white),
    );
  }
}

class NewItem {
  bool isExpanded;
  final String header;
  final Icon iconpic;
  NewItem(this.isExpanded, this.header, this.iconpic);
}

double discretevalue = 2.0;
double hospitaldiscretevalue = 25.0;
