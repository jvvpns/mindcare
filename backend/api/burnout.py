import os
import numpy as np
try:
    import tflite_runtime.interpreter as tflite
    HAS_TFLITE = True
except ImportError:
    try:
        import tensorflow.lite as tflite
        HAS_TFLITE = True
    except ImportError:
        HAS_TFLITE = False
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import Dict, Any, List
from datetime import datetime

router = APIRouter()

# --- ML Feature Schema (Strict Contract) ---
class BurnoutFeatures(BaseModel):
    mood_trend_score: float = Field(..., description="0.0-1.0: 7-day weighted average")
    sleep_avg_hours: float = Field(..., description="0.0-24.0: 3-day average")
    task_load_index: float = Field(..., description="0.0-1.0: pending_tasks / capacity_limit")
    burnout_history_score: float = Field(..., description="0.0-1.0: average of last 3 assessments")
    meal_skip_rate: float = Field(..., description="0.0-1.0: skipped_meals / total_required_meals")

class BurnoutMetadata(BaseModel):
    user_id: str
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())

class BurnoutPredictionRequest(BaseModel):
    version: str = "1.0.0"
    features: BurnoutFeatures
    metadata: BurnoutMetadata

class BurnoutPredictionResponse(BaseModel):
    level: str
    confidence: float
    probabilities: List[float]

# --- Model Loading ---
# We load the model once into memory at startup
MODEL_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "models", "burnout_model.tflite")
MODEL_LOADED = False

if HAS_TFLITE and os.path.exists(MODEL_PATH):
    try:
        interpreter = tflite.Interpreter(model_path=MODEL_PATH)
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        MODEL_LOADED = True
    except Exception as e:
        print(f"Warning: Failed to load TFLite model at {MODEL_PATH}: {e}")
else:
    if not HAS_TFLITE:
        print("Warning: TFLite runtime not found. Burnout prediction will be unavailable.")
    if not os.path.exists(MODEL_PATH):
        print(f"Warning: Model file not found at {MODEL_PATH}")

def heuristic_predict(feats: BurnoutFeatures):
    """
    Fallback Heuristic: Estimates burnout risk based on weighted factors 
    if the TFLite engine is unavailable.
    """
    # Start with a base risk of 20%
    score = 0.2
    
    # 1. Mood Trend: Significant factor for mental resilience
    if feats.mood_trend_score < 0.3: # Depressed/Very Anxious trend
        score += 0.3
    elif feats.mood_trend_score < 0.6: # Neutral/Down trend
        score += 0.15
        
    # 2. Sleep: Physical recovery (Critical for nursing)
    if feats.sleep_avg_hours < 5.0:
        score += 0.25
    elif feats.sleep_avg_hours < 7.0:
        score += 0.1
        
    # 3. Task Load: Academic stress factor
    if feats.task_load_index > 0.8:
        score += 0.2
    elif feats.task_load_index > 0.5:
        score += 0.1
        
    # 4. Meal Skip Rate: Self-care indicator
    if feats.meal_skip_rate > 0.6:
        score += 0.15
    elif feats.meal_skip_rate > 0.3:
        score += 0.05
        
    # Normalize result
    final_score = min(score, 0.95)
    
    if final_score > 0.7:
        level = "high"
    elif final_score > 0.4:
        level = "medium"
    else:
        level = "low"
        
    return level, final_score

@router.post("/burnout", response_model=BurnoutPredictionResponse)
def predict_burnout(request: BurnoutPredictionRequest):
    feats = request.features

    # --- Case 1: TFLite Inference ---
    if MODEL_LOADED:
        try:
            # Adapter Logic for 4-input training format
            input_sleep = float(feats.sleep_avg_hours)
            input_stress = 5.0 - (feats.mood_trend_score * 4.0)
            input_duties = feats.task_load_index * 5.0
            input_meals = feats.meal_skip_rate * 4.0

            input_data = np.array([[input_sleep, input_stress, input_duties, input_meals]], dtype=np.float32)
            
            interpreter.set_tensor(input_details[0]['index'], input_data)
            interpreter.invoke()
            output_data = interpreter.get_tensor(output_details[0]['index'])
            
            probabilities = output_data[0].tolist()
            p_low, p_med, p_high = probabilities
            
            max_prob = max(probabilities)
            if max_prob == p_high:
                level = "high"
            elif max_prob == p_med:
                level = "medium"
            else:
                level = "low"
                
            return BurnoutPredictionResponse(
                level=level,
                confidence=round(max_prob * 100, 2),
                probabilities=probabilities
            )
        except Exception as e:
            print(f"Inference failed, falling back to heuristic: {e}")
            # Fall through to heuristic

    # --- Case 2: Heuristic Fallback ---
    # This ensures the API is NEVER down (No 503s) even if the ML runtime fails
    level, score = heuristic_predict(feats)
    
    return BurnoutPredictionResponse(
        level=level,
        confidence=round(score * 100, 2),
        probabilities=[0.0, 0.0, 0.0] # Heuristic doesn't provide granular class probs
    )
