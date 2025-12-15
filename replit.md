# Programming Quiz App

## Overview
An AI-powered Programming Quiz App built with Clean Architecture principles. The app uses a card-based UI where users select programming languages/technologies to start intelligent quizzes with randomly generated questions.

## Architecture

### Frontend (web/)
- **Pure JavaScript** implementation with Clean Architecture patterns
- `app.js` - Main application with classes for:
  - `ProgrammingQuizApp` - Main controller
  - `TechnologyDatasource` - 20 programming technologies
  - `QuestionBank` - Comprehensive question bank with 30+ questions per technology
  - `Question`, `Technology` - Domain entities
- `styles.css` - Modern dark-themed UI with animations
- `index.html` - Entry point

### Backend (server/)
- **Express.js** server on port 5000
- `/api/analyze` - AI-powered skill analysis endpoint
- OpenAI integration for personalized feedback (with fallback)

### Dart/Flutter Reference (lib/)
- Clean Architecture folder structure (Presentation/Domain/Data layers)
- Provider pattern for state management
- Reference implementation that mirrors the JavaScript version

## Key Features
1. **Home Screen**: 20 technology cards with icons and difficulty levels
2. **Quiz Screen**: 30 MCQ questions (10 easy, 10 medium, 10 hard)
3. **Timer**: Optional 30-second countdown per question
4. **Progress Tracking**: Visual progress bar and question navigation
5. **Result Screen**: Score breakdown, grade, and AI skill analysis
6. **Question Review**: Detailed explanation for each answer

## Running the App
- Server runs on port 5000 via `cd server && node index.js`
- Static files served from `web/` directory

## Environment Variables
- `OPENAI_API_KEY` (optional) - Enables AI-powered analysis
- Falls back to rule-based analysis if not provided

## Tech Stack
- Frontend: Vanilla JavaScript (ES6+), CSS3
- Backend: Node.js, Express.js
- AI: OpenAI GPT-4 (optional)
