# Step 1: Import necessary libraries
from sentence_transformers import SentenceTransformer, util
import numpy as np

# Step 2: Load the all-mini-lm model
# 'all-MiniLM-L6-v2' is one of the popular variants in the all-mini-lm family
model = SentenceTransformer('all-MiniLM-L6-v2')

# Step 3: Define the summary text (this should be the output of your summarization model)
summary_text = (
    "The study highlights significant advancements in the field of renewable energy, "
    "demonstrating that innovative solar panels can substantially increase energy efficiency "
    "while reducing costs. The research suggests a promising future for widespread adoption and further development."
)

# Step 4: Generate the embedding for the summary
embedding = model.encode(summary_text)

# Optionally, normalize the embedding if you plan to use it in cosine similarity searches later
embedding_normalized = embedding / np.linalg.norm(embedding)

# Step 5: Output the results
print("Embedding vector shape:", embedding.shape)
print("Normalized embedding (first 5 values):", embedding_normalized[:5])


summary_text = (
    "We used python technlogies 3.9.9 and PyTorch 1.10.1 to train and test our models, but the codebase is expected to be compatible with Python 3.8-3.11 and recent PyTorch versions. The codebase also depends on a few Python packages, most notably OpenAI's tiktoken for their fast tokenizer implementation. You can download and install (or update to) the latest release of Whisper with the following command:"
)
# Step 4: Generate the embedding for the summary
embedding2 = model.encode(summary_text)

# Optionally, normalize the embedding if you plan to use it in cosine similarity searches later
embedding_normalized = embedding2 / np.linalg.norm(embedding2)
print("Normalized embedding (first 5 values):", embedding_normalized[:5])

cosine_sim = util.cos_sim(embedding, embedding2)

print("Cosine Similarity:", cosine_sim.item())