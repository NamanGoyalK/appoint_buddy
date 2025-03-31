part of 'patient_cubit.dart';

@immutable
abstract class PatientState {}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientCreating extends PatientState {}

class PatientUpdating extends PatientState {}

class PatientDeleting extends PatientState {}

class PatientLoaded extends PatientState {
  final List<Patient> patients;

  PatientLoaded(this.patients);
}

class PatientError extends PatientState {
  final String message;

  PatientError(this.message);
}
