// lib/jobseeker_update_page.dart
// Edit/Update existing jobseeker registration - loads data from Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:peso_makati_website_application/widgets/jobseeker_form_data.dart';
import 'package:peso_makati_website_application/widgets/jobseeker_form_widget.dart';

import 'widgets/plus_sign_painter.dart';
import 'main_homepage.dart';

class JobseekerUpdatePage extends StatefulWidget {
  const JobseekerUpdatePage({Key? key}) : super(key: key);

  @override
  State<JobseekerUpdatePage> createState() => _JobseekerUpdatePageState();
}

class _JobseekerUpdatePageState extends State<JobseekerUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _errorMessage;

  late JobseekerFormData _formData;

  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Personal Info',
    'Employment',
    'Preferences',
    'Education',
    'Skills',
  ];

  @override
  void initState() {
    super.initState();
    _formData = JobseekerFormData();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not signed in.';
        });
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('forms')
          .doc('jobseeker_registration');

      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        _formData = JobseekerFormData.fromFirestore(snapshot.data()!);
      } else {
        // No existing data - still allow editing with empty form
        _formData = JobseekerFormData(email: user.email ?? '');
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not signed in.')),
        );
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('forms')
          .doc('jobseeker_registration');

      await docRef.set(_formData.toFirestore(user.uid), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _formData.dateOfBirth ?? DateTime(now.year - 20);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _formData.dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return MainScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgimage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background
              Container(
                width: 650,
                height: screenH,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(painter: const PlusSignPainter()),
              ),

              // Content
              if (_isLoading)
                _buildLoadingState()
              else if (_errorMessage != null)
                _buildErrorState()
              else
                _buildFormContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your profile...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadExistingData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Container(
        width: kIsWeb ? 900 : double.infinity,
        constraints: const BoxConstraints(maxWidth: 900),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const Expanded(
                    child: JobseekerFormHeader(
                      subtitle: 'UPDATE YOUR PROFILE',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Step indicator
              _buildStepIndicator(),
              const SizedBox(height: 16),

              // Current step content
              _buildCurrentStep(),

              const SizedBox(height: 20),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _currentStep;

          return GestureDetector(
            onTap: () => setState(() => _currentStep = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.orange.shade600 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${index + 1}. ${_stepTitles[index]}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildEmploymentStep();
      case 2:
        return _buildPreferencesStep();
      case 3:
        return _buildEducationStep();
      case 4:
        return _buildSkillsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('I. PERSONAL INFORMATION'),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'Surname',
              label: 'SURNAME *',
              width: 200,
              initialValue: _formData.surname,
              onChanged: (v) => _formData.surname = v,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            CompactTextField(
              hint: 'First Name',
              label: 'FIRST NAME *',
              width: 200,
              initialValue: _formData.firstName,
              onChanged: (v) => _formData.firstName = v,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            CompactTextField(
              hint: 'Middle Name',
              label: 'MIDDLE NAME',
              width: 200,
              initialValue: _formData.middleName,
              onChanged: (v) => _formData.middleName = v,
            ),
            CompactTextField(
              hint: 'Suffix',
              label: 'SUFFIX',
              width: 100,
              initialValue: _formData.suffix,
              onChanged: (v) => _formData.suffix = v,
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: CompactTextField(
                  hint: 'Date of Birth',
                  label: 'DATE OF BIRTH',
                  width: 180,
                  initialValue: _formData.dateOfBirth != null
                      ? '${_formData.dateOfBirth!.year}-${_formData.dateOfBirth!.month.toString().padLeft(2, '0')}-${_formData.dateOfBirth!.day.toString().padLeft(2, '0')}'
                      : '',
                  readOnly: true,
                ),
              ),
            ),
            CompactTextField(
              hint: 'Place of Birth',
              label: 'PLACE OF BIRTH',
              width: 250,
              initialValue: _formData.placeOfBirth,
              onChanged: (v) => _formData.placeOfBirth = v,
            ),
            CompactDropdown<String>(
              label: 'SEX',
              items: const ['Male', 'Female', 'Other'],
              value: _formData.sex,
              onChanged: (v) => setState(() => _formData.sex = v),
              width: 120,
            ),
            CompactDropdown<String>(
              label: 'CIVIL STATUS',
              items: const ['Single', 'Married', 'Widowed', 'Separated'],
              value: _formData.civilStatus,
              onChanged: (v) => setState(() => _formData.civilStatus = v),
              width: 140,
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'Religion',
              label: 'RELIGION',
              width: 150,
              initialValue: _formData.religion,
              onChanged: (v) => _formData.religion = v,
            ),
            CompactTextField(
              hint: 'Height (ft)',
              label: 'HEIGHT',
              width: 100,
              initialValue: _formData.heightFt,
              onChanged: (v) => _formData.heightFt = v,
            ),
            CompactTextField(
              hint: 'Disability (if any)',
              label: 'DISABILITY',
              width: 200,
              initialValue: _formData.disability,
              onChanged: (v) => _formData.disability = v,
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'Contact Number',
              label: 'CONTACT NUMBER *',
              width: 200,
              initialValue: _formData.contactNumbers,
              onChanged: (v) => _formData.contactNumbers = v,
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            CompactTextField(
              hint: 'Email',
              label: 'EMAIL *',
              width: 250,
              initialValue: _formData.email,
              onChanged: (v) => _formData.email = v,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            CompactTextField(
              hint: 'TIN',
              label: 'TIN',
              width: 150,
              initialValue: _formData.tin,
              onChanged: (v) => _formData.tin = v,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Parents
        const Text("PARENT'S INFORMATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: "Father's Name",
              width: 280,
              initialValue: _formData.fatherName,
              onChanged: (v) => _formData.fatherName = v,
            ),
            CompactTextField(
              hint: "Mother's Name",
              width: 280,
              initialValue: _formData.motherName,
              onChanged: (v) => _formData.motherName = v,
            ),
            CompactTextField(
              hint: "Mother's Maiden Name",
              width: 280,
              initialValue: _formData.motherMaidenName,
              onChanged: (v) => _formData.motherMaidenName = v,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Address
        const Text('PRESENT ADDRESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'House No. / Street',
              width: 200,
              initialValue: _formData.houseNoStreet,
              onChanged: (v) => _formData.houseNoStreet = v,
            ),
            CompactTextField(
              hint: 'Village',
              width: 150,
              initialValue: _formData.village,
              onChanged: (v) => _formData.village = v,
            ),
            CompactTextField(
              hint: 'Barangay',
              width: 150,
              initialValue: _formData.barangay,
              onChanged: (v) => _formData.barangay = v,
            ),
            CompactTextField(
              hint: 'Municipality/City',
              width: 180,
              initialValue: _formData.municipalityCity,
              onChanged: (v) => _formData.municipalityCity = v,
            ),
            CompactTextField(
              hint: 'Province',
              width: 150,
              initialValue: _formData.province,
              onChanged: (v) => _formData.province = v,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmploymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('EMPLOYMENT STATUS'),

        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            EmploymentRadio(
              title: 'Employed',
              value: 'Employed',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
            EmploymentRadio(
              title: 'Unemployed',
              value: 'Unemployed',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
            EmploymentRadio(
              title: 'New Entrant',
              value: 'New Entrant/Fresh Graduate',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
            EmploymentRadio(
              title: 'Terminated (local)',
              value: 'Terminated/Laid off (local)',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
            EmploymentRadio(
              title: 'Terminated (abroad)',
              value: 'Terminated/Laid off (abroad)',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
            EmploymentRadio(
              title: 'Resigned',
              value: 'Resigned',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
            EmploymentRadio(
              title: 'Retired',
              value: 'Retired',
              groupValue: _formData.employmentStatus,
              onChanged: (v) => setState(() => _formData.employmentStatus = v),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'How long looking for work? (months)',
              width: 280,
              initialValue: _formData.howLongLookingMonths,
              onChanged: (v) => _formData.howLongLookingMonths = v,
              keyboardType: TextInputType.number,
            ),
            CompactTextField(
              hint: 'Employment type detail',
              width: 280,
              initialValue: _formData.employmentTypeDetail,
              onChanged: (v) => _formData.employmentTypeDetail = v,
            ),
          ],
        ),
        const SizedBox(height: 16),

        LabeledCheckbox(
          label: 'Are you an OFW?',
          value: _formData.isOFW,
          onChanged: (v) => setState(() => _formData.isOFW = v),
        ),
        if (_formData.isOFW) ...[
          const SizedBox(height: 8),
          CompactTextField(
            hint: 'Specify country',
            width: 250,
            initialValue: _formData.ofwCountry,
            onChanged: (v) => _formData.ofwCountry = v,
          ),
        ],
        const SizedBox(height: 12),

        LabeledCheckbox(
          label: 'Are you a former OFW?',
          value: _formData.isFormerOFW,
          onChanged: (v) => setState(() => _formData.isFormerOFW = v),
        ),
        if (_formData.isFormerOFW) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CompactTextField(
                hint: 'Latest country of deployment',
                width: 250,
                initialValue: _formData.latestCountryOfDeployment,
                onChanged: (v) => _formData.latestCountryOfDeployment = v,
              ),
              CompactTextField(
                hint: 'Month/Year of return',
                width: 180,
                initialValue: _formData.monthYearReturn,
                onChanged: (v) => _formData.monthYearReturn = v,
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        LabeledCheckbox(
          label: 'Are you a 4Ps beneficiary?',
          value: _formData.is4Ps,
          onChanged: (v) => setState(() => _formData.is4Ps = v),
        ),
        if (_formData.is4Ps) ...[
          const SizedBox(height: 8),
          CompactTextField(
            hint: 'Household ID No.',
            width: 250,
            initialValue: _formData.householdIdNo,
            onChanged: (v) => _formData.householdIdNo = v,
          ),
        ],
      ],
    );
  }

  Widget _buildPreferencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('II. JOB PREFERENCES'),

        for (int i = 0; i < 3; i++) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CompactTextField(
                hint: 'Preferred Occupation ${i + 1}',
                width: 350,
                initialValue: _formData.preferredOccupations[i],
                onChanged: (v) => _formData.preferredOccupations[i] = v,
              ),
              CompactTextField(
                hint: 'Preferred Location ${i + 1}',
                width: 300,
                initialValue: _formData.preferredWorkLocations[i],
                onChanged: (v) => _formData.preferredWorkLocations[i] = v,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),
        const FormSectionTitle('III. LANGUAGE PROFICIENCY'),

        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(width: 100),
              SizedBox(width: 70, child: Text('Read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              SizedBox(width: 70, child: Text('Write', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              SizedBox(width: 70, child: Text('Speak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              SizedBox(width: 90, child: Text('Understand', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        for (final lang in ['English', 'Filipino', 'Mandarin', 'Others'])
          LanguageRow(
            language: lang,
            proficiency: _formData.languageProficiency[lang]!,
            onChanged: (v) => setState(() => _formData.languageProficiency[lang] = v),
          ),

        if (_formData.languageProficiency['Others']!.values.any((v) => v)) ...[
          const SizedBox(height: 8),
          CompactTextField(
            hint: 'Specify other language',
            width: 250,
            initialValue: _formData.languagesOtherText,
            onChanged: (v) => _formData.languagesOtherText = v,
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            LabeledCheckbox(
              label: 'Part-time',
              value: _formData.partTime,
              onChanged: (v) => setState(() => _formData.partTime = v),
            ),
            const SizedBox(width: 20),
            LabeledCheckbox(
              label: 'Full-time',
              value: _formData.fullTime,
              onChanged: (v) => setState(() => _formData.fullTime = v),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'Local work locations (cities)',
              width: 350,
              initialValue: _formData.localWorkLocations,
              onChanged: (v) => _formData.localWorkLocations = v,
            ),
            CompactTextField(
              hint: 'Overseas countries',
              width: 300,
              initialValue: _formData.overseasCountries,
              onChanged: (v) => _formData.overseasCountries = v,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('IV. EDUCATIONAL BACKGROUND'),

        LabeledCheckbox(
          label: 'Currently in school?',
          value: _formData.currentlyInSchool,
          onChanged: (v) => setState(() => _formData.currentlyInSchool = v),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            CompactTextField(
              hint: 'Elementary',
              label: 'ELEMENTARY',
              width: 400,
              initialValue: _formData.elementary,
              onChanged: (v) => _formData.elementary = v,
            ),
            CompactTextField(
              hint: 'Secondary',
              label: 'SECONDARY',
              width: 400,
              initialValue: _formData.secondary,
              onChanged: (v) => _formData.secondary = v,
            ),
            CompactTextField(
              hint: 'Senior High Strand',
              label: 'SENIOR HIGH',
              width: 300,
              initialValue: _formData.seniorHighStrand,
              onChanged: (v) => _formData.seniorHighStrand = v,
            ),
            CompactTextField(
              hint: 'Tertiary - Course/School',
              label: 'TERTIARY',
              width: 400,
              initialValue: _formData.tertiary,
              onChanged: (v) => _formData.tertiary = v,
            ),
            CompactTextField(
              hint: 'Graduate Studies',
              label: 'GRADUATE STUDIES',
              width: 400,
              initialValue: _formData.graduateStudies,
              onChanged: (v) => _formData.graduateStudies = v,
            ),
          ],
        ),

        const SizedBox(height: 20),
        const FormSectionTitle('V. TRAININGS'),

        for (int i = 0; i < 3; i++) ...[
          Text('Training ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CompactTextField(
                hint: 'Course/Training',
                width: 200,
                initialValue: _formData.trainings[i].course,
                onChanged: (v) => _formData.trainings[i].course = v,
              ),
              CompactTextField(
                hint: 'Institution',
                width: 180,
                initialValue: _formData.trainings[i].institution,
                onChanged: (v) => _formData.trainings[i].institution = v,
              ),
              CompactTextField(
                hint: 'Hours',
                width: 70,
                initialValue: _formData.trainings[i].hours,
                onChanged: (v) => _formData.trainings[i].hours = v,
              ),
              CompactTextField(
                hint: 'Skills Acquired',
                width: 180,
                initialValue: _formData.trainings[i].skillsAcquired,
                onChanged: (v) => _formData.trainings[i].skillsAcquired = v,
              ),
              CompactTextField(
                hint: 'Certificate',
                width: 120,
                initialValue: _formData.trainings[i].certificate,
                onChanged: (v) => _formData.trainings[i].certificate = v,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 16),
        const FormSectionTitle('VI. ELIGIBILITY / LICENSE'),

        for (int i = 0; i < 2; i++) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CompactTextField(
                hint: 'Eligibility ${i + 1}',
                width: 200,
                initialValue: _formData.eligibilities[i].eligibility,
                onChanged: (v) => _formData.eligibilities[i].eligibility = v,
              ),
              CompactTextField(
                hint: 'Date Taken',
                width: 120,
                initialValue: _formData.eligibilities[i].dateTaken,
                onChanged: (v) => _formData.eligibilities[i].dateTaken = v,
              ),
              CompactTextField(
                hint: 'Prof. License ${i + 1}',
                width: 200,
                initialValue: _formData.professionalLicenses[i].license,
                onChanged: (v) => _formData.professionalLicenses[i].license = v,
              ),
              CompactTextField(
                hint: 'Valid Until',
                width: 120,
                initialValue: _formData.professionalLicenses[i].validUntil,
                onChanged: (v) => _formData.professionalLicenses[i].validUntil = v,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSkillsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('VII. WORK EXPERIENCE'),

        for (int i = 0; i < 3; i++) ...[
          Text('Experience ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CompactTextField(
                hint: 'Company Name',
                width: 200,
                initialValue: _formData.workExperiences[i].companyName,
                onChanged: (v) => _formData.workExperiences[i].companyName = v,
              ),
              CompactTextField(
                hint: 'Address',
                width: 200,
                initialValue: _formData.workExperiences[i].companyAddress,
                onChanged: (v) => _formData.workExperiences[i].companyAddress = v,
              ),
              CompactTextField(
                hint: 'Position',
                width: 150,
                initialValue: _formData.workExperiences[i].position,
                onChanged: (v) => _formData.workExperiences[i].position = v,
              ),
              CompactTextField(
                hint: 'Months',
                width: 70,
                initialValue: _formData.workExperiences[i].months,
                onChanged: (v) => _formData.workExperiences[i].months = v,
              ),
              CompactTextField(
                hint: 'Status',
                width: 150,
                initialValue: _formData.workExperiences[i].status,
                onChanged: (v) => _formData.workExperiences[i].status = v,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 16),
        const FormSectionTitle('VIII. OTHER SKILLS'),

        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: _formData.otherSkills.keys.map((skill) {
            return SkillCheckbox(
              skill: skill,
              value: _formData.otherSkills[skill]!,
              onChanged: (v) => setState(() => _formData.otherSkills[skill] = v),
            );
          }).toList(),
        ),

        if (_formData.otherSkills['Others'] == true) ...[
          const SizedBox(height: 12),
          CompactTextField(
            hint: 'Please specify other skills',
            width: 400,
            initialValue: _formData.otherSkillsOtherText,
            onChanged: (v) => _formData.otherSkillsOtherText = v,
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton.icon(
            onPressed: () => setState(() => _currentStep--),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          )
        else
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),

        Row(
          children: [
            if (_currentStep < _stepTitles.length - 1) ...[
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentStep++),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _saveChanges,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSubmitting ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}