from sentence_transformers import util
import torch
import json

with open("db.json", "r") as f:
    notes = json.load(f)

note_embeddings = []
note_ids = []

for note in notes:
    if "embedding" in note and note["embedding"]:
        note_embeddings.append(torch.tensor(note["embedding"]))
        note_ids.append(note["id"])

for i, note in enumerate(notes):
    if not note.get("embedding"):
        continue  # skip if no embedding

    current_id = note["id"]
    current_emb = torch.tensor(note["embedding"]).unsqueeze(0)  # shape: (1, dim)
    print("Current ID:", current_id)
    # Compare with all other embeddings
    others = torch.stack([
        emb for j, emb in enumerate(note_embeddings) if j != i - 1
    ])
    other_ids = [note_ids[j] for j in range(len(note_ids)) if j != i - 1]

    similarities = util.cos_sim(current_emb, others).squeeze(0)  # shape: (N,)
    print(similarities)
    top_matches = [
        (other_ids[j], similarities[j].item())
        for j in range(len(other_ids)) if similarities[j] >= 0.7
    ]
    print("Top matches:", top_matches)

    # Sort and keep top 3
    top_matches.sort(key=lambda x: x[1], reverse=True)
    backlinks = [match[0] for match in top_matches[:3]]

    # Update backlinks field
    note["backlinks"] = backlinks
    
with open("db.json", "w") as f:
    json.dump(notes, f, indent=4)
# cosine_sim = util.cos_sim(embedding, embedding2)

# print("Cosine Similarity:", cosine_sim.item())