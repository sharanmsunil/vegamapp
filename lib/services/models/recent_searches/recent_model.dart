import 'package:hive_flutter/hive_flutter.dart';
part 'recent_model.g.dart';

@HiveType(typeId: 1)
class RecentSearchModel {

  @HiveField(0)
  int? id;

  @HiveField(1)
  final String search;

  RecentSearchModel({
    required this.search,
    this.id
});
}