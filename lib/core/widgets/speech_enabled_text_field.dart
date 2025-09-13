import 'dart:async';
import 'package:flutter/material.dart';
import 'package:storytales/core/services/speech/speech_to_text_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// A text field that supports both typing and speech-to-text input
class SpeechEnabledTextField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final VoidCallback? onSpeechStart;
  final VoidCallback? onSpeechEnd;
  final Function(String)? onSpeechResult;
  final Function(String)? onSpeechError;

  const SpeechEnabledTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.style,
    this.maxLines,
    this.minLines,
    this.validator,
    this.onSpeechStart,
    this.onSpeechEnd,
    this.onSpeechResult,
    this.onSpeechError,
  });

  @override
  State<SpeechEnabledTextField> createState() => _SpeechEnabledTextFieldState();
}

class _SpeechEnabledTextFieldState extends State<SpeechEnabledTextField>
    with SingleTickerProviderStateMixin {
  final SpeechToTextService _speechService = SpeechToTextService();
  
  StreamSubscription<String>? _speechSubscription;
  StreamSubscription<bool>? _listeningSubscription;
  StreamSubscription<String>? _errorSubscription;
  
  bool _isListening = false;
  bool _speechAvailable = false;
  String _speechText = '';
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speechService.isAvailable;
    
    if (_speechAvailable) {
      _speechSubscription = _speechService.speechStream.listen((text) {
        setState(() {
          _speechText = text;
        });
        
        // Update the text field with speech result
        final currentText = widget.controller.text;
        final newText = _combineTextAndSpeech(currentText, text);
        widget.controller.text = newText;
        
        widget.onSpeechResult?.call(text);
      });
      
      _listeningSubscription = _speechService.listeningStream.listen((listening) {
        setState(() {
          _isListening = listening;
        });
        
        if (listening) {
          widget.onSpeechStart?.call();
          _animationController.repeat(reverse: true);
        } else {
          widget.onSpeechEnd?.call();
          _animationController.stop();
          _animationController.reset();
        }
      });
      
      _errorSubscription = _speechService.errorStream.listen((error) {
        widget.onSpeechError?.call(error);
        
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText(
                text: error,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: StoryTalesTheme.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  String _combineTextAndSpeech(String currentText, String speechText) {
    if (currentText.isEmpty) {
      return speechText;
    }
    
    // If current text doesn't end with punctuation or whitespace, add a space
    final needsSpace = currentText.isNotEmpty && 
        !currentText.endsWith(' ') && 
        !currentText.endsWith('.') && 
        !currentText.endsWith('!') && 
        !currentText.endsWith('?') &&
        !currentText.endsWith(',');
    
    return currentText + (needsSpace ? ' ' : '') + speechText;
  }

  void _toggleSpeech() async {
    if (!_speechAvailable) {
      widget.onSpeechError?.call('Speech recognition is not available on this device');
      return;
    }

    if (_isListening) {
      await _speechService.stopListening();
    } else {
      await _speechService.startListening();
    }
  }

  Widget _buildMicrophoneButton() {
    if (!_speechAvailable) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleSpeech,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isListening 
                        ? StoryTalesTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: _isListening 
                        ? Border.all(color: StoryTalesTheme.primaryColor, width: 1)
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening 
                        ? StoryTalesTheme.primaryColor 
                        : StoryTalesTheme.textLightColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeechIndicator() {
    if (!_isListening || _speechText.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic,
            size: 16,
            color: StoryTalesTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: ResponsiveText(
              text: 'Listening: "$_speechText"',
              style: TextStyle(
                fontSize: 12,
                color: StoryTalesTheme.primaryColor,
                fontFamily: StoryTalesTheme.fontFamilyBody,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration ?? const InputDecoration();
    final updatedDecoration = decoration.copyWith(
      suffixIcon: _buildMicrophoneButton(),
      hintText: _speechAvailable 
          ? (decoration.hintText ?? 'Type or speak your message')
          : decoration.hintText,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: updatedDecoration,
          style: widget.style,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          validator: widget.validator,
        ),
        _buildSpeechIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechSubscription?.cancel();
    _listeningSubscription?.cancel();
    _errorSubscription?.cancel();
    _speechService.dispose();
    super.dispose();
  }
}