import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/app_interrupt.dart';

class AppInterruptDialog extends StatefulWidget {
  final AppInterrupt interrupt;
  final VoidCallback onSuccess;

  const AppInterruptDialog({
    super.key,
    required this.interrupt,
    required this.onSuccess,
  });

  @override
  State<AppInterruptDialog> createState() => _AppInterruptDialogState();
}

class _AppInterruptDialogState extends State<AppInterruptDialog> {
  final TextEditingController _passwordController = TextEditingController();
  int _remainingSeconds = 30;
  Timer? _timer;
  bool _timerComplete = false;
  bool _showPasswordError = false;

  // Voice recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();

    if (widget.interrupt.method.usesTimer) {
      _startTimer();
    }
  }

  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timerComplete = true;
          timer.cancel();
        }
      });
    });
  }

  void _startListening() async {
    if (!_speechAvailable) {
      _showVoiceError('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords.toLowerCase();
        });

        // Check if user said the app name
        if (_recognizedText.contains(widget.interrupt.appName.toLowerCase())) {
          _speech.stop();
          widget.onSuccess();
          Navigator.of(context).pop(true);
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _showVoiceError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade900),
    );
  }

  void _validatePassword() {
    if (_passwordController.text == widget.interrupt.customPassword) {
      widget.onSuccess();
      Navigator.of(context).pop(true);
    } else {
      setState(() => _showPasswordError = true);
    }
  }

  void _proceedAfterTimer() {
    if (_timerComplete) {
      widget.onSuccess();
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _passwordController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          false, // Don't allow dismissing - user must complete the interrupt
      child: Dialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App name only - minimal header
              Text(
                widget.interrupt.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // Reminder message (if enabled)
              if (widget.interrupt.showReminder &&
                  widget.interrupt.reminderMessage != null)
                _buildReminderSection(),

              // Interrupt method content
              _buildInterruptContent(),

              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remember:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.interrupt.reminderMessage!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterruptContent() {
    final method = widget.interrupt.method;

    if (method.usesVoice) {
      return _buildVoiceContent();
    } else if (method.requiresPassword) {
      return _buildPasswordContent();
    } else if (method.usesTimer) {
      return _buildTimerContent();
    }

    return const SizedBox.shrink();
  }

  Widget _buildTimerContent() {
    return Column(
      children: [
        Text(
          _timerComplete ? 'Ready to proceed' : 'Please wait...',
          style: TextStyle(
            color: _timerComplete
                ? Colors.green.shade400
                : const Color.fromARGB(255, 252, 178, 67),
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: _timerComplete ? 1.0 : (30 - _remainingSeconds) / 30,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timerComplete
                        ? Colors.green.shade400
                        : Colors.orange.shade400,
                  ),
                ),
              ),
              Text(
                _timerComplete ? '✓' : '$_remainingSeconds',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _timerComplete ? 40 : 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordContent() {
    return Column(
      children: [
        const Text(
          'Enter password to continue',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: _showPasswordError ? 'Incorrect password' : null,
            errorStyle: const TextStyle(color: Colors.red),
          ),
          onSubmitted: (_) => _validatePassword(),
        ),
      ],
    );
  }

  Widget _buildVoiceContent() {
    return Column(
      children: [
        Text(
          _isListening
              ? 'Listening...'
              : 'Say "${widget.interrupt.appName}" to continue',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _isListening ? null : _startListening,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.red.shade700 : Colors.blue.shade700,
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Heard: "$_recognizedText"',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
        if (!_speechAvailable) ...[
          const SizedBox(height: 16),
          const Text(
            'Tap the microphone to start.',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    final method = widget.interrupt.method;

    if (method.requiresPassword) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _validatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (method.usesTimer) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _timerComplete ? _proceedAfterTimer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _timerComplete
                ? Colors.green.shade700
                : Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _timerComplete ? 'Continue' : 'Wait $_remainingSeconds seconds',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
