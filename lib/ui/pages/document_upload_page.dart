import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class DocumentUploadPage extends StatefulWidget {
  final String applicationId;
  const DocumentUploadPage({super.key, required this.applicationId});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  double _progress = 0;
  bool _busy = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: kIsWeb,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final path = file.path;

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size must be less than 10MB'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate file extension
    final extension = file.extension?.toLowerCase();
    const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
    if (extension == null || !allowedExtensions.contains(extension)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only PDF, JPG, PNG, DOC, and DOCX files are allowed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _busy = true;
      _progress = 0;
    });
    try {
      final name = file.name;
      final ref = FirebaseStorage.instance.ref(
        'applications/${widget.applicationId}/$name',
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        // Web upload using bytes
        uploadTask = ref.putData(file.bytes!);
      } else {
        // Mobile/Desktop upload using file
        if (path == null) return;
        uploadTask = ref.putFile(File(path));
      }

      uploadTask.snapshotEvents.listen((e) {
        if (e.totalBytes > 0) {
          setState(() => _progress = e.bytesTransferred / e.totalBytes);
        }
      });

      final snap = await uploadTask;
      final url = await snap.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId)
          .collection('documents')
          .add({
            'name': name,
            'url': url,
            'size': file.size,
            'mime': file.extension ?? '',
            'status': 'uploaded',
            'uploaded_at': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload complete')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appRef = FirebaseFirestore.instance
        .collection('applications')
        .doc(widget.applicationId)
        .collection('documents')
        .orderBy('uploaded_at', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: Column(
        children: [
          if (_busy)
            LinearProgressIndicator(
              value: _progress > 0 && _progress < 1 ? _progress : null,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _pickAndUpload,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Upload Document'),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: appRef.snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No documents yet.'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text((d['name'] ?? 'Document').toString()),
                      subtitle: Text((d['mime'] ?? '').toString()),
                      trailing: Icon(
                        (d['status'] ?? 'uploaded') == 'uploaded'
                            ? Icons.check_circle
                            : Icons.hourglass_bottom,
                        color: Colors.green,
                      ),
                      onTap: () {}, // optional preview logic later
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
