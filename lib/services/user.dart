import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class User {
  Future<String> uploadPicture(String filePath, File fileName);
  Future<List<StorageTaskSnapshot>> postHouseDetail(String address,
      int noOfRooms, int price, List<Asset> imageAssets, LatLng coords);
  Future<List<DocumentSnapshot>> getClosestHomesToLocation();
}

class UserActivity implements User {
  final fbInstance = FirebaseAuth.instance;
  final firebaseStorageRef = FirebaseStorage.instance;
  final firestoreRef = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  SharedPreferences prefs;
  @override
  Future<String> uploadPicture(String filePath, File fileName) async {
    FirebaseUser user = await fbInstance.currentUser();
    print('current userId,');
    print(user.uid);
    StorageReference storageRef = firebaseStorageRef
        .ref()
        .child('Profile Images')
        .child(user.uid)
        .child(filePath);
    StorageUploadTask uploadTask = storageRef.putFile(fileName);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print('task Snapshot, $taskSnapshot');
    String downloadUrl = await storageRef.getDownloadURL();
    await firestoreRef.collection('users').document(user.uid).updateData({
      'photoUrl': downloadUrl,
    });
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoUrl', downloadUrl);
    return downloadUrl;
  }

  Future<List<StorageTaskSnapshot>> postHouseDetail(String address,
      int noOfRooms, int price, List<Asset> imageAssets, LatLng coords) async {
    FirebaseUser user = await fbInstance.currentUser();
    List<StorageTaskSnapshot> taskSnapshots = List<StorageTaskSnapshot>();
    List<String> pictureUrls = List<String>();
    for (int i = 0; i < imageAssets.length; i++) {
      StorageReference storageRef = firebaseStorageRef
          .ref()
          .child('uploadedImages')
          .child(user.uid)
          .child(imageAssets[i].name);
      ByteData byteData = await imageAssets[i].getByteData();
      List<int> image = byteData.buffer.asUint8List();
      StorageUploadTask uploadTask = storageRef.putData(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshots.add(taskSnapshot);
      String downloadUrl = await storageRef.getDownloadURL();
      pictureUrls.add(downloadUrl);
    }
    GeoFirePoint point =
        geo.point(latitude: coords.latitude, longitude: coords.longitude);
    await firestoreRef.collection('homeRentals').document(user.uid).setData({
      'uid': user.uid,
      'address': address,
      'price': price,
      'noOfRooms': noOfRooms,
      'uploadedImages': pictureUrls,
      'position': point.data,
    });
    return taskSnapshots;
  }

  upload(fileName, filePath) async {
    FirebaseUser user = await fbInstance.currentUser();
    StorageReference storageRef = firebaseStorageRef
        .ref()
        .child('House Images')
        .child(user.uid)
        .child(filePath);
    final StorageUploadTask uploadTask = storageRef.putFile(filePath);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  }

  Future<String> getAllHomes() async {}

  Future<String> getSingleHome(String userId) async {}

  int getDistanceInKms(double distance) {
    double value =  distance.round()/1000;
    return value.round();
  }

  Future<List<DocumentSnapshot>> getClosestHomesToLocation() async {
    var currLoc = await Geolocator().getCurrentPosition();
    List<DocumentSnapshot> documentToBeReturned = List<DocumentSnapshot>();
    final QuerySnapshot snap =
        await firestoreRef.collection('homeRentals').getDocuments();
    final List<DocumentSnapshot> documents = snap.documents;
    final lat1 = currLoc.latitude;
    final lng1 = currLoc.longitude; 
    if (documents.length != 0) {
      for (int i = 0; i < documents.length; i++) {
        final lat2 = documents[i].data['position']['geopoint'].latitude;
        final lng2 = documents[i].data['position']['geopoint'].longitude;
        await Geolocator()
            .distanceBetween(lat1, lng1, lat2, lng2)
            .then((double distanceInMeters) {
          print('Distance: $distanceInMeters');
          print('Distance from method ${getDistanceInKms(distanceInMeters)}');
          if(getDistanceInKms(distanceInMeters) < 100){
          documentToBeReturned.add(documents[i]);
        }
        });
        
      }
        
    }
    return documentToBeReturned;
  }
}
