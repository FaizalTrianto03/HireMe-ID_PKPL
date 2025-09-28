import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  // Singleton Pattern
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  late stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;

  SpeechService._internal() {
    _speech = stt.SpeechToText();
  }

  // Method untuk inisialisasi Speech-to-Text dengan izin microphone
  Future<bool> initialize() async {
    // Periksa dan minta izin microphone
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        throw Exception("Microphone permission is required for speech recognition.");
      }
    }

    if (!_isInitialized) {
      // _isInitialized = await _speech.initialize();
    }
    return _isInitialized;
  }

  // Method untuk mulai mendengarkan suara
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) {
      throw Exception("SpeechService is not initialized. Call initialize() first.");
    }

    if (!_isListening) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords); // Mengirim hasil pengenalan suara
        },
      );
    }
  }

  // Method untuk berhenti mendengarkan
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  // Method untuk mengetahui apakah sedang mendengarkan
  bool get isListening => _isListening;
}

// Contoh penggunaan di fitur lain:
// final mic = SpeechService();
// await mic.initialize();
// mic.startListening((result) {
//   print("Hasil pengenalan suara: $result");
// });
// mic.stopListening();
