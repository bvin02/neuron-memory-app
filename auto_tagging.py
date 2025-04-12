import spacy
import yake
import os
import pandas as pd
import re

summary_text = (
    """ Meeting Summary: YOLOv8 for Drone Navigation

Overview:
Evaluated YOLOv8 for object detection in aerial navigation.

Key Concepts:
- Custom training done on obstacle-heavy datasets.
- High-altitude accuracy confirmed.

Next Steps:
- Integrate detection outputs with autonomous path planning logic.
"""
)


# Load spaCy English model
nlp = spacy.load("en_core_web_sm")

# Define stoplist to exclude generic, cross-topic terms
stop_tags = {
    "overview", "summary", "key concepts", "next steps", "current progress", 
    "structure", "method", "logic", "discussion", "result", "task", "step", "conclusion"
}

def generate_general_tags(summary, max_tags=4):
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
        if len(tag) > 2 and tag not in stop_tags and not tag.startswith("•")
    ]
    
    # Scoring
    def score(tag):
        s = 0
        if len(tag.split()) >= 3:
            s += 1
        if len(tag.split()) == 2:
            s += 2
        if len(tag.split()) == 1:
            s += 1
        
        
        return s

    # Sort, deduplicate, return top N
    sorted_tags = sorted(set(filtered), key=score, reverse=True)
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



def clean_tag(tag):
    tag = tag.lower().strip()
    tag = re.sub(r"[^a-z0-9\s]", "", tag)  # remove all non-alphanumeric characters except spaces
    tag = re.sub(r"\s+", " ", tag)         # normalize whitespace
    return tag


tags = generate_general_tags(summary_text)
tags = [clean_tag(tag) for tag in tags]
print("Generated Tags:" , tags)
