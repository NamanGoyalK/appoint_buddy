// The PatientRepo outlines the possible operations that can be done for this application.

import '../models/patient_model.dart';

abstract class PatientRepo {
  Future<void> addPatient(Patient patient);
  Future<List<Patient>> fetchAllPatients();
  Future<Patient?> fetchPatient(String uid);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(String uid);
  Future<List<Patient>> fetchPatientsByDate(DateTime date);
}
