from fastapi import FastAPI, Header, HTTPException, Depends
from firebase_admin import auth, credentials
import firebase_admin

#cred = credentials.Certificate("path/to/your/serviceAccountKey.json")  # 서비스 계정 키 파일 경로
#firebase_admin.initialize_app(cred)


async def get_user_id(authorization: str = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="유효하지 않은 인증 정보")
    try:
        id_token = authorization.split(" ")[1]
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token.get("uid")
        if uid is None:
            raise HTTPException(status_code=401, detail="유효하지 않은 사용자 ID")
        return uid
    except auth.InvalidIdTokenError:
        raise HTTPException(status_code=401, detail="유효하지 않은 ID 토큰")
    except Exception as e:
        print(f"토큰 검증 오류: {e}")
        raise HTTPException(status_code=500, detail="서버 오류")