"""
Ascend — FastAPI Backend
Run: uvicorn main:app --reload
Base URL: http://127.0.0.1:8000
"""

import uuid
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

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

    # Optional onboarding fields (collected on first launch)
    profile_picture: Optional[bytes] = None
    type_of_school: Optional[str] = None
    graduation_year: Optional[int] = None
    gender: Optional[str] = None
    occupation_major: Optional[str] = None


class CreateLearnerRequest(BaseModel):
    name: str
    profile_picture: Optional[bytes] = None
    type_of_school: str
    graduation_year: int
    gender: str
    occupation_major: str
    current_confidence_score: int
    # Filled later via questionnaire; defaulted here so onboarding can
    # complete before the questionnaire step.
    age: int = 0
    background: str = "general"
    interest: str = "financial"
    goal: str = "career"


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
    email: Optional[str] = None
    linked_in_url: Optional[str] = None
    education_history: Optional[list[str]] = None
    profile_picture: Optional[bytes] = None


class CreateMentorRequest(BaseModel):
    name: str
    title: str
    company: str = "Fidelity Investments"
    track: str               # "Financial" | "Tech"
    bio: str
    expertise: list[str]
    years_experience: int
    avatar_initials: str
    email: Optional[str] = None
    linked_in_url: Optional[str] = None
    education_history: Optional[list[str]] = None
    profile_picture: Optional[bytes] = None


class User(BaseModel):
    """Lightweight identity used by the threading system. Either a learner or a mentor."""
    id: str
    name: str
    role: str                # "learner" | "mentor"


class ThreadReply(BaseModel):
    id: str
    post_id: str
    author_id: str
    author_name: str
    author_role: str         # "learner" | "mentor"
    body: str
    upvotes: int = 0


class ThreadPost(BaseModel):
    id: str
    author_id: str
    author_name: str
    author_role: str         # "learner" | "mentor"
    category: str            # "Financial" | "Tech" — mirrors MentorTrack
    title: str
    body: str
    upvotes: int = 0
    replies: list[ThreadReply] = []


class Notification(BaseModel):
    id: str
    learner_id: str          # recipient
    post_id: str
    post_title: str
    mentor_id: str
    mentor_name: str
    reply_preview: str
    created_at: str          # ISO-8601 UTC


class CreatePostRequest(BaseModel):
    author_id: str
    category: str            # "Financial" | "Tech"
    title: str
    body: str


class CreateReplyRequest(BaseModel):
    post_id: str
    author_id: str
    body: str


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
        email="priya.sharma@fidelity.com",
        linked_in_url="linkedin.com/in/priyasharma",
        education_history=["MBA Finance, NYU Stern", "BS Economics, UCLA"],
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
        email="jordan.lee@fidelity.com",
        linked_in_url="linkedin.com/in/jordanlee",
        education_history=["BA English, UNC Chapel Hill"],
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
        email="amara.okafor@fidelity.com",
        linked_in_url="linkedin.com/in/amaraokafor",
        education_history=["BS Finance, Spelman College"],
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
    ),
    "u2": LearnerProfile(
        id="u2",
        name="Kezia Mensah",
        age=20,
        background="first_gen",
        interest="tech",
        goal="career",
        confidence_score=210,
    ),
}

MOCK_THREAD_POSTS: dict[str, ThreadPost] = {
    "p1": ThreadPost(
        id="p1",
        author_id="u1",
        author_name="Sofia Rodriguez",
        author_role="learner",
        category="Financial",
        title="How do I start investing with only $50/month?",
        body="I'm a first-gen college student with a part-time job. I can only save about $50 a month. Is it even worth starting to invest with that amount? Where do I begin?",
        upvotes=24,
        replies=[
            ThreadReply(
                id="r1",
                post_id="p1",
                author_id="m1",
                author_name="Priya Sharma",
                author_role="mentor",
                body="Absolutely worth it! Start with a Roth IRA — you can open one with $0 at Fidelity and invest in a broad index fund like FZROX (0% expense ratio). Even $50/month compounding over 40 years grows to ~$150k. Time in the market beats timing the market every time.",
                upvotes=18,
            )
        ],
    ),
    "p2": ThreadPost(
        id="p2",
        author_id="u2",
        author_name="Kezia Mensah",
        author_role="learner",
        category="Tech",
        title="Tips for breaking into tech without a CS degree?",
        body="I'm a first-gen student majoring in Business. I love coding but my school doesn't have a CS program. How do I compete with CS graduates for software jobs?",
        upvotes=31,
        replies=[
            ThreadReply(
                id="r2",
                post_id="p2",
                author_id="m2",
                author_name="Jordan Lee",
                author_role="mentor",
                body="I did exactly this! Three things that got me hired: (1) Build 2–3 real portfolio projects on GitHub — quality over quantity. (2) Get comfortable with LeetCode Easy/Mediums. (3) Network relentlessly on LinkedIn. Reach out to engineers for 15-min coffee chats. Your business background is actually a differentiator — lean into it.",
                upvotes=27,
            )
        ],
    ),
}

# Notifications keyed by learner_id. New notifications are appended on
# POST /replies whenever a mentor replies to a learner's post.
MOCK_NOTIFICATIONS: dict[str, list[Notification]] = {
    "u1": [],
    "u2": [],
}

# Confidence boost applied to a learner each time a mentor replies to one
# of their posts. Clamp range matches PUT /confidence/{user_id}.
MENTOR_REPLY_CONFIDENCE_BOOST = 10


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
    return sorted(MOCK_THREAD_POSTS.values(), key=lambda p: p.upvotes, reverse=True)


# ── POST /posts ───────────────────────────────────────────────
@app.post("/posts", response_model=ThreadPost, status_code=201)
def create_post(body: CreatePostRequest):
    """Create a new question. Learner-authored by convention; we resolve the
    author from MOCK_LEARNERS so the post carries an accurate display name."""
    learner = MOCK_LEARNERS.get(body.author_id)
    if not learner:
        raise HTTPException(
            status_code=404,
            detail=f"Learner '{body.author_id}' not found.",
        )
    if body.category not in {"Financial", "Tech"}:
        raise HTTPException(
            status_code=400,
            detail="category must be 'Financial' or 'Tech'.",
        )
    if not body.title.strip() or not body.body.strip():
        raise HTTPException(
            status_code=400,
            detail="Title and body are required.",
        )

    new_id = f"p{uuid.uuid4().hex[:6]}"
    post = ThreadPost(
        id=new_id,
        author_id=learner.id,
        author_name=learner.name,
        author_role="learner",
        category=body.category,
        title=body.title,
        body=body.body,
        upvotes=0,
        replies=[],
    )
    MOCK_THREAD_POSTS[new_id] = post
    return post


# ── POST /replies ─────────────────────────────────────────────
@app.post("/replies", response_model=ThreadReply, status_code=201)
def create_reply(body: CreateReplyRequest):
    """Mentor reply to a post. Side-effects when the post author is a learner:
       (1) append a Notification to that learner's inbox,
       (2) bump that learner's confidence_score by MENTOR_REPLY_CONFIDENCE_BOOST."""
    post = MOCK_THREAD_POSTS.get(body.post_id)
    if not post:
        raise HTTPException(status_code=404, detail=f"Post '{body.post_id}' not found.")

    mentor = MOCK_MENTORS.get(body.author_id)
    if not mentor:
        raise HTTPException(
            status_code=404,
            detail=f"Mentor '{body.author_id}' not found.",
        )
    if not body.body.strip():
        raise HTTPException(status_code=400, detail="Reply body is required.")

    new_id = f"r{uuid.uuid4().hex[:6]}"
    reply = ThreadReply(
        id=new_id,
        post_id=post.id,
        author_id=mentor.id,
        author_name=mentor.name,
        author_role="mentor",
        body=body.body,
        upvotes=0,
    )
    post.replies.append(reply)

    # Side-effects only fire when the original poster is a learner.
    if post.author_role == "learner":
        learner = MOCK_LEARNERS.get(post.author_id)
        if learner is not None:
            # 1. Notification
            notif = Notification(
                id=f"n{uuid.uuid4().hex[:6]}",
                learner_id=learner.id,
                post_id=post.id,
                post_title=post.title,
                mentor_id=mentor.id,
                mentor_name=mentor.name,
                reply_preview=reply.body[:140],
                created_at=datetime.now(timezone.utc).isoformat(),
            )
            MOCK_NOTIFICATIONS.setdefault(learner.id, []).append(notif)
            # 2. Confidence bump (clamped 1..1000, same as PUT /confidence)
            learner.confidence_score = max(
                1, min(1000, learner.confidence_score + MENTOR_REPLY_CONFIDENCE_BOOST)
            )

    return reply


# ── GET /inbox/{learner_id} ───────────────────────────────────
@app.get("/inbox/{learner_id}", response_model=list[Notification])
def get_inbox(learner_id: str):
    """Return notifications for a learner, most recent first."""
    if learner_id not in MOCK_LEARNERS:
        raise HTTPException(status_code=404, detail=f"Learner '{learner_id}' not found.")
    notifs = MOCK_NOTIFICATIONS.get(learner_id, [])
    return sorted(notifs, key=lambda n: n.created_at, reverse=True)


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


# ── POST /mentors ─────────────────────────────────────────────
@app.post("/mentors", response_model=MentorProfile, status_code=201)
def create_mentor(body: CreateMentorRequest):
    """Creates a new mentor from onboarding-form data. ID is server-generated."""
    new_id = f"m{uuid.uuid4().hex[:6]}"
    mentor = MentorProfile(
        id=new_id,
        name=body.name,
        title=body.title,
        company=body.company,
        track=body.track,
        bio=body.bio,
        expertise=body.expertise,
        years_experience=body.years_experience,
        avatar_initials=body.avatar_initials,
        email=body.email,
        linked_in_url=body.linked_in_url,
        education_history=body.education_history,
        profile_picture=body.profile_picture,
    )
    MOCK_MENTORS[new_id] = mentor
    return mentor


# ── POST /learners ────────────────────────────────────────────
@app.post("/learners", response_model=LearnerProfile, status_code=201)
def create_learner(body: CreateLearnerRequest):
    """Creates a new learner from onboarding-form data. ID is server-generated."""
    new_id = f"u{uuid.uuid4().hex[:6]}"
    learner = LearnerProfile(
        id=new_id,
        name=body.name,
        age=body.age,
        background=body.background,
        interest=body.interest,
        goal=body.goal,
        confidence_score=max(1, min(1000, body.current_confidence_score)),
        profile_picture=body.profile_picture,
        type_of_school=body.type_of_school,
        graduation_year=body.graduation_year,
        gender=body.gender,
        occupation_major=body.occupation_major,
    )
    MOCK_LEARNERS[new_id] = learner
    return learner
