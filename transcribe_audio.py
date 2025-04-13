import whisper
from jiwer import wer, cer, compute_measures, Compose, RemovePunctuation, ToLowerCase, Strip, RemoveMultipleSpaces
import string
import time 

# Load Whisper model
start = time.time()
model = whisper.load_model("tiny")  # or "tiny", "small", "medium", etc.

# Transcribe audio
transcribed_result = model.transcribe("audio-meeting.mp3")
transcribed_text = transcribed_result["text"].strip()
end = time.time()
transcription_duration = end - start
# # Actual ground truth text
# ground_truth_text = "I need your arms around me I need to feel your touch Hey Baby Im tired of waiting Go re-charge your batteries Come back to me and make your mama proud I need your arms around me I need to feel your touch And I really want to talk"

# # Compute detailed measures
# measures = compute_measures(
#     ground_truth_text,
#     transcribed_text,
    
# )

# # Display results
# print("Ground Truth:\n", ground_truth_text)
print("Transcription:\n", transcribed_text)
print("Transcription Duration:", transcription_duration, "seconds")
# print("\n--- Evaluation Metrics ---")
# print(f"WER (Word Error Rate): {measures['wer']:.2%}")
# print(f"Insertions: {measures['insertions']}")
# print(f"Deletions: {measures['deletions']}")
# print(f"Substitutions: {measures['substitutions']}")
