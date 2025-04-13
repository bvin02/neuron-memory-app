# neuron
Catapult | AI x Hackathon | Purdue 2025


![433052705-81124ce3-2d0d-4304-9276-55118d1818ab (1)](https://github.com/user-attachments/assets/f49e699f-ab3b-4c00-bf41-8ca75347a9d0)


## Inspiration

In today’s fast-paced work environments, it’s easy to forget what was said, decided, or discussed during meetings, lectures, and personal conversations. We take notes, but they're often incomplete or difficult to understand. We record audio, but rarely go back to listen. What if you had an intelligent memory system that could listen, understand, and remember - like your very own personal assistant?

We built Neuron to capture that idea. It not only transcribes your meetings, but also generates instant meeting summaries and intelligently tags key ideas for fast retrieval, all without needing the cloud and kept completely hands free. Neuron knows your schedule, listens in on those events, generates high quality markdown notes, catches the details you miss. We all would love our own personal assistant, and Neuron ensures your thoughts stay private, accessible, and actionable so that you can focus on what really matters.


## What it does

Neuron is a mobile-first AI app that helps users capture, summarize, and search their daily thoughts and meetings. Some of the key features of this app:

Records audio from meetings and converts it to text in real time
Summarizes transcriptions into concise, readable meeting notes
Generates vector embeddings to represent the each note semantically
Assigns context-aware tags to the note for easy search and filtering
Works completely offline, ensuring privacy and confidentiality, as well as low latency
Calendar integration and event creation capabilities with your phone's Google Calendar


## How we built it

We designed various algorithms and implemented models within this app:

Flutter was used to develop the clean and responsive mobile UI
Whisper (from OpenAI) was leveraged for offline yet robust audio transcription
Fine-tuned Llama3.2:1b for on-device summarizations of transcriptions
Vector embeddings are generated using sentence-transformers (all-MiniLm-L6-v2), and stored locally in a vector database


## Core Features

📜 Offline Transcription using Whisper

✂️ Summarization for digestible meeting notes

🧩 Auto-tagging using contextual NLP

🔍 Semantic Search via vector embeddings

📴 Offline-first Architecture for full privacy


## Challenges we ran into

Balancing performance vs. accuracy in summary and embedding generation on mobile hardware
Ensuring the embedding and tagging pipeline worked consistently across a wide range of topics
Accomplishments that we're proud of

Successfully running end-to-end vector search and summarization offline on a mobile device
Implementing a custom tagging system that adapts to any domain — no need for predefined labels
Calendar system that seamlessly integrates with your Google Calendar, allowing users to create, edit, and delete right from the app


## What we learned

Running even small LLMs on-device requires careful optimization and consideration of hardware requirements
Embeddings offer more than search — they're the key to building memory graphs and context linking
What's next for Neuron

Stay tuned for the next updates of Neuron. We plan to continue enhancing it so that it can improve your life. Here are some sneak peaks of our upcoming features:

Back up data securely on cloud as protection against loss of  local storage
Add a focus directed graph to visually display various links between notes
Automatically schedule recordings based on your calendar, so you never miss a meeting
Attach images, screenshots, and sketches to your memory timeline for richer context

https://devpost.com/software/neuron-k8ij9s?ref_content=user-portfolio&ref_feature=in_progress
