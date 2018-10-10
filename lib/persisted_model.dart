library a2s_widgets;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';


import 'package:scoped_model/scoped_model.dart';

class PersistedModel extends Model {
  final String documentType;
  Function onLoadComplete;

  List<Map<String, dynamic>> data;

  PersistedModel(this.documentType, {this.onLoadComplete}) {
    data = [];
    _loadLocalData();
  }

  void _loadLocalData() async {
    getApplicationDocumentsDirectory().then((Directory appDir){
    appDir.listSync(recursive: false,
     followLinks: false).forEach(( FileSystemEntity f) {
        if(f.path.endsWith('.json')) {
            String j = new File(f.path).readAsStringSync();
            Map newData = json.decode(j);
            data.add(newData);
        }
    });
    if(onLoadComplete != null) onLoadComplete(data);
  });}

  void add(Map<String,dynamic> map) {
      map["docType"] = documentType;
      map["_id"] = _randomString(16);
      map["_time_stamp"] = new DateTime.now().millisecondsSinceEpoch.toInt();
      data.add(map);
      writeMap(map);
  }

String _randomString(int length) {
   var rand = new Random();
   var codeUnits = new List.generate(
      length, 
      (index){
         return rand.nextInt(33)+89;
      }
   );
   
   return new String.fromCharCodes(codeUnits);
}

Future<File> writeMap(Map<String,dynamic> map) async {
  final file = await _localFile(map["_id"]);
  // Write the file
  String mapString = json.encode(map);
  return file.writeAsString('$mapString');
}

Future<File> _localFile(String id) async {
  final path = await _localPath;
  return File('$path/$id.json');
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}


}