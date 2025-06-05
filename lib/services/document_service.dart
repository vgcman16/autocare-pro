import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/vehicle_document.dart';
import 'database_service.dart';

class DocumentService {
  final DatabaseService _db;
  
  DocumentService(this._db);

  Future<String> get _documentsPath async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${appDir.path}/vehicle_documents');
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir.path;
  }

  Future<VehicleDocument> saveDocument({
    required int vehicleId,
    required String title,
    required String type,
    required File file,
    required DateTime date,
    String? description,
    double? amount,
    Map<String, dynamic>? metadata,
  }) async {
    final docsPath = await _documentsPath;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    final savedFile = await file.copy('$docsPath/$fileName');

    final document = VehicleDocument(
      vehicleId: vehicleId,
      title: title,
      type: type,
      filePath: savedFile.path,
      date: date,
      description: description,
      amount: amount,
      metadata: metadata,
    );

    final id = await _db.insert('documents', document.toMap());
    return document.copyWith(id: id);
  }

  Future<List<VehicleDocument>> getDocuments(int vehicleId) async {
    final records = await _db.query(
      'documents',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    return records.map((record) => VehicleDocument.fromMap(record)).toList();
  }

  Future<void> deleteDocument(int id) async {
    final document = (await _db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    )).first;
    
    // Delete the file
    final file = File(VehicleDocument.fromMap(document).filePath);
    if (await file.exists()) {
      await file.delete();
    }
    
    // Delete the database record
    await _db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<File> exportToPdf(int vehicleId) async {
    final documents = await getDocuments(vehicleId);
    final pdf = pw.Document();

    // Create PDF content
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Vehicle Documents Report'),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              ['Title', 'Type', 'Date', 'Description', 'Amount'],
              ...documents.map((doc) => [
                    doc.title,
                    doc.type,
                    doc.date.toString(),
                    doc.description ?? '',
                    doc.amount?.toString() ?? '',
                  ]),
            ],
          ),
        ],
      ),
    );

    // Save PDF
    final docsPath = await _documentsPath;
    final pdfFile = File('$docsPath/vehicle_${vehicleId}_documents.pdf');
    await pdfFile.writeAsBytes(await pdf.save());
    return pdfFile;
  }
}
