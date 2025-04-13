import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final dylib = () {
  if (Platform.isIOS) return DynamicLibrary.process(); // already linked
  throw UnsupportedError("Only iOS supported in this example");
}();

typedef CRunWhisper = Int32 Function(
  Pointer<Utf8> modelPath,
  Pointer<Utf8> wavPath,
  Pointer<Utf8> outText,
  Int32 maxLen,
);

typedef DartRunWhisper = int Function(
  Pointer<Utf8> modelPath,
  Pointer<Utf8> wavPath,
  Pointer<Utf8> outText,
  int maxLen,
);

final runWhisper = dylib
    .lookup<NativeFunction<CRunWhisper>>('run_whisper')
    .asFunction<DartRunWhisper>();

/// Transcribes audio using Whisper
/// 
/// Returns a [String] containing the transcription text or throws an exception if processing failed
String transcribeAudio(String modelPath, String wavPath) {
  final modelPathPointer = modelPath.toNativeUtf8();
  final wavPathPointer = wavPath.toNativeUtf8();
  
  // Allocate a buffer for the output text (adjust size as needed)
  final int maxLen = 16 * 1024; // 16KB should be enough for most transcriptions
  final outTextPointer = malloc<Char>(maxLen);
  
  try {
    final result = runWhisper(
      modelPathPointer,
      wavPathPointer,
      outTextPointer.cast<Utf8>(),
      maxLen,
    );
    
    if (result < 0) {
      if (result == -1) {
        throw Exception("Failed to initialize Whisper model from: $modelPath");
      } else if (result == -2) {
        throw Exception("Failed to process audio file: $wavPath");
      } else {
        throw Exception("Unknown error during transcription: $result");
      }
    }
    
    return outTextPointer.cast<Utf8>().toDartString();
  } finally {
    // Always free allocated memory
    malloc.free(modelPathPointer);
    malloc.free(wavPathPointer);
    malloc.free(outTextPointer);
  }
}
