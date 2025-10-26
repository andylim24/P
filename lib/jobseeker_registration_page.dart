// lib/jobseeker_registration_page.dart
//
// Complete Jobseeker Registration Form page for Flutter (web-friendly).
// - Mirrors the NSRP Jobseeker Registration Form (I - VIII) (no signature / date).
// - Auto-populates name & email from FirebaseAuth on first open.
// - Supports "edit mode" (loads existing data from Firestore & lets user save changes).
// - Saves to Firestore at: users/{uid}/forms/jobseeker_registration (merge:true).
// - Includes date picker for DOB, lightweight validation, compact web-friendly layout.
//
// Usage:
//   // From RegisterPage after signup:
//   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JobseekerRegistrationPage(isEditMode: false)));
//   // From popup menu (edit mode):
//   Navigator.push(context, MaterialPageRoute(builder: (_) => const JobseekerRegistrationPage(isEditMode: true)));
//
// NOTE: Adjust imports/paths to HomePage and your project structure as needed.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_homepage.dart';

class JobseekerRegistrationPage extends StatefulWidget {
  final bool isEditMode;
  const JobseekerRegistrationPage({Key? key, this.isEditMode = false}) : super(key: key);

  @override
  State<JobseekerRegistrationPage> createState() => _JobseekerRegistrationPageState();
}

class _JobseekerRegistrationPageState extends State<JobseekerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _loadingExisting = false;

  // --------------------------
  // Personal Information fields
  // --------------------------
  final _surnameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _suffixCtrl = TextEditingController();
  DateTime? _dob;
  final _dobCtrl = TextEditingController(); // human-readable
  final _placeOfBirthCtrl = TextEditingController();
  String? _sex; // 'Male' / 'Female' / other
  final _religionCtrl = TextEditingController();
  String? _civilStatus; // Single/Married/Widowed/Separated
  final _tinCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _disabilityCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Parents
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _motherMaidenCtrl = TextEditingController();

  // Present address (structured)
  final _houseNoStreetCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _barangayCtrl = TextEditingController();
  final _municipalityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();

  // --------------------------
  // Employment status / type
  // --------------------------
  String? _employmentStatus; // Employed / Unemployed / New Entrant / Terminated local / Terminated abroad / Resigned / Retired
  final _howLongLookingCtrl = TextEditingController(); // months
  final _employmentTypeDetailCtrl = TextEditingController(); // free text for "self-employed specify" etc.

  // OFW / 4Ps
  bool _isOFW = false;
  final _ofwCountryCtrl = TextEditingController();
  bool _isFormerOFW = false;
  final _latestCountryDeploymentCtrl = TextEditingController();
  final _monthYearReturnCtrl = TextEditingController();
  bool _is4Ps = false;
  final _householdIdCtrl = TextEditingController();

  // --------------------------
  // Job Preferences (3 rows)
  // --------------------------
  final List<TextEditingController> _prefOccupationCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _prefLocationCtrls = List.generate(3, (_) => TextEditingController());

  // --------------------------
  // Language / Dialect proficiency
  // --------------------------
  // map: language -> map of proficiency flags
  final Map<String, Map<String, bool>> _languages = {
    'English': {'read': false, 'write': false, 'speak': false, 'understand': false},
    'Filipino': {'read': false, 'write': false, 'speak': false, 'understand': false},
    'Mandarin': {'read': false, 'write': false, 'speak': false, 'understand': false},
    'Others': {'read': false, 'write': false, 'speak': false, 'understand': false},
  };
  final _languagesOtherCtrl = TextEditingController();

  // Work type preferences
  bool _partTime = false;
  bool _fullTime = false;
  final _localWorkLocationsCtrl = TextEditingController();
  final _overseasCountriesCtrl = TextEditingController();

  // --------------------------
  // Education
  // --------------------------
  bool _currentlyInSchool = false;
  final _elementaryCtrl = TextEditingController(); // Course/Year/Graduated
  final _secondaryCtrl = TextEditingController(); // Course/Year/Undergraduate/Year last attended
  final _seniorHighStrandCtrl = TextEditingController();
  final _tertiaryCtrl = TextEditingController();
  final _graduateStudiesCtrl = TextEditingController();

  // --------------------------
  // Training (up to 3)
  // --------------------------
  final List<TextEditingController> _trainingCourseCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _trainingHoursCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _trainingInstitutionCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _trainingSkillsCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _trainingCertCtrls = List.generate(3, (_) => TextEditingController());

  // --------------------------
  // Eligibility / License (up to 2)
  // --------------------------
  final List<TextEditingController> _eligibilityCtrls = List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _eligibilityDateCtrls = List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _profLicenseCtrls = List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _profLicenseValidUntilCtrls = List.generate(2, (_) => TextEditingController());

  // --------------------------
  // Work Experience (up to 3)
  // --------------------------
  final List<TextEditingController> _companyNameCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _companyAddressCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _positionCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _monthsCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _statusCtrls = List.generate(3, (_) => TextEditingController());

  // --------------------------
  // Other skills
  // --------------------------
  final Map<String, bool> _otherSkills = {
    'Auto Mechanic': false,
    'Electrician': false,
    'Photography': false,
    'Beautician': false,
    'Embroidery': false,
    'Plumbing': false,
    'Carpentry Work': false,
    'Gardening': false,
    'Sewing Dresses': false,
    'Computer Literate': false,
    'Masonry': false,
    'Stenography': false,
    'Domestic Chores': false,
    'Painter/Artist': false,
    'Tailoring': false,
    'Driver': false,
    'Painting Jobs': false,
    'Others': false,
  };
  final _otherSkillsOtherCtrl = TextEditingController();

  // --------------------------
  // UI / Styling small field decoration (web-friendly)
  // --------------------------
  InputDecoration get _compactInputDecoration => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: Colors.grey.shade100,
  );

  @override
  void initState() {
    super.initState();
    _autoFillFromAuth();
    if (widget.isEditMode) _loadExistingData();
  }

  @override
  void dispose() {
    // dispose all controllers
    _surnameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _suffixCtrl.dispose();
    _dobCtrl.dispose();
    _placeOfBirthCtrl.dispose();
    _religionCtrl.dispose();
    _tinCtrl.dispose();
    _heightCtrl.dispose();
    _disabilityCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _motherMaidenCtrl.dispose();
    _houseNoStreetCtrl.dispose();
    _villageCtrl.dispose();
    _barangayCtrl.dispose();
    _municipalityCtrl.dispose();
    _provinceCtrl.dispose();
    _howLongLookingCtrl.dispose();
    _employmentTypeDetailCtrl.dispose();
    _ofwCountryCtrl.dispose();
    _latestCountryDeploymentCtrl.dispose();
    _monthYearReturnCtrl.dispose();
    _householdIdCtrl.dispose();
    for (final c in _prefOccupationCtrls) c.dispose();
    for (final c in _prefLocationCtrls) c.dispose();
    _languagesOtherCtrl.dispose();
    _localWorkLocationsCtrl.dispose();
    _overseasCountriesCtrl.dispose();
    _elementaryCtrl.dispose();
    _secondaryCtrl.dispose();
    _seniorHighStrandCtrl.dispose();
    _tertiaryCtrl.dispose();
    _graduateStudiesCtrl.dispose();
    for (final c in _trainingCourseCtrls) c.dispose();
    for (final c in _trainingHoursCtrls) c.dispose();
    for (final c in _trainingInstitutionCtrls) c.dispose();
    for (final c in _trainingSkillsCtrls) c.dispose();
    for (final c in _trainingCertCtrls) c.dispose();
    for (final c in _eligibilityCtrls) c.dispose();
    for (final c in _eligibilityDateCtrls) c.dispose();
    for (final c in _profLicenseCtrls) c.dispose();
    for (final c in _profLicenseValidUntilCtrls) c.dispose();
    for (final c in _companyNameCtrls) c.dispose();
    for (final c in _companyAddressCtrls) c.dispose();
    for (final c in _positionCtrls) c.dispose();
    for (final c in _monthsCtrls) c.dispose();
    for (final c in _statusCtrls) c.dispose();
    _otherSkillsOtherCtrl.dispose();
    super.dispose();
  }

  // --------------------------
  // Auto-fill name & email from FirebaseAuth for convenience
  // --------------------------
  Future<void> _autoFillFromAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!widget.isEditMode) {
      // Only auto-fill when not editing existing (first time)
      final displayName = user.displayName ?? '';
      if (displayName.isNotEmpty) {
        final parts = displayName.trim().split(' ');
        if (parts.length == 1) {
          _firstNameCtrl.text = parts[0];
        } else if (parts.length >= 2) {
          _firstNameCtrl.text = parts.first;
          _surnameCtrl.text = parts.last;
          if (parts.length > 2) {
            _middleNameCtrl.text = parts.sublist(1, parts.length - 1).join(' ');
          }
        }
      }
      _emailCtrl.text = user.email ?? '';
    }
  }

  // --------------------------
  // Load existing data when in edit mode
  // --------------------------
  Future<void> _loadExistingData() async {
    setState(() => _loadingExisting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('forms')
          .doc('jobseeker_registration');
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      // personal info
      _surnameCtrl.text = data['surname'] ?? '';
      _firstNameCtrl.text = data['firstName'] ?? '';
      _middleNameCtrl.text = data['middleName'] ?? '';
      _suffixCtrl.text = data['suffix'] ?? '';
      _dobCtrl.text = data['dateOfBirth'] ?? '';
      if ((data['dateOfBirth'] ?? '').isNotEmpty) {
        try {
          _dob = DateTime.parse(data['dateOfBirth']);
        } catch (_) {
          _dob = null;
        }
      }
      _placeOfBirthCtrl.text = data['placeOfBirth'] ?? '';
      _sex = data['sex'];
      _religionCtrl.text = data['religion'] ?? '';
      _civilStatus = data['civilStatus'];
      _tinCtrl.text = data['tin'] ?? '';
      _heightCtrl.text = data['heightFt'] ?? '';
      _disabilityCtrl.text = data['disability'] ?? '';
      _contactCtrl.text = data['contactNumbers'] ?? '';
      _emailCtrl.text = data['email'] ?? '';

      _fatherNameCtrl.text = data['fatherName'] ?? '';
      _motherNameCtrl.text = data['motherName'] ?? '';
      _motherMaidenCtrl.text = data['motherMaidenName'] ?? '';

      final presentAddress = data['presentAddress'] ?? {};
      _houseNoStreetCtrl.text = presentAddress['houseNoStreet'] ?? '';
      _villageCtrl.text = presentAddress['village'] ?? '';
      _barangayCtrl.text = presentAddress['barangay'] ?? '';
      _municipalityCtrl.text = presentAddress['municipalityCity'] ?? '';
      _provinceCtrl.text = presentAddress['province'] ?? '';

      // employment
      _employmentStatus = data['employmentStatus'] ?? '';
      _employmentTypeDetailCtrl.text = data['employmentTypeDetail'] ?? '';
      _howLongLookingCtrl.text = data['howLongLookingMonths'] ?? '';
      _isOFW = data['isOFW'] ?? false;
      _ofwCountryCtrl.text = data['ofwCountry'] ?? '';
      _isFormerOFW = data['isFormerOFW'] ?? false;
      _latestCountryDeploymentCtrl.text = data['latestCountryOfDeployment'] ?? '';
      _monthYearReturnCtrl.text = data['monthYearReturn'] ?? '';
      _is4Ps = data['is4Ps'] ?? false;
      _householdIdCtrl.text = data['householdIdNo'] ?? '';

      // preferences
      final prefsOcc = List<String>.from((data['preferredOccupations'] ?? []) as List<dynamic>);
      final prefsLoc = List<String>.from((data['preferredWorkLocations'] ?? []) as List<dynamic>);
      for (int i = 0; i < 3; i++) {
        _prefOccupationCtrls[i].text = i < prefsOcc.length ? prefsOcc[i] : '';
        _prefLocationCtrls[i].text = i < prefsLoc.length ? prefsLoc[i] : '';
      }

      // languages
      final langMap = (data['languageProficiency'] ?? {}) as Map<String, dynamic>;
      if (langMap.isNotEmpty) {
        for (final k in _languages.keys) {
          final d = langMap[k] as Map<String, dynamic>?;
          if (d != null) {
            _languages[k]?['read'] = d['read'] ?? false;
            _languages[k]?['write'] = d['write'] ?? false;
            _languages[k]?['speak'] = d['speak'] ?? false;
            _languages[k]?['understand'] = d['understand'] ?? false;
          }
        }
      }
      _languagesOtherCtrl.text = data['languagesOtherText'] ?? '';
      _partTime = data['partTime'] ?? false;
      _fullTime = data['fullTime'] ?? false;
      _localWorkLocationsCtrl.text = data['localWorkLocations'] ?? '';
      _overseasCountriesCtrl.text = data['overseasCountries'] ?? '';

      // education
      _currentlyInSchool = data['currentlyInSchool'] ?? false;
      _elementaryCtrl.text = data['elementary'] ?? '';
      _secondaryCtrl.text = data['secondary'] ?? '';
      _seniorHighStrandCtrl.text = data['seniorHighStrand'] ?? '';
      _tertiaryCtrl.text = data['tertiary'] ?? '';
      _graduateStudiesCtrl.text = data['graduateStudies'] ?? '';

      // trainings
      final trainings = List<Map<String, dynamic>>.from((data['trainings'] ?? []) as List<dynamic>);
      for (int i = 0; i < trainings.length && i < 3; i++) {
        _trainingCourseCtrls[i].text = trainings[i]['course'] ?? '';
        _trainingHoursCtrls[i].text = trainings[i]['hours'] ?? '';
        _trainingInstitutionCtrls[i].text = trainings[i]['institution'] ?? '';
        _trainingSkillsCtrls[i].text = trainings[i]['skillsAcquired'] ?? '';
        _trainingCertCtrls[i].text = trainings[i]['certificate'] ?? '';
      }

      // eligibilities
      final eligs = List<Map<String, dynamic>>.from((data['eligibilities'] ?? []) as List<dynamic>);
      for (int i = 0; i < eligs.length && i < 2; i++) {
        _eligibilityCtrls[i].text = eligs[i]['eligibility'] ?? '';
        _eligibilityDateCtrls[i].text = eligs[i]['dateTaken'] ?? '';
      }
      final profLic = List<Map<String, dynamic>>.from((data['professionalLicenses'] ?? []) as List<dynamic>);
      for (int i = 0; i < profLic.length && i < 2; i++) {
        _profLicenseCtrls[i].text = profLic[i]['license'] ?? '';
        _profLicenseValidUntilCtrls[i].text = profLic[i]['validUntil'] ?? '';
      }

      // work experience
      final experiences = List<Map<String, dynamic>>.from((data['workExperiences'] ?? []) as List<dynamic>);
      for (int i = 0; i < experiences.length && i < 3; i++) {
        _companyNameCtrls[i].text = experiences[i]['companyName'] ?? '';
        _companyAddressCtrls[i].text = experiences[i]['companyAddress'] ?? '';
        _positionCtrls[i].text = experiences[i]['position'] ?? '';
        _monthsCtrls[i].text = experiences[i]['months'] ?? '';
        _statusCtrls[i].text = experiences[i]['status'] ?? '';
      }

      // other skills
      final otherSkillsMap = (data['otherSkills'] ?? {}) as Map<String, dynamic>;
      if (otherSkillsMap.isNotEmpty) {
        for (final entry in _otherSkills.keys) {
          if (otherSkillsMap.containsKey(entry)) {
            _otherSkills[entry] = otherSkillsMap[entry] ?? false;
          }
        }
      }
      _otherSkillsOtherCtrl.text = data['otherSkillsOtherText'] ?? '';
    } catch (e) {
      debugPrint('Error loading jobseeker data: $e');
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  // --------------------------
  // Date picker for DOB
  // --------------------------
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobCtrl.text = "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // --------------------------
  // Submit/save
  // --------------------------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // show a small snackbar and return
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix validation errors.')));
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not signed in.')));
        return;
      }

      // Prepare data map consistent with earlier structure
      final Map<String, dynamic> payload = {
        // I. personal
        'surname': _surnameCtrl.text.trim(),
        'firstName': _firstNameCtrl.text.trim(),
        'middleName': _middleNameCtrl.text.trim(),
        'suffix': _suffixCtrl.text.trim(),
        'dateOfBirth': _dob != null ? _dob!.toIso8601String() : _dobCtrl.text.trim(),
        'placeOfBirth': _placeOfBirthCtrl.text.trim(),
        'sex': _sex ?? '',
        'religion': _religionCtrl.text.trim(),
        'civilStatus': _civilStatus ?? '',
        'tin': _tinCtrl.text.trim(),
        'heightFt': _heightCtrl.text.trim(),
        'disability': _disabilityCtrl.text.trim(),
        'contactNumbers': _contactCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'fatherName': _fatherNameCtrl.text.trim(),
        'motherName': _motherNameCtrl.text.trim(),
        'motherMaidenName': _motherMaidenCtrl.text.trim(),
        'presentAddress': {
          'houseNoStreet': _houseNoStreetCtrl.text.trim(),
          'village': _villageCtrl.text.trim(),
          'barangay': _barangayCtrl.text.trim(),
          'municipalityCity': _municipalityCtrl.text.trim(),
          'province': _provinceCtrl.text.trim(),
        },

        // Employment
        'employmentStatus': _employmentStatus ?? '',
        'employmentTypeDetail': _employmentTypeDetailCtrl.text.trim(),
        'howLongLookingMonths': _howLongLookingCtrl.text.trim(),
        'isOFW': _isOFW,
        'ofwCountry': _ofwCountryCtrl.text.trim(),
        'isFormerOFW': _isFormerOFW,
        'latestCountryOfDeployment': _latestCountryDeploymentCtrl.text.trim(),
        'monthYearReturn': _monthYearReturnCtrl.text.trim(),
        'is4Ps': _is4Ps,
        'householdIdNo': _householdIdCtrl.text.trim(),

        // II. job preference
        'preferredOccupations': _prefOccupationCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        'preferredWorkLocations': _prefLocationCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),

        // III. languages
        'languageProficiency': {
          for (final entry in _languages.entries)
            entry.key: {
              'read': entry.value['read'] ?? false,
              'write': entry.value['write'] ?? false,
              'speak': entry.value['speak'] ?? false,
              'understand': entry.value['understand'] ?? false,
            }
        },
        'languagesOtherText': _languagesOtherCtrl.text.trim(),
        'partTime': _partTime,
        'fullTime': _fullTime,
        'localWorkLocations': _localWorkLocationsCtrl.text.trim(),
        'overseasCountries': _overseasCountriesCtrl.text.trim(),

        // IV. education
        'currentlyInSchool': _currentlyInSchool,
        'elementary': _elementaryCtrl.text.trim(),
        'secondary': _secondaryCtrl.text.trim(),
        'seniorHighStrand': _seniorHighStrandCtrl.text.trim(),
        'tertiary': _tertiaryCtrl.text.trim(),
        'graduateStudies': _graduateStudiesCtrl.text.trim(),

        // V. training
        'trainings': List.generate(3, (i) {
          return {
            'course': _trainingCourseCtrls[i].text.trim(),
            'hours': _trainingHoursCtrls[i].text.trim(),
            'institution': _trainingInstitutionCtrls[i].text.trim(),
            'skillsAcquired': _trainingSkillsCtrls[i].text.trim(),
            'certificate': _trainingCertCtrls[i].text.trim(),
          };
        }).where((t) => (t['course'] as String).isNotEmpty).toList(),

        // VI. eligibilities and professional licenses
        'eligibilities': List.generate(2, (i) {
          return {
            'eligibility': _eligibilityCtrls[i].text.trim(),
            'dateTaken': _eligibilityDateCtrls[i].text.trim(),
          };
        }).where((e) => (e['eligibility'] as String).isNotEmpty).toList(),
        'professionalLicenses': List.generate(2, (i) {
          return {
            'license': _profLicenseCtrls[i].text.trim(),
            'validUntil': _profLicenseValidUntilCtrls[i].text.trim(),
          };
        }).where((p) => (p['license'] as String).isNotEmpty).toList(),

        // VII. work experience
        'workExperiences': List.generate(3, (i) {
          return {
            'companyName': _companyNameCtrls[i].text.trim(),
            'companyAddress': _companyAddressCtrls[i].text.trim(),
            'position': _positionCtrls[i].text.trim(),
            'months': _monthsCtrls[i].text.trim(),
            'status': _statusCtrls[i].text.trim(),
          };
        }).where((w) => (w['companyName'] as String).isNotEmpty).toList(),

        // VIII. other skills
        'otherSkills': {
          for (final e in _otherSkills.entries) e.key: e.value,
        },
        'otherSkillsOtherText': _otherSkillsOtherCtrl.text.trim(),

        // metadata
        'submittedAt': FieldValue.serverTimestamp(),
        'submittedByUid': user.uid,
      };

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('forms')
          .doc('jobseeker_registration');

      await docRef.set(payload, SetOptions(merge: true));

      if (mounted) {
        if (widget.isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jobseeker registration updated.')));
        } else {
          // Navigate to HomePage only on first-time submit (after register)
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        }
      }
    } catch (e) {
      debugPrint('Error saving jobseeker form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --------------------------
  // Helpers for compact web UI
  // --------------------------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: GoogleFonts.bebasNeue(fontSize: 16, color: Colors.blue.shade700)),
    );
  }

  Widget _compactTextField(TextEditingController ctrl, String hint, {String? label, double width = 320, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label ?? hint,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: validator,
      ),
    );
  }

  Widget _compactDropdown<T>(
      String label,
      List<T> items,
      T? value,
      void Function(T?) onChanged, {
        double width = 320,
      }) {
    // ✅ Type-safe check to prevent dropdown assertion error
    final T? safeValue = (value != null && items.contains(value)) ? value : null;

    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        value: safeValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: items.map((e) {
          return DropdownMenuItem<T>(
            value: e,
            child: Text(
              e.toString(),
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }



  Widget _langRow(String lang) {
    final map = _languages[lang]!;
    return Row(
      children: [
        SizedBox(width: 120, child: Text(lang, style: const TextStyle(fontSize: 13))),
        SizedBox(width: 48, child: Checkbox(value: map['read'], onChanged: (v) => setState(() => map['read'] = v ?? false))),
        const SizedBox(width: 6),
        SizedBox(width: 48, child: Checkbox(value: map['write'], onChanged: (v) => setState(() => map['write'] = v ?? false))),
        const SizedBox(width: 6),
        SizedBox(width: 48, child: Checkbox(value: map['speak'], onChanged: (v) => setState(() => map['speak'] = v ?? false))),
        const SizedBox(width: 6),
        SizedBox(width: 48, child: Checkbox(value: map['understand'], onChanged: (v) => setState(() => map['understand'] = v ?? false))),
      ],
    );
  }

  // --------------------------
  // Build
  // --------------------------
  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final isLoading = _loadingExisting;
    return MainScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/bgimage.png'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // left decorative stripe similar to register page
              Container(
                width: 600,
                height: screenH,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: CustomPaint(painter: PlusSignPainter()),
              ),

              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                child: Container(
                  width: kIsWeb ? 980 : double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.98),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 6))],
                  ),
                  child: isLoading
                      ? SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Loading your saved Jobseeker registration...'),
                      ]),
                    ),
                  )
                      : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/logo.png', width: 90, height: 90),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PESO MAKATI:', style: GoogleFonts.bebasNeue(fontSize: 28, color: Colors.blue.shade700)),
                                Text('NATIONAL SKILLS REGISTRATION PROGRAM - JOBSEEKER REGISTRATION FORM',
                                    style: GoogleFonts.bebasNeue(fontSize: 14, color: Colors.blue.shade700)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),

                        // I. Personal Information (table-like)
                        _sectionTitle('I. PERSONAL INFORMATION'),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_surnameCtrl, 'Surname', label: 'SURNAME', width: 420),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_firstNameCtrl, 'First name', label: 'FIRST NAME', width: 420),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_middleNameCtrl, 'Middle name', label: 'MIDDLE NAME', width: 420),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_suffixCtrl, 'Suffix', label: 'SUFFIX (Sr., Jr., etc.)', width: 420),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: GestureDetector(
                                  onTap: _pickDob,
                                  child: AbsorbPointer(
                                    child: _compactTextField(_dobCtrl, 'Date of Birth (YYYY-MM-DD)', label: 'DATE OF BIRTH', width: 420, validator: (v) {
                                      // optional validate format if present
                                      if (v != null && v.isNotEmpty) {
                                        try {
                                          DateTime.parse(v);
                                        } catch (_) {
                                          return 'Invalid date';
                                        }
                                      }
                                      return null;
                                    }),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_placeOfBirthCtrl, 'Place of Birth (City/Province)', label: 'PLACE OF BIRTH', width: 420),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactDropdown('SEX', ['Male', 'Female', 'Other'], _sex, (v) => setState(() => _sex = v), width: 420),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_religionCtrl, 'Religion', label: 'RELIGION', width: 420),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactDropdown('CIVIL STATUS', ['Single', 'Married', 'Widowed', 'Separated'], _civilStatus, (v) => setState(() => _civilStatus = v), width: 420),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_tinCtrl, 'Tax Identification Number (TIN)', label: 'TIN', width: 420),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_heightCtrl, 'Height (ft.)', label: 'HEIGHT (FT.)', width: 420),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: _compactTextField(_disabilityCtrl, 'Disability (If any)', label: 'DISABILITY', width: 420),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(padding: const EdgeInsets.all(6), child: _compactTextField(_fatherNameCtrl, "Father's name", label: "FATHER'S NAME", width: 420)),
                              Padding(padding: const EdgeInsets.all(6), child: _compactTextField(_motherNameCtrl, "Mother's name", label: "MOTHER'S NAME", width: 420)),
                            ]),
                            TableRow(children: [
                              Padding(padding: const EdgeInsets.all(6), child: _compactTextField(_motherMaidenCtrl, "Mother's maiden name", label: "MOTHER'S MAIDEN NAME", width: 420)),
                              const SizedBox(), // empty
                            ]),
                            TableRow(children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('PRESENT ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Wrap(spacing: 8, runSpacing: 6, children: [
                                      _compactTextField(_houseNoStreetCtrl, 'House No. / Street', width: 300),
                                      _compactTextField(_villageCtrl, 'Village', width: 300),
                                      _compactTextField(_barangayCtrl, 'Barangay', width: 300),
                                      _compactTextField(_municipalityCtrl, 'Municipality/City', width: 300),
                                      _compactTextField(_provinceCtrl, 'Province', width: 300),
                                    ]),
                                  ]),
                                ),
                              ),
                              Padding(padding: const EdgeInsets.all(6), child: Column(children: [
                                _compactTextField(_contactCtrl, 'Contact Number/s', label: 'CONTACT NUMBER/S', width: 420),
                                const SizedBox(height: 8),
                                _compactTextField(_emailCtrl, 'Email', label: 'E-MAIL', width: 420),
                              ])),
                            ]),
                          ],
                        ),

                        const SizedBox(height: 8),
                        _sectionTitle('EMPLOYMENT STATUS / TYPE'),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          SizedBox(width: 260, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('Employed', style: TextStyle(fontSize: 13)), value: 'Employed', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          SizedBox(width: 260, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('Unemployed', style: TextStyle(fontSize: 13)), value: 'Unemployed', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          SizedBox(width: 300, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('New Entrant / Fresh Graduate', style: TextStyle(fontSize: 13)), value: 'New Entrant/Fresh Graduate', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          SizedBox(width: 300, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('Terminated / Laid off (local)', style: TextStyle(fontSize: 13)), value: 'Terminated/Laid off (local)', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          SizedBox(width: 300, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('Terminated / Laid off (abroad)', style: TextStyle(fontSize: 13)), value: 'Terminated/Laid off (abroad)', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          SizedBox(width: 260, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('Resigned', style: TextStyle(fontSize: 13)), value: 'Resigned', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          SizedBox(width: 260, child: RadioListTile<String>(dense: true, contentPadding: EdgeInsets.zero, title: const Text('Retired', style: TextStyle(fontSize: 13)), value: 'Retired', groupValue: _employmentStatus, onChanged: (v) => setState(() => _employmentStatus = v))),
                          _compactTextField(_howLongLookingCtrl, 'How long have you been looking for work? (months)', width: 320),
                          _compactTextField(_employmentTypeDetailCtrl, 'Employment type detail (e.g., self-employed specify)', width: 320),
                          Row(children: [
                            Checkbox(value: _isOFW, onChanged: (v) => setState(() => _isOFW = v ?? false)),
                            const SizedBox(width: 6),
                            const Text('Are you an OFW?', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),
                            _compactTextField(_ofwCountryCtrl, 'Specify country', width: 300),
                          ]),
                          Row(children: [
                            Checkbox(value: _isFormerOFW, onChanged: (v) => setState(() => _isFormerOFW = v ?? false)),
                            const SizedBox(width: 6),
                            const Text('Are you a former OFW?', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),
                            _compactTextField(_latestCountryDeploymentCtrl, 'Latest country of deployment', width: 300),
                            const SizedBox(width: 12),
                            _compactTextField(_monthYearReturnCtrl, 'Month & year of return to PH', width: 220),
                          ]),
                          Row(children: [
                            Checkbox(value: _is4Ps, onChanged: (v) => setState(() => _is4Ps = v ?? false)),
                            const SizedBox(width: 6),
                            const Text('Are you a 4Ps beneficiary?', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),
                            _compactTextField(_householdIdCtrl, 'Household ID No. (if yes)', width: 300),
                          ]),
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('II. JOB PREFERENCE'),
                        Column(children: [
                          for (int i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(children: [
                                Expanded(child: _compactTextField(_prefOccupationCtrls[i], 'Preferred Occupation ${i + 1}', width: 420)),
                                const SizedBox(width: 8),
                                Expanded(child: _compactTextField(_prefLocationCtrls[i], 'Preferred Work Location ${i + 1}', width: 420)),
                              ]),
                            )
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('III. LANGUAGE / DIALECT PROFICIENCY'),
                        Column(children: [
                          Row(children: [
                            const SizedBox(width: 120, child: Text('Language', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 48, child: Text('Read', style: TextStyle(fontSize: 12))),
                            const SizedBox(width: 48, child: Text('Write', style: TextStyle(fontSize: 12))),
                            const SizedBox(width: 48, child: Text('Speak', style: TextStyle(fontSize: 12))),
                            const SizedBox(width: 65, child: Text('Understand', style: TextStyle(fontSize: 12))),
                          ]),
                          const SizedBox(height: 6),
                          _langRow('English'),
                          const SizedBox(height: 6),
                          _langRow('Filipino'),
                          const SizedBox(height: 6),
                          _langRow('Mandarin'),
                          const SizedBox(height: 6),
                          Row(children: [
                            _langRow('Others'),
                            const SizedBox(width: 12),
                            Expanded(child: _compactTextField(_languagesOtherCtrl, 'If others, please specify', width: 260)),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Checkbox(value: _partTime, onChanged: (v) => setState(() => _partTime = v ?? false)),
                            const SizedBox(width: 6),
                            const Text('Part-time', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),
                            Checkbox(value: _fullTime, onChanged: (v) => setState(() => _fullTime = v ?? false)),
                            const SizedBox(width: 6),
                            const Text('Full-time', style: TextStyle(fontSize: 13)),
                          ]),
                          const SizedBox(height: 6),
                          _compactTextField(_localWorkLocationsCtrl, 'Local (specify cities/municipalities)', width: 540),
                          const SizedBox(height: 6),
                          _compactTextField(_overseasCountriesCtrl, 'Overseas (specify countries)', width: 540),
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('IV. EDUCATIONAL BACKGROUND'),
                        Row(children: [
                          Checkbox(value: _currentlyInSchool, onChanged: (v) => setState(() => _currentlyInSchool = v ?? false)),
                          const SizedBox(width: 6),
                          const Text('Currently in school?', style: TextStyle(fontSize: 13)),
                        ]),
                        const SizedBox(height: 6),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          _compactTextField(_elementaryCtrl, 'Elementary - Course/Year/Graduated', width: 520),
                          _compactTextField(_secondaryCtrl, 'Secondary - Course/Year/Undergraduate/Year last attended', width: 520),
                          _compactTextField(_seniorHighStrandCtrl, 'Senior High Strand', width: 520),
                          _compactTextField(_tertiaryCtrl, 'Tertiary - Course', width: 520),
                          _compactTextField(_graduateStudiesCtrl, 'Graduate Studies / Post-graduate', width: 520),
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('V. TECHNICAL / VOCATIONAL AND OTHER TRAINING'),
                        Column(children: [
                          for (int i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(children: [
                                Row(children: [
                                  Expanded(child: _compactTextField(_trainingCourseCtrls[i], 'Training / Vocational Course ${i + 1}', width: 420)),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 120, child: _compactTextField(_trainingHoursCtrls[i], 'Hours', width: 120)),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Expanded(child: _compactTextField(_trainingInstitutionCtrls[i], 'Training Institution', width: 420)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _compactTextField(_trainingSkillsCtrls[i], 'Skills Acquired', width: 420)),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 200, child: _compactTextField(_trainingCertCtrls[i], 'Certificate (NC I/II/III etc.)', width: 200)),
                                ]),
                              ]),
                            )
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('VI. ELIGIBILITY / PROFESSIONAL LICENSE'),
                        Column(children: [
                          for (int i = 0; i < 2; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Expanded(child: _compactTextField(_eligibilityCtrls[i], 'Eligibility ${i + 1}', width: 320)),
                                const SizedBox(width: 8),
                                SizedBox(width: 140, child: _compactTextField(_eligibilityDateCtrls[i], 'Date Taken', width: 140)),
                                const SizedBox(width: 8),
                                Expanded(child: _compactTextField(_profLicenseCtrls[i], 'Professional License ${i + 1}', width: 320)),
                                const SizedBox(width: 8),
                                SizedBox(width: 140, child: _compactTextField(_profLicenseValidUntilCtrls[i], 'Valid Until', width: 140)),
                              ]),
                            )
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('VII. WORK EXPERIENCE (Limit to 10 years, most recent first)'),
                        Column(children: [
                          for (int i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(children: [
                                Row(children: [
                                  Expanded(child: _compactTextField(_companyNameCtrls[i], 'Company Name', width: 420)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _compactTextField(_companyAddressCtrls[i], 'Address (City/Municipality)', width: 420)),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Expanded(child: _compactTextField(_positionCtrls[i], 'Position', width: 420)),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 120, child: _compactTextField(_monthsCtrls[i], 'No. of Months', width: 120)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _compactTextField(_statusCtrls[i], 'Status (Permanent/Contractual/Part-time/etc.)', width: 420)),
                                ]),
                              ]),
                            )
                        ]),

                        const SizedBox(height: 8),
                        _sectionTitle('VIII. OTHER SKILLS ACQUIRED WITHOUT CERTIFICATE'),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          for (final skill in _otherSkills.keys)
                            SizedBox(
                              width: 220,
                              child: CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(skill, style: const TextStyle(fontSize: 13)),
                                controlAffinity: ListTileControlAffinity.leading,
                                value: _otherSkills[skill],
                                onChanged: (v) => setState(() => _otherSkills[skill] = v ?? false),
                              ),
                            ),
                        ]),
                        if (_otherSkills['Others'] ?? false) _compactTextField(_otherSkillsOtherCtrl, 'Please specify other skill', width: 520),

                        const SizedBox(height: 12),

                        Center(
                          child: SizedBox(
                            width: 320,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(vertical: 12)),
                              child: _isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(widget.isEditMode ? 'Save Changes' : 'Submit and Continue', style: const TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          'By submitting, you authorize DOLE to include your profile in the PESO Employment Information System.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------
// Decorative painter used by the page (same as register page)
// --------------------------
class PlusSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white.withOpacity(0.12)..style = PaintingStyle.fill;
    double spacing = 40.0;
    double sizeOfPlus = 20.0;
    double padding = 20.0;
    for (double x = padding; x < size.width - padding + spacing; x += spacing) {
      for (double y = padding; y < size.height - padding; y += spacing) {
        canvas.drawLine(Offset(x - sizeOfPlus / 2, y), Offset(x + sizeOfPlus / 2, y), paint);
        canvas.drawLine(Offset(x, y - sizeOfPlus / 2), Offset(x, y + sizeOfPlus / 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
