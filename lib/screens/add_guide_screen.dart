import 'package:flutter/cupertino.dart';
import '../models/maintenance_guide.dart';

class AddGuideScreen extends StatefulWidget {
  const AddGuideScreen({super.key});

  @override
  State<AddGuideScreen> createState() => _AddGuideScreenState();
}

class _AddGuideScreenState extends State<AddGuideScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  
  final List<TextEditingController> _stepControllers = [TextEditingController()];
  final List<TextEditingController> _toolControllers = [TextEditingController()];
  final List<TextEditingController> _partControllers = [TextEditingController()];
  
  String _selectedDifficulty = 'Easy';
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _costController.dispose();
    _videoUrlController.dispose();
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    for (var controller in _toolControllers) {
      controller.dispose();
    }
    for (var controller in _partControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _addNewTool() {
    setState(() {
      _toolControllers.add(TextEditingController());
    });
  }

  void _addNewPart() {
    setState(() {
      _partControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  void _removeTool(int index) {
    setState(() {
      _toolControllers[index].dispose();
      _toolControllers.removeAt(index);
    });
  }

  void _removePart(int index) {
    setState(() {
      _partControllers[index].dispose();
      _partControllers.removeAt(index);
    });
  }

  void _saveGuide() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _costController.text.isEmpty) {
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

    final guide = MaintenanceGuide(
      title: _titleController.text,
      description: _descriptionController.text,
      steps: _stepControllers.map((c) => c.text).where((text) => text.isNotEmpty).toList(),
      estimatedDuration: int.parse(_durationController.text),
      estimatedCost: double.parse(_costController.text),
      difficulty: _selectedDifficulty,
      tools: _toolControllers.map((c) => c.text).where((text) => text.isNotEmpty).toList(),
      parts: _partControllers.map((c) => c.text).where((text) => text.isNotEmpty).toList(),
      videoUrl: _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
    );

    Navigator.pop(context, guide);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Maintenance Guide'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _saveGuide,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Basic Information'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _titleController,
                  prefix: const Text('Title'),
                  placeholder: 'Enter guide title',
                ),
                CupertinoTextFormFieldRow(
                  controller: _descriptionController,
                  prefix: const Text('Description'),
                  placeholder: 'Enter guide description',
                  maxLines: 3,
                ),
                CupertinoTextFormFieldRow(
                  controller: _durationController,
                  prefix: const Text('Duration (mins)'),
                  placeholder: 'Estimated duration',
                  keyboardType: TextInputType.number,
                ),
                CupertinoTextFormFieldRow(
                  controller: _costController,
                  prefix: const Text('Cost (\$)'),
                  placeholder: 'Estimated cost',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
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
                                _selectedDifficulty = _difficulties[index];
                              });
                            },
                            children: _difficulties.map((d) => Text(d)).toList(),
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
                          'Difficulty',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _selectedDifficulty,
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
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Steps'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Add Step'),
                    onPressed: _addNewStep,
                  ),
                ],
              ),
              children: [
                for (int i = 0; i < _stepControllers.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextFormFieldRow(
                          controller: _stepControllers[i],
                          prefix: Text('Step ${i + 1}'),
                          placeholder: 'Enter step description',
                        ),
                      ),
                      if (i > 0)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            CupertinoIcons.minus_circle_fill,
                            color: CupertinoColors.destructiveRed,
                          ),
                          onPressed: () => _removeStep(i),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Required Tools'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Add Tool'),
                    onPressed: _addNewTool,
                  ),
                ],
              ),
              children: [
                for (int i = 0; i < _toolControllers.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextFormFieldRow(
                          controller: _toolControllers[i],
                          prefix: Text('Tool ${i + 1}'),
                          placeholder: 'Enter tool name',
                        ),
                      ),
                      if (i > 0)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            CupertinoIcons.minus_circle_fill,
                            color: CupertinoColors.destructiveRed,
                          ),
                          onPressed: () => _removeTool(i),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Required Parts'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Add Part'),
                    onPressed: _addNewPart,
                  ),
                ],
              ),
              children: [
                for (int i = 0; i < _partControllers.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextFormFieldRow(
                          controller: _partControllers[i],
                          prefix: Text('Part ${i + 1}'),
                          placeholder: 'Enter part name',
                        ),
                      ),
                      if (i > 0)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            CupertinoIcons.minus_circle_fill,
                            color: CupertinoColors.destructiveRed,
                          ),
                          onPressed: () => _removePart(i),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Additional Information'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _videoUrlController,
                  prefix: const Text('Video URL'),
                  placeholder: 'Enter tutorial video URL (optional)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
