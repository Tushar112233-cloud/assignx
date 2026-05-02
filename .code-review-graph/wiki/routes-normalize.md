# routes-normalize

## Overview

Directory-based community: api-server/src

- **Size**: 108 nodes
- **Cohesion**: 0.0224
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| getCloudinary | Function | /Volumes/Crucial X9/AssignX/api-server/src/config/cloudinary.ts | 5-15 |
| connectDatabase | Function | /Volumes/Crucial X9/AssignX/api-server/src/config/database.ts | 3-24 |
| getResend | Function | /Volumes/Crucial X9/AssignX/api-server/src/config/resend.ts | 5-10 |
| get | Function | /Volumes/Crucial X9/AssignX/api-server/src/config/resend.ts | 13-15 |
| initializeSocket | Function | /Volumes/Crucial X9/AssignX/api-server/src/config/socket.ts | 17-66 |
| start | Function | /Volumes/Crucial X9/AssignX/api-server/src/index.ts | 54-59 |
| authenticate | Function | /Volumes/Crucial X9/AssignX/api-server/src/middleware/auth.ts | 5-23 |
| optionalAuth | Function | /Volumes/Crucial X9/AssignX/api-server/src/middleware/auth.ts | 25-43 |
| AppError | Class | /Volumes/Crucial X9/AssignX/api-server/src/middleware/errorHandler.ts | 3-13 |
| constructor | Function | /Volumes/Crucial X9/AssignX/api-server/src/middleware/errorHandler.ts | 7-12 |
| globalErrorHandler | Function | /Volumes/Crucial X9/AssignX/api-server/src/middleware/errorHandler.ts | 15-33 |
| requireRole | Function | /Volumes/Crucial X9/AssignX/api-server/src/middleware/roleGuard.ts | 4-14 |
| findAnyWallet | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts | 16-26 |
| s | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts | 1171-1171 |
| ids | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts | 695-695 |
| d | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts | 1170-1170 |
| p | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts | 1172-1172 |
| f | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/admin.routes.ts | 1175-1175 |
| getModelByRole | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/auth.routes.ts | 15-23 |
| directLogin | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/auth.routes.ts | 25-94 |
| r | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/chat.routes.ts | 86-86 |
| p | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/chat.routes.ts | 83-83 |
| room | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/chat.routes.ts | 101-126 |
| m | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/chat.routes.ts | 297-305 |
| id | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/chat.routes.ts | 372-372 |
| normalizePost | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/community.routes.ts | 10-17 |
| normalizePosts | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/community.routes.ts | 19-21 |
| p | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/community.routes.ts | 446-446 |
| s | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/community.routes.ts | 465-465 |
| i | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/community.routes.ts | 492-492 |
| normalizePost | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/connect.routes.ts | 9-16 |
| normalizePosts | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/connect.routes.ts | 18-20 |
| p | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/connect.routes.ts | 62-62 |
| i | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/connect.routes.ts | 107-107 |
| normalizeDoer | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/doer.routes.ts | 10-48 |
| d | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/doer.routes.ts | 73-81 |
| normalizeExpert | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/expert.routes.ts | 11-58 |
| r | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/expert.routes.ts | 519-529 |
| formatTicketSize | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/investor.routes.ts | 12-21 |
| fmt | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/investor.routes.ts | 15-19 |
| normalizeInvestor | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/investor.routes.ts | 23-53 |
| normalizePitchDeck | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/investor.routes.ts | 55-81 |
| normalizeJob | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/job.routes.ts | 12-49 |
| normalizeApplication | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/job.routes.ts | 51-68 |
| formatRelativeTime | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/job.routes.ts | 70-84 |
| s | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/marketplace.routes.ts | 132-132 |
| getWalletModel | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/payment.routes.ts | 9-20 |
| getWalletType | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/payment.routes.ts | 22-27 |
| autoJoinProjectChat | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/project.routes.ts | 11-24 |
| resolveId | Function | /Volumes/Crucial X9/AssignX/api-server/src/routes/project.routes.ts | 186-190 |

*... and 58 more members.*

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `log` (95 edge(s))
- `now` (80 edge(s))
- `findOne` (39 edge(s))
- `toString` (25 edge(s))
- `create` (22 edge(s))
- `includes` (21 edge(s))
- `collection` (21 edge(s))
- `find` (18 edge(s))
- `insertMany` (18 edge(s))
- `save` (16 edge(s))
- `toLowerCase` (14 edge(s))
- `on` (13 edge(s))
- `toObject` (13 edge(s))
- `push` (12 edge(s))
- `countDocuments` (12 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/api-server/src/routes/supervisor.routes.ts` (86 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/community.routes.ts` (35 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/project.routes.ts` (27 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/chat.routes.ts` (24 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/user.routes.ts` (18 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/training.routes.ts` (15 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/investor.routes.ts` (14 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/marketplace.routes.ts` (14 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/support.routes.ts` (14 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/doer.routes.ts` (13 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/expert.routes.ts` (13 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/connect.routes.ts` (12 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/wallet.routes.ts` (12 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/scripts/seed-jasvin-data.js` (12 edge(s))
- `/Volumes/Crucial X9/AssignX/api-server/src/routes/job.routes.ts` (10 edge(s))
