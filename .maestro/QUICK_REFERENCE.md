# Quick Reference - Automated Test Cases

Referensi cepat untuk menjalankan 16 automated test cases.

## 🔐 Login (4 TC)

### TC-LOGIN-01
**File:** `TC-LOGIN-01.yaml`  
**Email:** adminhireme@gmail.com  
**Password:** AdminHireme123  
**Expected:** Login berhasil dan halaman dashboard muncul  
**Command:** `maestro test .maestro/TC-LOGIN-01.yaml`

### TC-LOGIN-02
**File:** `TC-LOGIN-02.yaml`  
**Email:** adminhireme (tanpa @)  
**Password:** AdminHireme123  
**Expected:** Sistem menampilkan pesan error format email  
**Command:** `maestro test .maestro/TC-LOGIN-02.yaml`

### TC-LOGIN-03
**File:** `TC-LOGIN-03.yaml`  
**Accounts:**
- Admin: adminhireme@gmail.com / AdminHireme123
- Recruiter: testrecruiter@gmail.com / recruiter123
- Jobseeker: testapplicant@gmail.com / applicant123

**Expected:** Redirect sesuai role masing-masing  
**Command:** `maestro test .maestro/TC-LOGIN-03.yaml`

### TC-LOGIN-04
**File:** `TC-LOGIN-04.yaml`  
**Email:** testcreateaccount@gmail.com  
**Password:** IniTesting123  
**Expected:** Sistem menolak login dengan pesan error  
**Command:** `maestro test .maestro/TC-LOGIN-04.yaml`

---

## 📝 Register (4 TC)

### TC-REGISTER-01
**File:** `TC-REGISTER-01.yaml`  
**Email:** newuser@test.com  
**Password:** SecurePass123  
**Role:** Job Seeker  
**Expected:** Akun berhasil dibuat dan login otomatis  
**Command:** `maestro test .maestro/TC-REGISTER-01.yaml`

### TC-REGISTER-02
**File:** `TC-REGISTER-02.yaml`  
**Email:** user@example.com (sudah terdaftar)  
**Password:** SecurePass123  
**Expected:** Pesan error "Email sudah terdaftar"  
**Command:** `maestro test .maestro/TC-REGISTER-02.yaml`

### TC-REGISTER-03
**File:** `TC-REGISTER-03.yaml`  
**Email:** user@example.com  
**Password:** TestingAkun123  
**Role:** (tidak dipilih)  
**Expected:** Pesan error "Silakan pilih jenis akun"  
**Command:** `maestro test .maestro/TC-REGISTER-03.yaml`

### TC-REGISTER-04
**File:** `TC-REGISTER-04.yaml`  
**Login sebagai:** testrecruiter@gmail.com / recruiter123  
**Expected:** Sistem menolak role tidak valid  
**Command:** `maestro test .maestro/TC-REGISTER-04.yaml`

---

## 💼 Job (8 TC)

### TC-JOB-01
**File:** `TC-JOB-01.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Scenario:** Semua field diisi dengan valid  
**Expected:** Snackbar hijau "Job has been posted successfully!"  
**Command:** `maestro test .maestro/TC-JOB-01.yaml`

### TC-JOB-02
**File:** `TC-JOB-02.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Scenario:** Job Description dikosongkan  
**Expected:** Snackbar merah dengan field yang bermasalah  
**Command:** `maestro test .maestro/TC-JOB-02.yaml`

### TC-JOB-03
**File:** `TC-JOB-03.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Position:** Mobile Engineer (baru)  
**Expected:** Snackbar hijau sukses  
**Command:** `maestro test .maestro/TC-JOB-03.yaml`

### TC-JOB-04
**File:** `TC-JOB-04.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Position:** Mobile Engineer (sudah ada)  
**Expected:** Snackbar merah "Job position already exists"  
**Command:** `maestro test .maestro/TC-JOB-04.yaml`

### TC-JOB-05
**File:** `TC-JOB-05.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Description:** 100 karakter (dalam range 50-300)  
**Expected:** Snackbar hijau sukses  
**Command:** `maestro test .maestro/TC-JOB-05.yaml`

### TC-JOB-06
**File:** `TC-JOB-06.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Description:** 49 karakter (kurang dari 50)  
**Expected:** Snackbar merah "must be at least 50 characters"  
**Command:** `maestro test .maestro/TC-JOB-06.yaml`

### TC-JOB-07
**File:** `TC-JOB-07.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Company Desc:** 150 karakter (max)  
**Expected:** Snackbar hijau sukses  
**Command:** `maestro test .maestro/TC-JOB-07.yaml`

### TC-JOB-08
**File:** `TC-JOB-08.yaml`  
**Login:** testrecruiter@gmail.com / recruiter123  
**Company Desc:** 151 karakter (lebih dari max)  
**Expected:** Snackbar merah "must not exceed 150 characters"  
**Command:** `maestro test .maestro/TC-JOB-08.yaml`

---

## 🎯 Run All Tests

```bash
# Jalankan semua 16 test cases
maestro test .maestro/

# Atau satu per satu berurutan
maestro test .maestro/TC-LOGIN-01.yaml
maestro test .maestro/TC-LOGIN-02.yaml
maestro test .maestro/TC-LOGIN-03.yaml
maestro test .maestro/TC-LOGIN-04.yaml
maestro test .maestro/TC-REGISTER-01.yaml
maestro test .maestro/TC-REGISTER-02.yaml
maestro test .maestro/TC-REGISTER-03.yaml
maestro test .maestro/TC-REGISTER-04.yaml
maestro test .maestro/TC-JOB-01.yaml
maestro test .maestro/TC-JOB-02.yaml
maestro test .maestro/TC-JOB-03.yaml
maestro test .maestro/TC-JOB-04.yaml
maestro test .maestro/TC-JOB-05.yaml
maestro test .maestro/TC-JOB-06.yaml
maestro test .maestro/TC-JOB-07.yaml
maestro test .maestro/TC-JOB-08.yaml
```

## 📋 Checklist Sebelum Testing

- [ ] Maestro sudah terinstall
- [ ] Device/emulator sudah running
- [ ] Aplikasi HireMe sudah terinstall
- [ ] Database sudah disiapkan dengan akun test
- [ ] Koneksi internet stabil

## 🔑 Test Accounts Required

| Role | Email | Password | Status |
|------|-------|----------|--------|
| Admin | adminhireme@gmail.com | AdminHireme123 | Aktif |
| Recruiter | testrecruiter@gmail.com | recruiter123 | Aktif |
| Jobseeker | testapplicant@gmail.com | applicant123 | Aktif |
| Non-aktif | testcreateaccount@gmail.com | IniTesting123 | Non-aktif |

## 💡 Tips

- Jalankan test secara berurutan untuk hasil konsisten
- Pastikan app dalam keadaan fresh sebelum test
- Koordinat tap mungkin perlu disesuaikan dengan device
- Perhatikan waiting time untuk animasi

---
**Total:** 16 Automated Test Cases  
**Status:** ✅ Ready to Run
