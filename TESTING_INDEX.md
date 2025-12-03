# 🗂️ Testing Index - HireMe PKPL

Panduan navigasi cepat ke semua file testing yang telah diorganisir.

## 📚 Dokumentasi Utama

| Dokumen | Deskripsi | Link |
|---------|-----------|------|
| Testing Structure | Dokumentasi lengkap struktur testing | [TESTING_STRUCTURE.md](TESTING_STRUCTURE.md) |
| Testing Complete | Ringkasan apa saja yang sudah dibuat | [TESTING_COMPLETE.md](TESTING_COMPLETE.md) |
| Learning Guide | Panduan pembelajaran unit testing | [codelab/LEARNING_GUIDE.md](codelab/LEARNING_GUIDE.md) |
| Quick Reference | Referensi cepat semua test case | [demo/QUICK_REFERENCE.md](demo/QUICK_REFERENCE.md) |

## 🧪 Unit Testing (Codelab)

### Login
- [login_validation_test.dart](codelab/unit_testing/login/login_validation_test.dart)
  - Email format validation
  - Password validation
  - Role validation

### Register
- [register_validation_test.dart](codelab/unit_testing/register/register_validation_test.dart)
  - Email validation
  - Password strength validation
  - Role selection validation

### Job
- [job_validation_test.dart](codelab/unit_testing/job/job_validation_test.dart)
  - Position validation
  - Description length validation
  - Company description validation
  - Uniqueness validation

## 🎬 Demo Testing (Maestro)

### Login Test Cases
| TC ID | Deskripsi | Link |
|-------|-----------|------|
| TC-LOGIN-01 | Login dengan email dan password yang benar | [test.yaml](demo/TC-LOGIN-01/test.yaml) |
| TC-LOGIN-02 | Email tanpa format yang benar | [test.yaml](demo/TC-LOGIN-02/test.yaml) |
| TC-LOGIN-03 | Pemeriksaan status akun dan role user | [test.yaml](demo/TC-LOGIN-03/test.yaml) |
| TC-LOGIN-04 | Akun tidak aktif atau role kosong | [test.yaml](demo/TC-LOGIN-04/test.yaml) |

### Register Test Cases
| TC ID | Deskripsi | Link |
|-------|-----------|------|
| TC-REGISTER-01 | Pendaftaran dengan email baru dan password kuat | [test.yaml](demo/TC-REGISTER-01/test.yaml) |
| TC-REGISTER-02 | Email sudah terdaftar | [test.yaml](demo/TC-REGISTER-02/test.yaml) |
| TC-REGISTER-03 | Tanpa memilih role | [test.yaml](demo/TC-REGISTER-03/test.yaml) |
| TC-REGISTER-04 | Role tidak valid | [test.yaml](demo/TC-REGISTER-04/test.yaml) |

### Job Test Cases
| TC ID | Deskripsi | Link |
|-------|-----------|------|
| TC-JOB-01 | Semua field valid dan data berhasil disimpan | [test.yaml](demo/TC-JOB-01/test.yaml) |
| TC-JOB-02 | Field wajib kosong | [test.yaml](demo/TC-JOB-02/test.yaml) |
| TC-JOB-03 | Job position baru berhasil | [test.yaml](demo/TC-JOB-03/test.yaml) |
| TC-JOB-04 | Duplikasi job position | [test.yaml](demo/TC-JOB-04/test.yaml) |
| TC-JOB-05 | Description 50-300 karakter | [test.yaml](demo/TC-JOB-05/test.yaml) |
| TC-JOB-06 | Description kurang dari 50 karakter | [test.yaml](demo/TC-JOB-06/test.yaml) |
| TC-JOB-07 | Company description 150 karakter | [test.yaml](demo/TC-JOB-07/test.yaml) |
| TC-JOB-08 | Company description lebih dari 150 karakter | [test.yaml](demo/TC-JOB-08/test.yaml) |

## 📖 README Files

| Folder | Link | Deskripsi |
|--------|------|-----------|
| Codelab | [README.md](codelab/README.md) | Overview folder codelab |
| Demo | [README.md](demo/README.md) | Overview folder demo |

## 🎯 Quick Commands

### Menjalankan Unit Test
```bash
# Login tests
flutter test codelab/unit_testing/login/login_validation_test.dart

# Register tests
flutter test codelab/unit_testing/register/register_validation_test.dart

# Job tests
flutter test codelab/unit_testing/job/job_validation_test.dart

# Semua unit tests
flutter test codelab/
```

### Menjalankan Demo Test
```bash
# Login tests
maestro test demo/TC-LOGIN-01/test.yaml
maestro test demo/TC-LOGIN-02/test.yaml
maestro test demo/TC-LOGIN-03/test.yaml
maestro test demo/TC-LOGIN-04/test.yaml

# Register tests
maestro test demo/TC-REGISTER-01/test.yaml
maestro test demo/TC-REGISTER-02/test.yaml
maestro test demo/TC-REGISTER-03/test.yaml
maestro test demo/TC-REGISTER-04/test.yaml

# Job tests
maestro test demo/TC-JOB-01/test.yaml
maestro test demo/TC-JOB-02/test.yaml
maestro test demo/TC-JOB-03/test.yaml
maestro test demo/TC-JOB-04/test.yaml
maestro test demo/TC-JOB-05/test.yaml
maestro test demo/TC-JOB-06/test.yaml
maestro test demo/TC-JOB-07/test.yaml
maestro test demo/TC-JOB-08/test.yaml
```

## 🔑 Test Accounts

| Role | Email | Password | Status |
|------|-------|----------|--------|
| Admin | adminhireme@gmail.com | AdminHireme123 | Aktif |
| Recruiter | testrecruiter@gmail.com | recruiter123 | Aktif |
| Jobseeker | testapplicant@gmail.com | applicant123 | Aktif |
| Non-aktif | testcreateaccount@gmail.com | IniTesting123 | Non-aktif |

## 📊 Statistics

- **Total Test Cases:** 16
- **Login TC:** 4
- **Register TC:** 4
- **Job TC:** 8
- **Unit Test Files:** 3
- **Demo Test Files:** 16
- **Documentation Files:** 7

## 🎓 Learning Path

1. **Start Here** → [TESTING_STRUCTURE.md](TESTING_STRUCTURE.md)
2. **For Learning** → [codelab/LEARNING_GUIDE.md](codelab/LEARNING_GUIDE.md)
3. **For Demo** → [demo/QUICK_REFERENCE.md](demo/QUICK_REFERENCE.md)
4. **Check Progress** → [TESTING_COMPLETE.md](TESTING_COMPLETE.md)

## 🔍 Search by Category

### Positive Test Cases
- TC-LOGIN-01, TC-LOGIN-03
- TC-REGISTER-01
- TC-JOB-01, TC-JOB-03, TC-JOB-05, TC-JOB-07

### Negative Test Cases
- TC-LOGIN-02, TC-LOGIN-04
- TC-REGISTER-02, TC-REGISTER-03, TC-REGISTER-04
- TC-JOB-02, TC-JOB-04, TC-JOB-06, TC-JOB-08

### Validation Tests
- Email validation: TC-LOGIN-01, TC-LOGIN-02
- Password validation: All login & register
- Role validation: TC-LOGIN-03, TC-REGISTER-03, TC-REGISTER-04
- Field validation: All job test cases
- Uniqueness validation: TC-JOB-04

### Boundary Tests
- TC-JOB-05 (50 chars min)
- TC-JOB-06 (49 chars - below min)
- TC-JOB-07 (150 chars max)
- TC-JOB-08 (151 chars - above max)

---

**💡 Tip:** Gunakan Ctrl+F untuk mencari test case spesifik di halaman ini.

**📌 Bookmark:** Simpan file ini untuk akses cepat ke semua testing resources.
