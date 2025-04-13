from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer

# Load the dataset (using JSON; your training file should be in JSONL format)
dataset = load_dataset("json", data_files={"train": "training_data.json"})

# Use the Llama 3.2 1B Instruct checkpoint; this requires trust_remote_code to be enabled.
model_checkpoint = "meta-llama/Llama-3.2-1B-Instruct"
tokenizer = AutoTokenizer.from_pretrained(model_checkpoint, trust_remote_code=True)

# Print out one example to verify the dataset structure.
print("Original Example:", dataset["train"][0])

# Preprocessing function to add the system prompt to the "text" field.
def preprocess_function(examples):
    system_prompt = (
        "Summarize the transcript below using structured bullet points. "
        "Focus only on key ideas and technical details:\n"
    )
    # Prepend the prompt to each transcript.
    input_texts = [system_prompt + txt for txt in examples["text"]]
    inputs = tokenizer(input_texts, max_length=1024, truncation=True)
    # Tokenize the target summaries.
    targets = tokenizer(examples["summary"], max_length=128, truncation=True)
    labels = targets.input_ids
    # Replace pad token id's with -100 so loss is not computed on padding.
    labels = [[(token if token != tokenizer.pad_token_id else -100) for token in label] for label in labels]
    inputs["labels"] = labels
    return inputs

# Map the preprocessing function over the dataset (batched processing for speed).
tokenized_dataset = dataset.map(preprocess_function, batched=True)

# Set up training arguments. (Note: For CPU training, set per_device_train_batch_size=1.)
training_args = TrainingArguments(
    output_dir="./llama3.2-finetuned-cpu",
    eval_strategy="no",   # Not using an eval set here
    learning_rate=2e-5,
    per_device_train_batch_size=1,  # Small batch size for CPU limitations
    num_train_epochs=3,
    weight_decay=0.01,
    logging_steps=100,
    save_total_limit=2,
    fp16=False  # Mixed precision is disabled on CPU
)

# Load the pre-trained Llama 3.2 model using the causal LM class.
model = AutoModelForCausalLM.from_pretrained(model_checkpoint, trust_remote_code=True)

# Initialize the Trainer. (We're using tokenized_dataset["train"] as the training data.)
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset["train"]
)

# Start fine-tuning.
trainer.train()

# Save the fine-tuned model and tokenizer.
trainer.save_model("./llama3.2-finetuned-cpu")
tokenizer.save_pretrained("./llama3.2-finetuned-cpu")

print("Fine-tuning complete and model saved.")
