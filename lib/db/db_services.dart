import 'package:hive_flutter/hive_flutter.dart';

part 'db_services.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isCompleted;

  Todo(
      {required this.title,
      required this.description,
      required this.date,
      this.isCompleted = false});
}
