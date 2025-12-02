import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast_web/sembast_web.dart';
import 'package:sembast/sembast_io.dart' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AppDb {
  static Database? _db;
  static Future<Database> instance() async {
    if (_db != null) return _db!;
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('app.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _db = await io.databaseFactoryIo.openDatabase(p.join(dir.path, 'app.db'));
    }
    return _db!;
  }
}
