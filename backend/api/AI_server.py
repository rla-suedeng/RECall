from fastapi import HTTPException
from typing import List, Any, Union
from sqlalchemy.orm import Session
import google.generativeai as genai
from dotenv import load_dotenv
import os
from PIL import Image
# pip install google-cloud-texttospeech
# pip install google-cloud-speech
from google.cloud import texttospeech
from google.cloud import speech_v1p1beta1 as speech
from io import BytesIO
from models import Chat, History,Rec
import random
import requests
import base64
from firebase.firebase_user import AuthenticatedUser
from schemas.chat import ChatGet
# Load environment variables and configure API key
load_dotenv()
my_api_key=os.getenv("GOOGLE_API_KEY").strip()
genai.configure(api_key=my_api_key)

env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(dotenv_path=env_path)


SYSTEM_PROMPT = os.getenv(
    "SYSTEM_PROMPT",
    """
    1. You are talking to an elderly person. You are therapist, trying to engage the elderly into talking. 
    2. The photo is related to the elderly person's memory. 
    3. Kindly respond to the elderly person's answer. 
    4. Ask a gentle, open-ended question to encourage the user to share memories about this moment. 
    5. Don't answer to me. Only do what I asked. 
    6. Be brief with your answers.
    """
)

# Initialize the Gemini model (multimodal)
model = genai.GenerativeModel(model_name="gemini-2.0-flash")

def chat_history_from_db(gemini :bool, db: Session, h_id: int, limit: int = 20) -> List[dict]:
    messages = (
        db.query(Chat)
        .filter(Chat.h_id == h_id)
        .order_by(Chat.timestamp.asc())
        .limit(limit)
        .all()
    )
    clean_history = []
    if gemini:
        for msg in messages:
            if msg.content:
                clean_history.append({
                    "role": "model" if msg.u_id=="gemini" else "user",
                    "parts":[{"text": msg.content}]
                })
    else:
        for msg in messages:
            if msg.content:
                chat_data = ChatGet(
                    u_id=msg.u_id,
                    content=msg.content,
                    timestamp=msg.timestamp
                )
                clean_history.append(chat_data.dict())
    return clean_history

def get_or_create_active_chatroom(db: Session, user_id : int):
    room = db.query(History).filter(
        History.summary.is_(None),
        History.u_id == user_id
        ).first()
    if room:
        print(repr(room.summary)) 
        return room,False
    
    recs = db.query(Rec).filter(Rec.u_id == user_id).all()  
    if not recs:
        raise HTTPException(status_code=404, detail="No Rec found for user")

    selected_rec = random.choice(recs)

    new_room = History(u_id=user_id, r_id=selected_rec.r_id)
    db.add(new_room)
    db.commit()
    db.refresh(new_room)
    return new_room,True

def save_message_to_db(db: Session, h_id: int, u_id: str, content: str):
    msg = Chat(h_id=h_id, u_id=u_id, content=content)
    db.add(msg)
    db.commit()
    
async def summarize(db: Session,h_id:int):
    history_list = chat_history_from_db(gemini=True,db = db, h_id=h_id)
    raw_text=""
    for history in history_list:
        raw_text+=f"{history['role']}:{history['parts'][0]['text']}"

    instruction = "Following is the converation between Gemini and User. Summarize the conversation around the user in only one short sentence, less than 15 words. \nConversation: "
    instruction += raw_text
    print(instruction)
    session = model.start_chat()
    response = session.send_message(instruction)
    print(response.text)

    return response.text



async def enter_chat(db:Session, auth_user: AuthenticatedUser):
    user = auth_user.user
    token = auth_user.token
    
    room, is_new = get_or_create_active_chatroom(db, user_id=user.u_id)
    print(room)
    rec = db.query(Rec).filter_by(r_id=room.r_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="No rec assigned to chatroom.")

    history = chat_history_from_db(gemini=True,db = db, h_id=room.h_id)

    gemini_text = None
    audio_base64 = None

    if is_new:
        # ✅ Initial Prompt
        prompt = """
            1. You are talking to an elderly person. You are therapist, trying to engage the elderly into talking. 
            2. The photo is related to the elderly person's memory. 
            3. The following is a information about the photo written by the elderly person's caregiver.
        """ +rec.content + """
            4. Briefly describe the photo focusing on people, places, and activities in 1 sentences. 
            5. Ask a gentle, open-ended question to encourage the user to share memories about this moment. 
            6. Keep in mind the information about the photo written by the elderly person's caregiver. You may ask a question related to it. 
            6. Don't answer to me. Only do what I asked.
        """

        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(room.rec.file, headers=headers)
        image = Image.open(BytesIO(response.content))
        content: Union[str, List[Any]] = [prompt, image]
        
        session = model.start_chat(history=history)
        response = session.send_message(content)

        gemini_text = response.text
        save_message_to_db(db, h_id=room.h_id, u_id="gemini", content=gemini_text)

        audio_bytes = await tts(gemini_text)
        audio_base64 = base64.b64encode(audio_bytes).decode()

        
    return {
        "h_id": room.h_id,
        "is_new": is_new,
        "rec_file": rec.file,
        "history": chat_history_from_db(gemini=False,db=db,h_id=room.h_id),
        "initial_text": gemini_text,
        "audio_base64": audio_base64
    }

async def send_messages(
    h_id:int,
    text: str,
    db: Session,
    auth_user: AuthenticatedUser
):
    user = auth_user.user
    token = auth_user.token
    
    if text.strip() == "[Voice recognition failed. Please try again.]":
        reply = "Sorry, I couldn't understand your voice. Please try again."
        audio = await tts(reply)
        return {
            "text": reply,
            "audio_base64": base64.b64encode(audio).decode(),
        }

    save_message_to_db(db, h_id=h_id, u_id=user.u_id, content=text)
    room = db.query(History).filter(History.h_id==h_id).first()
    if "goodbye" in text.lower():
            room.summary = await summarize(db,h_id=room.h_id)
            db.commit()
            end_text = "Wishing you a peaceful and joyful day. I'm here anytime you want to talk."
            audio = await tts(end_text)
            return {
                "user_text":"goodbye",
                "text": end_text,
                "audio_base64": base64.b64encode(audio).decode()
            }
    history_list =  chat_history_from_db(gemini=True,db=db, h_id=h_id)
    
    if SYSTEM_PROMPT:
        history_list.insert(0, {"role": "user", "parts": [{"text": SYSTEM_PROMPT}]})
        

    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(room.rec.file, headers=headers)
    image = Image.open(BytesIO(response.content))
    content: Union[str, List[Any]] = [text, image]
    
    session = model.start_chat(history=history_list)
    response = session.send_message(content)
    
    reply = response.text
    save_message_to_db(db, h_id=h_id, u_id="gemini", content=reply)
    audio = await tts(reply)
    
    return {
        "user_text":text,
        "text": reply,
        "audio_base64": base64.b64encode(audio).decode(),
    }



async def tts(content: str):
    text = '''I'm selfish, impatient and a little insecure. I make mistakes, I am out of control and at times hard to handle. But if you can't handle me at my worst, then you sure as hell don't deserve me at my best.'''.replace('\n', ' ')
    language_code = "en-US"
    name = "en-US-Chirp3-HD-Aoede"

    client = texttospeech.TextToSpeechClient()
    synthesis_input = texttospeech.SynthesisInput(text=content)
    voice = texttospeech.VoiceSelectionParams(
        language_code=language_code,
        name=name
    )

    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
    response = client.synthesize_speech(
        input=synthesis_input,
        voice=voice,
        audio_config=audio_config
    )

    return response.audio_content 


async def stt(content: bytes)-> str:
    client = speech.SpeechClient()

    audio = speech.RecognitionAudio(content=content)

    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.MP3,
        sample_rate_hertz=16000,  
        language_code="en-US", 
        enable_automatic_punctuation=True
    )

    try:
        response = client.recognize(config=config, audio=audio)
        transcript = response.results[0].alternatives[0].transcript
        return transcript

    except Exception as e:
        print("❌ STT error:", e)
        return "[Voice recognition failed. Please try again.]"


