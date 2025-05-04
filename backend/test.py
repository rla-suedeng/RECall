from unittest.mock import patch
from fastapi.testclient import TestClient
from main import app, get_user_id  # main.py에 FastAPI 앱과 의존성 함수가 있다고 가정

client = TestClient(app)

@patch("main.auth.verify_id_token")
def test_protected_route_valid_token(mock_verify):
    mock_verify.return_value = {"uid": "test_user_id"}
    headers = {"Authorization": "Bearer valid_token"}
    response = client.get("/protected", headers=headers)
    assert response.status_code == 200
    assert response.json() == {"message": "인증된 사용자 ID: test_user_id"}

@patch("main.auth.verify_id_token")
def test_protected_route_invalid_token(mock_verify):
    mock_verify.side_effect = auth.InvalidIdTokenError("Invalid token")
    headers = {"Authorization": "Bearer invalid_token"}
    response = client.get("/protected", headers=headers)
    assert response.status_code == 401
    assert response.json() == {"detail": "유효하지 않은 ID 토큰"}