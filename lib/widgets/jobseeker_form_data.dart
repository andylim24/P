import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for Jobseeker Registration Form
/// Handles conversion to/from Firestore
class JobseekerFormData {
  // Personal Information
  String surname;
  String firstName;
  String middleName;
  String suffix;
  DateTime? dateOfBirth;
  String placeOfBirth;
  String? sex;
  String religion;
  String? civilStatus;
  String tin;
  String heightFt;
  String disability;
  String contactNumbers;
  String email;
  String fatherName;
  String motherName;
  String motherMaidenName;

  // Address
  String houseNoStreet;
  String village;
  String barangay;
  String municipalityCity;
  String province;

  // Employment
  String? employmentStatus;
  String howLongLookingMonths;
  String employmentTypeDetail;
  bool isOFW;
  String ofwCountry;
  bool isFormerOFW;
  String latestCountryOfDeployment;
  String monthYearReturn;
  bool is4Ps;
  String householdIdNo;

  // Job Preferences
  List<String> preferredOccupations;
  List<String> preferredWorkLocations;

  // Language Proficiency
  Map<String, Map<String, bool>> languageProficiency;
  String languagesOtherText;
  bool partTime;
  bool fullTime;
  String localWorkLocations;
  String overseasCountries;

  // Education
  bool currentlyInSchool;
  String elementary;
  String secondary;
  String seniorHighStrand;
  String tertiary;
  String graduateStudies;

  // Training
  List<TrainingEntry> trainings;

  // Eligibility & License
  List<EligibilityEntry> eligibilities;
  List<LicenseEntry> professionalLicenses;

  // Work Experience
  List<WorkExperienceEntry> workExperiences;

  // Other Skills
  Map<String, bool> otherSkills;
  String otherSkillsOtherText;

  JobseekerFormData({
    this.surname = '',
    this.firstName = '',
    this.middleName = '',
    this.suffix = '',
    this.dateOfBirth,
    this.placeOfBirth = '',
    this.sex,
    this.religion = '',
    this.civilStatus,
    this.tin = '',
    this.heightFt = '',
    this.disability = '',
    this.contactNumbers = '',
    this.email = '',
    this.fatherName = '',
    this.motherName = '',
    this.motherMaidenName = '',
    this.houseNoStreet = '',
    this.village = '',
    this.barangay = '',
    this.municipalityCity = '',
    this.province = '',
    this.employmentStatus,
    this.howLongLookingMonths = '',
    this.employmentTypeDetail = '',
    this.isOFW = false,
    this.ofwCountry = '',
    this.isFormerOFW = false,
    this.latestCountryOfDeployment = '',
    this.monthYearReturn = '',
    this.is4Ps = false,
    this.householdIdNo = '',
    List<String>? preferredOccupations,
    List<String>? preferredWorkLocations,
    Map<String, Map<String, bool>>? languageProficiency,
    this.languagesOtherText = '',
    this.partTime = false,
    this.fullTime = false,
    this.localWorkLocations = '',
    this.overseasCountries = '',
    this.currentlyInSchool = false,
    this.elementary = '',
    this.secondary = '',
    this.seniorHighStrand = '',
    this.tertiary = '',
    this.graduateStudies = '',
    List<TrainingEntry>? trainings,
    List<EligibilityEntry>? eligibilities,
    List<LicenseEntry>? professionalLicenses,
    List<WorkExperienceEntry>? workExperiences,
    Map<String, bool>? otherSkills,
    this.otherSkillsOtherText = '',
  })  : preferredOccupations = preferredOccupations ?? ['', '', ''],
        preferredWorkLocations = preferredWorkLocations ?? ['', '', ''],
        languageProficiency = languageProficiency ?? _defaultLanguages(),
        trainings = trainings ?? List.generate(3, (_) => TrainingEntry()),
        eligibilities = eligibilities ?? List.generate(2, (_) => EligibilityEntry()),
        professionalLicenses = professionalLicenses ?? List.generate(2, (_) => LicenseEntry()),
        workExperiences = workExperiences ?? List.generate(3, (_) => WorkExperienceEntry()),
        otherSkills = otherSkills ?? _defaultOtherSkills();

  static Map<String, Map<String, bool>> _defaultLanguages() => {
        'English': {'read': false, 'write': false, 'speak': false, 'understand': false},
        'Filipino': {'read': false, 'write': false, 'speak': false, 'understand': false},
        'Mandarin': {'read': false, 'write': false, 'speak': false, 'understand': false},
        'Others': {'read': false, 'write': false, 'speak': false, 'understand': false},
      };

  static Map<String, bool> _defaultOtherSkills() => {
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

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore(String uid) {
    return {
      'surname': surname.trim(),
      'firstName': firstName.trim(),
      'middleName': middleName.trim(),
      'suffix': suffix.trim(),
      'dateOfBirth': dateOfBirth?.toIso8601String() ?? '',
      'placeOfBirth': placeOfBirth.trim(),
      'sex': sex ?? '',
      'religion': religion.trim(),
      'civilStatus': civilStatus ?? '',
      'tin': tin.trim(),
      'heightFt': heightFt.trim(),
      'disability': disability.trim(),
      'contactNumbers': contactNumbers.trim(),
      'email': email.trim(),
      'fatherName': fatherName.trim(),
      'motherName': motherName.trim(),
      'motherMaidenName': motherMaidenName.trim(),
      'presentAddress': {
        'houseNoStreet': houseNoStreet.trim(),
        'village': village.trim(),
        'barangay': barangay.trim(),
        'municipalityCity': municipalityCity.trim(),
        'province': province.trim(),
      },
      'employmentStatus': employmentStatus ?? '',
      'employmentTypeDetail': employmentTypeDetail.trim(),
      'howLongLookingMonths': howLongLookingMonths.trim(),
      'isOFW': isOFW,
      'ofwCountry': ofwCountry.trim(),
      'isFormerOFW': isFormerOFW,
      'latestCountryOfDeployment': latestCountryOfDeployment.trim(),
      'monthYearReturn': monthYearReturn.trim(),
      'is4Ps': is4Ps,
      'householdIdNo': householdIdNo.trim(),
      'preferredOccupations': preferredOccupations.where((s) => s.trim().isNotEmpty).toList(),
      'preferredWorkLocations': preferredWorkLocations.where((s) => s.trim().isNotEmpty).toList(),
      'languageProficiency': languageProficiency,
      'languagesOtherText': languagesOtherText.trim(),
      'partTime': partTime,
      'fullTime': fullTime,
      'localWorkLocations': localWorkLocations.trim(),
      'overseasCountries': overseasCountries.trim(),
      'currentlyInSchool': currentlyInSchool,
      'elementary': elementary.trim(),
      'secondary': secondary.trim(),
      'seniorHighStrand': seniorHighStrand.trim(),
      'tertiary': tertiary.trim(),
      'graduateStudies': graduateStudies.trim(),
      'trainings': trainings.where((t) => t.course.isNotEmpty).map((t) => t.toMap()).toList(),
      'eligibilities': eligibilities.where((e) => e.eligibility.isNotEmpty).map((e) => e.toMap()).toList(),
      'professionalLicenses': professionalLicenses.where((p) => p.license.isNotEmpty).map((p) => p.toMap()).toList(),
      'workExperiences': workExperiences.where((w) => w.companyName.isNotEmpty).map((w) => w.toMap()).toList(),
      'otherSkills': otherSkills,
      'otherSkillsOtherText': otherSkillsOtherText.trim(),
      'submittedAt': FieldValue.serverTimestamp(),
      'submittedByUid': uid,
    };
  }

  /// Create from Firestore document
  factory JobseekerFormData.fromFirestore(Map<String, dynamic> data) {
    final address = data['presentAddress'] as Map<String, dynamic>? ?? {};

    // Parse languages
    final langMap = (data['languageProficiency'] ?? {}) as Map<String, dynamic>;
    final languages = _defaultLanguages();
    for (final key in languages.keys) {
      if (langMap.containsKey(key)) {
        final langData = langMap[key] as Map<String, dynamic>;
        languages[key] = {
          'read': langData['read'] ?? false,
          'write': langData['write'] ?? false,
          'speak': langData['speak'] ?? false,
          'understand': langData['understand'] ?? false,
        };
      }
    }

    // Parse other skills
    final skillsMap = (data['otherSkills'] ?? {}) as Map<String, dynamic>;
    final skills = _defaultOtherSkills();
    for (final key in skills.keys) {
      if (skillsMap.containsKey(key)) {
        skills[key] = skillsMap[key] ?? false;
      }
    }

    // Parse lists
    final prefOcc = List<String>.from(data['preferredOccupations'] ?? []);
    final prefLoc = List<String>.from(data['preferredWorkLocations'] ?? []);

    return JobseekerFormData(
      surname: data['surname'] ?? '',
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      suffix: data['suffix'] ?? '',
      dateOfBirth: _parseDate(data['dateOfBirth']),
      placeOfBirth: data['placeOfBirth'] ?? '',
      sex: data['sex']?.toString().isNotEmpty == true ? data['sex'] : null,
      religion: data['religion'] ?? '',
      civilStatus: data['civilStatus']?.toString().isNotEmpty == true ? data['civilStatus'] : null,
      tin: data['tin'] ?? '',
      heightFt: data['heightFt'] ?? '',
      disability: data['disability'] ?? '',
      contactNumbers: data['contactNumbers'] ?? '',
      email: data['email'] ?? '',
      fatherName: data['fatherName'] ?? '',
      motherName: data['motherName'] ?? '',
      motherMaidenName: data['motherMaidenName'] ?? '',
      houseNoStreet: address['houseNoStreet'] ?? '',
      village: address['village'] ?? '',
      barangay: address['barangay'] ?? '',
      municipalityCity: address['municipalityCity'] ?? '',
      province: address['province'] ?? '',
      employmentStatus: data['employmentStatus']?.toString().isNotEmpty == true ? data['employmentStatus'] : null,
      howLongLookingMonths: data['howLongLookingMonths'] ?? '',
      employmentTypeDetail: data['employmentTypeDetail'] ?? '',
      isOFW: data['isOFW'] ?? false,
      ofwCountry: data['ofwCountry'] ?? '',
      isFormerOFW: data['isFormerOFW'] ?? false,
      latestCountryOfDeployment: data['latestCountryOfDeployment'] ?? '',
      monthYearReturn: data['monthYearReturn'] ?? '',
      is4Ps: data['is4Ps'] ?? false,
      householdIdNo: data['householdIdNo'] ?? '',
      preferredOccupations: _padList(prefOcc, 3),
      preferredWorkLocations: _padList(prefLoc, 3),
      languageProficiency: languages,
      languagesOtherText: data['languagesOtherText'] ?? '',
      partTime: data['partTime'] ?? false,
      fullTime: data['fullTime'] ?? false,
      localWorkLocations: data['localWorkLocations'] ?? '',
      overseasCountries: data['overseasCountries'] ?? '',
      currentlyInSchool: data['currentlyInSchool'] ?? false,
      elementary: data['elementary'] ?? '',
      secondary: data['secondary'] ?? '',
      seniorHighStrand: data['seniorHighStrand'] ?? '',
      tertiary: data['tertiary'] ?? '',
      graduateStudies: data['graduateStudies'] ?? '',
      trainings: _parseTrainings(data['trainings']),
      eligibilities: _parseEligibilities(data['eligibilities']),
      professionalLicenses: _parseLicenses(data['professionalLicenses']),
      workExperiences: _parseWorkExperiences(data['workExperiences']),
      otherSkills: skills,
      otherSkillsOtherText: data['otherSkillsOtherText'] ?? '',
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static List<String> _padList(List<String> list, int length) {
    final result = List<String>.from(list);
    while (result.length < length) {
      result.add('');
    }
    return result;
  }

  static List<TrainingEntry> _parseTrainings(dynamic data) {
    final list = <TrainingEntry>[];
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(TrainingEntry.fromMap(item));
        }
      }
    }
    while (list.length < 3) {
      list.add(TrainingEntry());
    }
    return list;
  }

  static List<EligibilityEntry> _parseEligibilities(dynamic data) {
    final list = <EligibilityEntry>[];
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(EligibilityEntry.fromMap(item));
        }
      }
    }
    while (list.length < 2) {
      list.add(EligibilityEntry());
    }
    return list;
  }

  static List<LicenseEntry> _parseLicenses(dynamic data) {
    final list = <LicenseEntry>[];
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(LicenseEntry.fromMap(item));
        }
      }
    }
    while (list.length < 2) {
      list.add(LicenseEntry());
    }
    return list;
  }

  static List<WorkExperienceEntry> _parseWorkExperiences(dynamic data) {
    final list = <WorkExperienceEntry>[];
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(WorkExperienceEntry.fromMap(item));
        }
      }
    }
    while (list.length < 3) {
      list.add(WorkExperienceEntry());
    }
    return list;
  }
}

class TrainingEntry {
  String course;
  String hours;
  String institution;
  String skillsAcquired;
  String certificate;

  TrainingEntry({
    this.course = '',
    this.hours = '',
    this.institution = '',
    this.skillsAcquired = '',
    this.certificate = '',
  });

  Map<String, dynamic> toMap() => {
        'course': course.trim(),
        'hours': hours.trim(),
        'institution': institution.trim(),
        'skillsAcquired': skillsAcquired.trim(),
        'certificate': certificate.trim(),
      };

  factory TrainingEntry.fromMap(Map<String, dynamic> map) => TrainingEntry(
        course: map['course'] ?? '',
        hours: map['hours'] ?? '',
        institution: map['institution'] ?? '',
        skillsAcquired: map['skillsAcquired'] ?? '',
        certificate: map['certificate'] ?? '',
      );
}

class EligibilityEntry {
  String eligibility;
  String dateTaken;

  EligibilityEntry({this.eligibility = '', this.dateTaken = ''});

  Map<String, dynamic> toMap() => {
        'eligibility': eligibility.trim(),
        'dateTaken': dateTaken.trim(),
      };

  factory EligibilityEntry.fromMap(Map<String, dynamic> map) => EligibilityEntry(
        eligibility: map['eligibility'] ?? '',
        dateTaken: map['dateTaken'] ?? '',
      );
}

class LicenseEntry {
  String license;
  String validUntil;

  LicenseEntry({this.license = '', this.validUntil = ''});

  Map<String, dynamic> toMap() => {
        'license': license.trim(),
        'validUntil': validUntil.trim(),
      };

  factory LicenseEntry.fromMap(Map<String, dynamic> map) => LicenseEntry(
        license: map['license'] ?? '',
        validUntil: map['validUntil'] ?? '',
      );
}

class WorkExperienceEntry {
  String companyName;
  String companyAddress;
  String position;
  String months;
  String status;

  WorkExperienceEntry({
    this.companyName = '',
    this.companyAddress = '',
    this.position = '',
    this.months = '',
    this.status = '',
  });

  Map<String, dynamic> toMap() => {
        'companyName': companyName.trim(),
        'companyAddress': companyAddress.trim(),
        'position': position.trim(),
        'months': months.trim(),
        'status': status.trim(),
      };

  factory WorkExperienceEntry.fromMap(Map<String, dynamic> map) => WorkExperienceEntry(
        companyName: map['companyName'] ?? '',
        companyAddress: map['companyAddress'] ?? '',
        position: map['position'] ?? '',
        months: map['months'] ?? '',
        status: map['status'] ?? '',
      );
}