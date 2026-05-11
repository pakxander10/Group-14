"""
Ascend — FastAPI Backend
Run: uvicorn main:app --reload
Base URL: http://127.0.0.1:8000
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import uuid

app = FastAPI(title="Ascend API", version="1.0.0")

# ─── CORS (allow iOS simulator / local dev) ──────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ══════════════════════════════════════════════════════════════
# PYDANTIC MODELS
# ══════════════════════════════════════════════════════════════

class LearnerProfile(BaseModel):
    id: str
    name: str
    age: int
    background: str          # e.g. "first_gen", "general"
    interest: str            # "financial" | "tech"
    goal: str                # e.g. "investing", "career", "budgeting"
    confidence_score: int = 100


class MentorProfile(BaseModel):
    id: str
    name: str
    title: str
    company: str = "Fidelity Investments"
    track: str               # "Financial" | "Tech"
    bio: str
    expertise: list[str]
    years_experience: int
    avatar_initials: str


class ThreadReply(BaseModel):
    id: str
    author_name: str
    author_role: str         # "learner" | "mentor"
    body: str
    upvotes: int = 0


class ThreadPost(BaseModel):
    id: str
    author_name: str
    author_role: str         # "learner" | "mentor"
    title: str
    body: str
    upvotes: int = 0
    replies: list[ThreadReply] = []


class QuestionnaireRequest(BaseModel):
    age: int
    background: str          # "first_gen" | "general"
    interest: str            # "financial" | "tech"
    goal: str                # "investing" | "budgeting" | "career" | "coding" | "interview_prep"


class ConfidenceUpdateRequest(BaseModel):
    delta: int               # positive or negative adjustment


# ══════════════════════════════════════════════════════════════
# MOCK DATABASE (in-memory Python dicts — no disk I/O needed)
# ══════════════════════════════════════════════════════════════

MOCK_MENTORS: dict[str, MentorProfile] = {
    "m1": MentorProfile(
        id="m1",
        name="Priya Sharma",
        title="Senior Financial Advisor",
        track="Financial",
        bio="10-year veteran at Fidelity specializing in helping first-gen investors build wealth through index funds and tax-advantaged accounts.",
        expertise=["Index Investing", "Roth IRA", "Budgeting", "Debt Payoff"],
        years_experience=10,
        avatar_initials="PS",
    ),
    "m2": MentorProfile(
        id="m2",
        name="Jordan Lee",
        title="Software Engineer II",
        track="Tech",
        bio="Full-stack engineer who broke into tech from a non-CS background. Passionate about helping first-gen students land their first tech role.",
        expertise=["Python", "System Design", "Interview Prep", "Networking"],
        years_experience=5,
        avatar_initials="JL",
    ),
    "m3": MentorProfile(
        id="m3",
        name="Amara Okafor",
        title="Wealth Management Analyst",
        track="Financial",
        bio="Specializes in financial literacy for young women — from emergency funds to stock market basics.",
        expertise=["Emergency Fund", "Stock Market Basics", "401k", "Credit Score"],
        years_experience=7,
        avatar_initials="AO",
    ),
}

MOCK_LEARNERS: dict[str, LearnerProfile] = {
    "u1": LearnerProfile(
        id="u1",
        name="Sofia Rodriguez",
        age=22,
        background="first_gen",
        interest="financial",
        goal="investing",
        confidence_score=340,
    )
}

MOCK_THREAD_POSTS: list[ThreadPost] = [
    ThreadPost(
        id="p1",
        author_name="Sofia Rodriguez",
        author_role="learner",
        title="How do I start investing with only $50/month?",
        body="I'm a first-gen college student with a part-time job. I can only save about $50 a month. Is it even worth starting to invest with that amount? Where do I begin?",
        upvotes=24,
        replies=[
            ThreadReply(
                id="r1",
                author_name="Priya Sharma",
                author_role="mentor",
                body="Absolutely worth it! Start with a Roth IRA — you can open one with $0 at Fidelity and invest in a broad index fund like FZROX (0% expense ratio). Even $50/month compounding over 40 years grows to ~$150k. Time in the market beats timing the market every time.",
                upvotes=18,
            )
        ],
    ),
    ThreadPost(
        id="p2",
        author_name="Kezia Mensah",
        author_role="learner",
        title="Tips for breaking into tech without a CS degree?",
        body="I'm a first-gen student majoring in Business. I love coding but my school doesn't have a CS program. How do I compete with CS graduates for software jobs?",
        upvotes=31,
        replies=[
            ThreadReply(
                id="r2",
                author_name="Jordan Lee",
                author_role="mentor",
                body="I did exactly this! Three things that got me hired: (1) Build 2–3 real portfolio projects on GitHub — quality over quantity. (2) Get comfortable with LeetCode Easy/Mediums. (3) Network relentlessly on LinkedIn. Reach out to engineers for 15-min coffee chats. Your business background is actually a differentiator — lean into it.",
                upvotes=27,
            )
        ],
    ),
]


# ══════════════════════════════════════════════════════════════
# ENDPOINTS
# ══════════════════════════════════════════════════════════════

@app.get("/")
def root():
    return {"message": "Ascend API is running 🚀"}


# ── GET /feed ─────────────────────────────────────────────────
@app.get("/feed", response_model=list[ThreadPost])
def get_feed():
    """Returns all thread posts sorted by upvotes descending."""
    return sorted(MOCK_THREAD_POSTS, key=lambda p: p.upvotes, reverse=True)


# ── POST /questionnaire ───────────────────────────────────────
@app.post("/questionnaire", response_model=MentorProfile)
def submit_questionnaire(answers: QuestionnaireRequest):
    """
    Simple matching logic:
    - interest == "tech"       → Jordan Lee (Tech track)
    - interest == "financial"  → Priya Sharma if goal is investing, else Amara Okafor
    """
    if answers.interest == "tech":
        return MOCK_MENTORS["m2"]

    # Financial track — refine by goal
    investing_goals = {"investing", "stock_market", "retirement"}
    if answers.goal in investing_goals:
        return MOCK_MENTORS["m1"]

    return MOCK_MENTORS["m3"]


# ── PUT /confidence/{user_id} ─────────────────────────────────
@app.put("/confidence/{user_id}", response_model=LearnerProfile)
def update_confidence(user_id: str, body: ConfidenceUpdateRequest):
    """Applies a delta to the user's confidence score (clamps 1–1000)."""
    learner = MOCK_LEARNERS.get(user_id)
    if not learner:
        raise HTTPException(status_code=404, detail=f"User '{user_id}' not found.")

    new_score = max(1, min(1000, learner.confidence_score + body.delta))
    learner.confidence_score = new_score
    MOCK_LEARNERS[user_id] = learner
    return learner


# ── GET /mentors ──────────────────────────────────────────────
@app.get("/mentors", response_model=list[MentorProfile])
def get_mentors():
    """Returns all available mentors."""
    return list(MOCK_MENTORS.values())


# ── GET /profile/{user_id} ────────────────────────────────────
@app.get("/profile/{user_id}", response_model=LearnerProfile)
def get_profile(user_id: str):
    learner = MOCK_LEARNERS.get(user_id)
    if not learner:
        raise HTTPException(status_code=404, detail=f"User '{user_id}' not found.")
    return learner
