import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'jobseeker_registration_page.dart';
import 'main_homepage.dart';
import 'widgets/plus_sign_painter.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // User type selection
  String _userType = 'jobseeker';

  // Jobseeker fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _skillsController = TextEditingController();
  String? _selectedBarangay;

  // Employer fields
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _philJobNetIdController = TextEditingController();
  final _vacanciesController = TextEditingController();
  String? _selectedLicenseType;
  String? _selectedEmployerType;

  // File uploads for employer
  PlatformFile? _letterOfIntentFile;
  PlatformFile? _pesoFormFile;
  PlatformFile? _birCertificateFile;
  PlatformFile? _businessPermitFile;
  PlatformFile? _licenseFile;
  PlatformFile? _philJobNetProofFile;
  PlatformFile? _vacanciesListFile;

  bool _isHovering = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _barangayList = [
    'Poblacion', 'Bel-Air', 'Guadalupe Nuevo', 'San Antonio', 'Santa Cruz',
    'San Lorenzo', 'Cembo', 'Comembo', 'East Rembo', 'West Rembo', 'Pembo',
    'South Cembo', 'Rizal', 'Pitogo', 'Olympia', 'Bangkal', 'Tejeros',
    'Singkamas', 'La Paz', 'Palanan', 'Magallanes', 'San Isidro', 'Kasilawan',
  ];

  final List<String> _licenseTypes = [
    'Local Agency - D.O. 174',
    'Overseas Local Agency - POEA License',
    'Cooperative - CDA Membership',
  ];

  final List<String> _employerTypes = [
    'Direct Employer',
    'Local Manpower Agency',
    'Overseas Manpower Agency',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _skillsController.dispose();
    _companyNameController.dispose();
    _companyEmailController.dispose();
    _companyAddressController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _philJobNetIdController.dispose();
    _vacanciesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String fileType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          switch (fileType) {
            case 'letterOfIntent':
              _letterOfIntentFile = result.files.first;
              break;
            case 'pesoForm':
              _pesoFormFile = result.files.first;
              break;
            case 'birCertificate':
              _birCertificateFile = result.files.first;
              break;
            case 'businessPermit':
              _businessPermitFile = result.files.first;
              break;
            case 'license':
              _licenseFile = result.files.first;
              break;
            case 'philJobNetProof':
              _philJobNetProofFile = result.files.first;
              break;
            case 'vacanciesList':
              _vacanciesListFile = result.files.first;
              break;
          }
        });
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<String?> _uploadFile(PlatformFile? file, String folder) async {
    if (file == null || file.bytes == null) return null;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = FirebaseStorage.instance.ref().child('employer_documents/$folder/$fileName');
      
      final uploadTask = ref.putData(
        file.bytes!,
        SettableMetadata(contentType: _getContentType(file.extension)),
      );
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userType == 'jobseeker') {
      await _registerJobseeker();
    } else {
      await _registerEmployer();
    }
  }

  Future<void> _registerJobseeker() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showError("Passwords don't match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        final skillsList = _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': user.email,
          'skills': skillsList,
          'barangay': _selectedBarangay ?? '',
          'userType': 'jobseeker',
          'resumeUrl': '',
          'appliedJobs': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const JobseekerRegistrationPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Registration failed. Please try again.');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerEmployer() async {
    // Validate required files
    if (_letterOfIntentFile == null) {
      _showError('Please upload Letter of Intent');
      return;
    }
    if (_pesoFormFile == null) {
      _showError('Please upload Makati-PESO Establishment Registration Form');
      return;
    }
    if (_birCertificateFile == null) {
      _showError('Please upload BIR Certificate of Registration');
      return;
    }
    if (_businessPermitFile == null) {
      _showError('Please upload Business Permit');
      return;
    }
    if (_licenseFile == null) {
      _showError('Please upload License document');
      return;
    }
    if (_philJobNetProofFile == null) {
      _showError('Please upload PhilJobNet membership proof');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload all files
      final letterOfIntentUrl = await _uploadFile(_letterOfIntentFile, 'letter_of_intent');
      final pesoFormUrl = await _uploadFile(_pesoFormFile, 'peso_form');
      final birCertificateUrl = await _uploadFile(_birCertificateFile, 'bir_certificate');
      final businessPermitUrl = await _uploadFile(_businessPermitFile, 'business_permit');
      final licenseUrl = await _uploadFile(_licenseFile, 'license');
      final philJobNetProofUrl = await _uploadFile(_philJobNetProofFile, 'philjobnet_proof');
      final vacanciesListUrl = await _uploadFile(_vacanciesListFile, 'vacancies_list');

      // Save employer registration to Firestore
      await FirebaseFirestore.instance.collection('employer_registrations').add({
        'companyName': _companyNameController.text.trim(),
        'companyEmail': _companyEmailController.text.trim(),
        'companyAddress': _companyAddressController.text.trim(),
        'contactPerson': _contactPersonController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'licenseType': _selectedLicenseType ?? '',
        'philJobNetId': _philJobNetIdController.text.trim(),
        'employerType': _selectedEmployerType ?? '',
        'vacanciesInfo': _vacanciesController.text.trim(),
        // Document URLs
        'documents': {
          'letterOfIntent': letterOfIntentUrl,
          'pesoForm': pesoFormUrl,
          'birCertificate': birCertificateUrl,
          'businessPermit': businessPermitUrl,
          'license': licenseUrl,
          'philJobNetProof': philJobNetProofUrl,
          'vacanciesList': vacanciesListUrl,
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 32),
            const SizedBox(width: 12),
            const Text('Registration Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thank you for registering your company with PESO Makati.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Please wait for an email confirmation at:', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(_companyEmailController.text.trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Our accreditation staff will review your application and get back to you within 3-5 business days.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/bgimage.png'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 700,
                height: screenHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(painter: const PlusSignPainter(opacity: 0.2)),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildRegistrationForm(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png', width: 100, height: 100),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('PESO MAKATI:', style: GoogleFonts.bebasNeue(fontSize: 50, color: Colors.white)),
              Text('Job Recommendation APP', style: GoogleFonts.bebasNeue(fontSize: 25, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create an Account', style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.blue.shade700)),
            const SizedBox(height: 20),
            _buildUserTypeSelector(),
            const SizedBox(height: 20),
            if (_userType == 'jobseeker') _buildJobseekerForm() else _buildEmployerForm(),
            const SizedBox(height: 25),
            _buildRegisterButton(),
            const SizedBox(height: 20),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Jobseeker', style: TextStyle(fontWeight: FontWeight.w500)),
              value: 'jobseeker',
              groupValue: _userType,
              onChanged: (v) => setState(() => _userType = v!),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Employer', style: TextStyle(fontWeight: FontWeight.w500)),
              value: 'employer',
              groupValue: _userType,
              onChanged: (v) => setState(() => _userType = v!),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobseekerForm() {
    return Column(
      children: [
        _buildTextField(controller: _fullNameController, hintText: 'Full Name', validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 15),
        _buildTextField(controller: _emailController, hintText: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) {
          if (v?.isEmpty == true) return 'Required';
          if (!v!.contains('@')) return 'Invalid email';
          return null;
        }),
        const SizedBox(height: 15),
        _buildTextField(controller: _skillsController, hintText: 'Skills (comma-separated)'),
        const SizedBox(height: 15),
        _buildDropdownField(value: _selectedBarangay, hint: 'Select Barangay', items: _barangayList, onChanged: (v) => setState(() => _selectedBarangay = v), validator: (v) => v == null ? 'Please select a barangay' : null),
        const SizedBox(height: 15),
        _buildTextField(controller: _passwordController, hintText: 'Password', obscureText: true, isPassword: true, isPasswordVisible: _isPasswordVisible, onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible), validator: (v) {
          if (v?.isEmpty == true) return 'Required';
          if (v!.length < 6) return 'Min 6 characters';
          return null;
        }),
        const SizedBox(height: 15),
        _buildTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', obscureText: true, isPassword: true, isPasswordVisible: _isConfirmPasswordVisible, onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible), validator: (v) {
          if (v?.isEmpty == true) return 'Required';
          if (v != _passwordController.text) return 'Passwords must match';
          return null;
        }),
      ],
    );
  }

  Widget _buildEmployerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Company Information'),
        const SizedBox(height: 12),
        _buildTextField(controller: _companyNameController, hintText: 'Company / Establishment Name', validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 12),
        _buildTextField(controller: _companyEmailController, hintText: 'Company Email', keyboardType: TextInputType.emailAddress, validator: (v) {
          if (v?.isEmpty == true) return 'Required';
          if (!v!.contains('@')) return 'Invalid email';
          return null;
        }),
        const SizedBox(height: 12),
        _buildTextField(controller: _companyAddressController, hintText: 'Company Address (Makati deployment area)', validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 12),
        _buildTextField(controller: _contactPersonController, hintText: 'Contact Person Name', validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 12),
        _buildTextField(controller: _contactNumberController, hintText: 'Contact Number', keyboardType: TextInputType.phone, validator: (v) => v?.isEmpty == true ? 'Required' : null),

        const SizedBox(height: 24),
        _buildSectionTitle('Required Documents'),
        const SizedBox(height: 8),
        Text('Accepted formats: PDF, DOC, DOCX, JPG, PNG', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 12),
        
        _buildFileUploadField(
          label: '1. Letter of Intent (addressed to Ms. Vissia Marie P. Aldon)',
          file: _letterOfIntentFile,
          onTap: () => _pickFile('letterOfIntent'),
          required: true,
        ),
        _buildFileUploadField(
          label: '2. Makati-PESO Establishment Registration Form',
          file: _pesoFormFile,
          onTap: () => _pickFile('pesoForm'),
          required: true,
        ),
        _buildFileUploadField(
          label: '3. BIR Certificate of Registration (Form 2303)',
          file: _birCertificateFile,
          onTap: () => _pickFile('birCertificate'),
          required: true,
        ),
        _buildFileUploadField(
          label: '4. Business Permit',
          file: _businessPermitFile,
          onTap: () => _pickFile('businessPermit'),
          required: true,
        ),
        
        const SizedBox(height: 12),
        _buildDropdownField(value: _selectedLicenseType, hint: 'Select License Type', items: _licenseTypes, onChanged: (v) => setState(() => _selectedLicenseType = v), validator: (v) => v == null ? 'Please select license type' : null),
        const SizedBox(height: 8),
        _buildFileUploadField(
          label: '5. License Document (based on type selected above)',
          file: _licenseFile,
          onTap: () => _pickFile('license'),
          required: true,
        ),
        _buildFileUploadField(
          label: '6. PhilJobNet Membership Proof (www.philjobnet.ph)',
          file: _philJobNetProofFile,
          onTap: () => _pickFile('philJobNetProof'),
          required: true,
        ),
        
        const SizedBox(height: 12),
        _buildTextField(controller: _philJobNetIdController, hintText: 'PhilJobNet Registration ID', validator: (v) => v?.isEmpty == true ? 'Required' : null),

        const SizedBox(height: 24),
        _buildSectionTitle('Vacancy Information'),
        const SizedBox(height: 12),
        _buildDropdownField(value: _selectedEmployerType, hint: 'Select Employer Type', items: _employerTypes, onChanged: (v) => setState(() => _selectedEmployerType = v), validator: (v) => v == null ? 'Please select employer type' : null),
        const SizedBox(height: 12),
        _buildFileUploadField(
          label: '7. List of Vacancies (Optional)',
          file: _vacanciesListFile,
          onTap: () => _pickFile('vacanciesList'),
          required: false,
        ),
        _buildTextField(controller: _vacanciesController, hintText: 'Or describe vacancies here (Job titles, positions)', maxLines: 3),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade700));
  }

  Widget _buildFileUploadField({
    required String label,
    required PlatformFile? file,
    required VoidCallback onTap,
    required bool required,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
              if (required) Text(' *', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: file != null ? Colors.green.shade400 : Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  Icon(
                    file != null ? Icons.check_circle : Icons.upload_file,
                    color: file != null ? Colors.green.shade600 : Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      file?.name ?? 'Click to upload file',
                      style: TextStyle(
                        color: file != null ? Colors.black87 : Colors.grey.shade600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (file != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // Clear the file based on label
                          if (label.contains('Letter of Intent')) _letterOfIntentFile = null;
                          if (label.contains('PESO Establishment')) _pesoFormFile = null;
                          if (label.contains('BIR')) _birCertificateFile = null;
                          if (label.contains('Business Permit')) _businessPermitFile = null;
                          if (label.contains('License Document')) _licenseFile = null;
                          if (label.contains('PhilJobNet')) _philJobNetProofFile = null;
                          if (label.contains('Vacancies')) _vacanciesListFile = null;
                        });
                      },
                      child: Icon(Icons.close, color: Colors.red.shade400, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText && !isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: isPassword
            ? IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[700]), onPressed: onToggleVisibility)
            : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _isLoading ? null : _signUp,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isLoading ? Colors.grey : (_isHovering ? Colors.blue.shade800 : Colors.blue.shade700),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _userType == 'jobseeker' ? 'Register' : 'Submit Application',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?', style: TextStyle(fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: widget.showLoginPage,
          child: const Text('  Login', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}