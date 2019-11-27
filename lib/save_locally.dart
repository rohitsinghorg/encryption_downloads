import 'package:shared_preferences/shared_preferences.dart';

class SaveLocally {
  String fileNameKey = 'name';
  String filePathKey = 'path';
  String fileTypeKey = 'type';


  storeFileNamePathType(String fileName, String path, String fileTtype) async {
     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(fileNameKey, fileName);
      sharedPreferences.setString(filePathKey, path);
      sharedPreferences.setString(fileTypeKey, fileTtype);
  }

  getFilePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // return string
    String path = prefs.getString(filePathKey) ?? null;
    return path;
  }

}