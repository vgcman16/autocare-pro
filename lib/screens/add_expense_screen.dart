import 'package:flutter/cupertino.dart';
import '../models/expense.dart';
import '../models/vehicle.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const AddExpenseScreen({
    super.key,
    required this.vehicles,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late Vehicle _selectedVehicle;
  String _selectedCategory = 'Maintenance';

  final List<String> _categories = [
    'Maintenance',
    'Fuel',
    'Insurance',
    'Registration',
    'Repairs',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.vehicles.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() => _selectedDate = newDate);
            },
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all required fields'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final expense = Expense(
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      vehicleId: _selectedVehicle.id ?? 0,
      category: _selectedCategory,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Expense'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _saveExpense,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Expense Details'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _descriptionController,
                  prefix: const Text('Description'),
                  placeholder: 'Enter expense description',
                  autocorrect: false,
                ),
                CupertinoTextFormFieldRow(
                  controller: _amountController,
                  prefix: const Text('Amount'),
                  placeholder: 'Enter amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        const Text(
                          'Date',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Category'),
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        child: SafeArea(
                          top: false,
                          child: CupertinoPicker(
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                _selectedCategory = _categories[index];
                              });
                            },
                            children: _categories.map((c) => Text(c)).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        const Text(
                          'Category',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _selectedCategory,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Vehicle'),
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        child: SafeArea(
                          top: false,
                          child: CupertinoPicker(
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                _selectedVehicle = widget.vehicles[index];
                              });
                            },
                            children: widget.vehicles
                                .map((v) => Text('${v.year} ${v.make} ${v.model}'))
                                .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        const Text(
                          'Vehicle',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedVehicle.year} ${_selectedVehicle.make} ${_selectedVehicle.model}',
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Additional Information'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _notesController,
                  prefix: const Text('Notes'),
                  placeholder: 'Enter any additional notes',
                  maxLines: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
