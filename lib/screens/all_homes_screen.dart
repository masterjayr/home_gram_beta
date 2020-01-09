import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:home_gram_beta/ui/const.dart';

class AllHomesScreen extends StatefulWidget {
  @override
  _AllHomesScreenState createState() => _AllHomesScreenState();
}

class _AllHomesScreenState extends State<AllHomesScreen> {
  List<Map<String, dynamic>> allHomes = [];

  void populateList() {
    for (int i = 0; i < 10; i++) {
      allHomes.add({});
    }
  }

  @override
  void initState() {
    populateList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Room for status bar
          Container(
            width: double.infinity,
            height: 20,
          ),
          //Cards
          Expanded(
            child: CardFlipper(),
          ),
          //bottom bar
          Container(
            width: double.infinity,
            height: 50,
            color: themeColor,
          )
        ],
      ),
    );
  }
}


class CardFlipper extends StatefulWidget {
  @override
  _CardFlipperState createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper> with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  @override void initState() {
    super.initState();

    finishScrollController =  AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    )
      ..addListener((){
        setState(() {
          scrollPercent = lerpDouble(finishScrollStart, finishScrollEnd, finishScrollController.value); //todo
        });
      });

  }

  @override void dispose() {
    super.dispose();
    finishScrollController.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details){
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;

  }

  void _onHorizontalDragUpdate(DragUpdateDetails details){
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;
    
    final numCards = 3; 
    setState(() {
      scrollPercent = (startDragPercentScroll + (-singleCardDragPercent / numCards).clamp(0.0, 1.0 - (1 / numCards)));

    });

  }

  void _onHorizontalDragEnd(DragEndDetails details){
    finishScrollStart = scrollPercent;
    final numCards = 3; 
    finishScrollEnd = (scrollPercent * numCards).round() / numCards;
    finishScrollController.forward(from: 0.0);
    setState(() {
      startDrag = null;
      startDragPercentScroll= null;
    });
  }


  List<Widget> _buildCards() {
    return [
      _buildCard(0 , 3, scrollPercent),
      _buildCard(1 , 3, scrollPercent),  
      _buildCard(2 , 3, scrollPercent)
    ];
  }
  Widget _buildCard(int cardIndex, int cardCount, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    return FractionalTranslation(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card()
      ),
      translation: Offset(cardIndex - cardScrollPercent, 0.0),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
          child: Stack(
        children: _buildCards(),
      ),
    );
  }
}

class Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        //Background
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/notbestfriends.png',
            fit: BoxFit.cover,
          ),
        ),

        //content
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Text(
                'NO 3 beach Street Jos'.toUpperCase(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('\$30000/yr',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                    )),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: themeColor,
                  width: 1.5,
                ),
                color: Colors.black.withOpacity(0.3),
              ),
              child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Check Availability',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Icon(
                      MaterialCommunityIcons.check,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
                ),
            )
          ],
        ),
      ],
    );
  }
}
