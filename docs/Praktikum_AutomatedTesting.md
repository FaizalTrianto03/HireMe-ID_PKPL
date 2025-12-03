# Laporan Praktikum Automated Testing (E2E Testing)
# Proyek Flutter HireMe

---

## Identitas Praktikum

**Nama Proyek:** HireMe - Platform Rekrutmen Digital  
**Platform:** Flutter & Firebase  
**Periode Testing:** November 2025  
**Jenis Testing:** Automated End-to-End (E2E) Testing  
**Tools:** Maestro & Flutter Integration Test

---

## 1. Pengenalan Automated Testing

### Apa itu Automated Testing?

Automated Testing adalah proses pengujian aplikasi secara otomatis menggunakan script/program yang mensimulasikan interaksi user dengan aplikasi. Berbeda dengan manual testing yang memerlukan tester untuk mengklik dan menginput data secara manual, automated testing dapat:

- **Dijalankan berulang kali** tanpa intervensi manusia
- **Lebih cepat** untuk regression testing
- **Konsisten** - selalu mengikuti skenario yang sama
- **Dapat diintegrasikan** dengan CI/CD pipeline

### Jenis-jenis Automated Testing

1. **Unit Testing** - Menguji fungsi/method individual
2. **Widget Testing** - Menguji UI components secara terisolasi
3. **Integration Testing** - Menguji interaksi antar komponen
4. **End-to-End (E2E) Testing** - Menguji alur aplikasi lengkap dari perspektif user

---

## 2. Tools Automated Testing untuk Mobile

### A. Appium

**Appium** adalah open-source framework cross-platform untuk automated testing aplikasi mobile (native, hybrid, web mobile).

#### Karakteristik Appium:
- **Cross-platform**: Support Android & iOS
- **Multi-language**: Bisa pakai Java, Python, JavaScript, C#, Ruby
- **WebDriver protocol**: Standard W3C untuk automation
- **Driver-based**: Menggunakan driver khusus per platform
  - UiAutomator2 Driver (Android)
  - XCUITest Driver (iOS)
  - Flutter Driver (Flutter apps)

#### Cara Kerja Appium:
```
Test Script (Java/Python/JS)
    ↓
Appium Client (library)
    ↓
Appium Server (HTTP requests via WebDriver protocol)
    ↓
Platform Driver (UiAutomator2/XCUITest)
    ↓
Mobile Device/Emulator
```

#### Kelebihan Appium:
✅ Support banyak bahasa pemrograman  
✅ Matang dan banyak dokumentasi  
✅ Cocok untuk tim dengan background berbeda  

#### Kekurangan Appium:
❌ Setup kompleks (perlu install server, driver, dll)  
❌ Konfigurasi capability yang rumit  
❌ Eksekusi lebih lambat  
❌ Flaky tests (sering gagal karena timing issues)

---

### B. Maestro

**Maestro** adalah open-source framework modern untuk automated E2E testing aplikasi mobile yang menekankan **simplicity** dan **reliability**.

#### Karakteristik Maestro:
- **YAML-based**: Skenario test ditulis dalam file YAML (bukan kode)
- **Cross-platform**: Support Android, iOS, React Native, Flutter
- **Self-contained**: Tidak perlu Appium Server atau WebDriver
- **Smart waiting**: Otomatis menunggu elemen muncul (no explicit waits)
- **Built-in retry**: Otomatis retry jika elemen belum ready

#### Cara Kerja Maestro:

```
Flow File (YAML)
    ↓
Maestro CLI
    ↓
Device Bridge (ADB untuk Android / idb untuk iOS)
    ↓
Mobile Device/Emulator
```

**Contoh Flow Maestro:**
```yaml
appId: com.example.myapp
---
- launchApp
- tapOn: "Login"
- assertVisible: "Email"
- inputText: "user@test.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Submit"
- assertVisible: "Welcome"
```

#### Kelebihan Maestro:
✅ **Super simple** - No coding, pakai YAML  
✅ **Quick setup** - Install satu command, langsung jalan  
✅ **Reliable** - Smart waiting & auto-retry mengurangi flaky tests  
✅ **Readable** - Flow mudah dibaca bahkan oleh non-programmer  
✅ **Fast execution** - Lebih cepat dari Appium  
✅ **Built-in recording** - Bisa record interaksi jadi flow YAML  

#### Kekurangan Maestro:
❌ Kurang flexible untuk logic kompleks (karena YAML)  
❌ Komunitas lebih kecil dibanding Appium  
❌ Dokumentasi masih berkembang  

---

### C. Flutter Integration Test

**Flutter Integration Test** adalah framework bawaan Flutter untuk E2E testing aplikasi Flutter.

#### Karakteristik:
- **Built-in**: Sudah include di Flutter SDK
- **Dart-based**: Test ditulis dalam bahasa Dart
- **Widget-aware**: Bisa akses internal widget state
- **Type-safe**: Compile-time checking

#### Cara Kerja:

```
Test File (Dart)
    ↓
Flutter Test Framework
    ↓
Flutter Engine
    ↓
App Running on Device/Emulator
```

**Contoh Integration Test:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Login flow test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField).first, 'user@test.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    
    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

#### Kelebihan Integration Test:
✅ **No extra installation** - Sudah ada di Flutter  
✅ **Native Flutter** - Akses penuh ke widget tree  
✅ **Type-safe** - Error ketahuan saat compile  
✅ **Flexible** - Full Dart programming capabilities  
✅ **Fast** - Langsung via Flutter engine  

#### Kekurangan Integration Test:
❌ Harus bisa coding Dart  
❌ Hanya untuk Flutter apps  
❌ Setup awal agak verbose  

---

## 3. Perbandingan Tools

| Aspek | Maestro | Flutter Integration Test | Appium |
|-------|---------|-------------------------|--------|
| **Bahasa** | YAML | Dart | Java/Python/JS/C# |
| **Setup** | ⭐⭐⭐⭐⭐ Super mudah | ⭐⭐⭐⭐ Mudah | ⭐⭐ Kompleks |
| **Kecepatan** | ⭐⭐⭐⭐ Cepat | ⭐⭐⭐⭐⭐ Sangat cepat | ⭐⭐⭐ Sedang |
| **Reliability** | ⭐⭐⭐⭐⭐ Sangat reliable | ⭐⭐⭐⭐ Reliable | ⭐⭐⭐ Sering flaky |
| **Learning Curve** | ⭐⭐⭐⭐⭐ Sangat mudah | ⭐⭐⭐ Perlu tahu Dart | ⭐⭐ Cukup rumit |
| **Flexibility** | ⭐⭐⭐ Terbatas (YAML) | ⭐⭐⭐⭐⭐ Sangat flexible | ⭐⭐⭐⭐ Flexible |
| **Cross-platform** | ✅ Android, iOS, RN, Flutter | ❌ Flutter only | ✅ Android, iOS, Web |
| **Komunitas** | ⭐⭐⭐ Berkembang | ⭐⭐⭐⭐ Besar | ⭐⭐⭐⭐⭐ Sangat besar |

---

## 4. Kenapa Memilih Maestro untuk Proyek Ini?

Untuk praktikum ini, kami memilih **Maestro** sebagai tool utama dengan alasan:

### ✅ Alasan Memilih Maestro:

1. **Simplicity First**
   - Tidak perlu coding, cukup menulis YAML
   - Setup hanya 1 command
   - Cocok untuk rapid prototyping testing

2. **Reliability**
   - Smart waiting mechanism mengurangi flaky tests
   - Auto-retry untuk elemen yang belum ready
   - Hasil test lebih konsisten

3. **Quick Feedback Loop**
   - Eksekusi cepat
   - Error message jelas
   - Mudah di-debug

4. **Readable untuk Semua**
   - Product Manager bisa baca flow
   - QA tanpa programming background bisa maintain
   - Documentation as code

5. **Modern Best Practices**
   - Active development
   - Good documentation
   - Cloud integration ready

### 🔄 Backup: Flutter Integration Test

Kami juga menyediakan Flutter Integration Test sebagai alternatif karena:
- **Built-in** - Tidak perlu install tambahan
- **Powerful** - Full Dart capabilities untuk test kompleks
- **Native** - Akses langsung ke Flutter internals

---

## 5. Cara Kerja Maestro (Detail)

### Arsitektur Maestro

```
┌─────────────────────────────────────────────────────┐
│                  Developer/QA                        │
│              Menulis Flow (YAML)                     │
└────────────────────┬────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────┐
│              Maestro CLI (Binary)                    │
│  - Parse YAML                                        │
│  - Validate syntax                                   │
│  - Execute commands sequentially                     │
│  - Smart waiting & retry logic                       │
└────────────────────┬────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────┐
│            Device Bridge (ADB/idb)                   │
│  - Android: ADB (Android Debug Bridge)              │
│  - iOS: idb (iOS Debug Bridge)                       │
└────────────────────┬────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────┐
│        Mobile Device/Emulator                        │
│  - App running in profile/release mode               │
│  - Real user interactions                            │
│  - Screenshot & logs                                 │
└─────────────────────────────────────────────────────┘
```

### Flow Execution Process

#### 1. **Parsing Phase**
```yaml
appId: com.example.hireme_finalapp  # Maestro identify target app
---
- launchApp                          # Parse command 1
- tapOn: "Login"                     # Parse command 2
- assertVisible: "Email"             # Parse command 3
```

Maestro membaca file YAML, memvalidasi syntax, dan membuat execution plan.

#### 2. **Initialization Phase**
- Connect ke device via ADB (Android) atau idb (iOS)
- Verifikasi app sudah terinstall
- Launch app dengan app ID yang ditentukan

#### 3. **Execution Phase**

Setiap command dieksekusi sequentially dengan mekanisme:

**a. Smart Waiting (Built-in):**
```yaml
- tapOn: "Login"
```
Maestro secara otomatis:
1. Mencari elemen dengan text "Login"
2. Menunggu sampai elemen visible (timeout default 15s)
3. Menunggu sampai elemen clickable
4. Baru melakukan tap

**Tidak perlu explicit wait seperti di Appium:**
```java
// Appium (manual waiting)
WebDriverWait wait = new WebDriverWait(driver, 10);
wait.until(ExpectedConditions.elementToBeClickable(loginButton));
loginButton.click();
```

**b. Auto Retry:**
Jika elemen tidak ditemukan, Maestro akan:
- Retry pencarian setiap 200ms
- Sampai timeout tercapai
- Atau elemen ditemukan

**c. Error Reporting:**
Jika gagal, Maestro memberikan:
- Screenshot saat error
- Hierarchy elemen yang ada
- Suggestion perbaikan

#### 4. **Assertion Phase**
```yaml
- assertVisible: "Welcome"
```
Maestro verify bahwa elemen dengan text "Welcome" muncul di layar.

#### 5. **Cleanup Phase**
```yaml
- stopApp
```
Maestro menghentikan app dan cleanup resources.

---

## 6. Maestro Commands Reference

### A. App Lifecycle Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `launchApp` | Launch aplikasi | `- launchApp` |
| `stopApp` | Stop aplikasi | `- stopApp` |
| `clearState` | Clear app data | `- clearState` |
| `clearKeychain` | Clear iOS keychain | `- clearKeychain` (iOS only) |

### B. Interaction Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `tapOn` | Tap pada elemen | `- tapOn: "Login"` |
| `tapOn` (coordinate) | Tap di koordinat | `- tapOn: { x: 100, y: 200 }` |
| `doubleTapOn` | Double tap | `- doubleTapOn: "Image"` |
| `longPressOn` | Long press | `- longPressOn: "Item"` |
| `inputText` | Input teks | `- inputText: "user@test.com"` |
| `swipe` | Swipe gesture | `- swipe: { direction: "UP" }` |
| `scroll` | Scroll | `- scroll` |
| `scrollUntilVisible` | Scroll sampai elemen visible | `- scrollUntilVisible: { element: "Item" }` |

### C. Assertion Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `assertVisible` | Pastikan elemen visible | `- assertVisible: "Welcome"` |
| `assertNotVisible` | Pastikan elemen tidak visible | `- assertNotVisible: "Error"` |
| `assertTrue` | Pastikan kondisi true | `- assertTrue: ${output.status == "success"}` |

### D. Wait Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `waitForAnimationToEnd` | Tunggu animasi selesai | `- waitForAnimationToEnd` |
| `waitUntilVisible` | Tunggu sampai visible | `- waitUntilVisible: "Dashboard"` |

### E. Advanced Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `runFlow` | Jalankan flow lain | `- runFlow: common/login.yaml` |
| `repeat` | Repeat commands | `- repeat: { times: 3, commands: [...] }` |
| `evalScript` | Execute JavaScript | `- evalScript: "console.log('test')"` |

---

## 7. Project Implementation

### File Structure

```
HireMe-PKPL/
├── .maestro/                          # Maestro flows
│   └── login_flow.yaml               # Login E2E test flow
├── integration_test/                  # Flutter Integration Tests
│   └── login_flow_test.dart          # Login test (Dart)
├── build/
│   └── app/
│       └── outputs/
│           └── flutter-apk/
│               └── app-profile.apk   # APK for testing (94.9MB)
└── maestro/                           # Maestro CLI binary
    └── maestro/
        └── bin/
            └── maestro              # Maestro executable
```

### Maestro Flow: Login Test

**File:** `.maestro/login_flow.yaml`

```yaml
appId: com.example.hireme_finalapp
---
# Step 1: Launch aplikasi
- launchApp

# Step 2: Tap tombol Login di splash/welcome screen
- tapOn: "Login"

# Step 3: Verifikasi elemen form login muncul
- assertVisible: "Email"
- assertVisible: "Password"

# Step 4: Input email
- inputText: "recruiter@test.com"

# Step 5: Pindah ke field password
- tapOn: "Password"
- inputText: "password123"

# Step 6: Pilih role
- tapOn: "Role"
- tapOn: "recruiter"

# Step 7: Submit login
- tapOn: "Login"

# Step 8: Verifikasi sukses login (dashboard muncul)
- assertVisible: 
    text: ".*Dashboard.*|.*Home.*|.*Welcome.*"
    regex: true

# Step 9: Cleanup
- stopApp
```

### Penjelasan Flow:

#### **appId: com.example.hireme_finalapp**
- Identifier unik aplikasi (bundle ID)
- Maestro menggunakan ini untuk launch & identify app
- Didapat dari `android/app/build.gradle` → `applicationId`

#### **Step-by-step Explanation:**

1. **launchApp**
   - Maestro launch app via ADB
   - Equivalent: `adb shell am start -n com.example.hireme_finalapp/.MainActivity`

2. **tapOn: "Login"**
   - Mencari elemen dengan text "Login"
   - Smart waiting: tunggu sampai clickable
   - Tap di center elemen

3. **assertVisible: "Email"**
   - Assertion: pastikan field Email terlihat
   - Fail test jika tidak ada dalam 15s (default timeout)

4. **inputText: "recruiter@test.com"**
   - Input teks ke field yang sedang focus
   - Equivalent: typing via soft keyboard

5. **tapOn: "Role" → tapOn: "recruiter"**
   - Interaction dengan dropdown/selector
   - Tap untuk buka, tap pilihan untuk select

6. **assertVisible (dengan regex)**
   - Support regex pattern untuk flexible assertion
   - Match "Dashboard" atau "Home" atau "Welcome"
   - Cocok untuk variasi text

7. **stopApp**
   - Cleanup: tutup app
   - Equivalent: `adb shell am force-stop com.example.hireme_finalapp`

---

## 8. Staging Mode / Profile Mode

### Apa itu Profile Mode?

**Profile Mode** adalah build mode di Flutter yang mirip dengan production (release mode) namun dengan beberapa debugging capabilities.

| Mode | Debug | Profile | Release |
|------|-------|---------|---------|
| **Performance** | Lambat | **Cepat** | Sangat cepat |
| **Debugging** | ✅ Full | ⚠️ Limited | ❌ No |
| **Hot Reload** | ✅ | ❌ | ❌ |
| **Observatory** | ✅ | ✅ | ❌ |
| **File Size** | Besar | **Medium** | Kecil |

### Kenapa Pakai Profile Mode untuk Testing?

✅ **Performance realistic** - Mendekati production  
✅ **Masih bisa profiling** - Bisa lihat performance metrics  
✅ **Ukuran reasonable** - Tidak sebesar debug (94.9MB vs 100+MB)  
✅ **JIT compilation** - Faster than release for testing  

### Command Build Profile APK:

```bash
flutter build apk --profile
```

Output:
```
Running Gradle task 'assembleProfile'...                          139.5s
✓ Built build\app\outputs\flutter-apk\app-profile.apk (94.9MB)
```

**File location:** `build/app/outputs/flutter-apk/app-profile.apk`

---

## 9. Running Tests

### A. Maestro Test

#### Prerequisites:
1. ✅ Maestro CLI installed
2. ✅ APK profile built
3. ✅ Device/emulator running & connected

#### Commands:

**1. Check device connection:**
```bash
adb devices
```

Output:
```
List of devices attached
emulator-5554   device
```

**2. Install APK to device:**
```bash
adb install build\app\outputs\flutter-apk\app-profile.apk
```

**3. Run Maestro test:**
```bash
maestro\maestro\bin\maestro test .maestro\login_flow.yaml
```

#### Expected Output:

```
Running test: login_flow.yaml

✓ Launch app
✓ Tap on "Login"
✓ Assert visible "Email"
✓ Assert visible "Password"
✓ Input text "recruiter@test.com"
✓ Tap on "Password"
✓ Input text "password123"
✓ Tap on "Role"
✓ Tap on "recruiter"
✓ Tap on "Login"
✓ Assert visible (regex) ".*Dashboard.*|.*Home.*|.*Welcome.*"
✓ Stop app

✅ Test passed (12 commands, 5.3s)
```

#### Jika Test Gagal:

```
Running test: login_flow.yaml

✓ Launch app
✓ Tap on "Login"
✗ Assert visible "Email"

❌ Test failed at step 3

Element not found: "Email"

Screenshot saved: /maestro/screenshots/failure-123.png

Visible elements:
- "Username"
- "Password"
- "Submit"

Suggestion: Did you mean "Username"?
```

Maestro memberikan:
- Screenshot saat error
- List elemen yang visible
- Suggestion perbaikan

---

### B. Flutter Integration Test

#### Commands:

**1. Run on connected device/emulator:**
```bash
flutter test integration_test/login_flow_test.dart
```

**2. Run dengan device ID spesifik:**
```bash
flutter test integration_test/login_flow_test.dart -d <device-id>
```

**3. Run semua integration tests:**
```bash
flutter test integration_test/
```

#### Expected Output:

```
00:00 +0: loading integration_test/login_flow_test.dart
00:03 +0: Login Flow E2E Test TC-E2E-001: Login dengan kredensial valid
00:08 +1: Login Flow E2E Test TC-E2E-002: Login dengan email kosong (negative)
00:11 +2: Login Flow E2E Test TC-E2E-003: Login dengan password kosong (negative)
00:13 +3: All tests passed!
```

---

## 10. Best Practices

### Maestro Best Practices:

1. **Use descriptive flow names**
   ```yaml
   # ❌ Bad
   test.yaml
   
   # ✅ Good
   login_recruiter_success.yaml
   login_invalid_credentials.yaml
   ```

2. **Add comments for clarity**
   ```yaml
   # Login as recruiter
   - tapOn: "Login"
   
   # Fill credentials
   - inputText: "recruiter@test.com"
   ```

3. **Use regex for flexible assertions**
   ```yaml
   # Match variations
   - assertVisible:
       text: "Welcome|Selamat Datang"
       regex: true
   ```

4. **Modularize common flows**
   ```yaml
   # In common/login.yaml
   - inputText: ${email}
   - inputText: ${password}
   - tapOn: "Submit"
   
   # In main flow
   - runFlow: 
       file: common/login.yaml
       env:
         email: "user@test.com"
         password: "pass123"
   ```

5. **Add explicit waits for slow operations**
   ```yaml
   - tapOn: "Submit"
   - waitUntilVisible: "Dashboard"
   ```

### Integration Test Best Practices:

1. **Use pumpAndSettle for animations**
   ```dart
   await tester.tap(loginButton);
   await tester.pumpAndSettle(); // Wait for animations
   ```

2. **Find by type when possible**
   ```dart
   // ✅ More reliable
   final emailField = find.byType(TextField).first;
   
   // ❌ Less reliable (text bisa berubah)
   final emailField = find.byWidgetPredicate(
     (widget) => widget is TextField && widget.decoration?.labelText == 'Email'
   );
   ```

3. **Add meaningful test descriptions**
   ```dart
   testWidgets('TC-E2E-001: Login dengan kredensial valid', (tester) async {
     // Test code
   });
   ```

4. **Group related tests**
   ```dart
   group('Login Flow E2E Test', () {
     testWidgets('positive case', ...);
     testWidgets('negative case', ...);
   });
   ```

---

## 11. Troubleshooting

### Common Issues & Solutions:

#### Maestro Issues:

**1. "Device not found"**
```
Error: No devices found
```
**Solution:**
```bash
adb devices              # Check connection
adb kill-server          # If no devices
adb start-server
```

**2. "App not installed"**
```
Error: App com.example.hireme_finalapp not found
```
**Solution:**
```bash
adb install build\app\outputs\flutter-apk\app-profile.apk
```

**3. "Element not found"**
```
Error: Element "Login" not found
```
**Solution:**
- Check exact text (case-sensitive)
- Use regex untuk flexibility
- Add screenshot untuk debug:
  ```yaml
  - takeScreenshot: debug.png
  ```

#### Integration Test Issues:

**1. "Binding has not been initialized"**
```
Error: ServicesBinding.defaultBinaryMessenger was accessed before binding was initialized
```
**Solution:**
```dart
IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // Di awal main()
```

**2. "Timeout waiting for element"**
```
Error: Timed out waiting for element
```
**Solution:**
```dart
await tester.pumpAndSettle(Duration(seconds: 5)); // Increase timeout
```

**3. "Multiple widgets found"**
```
Error: Found 2 widgets with text "Login"
```
**Solution:**
```dart
final loginButton = find.text('Login').first;
// atau
final loginButton = find.widgetWithText(ElevatedButton, 'Login');
```

---

## 12. Kesimpulan

### Summary Implementasi:

| Aspek | Maestro | Integration Test |
|-------|---------|------------------|
| **Setup Time** | ~5 menit | ~2 menit |
| **Learning Curve** | Sangat mudah | Butuh tahu Dart |
| **Test Creation** | Cepat (YAML) | Sedang (coding) |
| **Maintenance** | Mudah | Sedang |
| **Reliability** | Sangat baik | Baik |
| **Suitable For** | Quick smoke tests, demo | Complex scenarios, regression |

### Rekomendasi:

✅ **Gunakan Maestro untuk:**
- Smoke testing (happy path)
- Demo ke stakeholder
- Quick validation
- Non-technical team members

✅ **Gunakan Integration Test untuk:**
- Complex test scenarios
- Edge cases testing
- Deep integration dengan Flutter internals
- CI/CD pipeline

### Hasil Praktikum:

1. ✅ Berhasil setup **dua tools** automated testing
2. ✅ Membuat **flow login** dengan Maestro (YAML)
3. ✅ Membuat **integration test** untuk login (Dart)
4. ✅ Build APK **profile mode** (94.9MB)
5. ✅ Memahami **cara kerja** masing-masing tool
6. ✅ Menguasai **best practices** automated testing

### Next Steps:

1. **Expand test coverage:**
   - Register flow
   - Create job flow
   - Update job flow
   - Delete job flow

2. **Integrate dengan CI/CD:**
   - GitHub Actions
   - GitLab CI
   - Jenkins

3. **Add more assertions:**
   - Performance metrics
   - Network monitoring
   - Error handling

4. **Create test suite:**
   - Regression suite
   - Smoke test suite
   - Full E2E suite

---

**Catatan:** Dokumentasi ini mencakup setup, cara kerja, dan implementasi dua tools automated testing (Maestro & Flutter Integration Test) untuk memenuhi requirement praktikum Modul 5.
