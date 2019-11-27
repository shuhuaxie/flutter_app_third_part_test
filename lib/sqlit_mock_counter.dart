import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteMockCounter {
  var dbName = "test10.db";
  var dbPath;
  Database mdb;

  // 商品分类
  List<String> sqlCreateTables =
//      "CREATE TABLE Test1 (id INTEGER PRIMARY KEY)";

  [
    "CREATE TABLE [goodsType] ([id] INTEGER NOT NULL ON CONFLICT REPLACE  "
        "PRIMARY KEY AUTOINCREMENT, [name] CHAR);",
    "CREATE TABLE [goods] ("
        "[id] INTEGER NOT NULL ON CONFLICT REPLACE PRIMARY KEY AUTOINCREMENT,"
        "[name] CHAR,"
        "[goodsTypeId] INTEGER,"
        "[sellNum] INTEGER,"
        "[picurl] CHAR,"
        "[goodsCode] CHAR,"
        "[price] CHAR); ",
    "CREATE INDEX [goodsTypeId_index] ON [goods] ([goodsTypeId]); ",
    "CREATE INDEX [sellNum_index] ON [goods] ([sellNum]); ",
    "CREATE TABLE [order] ([id] INTEGER NOT NULL ON CONFLICT REPLACE "
        "PRIMARY KEY AUTOINCREMENT, [price] INTEGER, [time] INTEGER, [orderStatus] INTEGER, [payMethod] INTEGER); "
        "CREATE INDEX [time_index] ON [order] ([time]); ",
    "CREATE TABLE [orderItem] ([id] INTEGER NOT NULL ON CONFLICT REPLACE "
        "PRIMARY KEY AUTOINCREMENT, [orderId] INTEGER, [goodsId] INTEGER, [num] INTEGER); ",
    "CREATE INDEX [orderId_index] ON [orderItem] ([orderId]); "
  ]

  //  "insert into [goodsType] values(null, '热销');" not work

  // 初始化表
      ;

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

  init(BuildContext c) {
    _openDb(c);
  }

  _openDb(BuildContext c) async {
    dbPath = await _createNewDb(dbName);
    mdb = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    print('初始化数据库成功');
    // test
    test(c);
  }

  _onCreate(Database db, int version) async {
    for(String s in sqlCreateTables) {
      await db.execute(s);
    }
  }

  // 增删改查测试
  test(BuildContext c) async {
    int recordId =
    await mdb.rawInsert('INSERT INTO goodsType(name) VALUES (?)', ['热销']);
    recordId =
    await mdb.rawInsert('INSERT INTO goodsType(name) VALUES (?)', ['日用品']);
    print("recordId:" + recordId.toString());

//    await mdb.update('goodsType', {'name': '热销'},
//        where: 'id = ?', whereArgs: [1]);
//
//    List<Map> list2 =
//        await mdb.query('goodsType', where: 'id = ?', whereArgs: [1]);
//    print("qu2:" + list2.toString());
//
    List<Map> list2 = await mdb.rawQuery("select * from goodsType;");
    print("qu2:" + list2.toString());
    List<Map> list3 = await mdb.rawQuery("select * from goods;");
    print("qu3:" + list3.toString());
    print("start insert:" + TimeOfDay.now().format(c));

    List<Goods> l = getMockGoods();
    for (int i = 0; i < l.length; i++) {
      Goods g = l[i];
      await mdb.rawInsert(
          'INSERT INTO [goods](name, sellNum, goodsTypeId, price, picUrl, goodsCode) VALUES (?, ?, ?, ?, ?, ?)',
          [g.name, g.sellNum, g.goodsTypeId, g.price, g.picUrl, g.goodsCode]);
    }
    print("end insert: :" + TimeOfDay.now().format(c));
    List<Map> list = await mdb.rawQuery("select * from goods;");
    print("qu1:" + list.toString());
  }
}

List<Goods> getMockGoods() {
  List<Goods> it = [];
  num gi = 0;
  Goods goods = new Goods();
  goods.name = "洗发水";
  goods.sellNum = 0;
  goods.goodsTypeId = 0;
  goods.price = "10";
  goods.picUrl = "http://www.baidu.com";
  goods.goodsCode = "12989123123" + gi.toString();
  it.add(goods);
  for (int i = 0; i < 20; i++) {
    var good = new Goods();
    good.name = "海飞丝洗发水(薄荷 香味)100ml_" + gi.toString();
    good.sellNum = 1;
    good.goodsTypeId = 0;
    good.price = "10";
    good.picUrl = "http://www.baidu.com";
    good.goodsCode = "12989123124" + gi.toString();
    gi++;
    it.add(good);
  }
  goods = new Goods();
  goods.name = "菜刀";
  goods.sellNum = 0;
  goods.goodsTypeId = 1;
  goods.price = "10.3";
  goods.picUrl = "http://www.baidu.com";
  goods.goodsCode = "12989123133" + gi.toString();
  it.add(goods);
  goods = new Goods();
  goods.name = "啤酒";
  goods.sellNum = 0;
  goods.goodsTypeId = 1;
  goods.price = "10.31";
  goods.picUrl = "http://www.baidu.com";
  goods.goodsCode = "12989123143" + gi.toString();
  it.add(goods);
  return it;
}

class Goods {
  String name;
  num sellNum;
  num goodsTypeId;
  String price;
  String picUrl;
  String goodsCode;
}

// https://github.com/tekartik/sqflite
