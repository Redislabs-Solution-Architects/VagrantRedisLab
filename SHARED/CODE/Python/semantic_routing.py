from redisvl.extensions.router import Route
import os
from redisvl.extensions.router import SemanticRouter
from redisvl.utils.vectorize import HFTextVectorizer


# Define routes for the semantic router
genai = Route(
    name="genai",
    references=[
        "Introduction to GenAI",
        "GenAI Fundamentals",
        "Machine Learning",
        "Natural Language Processing (NLP)",
        "search all"
    ],
    metadata={"category": "tech", "priority": 1},
    distance_threshold=1.0
)

scifi = Route(
    name="scifi",
    references=[
        "tell me about the upcoming scifi events",
        "what's the latest in the world of scifi?",
        "scifi",
        "a space opera revolutionized the science fiction film",
        "sci-fi series",
        "sci-fi movies",
        "what are the top Science fiction movies right now?",
        "search all"
    ],
    metadata={"category": "scifi", "priority": 2},
    distance_threshold=0.5
)

classicmusic = Route(
    name="classicmusic",
    references=[
        "Who was the most productive classical music composer?",
        "The iconic opening motif that launched classical music into the modern era.",
        "A beautiful, melancholic piano piece",
        "search all"
    ],
    metadata={"category": "classic,usic", "priority": 3},
    distance_threshold=0.7
)

os.environ["TOKENIZERS_PARALLELISM"] = "false"

# Initialize the SemanticRouter
router = SemanticRouter(
    name="topic-router",
    vectorizer=HFTextVectorizer(),
    routes=[genai, scifi, classicmusic],
    redis_url="redis://redis-10001.rc1.example.com:10001",
    overwrite=True  # Blow away any other routing index with this name
)

router.vectorizer

print("Can you tell me about the NLP?")
route_match = router("Can you tell me about the NLP?")
print(route_match)

print("Can you list classic music composers?")
route_match = router("Can you list classic music composers?")
print(route_match)

print("Can you suggest scifi movie?")
route_match = router("Can you suggest scifi movie?")
print(route_match)

print("Search all")
route_matches = router.route_many("Search all", max_k=3)
print(route_match)


# Use clear to flush all routes from the index
router.clear()
# Use delete to clear the index and remove it completely
router.delete()
