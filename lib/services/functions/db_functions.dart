import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:m2/services/models/recent_searches/recent_model.dart';

ValueNotifier <List<RecentSearchModel>> searchListNotifier = ValueNotifier([]);

Future <void> addSearch(RecentSearchModel value) async{

  final searchDB = await Hive.openBox<RecentSearchModel>("search_db");
  final id = await searchDB.add(value);
  value.id = id;
  getAllSearches();
}

Future<void> getAllSearches() async{
  var searchDB = await Hive.openBox<RecentSearchModel>("search_db");
  searchListNotifier.value.clear();

  searchListNotifier.value.addAll(searchDB.values);
  searchListNotifier.notifyListeners();
}

Future<void> deleteSearch(int id) async{
  final studentDB = await Hive.openBox<RecentSearchModel>('search_db');
  await studentDB.deleteAt(id);
  getAllSearches();
}