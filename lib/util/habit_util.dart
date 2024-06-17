// give a habit list of completed days
// is the habit completed today

import 'package:habit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (element) =>
        element.year == today.year &&
        element.month == today.month &&
        element.day == today.day,
  );
}

//prepare heatmap dataset
Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      //normalize the date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);
      // if date already exists in the dataset,increment its count
      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        //else initialize it with count of 1
        dataset[normalizedDate] = 1;
      }
    }
  }
  return dataset;
}
