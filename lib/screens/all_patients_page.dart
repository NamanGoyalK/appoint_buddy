import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../backend/patient_cubit.dart';
import '../core/app_background.dart';
import '../widgets/index.dart';
import '../widgets/patient_card.dart';

class AllPatientsPage extends StatelessWidget {
  const AllPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InternalBackground(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new)),
                  const SizedBox(width: 10),
                  Text(
                    'A L L  P A T I E N T S',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // Refresh the patients list
                      BlocProvider.of<PatientCubit>(context)
                          .fetchPatientsByDate(DateTime.now());
                      // show a snackbar or toast to indicate refresh
                      showSnackBar(context, 'Patients refreshed', Colors.green);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    iconSize: 30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            NoPatientsPlaceholder2(),
                          ],
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: allPatients.length,
                        itemBuilder: (context, index) {
                          final patient = allPatients[index];
                          return PatientCard(
                            index: index + 1,
                            patient: patient,
                            showActions: true, // Pass a flag to show buttons
                          );
                        },
                      );
                    } else if (state is PatientError) {
                      return Center(
                        child: Text(state.message),
                      );
                    } else {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: const [NoPatientsPlaceholder2()],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
