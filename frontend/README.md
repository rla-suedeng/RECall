# Git 협업

```bash
git checkout develop
git pull origin develop

git checkout -b feature/your-feature-name
```

### 개발 작업 후

```bash
git add .
git commit -m "feat: your commit message"
git push origin feature/your-feature-name
```

### Conventional Commits

```bash
feat: 새로운 기능
fix: 버그 수정
docs: 문서
style: 스타일 (포맷팅 등)
refactor: 리팩토링
test: 테스트 코드
chore: 기타 변경
mod: 버그는 아니나 코드 일부 수정
```

# PR 보내기!

### 시작하기

[Coding Style](https://github.com/1kl1/flutter_template/blob/main/coding_style.pdf)

[State Management](https://github.com/1kl1/flutter_template/blob/main/state_management.pdf)

[Code Generation](https://github.com/1kl1/flutter_template/blob/main/code_generation.pdf)

[Api Handling](https://github.com/1kl1/flutter_template/blob/main/api_handling.pdf)

[Recommendations](https://github.com/1kl1/flutter_template/blob/main/recommendations.pdf)

### 요구사항

- Flutter SDK
- Dart SDK
- FVM(Flutter Version Management)
- Android Studio / VS Code
- Git

### 설치 및 실행

1. 저장소 클론하기

```bash
git clone https://github.com/linkive/favy_app/
cd favy
```

2. FVM을 이용한 Flutter 버전 설정

3. 의존성 패키지 설치

```bash
flutter pub get
```
