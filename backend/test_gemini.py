import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
key = os.getenv("GEMINI_API_KEY")
print(f"Key found: {'Yes' if key else 'No'}")

if key:
    genai.configure(api_key=key)
    try:
        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content("Say hello")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
else:
    print("No key found.")
