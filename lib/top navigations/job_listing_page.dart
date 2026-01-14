import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main_homepage.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBarangay;
  String? _selectedEmploymentType;
  String? _selectedEducationLevel;
  bool _pwdOnly = false;
  bool _spesOnly = false;
  bool _mipOnly = false;
  bool _showRecommended = true;

  final List<String> barangays = [
    'Barangays', 'Poblacion', 'Bel-Air', 'San Antonio', 'Guadalupe Nuevo',
    'Cembo', 'West Rembo', 'Tejeros', 'Rizal',
  ];

  final List<String> employmentTypes = [
    'Employment Type', 'Contractual', 'Permanent', 'Project-based', 'Work from home'
  ];

  final List<String> educationLevels = [
    'Education Level', 'High School', 'College Graduate', "Master's", 'Doctorate'
  ];

  User? currentUser;
  List<String> appliedJobIds = [];
  Map<String, dynamic>? userProfile;
  Map<String, double> jobMatchScores = {};

  // Cached user data for matching
  Set<String> _userSkills = {};
  Set<String> _userPreferredOccupations = {};
  Set<String> _userWorkExperience = {};
  Set<String> _userPreferredLocations = {};
  int _userEducationLevel = 0;
  bool _userIsPWD = false;
  bool _userIs4Ps = false;
  bool _userWantsFullTime = false;
  bool _userWantsPartTime = false;
  String _userBarangay = '';

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    if (userDoc.exists) {
      final data = userDoc.data();
      final List<dynamic> appliedJobsData = data?['appliedJobs'] ?? [];
      setState(() {
        appliedJobIds = appliedJobsData
            .map<String>((entry) {
              if (entry is Map<String, dynamic>) return entry['jobId'] ?? '';
              return '';
            })
            .where((id) => id.isNotEmpty)
            .toList();
      });
    }

    final profileDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('forms')
        .doc('jobseeker_registration')
        .get();

    if (profileDoc.exists) {
      setState(() {
        userProfile = profileDoc.data();
        _cacheUserData();
      });
    }
  }

  /// Cache user profile data for efficient matching
  void _cacheUserData() {
    if (userProfile == null) return;

    // Extract skills
    _userSkills = {};
    final otherSkills = userProfile!['otherSkills'];
    if (otherSkills is Map<String, dynamic>) {
      otherSkills.forEach((skill, hasSkill) {
        if (hasSkill == true && skill != 'Others') {
          _userSkills.addAll(_normalizeAndSplit(skill));
        }
      });
    } else if (otherSkills is List) {
      for (var skill in otherSkills) {
        _userSkills.addAll(_normalizeAndSplit(skill?.toString() ?? ''));
      }
    }

    // Extract preferred occupations
    _userPreferredOccupations = {};
    final prefOcc = _safeGetList(userProfile!['preferredOccupations']);
    for (var occ in prefOcc) {
      _userPreferredOccupations.addAll(_normalizeAndSplit(occ?.toString() ?? ''));
    }

    // Extract work experience titles
    _userWorkExperience = {};
    final workExp = _safeGetList(userProfile!['workExperiences']);
    for (var exp in workExp) {
      if (exp is Map<String, dynamic>) {
        _userWorkExperience.addAll(_normalizeAndSplit(exp['position']?.toString() ?? ''));
      }
    }

    // Extract preferred locations
    _userPreferredLocations = _safeGetList(userProfile!['preferredWorkLocations'])
        .map((l) => _normalize(l?.toString() ?? ''))
        .where((l) => l.isNotEmpty)
        .toSet();

    // Education level
    _userEducationLevel = _getUserEducationLevel();

    // Flags
    _userIsPWD = userProfile?['isPWD'] == true || 
                 (userProfile?['disabilityType']?.toString().isNotEmpty == true);
    _userIs4Ps = userProfile?['is4Ps'] == true;
    _userWantsFullTime = userProfile?['fullTime'] == true;
    _userWantsPartTime = userProfile?['partTime'] == true;
    _userBarangay = _normalize(userProfile?['barangay']?.toString() ?? '');
  }

  // ============================================================
  // IMPROVED RECOMMENDATION ALGORITHM
  // ============================================================

  /// Calculate match score using weighted criteria matching
  double calculateMatchScore(Map<String, dynamic> job) {
    if (userProfile == null) return 0.0;

    double totalScore = 0.0;
    double maxScore = 0.0;

    // 1. SKILLS MATCH (35 points max)
    // Most important - direct skill overlap
    maxScore += 35;
    final jobSkills = _extractJobSkills(job);
    if (jobSkills.isNotEmpty && _userSkills.isNotEmpty) {
      int matchedSkills = _userSkills.intersection(jobSkills).length;
      int totalRequired = jobSkills.length;
      double skillRatio = matchedSkills / totalRequired;
      totalScore += skillRatio * 35;
    } else if (jobSkills.isEmpty) {
      totalScore += 17.5; // Neutral if job doesn't specify skills
    }

    // 2. JOB TITLE / OCCUPATION MATCH (25 points max)
    // Does the job title match user's preferred occupations or experience?
    maxScore += 25;
    final jobTitleWords = _normalizeAndSplit(job['title']?.toString() ?? '');
    
    bool titleMatchesPreferred = _userPreferredOccupations.intersection(jobTitleWords).isNotEmpty;
    bool titleMatchesExperience = _userWorkExperience.intersection(jobTitleWords).isNotEmpty;
    
    if (titleMatchesPreferred && titleMatchesExperience) {
      totalScore += 25;
    } else if (titleMatchesPreferred || titleMatchesExperience) {
      totalScore += 18;
    } else {
      // Check description for partial matches
      final jobDesc = _normalizeAndSplit(job['description']?.toString() ?? '');
      bool descMatchesPreferred = _userPreferredOccupations.intersection(jobDesc).length >= 2;
      if (descMatchesPreferred) totalScore += 10;
    }

    // 3. EDUCATION QUALIFICATION (15 points max)
    // User meets or exceeds required education
    maxScore += 15;
    int requiredEdu = _getRequiredEducationLevel(job['educationLevel']?.toString() ?? '');
    if (requiredEdu == 0) {
      totalScore += 15; // No requirement specified
    } else if (_userEducationLevel >= requiredEdu) {
      totalScore += 15; // Qualified
    } else if (_userEducationLevel == requiredEdu - 1) {
      totalScore += 8; // Close to qualified
    }

    // 4. LOCATION MATCH (10 points max)
    maxScore += 10;
    String jobLocation = _normalize(job['location']?.toString() ?? '');
    
    if (jobLocation.isEmpty || jobLocation == 'barangays') {
      totalScore += 7; // Any location
    } else if (jobLocation == _userBarangay) {
      totalScore += 10; // Exact match
    } else if (_userPreferredLocations.contains(jobLocation)) {
      totalScore += 10; // Preferred location
    } else if (_userPreferredLocations.any((p) => p.contains(jobLocation) || jobLocation.contains(p))) {
      totalScore += 7; // Partial match
    }

    // 5. EMPLOYMENT TYPE PREFERENCE (10 points max)
    maxScore += 10;
    String jobType = _normalize(job['employmentType']?.toString() ?? '');
    
    if (jobType == 'permanent' && _userWantsFullTime) {
      totalScore += 10;
    } else if ((jobType == 'contractual' || jobType == 'project-based') && _userWantsPartTime) {
      totalScore += 10;
    } else if (jobType == 'work from home') {
      totalScore += 8; // Generally desirable
    } else if (_userWantsFullTime || _userWantsPartTime) {
      totalScore += 3; // Has preference but doesn't match
    } else {
      totalScore += 5; // No preference set
    }

    // 6. SPECIAL PROGRAM MATCH (5 points max)
    // Bonus for PWD/SPES/4Ps matching
    maxScore += 5;
    if (_userIsPWD && job['isPWD'] == true) {
      totalScore += 5;
    } else if (_userIs4Ps && job['isSPES'] == true) {
      totalScore += 5;
    } else if (!_userIsPWD && !_userIs4Ps) {
      totalScore += 2.5; // Neutral
    }

    return (totalScore / maxScore * 100).clamp(0.0, 100.0);
  }

  /// Extract skills from job posting
  Set<String> _extractJobSkills(Map<String, dynamic> job) {
    Set<String> skills = {};
    
    // From requiredSkills field
    final requiredSkills = _safeGetList(job['requiredSkills']);
    for (var skill in requiredSkills) {
      skills.addAll(_normalizeAndSplit(skill?.toString() ?? ''));
    }
    
    // From requirements text (look for common skill patterns)
    final requirements = _normalize(job['requirements']?.toString() ?? '');
    final skillKeywords = [
      'excel', 'word', 'powerpoint', 'computer', 'driving', 'communication',
      'leadership', 'management', 'accounting', 'bookkeeping', 'sales',
      'marketing', 'customer service', 'typing', 'encoding', 'filing',
      'java', 'python', 'javascript', 'sql', 'html', 'css', 'react',
      'flutter', 'dart', 'nodejs', 'php', 'laravel', 'vue', 'angular',
    ];
    
    for (var keyword in skillKeywords) {
      if (requirements.contains(keyword)) {
        skills.add(keyword);
      }
    }
    
    return skills;
  }

  // ============================================================
  // HELPER FUNCTIONS
  // ============================================================

  List<dynamic> _safeGetList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is Map) return value.values.toList();
    return [];
  }

  String _normalize(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ');
  }

  Set<String> _normalizeAndSplit(String text) {
    if (text.isEmpty) return {};
    final stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'been',
      'be', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
      'could', 'should', 'may', 'might', 'must', 'can', 'this', 'that',
      'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they',
      'not', 'no', 'yes', 'any', 'all', 'some', 'such', 'than', 'too',
    };
    return _normalize(text)
        .split(' ')
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toSet();
  }

  int _getUserEducationLevel() {
    if (userProfile?['graduateStudies']?.toString().isNotEmpty == true) return 4;
    if (userProfile?['tertiary']?.toString().isNotEmpty == true) return 2;
    if (userProfile?['secondary']?.toString().isNotEmpty == true) return 1;
    return 1;
  }

  int _getRequiredEducationLevel(String education) {
    String edu = _normalize(education);
    if (edu.contains('doctorate')) return 4;
    if (edu.contains('master')) return 3;
    if (edu.contains('college') || edu.contains('bachelor') || edu.contains('graduate')) return 2;
    if (edu.contains('high school')) return 1;
    return 0;
  }

  Color _getMatchColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.lightGreen;
    if (score >= 35) return Colors.orange;
    return Colors.grey;
  }

  // ============================================================
  // JOB APPLICATION
  // ============================================================

  Future<void> _applyForJob(String jobId) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to apply.')));
      return;
    }

    if (appliedJobIds.contains(jobId)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already applied to this job.')));
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      final userData = userDoc.data();

      if (userData == null || userData['resumeUrl'] == null || userData['resumeUrl'].isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Resume Required'),
            content: const Text('Please upload your resume before applying for jobs.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Text('Upload Resume'),
              ),
            ],
          ),
        );
        return;
      }

      final appliedAt = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'appliedJobs': FieldValue.arrayUnion([{'jobId': jobId, 'appliedAt': appliedAt}])
      });

      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'applicants': FieldValue.arrayUnion([{
          'uid': currentUser!.uid,
          'fullName': userData['fullName'] ?? '',
          'email': userData['email'] ?? '',
          'resumeUrl': userData['resumeUrl'],
          'appliedAt': appliedAt,
        }]),
      });

      setState(() => appliedJobIds.add(jobId));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Applied successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply: $e')));
    }
  }

  // ============================================================
  // UI COMPONENTS
  // ============================================================

  void _showJobDetailsDialog(Map<String, dynamic> data, String jobId) {
    final matchScore = jobMatchScores[jobId] ?? 0.0;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.work_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(data['title'] ?? 'Job Details',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              if (_showRecommended && userProfile != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMatchColor(matchScore),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${matchScore.toStringAsFixed(0)}% Match',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(Icons.business, 'Company', data['company']),
                  _detailRow(Icons.location_on, 'Location', data['location']),
                  _detailRow(Icons.school, 'Education', data['educationLevel']),
                  _detailRow(Icons.work, 'Employment Type', data['employmentType']),
                  if (data['salaryMin'] != null && data['salaryMax'] != null)
                    _detailRow(Icons.payments, 'Salary', '₱${data['salaryMin']} - ₱${data['salaryMax']}'),
                  const Divider(),

                  // Program badges
                  if (data['isPWD'] == true || data['isSPES'] == true || data['isMIP'] == true) ...[
                    const Text('Programs:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (data['isPWD'] == true) _programBadge('PWD', Icons.accessible, Colors.purple),
                        if (data['isSPES'] == true) _programBadge('SPES', Icons.school, Colors.orange),
                        if (data['isMIP'] == true) _programBadge('MIP', Icons.groups, Colors.teal),
                      ],
                    ),
                    const Divider(),
                  ],

                  const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(data['description'] ?? 'No description provided.'),
                  const SizedBox(height: 12),
                  
                  const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(data['requirements'] ?? 'No requirements specified.'),
                  const SizedBox(height: 12),
                  
                  const Text('Required Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (_safeGetList(data['requiredSkills']))
                        .map((skill) {
                          bool userHasSkill = _userSkills.intersection(_normalizeAndSplit(skill.toString())).isNotEmpty;
                          return Chip(
                            label: Text(skill.toString(), style: TextStyle(
                              fontSize: 12,
                              color: userHasSkill ? Colors.green.shade700 : Colors.black87,
                            )),
                            backgroundColor: userHasSkill ? Colors.green.shade50 : Colors.blue.shade50,
                            side: userHasSkill ? BorderSide(color: Colors.green.shade300) : BorderSide.none,
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.grey),
              label: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            if (!appliedJobIds.contains(jobId))
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _applyForJob(jobId);
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Apply Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value ?? 'Not specified')),
        ],
      ),
    );
  }

  Widget _programBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homebackground.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue[900]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Find Your Perfect Job Match!",
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildFilters(),
                        const Divider(color: Colors.white54),
                        _buildJobListings(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Find jobs here', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            if (userProfile != null) _buildFindMatchToggle(),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Search by position, company, skills, or use filters below.', style: TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            _buildFilterDropdown(barangays, _selectedBarangay ?? 'Barangays', (v) => setState(() => _selectedBarangay = v)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFilterDropdown(employmentTypes, _selectedEmploymentType ?? 'Employment Type', (v) => setState(() => _selectedEmploymentType = v)),
            _buildFilterDropdown(educationLevels, _selectedEducationLevel ?? 'Education Level', (v) => setState(() => _selectedEducationLevel = v)),
            _buildProgramCheckbox('PWD', _pwdOnly, (v) => setState(() => _pwdOnly = v!), Icons.accessible, Colors.purple),
            _buildProgramCheckbox('SPES', _spesOnly, (v) => setState(() => _spesOnly = v!), Icons.school, Colors.orange),
            _buildProgramCheckbox('MIP', _mipOnly, (v) => setState(() => _mipOnly = v!), Icons.groups, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(List<String> items, String value, Function(String?) onChanged) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProgramCheckbox(String label, bool value, Function(bool?) onChanged, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: value ? color : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: onChanged, activeColor: color, visualDensity: VisualDensity.compact),
          Icon(icon, size: 18, color: value ? color : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, color: value ? color : Colors.black87, fontWeight: value ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildFindMatchToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _showRecommended ? Colors.blue.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _showRecommended ? Colors.blue : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 18, color: _showRecommended ? Colors.blue : Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Find Match',
            style: TextStyle(
              fontSize: 13,
              color: _showRecommended ? Colors.blue : Colors.black87,
              fontWeight: _showRecommended ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            height: 24,
            child: Switch(
              value: _showRecommended,
              onChanged: (v) => setState(() => _showRecommended = v),
              activeColor: Colors.blue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobListings() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').orderBy('postedDate', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final keyword = _searchController.text.toLowerCase();
          final allContent = '${data['title'] ?? ''}${data['company'] ?? ''}${data['description'] ?? ''}${data['requirements'] ?? ''}${(_safeGetList(data['requiredSkills'])).join(',')}'.toLowerCase();

          return (keyword.isEmpty || allContent.contains(keyword)) &&
              (_selectedBarangay == null || _selectedBarangay == 'Barangays' || (data['location'] ?? '').toString().toLowerCase() == _selectedBarangay!.toLowerCase()) &&
              (_selectedEmploymentType == null || _selectedEmploymentType == 'Employment Type' || (data['employmentType'] ?? '').toString().toLowerCase() == _selectedEmploymentType!.toLowerCase()) &&
              (_selectedEducationLevel == null || _selectedEducationLevel == 'Education Level' || (data['educationLevel'] ?? '').toString().toLowerCase() == _selectedEducationLevel!.toLowerCase()) &&
              (!_pwdOnly || data['isPWD'] == true) &&
              (!_spesOnly || data['isSPES'] == true) &&
              (!_mipOnly || data['isMIP'] == true);
        }).toList();

        // Calculate match scores and sort
        if (_showRecommended && userProfile != null) {
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            jobMatchScores[doc.id] = calculateMatchScore(data);
          }
          docs.sort((a, b) => (jobMatchScores[b.id] ?? 0).compareTo(jobMatchScores[a.id] ?? 0));
        }

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No jobs found matching your criteria.', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          );
        }

        return Column(children: docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _buildJobCard(data, doc.id, jobMatchScores[doc.id] ?? 0, appliedJobIds.contains(doc.id));
        }).toList());
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> data, String jobId, double matchScore, bool alreadyApplied) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    final bgColor = colors[jobId.hashCode % colors.length];
    final initials = (data['company']?.toString().isNotEmpty == true) ? data['company'].toString().trim()[0].toUpperCase() : '?';

    return InkWell(
      onTap: () => _showJobDetailsDialog(data, jobId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                image: (data['logoUrl']?.toString().isNotEmpty == true)
                    ? DecorationImage(image: NetworkImage(data['logoUrl']), fit: BoxFit.cover)
                    : null,
              ),
              child: (data['logoUrl'] == null || data['logoUrl'].toString().isEmpty)
                  ? Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(data['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))),
                      if (_showRecommended && userProfile != null && matchScore > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _getMatchColor(matchScore), borderRadius: BorderRadius.circular(12)),
                          child: Text('${matchScore.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(data['company'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(data['location'] ?? 'Not specified', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(width: 12),
                      const Icon(Icons.school, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(data['educationLevel'] ?? 'Not specified', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (data['isPWD'] == true) _smallBadge('PWD', Colors.purple),
                      if (data['isSPES'] == true) _smallBadge('SPES', Colors.orange),
                      if (data['isMIP'] == true) _smallBadge('MIP', Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: alreadyApplied ? null : () => _applyForJob(jobId),
              style: ElevatedButton.styleFrom(
                backgroundColor: alreadyApplied ? Colors.grey : Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(alreadyApplied ? 'Applied' : 'Apply', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}