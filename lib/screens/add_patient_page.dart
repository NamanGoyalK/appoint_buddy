import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../backend/patient_cubit.dart';
import '../models/app_user.dart';
import '../models/patient_model.dart';
import '../widgets/index.dart';

void showAddBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddPatientBlock();
    },
  );
}

class AddPatientBlock extends StatefulWidget {
  const AddPatientBlock({super.key});

  @override
  State<AddPatientBlock> createState() => _AddPatientBlockState();
}

class _AddPatientBlockState extends State<AddPatientBlock> {
  late TextEditingController patientNameController;
  late TextEditingController patientEmailController;
  late TextEditingController problemController;
  late TextEditingController treatmentController;
  late TextEditingController daysController;
  late TextEditingController phoneNumberController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  bool isRecurring = false;

  AppUser? currentUser;
  String? errorMessage;
  DateTime selectedTime = DateTime.now();
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();

    patientNameController = TextEditingController();
    patientEmailController = TextEditingController();
    problemController = TextEditingController();
    treatmentController = TextEditingController();
    daysController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // Dispose timer
    super.dispose();
  }

  void _uploadPatient() {
    setState(() {
      errorMessage = null;
    });

    final newPatient = Patient(
      pid: DateTime.now().millisecondsSinceEpoch.toString(),
      name: patientNameController.text,
      email: patientEmailController.text,
      problem: problemController.text,
      treatment: treatmentController.text,
      lastVisitDay: selectedTime,
      days: int.tryParse(daysController.text) ?? 0,
      isRecurring: isRecurring,
      phoneNumber: int.tryParse(phoneNumberController.text) ?? 0,
    );

    context.read<PatientCubit>().createPatient(newPatient);
    context.read<PatientCubit>().fetchAllPatients();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Patient created successfully!',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<PatientCubit, PatientState>(
          listener: (context, state) {
            // Handle state changes if needed
          },
          builder: (context, state) {
            if (state is PatientLoading || state is PatientCreating) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHandleIndicator(),
                  const SizedBox(height: 16),
                  _buildHeader('A D D  P A T I E N T'),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                ],
              );
            } else {
              return createPatientColumn(context);
            }
          },
        ),
      ),
    );
  }

  Column createPatientColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHandleIndicator(),
        const SizedBox(height: 16),
        _buildHeader('A D D  P A T I E N T'),
        const SizedBox(height: 20),
        _buildTextField(
          context,
          patientNameController,
          'P A T I E N T  N A M E',
          'Patient Name',
          Icons.person,
          TextInputType.name,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context,
          patientEmailController,
          'P A T I E N T  E M A I L',
          'Patient Email',
          Icons.email,
          TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context,
          problemController,
          'P R O B L E M',
          'Problem',
          Icons.question_answer,
          TextInputType.text,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context,
          treatmentController,
          'T R E A T M E N T',
          'Treatment',
          Icons.medical_services,
          TextInputType.text,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context,
          daysController,
          'D A Y S',
          'Days',
          Icons.calendar_today,
          TextInputType.number,
          suffix: ButtonInsideTF(
            onPressed: () {
              setState(() {
                isRecurring = !isRecurring;
              });
            },
            text: isRecurring ? 'Recurring' : 'One Time',
          ),
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context,
          phoneNumberController,
          'P H O N E  N U M B E R',
          'Phone Number',
          Icons.phone,
          TextInputType.phone,
        ),
        const SizedBox(height: 15),
        if (errorMessage != null) ...[
          Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
        ],
        ColoredButton(
          labelText: 'A D D  P A T I E N T',
          onPressed: _uploadPatient,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHandleIndicator() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    TextInputType keyboardType, {
    Widget? suffix,
  } // Optional suffix widget
      ) {
    return TextFromUser(
      controller: controller,
      labelText: label,
      hintText: hint,
      icon: icon,
      keyboardType: keyboardType,
      obscureText: false,
      suffix: suffix,
    );
  }
}
