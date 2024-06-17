import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSetting{
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}