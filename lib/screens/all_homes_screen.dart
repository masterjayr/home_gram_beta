import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:home_gram_beta/screens/home_detail_screen.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:home_gram_beta/widgets/card_data.dart';
import 'package:home_gram_beta/services/user.dart';


class AllHomesScreen extends StatefulWidget {
  final User user = UserActivity();
  @override
  _AllHomesScreenState createState() => _AllHomesScreenState();
}

class _AllHomesScreenState extends State<AllHomesScreen> {
  final List<CardViewModel> allHomeCards = List<CardViewModel>();
  bool isLoading = false;
  double scrollPercent = 0.0;

  void _getInitialData() async{
    List<DocumentSnapshot> closestHomesGotten =
        await widget.user.getClosestHomesToLocation();
    List<DocumentSnapshot> allHomesGotten = 
        await widget.user.getAllHomes();
    for(int i =0; i< allHomesGotten.length; i++) {
      for(int j =0; j< closestHomesGotten.length; j++){
        if(allHomesGotten[i].data['uid'] == closestHomesGotten[j].data['uid']) {
          allHomeCards.insert(j, CardViewModel(
            document : closestHomesGotten[j].data,
            address: closestHomesGotten[j].data['address'],
            noOfRooms: closestHomesGotten[j].data['noOfRooms'],
            pictureUrl: closestHomesGotten[j].data['uploadedImages'][0],
            price: closestHomesGotten[j].data['price']
          ));
          print(closestHomesGotten[i].data['uid']);
          print(allHomesGotten[j].data['uid']);
          closestHomesGotten.remove(closestHomesGotten[i]);
        } 
      }
    }
    for(int i=0; i<allHomeCards.length; i++) {
      print(allHomeCards[i].price);
    }
  }

  @override
  void initState() {
    super.initState();
    _getInitialData();
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
            child: CardFlipper(
                cards: allHomeCards,
                onScroll: (double scrollPercent) {
                  setState(() {
                    this.scrollPercent = scrollPercent;
                  });
                }),
          ),
          //bottom bar
          BottomBar(
            cardCount: allHomeCards.length,
            scrollPercent: scrollPercent,
          )
        ],
      ),
    );
  }
}

class CardFlipper extends StatefulWidget {
  final List<CardViewModel> cards;
  final Function(double scrollPercent) onScroll;

  CardFlipper({this.cards, this.onScroll});

  @override
  _CardFlipperState createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper>
    with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  @override
  void initState() {
    super.initState();

    finishScrollController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    )..addListener(() {
        setState(() {
          scrollPercent = lerpDouble(
              finishScrollStart, finishScrollEnd, finishScrollController.value);

          if (widget.onScroll != null) {
            widget.onScroll(scrollPercent);
          }
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    finishScrollController.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    final numCards = widget.cards.length;
    setState(() {
      scrollPercent =
          (startDragPercentScroll + (-singleCardDragPercent / numCards))
              .clamp(0.0, 1.0 - (1 / numCards));
    });

    if (widget.onScroll != null) {
      widget.onScroll(scrollPercent);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    finishScrollStart = scrollPercent;
    final numCards = widget.cards.length;
    finishScrollEnd = (scrollPercent * numCards).round() / numCards;
    finishScrollController.forward(from: 0.0);
    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  List<Widget> _buildCards() {
    final cardCount = widget.cards.length;
    int index = -1;
    return widget.cards.map((CardViewModel viewModel) {
      ++index;
      return _buildCard(viewModel, index, cardCount, scrollPercent);
    }).toList();
  }

  Matrix4 _buildCardProjection(double scrollPercent) {
    final perspective = 0.002;
    final radius = 1.0;
    final angle = scrollPercent * pi / 8;
    final horizontalTranslation = 0.0;
    Matrix4 projection = new Matrix4.identity()
      ..setEntry(0, 0, 1 / radius)
      ..setEntry(1, 1, 1 / radius)
      ..setEntry(3, 2, -perspective)
      ..setEntry(2, 3, -radius)
      ..setEntry(3, 3, perspective * radius + 1.0);

    final rotationPointMultiplier = angle > 0.0 ? angle / angle.abs() : 1.0;
    print('Angle :$angle');
    projection *= Matrix4.translationValues(
            horizontalTranslation + (rotationPointMultiplier * 300.0),
            0.0,
            0.0) *
        Matrix4.rotationY(angle) *
        Matrix4.translationValues(0.0, 0.0, radius) *
        Matrix4.translationValues(-rotationPointMultiplier * 300.0, 0.0, 0.0);
    return projection;
  }

  Widget _buildCard(CardViewModel viewModel, int cardIndex, int cardCount,
      double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - (cardIndex / cardCount);

    return FractionalTranslation(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Transform(
            transform: _buildCardProjection(cardScrollPercent - cardIndex),
            child: Card(
              viewModel: viewModel,
              parallaxPercent: parallax,
            ),
          )),
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

class Card extends StatefulWidget {
  final CardViewModel viewModel;
  final double parallaxPercent;
  Card({this.viewModel, this.parallaxPercent = 0.0});
  @override
  _CardState createState() => _CardState();
}

class _CardState extends State<Card> {
  void _checkAvailability() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context)=> HomeDetailScreen(house: widget.viewModel.document,))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        //Background
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FractionalTranslation(
            translation: Offset(widget.parallaxPercent * 2.0, 0.0),
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Image.network(
                widget.viewModel.pictureUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        //content
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Text(
                widget.viewModel.address.toUpperCase(),
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
                Text('N${widget.viewModel.price}',
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
              child: GestureDetector(
                  onTap: _checkAvailability,
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
              ),
            )
          ],
        ),
      ],
    );
  }
}


class BottomBar extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  BottomBar({this.cardCount, this.scrollPercent});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 5.0,
              child: ScrollIndicator(
                  cardCount: cardCount, scrollPercent: scrollPercent),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  ScrollIndicator({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScrollIndicatorPainter(
          cardCount: cardCount, scrollPercent: scrollPercent),
      child: Container(),
    );
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  final int cardCount;
  final double scrollPercent;
  final Paint trackPaint;
  final Paint thumbPaint;

  ScrollIndicatorPainter({this.cardCount, this.scrollPercent})
      : trackPaint = Paint()
          ..color = Color(0xFF444444)
          ..style = PaintingStyle.fill,
        thumbPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    //Draw track
    canvas.drawRRect(
        new RRect.fromRectAndCorners(
          new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: new Radius.circular(3.0),
          topRight: new Radius.circular(3.0),
          bottomLeft: new Radius.circular(3.0),
          bottomRight: new Radius.circular(3.0),
        ),
        trackPaint);

    //Draw  thumb
    final thumbWidth = size.width / cardCount;
    final thumbLeft = scrollPercent * size.width;

    canvas.drawRRect(
        new RRect.fromRectAndCorners(
          new Rect.fromLTWH(thumbLeft, 0.0, thumbWidth, size.height),
          topLeft: new Radius.circular(3.0),
          topRight: new Radius.circular(3.0),
          bottomLeft: new Radius.circular(3.0),
          bottomRight: new Radius.circular(3.0),
        ),
        thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
