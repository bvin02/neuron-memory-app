# Step 1: Import necessary libraries
from sentence_transformers import SentenceTransformer, util
import numpy as np

# Step 2: Load the all-mini-lm model

model = SentenceTransformer('all-MiniLM-L6-v2')

def generate_embedding(text, normalize=True):
    """
    Generate an embedding for the given text using the SentenceTransformer model.
    
    Args:
        text (str): The input text to be embedded.
        
    Returns:
        np.ndarray: The generated embedding vector.
    """
    
    # # Step 3: Define the summary text (this should be the output of your summarization model)
    # summary_text = (
    # """ Meeting Summary: Google Maps API Integration

    # Overview:
    # Discussion focused on integrating Google Maps API for location-based business search and routing.

    # Key Concepts:
    # - Enabled proper billing and permissions for API functionality.
    # - Users can now search for nearby businesses and get visual routes.

    # Next Steps:
    # - Customize map markers with branded icons.
    # - Implement filters for categories (e.g., restaurants, stores).
    # """
    # )

    embedding = model.encode(text, convert_to_tensor=True)

    embedding_normalized = embedding / np.linalg.norm(embedding)

    # Step 5: Output the results
    print("Embedding vector shape:", embedding.shape)
    print("Normalized embedding (first 5 values):", embedding_normalized[:5])

    return embedding.tolist()
