# Quick Reference - Demo Test Cases

## 🔐 Login Test Cases

### TC-LOGIN-01: Login Berhasil
**Kredensial:** `adminhireme@gmail.com` / `AdminHireme123`  
**Expected:** Login berhasil, redirect ke dashboard admin  
**File:** `demo/TC-LOGIN-01/test.yaml`

### TC-LOGIN-02: Email Invalid
**Kredensial:** `adminhireme` (tanpa @) / `AdminHireme123`  
**Expected:** Error "Format email tidak valid"  
**File:** `demo/TC-LOGIN-02/test.yaml`

### TC-LOGIN-03: Multi-Role Login
**Kredensial:**
- Admin: `adminhireme@gmail.com` / `AdminHireme123`
- Recruiter: `testrecruiter@gmail.com` / `recruiter123`
- Jobseeker: `testapplicant@gmail.com` / `applicant123`

**Expected:** Redirect sesuai role masing-masing  
**File:** `demo/TC-LOGIN-03/test.yaml`

### TC-LOGIN-04: Akun Non-Aktif
**Kredensial:** `testcreateaccount@gmail.com` / `IniTesting123`  
**Expected:** Error "Akun dinonaktifkan"  
**File:** `demo/TC-LOGIN-04/test.yaml`

---

## 📝 Register Test Cases

### TC-REGISTER-01: Registrasi Berhasil
**Data:**
- Email: `newuser@test.com`
- Password: `SecurePass123`
- Role: Job Seeker

**Expected:** Akun berhasil dibuat, login otomatis  
**File:** `demo/TC-REGISTER-01/test.yaml`

### TC-REGISTER-02: Email Sudah Terdaftar
**Data:**
- Email: `user@example.com` (sudah ada)
- Password: `SecurePass123`

**Expected:** Error "Email sudah terdaftar"  
**File:** `demo/TC-REGISTER-02/test.yaml`

### TC-REGISTER-03: Role Tidak Dipilih
**Data:**
- Email: `user@example.com`
- Password: `TestingAkun123`
- Role: (tidak dipilih)

**Expected:** Error "Silakan pilih jenis akun"  
**File:** `demo/TC-REGISTER-03/test.yaml`

### TC-REGISTER-04: Role Invalid
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Expected:** Error "Role tidak valid"  
**File:** `demo/TC-REGISTER-04/test.yaml`

---

## 💼 Job Test Cases

### TC-JOB-01: Create Job Berhasil
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Data:** Semua field diisi dengan valid  
**Expected:** Snackbar hijau "Job has been posted successfully!"  
**File:** `demo/TC-JOB-01/test.yaml`

### TC-JOB-02: Field Wajib Kosong
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Data:** Job Description dikosongkan  
**Expected:** Snackbar merah dengan error field kosong  
**File:** `demo/TC-JOB-02/test.yaml`

### TC-JOB-03: Job Position Baru
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Position:** `Mobile Engineer` (baru)  
**Expected:** Snackbar hijau sukses  
**File:** `demo/TC-JOB-03/test.yaml`

### TC-JOB-04: Duplikasi Position
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Position:** `Mobile Engineer` (sudah ada)  
**Expected:** Snackbar merah "Job position already exists"  
**File:** `demo/TC-JOB-04/test.yaml`

### TC-JOB-05: Description Valid (100 char)
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Description:** 100 karakter (dalam range 50-300)  
**Expected:** Snackbar hijau sukses  
**File:** `demo/TC-JOB-05/test.yaml`

### TC-JOB-06: Description Terlalu Pendek (49 char)
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Description:** 49 karakter (kurang dari 50)  
**Expected:** Snackbar merah "must be at least 50 characters"  
**File:** `demo/TC-JOB-06/test.yaml`

### TC-JOB-07: Company Description Valid (150 char)
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Company Desc:** 150 karakter (max)  
**Expected:** Snackbar hijau sukses  
**File:** `demo/TC-JOB-07/test.yaml`

### TC-JOB-08: Company Description Terlalu Panjang (151 char)
**Login:** `testrecruiter@gmail.com` / `recruiter123`  
**Company Desc:** 151 karakter (lebih dari max)  
**Expected:** Snackbar merah "must not exceed 150 characters"  
**File:** `demo/TC-JOB-08/test.yaml`

---

## 🎯 Cara Cepat Menjalankan

```bash
# Login Tests
maestro test demo/TC-LOGIN-01/test.yaml
maestro test demo/TC-LOGIN-02/test.yaml
maestro test demo/TC-LOGIN-03/test.yaml
maestro test demo/TC-LOGIN-04/test.yaml

# Register Tests
maestro test demo/TC-REGISTER-01/test.yaml
maestro test demo/TC-REGISTER-02/test.yaml
maestro test demo/TC-REGISTER-03/test.yaml
maestro test demo/TC-REGISTER-04/test.yaml

# Job Tests
maestro test demo/TC-JOB-01/test.yaml
maestro test demo/TC-JOB-02/test.yaml
maestro test demo/TC-JOB-03/test.yaml
maestro test demo/TC-JOB-04/test.yaml
maestro test demo/TC-JOB-05/test.yaml
maestro test demo/TC-JOB-06/test.yaml
maestro test demo/TC-JOB-07/test.yaml
maestro test demo/TC-JOB-08/test.yaml
```

## 📋 Checklist Sebelum Demo

- [ ] Maestro sudah terinstall
- [ ] Aplikasi HireMe sudah terinstall di device/emulator
- [ ] Database sudah disiapkan dengan akun test:
  - [ ] Admin: `adminhireme@gmail.com`
  - [ ] Recruiter: `testrecruiter@gmail.com`
  - [ ] Jobseeker: `testapplicant@gmail.com`
  - [ ] Akun non-aktif: `testcreateaccount@gmail.com`
- [ ] Koneksi internet stabil (untuk Firebase)
- [ ] Device/emulator sudah running

## 🔑 Akun Test yang Diperlukan

| Role | Email | Password | Status |
|------|-------|----------|--------|
| Admin | adminhireme@gmail.com | AdminHireme123 | Aktif |
| Recruiter | testrecruiter@gmail.com | recruiter123 | Aktif |
| Jobseeker | testapplicant@gmail.com | applicant123 | Aktif |
| Non-aktif | testcreateaccount@gmail.com | IniTesting123 | Non-aktif |

---
**Tip:** Jalankan test secara berurutan untuk hasil yang konsisten
