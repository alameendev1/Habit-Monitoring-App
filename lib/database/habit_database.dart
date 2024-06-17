import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  //initialize
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingSchema],
      directory: dir.path,
    );
  }
  // save first date of app startup(heatmap)

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settting = AppSetting()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settting));
    }
  }
  //get first date of app startup(heatmap)

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  //CRUD operations

  final List<Habit> currentHabits = [];

  //create add new habit

  Future<void> addHabit(String HabitName) async {
    // create a new Habit
    final newHabit = Habit()..name = HabitName;
    // save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));
    //re read from db
    readHabits();
  }

  // READ
  Future<void> readHabits() async {
    //fetch
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    //update ui
    notifyListeners();
  }

  //UPDATE - check habit on or off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find specific habit
    final habit = await isar.habits.get(id);
    //update the completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if habit completed = add the current date to the completedDays list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          //today
          final today = DateTime.now();
          //add current date if it's not already on the list
          habit.completedDays.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));
        }
        // if not completed remove the current date from the list
        else {
          //remove the current date if the habit is marked as not completed
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.year == DateTime.now().month &&
              date.year == DateTime.now().day);
        }
        // save the update habit back to db
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  //UPDATE - edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    //find the specific habit
    final habit = await isar.habits.get(id);
    //update name
    if (habit != null) {
      //update name
      await isar.writeTxn(() async {
        habit.name = newName;
        //save updated habit to db
        await isar.habits.put(habit);
      });
    }
    //reread from db
    readHabits();
  }

  //DELETE - delete habit

  Future<void> deleteHabit(int id) async {
    //perform the delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    //re read the db
    readHabits();
  }
}
