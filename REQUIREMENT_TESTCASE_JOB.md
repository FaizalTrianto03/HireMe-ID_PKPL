# Job Management - Requirements & Test Cases

## Functional Requirements

| Requirement ID | Requirement Description | Related Test Cases |
|---------------|------------------------|-------------------|
| FR-JOB-001 | Sistem harus memvalidasi semua field required sebelum menyimpan job secara sequential dan menampilkan error message untuk field pertama yang tidak valid (position min 3 char, location min 3 char, job description min 50 char, requirements min 5 char, salary min 5 char, about company min 30 char, website format URL valid, min 1 category, min 1 facility, min 1 gallery image). | TC-JOB-01, TC-JOB-02 |
| FR-JOB-002 | Sistem harus menampilkan loading indicator pada button saat proses create/update job berlangsung, menonaktifkan button untuk mencegah double submit, dan menampilkan feedback berupa snackbar success/error setelah proses selesai. | TC-JOB-03, TC-JOB-04 |

---

## Test Cases

### TC-JOB-01: Create Job dengan Semua Data Valid

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-JOB-01 |
| **Requirement ID** | FR-JOB-001 |
| **Test Scenario** | Memastikan job berhasil dibuat ketika semua field diisi dengan data valid sesuai aturan validasi. |
| **Precondition** | User sudah login sebagai recruiter dan berada di halaman "Add Job". |
| **Test Steps** | 1. Isi field "Job Position" dengan "Senior Flutter Developer" (min 3 char ✓)<br>2. Isi field "Location" dengan "Jakarta" (min 3 char ✓)<br>3. Pilih "Job Type" = "Full-time"<br>4. Pilih minimal 1 "Job Category" (contoh: IT, Software Engineering)<br>5. Isi "Job Description" dengan minimal 50 karakter (contoh: "We are looking for an experienced Flutter developer to join our team. You will be responsible for developing mobile applications...")<br>6. Tambahkan minimal 1 requirement dengan minimal 5 karakter per item (contoh: "Bachelor degree in Computer Science")<br>7. Isi "Facilities" dengan minimal 1 benefit (contoh: "Health Insurance, Annual Bonus")<br>8. Isi "Salary" dengan minimal 5 karakter (contoh: "IDR 10,000,000 - 15,000,000")<br>9. Isi "About Company" dengan minimal 30 karakter (contoh: "PT Example Tech is a leading technology company in Indonesia...")<br>10. Isi "Industry" dengan data valid (contoh: "Information Technology")<br>11. Isi "Website" dengan format URL valid (contoh: "www.example.com" atau "https://example.com")<br>12. Upload minimal 1 Company Gallery Image<br>13. Klik tombol "Save Job" |
| **Expected Result** | - Button "Save Job" berubah menjadi CircularProgressIndicator<br>- Setelah proses selesai, muncul snackbar hijau: "Job has been posted successfully!"<br>- User otomatis dinavigasi kembali ke halaman Job Management<br>- Job baru muncul di daftar job |
| **Actual Result** | _(Diisi saat testing)_ |
| **Status** | _(Pass / Failed)_ |

---

### TC-JOB-02: Create Job dengan Job Description Kurang dari 50 Karakter

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-JOB-02 |
| **Requirement ID** | FR-JOB-001 |
| **Test Scenario** | Memastikan sistem menolak job description yang kurang dari 50 karakter (validasi sequential - error muncul sesuai urutan). |
| **Precondition** | User sudah login sebagai recruiter dan berada di halaman "Add Job". |
| **Test Steps** | 1. Isi field "Job Position" dengan "Backend Developer" (valid ✓)<br>2. Isi field "Location" dengan "Bandung" (valid ✓)<br>3. Pilih "Job Type" = "Full-time" (valid ✓)<br>4. Pilih 1 category (valid ✓)<br>5. Isi "Job Description" dengan **"Short description"** (hanya 17 karakter, kurang dari 50 ❌)<br>6. Isi semua field lainnya dengan data valid<br>7. Klik tombol "Save Job" |
| **Expected Result** | - Button menampilkan loading indicator<br>- Sistem melakukan validasi sequential: Position ✓ → Location ✓ → Job Type ✓ → Categories ✓ → Description ❌ STOP<br>- Muncul snackbar merah: **"Job description must be at least 50 characters"**<br>- Button kembali normal (text "Save Job" muncul lagi)<br>- User tetap di halaman Add Job<br>- Form tidak direset |
| **Actual Result** | _(Diisi saat testing)_ |
| **Status** | _(Pass / Failed)_ |

---

### TC-JOB-03: Button Loading State saat Create Job

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-JOB-03 |
| **Requirement ID** | FR-JOB-002 |
| **Test Scenario** | Memastikan button menampilkan loading indicator dan tidak bisa diklik berulang kali saat proses create job berlangsung. |
| **Precondition** | User sudah login sebagai recruiter dan berada di halaman "Add Job" dengan semua field terisi valid. |
| **Test Steps** | 1. Isi semua field dengan data valid<br>2. Klik tombol "Save Job"<br>3. Perhatikan perubahan pada button<br>4. Coba klik button berkali-kali saat proses masih berjalan |
| **Expected Result** | - Saat diklik pertama kali:<br>&nbsp;&nbsp;• Text "Save Job" hilang<br>&nbsp;&nbsp;• Muncul CircularProgressIndicator (spinner putih kecil) di tengah button<br>&nbsp;&nbsp;• Button menjadi disabled (tidak bisa diklik lagi)<br>&nbsp;&nbsp;• Warna button tetap ungu<br>- Klik button berkali-kali tidak memicu proses baru (hanya 1 proses yang berjalan)<br>- Setelah proses selesai:<br>&nbsp;&nbsp;• Loading indicator hilang<br>&nbsp;&nbsp;• Muncul snackbar hijau "Job has been posted successfully!"<br>&nbsp;&nbsp;• User dinavigasi ke halaman Job Management |
| **Actual Result** | _(Diisi saat testing)_ |
| **Status** | _(Pass / Failed)_ |

---

### TC-JOB-04: Update Job dengan Data Valid

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-JOB-04 |
| **Requirement ID** | FR-JOB-002 |
| **Test Scenario** | Memastikan button loading dan success snackbar bekerja dengan baik saat update job. |
| **Precondition** | - User sudah login sebagai recruiter<br>- Sudah ada minimal 1 job di database<br>- User berada di halaman "Edit Job" |
| **Test Steps** | 1. Buka halaman Edit Job untuk salah satu job yang ada<br>2. Ubah field "Salary" menjadi "IDR 12,000,000 - 18,000,000" (data valid)<br>3. Biarkan field lain tetap valid<br>4. Klik tombol "Update Job"<br>5. Perhatikan perubahan button dan feedback yang muncul |
| **Expected Result** | - Button "Update Job" berubah menjadi CircularProgressIndicator<br>- Button menjadi disabled selama proses berlangsung<br>- Sistem melakukan validasi sequential untuk semua field ✓<br>- Data berhasil diupdate ke Firestore<br>- Muncul snackbar hijau: **"Job updated successfully!"**<br>- Button kembali normal<br>- User otomatis dinavigasi kembali ke halaman Job Management<br>- Data job yang diupdate berubah di daftar |
| **Actual Result** | _(Diisi saat testing)_ |
| **Status** | _(Pass / Failed)_ |

---

## Testing Notes

### Urutan Validasi Sequential (FR-JOB-001)

Sistem melakukan validasi dengan urutan sebagai berikut:

1. **Job Position** (required + min 3 char)
2. **Location** (required + min 3 char)
3. **Job Type** (required + harus salah satu dari: Full-time, Part-time, Contract, Freelance)
4. **Categories** (min 1, max 5)
5. **Job Description** (required + min 50 char)
6. **Requirements** (min 1 item, setiap item min 5 char)
7. **Facilities** (min 1 item)
8. **Salary** (required + min 5 char)
9. **About Company** (required + min 30 char)
10. **Industry** (required)
11. **Website** (required + format URL valid)
12. **Company Gallery** (min 1 image, max 10 images)

**Jika validasi ke-N gagal, sistem akan:**
- Menampilkan error message untuk field ke-N
- STOP validasi (tidak lanjut ke validasi ke-(N+1))
- Set `isLoading = false`
- Return `false` ke view
- Button kembali ke state normal

### Expected Behavior Summary

| Scenario | Button State | Error Display | Form State | Navigation |
|----------|-------------|---------------|------------|------------|
| Create/Update Success | Loading → Normal | Success snackbar (hijau) | Reset (create only) | Navigate back |
| Validation Failed | Loading → Normal | Error snackbar (merah) | **NOT Reset** | Stay on page |
| Duplicate Position | Loading → Normal | Warning snackbar (merah) | **NOT Reset** | Stay on page |
| Network Error | Loading → Normal | Error snackbar (merah) | **NOT Reset** | Stay on page |

---

## Test Execution Template

Gunakan template ini untuk mencatat hasil testing:

```
Test Date: __________
Tester: __________
Environment: [Development / Staging / Production]
App Version: __________

| Test Case ID | Status | Notes |
|-------------|--------|-------|
| TC-JOB-01 | [ ] Pass / [ ] Failed | |
| TC-JOB-02 | [ ] Pass / [ ] Failed | |
| TC-JOB-03 | [ ] Pass / [ ] Failed | |
| TC-JOB-04 | [ ] Pass / [ ] Failed | |

Summary:
- Total Test Cases: 4
- Passed: __
- Failed: __
- Pass Rate: ___%
```

---

## Key Differences Between Test Cases

| Test Case | What It Tests | Focus Area | Validation Type |
|-----------|--------------|------------|-----------------|
| **TC-JOB-01** | Create dengan semua field valid | Happy path - Success scenario | Complete validation pass |
| **TC-JOB-02** | Job Description < 50 char | Sequential validation - Field ke-5 | Specific field format rule |
| **TC-JOB-03** | Button loading state & double click prevention | UI/UX behavior saat create | Loading indicator & button disabled |
| **TC-JOB-04** | Update job dengan data valid | Update operation dengan feedback | Loading, validation, snackbar, navigation |

**Perbedaan Utama:**
- **TC-JOB-01 vs TC-JOB-02**: TC-01 menguji success path, TC-02 menguji error path dengan field spesifik
- **TC-JOB-03 vs TC-JOB-04**: TC-03 fokus UI behavior saat create, TC-04 fokus complete flow saat update
- **FR-JOB-001 vs FR-JOB-002**: FR-001 tentang validasi data, FR-002 tentang UI/UX dan feedback system

---

## Bug History

### Bug #1: Success Message Appears Even When Validation Fails (FIXED)
- **Date Found:** _(recent)_
- **Description:** Saat create/update job, jika validasi gagal, snackbar error muncul tetapi beberapa detik kemudian snackbar success juga muncul dan form direset.
- **Root Cause:** View tidak mengecek return value dari `addJob()` / `updateJob()`. Method controller dulunya `Future<void>` sehingga view tidak bisa tahu apakah proses berhasil atau gagal.
- **Fix:** 
  - Changed `addJob()` dan `updateJob()` dari `Future<void>` ke `Future<bool>`
  - Return `false` jika validasi gagal
  - Return `true` jika berhasil disimpan ke Firestore
  - View sekarang cek `if (success)` sebelum menampilkan success message dan reset form
- **Status:** RESOLVED ✅

### Bug #2: Update Mode Validation Not Triggered (FIXED)
- **Date Found:** _(recent)_
- **Description:** Saat update job, validasi tidak berjalan sama sekali, langsung muncul "updated successfully" tanpa mengecek data.
- **Root Cause:** `updateJob()` hanya memvalidasi `position` jika ada di `updatedFields`, tidak memvalidasi semua field.
- **Fix:**
  - Extract semua field dari job yang sedang diedit
  - Apply perubahan dari `updatedFields` ke variabel lokal
  - Panggil `validateJobRequiredFields()` dengan data lengkap (existing + updated)
  - Validasi berjalan untuk SEMUA field, bukan hanya yang diubah
- **Status:** RESOLVED ✅
