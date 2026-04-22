import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtracker/settings/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../accounts/models/account_model.dart';
import '../../homescreen/models/transaction_model.dart';
import '../../homescreen/models/category_model.dart';
import '../../homescreen/models/emi_model.dart';
import '../../settings/models/payment_models.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

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

  /// DANGEROUS: Deletes ALL data for the current user in Firestore.
  /// This includes accounts, transactions, categories, emis, etc.
  Future<void> dangerousWipeAllMyData() async {
    final uid = currentUid;
    if (uid == null) return;

    final userDoc = _db.collection('users').doc(uid);

    // List of subcollections to clear
    final subcollections = [
      'accounts',
      'transactions',
      'categories',
      'emis',
      'payment_methods',
      'fixed_expenses',
      'profile',
      'salary_management',
      'loans',
      'salary_reports',
      'pending_transactions',
    ];

    WriteBatch batch = _db.batch();
    int opCount = 0;

    for (final collName in subcollections) {
      final snapshot = await userDoc.collection(collName).get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        opCount++;

        // Firestore batch limit is 500. We commit every 450 to be safe.
        if (opCount >= 450) {
          await batch.commit();
          batch = _db.batch();
          opCount = 0;
        }
      }
    }
    // Finally delete the user root document if we have space in batch,
    // or start a fresh one.
    if (opCount >= 450) {
      await batch.commit();
      batch = _db.batch();
    }
    batch.delete(userDoc);
    await batch.commit();
  }

  // --- ACCOUNTS ---
  Stream<List<AccountModel>> getAccounts() {
    return _userCollection('accounts').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => AccountModel.fromMap(doc.data() as Map<String, dynamic>),
          )
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
    return _userCollection(
      'transactions',
    ).orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    await _userCollection(
      'transactions',
    ).doc(transaction.id).set(transaction.toMap());
  }

  Future<void> saveTransactionAndUpdateBalance(
    TransactionModel transaction,
  ) async {
    // 1. Save the transaction itself
    await saveTransaction(transaction);

    // 2. If an account is linked, update its balance
    if (transaction.accountId != null && transaction.accountId!.isNotEmpty) {
      final accountDoc = _userCollection('accounts').doc(transaction.accountId);

      // Use a Firestore transaction for consistency
      await _db.runTransaction((firestoreTransaction) async {
        final snapshot = await firestoreTransaction.get(accountDoc);

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final currentBalance = (data['balance'] ?? 0.0).toDouble();

          double newBalance;
          if (transaction.isExpense) {
            newBalance = currentBalance - transaction.amount;
          } else {
            newBalance = currentBalance + transaction.amount;
          }

          firestoreTransaction.update(accountDoc, {'balance': newBalance});
        }
      });
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _userCollection('transactions').doc(id).delete();
  }

  Future<void> deleteTransactionAndUpdateBalance(
    TransactionModel transaction,
  ) async {
    // 1. Delete the transaction itself
    await deleteTransaction(transaction.id);

    // 2. If an account is linked, revert its balance
    if (transaction.accountId != null && transaction.accountId!.isNotEmpty) {
      final accountDoc = _userCollection('accounts').doc(transaction.accountId);

      // Use a Firestore transaction for consistency
      await _db.runTransaction((firestoreTransaction) async {
        final snapshot = await firestoreTransaction.get(accountDoc);

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final currentBalance = (data['balance'] ?? 0.0).toDouble();

          double newBalance;
          if (transaction.isExpense) {
            // Deleting an expense adds back to the balance
            newBalance = currentBalance + transaction.amount;
          } else {
            // Deleting an income reduces the balance
            newBalance = currentBalance - transaction.amount;
          }

          firestoreTransaction.update(accountDoc, {'balance': newBalance});
        }
      });
    }
  }

  // --- CATEGORIES ---
  Stream<List<CategoryModel>> getCategories() {
    return _userCollection('categories').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> saveCategory(CategoryModel category) async {
    await _userCollection('categories').doc(category.id).set(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _userCollection('categories').doc(id).delete();
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

  Future<void> saveEmiWithInitialDeduction(EmiModel emi) async {
    final emiDoc = _userCollection('emis').doc(emi.id);

    await _db.runTransaction((firestoreTransaction) async {
      // 1. Perform ALL Reads first
      DocumentSnapshot? accountSnapshot;
      if (emi.isNewPurchase &&
          emi.totalAmount > 0 &&
          emi.accountId != null &&
          emi.accountId!.isNotEmpty) {
        final accountDoc = _userCollection('accounts').doc(emi.accountId);
        accountSnapshot = await firestoreTransaction.get(accountDoc);
      }

      // 2. Perform ALL Writes next

      firestoreTransaction.set(emiDoc, emi.toMap());

      if (emi.isNewPurchase &&
          emi.totalAmount > 0 &&
          emi.accountId != null &&
          emi.accountId!.isNotEmpty) {
        final transactionId =
            'purchase_${DateTime.now().millisecondsSinceEpoch}';
        final transactionDoc = _userCollection(
          'transactions',
        ).doc(transactionId);

        // Create Transaction record for the purchase
        final transaction = TransactionModel(
          id: transactionId,
          title: emi.title,
          dateSubtitle: 'Loan Initiation',
          date: DateTime.now(),
          amount: emi.totalAmount,
          iconName: emi.iconName,
          iconBackgroundColor: emi.color.withOpacity(0.1),
          iconColor: emi.color,
          isExpense: true,
          accountId: emi.accountId,
          categoryId: emi.categoryId,
        );
        firestoreTransaction.set(transactionDoc, transaction.toMap());

        // Update Account Balance if it exists
        if (accountSnapshot != null && accountSnapshot.exists) {
          final data = accountSnapshot.data() as Map<String, dynamic>;
          final currentBalance = (data['balance'] ?? 0.0).toDouble();

          // Deduct full amount from balance (e.g. 5000 - 3000 = 2000)
          double newBalance = currentBalance - emi.totalAmount;
          final accountDoc = _userCollection('accounts').doc(emi.accountId);
          firestoreTransaction.update(accountDoc, {'balance': newBalance});
        }
      }
    });
  }

  Future<void> payEmiAndUpdateBalance(
    EmiModel emi,
    AccountModel? account,
  ) async {
    final emiDoc = _userCollection('emis').doc(emi.id);

    await _db.runTransaction((firestoreTransaction) async {
      // 1. Perform ALL Reads first
      DocumentSnapshot? accountSnapshot;
      if (account != null) {
        final accountDoc = _userCollection('accounts').doc(account.id);
        accountSnapshot = await firestoreTransaction.get(accountDoc);
      }

      // 2. Perform ALL Writes next
      // Update EMI progress
      final updatedEmi = emi.copyWith(
        monthsPaid: emi.monthsPaid + 1,
        nextPaymentDate: DateTime(
          emi.nextPaymentDate.year,
          emi.nextPaymentDate.month + 1,
          emi.nextPaymentDate.day,
        ),
      );
      firestoreTransaction.update(emiDoc, updatedEmi.toMap());

      // If it's a Credit Card or we have an account to deduct from:
      // (Simplified logic here: if we have an account, create transaction and update balance)
      // Calculate actual amount for this installment (handles final months with smaller balances)
      final actualInstallmentAmount = (emi.amountLeft < emi.monthlyAmount)
          ? emi.amountLeft
          : emi.monthlyAmount;

      if (account != null) {
        final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
        final transactionDoc = _userCollection(
          'transactions',
        ).doc(transactionId);

        // Create Transaction record
        final transaction = TransactionModel(
          id: transactionId,
          title: 'EMI: ${emi.title}',
          dateSubtitle: 'EMI Installment',
          date: DateTime.now(),
          amount: actualInstallmentAmount,
          iconName: emi.iconName,
          iconBackgroundColor: emi.color.withOpacity(0.1),
          iconColor: emi.color,
          isExpense: true,
          accountId: account.id,
          accountName: account.name,
          categoryId: emi.categoryId,
        );
        firestoreTransaction.set(transactionDoc, transaction.toMap());

        // Update Account Balance
        if (accountSnapshot != null && accountSnapshot.exists) {
          final data = accountSnapshot.data() as Map<String, dynamic>;
          final currentBalance = (data['balance'] ?? 0.0).toDouble();
          final accountType = data['type'] ?? 'bank';

          double newBalance;
          if (accountType == 'credit') {
            // RECOVERY: Addition for Credit/Limit accounts (Restores limit/repays debt)
            // Example: 5,000 remains but monthly is 10,000 -> Restores 5,000
            newBalance = currentBalance + actualInstallmentAmount;
          } else {
            // DEDUCTION: Subtraction for Bank/Cash (Money leaves account)
            newBalance = currentBalance - actualInstallmentAmount;
          }
          final accountDoc = _userCollection('accounts').doc(account.id);
          firestoreTransaction.update(accountDoc, {'balance': newBalance});
        }
      }
    });
  }

  Future<void> deleteEmi(String id) async {
    final emiDoc = _userCollection('emis').doc(id);

    await _db.runTransaction((firestoreTransaction) async {
      // 1. Perform ALL Reads first
      final emiSnapshot = await firestoreTransaction.get(emiDoc);

      if (!emiSnapshot.exists) return;

      final emiData = emiSnapshot.data() as Map<String, dynamic>;
      final emi = EmiModel.fromMap(emiData);

      DocumentSnapshot? accountSnapshot;
      if (emi.isNewPurchase &&
          emi.totalAmount > 0 &&
          emi.accountId != null &&
          emi.accountId!.isNotEmpty) {
        final accountDoc = _userCollection('accounts').doc(emi.accountId);
        accountSnapshot = await firestoreTransaction.get(accountDoc);
      }

      // 2. Perform ALL Writes next
      if (emi.isNewPurchase &&
          emi.totalAmount > 0 &&
          emi.accountId != null &&
          emi.accountId!.isNotEmpty &&
          accountSnapshot != null &&
          accountSnapshot.exists) {
        final data = accountSnapshot.data() as Map<String, dynamic>;
        final currentBalance = (data['balance'] ?? 0.0).toDouble();

        // REVERSE the deduction: add totalAmount back
        double newBalance = currentBalance + emi.totalAmount;
        final accountDoc = _userCollection('accounts').doc(emi.accountId);
        firestoreTransaction.update(accountDoc, {'balance': newBalance});
      }

      // Delete the EMI document
      firestoreTransaction.delete(emiDoc);
    });
  }

  // --- FIXED EXPENSES & SALARY ---
  Stream<List<FixedExpenseModel>> getFixedExpenses() {
    return _userCollection('fixed_expenses').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                FixedExpenseModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> saveFixedExpense(FixedExpenseModel expense) async {
    await _userCollection(
      'fixed_expenses',
    ).doc(expense.id).set(expense.toMap());
  }

  Future<void> deleteFixedExpense(String id) async {
    await _userCollection('fixed_expenses').doc(id).delete();
  }

  // --- SETTINGS (Salary, Profile, Budget, etc.) ---

  // PROFILE
  Stream<UserModel?> getProfile() {
    final uid = currentUid;
    if (uid == null) throw Exception('User not authenticated');
    return _db
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profileData')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;
          return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        });
  }

  Future<void> saveProfile(UserModel user) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profileData')
        .set(user.toMap(), SetOptions(merge: true));
  }

  // SALARY (Monthly Partitioned)
  Stream<Map<String, dynamic>> getMonthlySalaryConfig(String monthKey) {
    final uid = currentUid;
    if (uid == null) throw Exception('User not authenticated');
    return _db
        .collection('users')
        .doc(uid)
        .collection('salary_reports')
        .doc(monthKey)
        .snapshots()
        .map((snapshot) {
          return (snapshot.data() as Map<String, dynamic>?) ?? {};
        });
  }

  Future<QuerySnapshot> getSalaryReportsSnapshot() async {
    return _userCollection('salary_reports').get();
  }

  Future<void> saveMonthlySalaryConfig(
    String monthKey,
    Map<String, dynamic> data,
  ) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('salary_reports')
        .doc(monthKey)
        .set(data, SetOptions(merge: true));
  }

  // SALARY (Global - Primary again)
  Stream<Map<String, dynamic>> getSalaryConfig() {
    final uid = currentUid;
    if (uid == null) throw Exception('User not authenticated');
    return _db
        .collection('users')
        .doc(uid)
        .collection('salary_management')
        .doc('salaryConfig')
        .snapshots()
        .map((snapshot) {
          return (snapshot.data() as Map<String, dynamic>?) ?? {};
        });
  }

  Future<void> saveSalaryConfig(Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) return;

    final batch = _db.batch();

    // 1. Update Global Config
    final globalDoc = _db
        .collection('users')
        .doc(uid)
        .collection('salary_management')
        .doc('salaryConfig');
    batch.set(globalDoc, data, SetOptions(merge: true));

    // 2. Update Current Month Report
    final monthKey = DateFormat('yyyy_MM').format(DateTime.now());
    final monthDoc = _db
        .collection('users')
        .doc(uid)
        .collection('salary_reports')
        .doc(monthKey);
    batch.set(monthDoc, data, SetOptions(merge: true));

    await batch.commit();
  }

  // LOANS
  Stream<List<Map<String, dynamic>>> getLoans() {
    return _userCollection('loans').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> saveLoan(Map<String, dynamic> loan) async {
    final id = loan['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _userCollection('loans').doc(id).set(loan);
  }

  Future<void> deleteLoan(String id) async {
    await _userCollection('loans').doc(id).delete();
  }

  // --- PENDING TRANSACTIONS (from SMS) ---
  Stream<List<Map<String, dynamic>>> getPendingTransactions() {
    return _userCollection(
      'pending_transactions',
    ).orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    });
  }

  Future<void> savePendingTransaction(Map<String, dynamic> pending) async {
    final id =
        pending['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _userCollection('pending_transactions').doc(id).set(pending);
  }

  Future<void> deletePendingTransaction(String id) async {
    await _userCollection('pending_transactions').doc(id).delete();
  }
}
