import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../backend/auth_cubit.dart';
import '../backend/calender_cubit.dart';
import '../backend/patient_cubit.dart';
import '../core/app_background.dart';
import '../widgets/index.dart';
import '../widgets/patient_card.dart';
import 'add_patient_page.dart';
import 'all_patients_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  DateTime focusedDate = DateTime.now();
  DateTime? selectedDate = DateTime.now(); // Default to today
  final List<Map<String, dynamic>> patients = [];

  // For the expandable FAB
  late AnimationController _animationController;
  final List<String> _fabOptions = ['Settings', 'View Patients', 'Add Patient'];
  final List<IconData> _fabIcons = [
    Icons.settings,
    Icons.people,
    Icons.person_add,
  ];
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    // Ensure patients are fetched when the page is initialized
    context.read<PatientCubit>().fetchPatientsByDate(focusedDate);

    // Initialize animation controller for FAB
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          setState(() {
            if (details.primaryVelocity! < 0) {
              // Swipe left to go to the next day
              focusedDate = focusedDate.add(Duration(days: 1));
              selectedDate = focusedDate;
            } else if (details.primaryVelocity! > 0) {
              // Swipe right to go to the previous day
              focusedDate = focusedDate.subtract(Duration(days: 1));
              selectedDate = focusedDate;
            }
          });

          // Automatically refresh if no data in cache
          context.read<PatientCubit>().fetchPatientsByDate(focusedDate);
        },
        onTap: _isFabOpen
            ? _toggleFab
            : null, // Close FAB menu when tapping anywhere
        child: InternalBackground(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'A P P O I N T  B U D D Y',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocBuilder<CalendarFormatCubit, CalendarFormat>(
                builder: (context, format) {
                  return TableCalendar(
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    focusedDay: focusedDate,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        selectedDate = selectedDay;
                        focusedDate = focusedDay;
                      });

                      // Automatically refresh if no data in cache
                      context
                          .read<PatientCubit>()
                          .fetchPatientsByDate(selectedDay);
                    },
                    calendarFormat: format,
                    onFormatChanged: (newFormat) {
                      context
                          .read<CalendarFormatCubit>()
                          .updateFormat(newFormat);
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.week: 'Week',
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  context.read<CalendarFormatCubit>().toggleFormat();
                },
                icon: BlocBuilder<CalendarFormatCubit, CalendarFormat>(
                  builder: (context, format) {
                    return Icon(
                      format == CalendarFormat.month
                          ? Icons.expand_less
                          : Icons.expand_more,
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: BlocBuilder<PatientCubit, PatientState>(
                    builder: (context, state) {
                      if (state is PatientLoading || state is PatientCreating) {
                        return Center(
                          child: ShimmerForPatientCards(),
                        );
                      } else if (state is PatientLoaded) {
                        final allPatients = state.patients;
                        if (allPatients.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: _refreshPatients,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                NoPatientsPlaceholder(),
                              ],
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: _refreshPatients,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: allPatients.length,
                            itemBuilder: (context, index) {
                              final patient = allPatients[index];
                              return PatientCard(
                                index: index + 1,
                                patient: patient,
                              );
                            },
                          ),
                        );
                      } else if (state is PatientError) {
                        return Center(
                          child: Text(state.message),
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: _refreshPatients,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: const [NoPatientsPlaceholder()],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildExpandableFab(),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Stacked FAB options - these appear when the main FAB is clicked
        ..._buildExpandableFabOptions(),

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleFab,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isFabOpen
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            color: Theme.of(context).colorScheme.inverseSurface,
            progress: _animationController,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandableFabOptions() {
    if (!_isFabOpen) {
      return []; // Return empty list when not expanded
    }

    // Create a list of mini FABs that appear above the main FAB
    List<Widget> options = [];

    for (int i = 0; i < _fabOptions.length; i++) {
      options.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Label for the FAB option
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black87
                      : Colors.grey[300]!,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _fabOptions[i],
                  style: const TextStyle(),
                ),
              ),

              // Mini FAB
              FloatingActionButton.small(
                onPressed: () {
                  // Handle option press
                  _handleFabOptionPressed(i);
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(_fabIcons[i]),
              ),
            ],
          ),
        ),
      );
    }

    return options;
  }

  void _handleFabOptionPressed(int index) {
    _toggleFab(); // Close the menu

    // Handle the option press based on index
    switch (index) {
      case 0: // Settings
        // Logout user
        BlocProvider.of<AuthCubit>(context).logout();
        break;
      case 1: // View Patients
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllPatientsPage(),
          ),
        );
        break;
      case 2: // Add Patient
        showAddBottomSheet(context);
        break;
    }
  }

  Future<void> _refreshPatients() async {
    // Refresh patients for the selected date
    if (selectedDate != null) {
      await context.read<PatientCubit>().refreshPatients();
    }
  }
}
