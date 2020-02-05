import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_gram_beta/screens/add_home_screen.dart';
import 'package:home_gram_beta/screens/home_detail_screen.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/screens/my_homes_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  HomeScreen({this.auth});
  final BaseAuth auth;
  final User user = UserActivity();
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool mapToggle = false;
  var currentLocation;
  GoogleMapController mapController;
  List<Marker> _markers = [];
  SharedPreferences prefs;
  String email;
  String photoUrl;
  String uid;
  String displayName;
  String phoneNo;
  String role;
  double zoomVal = 5.0;
  List<Map<String, dynamic>> houses = List<Map<String, dynamic>>();
  Uint8List houseMarker;
  List<DocumentSnapshot> allHouses;
  
  Future<List<DocumentSnapshot>> getInitialDetails() async {
    prefs = await SharedPreferences.getInstance();
    String localRole = prefs.getString('role');
    List<DocumentSnapshot> documents =
        await widget.user.getClosestHomesToLocation();
    for (int i = 0; i < documents.length; i++) {
      print('home screen documents: ${documents[i].data}');
      initMarker(documents[i].data);
        setState(() {
          role = localRole;
          allHouses = documents;
          houses.add({
          'pictureUrl': documents[i].data['uploadedImages'][i],
          'address': documents[i].data['address'],
          'lat': documents[i].data['position']['geopoint'].latitude,
          'lng': documents[i].data['position']['geopoint'].longitude
        });  
        });    
    }
    print('houses: $houses');
    prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid');
      photoUrl = prefs.getString('photoUrl');
      email = prefs.getString('email');
      displayName = prefs.getString('displayName');
      role = prefs.getString('role');
    });
    return documents;
  }

  void initMarker(document) async  {
    _markers.add(Marker(
        markerId: MarkerId(document['address']),
        position: LatLng(document['position']['geopoint'].latitude,
            document['position']['geopoint'].longitude),
        infoWindow: InfoWindow(title: document['address']),
        icon: BitmapDescriptor.fromBytes(houseMarker)));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void initState() {
    super.initState();
    getBytesFromAsset('assets/home_map_marker2.png', 80, 80).then((Uint8List marker){
      houseMarker = marker;
    });
    Geolocator().getCurrentPosition().then((currLoc) {
      setState(() {
        currentLocation = currLoc;
        print(currLoc.latitude);
        print(currLoc.longitude);
        _markers.add(Marker(
          markerId: MarkerId('myMarker'),
          position: LatLng(currLoc.longitude, currLoc.latitude),
          infoWindow: InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarker
        ));
        mapToggle = true;
      });
    });
      getInitialDetails().then((onValue){
        print(onValue);
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

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: customizedDrawer(),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: mapToggle
                ? GoogleMap(
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          currentLocation.longitude, currentLocation.latitude),
                      zoom: 8,
                    ),
                    markers: Set.from(_markers),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          _buildContainer(),
          zoomMinusFunction(),
          zoomPlusFunction(),
        ],
      ),
    );
  }

  _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: houses.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: EdgeInsets.all(8.0),
                child: _boxes(houses[index]['pictureUrl'], houses[index]['lat'],
                    houses[index]['lng'], houses[index]['address'],  allHouses[index].data), );
          },
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String houseName, Map<String, dynamic> house) {
    return GestureDetector(
      onTap: () {
        _goToLocation(lat, long);
      },
      onDoubleTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> HomeDetailScreen(house: house)));
      },
      child: Container(
        child: FittedBox(
          child: Material(
            color: Colors.white,
            elevation: 14,
            borderRadius: BorderRadius.circular(24.0),
            shadowColor: Color(0x802196F3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image.network(
                      '$_image',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: myDetailsContainer(houseName),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Drawer customizedDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('$displayName'),
            accountEmail: Text('$email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.brown,
              child: Text('E'),
            ),
            decoration: BoxDecoration(color: themeColor),
          ),
          ListTile(
              title: Text('Home'),
              trailing: Icon(MdiIcons.home, color: themeColor),
              onTap: () {
                // Navigator.of(context).pop();
                // Navigator.of(context).pushNamed('/profile');
              }),
          ListTile(
              title: Text('Profile'),
              trailing: Icon(MdiIcons.faceProfile, color: themeColor),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/profile');
              }),
              role == 'landlord' ? ListTile(
              title: Text('Add Home'),
              trailing: Icon(Fontisto.plus_a, color: themeColor),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddHomeScreen(user: UserActivity())));
              }) : null,
            role == 'landlord' ? ListTile(
              title: Text('My Homes'),
              trailing: Icon(Fontisto.nursing_home, color: themeColor),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyHomeScreen()));
              }) : null,
          ListTile(
            title: Text('About'),
            trailing: Icon(
              Icons.details,
              color: themeColor,
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Settings'),
            trailing: Icon(MdiIcons.settings, color: themeColor),
            onTap: null,
          ),
          ListTile(
              title: Text('Logout'),
              trailing: Icon(MdiIcons.exitToApp, color: themeColor),
              onTap: () => handleSignOut(context)),
        ],
      ),
    );
  }

  Widget myDetailsContainer(String houseName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            houseName,
            style: TextStyle(
              color: Color(0xff6200ee),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )),
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: Text(
                  'Along $houseName road Jos',
                  style: TextStyle(color: Colors.black54, fontSize: 18),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> _goToLocation(double lat, double long) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, long), zoom: 15, tilt: 50.0, bearing: 45.0)));
  }

  Widget zoomMinusFunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(
          Fontisto.zoom_minus,
          color: primaryColor,
        ),
        onPressed: () {
          zoomVal--;
          _minus(zoomVal);
        },
      ),
    );
  }

  Future<void> _minus(double zoomVal) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentLocation,
      zoom: zoomVal,
    )));
  }

  Widget zoomPlusFunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        iconSize: 40,
        icon: Icon(
          Fontisto.zoom_plus,
          color: primaryColor,
        ),
        onPressed: () {
          zoomVal++;
          _plus(zoomVal);
        },
      ),
    );
  }

  Future<void> _plus(double zoomVal) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentLocation,
      zoom: zoomVal,
    )));
  }
}
