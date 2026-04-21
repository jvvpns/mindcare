import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize FastAPI application
app = FastAPI(
    title="HILWAY Intelligence Gateway",
    description="Backend API for Mindcare AI Orchestration & ML Inference",
    version="1.0.0"
)

# Configure CORS for Flutter Web PWA
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict this to the production domain (e.g., Vercel/Netlify) in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
@app.get("/health")
def health_check():
    """
    Warm-up and health check endpoint to prevent cold starts on Render.
    """
    return {"status": "ok", "service": "HILWAY Intelligence Gateway"}

from api.context import router as context_router
from api.chat import router as chat_router
from api.burnout import router as burnout_router

app.include_router(context_router, prefix="/v1/context", tags=["Context"])
app.include_router(chat_router, prefix="/v1/chat", tags=["Chat"])
app.include_router(burnout_router, prefix="/v1/predict", tags=["ML"])
