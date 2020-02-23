import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:home_gram_beta/widgets/drawer_tile_widget.dart';
import 'dart:ui' as ui;
import 'package:home_gram_beta/widgets/network_sensitivity.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_gram_beta/widgets/app_bar_widget.dart';

class HomeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> house;
  final BaseAuth auth = Auth();

  HomeDetailScreen({this.house});

  @override
  _HomeDetailScreenState createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  bool mapToggle = false;
  var currentLocation;
  GoogleMapController mapController;
  List<Marker> _markers = [];
  List<NetworkImage> carouselImages = List<NetworkImage>();
  Uint8List houseMarker;
  String firstImageUrl;
  SharedPreferences prefs;
  String name;
  String email;
  int phoneNo;
  GlobalKey<ScaffoldState> _scaffoldKey;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void getInitialDetails() async {
    for (int i = 0; i < widget.house['uploadedImages'].length; i++) {
      setState(() {
        carouselImages.add(NetworkImage(widget.house['uploadedImages'][i]));
      });
    }
    prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('displayName');
      email = prefs.getString('email');
      phoneNo = prefs.getInt('phoneNo');
    });
    setState(() {
      firstImageUrl = widget.house['uploadedImages'][0];
      _markers.add(Marker(
          markerId: MarkerId(widget.house['address']),
          position: LatLng(widget.house['position']['geopoint'].latitude,
              widget.house['position']['geopoint'].longitude),
          infoWindow: InfoWindow(title: widget.house['address']),
          icon: BitmapDescriptor.fromBytes(houseMarker)));
    });
  }

  Future<Uint8List> getBytesFromAsset(
      String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    getBytesFromAsset('assets/home_map_marker2.png', 80, 80)
        .then((Uint8List marker) {
      houseMarker = marker;
      getInitialDetails();
    });
    print('House detail: ${widget.house}');
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

  void handleSignOut(BuildContext context) async {
    prefs.remove('email');
    prefs.remove('photoUrl');
    prefs.remove('displayName');
    Fluttertoast.showToast(
        msg: 'Logging Out',
        gravity: ToastGravity.TOP,
        toastLength: Toast.LENGTH_SHORT);
    await widget.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen(auth: widget.auth)),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.yellow.shade50,
        appBar: MyAppBar.customAppBar(_scaffoldKey, 'Home Detail', context),
        drawer: customizedDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: NetworkSensitive(
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
                                  zoom: 6,
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
                    child: Image.network(
                      firstImageUrl,
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
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              customTextAreas('Name', Fontisto.person,
                                  prefs.getString('displayName')),
                              SizedBox(
                                height: 10,
                              ),
                              customTextAreas('Email', Fontisto.email,
                                  prefs.getString('email')),
                              SizedBox(
                                height: 10,
                              ),
                              customTextAreas('Phone No', Fontisto.phone,
                                  prefs.getInt('phoneNo')),
                              SizedBox(
                                height: 10,
                              ),
                              customTextAreas(
                                  'Message', Fontisto.text_height, null),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  buttons('Send', null),
                                  Text(
                                    'OR',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
          ),
        ));
  }

    Drawer customizedDrawer() {
    return Drawer(
        child: ListView(children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text('${prefs.getString('displayName')}'),
        accountEmail: Text('${prefs.getString('email')}'),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.brown,
          child: Text('E'),
        ),
        decoration: BoxDecoration(color: themeColor),
      ),
      DrawerTiles('Home', MdiIcons.home, false, () {
        Navigator.of(context).pushReplacementNamed('/home');
      }),
      DrawerTiles('Profile', MdiIcons.faceProfile, false, () {
        Navigator.of(context).pushReplacementNamed('/profile');
      }),
      DrawerTiles('Add Home', Fontisto.plus_a, false, () {
        Navigator.of(context).pushReplacementNamed('/addHome');
      }),
      DrawerTiles('Manage Homes', Fontisto.nursing_home, false, () {
        Navigator.of(context).pushReplacementNamed('/myHomes');
      }),
      DrawerTiles('About', MdiIcons.details, false, () {
        Navigator.of(context).pushReplacementNamed('/about');
      }),
      DrawerTiles('Settings', MdiIcons.settings, false, () {
        Navigator.of(context).pushReplacementNamed('/settings');
      }),
      DrawerTiles('Logout', MdiIcons.exitToApp, false, () {
        handleSignOut(context);
      }),
    ]));
  }

  Widget _imageCarousel(context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Carousel(
        boxFit: BoxFit.cover,
        images: carouselImages,
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
                'N${widget.house['price'].toString()}',
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
                  '${widget.house['address']}',
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

  Widget customTextAreas(String labelText, IconData icon, var item) {
    return TextFormField(
        initialValue: item.toString(),
        keyboardType:
            labelText == 'Phone No' ? TextInputType.phone : TextInputType.text,
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
              borderSide: BorderSide(width: 1.0)),
          suffixIcon: Icon(icon),
          labelText: '$labelText',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          hintStyle: TextStyle(fontStyle: FontStyle.italic),
        ));
  }

  Widget buttons(String text, IconData icon) {
    return MaterialButton(
      child: icon == null
          ? Text('$text')
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  '$text',
                ),
                Icon(icon)
              ],
            ),
      color: themeColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      height: 40,
      onPressed: () {},
    );
  }
}
