import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:download_encrypt/de_button.dart';
import 'package:download_encrypt/save_locally.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:toast/toast.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
//  final imgUrl = "https://unsplash.com/photos/iEJVyyevw-U/download?force=true";
//  final imgUrl = "https://www.bensound.com/bensound-music/bensound-jazzyfrenchy.mp3";
  final imgUrl =
      "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/GettyImages-1136749971-920x584.jpg";
  bool downloading = false;
  var progressString = "";
  Permission permission = Permission.WriteExternalStorage;
  String permissionStatus = 'None';
  String filePath;
  bool showImage = false;
  Uint8List imageInBytes;
  SaveLocally _saveLocally = SaveLocally();
  bool showDownloadImageButton = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> downloadFile(BuildContext context) async {
    bool isInternetAvailable = await checkInternetAvailability();
    if(isInternetAvailable) {
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      try {
        await dio.download(imgUrl, "${dir.path}/myimg.jpg",
            onReceiveProgress: (rec, total) {
              print("Rec: $rec , Total: $total");

              setState(() {
                downloading = true;
                progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
              });
            });
      } catch (e) {
        print(e);
      }

      setState(() {
        downloading = false;
        progressString = "Completed";
      });
      print("Download completed in path: ${dir.path}");
      filePath = '${dir.path}/myimg.jpg';

      getFileFromPath(filePath);

    } else {
      Toast.show("No Internet Connection.", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Ecrypted Downloads".toUpperCase(),
          style: TextStyle(fontSize: 14, letterSpacing: 2.1, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Color(0xFF420062),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Center(
            child: downloading
                ? Container(
                    height: 120.0,
                    width: 200.0,
                    child: Card(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Downloading File: $progressString",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DEButton(
                          name: 'Check Permission',
                          function: () {
                            checkPermission(context);
                          }),
                      DEButton(
                        name: 'Request Permission',
                        function: (){
                          requestPermission(context);
                        },
                      ),
                      DEButton(
                        name: 'Download File (online)',
                        function: () async {
                          String path = await _saveLocally.getFilePath();
                          if(path == null)
                             downloadFile(context);
                          else
                            Toast.show("File is already downloaded", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Divider(
                          height: 1,
                          color: Color(0xFF420062)
                        ),
                      ),
                      DEButton(
                        name: 'Get Saved File',
                        function: () async {
                          String path = await _saveLocally.getFilePath();
                          print('GetStoreFile: Path is: $path');
                          if (path == null)
                            Toast.show("Application has not any file", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          else
                            getFileFromPath(path);
                        },
                      ),
                      Visibility(visible: showImage, child: getWidget()),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  checkPermission(BuildContext context) async {
    bool res = await SimplePermissions.checkPermission(permission);
    print('Check permisison is: $res');
    if (res)
      Toast.show("Application has Write permission", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    else
      Toast.show("Application has NOT Write permission", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
  }

  requestPermission(BuildContext context) async {
    PermissionStatus _permissionStatus =
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
    print('Inside request permission: ${_permissionStatus}');
    if (_permissionStatus == PermissionStatus.authorized) {
      Toast.show("Application has Write permission", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return true;
    } else {
      Toast.show("Application has NOT Write permission", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  getFileFromPath(String path) async {
    print('getFileFromPath: $path');
    if (path == null) {
      print('Nothing stored in application');
    } else {
      var imgBytes = await File(path).readAsBytes(); //.then((result) => print(result));
      print('getFileFromPath: $imageInBytes');
      setState(() {
        imageInBytes = imgBytes;
        showImage = true;
      });
      _saveLocally.storeFileNamePathType('myimg', path, 'IMAGE');
    }
  }

  Widget getWidget() {
    if (showImage) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(imageInBytes, width: 400, height: 400));
    } else {
      return Container(width: 10, height: 10);
    }
  }

  Future<bool> checkInternetAvailability() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}
