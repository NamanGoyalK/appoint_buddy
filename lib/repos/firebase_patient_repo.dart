import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/patient_model.dart';
import 'patient_repo.dart';

class FirebasePatientRepo implements PatientRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get collection reference safely with null check
  CollectionReference _getPatientCollection() {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('patients');
  }

  @override
  Future<void> addPatient(Patient patient) async {
    try {
      await _getPatientCollection().doc(patient.pid).set(patient.toJson());
    } catch (e) {
      throw Exception('Error creating patient: $e');
    }
  }

  @override
  Future<List<Patient>> fetchAllPatients() async {
    try {
      // Fetch all patients ordered by timestamp
      final patientsSnapshot = await _getPatientCollection()
          .orderBy('timestamp', descending: true)
          .get();

      // Convert Firestore documents to a list of Patient objects
      final List<Patient> allPatients = patientsSnapshot.docs
          .map((doc) => Patient.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPatients;
    } catch (e) {
      throw Exception('Error fetching the patients: $e');
    }
  }

  @override
  Future<Patient?> fetchPatient(String pid) async {
    try {
      final patientDoc = await _getPatientCollection().doc(pid).get();

      if (!patientDoc.exists) {
        return null;
      }

      return Patient.fromJson(patientDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching the patient: $e');
    }
  }

  @override
  Future<void> updatePatient(Patient updatedPatient) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('patients')
          .doc(updatedPatient.pid)
          .update({
        'name': updatedPatient.name,
        'email': updatedPatient.email,
        'days': updatedPatient.days,
        'problem': updatedPatient.problem,
        'treatment': updatedPatient.treatment,
        'lastVisitDay': Timestamp.fromDate(updatedPatient.lastVisitDay),
        'isRecurring': updatedPatient.isRecurring,
        'phoneNumber': updatedPatient.phoneNumber
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Patient: $e');
      }
      throw Exception('Error updating Patient');
    }
  }

  @override
  Future<void> deletePatient(String pid) async {
    try {
      await _getPatientCollection().doc(pid).delete();
    } catch (e) {
      throw Exception('Error deleting patient: $e');
    }
  }

  @override
  Future<List<Patient>> fetchPatientsByDate(DateTime date) async {
    try {
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(const Duration(days: 1));

      // Fetch all patients
      final patientsSnapshot = await _getPatientCollection().get();

      // Apply filtering for lastVisitDay + recurringDays logic
      final List<Patient> filteredPatients = patientsSnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final lastVisitDay = (data['lastVisitDay'] != null)
                ? (data['lastVisitDay'] as Timestamp).toDate()
                : null; // Handle null values
            final days = data['days'] ?? 0; // Default to 0 if null
            final isRecurring =
                data['isRecurring'] ?? false; // Default to false

            if (lastVisitDay == null) {
              return false; // Skip patients with no lastVisitDay
            }

            // Check if this patient has a recurring schedule
            if (isRecurring) {
              if (days > 0) {
                final daysSinceLastVisit =
                    startDate.difference(lastVisitDay).inDays;

                return daysSinceLastVisit >= 0 &&
                    daysSinceLastVisit % days == 0;
              }
            } else {
              return lastVisitDay.isAfter(startDate) &&
                  lastVisitDay.isBefore(endDate);
            }
            return false; // Default return to satisfy non-nullable bool
          })
          .map((doc) => Patient.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return filteredPatients;
    } catch (e) {
      throw Exception('Error fetching the patients by date: $e');
    }
  }

  // Optional: Add transaction support for critical operations
  Future<void> updatePatientWithTransaction(Patient patient) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await firestore.runTransaction((transaction) async {
        final docRef = firestore
            .collection('users')
            .doc(user.uid)
            .collection('patients')
            .doc(patient.pid);

        transaction.update(docRef, patient.toJson());
      });
    } catch (e) {
      throw Exception('Error updating patient in transaction: $e');
    }
  }
}
