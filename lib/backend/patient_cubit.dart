import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../models/patient_model.dart';
import '../repos/patient_repo.dart';

part 'patient_states.dart';

class PatientCubit extends Cubit<PatientState> {
  final PatientRepo patientRepo;
  List<Patient> allPatients = [];
  DateTime? currentDate;

  // Cache to store schedules for each date
  final Map<DateTime, List<Patient>> _scheduleCache = {};

  PatientCubit({required this.patientRepo}) : super(PatientInitial());

  Future<void> fetchPatient(String pid) async {
    emit(PatientLoading());
    try {
      final patient = await patientRepo.fetchPatient(pid);
      if (patient != null) {
        emit(PatientLoaded([patient]));
      } else {
        emit(PatientError('Patient not found'));
      }
    } catch (e) {
      emit(PatientError('Failed to fetch patient: $e'));
    }
  }

  Future<void> fetchPatientsByDate(DateTime date) async {
    emit(PatientLoading());
    try {
      currentDate = date; // Store the current date

      // Check if the schedule is already cached
      if (_scheduleCache.containsKey(date)) {
        emit(PatientLoaded(_scheduleCache[date]!));
        return;
      }

      // Fetch from repository if not in cache
      final patients = await patientRepo.fetchPatientsByDate(date);

      // Cache the fetched schedule
      _scheduleCache[date] = patients;

      emit(PatientLoaded(patients));
    } catch (e) {
      emit(PatientError('Failed to fetch patients by date: $e'));
    }
  }

  // Create a new patient
  Future<void> createPatient(Patient patient) async {
    emit(PatientCreating());
    try {
      await patientRepo.addPatient(patient);

      // Refresh patient list after creating
      if (currentDate != null) {
        await refreshPatients();
      } else {
        await fetchAllPatients();
      }
    } catch (e) {
      emit(PatientError('Failed to create patient: $e'));
    }
  }

  // Fetch all patients
  Future<void> fetchAllPatients() async {
    emit(PatientLoading());
    try {
      final patients = await patientRepo.fetchAllPatients();
      allPatients = patients; // Store the full patient list
      emit(PatientLoaded(patients));
    } catch (e) {
      emit(PatientError('Failed to fetch patients: $e'));
    }
  }

  // Update a patient
  Future<void> updatePatient(Patient patient) async {
    emit(PatientUpdating());
    try {
      await patientRepo.updatePatient(patient);

      // Refresh patient list after updating
      if (currentDate != null) {
        await refreshPatients();
      } else {
        await fetchAllPatients();
      }
    } catch (e) {
      emit(PatientError('Failed to update patient: $e'));
    }
  }

  // Delete a patient
  Future<void> deletePatient(String pid) async {
    emit(PatientDeleting());
    try {
      await patientRepo.deletePatient(pid);

      // Refresh patient list after deleting
      if (currentDate != null) {
        await refreshPatients();
      } else {
        await fetchAllPatients();
      }
    } catch (e) {
      emit(PatientError('Failed to delete patient: $e'));
    }
  }

  // Refresh the current patient list
  Future<void> refreshPatients() async {
    if (currentDate != null) {
      // Clear cache for the current date
      _scheduleCache.remove(currentDate!);

      // Fetch fresh data
      await fetchPatientsByDate(currentDate!);
    } else {
      await fetchAllPatients();
    }
  }
}
