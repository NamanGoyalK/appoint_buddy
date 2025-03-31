import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../backend/patient_cubit.dart';
import '../models/patient_model.dart';
import '../widgets/index.dart';

void showEditBottomSheet(BuildContext context, Patient patient) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return EditPatientBlock(patient: patient);
    },
  );
}

class EditPatientBlock extends StatefulWidget {
  final Patient patient;

  const EditPatientBlock({super.key, required this.patient});

  @override
  State<EditPatientBlock> createState() => _EditPatientBlockState();
}

class _EditPatientBlockState extends State<EditPatientBlock> {
  late TextEditingController patientNameController;
  late TextEditingController patientEmailController;
  late TextEditingController problemController;
  late TextEditingController treatmentController;
  late TextEditingController daysController;
  late TextEditingController phoneNumberController;
  late bool isRecurring;
  late DateTime selectedTime;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing patient data
    patientNameController = TextEditingController(text: widget.patient.name);
    patientEmailController = TextEditingController(text: widget.patient.email);
    problemController = TextEditingController(text: widget.patient.problem);
    treatmentController = TextEditingController(text: widget.patient.treatment);
    daysController =
        TextEditingController(text: widget.patient.days.toString());
    phoneNumberController =
        TextEditingController(text: widget.patient.phoneNumber.toString());

    // Initialize other fields
    isRecurring = widget.patient.isRecurring;
    selectedTime = widget.patient.lastVisitDay;
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    patientNameController.dispose();
    patientEmailController.dispose();
    problemController.dispose();
    treatmentController.dispose();
    daysController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updatePatient() async {
    // Reset error message
    setState(() => errorMessage = null);

    // Basic validation
    if (patientNameController.text.isEmpty) {
      setState(() => errorMessage = 'Patient name is required');
      return;
    }

    // Get patient cubit
    final patientCubit = context.read<PatientCubit>();

    try {
      await patientCubit.updatePatient(
        pid: widget.patient.pid,
        newName: patientNameController.text,
        newEmail: patientEmailController.text,
        newProblem: problemController.text,
        newTreatment: treatmentController.text,
        newLastVisitDay: selectedTime,
        newDays: int.tryParse(daysController.text) ?? 0,
        newIsRecurring: isRecurring,
        newPhoneNumber: int.tryParse(phoneNumberController.text) ?? 0,
      );

      if (mounted) {
        // Close the bottom sheet
        Navigator.of(context).pop();
        // Show success message
        _showSuccessSnackbar();
      }
    } catch (e) {
      setState(() => errorMessage = 'Error updating patient: $e');
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Patient updated successfully!',
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
            if (state is PatientError) {
              setState(() => errorMessage = state.message);
            }
          },
          builder: (context, state) {
            final isLoading =
                state is PatientLoading || state is PatientUpdating;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHandleIndicator(),
                const SizedBox(height: 16),
                _buildHeader('E D I T  P A T I E N T'),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  _buildForm(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            onPressed: () => setState(() => isRecurring = !isRecurring),
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
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
        ],
        ColoredButton(
          labelText: 'U P D A T E  P A T I E N T',
          onPressed: _updatePatient,
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
  }) {
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
