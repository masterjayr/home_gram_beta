import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_gram_beta/screens/home_detail_screen.dart';
import 'package:home_gram_beta/ui/const.dart';

class SearchResultScreen extends StatefulWidget {
  SearchResultScreen({this.docs});
  final List<DocumentSnapshot> docs;
  
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        
      ),
      body: ListView.builder(
        itemCount: widget.docs.length,
        itemBuilder: (BuildContext context, index) {
          return Container(
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      child: Image.network(widget.docs[index].data['uploadedImages'][0]),
                    ),
                    Positioned(
                      left: 30.0,
                      top: 30.0,
                      child: Text('${widget.docs[index].data['address']}', style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold))),
                      Center(child: Text('${widget.docs[index].data['price']}'),)
                  ],
                ),
                OutlineButton(
                  child: Text('Check Availability'),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomeDetailScreen(house: widget.docs[index].data,)));
                  },
                  color: themeColor,

                ),
                Divider(color: themeColor,thickness: 1.0,)
              ],
            ),
          );
        },
      ),
    );
  }
}