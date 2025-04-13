import spacy
import yake
import os
import pandas as pd
import re
from collections import Counter


summary_text = (
    """Meeting Summary: Arbitrage Model for Index Basket Trading

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

"""
)


# Load spaCy English model
nlp = spacy.load("en_core_web_sm")

# Define stoplist to exclude generic, cross-topic terms
stop_tags = {
    "overview", "summary", "key concepts", "next steps", "current progress", 
    "structure", "method", "logic", "discussion", "result", "task", "step", "conclusion", "a"
}

def generate_general_tags(summary, word_freq, max_tags=4):
    doc = nlp(summary)

    # Extract candidates
    noun_phrases = [chunk.text.lower().strip() for chunk in doc.noun_chunks]
    named_entities = [ent.text.lower().strip() for ent in doc.ents]

    # YAKE keyword extraction
    kw_extractor = yake.KeywordExtractor(lan="en", n=3, top=max_tags * 5)
    keywords = [kw[0].lower().strip() for kw in kw_extractor.extract_keywords(summary)]

    # Combine and filter
    candidates = noun_phrases + named_entities + keywords
    filtered = [
    tag for tag in candidates
    if len(tag) > 2
    and tag not in stop_tags
    and not tag.startswith("•")
    and 1 <= len(tag.split()) <= 3
]
    
    # Scoring function
    def score(tag):
        s = 0
        words = tag.split()
        n_words = len(words)
        tag_freq_score = sum(word_freq.get(word, 0) for word in words)
        s += tag_freq_score
        if n_words >= 3:
            s -= 1
        elif n_words == 2:
            s += 2
        elif n_words == 1:
            s += 2
        
        if n_words <= 3 and any(char.isdigit() for char in tag):
            s += 1
       
        return s

    # Sort and select top tags
    sorted_tags = sorted(set(filtered), key=lambda tag: score(tag), reverse=True)
    
    seen = set()
    tags = []
    for tag in sorted_tags:
        base = tag.lower().strip()
        if base not in seen:
            tags.append(base)
            seen.add(base)
        if len(tags) >= max_tags:
            break

    return tags


def get_word_frequency(text):
    doc = nlp(text.lower())
    word_freq = Counter([token.text for token in doc if token.is_alpha and not token.is_stop])
    return word_freq

def clean_tag(tag):
    tag = tag.lower().strip()
    tag = re.sub(r"[^a-z0-9\s\-]", "", tag)  # remove all non-alphanumeric characters except spaces
    tag = re.sub(r"\s+", " ", tag)         # normalize whitespace
    return tag

# word_freq = get_word_frequency(summary_text)
tags = generate_general_tags(summary_text, get_word_frequency(summary_text), max_tags=4)
tags = [clean_tag(tag) for tag in tags]
print("Generated Tags:" , tags)
