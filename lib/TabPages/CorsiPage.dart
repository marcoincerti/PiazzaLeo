import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CorsiPage extends StatefulWidget {
  final FirebaseAuth auth;

  const CorsiPage({Key key, this.auth}) : super(key: key);

  @override
  _CorsiPageState createState() => _CorsiPageState();
}

class _CorsiPageState extends State<CorsiPage> {
  int segmentedControlGroupValue = 0;

  Stream collectionStream;

  Map<String, dynamic> user;
  DocumentSnapshot lastDocument;
  List<DocumentSnapshot> lista = [];

  ScrollController controller = ScrollController();
  TextEditingController editingController = TextEditingController();
  //Color colorContainer = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 5, right: 5),
      child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: NotificationListener<ScrollNotification>(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            //controller: controller,
            child: Column(
              children: <Widget>[getChildWidget()],
            ),
          ),
          // ignore: missing_return
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              //fetchNextMovies();
            }
          },
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
                color: Colors.lightGreen,
              ),
            ),
          );
        }

        lista = List.from(snapshot.data.docs);

        if (segmentedControlGroupValue == 1) {
          lista.shuffle();
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
    lastDocument = document;
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
          DataConvertitore(data['data_inizio']),
          Divider(),
          SizedBox(
            height: 1,
          ),
          Text("${data['titolo']}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          SizedBox(
            height: 15,
          ),
          Text(
            "${data['descrizione']}",
            style: TextStyle(fontSize: 15),
          ),
          Divider(),
          data.containsKey("ospite")
              ? SizedBox(
                  height: 5,
                )
              : SizedBox(
                  height: 1,
                ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.containsKey('aperto')
                          ? data['aperto'].toString()
                          : "0",
                      textAlign: TextAlign.end,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      Icons.insert_chart,
                      color: Colors.lightGreen,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Mi piace'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget DataConvertitore(Timestamp data) {
    DateTime d = data.toDate();
    String formatDate = DateFormat('EEEE dd MMMM yy').format(d);
    String formatOra = DateFormat('kk:mm').format(d);
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            child: Row(children: <Widget>[
              Icon(
                LineIcons.calendarCheck,
                color: Colors.orange,
              ),
              SizedBox(
                width: 3,
              ),
              Text(
                formatDate,
                style: TextStyle(fontWeight: FontWeight.w500),
              )
            ]),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  formatOra,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 3,
                ),
                Icon(
                  LineIcons.clock,
                  color: Colors.orange,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Stream getData2() {
    return FirebaseFirestore.instance
        .collection('seminari')
        .where("data_inizio", isGreaterThanOrEqualTo: new DateTime.now())
        .orderBy("data_inizio")
        .limit(50)
        .snapshots();
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
