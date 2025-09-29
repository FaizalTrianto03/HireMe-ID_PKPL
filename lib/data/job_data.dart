import 'package:cloud_firestore/cloud_firestore.dart';

// Pastikan Firebase sudah diinisialisasi di main.dart
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Job {
  final String idjob; // ID pekerjaan
  final String position; // Posisi yang ditawarkan
  final String companyName; // Nama perusahaan
  final String location; // Lokasi perusahaan
  final String companyLogoPath; // Path gambar logo perusahaan
  final String jobType; // Lama kerja, misalnya full-time, part-time
  final List<String> categories; // Kategori, misalnya Marketing, Design
  final JobDetails jobDetails; // Detail pekerjaan dan perusahaan
  final String salary; // Gaji untuk pekerjaan ini
  bool isApplied; // Apakah pekerjaan sudah dilamar
  String applyStatus; // Status aplikasi (accepted, inProcess, cancelled)
  bool isRecommended; // Apakah pekerjaan ini direkomendasikan
  bool isSaved; // Apakah pekerjaan ini sudah disimpan

  Job({
    required this.idjob,
    required this.position,
    required this.companyName,
    required this.location,
    required this.companyLogoPath,
    required this.jobType,
    required this.categories,
    required this.jobDetails,
    required this.salary, // Menambahkan parameter salary
    this.isApplied = false, // Default: pekerjaan belum dilamar
    this.applyStatus = 'inProcess', // Default: aplikasi dalam proses
    this.isRecommended = false, // Default: tidak direkomendasikan
    this.isSaved = false, // Default: pekerjaan belum disimpan
  });
}

class JobDetails {
  final String jobDescription; // Deskripsi pekerjaan
  final List<String> requirements; // Persyaratan pekerjaan
  final String location; // Lokasi
  final List<String> facilities; // Fasilitas yang ditawarkan
  final CompanyDetails companyDetails; // Detail perusahaan

  JobDetails({
    required this.jobDescription,
    required this.requirements,
    required this.location,
    required this.facilities,
    required this.companyDetails,
  });
}

class CompanyDetails {
  final String aboutCompany; // Tentang perusahaan
  final String website; // Website perusahaan
  final String industry; // Industri tempat perusahaan berada
  final List<String> companyGalleryPaths; // Path gambar galeri perusahaan

  CompanyDetails({
    required this.aboutCompany,
    required this.website,
    required this.industry,
    required this.companyGalleryPaths,
  });
}

// List utama untuk menampung data - PURELY dari Firebase, NO DUMMY
List<Job> jobList = [];

// Fungsi untuk fetch data dari Firestore secara pure
Future<void> fetchJobData() async {
  try {
    print('🔥 Starting to fetch job data from Firestore...');
    
    // Clear list untuk memastikan tidak ada duplikasi
    jobList.clear();

    // Ambil data dari Firebase collection 'Jobs'
    final snapshot = await _firestore.collection('Jobs').get();
    
    print('📄 Found ${snapshot.docs.length} documents in Jobs collection');
    
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      print('📋 Processing document: ${doc.id}');
      print('📋 Document data keys: ${data.keys.toList()}');
      
      if (data.containsKey('jobs')) {
        List<dynamic> firebaseJobs = data['jobs'];
        print('💼 Found ${firebaseJobs.length} jobs in document ${doc.id}');
        
        for (var jobData in firebaseJobs) {
          try {
            // Normalize requirements to List<String> from either List<String> or List<Map>
            List<String> normalizeRequirements(dynamic raw) {
              final result = <String>[];
              if (raw is List) {
                for (final item in raw) {
                  if (item is String) {
                    result.add(item);
                  } else if (item is Map) {
                    final isActive = item['isActive'] == true;
                    final text = (item['text'] ?? '').toString();
                    if (text.isNotEmpty) {
                      // Only include active requirements if flag exists
                      if (item.containsKey('isActive')) {
                        if (isActive) result.add(text);
                      } else {
                        result.add(text);
                      }
                    }
                  }
                }
              }
              return result;
            }

            Job newJob = Job(
              idjob: jobData['idjob'] ?? '',
              position: jobData['position'] ?? '',
              companyName: jobData['companyName'] ?? '',
              location: jobData['location'] ?? '',
              companyLogoPath: jobData['companyLogoPath'] ?? '',
              jobType: jobData['jobType'] ?? '',
              categories: List<String>.from(jobData['categories'] ?? []),
              jobDetails: JobDetails(
                jobDescription: jobData['jobDetails']['jobDescription'] ?? '',
                requirements: normalizeRequirements(jobData['jobDetails']['requirements'] ?? []),
                location: jobData['jobDetails']['location'] ?? '',
                facilities: List<String>.from(jobData['jobDetails']['facilities'] ?? []),
                companyDetails: CompanyDetails(
                  aboutCompany: jobData['jobDetails']['companyDetails']['aboutCompany'] ?? '',
                  website: jobData['jobDetails']['companyDetails']['website'] ?? '',
                  industry: jobData['jobDetails']['companyDetails']['industry'] ?? '',
                  companyGalleryPaths: List<String>.from(
                    jobData['jobDetails']['companyDetails']['companyGalleryPaths'] ?? [],
                  ),
                ),
              ),
              salary: jobData['salary'] ?? '',
              isApplied: jobData['isApplied'] ?? false,
              applyStatus: jobData['applyStatus'] ?? 'inProcess',
              isRecommended: jobData['isRecommended'] ?? false,
              isSaved: jobData['isSaved'] ?? false,
            );

            // Cek duplikasi berdasarkan idjob sebelum menambahkan
            if (!jobList.any((existingJob) => existingJob.idjob == newJob.idjob)) {
              jobList.add(newJob);
              print('✅ Added job: ${newJob.position} at ${newJob.companyName}');
            } else {
              print('⚠️ Skipped duplicate job: ${newJob.position}');
            }
          } catch (e) {
            print('❌ Error processing individual job: $e');
          }
        }
      } else {
        print('⚠️ Document ${doc.id} does not contain "jobs" field');
      }
    }
    
    print('🎉 Successfully loaded ${jobList.length} jobs from Firestore');
    
    // Debug: Print sample data
    if (jobList.isNotEmpty) {
      print('📝 Sample job: ${jobList.first.position} - ${jobList.first.categories}');
    }
    
  } catch (error) {
    print('💥 Error fetching Firebase data: $error');
    
    // Buat beberapa sample data jika Firebase gagal (hanya untuk testing)
    if (jobList.isEmpty) {
      print('🚨 No data from Firebase, creating minimal sample data...');
      _createSampleData();
    }
  }
}

// Fungsi untuk membuat sample data jika Firebase benar-benar kosong
void _createSampleData() {
  jobList = [
    Job(
      idjob: 'sample1',
      position: 'Flutter Developer',
      companyName: 'TechCorp',
      location: 'Jakarta',
      companyLogoPath: 'assets/images/logo_tech_solutions.png',
      jobType: 'Full-time',
      categories: ['Technology'],
      salary: 'Rp 15.000.000 - 20.000.000',
      isRecommended: true,
      jobDetails: JobDetails(
        jobDescription: 'Develop mobile applications using Flutter',
        requirements: ['2+ years experience', 'Flutter expertise'],
        location: 'Jakarta',
        facilities: ['Health insurance', 'Remote work'],
        companyDetails: CompanyDetails(
          aboutCompany: 'Leading technology company',
          website: 'https://techcorp.com',
          industry: 'Technology',
          companyGalleryPaths: [],
        ),
      ),
    ),
    Job(
      idjob: 'sample2',
      position: 'UI/UX Designer',
      companyName: 'DesignCorp',
      location: 'Bandung',
      companyLogoPath: 'assets/images/logo_creative_studio.png',
      jobType: 'Full-time',
      categories: ['Design'],
      salary: 'Rp 10.000.000 - 15.000.000',
      isRecommended: false,
      jobDetails: JobDetails(
        jobDescription: 'Design user interfaces and experiences',
        requirements: ['Portfolio required', 'Figma proficiency'],
        location: 'Bandung',
        facilities: ['Creative workspace', 'Health insurance'],
        companyDetails: CompanyDetails(
          aboutCompany: 'Creative design agency',
          website: 'https://designcorp.com',
          industry: 'Design',
          companyGalleryPaths: [],
        ),
      ),
    ),
  ];
  
  print('📋 Created ${jobList.length} sample jobs for testing');
}
