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
            Text(
              'A L L P A T I E N T S',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
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
                            pid: patient.pid,
                            name: patient.name,
                            email: patient.email,
                            problem: patient.problem,
                            treatment: patient.treatment,
                            lastVisitDay: patient.lastVisitDay,
                            days: patient.days,
                            isRecurring: patient.isRecurring,
                            phoneNumber: patient.phoneNumber,
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
