import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompetizioniPage extends StatefulWidget {
  final FirebaseAuth auth;
  const CompetizioniPage({Key key, this.auth}) : super(key: key);
  @override
  _CompetizioniPageState createState() => _CompetizioniPageState();
}

class _CompetizioniPageState extends State<CompetizioniPage> {
  int segmentedControlGroupValue = 0;

  Stream collectionStream;
  Stream tags_account;

  Map<String, dynamic> user;
  DocumentSnapshot lastDocument;
  List<DocumentSnapshot> lista = [];

  ScrollController controller = ScrollController();
  TextEditingController editingController = TextEditingController();
  Color colorContainer = Colors.red;

  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("  Live  "),
    2: Text("  Tips  "),
    3: Text("Preferiti"),
  };

  @override
  void initState() {
    tags_account = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.auth.currentUser.uid)
        .snapshots();
    //controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 5, right: 5),
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: NotificationListener<ScrollNotification>(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                //controller: controller,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: colorContainer,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  colorContainer == Colors.red
                                      ? colorContainer = Colors.green
                                      : colorContainer = Colors.red;
                                });
                              },
                              child: Icon(
                                LineIcons.mapMarker,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              controller: editingController,
                              decoration: InputDecoration(
                                  labelText: "Search",
                                  hintText: "Search",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSlidingSegmentedControl(
                      groupValue: segmentedControlGroupValue,
                      children: myTabs,
                      onValueChanged: (i) {
                        setState(
                          () {
                            segmentedControlGroupValue = i;
                          },
                        );
                      },
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: tags_account,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            child: Center(
                              child: Loading(
                                  indicator: BallPulseIndicator(),
                                  size: 100.0,
                                  color: Colors.lightBlue),
                            ),
                          );
                        }
                        user = snapshot.data.data();
                        return getChildWidget();
                      },
                    ),
                  ],
                ),
              ),
              // ignore: missing_return
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  //fetchNextMovies();
                }
              }),
        ),
      ),
    );
  }

  Widget getChildWidget() {
    return StreamBuilder(
      stream: getData2(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            child: Center(
              child: Loading(
                indicator: BallPulseIndicator(),
                size: 100.0,
                color: Colors.lightBlue,
              ),
            ),
          );
        }

        lista = List.from(snapshot.data.docs);
        List tags_utente = List.from(user['tags_interesse']);

        if (user["attiva_filtri"]) {
          if ((segmentedControlGroupValue == 0) && tags_utente.length > 10) {
            var toRemove = [];

            lista.forEach((documento) {
              Map<String, dynamic> data = documento.data();
              List tags_evento = List.from(data['tags']);
              bool presente = false;
              for (var tag in tags_utente) {
                if (tags_evento.contains(tag)) {
                  presente = true;
                  break;
                }
              }
              presente ? null : toRemove.add(documento);
            });
            lista.removeWhere((e) => toRemove.contains(e));
          }
        }

        return ListView.builder(
            shrinkWrap: true,
            controller: controller,
            itemCount: lista.length,
            itemBuilder: (context, index) => _buildList(context, lista[index]));
      },
    );
  }

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data();
    bool ciao = false;
    lastDocument = document;

/*    if (data.containsKey("riservato_universita") && user != null) {
      if (data["riservato_universita"] == user["universita_uid"]) {
        if (data.containsKey("riservato_corso")) {
          if (data["riservato_corso"] == user["corso_uid"]) {
            ciao = true;
          } else {
            ciao = false;
          }
        } else {
          ciao = true;
        }
      } else {
        ciao = false;
      }
    } else {
      ciao = true;
    }*/

    if (editingController.text.isEmpty) {
      //if (ciao) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.all(15.0),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 30,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: NumeroTags(List.from(data["tags"])),
                  itemBuilder: (context, index) =>
                      _buildTagsList(context, data["tags"][index])),
            ),
            SizedBox(
              height: 15,
            ),
            Text("${data['titolo']}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            SizedBox(
              height: 15,
            ),
            Text("${data['descrizione']}",
                style: TextStyle(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            Divider(),
            data.containsKey("tipologia")
                ? SizedBox(
                    height: 5,
                  )
                : SizedBox(
                    height: 1,
                  ),
            data.containsKey("tipologia")
                ? Center(
                    child: Text(
                      "${data['tipologia']}",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            data.containsKey("tipologia")
                ? Divider()
                : SizedBox(
                    height: 0,
                  ),
            data.containsKey("ospite")
                ? SizedBox(
                    height: 5,
                  )
                : SizedBox(
                    height: 1,
                  ),
            data.containsKey("ospite")
                ? Center(
                    child: Text(
                      "Ospite:\n ${data['ospite']}",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            data.containsKey("ospite")
                ? Divider()
                : SizedBox(
                    height: 0,
                  ),
            data.containsKey("offerto")
                ? /*FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('universita').doc(data['riservato_universita']).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading");
                        }
                        Map<String, dynamic> universita = snapshot.data.data();*/
                Container(
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 15, right: 15),
                    margin: EdgeInsets.only(
                      bottom: 15.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text("Offerto da:\n ${data["offerto"]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                    ),
                  )
                /*})*/
                : SizedBox(
                    height: 0,
                  ),
            Row(
              children: [
                Expanded(
                  child: data.containsKey('data_inizio')
                      ? DataConvertitore(data['data_inizio'])
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: data.containsKey('provider')
                              ? Text(data['provider'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500))
                              : Icon(
                                  LineIcons.timesCircle,
                                  color: Colors.deepOrangeAccent,
                                ),
                        ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          data.containsKey('aperto')
                              ? data['aperto'].toString()
                              : "0",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Icon(
                        Icons.insert_chart,
                        color: Colors.lightGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      /*} else {
        return SizedBox(
          height: 0,
        );
      }*/
    } else if (document["titolo"]
            .toLowerCase()
            .contains(editingController.text.toLowerCase()) ||
        document["descrizione"]
            .toLowerCase()
            .contains(editingController.text.toLowerCase())) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.all(15.0),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 30,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: NumeroTags(List.from(data["tags"])),
                  itemBuilder: (context, index) =>
                      _buildTagsList(context, data["tags"][index])),
            ),
            SizedBox(
              height: 15,
            ),
            Text("${data['titolo']}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            SizedBox(
              height: 15,
            ),
            Text("${data['descrizione']}",
                style: TextStyle(fontSize: 15),
                maxLines: 4,
                overflow: TextOverflow.ellipsis),
            Divider(),
            data.containsKey("ospite")
                ? SizedBox(
                    height: 5,
                  )
                : SizedBox(
                    height: 1,
                  ),
            data.containsKey("ospite")
                ? Center(
                    child: Text(
                      "Ospite:\n ${data['ospite']}",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            data.containsKey("ospite")
                ? Divider()
                : SizedBox(
                    height: 0,
                  ),
            data.containsKey("offerto")
                ? /*FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('universita').doc(data['riservato_universita']).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading");
                        }
                        Map<String, dynamic> universita = snapshot.data.data();*/
                Container(
                    padding: EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 15, right: 15),
                    margin: EdgeInsets.only(
                      bottom: 15.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text("Offerto da:\n ${data["offerto"]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15)),
                    ),
                  )
                /*})*/
                : SizedBox(
                    height: 0,
                  ),
            Row(
              children: [
                Expanded(
                  child: data.containsKey('data_inizio')
                      ? DataConvertitore(data['data_inizio'])
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: data.containsKey('provider')
                              ? Text(data['provider'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500))
                              : Icon(
                                  LineIcons.timesCircle,
                                  color: Colors.deepOrangeAccent,
                                ),
                        ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            data.containsKey('aperto')
                                ? data['aperto'].toString()
                                : "0",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(
                          Icons.insert_chart,
                          color: Colors.lightGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildTagsList(BuildContext context, String data) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 2.0, bottom: 2.0, left: 15, right: 15),
        child: Center(
            child: Text(
          data,
          style: TextStyle(fontSize: 15),
        )),
      ),
    );
  }

  Widget DataConvertitore(Timestamp data) {
    DateTime d = data.toDate();
    String formatDate = DateFormat('EEEE dd MMMM yy').format(d);
    String formatOra = DateFormat('kk:mm').format(d);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: <Widget>[
          Icon(
            LineIcons.calendarCheck,
            color: Colors.lightGreen,
          ),
          Text(formatDate)
        ]),
        Row(
          children: <Widget>[
            Icon(
              LineIcons.clock,
              color: Colors.lightGreen,
            ),
            Text(formatOra)
          ],
        )
      ],
    );
  }

  int NumeroTags(List<String> data) {
    return data.length;
  }

  Stream getData2() {
    List<String> tags = List.from(user["tags_interesse"]);
    switch (segmentedControlGroupValue) {
      case 0:
        if (tags.length <= 10 && user["attiva_filtri"] && tags.isNotEmpty) {
          return FirebaseFirestore.instance
              .collection('competizioni')
              .where("live", isEqualTo: true)
              .where("data_fine", isGreaterThanOrEqualTo: new DateTime.now())
              .where('tags', arrayContainsAny: tags)
              .orderBy("data_fine")
              //.limit(20)
              .snapshots();
        } else {
          return FirebaseFirestore.instance
              .collection('competizioni')
              .where("live", isEqualTo: true)
              .where("data_fine", isGreaterThanOrEqualTo: new DateTime.now())
              .orderBy("data_fine")
              //.limit(70)
              .snapshots();
        }
        break;
      case 2:
        return FirebaseFirestore.instance
            .collection('competizioni')
            .orderBy("aperto", descending: true)
            //.limit(5)
            .snapshots();
        break;
      case 3:
        return FirebaseFirestore.instance
            .collection('users')
            .doc(widget.auth.currentUser.uid)
            .collection('competizioni')
            .where("data_fine", isGreaterThanOrEqualTo: new DateTime.now())
            .orderBy("data_fine")
            .snapshots();
        break;
    }
  }

  /*fetchNextMovies() async {
    try {
      List<String> tags = List.from(user["tags_interesse"]);
      List<DocumentSnapshot> newDocumentList;
      //updateIndicator(true);
      switch (segmentedControlGroupValue) {
        case 0:
          if(tags.length <= 10){
            newDocumentList = (await FirebaseFirestore.instance
                .collection('seminari')
                .orderBy("data_inizio")
                .where("live", isEqualTo: true)
                .where("data_inizio",
                isGreaterThanOrEqualTo: new DateTime.now())
                .where('tags', arrayContainsAny: tags)
                .startAfterDocument(lista[lista.length - 1])
                .limit(20)
                .get())
                .docs;
          }else {
            newDocumentList = (await FirebaseFirestore.instance
                .collection('seminari')
                .orderBy("data_inizio")
                .where("live", isEqualTo: true)
                .where("data_inizio", isGreaterThanOrEqualTo: new DateTime.now())
                .startAfterDocument(lista[lista.length - 1])
                .limit(20).get()).docs;
          }
          break;
        case 1:
          if(tags.length <= 10){
            tags.shuffle();
            newDocumentList = (await FirebaseFirestore.instance
                .collection('seminari')
                .where("live", isEqualTo: false)
                .startAfterDocument(lista[lista.length - 1])
                .where('tags', arrayContainsAny: tags)
                .limit(50)
                .get()).docs;
          }else {
            newDocumentList = (await FirebaseFirestore.instance.collection('seminari').startAfterDocument(lista[lista.length - 1]).where("live", isEqualTo: false).limit(20).get()).docs;
          }
          break;
        case 2:
          newDocumentList = (await FirebaseFirestore.instance.collection('seminari').startAfterDocument(lista[lista.length - 1]).limit(20).get()).docs;
          break;
        case 3:
          if (user.containsKey('seminari')) {
            if (user['seminari'].length > 10) {
              collectionStream = null;
              var chunks = partition(user['seminari'], 10);

              return FirebaseFirestore.instance.collection('seminari').where(FieldPath.documentId, whereIn: chunks.first).limit(50).snapshots();
            } else {
              return FirebaseFirestore.instance.collection('seminari').where(FieldPath.documentId, whereIn: user['seminari']).limit(50).snapshots();
            }
          } else {
            return FirebaseFirestore.instance.collection('seminari').where(FieldPath.documentId, whereIn: ['1']).limit(1).snapshots();
          }
          break;
      }
      setState(() {
        lista.addAll(newDocumentList);
      });

      //movieController.sink.add(documentList);
    } on SocketException {
      //movieController.sink.addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      //movieController.sink.addError(e);
    }
  }*/

  Future<void> _pullRefresh() async {
    setState(() {
      getData2();
    });
  }
}
