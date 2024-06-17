import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState

    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  //text editing controller
  final textController = TextEditingController();
  //create new habit

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Create a new habit'),
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get new habit name
              String newHabitName = textController.text;
              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);
              //pop box
              Navigator.pop(context);
              //clear controller
              textController.clear();
            },
            child: const Text('Save'),
          ),
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);
              //clear controller
              textController.clear();
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  //check habit on or off
  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                //save button
                MaterialButton(
                  onPressed: () {
                    //get new habit name
                    String newHabitName = textController.text;
                    //save to db
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);
                    //pop box
                    Navigator.pop(context);
                    //clear controller
                    textController.clear();
                  },
                  child: const Text('Save'),
                ),
                //cancel button
                MaterialButton(
                  onPressed: () {
                    //pop box
                    Navigator.pop(context);
                    //clear controller
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  //delete habit box
  void deletHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure to want to delete'),
              actions: [
                //save button
                MaterialButton(
                  onPressed: () {
                    //delet from db
                    context.read<HabitDatabase>().deleteHabit(habit.id);
                    //pop box
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                //cancel button
                MaterialButton(
                  onPressed: () {
                    //pop box
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: ListView(
        children: [
          _buildHeatMap(),
          _buildHabitList(),
        ],
      ),
    );
  }

  // heatmap on homepage
  Widget _buildHeatMap() {
    //habit database
    final habitDatabase = context.watch<HabitDatabase>();
    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return heatmap UI
    return FutureBuilder(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          // data available build heat map
          if (snapshot.hasData) {
            return MyHeatMap(
              datasets: prepHeatMapDataset(currentHabits),
              startDate: snapshot.data!,
            );
          } else {
            return Container();
          }

          // handle case when there is no data is returned
        });
  }

  //habit list on hompage
  Widget _buildHabitList() {
    //access habit db
    final habitDatabase = context.watch<HabitDatabase>();
    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;
    //return list of habit UI
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        //get individula habits
        final habit = currentHabits[index];
        //check if the habit is completed or not today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
        // return habit tile uI
        return MyHabitTile(
          isCompleted: isCompletedToday,
          text: habit.name,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) {
            deletHabitBox(habit);
          },
        );
      },
    );
  }
}
