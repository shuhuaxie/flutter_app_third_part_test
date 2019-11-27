import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlitTest {
  var dbName = "test2.db";
  var dbPath;
  String sql_createTable =
//      "CREATE TABLE Test1 (id INTEGER PRIMARY KEY)";
      "CREATE TABLE [main] ([id] INTEGER NOT NULL ON CONFLICT REPLACE "
      "PRIMARY KEY AUTOINCREMENT,[name] CHAR);";

  Future<String> _createNewDb(String dbName) async {
    //获取数据库文件路径
    var dbPath = await getDatabasesPath();
    print('dbPath:' + dbPath);

    String path = join(dbPath, dbName);

    if (await new Directory(dirname(path)).exists()) {

      // await deleteDatabase(path);
      // do nothing
    } else {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }
  init(){
    _create();
  }

  _create() async {
    dbPath = await _createNewDb(dbName);
    Database db = await openDatabase(dbPath);

    await db.execute(sql_createTable);
    await db.close();

    print('创建user.db222成功，创建user_table成功');
  }
  _create2() async {
    var path = await _createNewDb(dbName);
    var db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE User (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, address TEXT)');
        });
    print('创建user.db成功，创建user_table成功');
  }

  //打开数据库，获取数据库对象
  _open() async {
    if (null == dbPath) {
      var path = await getDatabasesPath();
      dbPath = join(path, dbName);
      print('dbPath:' + dbPath);
    }
    Database db = await openDatabase(dbPath);
//    db.execute(sql)
  }

  // 增删改查测试

}

// https://github.com/tekartik/sqflite
