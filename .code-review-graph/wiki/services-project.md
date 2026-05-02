# services-project

## Overview

Directory-based community: user-web/services

- **Size**: 62 nodes
- **Cohesion**: 0.0905
- **Dominant Language**: typescript

## Members

| Name | Kind | File | Lines |
|------|------|------|-------|
| normalizeMessage | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 9-35 |
| onConnectionStateChange | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 142-148 |
| _setConnectionState | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 153-156 |
| getOrCreateProjectChatRoom | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 161-173 |
| getChatRooms | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 178-181 |
| getMessages | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 186-199 |
| sendMessage | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 204-221 |
| uploadAttachment | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 226-237 |
| markAsRead | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 242-246 |
| markMessagesAsRead | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 251-253 |
| subscribeToRoom | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 259-301 |
| handler | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 314-316 |
| onConnect | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 278-278 |
| onDisconnect | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 279-279 |
| onReconnect | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 280-280 |
| cleanup | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 340-345 |
| subscribeToUnreadCounts | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 307-323 |
| getTotalUnreadCount | Function | /Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts | 328-335 |
| normalizeNotification | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 46-61 |
| getNotifications | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 76-92 |
| getUnreadCount | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 97-106 |
| markAsRead | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 111-115 |
| markAllAsRead | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 120-125 |
| deleteNotification | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 130-134 |
| clearReadNotifications | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 140-145 |
| subscribe | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 151-175 |
| handler | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 159-164 |
| cleanup | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 168-171 |
| requestPermission | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 180-186 |
| showBrowserNotification | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 191-200 |
| registerServiceWorker | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 205-216 |
| subscribeToPush | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 221-250 |
| urlBase64ToUint8Array | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 255-269 |
| getPreferences | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 274-301 |
| updatePreferences | Function | /Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts | 306-314 |
| getProjects | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 146-165 |
| getProjectById | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 170-179 |
| createProject | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 184-190 |
| updateProject | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 195-201 |
| uploadProjectFile | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 206-223 |
| approveProject | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 228-234 |
| requestRevision | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 239-245 |
| getProjectTimeline | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 250-255 |
| getSubjects | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 260-263 |
| getReferenceStyles | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 268-271 |
| getProjectCounts | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 277-286 |
| getPendingPaymentProjects | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 291-296 |
| getProjectQuotes | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 301-306 |
| getChatTimeline | Function | /Volumes/Crucial X9/AssignX/user-web/services/project.service.ts | 311-348 |
| getWallet | Function | /Volumes/Crucial X9/AssignX/user-web/services/wallet.service.ts | 90-97 |

*... and 12 more members.*

## Execution Flows

No execution flows pass through this community.

## Dependencies

### Outgoing

- `set` (18 edge(s))
- `stringify` (18 edge(s))
- `toString` (12 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/lib/api/client.ts::apiClient` (9 edge(s))
- `off` (6 edge(s))
- `String` (6 edge(s))
- `on` (6 edge(s))
- `append` (6 edge(s))
- `forEach` (4 edge(s))
- `callback` (4 edge(s))
- `isArray` (3 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/lib/socket/client.ts::getSocket` (3 edge(s))
- `toISOString` (3 edge(s))
- `warn` (3 edge(s))
- `substring` (3 edge(s))

### Incoming

- `/Volumes/Crucial X9/AssignX/user-web/services/chat.service.ts` (20 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/services/notification.service.ts` (17 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/services/project.service.ts` (14 edge(s))
- `/Volumes/Crucial X9/AssignX/user-web/services/wallet.service.ts` (13 edge(s))
