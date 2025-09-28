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
List<Job> jobList = []; // List utama untuk menampung data
Future<void> fetchJobData() async {
  try {
    jobList.clear(); // Kosongkan jobList (no dummy)

    // Ambil data dari Firebase
    final snapshot = await _firestore.collection('Jobs').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data.containsKey('jobs')) {
        List<dynamic> firebaseJobs = data['jobs'];
        for (var jobData in firebaseJobs) {
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

          jobList.add(newJob);
        }
      }
    }
  } catch (error) {
    print('Error fetching Firebase data: $error');
  }
}
