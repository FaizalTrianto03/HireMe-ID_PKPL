import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/job_data.dart';

// Debug utility untuk melihat data job dan kategori
Future<void> debugJobData() async {
  try {
    print('=== DEBUG JOB DATA ===');
    
    // 1. Check Firebase collection
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('Jobs').get();
    
    print('Firebase docs found: ${snapshot.docs.length}');
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      print('Doc ID: ${doc.id}');
      print('Has jobs field: ${data.containsKey('jobs')}');
      
      if (data.containsKey('jobs')) {
        final jobs = data['jobs'] as List;
        print('Jobs count in doc: ${jobs.length}');
        
        // Print first job for sample
        if (jobs.isNotEmpty) {
          final firstJob = jobs.first;
          print('Sample job:');
          print('  - idjob: ${firstJob['idjob']}');
          print('  - position: ${firstJob['position']}');
          print('  - categories: ${firstJob['categories']}');
        }
      }
    }
    
    // 2. Check local jobList after fetch
    await fetchJobData();
    print('\n=== LOCAL JOB LIST ===');
    print('Total jobs loaded: ${jobList.length}');
    
    // Count by category
    Map<String, int> categoryCount = {};
    for (var job in jobList) {
      for (var category in job.categories) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }
    
    print('\n=== CATEGORY BREAKDOWN ===');
    categoryCount.forEach((category, count) {
      print('$category: $count jobs');
    });
    
    // Print some sample jobs
    print('\n=== SAMPLE JOBS ===');
    for (int i = 0; i < (jobList.length > 3 ? 3 : jobList.length); i++) {
      final job = jobList[i];
      print('${i + 1}. ${job.position} - ${job.companyName}');
      print('   Categories: ${job.categories.join(', ')}');
      print('   Recommended: ${job.isRecommended}');
    }
    
  } catch (e) {
    print('ERROR in debugJobData: $e');
  }
}

// Fungsi untuk membuat sample data test di Firebase
Future<void> createSampleFirebaseData() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Sample data yang akan diupload ke Firebase
    final sampleData = {
      'jobs': [
        {
          'idjob': 'firebase_1',
          'position': 'Flutter Developer',
          'companyName': 'TechCorp Indonesia',
          'location': 'Jakarta',
          'companyLogoPath': 'assets/images/logo_tech_solutions.png',
          'jobType': 'Full-time',
          'categories': ['Technology'],
          'salary': 'Rp 15.000.000 - 20.000.000',
          'isRecommended': true,
          'isApplied': false,
          'applyStatus': 'inProcess',
          'isSaved': false,
          'jobDetails': {
            'jobDescription': 'Develop mobile applications using Flutter framework',
            'requirements': ['2+ years Flutter experience', 'Dart programming', 'Firebase integration'],
            'location': 'Jakarta',
            'facilities': ['Health insurance', 'Remote work flexible', 'Training budget'],
            'companyDetails': {
              'aboutCompany': 'Leading technology company in Indonesia',
              'website': 'https://techcorp.co.id',
              'industry': 'Technology',
              'companyGalleryPaths': []
            }
          }
        },
        {
          'idjob': 'firebase_2',
          'position': 'UI/UX Designer',
          'companyName': 'Creative Studio',
          'location': 'Bandung',
          'companyLogoPath': 'assets/images/logo_creative_studio.png',
          'jobType': 'Full-time',
          'categories': ['Design'],
          'salary': 'Rp 10.000.000 - 15.000.000',
          'isRecommended': false,
          'isApplied': false,
          'applyStatus': 'inProcess',
          'isSaved': false,
          'jobDetails': {
            'jobDescription': 'Design user interfaces and experiences for digital products',
            'requirements': ['Portfolio required', 'Figma proficiency', 'User research experience'],
            'location': 'Bandung',
            'facilities': ['Creative workspace', 'Health insurance', 'Design tools license'],
            'companyDetails': {
              'aboutCompany': 'Creative design agency specializing in digital products',
              'website': 'https://creativestudio.co.id',
              'industry': 'Design',
              'companyGalleryPaths': []
            }
          }
        },
        {
          'idjob': 'firebase_3',
          'position': 'Digital Marketing Specialist',
          'companyName': 'Marketing Pro',
          'location': 'Surabaya',
          'companyLogoPath': 'assets/images/logo_marketing_pro.jpg',
          'jobType': 'Full-time',
          'categories': ['Marketing'],
          'salary': 'Rp 8.000.000 - 12.000.000',
          'isRecommended': true,
          'isApplied': false,
          'applyStatus': 'inProcess',
          'isSaved': false,
          'jobDetails': {
            'jobDescription': 'Execute digital marketing strategies and campaigns',
            'requirements': ['Google Ads certification', 'Social media expertise', '1+ years experience'],
            'location': 'Surabaya',
            'facilities': ['Performance bonus', 'Training programs', 'Work from home'],
            'companyDetails': {
              'aboutCompany': 'Digital marketing agency helping businesses grow online',
              'website': 'https://marketingpro.co.id',
              'industry': 'Marketing',
              'companyGalleryPaths': []
            }
          }
        }
      ]
    };
    
    // Upload ke Firebase
    await firestore.collection('Jobs').doc('sample_jobs').set(sampleData);
    print('✅ Sample data uploaded to Firebase successfully!');
    
  } catch (e) {
    print('❌ Error uploading sample data: $e');
  }
}