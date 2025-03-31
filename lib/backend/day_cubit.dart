import 'package:flutter_bloc/flutter_bloc.dart';

class DayCubit extends Cubit<DateTime> {
  DayCubit() : super(DateTime.now()); // Initialize with the current date

  void updateSelectedDate(DateTime date) {
    emit(date); // Update the selected date
  }
}
