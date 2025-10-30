# 📋 PANDUAN PRAKTIKUM TEST CASES - CRUD JOB RECRUITER

## 🎯 Functional Requirements (FR)

### FR-JOB-001: Validasi Field Required
Sistem harus memeriksa semua kolom pada form lowongan kerja sebelum disimpan. Tiap kolom seperti posisi, deskripsi, lokasi, website, dan lain-lain harus diisi dengan benar.

**Aturan Validasi:**
- **Position**: Minimal 3 karakter, tidak boleh kosong
- **Location**: Minimal 3 karakter, tidak boleh kosong
- **Job Type**: Harus salah satu dari: Full-time, Part-time, Contract, Freelance
- **Categories**: Minimal 1 kategori, maksimal 5 kategori
- **Job Description**: Minimal 50 karakter
- **Requirements**: Minimal 1 requirement, setiap requirement minimal 5 karakter
- **Salary**: Minimal 5 karakter (contoh: "IDR 5,000,000")
- **About Company**: Minimal 30 karakter
- **Industry**: Tidak boleh kosong
- **Website**: Format URL valid (harus ada domain seperti .com, .id, dll)
- **Facilities**: Minimal 1 benefit/facility
- **Company Gallery**: Minimal 1 gambar, maksimal 10 gambar

### FR-JOB-002: Pencegahan Duplikasi & Validasi Data
Sistem harus mencegah data lowongan yang sama agar tidak ganda dan memastikan setiap data job punya id yang valid.

**Aturan:**
- Job position tidak boleh sama (case insensitive)
- Job index harus valid saat update/delete
- Setiap job punya ID unik (auto-generated)

---

## 🧪 TEST CASES & CARA PRAKTIK

### ✅ TC-JOB-01: Create Job - Semua Data Valid (POSITIF)

**Functional Requirement:** FR-JOB-001  
**Objective:** Memastikan lowongan bisa dibuat jika semua data valid  
**Precondition:** Login sebagai recruiter

**Langkah Praktik:**
1. Buka aplikasi HireMe → Login sebagai recruiter
2. Pergi ke halaman "Explore" atau "My Jobs"
3. Klik tombol "+ Add New Job" atau "Create Job"
4. Isi semua field dengan data VALID:
   ```
   Position: Frontend Developer
   Location: Jakarta Selatan
   Job Type: Full-time
   Categories: Technology, Software Development
   Job Description: We are looking for an experienced Frontend Developer to join our team. 
                    You will be responsible for building responsive web applications.
   Requirements: 
   - 3+ years experience in React.js
   - Strong understanding of HTML, CSS, JavaScript
   Salary: IDR 8,000,000 - 12,000,000
   About Company: ABC Tech is a leading software company in Indonesia with over 100 employees.
   Industry: Information Technology
   Website: https://www.abctech.com
   Facilities: Health Insurance, Paid Leave
   Company Gallery: Upload minimal 1 gambar
   ```
5. Klik tombol "Save Job" atau "Submit"

**Expected Result:** ✅
- Snackbar hijau muncul dengan pesan: **"Success! Job added successfully!"**
- Job baru muncul di daftar pekerjaan
- Tidak ada error yang muncul

**Actual Result:** _[Isi saat praktikum]_

---

### ❌ TC-JOB-02: Create Job - Data Tidak Lengkap (NEGATIF)

**Functional Requirement:** FR-JOB-001  
**Objective:** Memastikan sistem menolak input dengan data kurang dari syarat minimal  
**Precondition:** Login sebagai recruiter

**Langkah Praktik:**
1. Buka aplikasi HireMe → Login sebagai recruiter
2. Pergi ke halaman "Explore" atau "My Jobs"
3. Klik tombol "+ Add New Job" atau "Create Job"
4. Isi SEBAGIAN field saja (sengaja kosongkan beberapa):
   ```
   Position: FE                    ❌ (kurang dari 3 karakter)
   Location: [KOSONG]              ❌ (harus diisi)
   Job Type: Full-time             ✅
   Categories: [KOSONG]            ❌ (minimal 1)
   Job Description: Good job       ❌ (kurang dari 50 karakter)
   Requirements: [KOSONG]          ❌ (minimal 1)
   Salary: 5jt                     ❌ (kurang dari 5 karakter)
   About Company: Tech company     ❌ (kurang dari 30 karakter)
   Industry: [KOSONG]              ❌ (harus diisi)
   Website: abctech                ❌ (format URL invalid)
   Facilities: [KOSONG]            ❌ (minimal 1)
   Company Gallery: [KOSONG]       ❌ (minimal 1 gambar)
   ```
5. Klik tombol "Save Job" atau "Submit"

**Expected Result:** ❌
- Snackbar merah muncul dengan pesan: **"Validation Failed"**
- Detail error ditampilkan:
  - "Job position must be at least 3 characters"
  - "Location is required"
  - "At least one job category is required"
  - "Job description must be at least 50 characters"
  - "At least one job requirement is required"
  - "Please provide a valid salary range"
  - "Company description must be at least 30 characters"
  - "Industry is required"
  - "Invalid website URL format. Must include domain (e.g., www.company.com)"
  - "At least one benefit/facility is required"
  - "At least one company gallery image is required"
- Data TIDAK tersimpan
- Tetap di halaman form

**Actual Result:** _[Isi saat praktikum]_

---

### ❌ TC-JOB-03: Create Job - Duplicate Position (NEGATIF)

**Functional Requirement:** FR-JOB-002  
**Objective:** Memastikan sistem mencegah posisi yang sama dimasukkan dua kali  
**Precondition:** Sudah ada job dengan position "Software Engineer" di database

**Langkah Praktik:**

**PERSIAPAN (Buat job pertama):**
1. Login sebagai recruiter
2. Buat job baru dengan data valid:
   ```
   Position: Software Engineer
   Location: Jakarta
   Job Type: Full-time
   [... isi semua field dengan data valid ...]
   ```
3. Save → Job berhasil dibuat ✅

**PRAKTIK TEST (Coba buat duplicate):**
4. Klik "+ Add New Job" lagi
5. Isi dengan data yang SAMA persis di field Position:
   ```
   Position: Software Engineer     ❌ (SAMA dengan job sebelumnya)
   Location: Bandung               ✅ (berbeda tidak masalah)
   Job Type: Part-time             ✅ (berbeda tidak masalah)
   [... isi field lain dengan data valid ...]
   ```
6. Klik tombol "Save Job"

**Expected Result:** ❌
- Snackbar orange/merah muncul dengan pesan: 
  **"Duplicate Job Position. A job with the position "Software Engineer" already exists. Please use a different position title."**
- Data TIDAK tersimpan
- Tetap di halaman form
- Job yang lama tetap ada, tidak berubah

**Actual Result:** _[Isi saat praktikum]_

**Variasi Test:**
- Coba dengan huruf besar kecil berbeda: "software engineer" → Tetap ditolak ✅
- Coba dengan spasi ekstra: " Software Engineer " → Tetap ditolak ✅
- Coba dengan posisi berbeda: "Backend Engineer" → Berhasil disimpan ✅

---

### ❌ TC-JOB-04: Delete Job - Invalid Index (NEGATIF)

**Functional Requirement:** FR-JOB-002  
**Objective:** Memastikan sistem menolak penghapusan data dengan indeks tidak valid  
**Precondition:** Data job hanya 3 entri di database

**Langkah Praktik:**

**PERSIAPAN:**
1. Login sebagai recruiter
2. Pastikan kamu punya HANYA 3 job di database
   - Job 1: Frontend Developer
   - Job 2: Backend Developer
   - Job 3: UI/UX Designer
3. Catat jumlah job yang ada: **3 jobs**

**PRAKTIK TEST (Simulasi error):**

⚠️ **CATATAN PENTING:** 
Karena ini project monolith (frontend + backend jadi satu), kita tidak bisa langsung test "hapus index 10" dari UI. Tapi validasi ini TETAP PENTING karena:
- Mencegah crash jika ada bug di kode
- Mencegah race condition (data berubah saat user klik)
- Melindungi dari manipulasi API/request

**Cara Test (2 Metode):**

**Metode 1: Simulasi Race Condition (REAL SCENARIO)**
1. Buka aplikasi di 2 device/browser berbeda dengan akun recruiter yang sama
2. Di Device 1: Lihat list job (ada 3 jobs)
3. Di Device 2: Hapus Job #3 (UI/UX Designer) → Berhasil, sekarang tersisa 2 jobs
4. Di Device 1: JANGAN refresh, langsung coba hapus Job #3
5. Sistem akan cek: jobIndex (2) >= updatedJobs.length (2) → Invalid!

**Expected Result:** ❌
- Snackbar merah muncul: 
  **"Invalid Job Index. Cannot delete job. The job index (2) is invalid. You only have 2 job(s) posted."**
- Tidak ada job yang terhapus
- User diminta refresh halaman

**Metode 2: Test via Controller (Untuk Developer/Tester)**
```dart
// Di Flutter console atau test file
final jobController = Get.find<JobController>();
await jobController.deleteJob(10); // Coba hapus index 10, padahal hanya ada 3 jobs
```

**Expected Result:** ❌
- Snackbar merah: 
  **"Invalid Job Index. Cannot delete job. The job index (10) is invalid. You only have 3 job(s) posted."**
- Console log: Tidak ada error crash
- Aplikasi tetap stabil

**Actual Result:** _[Isi saat praktikum]_

**Kenapa Test Ini Penting?**
- ✅ Mencegah app crash jika ada bug di UI
- ✅ Melindungi dari race condition (data berubah saat user sedang aksi)
- ✅ Validasi di backend/controller tetap jalan meskipun UI sudah filter
- ✅ Best practice: "Never trust the client"

---

### ✅ TC-JOB-05: Update Job - Valid Data (POSITIF - BONUS)

**Langkah Praktik:**
1. Buka detail job yang sudah ada
2. Klik "Edit Job"
3. Ubah beberapa field dengan data VALID:
   ```
   Position: Senior Frontend Developer  ✅ (berbeda dari yang lain)
   Salary: IDR 10,000,000 - 15,000,000  ✅
   ```
4. Klik "Save Changes"

**Expected Result:** ✅
- Snackbar hijau: **"Success! Job updated successfully!"**
- Data berubah di list
- Detail job menampilkan data baru

---

### ❌ TC-JOB-06: Update Job - Duplicate Position (NEGATIF - BONUS)

**Precondition:** 
- Job A: "Frontend Developer" (index 0)
- Job B: "Backend Developer" (index 1)

**Langkah Praktik:**
1. Edit Job B (Backend Developer)
2. Ubah position menjadi "Frontend Developer" (sama dengan Job A)
3. Klik "Save Changes"

**Expected Result:** ❌
- Snackbar orange: **"Duplicate Job Position. A job with the position "Frontend Developer" already exists..."**
- Data TIDAK berubah
- Tetap di halaman edit

---

## 📊 FORM HASIL PRAKTIKUM

### Test Summary
| Test Case | Status | Error Message | Screenshot |
|-----------|--------|---------------|------------|
| TC-JOB-01 (Create Valid) | ⬜ Pass / ⬜ Fail | | |
| TC-JOB-02 (Create Invalid) | ⬜ Pass / ⬜ Fail | | |
| TC-JOB-03 (Duplicate) | ⬜ Pass / ⬜ Fail | | |
| TC-JOB-04 (Invalid Index) | ⬜ Pass / ⬜ Fail | | |
| TC-JOB-05 (Update Valid) | ⬜ Pass / ⬜ Fail | | |
| TC-JOB-06 (Update Duplicate) | ⬜ Pass / ⬜ Fail | | |

### Catatan Praktikum
```
Tanggal: _______________
Praktikan: _____________

Kendala yang ditemui:
- 

Bug yang ditemukan:
- 

Saran perbaikan:
- 
```

---

## 🔍 TIPS DEBUGGING

Jika test case GAGAL:
1. Cek console log untuk error detail
2. Pastikan semua validasi di `job_controller.dart` aktif
3. Cek network request di Firestore
4. Screenshot error untuk dokumentasi
5. Catat pesan error yang muncul

---

## ✅ KRITERIA SUKSES

Semua test case dianggap LULUS jika:
- ✅ TC-JOB-01: Data valid tersimpan dengan snackbar hijau
- ✅ TC-JOB-02: Data invalid ditolak dengan pesan error spesifik
- ✅ TC-JOB-03: Duplicate position ditolak dengan pesan jelas
- ✅ TC-JOB-04: Invalid index ditolak tanpa crash
- ✅ TC-JOB-05: Update valid berhasil dengan snackbar hijau
- ✅ TC-JOB-06: Update duplicate ditolak dengan pesan error

**SELAMAT PRAKTIKUM! 🚀**
