import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Service for handling speech-to-text functionality
class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  
  StreamController<String>? _speechController;
  StreamController<bool>? _listeningController;
  StreamController<String>? _errorController;

  /// Stream of recognized speech text
  Stream<String> get speechStream => _speechController?.stream ?? const Stream.empty();
  
  /// Stream of listening state changes
  Stream<bool> get listeningStream => _listeningController?.stream ?? const Stream.empty();
  
  /// Stream of error messages
  Stream<String> get errorStream => _errorController?.stream ?? const Stream.empty();

  /// Initialize the speech recognition service
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      // Check microphone permission
      final permissionStatus = await Permission.microphone.request();
      if (!permissionStatus.isGranted) {
        _emitError('Microphone permission is required for voice input');
        return false;
      }

      // Initialize speech recognition
      _isInitialized = await _speech.initialize(
        onError: (error) {
          _emitError('Speech recognition error: ${error.errorMsg}');
          _stopListening();
        },
        onStatus: (status) {
          final listening = status == 'listening';
          if (_isListening != listening) {
            _isListening = listening;
            _listeningController?.add(_isListening);
          }
        },
      );

      if (_isInitialized) {
        _speechController = StreamController<String>.broadcast();
        _listeningController = StreamController<bool>.broadcast();
        _errorController = StreamController<String>.broadcast();
      } else {
        _emitError('Failed to initialize speech recognition');
      }

      return _isInitialized;
    } catch (e) {
      _emitError('Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Check if speech recognition is available on this device
  Future<bool> get isAvailable async {
    if (!_isInitialized) {
      await init();
    }
    return _isInitialized && await _speech.hasPermission;
  }

  /// Start listening for speech input
  Future<void> startListening({
    String localeId = 'en_US',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isInitialized) {
      final initialized = await init();
      if (!initialized) return;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _speechController?.add(_lastWords);
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        localeId: localeId,
        onSoundLevelChange: null,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (e) {
      _emitError('Error starting speech recognition: $e');
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
    }
  }

  /// Cancel current listening session
  Future<void> cancel() async {
    if (_isListening) {
      await _speech.cancel();
    }
  }

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getLocales() async {
    if (!_isInitialized) {
      await init();
    }
    return _speech.locales();
  }

  /// Get the last recognized words
  String get lastWords => _lastWords;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Internal method to emit errors
  void _emitError(String error) {
    _errorController?.add(error);
  }

  /// Internal method to stop listening
  void _stopListening() {
    _isListening = false;
    _listeningController?.add(false);
  }

  /// Dispose of resources
  void dispose() {
    _speechController?.close();
    _listeningController?.close();
    _errorController?.close();
    _speechController = null;
    _listeningController = null;
    _errorController = null;
    _isInitialized = false;
  }
}