
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:latlong/latlong.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

abstract class User {
  Future<String> uploadPicture(String filePath, File fileName);
  Future<List<StorageTaskSnapshot>> postHouseDetail(String address, int noOfRooms, int price, List<Asset> imageAssets, map.LatLng coords);
  Future<List<DocumentSnapshot>> getClosestHomesToLocation(double lat, double lng);
}

class UserActivity implements User {
  final fbInstance = FirebaseAuth.instance;
  final firebaseStorageRef =  FirebaseStorage.instance;
  final firestoreRef = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  @override
  Future<String> uploadPicture(String filePath, File fileName) async{
    FirebaseUser user = await fbInstance.currentUser();
    print('current userId,');
    print(user.uid);
    StorageReference storageRef =  firebaseStorageRef.ref().child('Profile Images').child(user.uid).child(filePath);
    StorageUploadTask uploadTask = storageRef.putFile(fileName);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print('task Snapshot, $taskSnapshot');
    String downloadUrl = await storageRef.getDownloadURL();
    await firestoreRef.collection('users').document(user.uid).updateData({
      'photoUrl' : downloadUrl,
    });
    return downloadUrl;
  }

  Future<List<StorageTaskSnapshot>> postHouseDetail(String address, int noOfRooms, int price, List<Asset> imageAssets, map.LatLng coords) async {
    FirebaseUser user = await fbInstance.currentUser();
    List<StorageTaskSnapshot> taskSnapshots = List<StorageTaskSnapshot>();
    List<String> pictureUrls = List<String>();
    for(int i =0; i<imageAssets.length; i++){
      StorageReference storageRef = firebaseStorageRef.ref().child('uploadedImages').child(user.uid).child(imageAssets[i].name);
      ByteData byteData = await imageAssets[i].getByteData();
      List<int> image = byteData.buffer.asUint8List();
      StorageUploadTask uploadTask = storageRef.putData(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshots.add(taskSnapshot);
      String downloadUrl = await storageRef.getDownloadURL();
      pictureUrls.add(downloadUrl);
    } 
    GeoFirePoint point = geo.point(latitude: coords.latitude, longitude: coords.longitude);
    await firestoreRef.collection('homeRentals').document(user.uid).setData({
      'uid': user.uid,
      'address' : address,
      'price' : price,
      'noOfRooms' : noOfRooms,
      'uploadedImages' : pictureUrls,
      'position' : point.data,
    });
    return taskSnapshots;
  }

  upload(fileName, filePath) async{
    FirebaseUser user = await fbInstance.currentUser();
    StorageReference storageRef =  firebaseStorageRef.ref().child('House Images').child(user.uid).child(filePath);
    final StorageUploadTask uploadTask = storageRef.putFile(filePath);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  }

  Future<String> getAllHomes() async {
    
  }

  Future<String> getSingleHome(String userId) async {

  }
  
  Future<List<DocumentSnapshot>> getClosestHomesToLocation(double lat, double lng) async {
    Distance distance = Distance();
    List<DocumentSnapshot> documentToBeReturned = List<DocumentSnapshot>();
    final QuerySnapshot snap = await firestoreRef.collection('homeRentals').getDocuments();
    final List<DocumentSnapshot> documents = snap.documents;
      for(int i =0; i<documents.length; i++) {
        num distanceObtained = distance.as(LengthUnit.Kilometer, LatLng(lat, lng), LatLng(documents[i].data['position']['geopoints'].latitude, documents[i].data['position']['geopoints'].longitude)); 
        print('distanceObtained: $distanceObtained');
        documentToBeReturned.add(documents[i]);
        if(distanceObtained <= 100){
          documentToBeReturned.add(documents[i]);
        }
      }
    return documentToBeReturned;
  }

}