import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:home_gram_beta/enums/connectivity_status.dart';
import 'package:provider/provider.dart';

class NetworkSensitive extends StatelessWidget {
  final Widget child;

  NetworkSensitive({this.child});

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.HasConnection) {
      
      return child;
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned(
          height: 24.0,
          left: 0.0,
          right: 0.0,
          child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color: connectionStatus == ConnectivityStatus.HasConnection
                  ? Color(0xFF00EE44)
                  : Color(0xFFEE4400),
              child: connectionStatus == ConnectivityStatus.HasConnection
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'OFFLINE',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 8.0,
                          width: 6.0,
                        ),
                        SizedBox(
                          height: 12.0,
                          width: 12.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      ],
                    )),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Icon(
              MaterialCommunityIcons.network_off,
              color: Colors.grey,
              size: 100,
            )),
            SizedBox(
              height: 20,
            ),
            FittedBox(
                child: Text(
                    'It seems you\'re offline, Try connecting to a network',
                    style: TextStyle(color: Colors.grey)))
          ],
        )
      ],
    );
  }
}
