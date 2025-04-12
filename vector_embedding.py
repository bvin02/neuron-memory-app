# Step 1: Import necessary libraries
from sentence_transformers import SentenceTransformer, util
import numpy as np

# Step 2: Load the all-mini-lm model
# 'all-MiniLM-L6-v2' is one of the popular variants in the all-mini-lm family
model = SentenceTransformer('all-MiniLM-L6-v2')

# Step 3: Define the summary text (this should be the output of your summarization model)
summary_text = (
   """ Meeting Summary: Google Maps API Integration

Overview:
Discussion focused on integrating Google Maps API for location-based business search and routing.

Key Concepts:
- Enabled proper billing and permissions for API functionality.
- Users can now search for nearby businesses and get visual routes.

Next Steps:
- Customize map markers with branded icons.
- Implement filters for categories (e.g., restaurants, stores).
"""
)

# Step 4: Generate the embedding for the summary
embedding = model.encode(summary_text)

# Optionally, normalize the embedding if you plan to use it in cosine similarity searches later
embedding_normalized = embedding / np.linalg.norm(embedding)

# Step 5: Output the results
print("Embedding vector shape:", embedding.shape)
print("Normalized embedding (first 5 values):", embedding_normalized[:5])


summary_text = ("""
Meeting Summary: Arbitrage Model for Index Basket Trading

Overview:
We discussed implementing an arbitrage trading model based on pricing inefficiencies between index baskets and their underlying assets.

Key Concepts:
- Arbitrage Definition: Exploiting price discrepancies between an index (e.g., S&P-like basket) and its component stocks.
- Pricing Inefficiencies: The sum of individual stock prices may not match the index price due to supply-demand dynamics, creating arbitrage opportunities.
- Strategy:
  - If index price > sum of components → Short index, Long components.
  - If index price < sum of components → Long index, Short components.
  - Positions are liquidated when prices converge.

Structure:
- Three assets and two baskets:
  1. Basket A – contains all 3 assets.
  2. Basket B – contains 2 of the 3.
- Types of Arbitrage:
  1. Arbitrage between Basket A and all 3 products.
  2. Arbitrage between Basket B and the 2 products.
  3. Arbitrage using Basket A = Basket B + Product 3.

Current Progress:
- Entry logic for trades has been implemented.
- Remaining Tasks:
  - Implement position liquidation logic when prices converge.
  - Ensure no position limits are exceeded when using overlapping products across multiple baskets.
""")

# Step 4: Generate the embedding for the summary
embedding2 = model.encode(summary_text)

# Optionally, normalize the embedding if you plan to use it in cosine similarity searches later
embedding_normalized = embedding2 / np.linalg.norm(embedding2)
print("Normalized embedding (first 5 values):", embedding_normalized[:5])

cosine_sim = util.cos_sim(embedding, embedding2)

print("Cosine Similarity:", cosine_sim.item())