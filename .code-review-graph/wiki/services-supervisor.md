# services-supervisor

## Overview

Directory-based community: superviser-web/services

- **Size**: 14 nodes
- **Cohesion**: 0.0263
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| getSession | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 13-24 |
| getUser | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 29-44 |
| signUp | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 49-64 |
| signIn | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 69-84 |
| signInWithGoogle | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 89-93 |
| signOut | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 264-266 |
| resetPassword | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 111-117 |
| updatePassword | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 122-128 |
| getSupervisor | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 138-145 |
| getSupervisorActivation | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 150-159 |
| createSupervisor | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 165-179 |
| updateSupervisor | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 184-204 |
| createSupervisorActivation | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 210-223 |
| updateSupervisorActivation | Function | /Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts | 228-257 |

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `stringify` (8 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts::apiFetch` (4 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts::storeUser` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts::setTokens` (2 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts::getAccessToken` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts::getStoredUser` (1 edge(s))
- `encodeURIComponent` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/client.ts::clearTokens` (1 edge(s))
- `/Volumes/Crucial X9/AssignX/superviser-web/lib/api/auth.ts::clearStoredUser` (1 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/superviser-web/services/auth.service.ts` (15 edge(s))
