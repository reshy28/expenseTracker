import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../accounts/models/account_model.dart';
import '../../homescreen/models/transaction_model.dart';
import '../../homescreen/models/emi_model.dart';
import '../../settings/models/payment_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously and return UID
  Future<String?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user?.uid;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  String? get currentUid => _auth.currentUser?.uid;

  // Generic helper for collection paths
  CollectionReference _userCollection(String collectionName) {
    final uid = currentUid;
    if (uid == null) throw Exception('User not authenticated');
    return _db.collection('users').doc(uid).collection(collectionName);
  }

  // --- ACCOUNTS ---
  Stream<List<AccountModel>> getAccounts() {
    return _userCollection('accounts').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AccountModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> saveAccount(AccountModel account) async {
    await _userCollection('accounts').doc(account.id).set(account.toMap());
  }

  Future<void> deleteAccount(String id) async {
    await _userCollection('accounts').doc(id).delete();
  }

  // --- TRANSACTIONS ---
  Stream<List<TransactionModel>> getTransactions() {
    return _userCollection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    // Note: We use title+date as ID or a random ID if not provided
    await _userCollection('transactions').add(transaction.toMap());
  }

  // --- EMIS ---
  Stream<List<EmiModel>> getEmis() {
    return _userCollection('emis').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EmiModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> saveEmi(EmiModel emi) async {
    await _userCollection('emis').doc(emi.id).set(emi.toMap());
  }

  Future<void> deleteEmi(String id) async {
    await _userCollection('emis').doc(id).delete();
  }

  // --- FIXED EXPENSES & SALARY ---
  Stream<List<FixedExpenseModel>> getFixedExpenses() {
    return _userCollection('fixed_expenses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FixedExpenseModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> saveFixedExpense(FixedExpenseModel expense) async {
    await _userCollection('fixed_expenses').doc(expense.id).set(expense.toMap());
  }

  Future<void> deleteFixedExpense(String id) async {
    await _userCollection('fixed_expenses').doc(id).delete();
  }

  // --- SETTINGS (Salary, Budget, etc.) ---
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(settings, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getSettings() {
    final uid = currentUid;
    if (uid == null) throw Exception('User not authenticated');
    return _db.collection('users').doc(uid).snapshots();
  }
}
