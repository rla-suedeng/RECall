from fastapi import FastAPI, HTTPException, Depends, Header
from typing import Annotated

from RECall import schemas

async def get_current_user(authorization: Annotated[str, Header()]):
    if firebase_auth is None or not authorization:
        raise HTTPException(status_code=401, detail="인증되지 않았습니다.")
    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="유효하지 않은 인증 방식")
        decoded_token = await firebase_auth.verify_id_token(token)
        uid = decoded_token.get("uid")
        if not uid:
            raise HTTPException(status_code=401, detail="유효하지 않은 토큰")
        return UserInfo(uid=uid)
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"유효하지 않은 토큰: {e}")

