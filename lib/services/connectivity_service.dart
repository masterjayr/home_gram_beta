import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';

class ConnectivityService {
  var isDeviceConnected = false;
  StreamController<ConnectivityStatus> connectionController =  StreamController<ConnectivityStatus>();

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async{
      connectionController.add(await _getStatusFromResult(result));
    });
  }

  Future<ConnectivityStatus> _getStatusFromResult(ConnectivityResult result) async{
    if(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi ){
      isDeviceConnected = await DataConnectionChecker().hasConnection;
      if(isDeviceConnected) {
        return ConnectivityStatus.HasConnection;
      }
    }else{
      return ConnectivityStatus.Offline;
    }
  } 

}