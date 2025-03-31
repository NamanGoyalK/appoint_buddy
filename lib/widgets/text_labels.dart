import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../backend/calender_cubit.dart';

class DisplayText extends StatelessWidget {
  final String displayText;

  const DisplayText({
    super.key,
    required this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SubDisplayText extends StatelessWidget {
  final String subDisplayText;

  const SubDisplayText({
    super.key,
    required this.subDisplayText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Text(
        subDisplayText,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

String formatTime(DateTime dateTime) {
  int hour = dateTime.hour;
  String period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  String formattedTime =
      '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  return formattedTime;
}

String formatDay(int weekday) {
  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Day';
  }
}

String formatMonth(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return 'Month';
  }
}

Text dateFull(BuildContext context) {
  return Text(
    "${DateTime.now().day == DateTime.now().day ? 'Today' : formatDay(DateTime.now().weekday)}, ${DateTime.now().day} ${formatMonth(DateTime.now().month)}",
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    ),
  );
}

void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.normal,
          fontSize: 14,
          color: color,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    ),
  );
}

class NoPatientsPlaceholder extends StatelessWidget {
  const NoPatientsPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical:
            context.watch<CalendarFormatCubit>().state == CalendarFormat.month
                ? 20
                : 80,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Image.asset(
              "assets/images/doctor_symbol1.png",
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          const Text(
            "Nice! Looks like you are set for the day.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "You can ask the AI for a new patient or take a break?",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "You can swipe down too make sure !",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class NoPatientsPlaceholder2 extends StatelessWidget {
  const NoPatientsPlaceholder2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 160,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Image.asset(
              "assets/images/doctor_symbol1.png",
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          const Text(
            "Looks like you have added no patients yet.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "You can add new patient using the add patient button on the home screen.",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "You can take your time and add them later.",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ShimmerForPatientCards extends StatelessWidget {
  const ShimmerForPatientCards({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1100),
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]!
          : Colors.grey[400]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[300]!,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Container(
                height: 20,
                width: double.infinity,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 15,
                width: double.infinity,
                color: Colors.white,
              ),
              trailing: Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
