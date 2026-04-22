class LoanModel {
  final String id;
  final String personName;
  final double amountGiven;
  final double amountReturned;
  final DateTime date;

  LoanModel({
    required this.id,
    required this.personName,
    required this.amountGiven,
    required this.amountReturned,
    required this.date,
  });

  double get pendingAmount => amountGiven - amountReturned;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amountGiven': amountGiven,
      'amountReturned': amountReturned,
      'date': date.toIso8601String(),
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] ?? '',
      personName: map['personName'] ?? '',
      amountGiven: (map['amountGiven'] ?? 0.0).toDouble(),
      amountReturned: (map['amountReturned'] ?? 0.0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
