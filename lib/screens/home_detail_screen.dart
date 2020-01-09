import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:home_gram_beta/ui/const.dart';

class HomeDetailScreen extends StatefulWidget {
  @override
  _HomeDetailScreenState createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  bool mapToggle = false;
  var currentLocation;
  GoogleMapController mapController;
  List<Marker> _markers = [];

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  void initState() {
    super.initState();
    Geolocator().getCurrentPosition().then((currLoc) {
      setState(() {
        currentLocation = currLoc;
        _markers.add(Marker(
          markerId: MarkerId('myMarker'),
          position: LatLng(currLoc.longitude, currLoc.latitude),
        ));
        mapToggle = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Home Detail'),
        ),
        body: SafeArea(
                  child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _imageCarousel(context),
                _houseDetails(),
                Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      child: mapToggle
                          ? GoogleMap(
                              mapType: MapType.normal,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(currentLocation.longitude,
                                    currentLocation.latitude),
                                zoom: 5,
                              ),
                              markers: Set.from(_markers),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ),
                    //  Container(
                    //     decoration: BoxDecoration(color: Colors.white),
                    //     width: MediaQuery.of(context).size.width,
                    //     margin: EdgeInsets.symmetric(vertical: 200,),
                    //     child: Center(
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: <Widget>[
                    //           Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: <Widget>[
                    //             IconButton(
                    //                 onPressed: (){},
                    //                  icon: Icon(
                    //                 MaterialCommunityIcons.directions,
                    //                 color: Colors.blue,
                    //                 size: 40,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         Text('Directions', style: TextStyle(color: Colors.blue),)
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Image.asset(
                    'assets/bestfriends.png',
                    fit: BoxFit.fill,
                  ),
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Contact for more infor',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Your info will go to the landlord of the house',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            customTextAreas('Name', Fontisto.person),
                            SizedBox(height: 10,),
                            customTextAreas('Email', Fontisto.email),
                            SizedBox(height: 10,),
                            customTextAreas('Phone No', Fontisto.phone),
                            SizedBox(height: 10,),
                            customTextAreas('Message', Fontisto.text_height),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                buttons('Send', null),
                                Text('OR', style: TextStyle(fontWeight: FontWeight.bold),), 
                                buttons('Call', Fontisto.phone)
                              ],
                            )
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _imageCarousel(context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Carousel(
        boxFit: BoxFit.cover,
        images: [
          AssetImage('assets/bestfriends.png'),
          AssetImage('assets/notbestfriends.png'),
          AssetImage('assets/bestfriends.png'),
          AssetImage('assets/notbestfriends.png'),
        ],
        autoplay: false,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(microseconds: 1000),
        dotSize: 6,
        indicatorBgPadding: 2,
      ),
    );
  }

  Widget _houseDetails() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '#30,000/yr',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
              Icon(
                MaterialCommunityIcons.share,
                color: primaryColor,
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'No 33 Beach Streat Jos',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.blueGrey),
                ),
                Icon(
                  FontAwesome.map_marker,
                  color: primaryColor,
                )
              ])
        ],
      ),
    );
  }

  Widget customTextAreas(String labelText, IconData icon,) {
    return TextFormField(
        keyboardType: labelText == 'Phone No' ? TextInputType.phone : TextInputType.text,
        validator: (value) {
          if (value.isEmpty) {
            return 'Password can\'t be empty';
          } else if (value.length < 8) {
            return 'Password too short';
          }
          return null;
        },
        onSaved: (value) {
          setState(() {
            // _password = value;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(width: 1.0)
          ),
          suffixIcon: Icon(icon),
          labelText: '$labelText',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          hintStyle: TextStyle(fontStyle: FontStyle.italic),
        ));
  }

  Widget buttons(String text , IconData icon) {
      return MaterialButton(
          child: icon == null ? Text('$text') : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[Text('$text',), Icon(icon)],),
          color: themeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          height: 40,
          onPressed: (){},
        );
  }
}
