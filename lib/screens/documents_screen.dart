import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../models/vehicle_document.dart';
import '../services/document_service.dart';
import '../services/database_service.dart';

class DocumentsScreen extends StatefulWidget {
  final int vehicleId;

  const DocumentsScreen({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late final DatabaseService _databaseService;
  late final DocumentService _documentService;
  final ImagePicker _picker = ImagePicker();
  List<VehicleDocument> _documents = [];

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _documentService = DocumentService(_databaseService);
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final documents = await _documentService.getDocuments(widget.vehicleId);
    setState(() {
      _documents = documents;
    });
  }

  Future<void> _addDocument() async {
    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Document Type'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'registration'),
            child: const Text('Registration'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'insurance'),
            child: const Text('Insurance'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'service_record'),
            child: const Text('Service Record'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'receipt'),
            child: const Text('Receipt'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'damage_report'),
            child: const Text('Damage Report'),
          ),
        ],
      ),
    );

    if (type == null) return;

    final source = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Source'),
        children: [
          if (type == 'damage_report' || type == 'service_record')
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'camera'),
              child: const Text('Take Photo'),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'gallery'),
            child: const Text('Choose from Gallery'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'file'),
            child: const Text('Select File'),
          ),
        ],
      ),
    );

    if (source == null) return;

    File? file;
    if (source == 'camera') {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        file = File(image.path);
      }
    } else if (source == 'gallery') {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        file = File(image.path);
      }
    } else {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        file = File(result.files.single.path!);
      }
    }

    if (file == null) return;

    // Show dialog to get additional details
    final details = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _DocumentDetailsDialog(type: type),
    );

    if (details != null) {
      await _documentService.saveDocument(
        vehicleId: widget.vehicleId,
        title: details['title'],
        type: type,
        file: file,
        date: details['date'],
        description: details['description'],
        amount: details['amount'],
      );
      _loadDocuments();
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final file = await _documentService.exportToPdf(widget.vehicleId);
      await Share.shareFiles([file.path], text: 'Vehicle Documents Report');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final doc = _documents[index];
          return ListTile(
            leading: _getDocumentIcon(doc.type),
            title: Text(doc.title),
            subtitle: Text(
              '${DateFormat.yMMMd().format(doc.date)}\n${doc.description ?? ""}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Document'),
                    content: const Text('Are you sure you want to delete this document?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _documentService.deleteDocument(doc.id!);
                  _loadDocuments();
                }
              },
            ),
            onTap: () {
              OpenFile.open(doc.filePath);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDocument,
        child: const Icon(Icons.add),
      ),
    );
  }

  Icon _getDocumentIcon(String type) {
    switch (type) {
      case 'registration':
        return const Icon(Icons.description);
      case 'insurance':
        return const Icon(Icons.security);
      case 'service_record':
        return const Icon(Icons.build);
      case 'receipt':
        return const Icon(Icons.receipt);
      case 'damage_report':
        return const Icon(Icons.warning);
      default:
        return const Icon(Icons.file_present);
    }
  }
}

class _DocumentDetailsDialog extends StatefulWidget {
  final String type;

  const _DocumentDetailsDialog({Key? key, required this.type}) : super(key: key);

  @override
  _DocumentDetailsDialogState createState() => _DocumentDetailsDialogState();
}

class _DocumentDetailsDialogState extends State<_DocumentDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.type.replaceAll('_', ' ').toUpperCase()}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              if (widget.type == 'receipt' || widget.type == 'service_record')
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'description': _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                'amount': _amountController.text.isEmpty
                    ? null
                    : double.parse(_amountController.text),
                'date': _selectedDate,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
