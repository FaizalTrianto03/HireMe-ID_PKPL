# Demo Testing - HireMe

Folder ini berisi file demo untuk setiap test case yang akan dijalankan dalam presentasi.

## Struktur Folder

Setiap test case memiliki folder sendiri dengan file `.yaml` untuk Maestro testing.

### Login Test Cases
- `TC-LOGIN-01/` - Login dengan email dan password yang benar
- `TC-LOGIN-02/` - Email tanpa format yang benar
- `TC-LOGIN-03/` - Pemeriksaan status akun dan role user
- `TC-LOGIN-04/` - Akun tidak aktif atau role kosong

### Register Test Cases
- `TC-REGISTER-01/` - Pendaftaran dengan email baru dan password kuat
- `TC-REGISTER-02/` - Email sudah terdaftar
- `TC-REGISTER-03/` - Tanpa memilih role
- `TC-REGISTER-04/` - Role tidak valid

### Job Test Cases
- `TC-JOB-01/` - Semua field valid
- `TC-JOB-02/` - Field wajib kosong
- `TC-JOB-03/` - Job position baru berhasil
- `TC-JOB-04/` - Duplikasi job position
- `TC-JOB-05/` - Description 50-300 karakter
- `TC-JOB-06/` - Description kurang dari 50 karakter
- `TC-JOB-07/` - Company description 150 karakter
- `TC-JOB-08/` - Company description lebih dari 150 karakter

## Cara Menjalankan Demo

```bash
# Install Maestro terlebih dahulu
powershell -ExecutionPolicy Bypass -File maestro-install.ps1

# Jalankan test case spesifik
maestro test demo/TC-LOGIN-01/test.yaml

# Jalankan semua test dalam folder
maestro test demo/
```
