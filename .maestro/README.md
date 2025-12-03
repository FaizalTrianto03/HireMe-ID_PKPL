# Automated Testing - Maestro

Folder ini berisi 16 automated test cases menggunakan Maestro untuk aplikasi HireMe.

## 📋 Daftar Test Cases

### Login Test Cases (4 TC)

| Test Case ID | Requirement | Deskripsi | File |
|--------------|-------------|-----------|------|
| TC-LOGIN-01 | FR-LOGIN-001 | Login dengan email dan password yang benar | [TC-LOGIN-01.yaml](TC-LOGIN-01.yaml) |
| TC-LOGIN-02 | FR-LOGIN-001 | Email tanpa format yang benar | [TC-LOGIN-02.yaml](TC-LOGIN-02.yaml) |
| TC-LOGIN-03 | FR-LOGIN-002 | Pemeriksaan status akun dan role user | [TC-LOGIN-03.yaml](TC-LOGIN-03.yaml) |
| TC-LOGIN-04 | FR-LOGIN-002 | Akun tidak aktif atau role kosong | [TC-LOGIN-04.yaml](TC-LOGIN-04.yaml) |

### Register Test Cases (4 TC)

| Test Case ID | Requirement | Deskripsi | File |
|--------------|-------------|-----------|------|
| TC-REGISTER-01 | FR-REGISTER-001 | Pendaftaran dengan email baru dan password kuat | [TC-REGISTER-01.yaml](TC-REGISTER-01.yaml) |
| TC-REGISTER-02 | FR-REGISTER-001 | Email sudah terdaftar | [TC-REGISTER-02.yaml](TC-REGISTER-02.yaml) |
| TC-REGISTER-03 | FR-REGISTER-002 | Tidak memilih role | [TC-REGISTER-03.yaml](TC-REGISTER-03.yaml) |
| TC-REGISTER-04 | FR-REGISTER-002 | Role tidak valid | [TC-REGISTER-04.yaml](TC-REGISTER-04.yaml) |

### Job Test Cases (8 TC)

| Test Case ID | Requirement | Deskripsi | File |
|--------------|-------------|-----------|------|
| TC-JOB-01 | FR-JOB-001 | Semua field valid dan data berhasil disimpan | [TC-JOB-01.yaml](TC-JOB-01.yaml) |
| TC-JOB-02 | FR-JOB-001 | Field wajib kosong | [TC-JOB-02.yaml](TC-JOB-02.yaml) |
| TC-JOB-03 | FR-JOB-002 | Job position baru berhasil | [TC-JOB-03.yaml](TC-JOB-03.yaml) |
| TC-JOB-04 | FR-JOB-002 | Duplikasi job position | [TC-JOB-04.yaml](TC-JOB-04.yaml) |
| TC-JOB-05 | FR-JOB-003 | Description 50-300 karakter | [TC-JOB-05.yaml](TC-JOB-05.yaml) |
| TC-JOB-06 | FR-JOB-003 | Description kurang dari 50 karakter | [TC-JOB-06.yaml](TC-JOB-06.yaml) |
| TC-JOB-07 | FR-JOB-004 | Company description 150 karakter | [TC-JOB-07.yaml](TC-JOB-07.yaml) |
| TC-JOB-08 | FR-JOB-004 | Company description lebih dari 150 karakter | [TC-JOB-08.yaml](TC-JOB-08.yaml) |

## 🚀 Cara Menjalankan

### Install Maestro
```bash
# Windows
powershell -ExecutionPolicy Bypass -File maestro-install.ps1
```

### Jalankan Single Test Case
```bash
# Login tests
maestro test .maestro/TC-LOGIN-01.yaml
maestro test .maestro/TC-LOGIN-02.yaml
maestro test .maestro/TC-LOGIN-03.yaml
maestro test .maestro/TC-LOGIN-04.yaml

# Register tests
maestro test .maestro/TC-REGISTER-01.yaml
maestro test .maestro/TC-REGISTER-02.yaml
maestro test .maestro/TC-REGISTER-03.yaml
maestro test .maestro/TC-REGISTER-04.yaml

# Job tests
maestro test .maestro/TC-JOB-01.yaml
maestro test .maestro/TC-JOB-02.yaml
maestro test .maestro/TC-JOB-03.yaml
maestro test .maestro/TC-JOB-04.yaml
maestro test .maestro/TC-JOB-05.yaml
maestro test .maestro/TC-JOB-06.yaml
maestro test .maestro/TC-JOB-07.yaml
maestro test .maestro/TC-JOB-08.yaml
```

### Jalankan Semua Test
```bash
maestro test .maestro/
```

## 🔑 Test Accounts

| Role | Email | Password | Status |
|------|-------|----------|--------|
| Admin | adminhireme@gmail.com | AdminHireme123 | Aktif |
| Recruiter | testrecruiter@gmail.com | recruiter123 | Aktif |
| Jobseeker | testapplicant@gmail.com | applicant123 | Aktif |
| Non-aktif | testcreateaccount@gmail.com | IniTesting123 | Non-aktif |

## 📊 Statistik

- **Total Test Cases:** 16
- **Login:** 4 TC
- **Register:** 4 TC
- **Job:** 8 TC

## ✅ Checklist Sebelum Menjalankan Test

- [ ] Maestro sudah terinstall
- [ ] Aplikasi HireMe sudah terinstall di device/emulator
- [ ] Device/emulator sudah running
- [ ] Database sudah disiapkan dengan akun test
- [ ] Koneksi internet stabil (untuk Firebase)

## 📝 Catatan

- Semua test menggunakan comment dalam bahasa Indonesia sederhana
- Koordinat tap (point) mungkin perlu disesuaikan dengan UI actual
- Test case sudah disesuaikan dengan hasil testing manual
- Expected result sesuai dengan actual result dari testing manual

## 🎯 Expected vs Actual Results

Semua test case sudah diverifikasi melalui testing manual:
- ✅ TC-LOGIN-01: Login berhasil dan halaman dashboard muncul
- ✅ TC-LOGIN-02: Sistem menampilkan pesan error sesuai harapan
- ✅ TC-LOGIN-03: Redirect sesuai role masing-masing
- ✅ TC-LOGIN-04: Sistem menolak login dengan pesan error
- ✅ TC-REGISTER-01: Akun berhasil dibuat dan login otomatis
- ✅ TC-REGISTER-02: Pesan error muncul seperti yang diharapkan
- ✅ TC-REGISTER-03: Pesan error muncul sesuai harapan
- ✅ TC-REGISTER-04: Sistem menolak registrasi dengan error
- ✅ TC-JOB-01: Data berhasil disimpan sesuai yang diharapkan
- ✅ TC-JOB-02: Pesan error muncul sesuai harapan
- ✅ TC-JOB-03: Sesuai yang diharapkan
- ✅ TC-JOB-04: Pesan error muncul sesuai harapan
- ✅ TC-JOB-05: Data berhasil disimpan sesuai yang diharapkan
- ✅ TC-JOB-06: Pesan error muncul sesuai harapan
- ✅ TC-JOB-07: Data berhasil disimpan sesuai yang diharapkan
- ✅ TC-JOB-08: Pesan error muncul sesuai harapan

---
**Last Updated:** December 4, 2025
