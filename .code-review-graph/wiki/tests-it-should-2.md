# tests-it:should

## Overview

Directory-based community: doer-web/__tests__

- **Size**: 22 nodes
- **Cohesion**: 0.3024
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| calculateQuizScore | Function | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 26-52 |
| isQuizPassed | Function | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 60-62 |
| isAnswerCorrect | Function | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 70-76 |
| describe:Quiz Scoring@L79 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 79-281 |
| describe:calculateQuizScore@L132 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 132-212 |
| it:should calculate 100% for all correct answers@L133 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 133-147 |
| it:should calculate 0% for all wrong answers@L149 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 149-163 |
| it:should calculate 60% for 3 out of 5 correct@L165 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 165-179 |
| it:should handle empty answers@L181 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 181-189 |
| it:should handle partial answers@L191 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 191-203 |
| it:should handle empty questions array@L205 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 205-211 |
| describe:isQuizPassed@L214 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 214-232 |
| it:should return true for 80% or higher@L215 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 215-219 |
| it:should return false for below 80%@L221 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 221-225 |
| it:should respect custom passing score@L227 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 227-231 |
| describe:isAnswerCorrect@L234 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 234-256 |
| it:should return true for correct answer@L245 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 245-247 |
| it:should return false for wrong answer@L249 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 249-251 |
| it:should return false for undefined answer@L253 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 253-255 |
| describe:Multiple correct answers support@L258 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 258-280 |
| it:should accept any of the correct options@L271 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 271-275 |
| it:should reject incorrect option@L277 | Test | /Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts | 277-279 |

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `toBe` (34 edge(s))
- `expect` (34 edge(s))
- `includes` (2 edge(s))
- `forEach` (1 edge(s))

### Incoming

- `toBe` (34 edge(s))
- `expect` (34 edge(s))
- `/Volumes/Crucial X9/AssignX/doer-web/__tests__/quiz-scoring.test.ts` (4 edge(s))
