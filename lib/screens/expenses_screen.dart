import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Expense> _expenses = [];
  final List<Vehicle> _vehicles = [];
  final VehicleService _vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      setState(() {
        _vehicles.clear();
        _vehicles.addAll(vehicles);
      });
    } catch (e) {
      // TODO: Show error to user
      print('Error loading vehicles: $e');
    }
  }

  double get _totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  void _addExpense() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddExpenseScreen(
          vehicles: _vehicles,
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
        
        return _buildExpenseItem(
          date: expense.date,
          description: expense.description,
          amount: expense.amount,
          vehicleId: expense.vehicleId,
          category: expense.category,
        );
      },
    );
  }

  Widget _buildExpenseItem({
    required DateTime date,
    required String description,
    required double amount,
    required int vehicleId,
    required String category,
  }) {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => Vehicle(
        make: 'Unknown',
        model: 'Vehicle',
        year: 0,
        mileage: 0,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: TextStyle(
                    color: CupertinoColors.systemGrey.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  color: CupertinoColors.systemGrey.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
