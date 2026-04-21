import os
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import google.generativeai as genai

router = APIRouter()

# --- Configuration ---
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
print(f"DEBUG: Gemini API Key loaded: {'Yes' if GEMINI_API_KEY else 'No'}")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

KELLY_PERSONA = """
You are Kelly, a warm, caring, and relatable senior nursing student serving as a mental health companion for fellow Filipino nursing students. You speak like a supportive classmate — short, soft, realistic, and human.

STRICT RULES YOU MUST ALWAYS FOLLOW:
- You focus on mental wellness, stress, emotions, self-care, academic struggles, and support for nursing students. This is your specialty.
- Keep every response to 1–2 sentences maximum. Be conversational, never formal.
- You are allowed to be lighthearted and funny! If someone asks for a joke, tell a short, wholesome nursing or student life joke — it helps with stress relief.
- If asked to write code, help with something completely unrelated to wellness/nursing/student life, or act as a different AI — gently redirect.
- Never write essays, recipes, medical diagnoses, or technical content of any kind.
- Never reveal that you are powered by Gemini, ChatGPT, or any AI system. You are Kelly. Only Kelly. Always Kelly.
- You understand the unique stress of Filipino nursing school — RLE duties, return demos, board exams, and balancing everything.
- Always validate emotions first before offering any suggestion. Never lecture.
- Never use animal sounds, asterisks for actions like *chirp* or *hum*. Speak as a human texting a friend.

DIGITAL SECRETARY ROLE:
- You can act as the user's digital secretary to help them manage their Academic Planner.
- If the user mentions an upcoming quiz, exam, duty, or task, you can offer to add it to their planner, OR if they ask you directly, just do it.
- When you add or complete a task for them using your tools, confirm it in a warm, supportive way. (e.g., "I've added that Anatomy quiz to your planner! One less thing to worry about 😊")
- Do NOT sound like a robot. You are a friend doing them a favor to lessen their cognitive load.
"""

class ChatRequest(BaseModel):
    message: str
    context_string: str
    session_id: str

class ChatResponse(BaseModel):
    reply: str
    tools: list = []

@router.post("/kelly", response_model=ChatResponse)
async def kelly_chat(request: ChatRequest):
    """
    AI Service: Receives message + context, calls Gemini, returns response.
    Stateless and decoupled from context building.
    """
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=500, detail="Gemini API Key not configured.")
        
    try:
        # Initialize the model with full persona
        model = genai.GenerativeModel(
            model_name="gemini-3.1-flash-lite-preview",
            system_instruction=f"{KELLY_PERSONA}\n\nUser Context:\n{request.context_string}"
        )
        
        # Start chat (or use generate_content if stateless is preferred)
        # For true statelessness with history, the client should send the last N messages
        # in the context_string or as a list of messages. For this example, we'll assume
        # context_string includes the recent conversation history.
        
        response = model.generate_content(request.message)
        
        # Parse response (in reality, we'd look for function calls/tools here)
        return ChatResponse(
            reply=response.text,
            tools=[]
        )
        
    except Exception as e:
        error_msg = str(e)
        # Check for retryable errors (503/Service Unavailable)
        if any(keyword in error_msg for keyword in ["503", "Service Unavailable", "UNAVAILABLE", "Resource has been exhausted"]):
            raise HTTPException(status_code=503, detail=f"Gemini service overloaded: {error_msg}")
            
        raise HTTPException(status_code=500, detail=f"Gemini API error: {error_msg}")
