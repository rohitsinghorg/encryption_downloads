import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

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
  final imgUrl = "https://ksassets.timeincuk.net/wp/uploads/sites/55/2019/04/GettyImages-1136749971-920x584.jpg";
  bool downloading = false;
  var progressString = "";
  Permission permission = Permission.WriteExternalStorage;
  String permissionStatus = 'None';
  String filePath;

  @override
  void initState() {
    super.initState();

//    downloadFile();
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    var dir = await getExternalStorageDirectory();
    try {
      await dio.download(imgUrl, "${dir.path}/mymp.mp3",
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
    filePath = '${dir.path}/mymp.mp3';

    getFileFromPath(filePath);

/*    String urlStr = imgUrl;
    String fileName = urlStr.substring(urlStr.lastIndexOf('/')+1, urlStr.length);
    String fileNameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
    String fileExtension = urlStr.substring(urlStr.lastIndexOf("."));

    print("File Name: $fileName");
    print("File Name Without Extension: $fileNameWithoutExtension");
    print("File Extension: $fileExtension");*/

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AppBar"),
      ),
      body: Center(
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
                  RaisedButton(
                      onPressed: () {
                        checkPermission();
                      },
                      child: Text('Check Permission')),
                  Text('Permission Status: '+permissionStatus),
                  RaisedButton(onPressed: (){
                      requestPermission();
                  },
                  child: Text('Request Permission')),
                  SizedBox(height: 36),
                  Text('Click on Download Now button', style: TextStyle(fontStyle: FontStyle.italic)),
                  RaisedButton(onPressed: (){
                    downloadFile();
                  }, child: Text('Download Now'),)
                ],
              ),
      ),
    );
  }

  checkPermission() async {
    bool res = await SimplePermissions.checkPermission(permission);
    print('Check permisison is: $res');
    if (res)
      setState(() {
        permissionStatus = 'Permission granted';
      });
    else
      setState(() {
        permissionStatus = 'Permission denied';
      });
  }

  requestPermission() async {
    PermissionStatus _permissionStatus = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    print('Inside request permission: ${_permissionStatus}');
    if(_permissionStatus == 'authorized') {
      setState(() {
        permissionStatus = 'Permission granted';
      });
    } else if(_permissionStatus == 'deniedNeverAsk'){
      setState(() {
        permissionStatus = 'User set permission as never ask';
      });
    }else if(_permissionStatus == 'denied'){
      setState(() {
        permissionStatus = 'User denied Write External Storage permission';
      });
    }else if(_permissionStatus == 'restricted'){
      setState(() {
        permissionStatus = 'Permission is restricted';
      });
    } else {
      setState(() {
        permissionStatus = 'Permission is not determined';
      });
    }
  }

  getFileFromPath(String path) async{
      print('getFileFromPath: $path');
      try {
        final file = await File(path).readAsString().then((result) {
          print('Inside await: $result');
        });
        print('File content is: ${file}');
      } on FileSystemException {
        print('File System Exception occured');
      }
  }
}
