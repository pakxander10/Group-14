"""Ascend API — Hackathon MVP.

FastAPI + in-memory SQLite. Seeds 3 Fidelity mentors and 2 thread posts (each
with 1 reply), then exposes:
    GET  /feed
    POST /questionnaire   -> matched MentorProfile
    PUT  /confidence/{user_id}

Run:
    cd backend
    pip install -r requirements.txt
    uvicorn main:app --reload --host 0.0.0.0 --port 8000
"""

from __future__ import annotations

import json
import sqlite3
import uuid
from datetime import datetime, timezone
from typing import List, Literal, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

app = FastAPI(title="Ascend API", version="0.1.0")

# Open CORS — iOS simulator + Xcode previews hit us from arbitrary origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------- Pydantic Models ----------

Track = Literal["Financial", "Tech"]
Role = Literal["Learner", "Mentor"]


class LearnerProfile(BaseModel):
    id: str
    name: str
    email: str
    is_first_gen: bool = False
    interests: List[str] = []
    confidence_score: int = Field(500, ge=1, le=1000)
    track: Optional[Track] = None


class MentorProfile(BaseModel):
    id: str
    name: str
    title: str
    company: str = "Fidelity"
    track: Track
    years_experience: int
    bio: str
    specialties: List[str] = []


class ThreadReply(BaseModel):
    id: str
    post_id: str
    author_id: str
    author_name: str
    author_role: Role
    body: str
    created_at: str


class ThreadPost(BaseModel):
    id: str
    author_id: str
    author_name: str
    title: str
    body: str
    tags: List[str] = []
    created_at: str
    replies: List[ThreadReply] = []


class QuestionnaireAnswers(BaseModel):
    learner_id: str
    is_first_gen: bool
    interest_track: Track
    financial_goals: List[str] = []
    career_goals: List[str] = []
    preferred_experience_years: int = 5


class ConfidenceUpdate(BaseModel):
    score: int = Field(..., ge=1, le=1000)


class NewPost(BaseModel):
    author_id: str
    author_name: str
    title: str
    body: str
    tags: List[str] = []


class NewReply(BaseModel):
    author_id: str
    author_name: str
    author_role: Role
    body: str


# ---------- In-memory SQLite ----------

conn = sqlite3.connect(":memory:", check_same_thread=False)
conn.row_factory = sqlite3.Row

conn.executescript(
    """
    CREATE TABLE mentors (
        id TEXT PRIMARY KEY,
        name TEXT, title TEXT, company TEXT,
        track TEXT, years_experience INTEGER,
        bio TEXT, specialties TEXT
    );
    CREATE TABLE learners (
        id TEXT PRIMARY KEY,
        name TEXT, email TEXT,
        is_first_gen INTEGER,
        interests TEXT,
        confidence_score INTEGER,
        track TEXT
    );
    CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        author_id TEXT, author_name TEXT,
        title TEXT, body TEXT,
        tags TEXT, created_at TEXT
    );
    CREATE TABLE replies (
        id TEXT PRIMARY KEY,
        post_id TEXT, author_id TEXT, author_name TEXT,
        author_role TEXT, body TEXT, created_at TEXT
    );
    """
)


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _seed() -> None:
    mentors = [
        ("m1", "Priya Shah", "Senior Portfolio Manager", "Fidelity", "Financial", 12,
         "Helps first-gen students translate money anxiety into financial fluency.",
         ["Investing 101", "Roth IRAs", "Salary Negotiation"]),
        ("m2", "Jasmine Carter", "VP, Wealth Strategy", "Fidelity", "Financial", 15,
         "Champion for women's wealth-building and long-term career advocacy.",
         ["Retirement Planning", "Equity Compensation", "Career Pivots"]),
        ("m3", "Dr. Lin Wei", "Director of Engineering", "Fidelity", "Tech", 18,
         "Built her career from bootcamp grad to engineering leadership.",
         ["Software Engineering", "Career Growth", "Tech Leadership"]),
    ]
    conn.executemany(
        "INSERT INTO mentors VALUES (?,?,?,?,?,?,?,?)",
        [(m[0], m[1], m[2], m[3], m[4], m[5], m[6], json.dumps(m[7])) for m in mentors],
    )

    conn.execute(
        "INSERT INTO learners VALUES (?,?,?,?,?,?,?)",
        ("l1", "Maya Rodriguez", "maya@example.com", 1,
         json.dumps(["investing", "negotiation"]), 620, "Financial"),
    )

    now = _now()
    posts = [
        ("p1", "l1", "Maya R.",
         "How do I start investing on a $40k salary?",
         "Just got my first full-time offer and I'm overwhelmed. Where do I even begin?",
         ["investing", "first-job"]),
        ("p2", "l2", "Aisha B.",
         "Negotiating a tech offer as a first-gen grad",
         "I have an offer from a fintech and no idea what's normal to ask for. Help!",
         ["negotiation", "tech"]),
    ]
    conn.executemany(
        "INSERT INTO posts VALUES (?,?,?,?,?,?,?)",
        [(p[0], p[1], p[2], p[3], p[4], json.dumps(p[5]), now) for p in posts],
    )

    replies = [
        ("r1", "p1", "m1", "Priya Shah", "Mentor",
         "Start with your 401(k) match — that's free money. Then open a Roth IRA. "
         "DM me and I'll walk you through it.", now),
        ("r2", "p2", "m3", "Dr. Lin Wei", "Mentor",
         "Always negotiate. Ask for the salary band first. Total comp matters more than base.",
         now),
    ]
    conn.executemany("INSERT INTO replies VALUES (?,?,?,?,?,?,?)", replies)
    conn.commit()


_seed()


# ---------- Row -> Model adapters ----------

def _mentor(row: sqlite3.Row) -> MentorProfile:
    return MentorProfile(
        id=row["id"], name=row["name"], title=row["title"], company=row["company"],
        track=row["track"], years_experience=row["years_experience"],
        bio=row["bio"], specialties=json.loads(row["specialties"]),
    )


def _learner(row: sqlite3.Row) -> LearnerProfile:
    return LearnerProfile(
        id=row["id"], name=row["name"], email=row["email"],
        is_first_gen=bool(row["is_first_gen"]),
        interests=json.loads(row["interests"]),
        confidence_score=row["confidence_score"], track=row["track"],
    )


def _post(row: sqlite3.Row) -> ThreadPost:
    rep_rows = conn.execute(
        "SELECT * FROM replies WHERE post_id = ? ORDER BY created_at", (row["id"],)
    ).fetchall()
    return ThreadPost(
        id=row["id"], author_id=row["author_id"], author_name=row["author_name"],
        title=row["title"], body=row["body"], tags=json.loads(row["tags"]),
        created_at=row["created_at"],
        replies=[
            ThreadReply(
                id=r["id"], post_id=r["post_id"], author_id=r["author_id"],
                author_name=r["author_name"], author_role=r["author_role"],
                body=r["body"], created_at=r["created_at"],
            )
            for r in rep_rows
        ],
    )


# ---------- Endpoints ----------

@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/feed", response_model=List[ThreadPost])
def get_feed():
    rows = conn.execute("SELECT * FROM posts ORDER BY created_at DESC").fetchall()
    return [_post(r) for r in rows]


@app.get("/mentors", response_model=List[MentorProfile])
def get_mentors():
    rows = conn.execute("SELECT * FROM mentors").fetchall()
    return [_mentor(r) for r in rows]


@app.get("/profile/{user_id}", response_model=LearnerProfile)
def get_profile(user_id: str):
    row = conn.execute("SELECT * FROM learners WHERE id = ?", (user_id,)).fetchone()
    if not row:
        raise HTTPException(404, "Learner not found")
    return _learner(row)


@app.post("/questionnaire", response_model=MentorProfile)
def submit_questionnaire(answers: QuestionnaireAnswers):
    rows = conn.execute(
        "SELECT * FROM mentors WHERE track = ?", (answers.interest_track,)
    ).fetchall()
    if not rows:
        rows = conn.execute("SELECT * FROM mentors").fetchall()
    if not rows:
        raise HTTPException(404, "No mentors available")

    candidates = [_mentor(r) for r in rows]
    candidates.sort(
        key=lambda m: abs(m.years_experience - answers.preferred_experience_years)
    )
    matched = candidates[0]

    # Upsert learner track/first-gen flag.
    existing = conn.execute(
        "SELECT id FROM learners WHERE id = ?", (answers.learner_id,)
    ).fetchone()
    if existing:
        conn.execute(
            "UPDATE learners SET is_first_gen = ?, track = ? WHERE id = ?",
            (1 if answers.is_first_gen else 0, answers.interest_track, answers.learner_id),
        )
    else:
        conn.execute(
            "INSERT INTO learners VALUES (?,?,?,?,?,?,?)",
            (answers.learner_id, "New Learner", "unknown@example.com",
             1 if answers.is_first_gen else 0, json.dumps([]), 500,
             answers.interest_track),
        )
    conn.commit()
    return matched


@app.put("/confidence/{user_id}", response_model=LearnerProfile)
def update_confidence(user_id: str, update: ConfidenceUpdate):
    row = conn.execute("SELECT * FROM learners WHERE id = ?", (user_id,)).fetchone()
    if not row:
        raise HTTPException(404, "Learner not found")
    conn.execute(
        "UPDATE learners SET confidence_score = ? WHERE id = ?",
        (update.score, user_id),
    )
    conn.commit()
    return _learner(
        conn.execute("SELECT * FROM learners WHERE id = ?", (user_id,)).fetchone()
    )


@app.post("/posts", response_model=ThreadPost)
def create_post(post: NewPost):
    pid = str(uuid.uuid4())
    conn.execute(
        "INSERT INTO posts VALUES (?,?,?,?,?,?,?)",
        (pid, post.author_id, post.author_name, post.title, post.body,
         json.dumps(post.tags), _now()),
    )
    conn.commit()
    return _post(conn.execute("SELECT * FROM posts WHERE id = ?", (pid,)).fetchone())


@app.post("/posts/{post_id}/replies", response_model=ThreadPost)
def add_reply(post_id: str, reply: NewReply):
    if not conn.execute("SELECT 1 FROM posts WHERE id = ?", (post_id,)).fetchone():
        raise HTTPException(404, "Post not found")
    conn.execute(
        "INSERT INTO replies VALUES (?,?,?,?,?,?,?)",
        (str(uuid.uuid4()), post_id, reply.author_id, reply.author_name,
         reply.author_role, reply.body, _now()),
    )
    conn.commit()
    return _post(conn.execute("SELECT * FROM posts WHERE id = ?", (post_id,)).fetchone())
