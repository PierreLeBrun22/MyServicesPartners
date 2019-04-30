import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.qrCode})
      : super(key: key);

  final String qrCode;

  @override
  State<StatefulWidget> createState() => new _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  @override
  Widget build(BuildContext context) {
    print(widget.qrCode);
    return new Expanded(
            child: new Container(
                color: Color(0xFF302f33),
                child: new ListView(children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: 'assets/img/user.png',
                        child: Container(
                          height: 125.0,
                          width: 125.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(62.5),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/img/user.png'))),
                        ),
                      ),
                      SizedBox(height: 25.0),
                      Row(
                        children: <Widget>[
                          Text(
                        'Pierre',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 20.0),
                      ),
                      Text(
                        'Le Brun',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 20.0),
                      ),
                        ],
                      ),
                      Text(
                        'Orange',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF43e97b),
                            fontSize: 18.0),
                      ),
                    ],
                  )
                ])));
  }
}
