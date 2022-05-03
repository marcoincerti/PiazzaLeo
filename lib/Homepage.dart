import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app4/TabPages/CompetizioniPage.dart';
import 'package:flutter_app4/TabPages/CorsiPage.dart';
import 'package:line_icons/line_icons.dart';
import 'TabPages/SeminariPage.dart';
import 'account_manager/account_persona.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String universita;
  String titolo = "SPOTTED !!";

  _HomePageState();

  int _selectedIndex = 0;
// static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

  List<Widget> _widgetOptions = <Widget>[
    SeminariPage(auth: _auth),
    CorsiPage(auth: _auth),
    CompetizioniPage(auth: _auth),
  ];

  TextEditingController editingController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    //FirebaseAuth.instance.signOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 130.0,
              floating: false,
              pinned: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))),
              elevation: 8,
              backgroundColor: Colors.lightGreen,
              actions: <Widget>[
                IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  icon: Icon(
                    LineIcons.userCircle,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => accountPersona()));
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Text(
                            titolo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(15.0),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(160, 173, 203, 139),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Post di oggi:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                    Text(
                                      "200",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(15.0),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(160, 173, 203, 139),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Post di sempre:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                    Text(
                                      "2000",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LineIcons.book),
            label: 'Spotted',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.rocket),
            label: 'Feste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_late_outlined),
            label: 'Sport e Giochi',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          titolo = "SPOTTED !!";
          break;
        case 1:
          titolo = "FESTE 🎉";
          break;
        case 2:
          titolo = "Sport e Giochi";
          break;
      }
    });
  }
}
