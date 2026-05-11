# Ascend Backend

FastAPI + in-memory SQLite. Resets on every restart — perfect for demo, **not**
durable.

## Run

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Docs: http://127.0.0.1:8000/docs

## Endpoints

| Method | Path                          | Purpose                                |
| ------ | ----------------------------- | -------------------------------------- |
| GET    | `/health`                     | liveness                               |
| GET    | `/feed`                       | all thread posts (with replies)        |
| GET    | `/mentors`                    | all Fidelity mentors                   |
| GET    | `/profile/{user_id}`          | learner profile                        |
| POST   | `/questionnaire`              | submit answers, get matched mentor     |
| PUT    | `/confidence/{user_id}`       | update confidence score (1–1000)       |
| POST   | `/posts`                      | create thread post                     |
| POST   | `/posts/{post_id}/replies`    | reply to a thread post                 |

## Seed data

- Mentors: `m1` Priya Shah (Financial), `m2` Jasmine Carter (Financial), `m3` Dr. Lin Wei (Tech)
- Learner: `l1` Maya Rodriguez (confidence 620)
- Posts: `p1` (investing) + reply from Priya, `p2` (negotiation) + reply from Lin
