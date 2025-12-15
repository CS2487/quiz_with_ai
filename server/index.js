const express = require('express');
const path = require('path');
const OpenAI = require('openai');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use(express.static(path.join(__dirname, '../web')));

let openai = null;
if (process.env.OPENAI_API_KEY) {
  openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
  });
}

app.post('/api/analyze', async (req, res) => {
  try {
    const {
      technologyName,
      totalQuestions,
      correctAnswers,
      easyCorrect,
      mediumCorrect,
      hardCorrect,
      percentage,
      timeTaken
    } = req.body;

    if (!openai) {
      return res.json(generateFallbackAnalysis({
        technologyName,
        totalQuestions,
        correctAnswers,
        easyCorrect,
        mediumCorrect,
        hardCorrect,
        percentage,
        timeTaken
      }));
    }

    const prompt = `Analyze this programming quiz performance and provide personalized feedback:

Technology: ${technologyName}
Total Questions: ${totalQuestions}
Correct Answers: ${correctAnswers} (${percentage.toFixed(1)}%)
Easy Questions: ${easyCorrect}/10 correct
Medium Questions: ${mediumCorrect}/10 correct  
Hard Questions: ${hardCorrect}/10 correct
Time Taken: ${Math.floor(timeTaken / 60)} minutes ${timeTaken % 60} seconds

Provide a JSON response with:
1. "skillLevel": One of "Beginner", "Intermediate", "Advanced", or "Expert"
2. "analysis": A 2-3 sentence personalized analysis of their performance
3. "strengths": An array of 2-3 specific strengths based on their performance
4. "weaknesses": An array of 2-3 specific areas for improvement

Be encouraging but honest. Focus on actionable feedback.`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are an expert programming instructor providing personalized quiz feedback. Always respond with valid JSON.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 500,
      response_format: { type: 'json_object' }
    });

    const analysisText = completion.choices[0].message.content;
    const analysis = JSON.parse(analysisText);

    res.json(analysis);
  } catch (error) {
    console.error('AI Analysis Error:', error);
    res.json(generateFallbackAnalysis(req.body));
  }
});

function generateFallbackAnalysis(data) {
  const { percentage, easyCorrect, mediumCorrect, hardCorrect, technologyName } = data;

  let skillLevel;
  let strengths = [];
  let weaknesses = [];
  let analysis;

  if (percentage >= 90) {
    skillLevel = 'Expert';
    analysis = `Outstanding performance on the ${technologyName} quiz! You've demonstrated mastery of both fundamental and advanced concepts. Your comprehensive understanding positions you well for complex real-world challenges.`;
    strengths = [
      'Excellent mastery of core concepts',
      'Strong problem-solving abilities',
      'Comprehensive understanding across all difficulty levels'
    ];
    weaknesses = [
      'Consider exploring edge cases and advanced patterns',
      'Share your knowledge by mentoring others'
    ];
  } else if (percentage >= 70) {
    skillLevel = 'Advanced';
    analysis = `Great job on the ${technologyName} quiz! You have a solid grasp of the fundamentals and good understanding of intermediate concepts. With focused practice on advanced topics, you'll reach expert level.`;
    strengths = [
      'Good understanding of fundamental concepts',
      'Solid grasp of intermediate topics'
    ];
    weaknesses = [
      'Focus more on advanced and edge-case scenarios',
      'Practice more complex problem-solving exercises'
    ];
  } else if (percentage >= 50) {
    skillLevel = 'Intermediate';
    analysis = `Good effort on the ${technologyName} quiz! You've shown understanding of basic concepts. Continue building your knowledge with hands-on projects and focused study on areas you found challenging.`;
    strengths = [
      'Understanding of basic concepts',
      'Good foundation to build upon'
    ];
    weaknesses = [
      'Review medium and hard difficulty topics',
      'Practice with real-world coding examples',
      'Consider structured learning resources'
    ];
  } else {
    skillLevel = 'Beginner';
    analysis = `Keep practicing ${technologyName}! Everyone starts somewhere, and consistent practice is key. Focus on understanding the fundamentals first, then gradually work up to more complex topics.`;
    strengths = [
      'Taking initiative to learn',
      'Identifying areas for growth'
    ];
    weaknesses = [
      'Start with fundamental concepts and documentation',
      'Practice basic exercises regularly',
      'Consider following a structured learning path'
    ];
  }

  if (easyCorrect >= 8) {
    strengths.push('Strong foundation in fundamental concepts');
  }
  if (hardCorrect >= 7) {
    strengths.push('Excellent grasp of advanced topics');
  }
  if (easyCorrect < 5) {
    weaknesses.push('Review and reinforce basic fundamentals');
  }
  if (hardCorrect < 3) {
    weaknesses.push('Dedicate time to advanced problem-solving');
  }

  return {
    skillLevel,
    analysis,
    strengths: strengths.slice(0, 3),
    weaknesses: weaknesses.slice(0, 3)
  };
}

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../web/index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Programming Quiz Server running on http://0.0.0.0:${PORT}`);
});
