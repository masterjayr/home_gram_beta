import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_gram_beta/screens/login_screen.dart';
import 'package:home_gram_beta/services/auth.dart';
import 'package:home_gram_beta/services/user.dart';
import 'package:home_gram_beta/ui/const.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  LatLng myPosition;
  List<Map<String, dynamic>> houses = List<Map<String, dynamic>>();

  void getInitialDetails() async {
    List<DocumentSnapshot> documents =
        await widget.user.getClosestHomesToLocation(myPosition.latitude, myPosition.longitude);
    for (int i = 0; i < documents.length; i++) {
      initMarker(documents[i].data);
      setState(() {
        houses.add({
          'pictureUrl': documents[i].data['uploadedImages'][i],
          'address': documents[i].data['address'],
          'lat': documents[i].data['position']['geopoint'].latitude,
          'lng': documents[i].data['position']['geopoint'].longitude
        });
      });
    }
    print(houses);
    prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid');
      photoUrl = prefs.getString('photoUrl');
      email = prefs.getString('email');
      displayName = prefs.getString('displayName');
    });
  }

  void initMarker(document) {
    _markers.add(Marker(
        markerId: MarkerId(document['address']),
        position: LatLng(document['position']['geopoint'].latitude,
            document['position']['geopoint'].longitude),
        infoWindow: InfoWindow(title: document['address']),
        icon: BitmapDescriptor.defaultMarker));
  }

  void initState() {
    super.initState();
    getInitialDetails();
    Geolocator().getCurrentPosition().then((currLoc) {
      setState(() {
        currentLocation = currLoc;
        myPosition = LatLng(currLoc.latitude, currLoc.longitude);
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
                    houses[index]['lng'], houses[index]['address']));
          },
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String houseName) {
    return GestureDetector(
      onTap: () {
        _goToLocation(lat, long);
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
