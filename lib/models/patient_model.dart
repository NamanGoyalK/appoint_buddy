import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String pid;
  final String name;
  final String email;
  final String problem;
  final String treatment;
  late final DateTime lastVisitDay;
  final int days;
  final bool isRecurring;
  final int phoneNumber;

  Patient({
    required this.pid,
    required this.name,
    required this.email,
    required this.problem,
    required this.treatment,
    required this.lastVisitDay,
    required this.days,
    required this.isRecurring,
    required this.phoneNumber,
  });

  //copyWith method to update the patient details
  Patient copyWith({
    String? pid,
    String? name,
    String? newEmail,
    String? newProblem,
    String? newTreatment,
    DateTime? newLastVisitDay,
    int? newDays,
    bool? newIsRecurring,
    int? newPhoneNumber,
  }) {
    return Patient(
      pid: pid ?? this.pid,
      name: name ?? this.name,
      email: newEmail ?? email,
      problem: newProblem ?? problem,
      treatment: newTreatment ?? treatment,
      lastVisitDay: newLastVisitDay ?? lastVisitDay,
      days: newDays ?? days,
      isRecurring: newIsRecurring ?? isRecurring,
      phoneNumber: newPhoneNumber ?? phoneNumber,
    );
  }

  //convert AppUser to json
  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'email': email,
      'problem': problem,
      'treatment': treatment,
      'lastVisitDay': Timestamp.fromDate(lastVisitDay),
      'days': days,
      'isRecurring': isRecurring,
      'phoneNumber': phoneNumber,
    };
  }

  //convert json to AppUser
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      pid: json['pid'],
      name: json['name'],
      email: json['email'],
      problem: json['problem'],
      treatment: json['treatment'],
      lastVisitDay: json['lastVisitDay'] != null
          ? (json['lastVisitDay'] as Timestamp).toDate()
          : DateTime.now(), // Default to current date if null
      days: json['days'] ?? 0, // Default to 0 if null
      isRecurring: json['isRecurring'] ?? false, // Default to false if null
      phoneNumber: json['phoneNumber'] ?? 0, // Default to 0 if null
    );
  }
}
