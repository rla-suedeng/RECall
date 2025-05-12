from fastapi import FastAPI, Request, UploadFile, File, Form,Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from typing import List, Any, Union
from sqlalchemy.orm import Session
import google.generativeai as genai
from dotenv import load_dotenv
import os
import io
import json
from PIL import Image
# pip install google-cloud-texttospeech
# pip install google-cloud-speech
from google.cloud import texttospeech
from google.cloud import speech_v1p1beta1 as speech
from io import BytesIO
from models import Chat, History,Rec,User 
from firebase_admin import storage
import random
import requests
from sqlalchemy import not_
import base64
# Load environment variables and configure API key
load_dotenv()
my_api_key=os.getenv("GOOGLE_API_KEY").strip()
genai.configure(api_key=my_api_key)


SYSTEM_PROMPT = os.getenv(
    "SYSTEM_PROMPT",
    """
    1. You are talking to an elderly person. You are therapist, trying to engage the elderly into talking. 
    2. The photo is related to the elderly person's memory. 
    3. Kindly respond to the elderly person's answer. 
    4. Ask a gentle, open-ended question to encourage the user to share memories about this moment. 
    5. Don't answer to me. Only do what I asked. 
    """
)

basic_info = {
    "WHEN": "Last year, Grandma's birthday",
    "WHO": "Our family", 
    "WHERE": "Spa in Japan", 
    "WHAT": "We had a great time and relaxed in the spa"
}

# Initialize the Gemini model (multimodal)
model = genai.GenerativeModel(model_name="gemini-2.0-flash")

# Initialize FastAPI app and apply CORS
# app = FastAPI()
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


    # clean_history = []
    # for msg in messages:
    #     if msg.text:
    #         clean_history.append({
    #             "role": msg.role,
    #             "parts": [{"text": msg.text}]
    #         })
    # return clean_history


def fetch_history_from_db(db: Session, h_id: int, limit: int = 20) -> List[dict]:
    messages = (
        db.query(Chat)
        .filter(Chat.h_id == h_id)
        .order_by(Chat.timestamp.asc())
        .limit(limit)
        .all()
    )

    clean_history = []
    for msg in messages:
        if msg.content:
            clean_history.append({
                "role": "model" if msg.u_id=="gemini" else "user",
                "parts": [{"text": msg.content}]
            })
    return clean_history

def get_or_create_active_chatroom(db: Session, user_id : int):
    room = db.query(History).filter(History.summary.is_(None)).first()
    if room:
        print(repr(room.summary))  # 공백, \n, \t 확인
        return room
    
    recs = db.query(Rec).filter(Rec.u_id == user_id).all()  
    # if not recs:
    #     raise HTTPException(status_code=404, detail="No Rec found for user")

    selected_rec = random.choice(recs)

    # 새 History 생성
    new_room = History(u_id=user_id, r_id=selected_rec.r_id)
    db.add(new_room)
    db.commit()
    db.refresh(new_room)
    return new_room

def save_message_to_db(db: Session, h_id: int, u_id: str, content: str):
    msg = Chat(h_id=h_id, u_id=u_id, content=content)
    db.add(msg)
    db.commit()
    
async def summarize(db: Session,h_id:int):
    raw_text = '''
        Gemini: That's a lovely photo of your family enjoying a foot spa. It looks like a very relaxing place in Japan with everyone having their feet in the warm water. What comes to mind when you see this picture of your birthday trip?

        User: I remember that place. It was in Tokyo, and I enjoyed Japanese food.

        Gemini: Tokyo, wonderful! I've heard the food there is amazing. What kind of Japanese food did you enjoy most on that trip?

        User: I loved salmon sushi. It was so fresh and delicious.

        Gemini: Salmon sushi, a classic! It's amazing how different it can taste depending on where you are. Thinking back to that meal, what else do you remember about that day? Was there anything else special that happened or anyone special you were with?

        User: My daughter gave me a sweater as a birthday gift. I still love to wear that sweater.

        Gemini: That's so heartwarming! A gift that you still cherish. Tell me more about that sweater. What does it look like, and what makes it so special to you?

        User: It's red and warm sweater. I love to wear that in Christmas.

        Gemini: A red, warm sweater for Christmas sounds perfect! That sounds like it brings back many memories. What makes wearing that sweater at Christmas so special for you? Is there a particular Christmas memory connected to it?
    '''

    instruction = "Following is the converation between Gemini and User. Summarize the conversation around the user in only one short sentence, less than 15 words. \nConversation: "
    instruction += raw_text
    
    session = model.start_chat()
    response = session.send_message(instruction)

    return response.text



# @app.post("/chat")
async def chat(request: str, db: Session,user:User ):
    """
    Handle a single user message (and optional image) and return a reply.
    Supports JSON or multipart/form-data with 'chat', 'history', and optional 'file'.
    """

    # form = await request.json()
    # chat_text = form.get("chat", "") or ""
    chat_text = request
    # Clean up history to remove unsupported image parts
    room = get_or_create_active_chatroom(db, user_id=user.u_id)
    history_list =  fetch_history_from_db(db, h_id=room.h_id)

    if SYSTEM_PROMPT:
        history_list.insert(0, {"role": "user", "parts": [{"text": SYSTEM_PROMPT}]})

    if chat_text.strip() == "[Voice recognition failed. Please try again.]":
        return StreamingResponse(
            iter(["Sorry, I couldn't understand your voice. Please try again."]),
            media_type="text/event-stream"
        )
    # Prompt
    if  chat_text==None:
        chat_text = """
            1. You are talking to an elderly person. You are therapist, trying to engage the elderly into talking. 
            2. The photo is related to the elderly person's memory. 
            3. The following is a information about the photo written by the elderly person's caregiver.
        """

        for key, value in basic_info.items():
            chat_text += f'{key}: {value}\n'
        
        chat_text += """
            4. Briefly describe the photo focusing on people, places, and activities in 1~3 sentences. 
            5. Ask a gentle, open-ended question to encourage the user to share memories about this moment. 
            6. Keep in mind the information about the photo written by the elderly person's caregiver. You may ask a question related to it. 
            6. Don't answer to me. Only do what I asked. 
        """
    else : 
        save_message_to_db(db, h_id=room.h_id, u_id=user.u_id, content=chat_text)
        if "goodbye" in chat_text:
            room.summary = summarize(db,h_id=room.h_id)
            db.commit()
            return {"text": "Wishing you a peaceful and joyful day. I'm here anytime you want to talk."

}

    # Build content for Gemini: either text or [text, image]

    recs = db.query(Rec).filter(Rec.r_id == room.r_id).first()
    
    # bucket = storage.bucket()
    # blob = bucket.blob(recs.file)
    # image_bytes = blob.download_as_bytes()
    # PIL Image 객체로 변환
    # image = Image.open(io.BytesIO(image_bytes))
    
    response = requests.get(recs.file)
    image = Image.open(BytesIO(response.content))
    content: Union[str, List[Any]] = [chat_text, image]

    print(history_list)

    # Start chat session with sanitized history
    session = model.start_chat(history=history_list)
    response = session.send_message(content)
    save_message_to_db(db, h_id=room.h_id, u_id="gemini", content=response.text)
    return {"text": response.text}


# @app.post("/stream")
async def stream(request: str, db: Session,user:User ):
    """
    Stream the model's response chunk-by-chunk for real-time chat, with optional image.
    """
    chat_text = request
    # Clean up history to remove unsupported image parts
    room = get_or_create_active_chatroom(db, user_id=user.u_id)
    history_list =  fetch_history_from_db(db, h_id=room.h_id)

    if SYSTEM_PROMPT:
        history_list.insert(0, {"role": "user", "parts": [{"text": SYSTEM_PROMPT}]})

    if chat_text.strip() == "[Voice recognition failed. Please try again.]":
        return StreamingResponse(
            iter(["Sorry, I couldn't understand your voice. Please try again."]),
            media_type="text/event-stream"
        )

   
    # Prompt
    if not chat_text:
        chat_text = """
            Briefly describe the image focusing on people, places, and activities. 
            Then, ask a gentle, open-ended question to encourage the user to share memories about this moment. 
            For example: 'This looks like a [description]. What do you remember about this day?' or 'Who are the people in this photo? 
            It looks like a special occasion.' 
        """
    else : 
        save_message_to_db(db, h_id=room.h_id, u_id=user.u_id, content=chat_text)
        if "goodbye" in chat_text:
            room.summary = summarize(db,h_id=room.h_id)
            db.commit()
            return {"text": "Chat closed"}
    recs = db.query(Rec).filter(Rec.r_id == room.r_id).first()
    
    # bucket = storage.bucket()
    # blob = bucket.blob(recs.file)
    # image_bytes = blob.download_as_bytes()

    # # PIL Image 객체로 변환
    # image = Image.open(io.BytesIO(image_bytes))
    response = requests.get(recs.file)
    image = Image.open(BytesIO(response.content))
    content: Union[str, List[Any]] = [chat_text, image]

    print(history_list)

    # Start chat session with sanitized history
    session = model.start_chat(history=history_list)

    stream_response = session.send_message(content, stream=True)

    
    full_response = ""  # 전체 응답을 누적할 변수   

    async def event_generator():
        nonlocal full_response
        for chunk in stream_response:
            full_response += chunk.text  # 응답 누적
            yield chunk.text

        # ✅ 스트리밍이 끝난 후 DB에 저장
        save_message_to_db(db, h_id=room.h_id, u_id="gemini", content=full_response)
        
        audio_bytes = await tts(full_response)
        audio_base64 = base64.b64encode(audio_bytes).decode()

        # ✅ 음성도 마지막에 함께 전송 (base64)
        yield f"event: audio\n"
        yield f"data: {audio_base64}\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")

# @app.post('/tts')
async def tts(content: str):
    text = '''I'm selfish, impatient and a little insecure. I make mistakes, I am out of control and at times hard to handle. But if you can't handle me at my worst, then you sure as hell don't deserve me at my best.'''.replace('\n', ' ')
    language_code = "en-US"
    name = "en-US-Chirp3-HD-Aoede"

    # 클라이언트 생성
    client = texttospeech.TextToSpeechClient()

    # 요청 구성
    synthesis_input = texttospeech.SynthesisInput(text=content)

    # 음성 구성
    voice = texttospeech.VoiceSelectionParams(
        language_code=language_code,
        name=name
    )

    # 오디오 설정
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )

    # 요청 보내기
    response = client.synthesize_speech(
        input=synthesis_input,
        voice=voice,
        audio_config=audio_config
    )

    # 오디오 저장
    return response.audio_content 


async def stt(content: bytes)-> str:
    client = speech.SpeechClient()

    audio = speech.RecognitionAudio(content=content)

    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.MP3,
        sample_rate_hertz=16000,  # 샘플 속도
        language_code="en-US",  # 언어코드
        enable_automatic_punctuation=True
    )

    try:
        response = client.recognize(config=config, audio=audio)
        transcript = response.results[0].alternatives[0].transcript
        return transcript

    except Exception as e:
        print("❌ STT 오류:", e)
        return "[Voice recognition failed. Please try again.]"


