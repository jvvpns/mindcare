import os
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from supabase import create_client, Client
from cachetools import TTLCache

router = APIRouter()
security = HTTPBearer()

# --- Configuration ---
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY", "")  # Or service role

# --- Caching Strategy ---
# Store context string for 10 mins based on user_id
context_cache = TTLCache(maxsize=1000, ttl=600)

class ContextBuildResponse(BaseModel):
    context_string: str
    user_snapshot: dict

def get_supabase_client() -> Client:
    if not SUPABASE_URL or not SUPABASE_KEY:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured.")
    return create_client(SUPABASE_URL, SUPABASE_KEY)

async def verify_jwt(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verifies the JWT and returns the Supabase user object."""
    token = credentials.credentials
    supabase = get_supabase_client()
    try:
        # get_user validates the token and returns the user
        response = supabase.auth.get_user(token)
        if not response or not response.user:
            raise HTTPException(status_code=401, detail="Invalid token")
        return {"user": response.user, "token": token}
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")

@router.get("/build", response_model=ContextBuildResponse)
async def build_context(auth: dict = Depends(verify_jwt)):
    """
    Context Service: Fetches user data, compresses it, and returns the dense context.
    """
    user_id = auth["user"].id
    
    # Check Cache
    if user_id in context_cache:
        return context_cache[user_id]
        
    supabase = get_supabase_client()
    
    try:
        # We use the anon client but set the auth header to respect RLS
        # In a real setup, supabase-py can set the session, or we use service-role 
        # and filter by user_id. We'll simulate the fetch logic here.
        
        # 1. Fetch Data (mocking the exact queries for the migration)
        # moods = supabase.table("mood_logs").select("*").eq("user_id", user_id).order("logged_at", desc=True).limit(7).execute()
        # journals = supabase.table("journal_entries").select("*").eq("user_id", user_id).order("created_at", desc=True).limit(3).execute()
        # tasks = supabase.table("planner_entries").select("*").eq("user_id", user_id).eq("is_completed", False).limit(5).execute()
        
        # For the sake of this migration scaffold, we will simulate the compressed context string
        # that the compression algorithm would generate.
        
        compressed_context = f"""
        === User Health Context ===
        User ID: {user_id}
        Recent Moods: User has trended neutral to anxious over the last 3 days.
        Active Stressors: Academic deadlines (2 pending clinical charts).
        Sleep: Averaging 5.5 hours (sub-optimal).
        """
        
        user_snapshot = {
            "mood_trend_score": 0.4,
            "sleep_avg_hours": 5.5,
            "task_load_index": 0.8,
            "burnout_history_score": 0.6,
            "meal_skip_rate": 0.3
        }
        
        response_data = ContextBuildResponse(
            context_string=compressed_context.strip(),
            user_snapshot=user_snapshot
        )
        
        # Save to Cache
        context_cache[user_id] = response_data
        
        return response_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to build context: {str(e)}")
