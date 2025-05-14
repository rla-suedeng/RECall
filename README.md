# RECall

Google APAC Solution Challenge

- Belonging: GDG-KU on Campus Team 1

![Logo](logo.png)

### Problem Statement

Improving Accessibility and Personalization in Reminiscence Therapy for Neurocognitive Disorders Patients Using Large Language Models

### Features

- Image-Based Conversation: Patients engage in conversations centered around photos related to their personal memories

- LLM-Driven Dialogue: Gemini actively leads the conversation by asking thoughtful questions, carefully triggering the patient's memory through elaborate prompting.

- Voice Interaction: Using the Google Speech API, patients can interact with Gemini by speaking, eliminating the need for text input.

- User-Friendly Interface: A simple and intuitive interface allows patients to easily participate in the therapy.

### Stacks

- FE: Flutter, Figma
- BE: FastAPI, Firebase, MySQL
- AI: Gemini, Pytorch, Google STT TTS

### Members

| Name          | Role        | GitHub                                        | Techinical Stack                    |
| ------------- | ----------- | --------------------------------------------- | ----------------------------------- |
| Suhyun Kim    | Leader, FE  | [rla-suedeng](https://github.com/rla-suedeng) | Flutter, React, Pytorch             |
| Jeongmin Moon | AI(LLM)     | [strn18](https://github.com/strn18)           | Pytorch, React, Express, TypeORM    |
| Hyunjin Lee   | PM, AI(LLM) | [hyunjin09](https://github.com/hyunjin09)     | React, Node.js, Pytorch, Tensorflow |
| Yunji Cho     | BE          | [robosun78](https://github.com/robosun78)     | FastAPI, Django, Pytorch            |

## Git Rules

```bash
git checkout develop
git pull origin develop

git checkout -b feature/your-feature-name
```

### After Develop

```bash
git add .
git commit -m "feat: your commit message"
git push origin feature/your-feature-name
```

### Conventional Commits

```bash
feat: new feature
fix: fix bug
docs: documents
style: style formatting
refactor: code refactoring
test: test code or dummy code
chore: etc difference
mod: not bug but modifing code
```

### Send PR
