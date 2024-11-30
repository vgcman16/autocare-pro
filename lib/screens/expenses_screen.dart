import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/vehicle.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Expense> _expenses = [];
  final List<Vehicle> _dummyVehicles = [
    Vehicle(
      make: 'Toyota',
      model: 'Camry',
      year: 2020,
      vin: 'ABC123',
      mileage: 50000,
    ),
  ];

  double get _totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  void _addExpense() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddExpenseScreen(
          vehicles: _dummyVehicles,
        ),
      ),
    );

    if (result != null && result is Expense) {
      setState(() {
        _expenses.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Expenses'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _addExpense,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildExpenseSummary(),
            Expanded(
              child: _buildExpensesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSummary() {
    final currentYear = DateTime.now().year;
    final yearlyExpenses = _expenses
        .where((expense) => expense.date.year == currentYear)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoListSection.insetGrouped(
        children: [
          CupertinoListTile(
            title: Text('Total Expenses ($currentYear)'),
            trailing: Text(
              '\$${yearlyExpenses.toStringAsFixed(2)}',
              style: const TextStyle(
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.money_dollar_circle,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No expenses yet',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add an expense',
              style: TextStyle(
                color: CupertinoColors.systemGrey.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        final vehicle = _dummyVehicles.firstWhere(
          (v) => v.id == expense.vehicleId,
          orElse: () => _dummyVehicles.first,
        );
        
        return _buildExpenseItem(
          date: expense.date,
          description: expense.description,
          amount: expense.amount,
          vehicle: '${vehicle.year} ${vehicle.make} ${vehicle.model}',
          category: expense.category,
        );
      },
    );
  }

  Widget _buildExpenseItem({
    required DateTime date,
    required String description,
    required double amount,
    required String vehicle,
    required String category,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: CupertinoListSection.insetGrouped(
        children: [
          CupertinoListTile(
            title: Text(description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle),
                Text(
                  category,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
