import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Announcements',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AnnouncementPageAdmin(),
    );
  }
}

class AnnouncementPageAdmin extends StatefulWidget {
  @override
  _AnnouncementPageAdminState createState() => _AnnouncementPageAdminState();
}

class _AnnouncementPageAdminState extends State<AnnouncementPageAdmin> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _uploadedImageUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes!;
      });
    }
  }

  Future<void> _deleteAnnouncement(String docId) async {
    try {
      await _firestore.collection('announcements').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Announcement deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }


  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('announcements/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _saveAnnouncement({String? docId}) async {
    String? imageUrl = _uploadedImageUrl;
    if (_selectedImageBytes != null) {
      imageUrl = await _uploadImage(_selectedImageBytes!);
    }

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'date': _dateController.text,
      'imageUrl': imageUrl,
    };

    if (docId == null) {
      await _firestore.collection('announcements').add(data);
    } else {
      await _firestore.collection('announcements').doc(docId).update(data);
    }

    _clearFields();
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _dateController.clear();
    _selectedImageBytes = null;
    _uploadedImageUrl = null;
  }

  void _populateFields(Map<String, dynamic> data) {
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _locationController.text = data['location'] ?? '';
    _dateController.text = data['date'] ?? '';
    _uploadedImageUrl = data['imageUrl'];
  }

  void _showEditDialog(DocumentSnapshot doc) {
    _populateFields(doc.data() as Map<String, dynamic>);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Announcement'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ..._buildFormFields(),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                label: Text('Pick Image'),
                onPressed: _pickImage,
              ),
              if (_selectedImageBytes != null || _uploadedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _selectedImageBytes != null
                      ? Image.memory(_selectedImageBytes!, height: 150)
                      : Image.network(_uploadedImageUrl!, height: 150),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _saveAnnouncement(docId: doc.id);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
      TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
      TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Location')),
      TextField(controller: _dateController, decoration: InputDecoration(labelText: 'Date')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('Admin Announcements', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Color(0xFFF7F9FC),
        body: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Create New Announcement',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ..._buildFormFields(),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.image),
                              label: Text('Pick Image'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _saveAnnouncement,
                              icon: Icon(Icons.save),
                              label: Text('Save'),
                            ),
                          ],
                        ),
                        if (_selectedImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Image.memory(_selectedImageBytes!, height: 120),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text('All Announcements',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('announcements')
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting)
                              return Center(child: CircularProgressIndicator());

                            if (snapshot.hasError)
                              return Center(child: Text('Error: ${snapshot.error}'));

                            final docs = snapshot.data?.docs ?? [];

                            if (docs.isEmpty)
                              return Center(child: Text('No announcements yet.'));

                            return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data() as Map<String, dynamic>;

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 📄 Left Section - Text Info
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['title'] ?? 'No Title',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                data['description'] ?? 'No Description',
                                                style: TextStyle(color: Colors.grey[800]),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                '📍 ${data['location'] ?? 'No location'}',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                              Text(
                                                '📅 ${data['date'] ?? 'No date'}',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.edit, color: Colors.blue),
                                                    onPressed: () => _showEditDialog(doc),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => _deleteAnnouncement(doc.id),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 🖼️ Right Section - Image
                                        if (data['imageUrl'] != null) ...[
                                          SizedBox(width: 16),
                                          // Right section: Always show an image
                                          SizedBox(width: 16),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                                ? Image.network(
                                              data['imageUrl'],
                                              height: 100,
                                              width: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/announcement.png',
                                                  height: 100,
                                                  width: 140,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                                : Image.asset(
                                              'assets/images/announcement.png',
                                              height: 100,
                                              width: 140,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                    ],
                ),
            ),
        ),
    );
  }
}
