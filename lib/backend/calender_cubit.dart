import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarFormatCubit extends Cubit<CalendarFormat> {
  CalendarFormatCubit() : super(CalendarFormat.week);

  void toggleFormat() {
    emit(state == CalendarFormat.month
        ? CalendarFormat.week
        : CalendarFormat.month);
  }

  void updateFormat(CalendarFormat newFormat) {
    emit(newFormat);
  }
}
