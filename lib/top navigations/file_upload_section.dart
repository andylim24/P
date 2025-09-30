import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class FileUploadSection extends StatefulWidget {
  const FileUploadSection({super.key});

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> _uploadFile(String type) async {
    final consent = await _showDisclaimerDialog();
    if (!consent) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.bytes != null && user != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName =
          '$type/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      setState(() => isUploading = true);

      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putData(fileBytes);
        final downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          '${type}Url': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.toUpperCase()} uploaded successfully!')),
        );

        await _loadUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  Future<void> _removeFile(String type) async {
    final field = '${type}Url';
    if (userData?[field] != null && user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          field: FieldValue.delete(),
        });
        setState(() => userData![field] = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.toUpperCase()} removed.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing ${type.toUpperCase()}: $e')),
        );
      }
    }
  }

  void _viewFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file link')),
      );
    }
  }
  Future<bool> _showDisclaimerDialog() async {
    bool consentGiven = false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            'Disclaimer!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DATA PRIVACY CONSENT\n\n'
                              'In compliance with the Data Privacy Act (DPA) of 2012 and its Implementing Rules and Regulations (IRR), '
                              'I authorize the Public Employment Service Office of the City Government of Makati to collect and use my personal information '
                              'for the purpose of processing my application and providing relevant services.\n\n'
                              'I agree and acknowledge the following:\n'
                              '1. My data will be collected and stored for lawful purposes.\n'
                              '2. My data may be shared within the city government and trusted third parties.\n'
                              '3. I may request to update or delete my data at any time.\n'
                              '4. My data will be handled securely and confidentially.\n\n'
                              'Signed this day in Makati City.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "I agree and provide my consent.",
                          style: TextStyle(fontSize: 14),
                        ),
                        value: consentGiven,
                        onChanged: (value) {
                          setState(() {
                            consentGiven = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (consentGiven) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                      Text("You must provide consent before uploading."),
                    ),
                  );
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    ) ??
        false;
  }


  Widget _buildUploadBox(String label, String type) {
    final field = '${type}Url';
    final bgColor =
    type == 'resume' ? Colors.blue.shade700 : Colors.green.shade700;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          if (userData != null && userData![field] != null)
            ListTile(
              tileColor: Colors.white10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
              title: Text(
                'View $label',
                style: const TextStyle(
                    decoration: TextDecoration.underline, color: Colors.white),
              ),
              onTap: () => _viewFile(userData![field]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _removeFile(type),
              ),
            ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: isUploading ? null : () => _uploadFile(type),
            icon: isUploading
                ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_file),
            label: Text(
              isUploading
                  ? 'Uploading...'
                  : (userData?[field] != null
                  ? 'Update $label (PDF)'
                  : 'Upload $label (PDF)'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 500;
        return isMobile
            ? Column(
          children: [
            SizedBox(
                width: double.infinity,
                child: _buildUploadBox('Resume', 'resume')),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: _buildUploadBox('CV', 'cv')),
          ],
        )
            : Row(
          children: [
            Expanded(child: _buildUploadBox('Resume', 'resume')),
            const SizedBox(width: 16),
            Expanded(child: _buildUploadBox('CV', 'cv')),
          ],
        );
      },
    );
  }
}
