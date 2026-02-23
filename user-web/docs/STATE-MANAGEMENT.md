# State Management Documentation

## Overview

AssignX uses **Zustand** for global state management. Zustand provides a minimal, hook-based API with excellent TypeScript support and optional persistence.

## Store Architecture

```
stores/
├── index.ts              # Barrel exports
├── user-store.ts         # User authentication state
├── project-store.ts      # Project data and filters
├── wallet-store.ts       # Wallet balance
└── notification-store.ts # Notifications
```

---

## User Store (`user-store.ts`)

Manages authenticated user state with localStorage persistence.

### Interface
```typescript
interface UserState {
  user: User | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setLoading: (isLoading: boolean) => void;
  clearUser: () => void;
}
```

### Usage
```tsx
import { useUserStore } from "@/stores";

function Component() {
  const { user, isLoading, setUser, clearUser } = useUserStore();

  // Access user data
  if (user) {
    console.log(user.fullName);
  }

  // Update user
  setUser({ id: "123", email: "test@example.com", ... });

  // Clear on logout
  clearUser();
}
```

### Persistence
- Stored in `localStorage` under key `user-storage`
- Automatically hydrated on app load
- Cleared on `clearUser()` call

---

## Project Store (`project-store.ts`)

Manages project list, tabs, and payment prompts.

### Interface
```typescript
interface ProjectState {
  projects: Project[];
  activeTab: ProjectTab;
  isLoading: boolean;
  hasUnpaidQuotes: boolean;
  unpaidProject: Project | null;
  showPaymentPrompt: boolean;

  setActiveTab: (tab: ProjectTab) => void;
  getProjectsByTab: (tab: ProjectTab) => Project[];
  getProjectById: (id: string) => Project | undefined;
  setLoading: (loading: boolean) => void;
  dismissPaymentPrompt: () => void;
  checkUnpaidQuotes: () => void;
}
```

### Tab to Status Mapping
```typescript
const tabStatuses = {
  in_review: ["analyzing", "quoted", "payment_pending"],
  in_progress: ["paid", "assigned", "in_progress"],
  for_review: ["delivered", "qc_approved"],
  history: ["completed", "cancelled", "refunded"],
};
```

### Usage
```tsx
import { useProjectStore } from "@/stores";

function ProjectList() {
  const {
    activeTab,
    setActiveTab,
    getProjectsByTab,
    showPaymentPrompt,
    unpaidProject,
    dismissPaymentPrompt
  } = useProjectStore();

  const projects = getProjectsByTab(activeTab);

  return (
    <>
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        {/* Tab content */}
      </Tabs>

      {showPaymentPrompt && unpaidProject && (
        <PaymentPromptModal
          project={unpaidProject}
          onDismiss={dismissPaymentPrompt}
        />
      )}
    </>
  );
}
```

---

## Wallet Store (`wallet-store.ts`)

Manages user wallet balance.

### Interface
```typescript
interface WalletState {
  balance: number;
  currency: string;
  isLoading: boolean;
  setBalance: (balance: number) => void;
  addCredits: (amount: number) => void;
  deductCredits: (amount: number) => void;
  setLoading: (isLoading: boolean) => void;
}
```

### Usage
```tsx
import { useWalletStore } from "@/stores";

function WalletPill() {
  const { balance, currency } = useWalletStore();

  return (
    <div>
      {currency}{balance}
    </div>
  );
}

function PaymentHandler() {
  const { deductCredits, balance } = useWalletStore();

  const handlePayment = (amount: number) => {
    if (balance >= amount) {
      deductCredits(amount);
      // Process payment
    }
  };
}
```

---

## Notification Store (`notification-store.ts`)

Manages user notifications.

### Interface
```typescript
interface Notification {
  id: string;
  title: string;
  message: string;
  type: "info" | "success" | "warning" | "error";
  read: boolean;
  createdAt: string;
  link?: string;
}

interface NotificationState {
  notifications: Notification[];
  unreadCount: number;
  isLoading: boolean;
  addNotification: (notification: Omit<Notification, "id" | "createdAt">) => void;
  markAsRead: (id: string) => void;
  markAllAsRead: () => void;
  clearNotifications: () => void;
  setLoading: (isLoading: boolean) => void;
}
```

### Usage
```tsx
import { useNotificationStore } from "@/stores";

function NotificationBell() {
  const {
    notifications,
    unreadCount,
    markAsRead,
    markAllAsRead
  } = useNotificationStore();

  return (
    <DropdownMenu>
      <Badge count={unreadCount} />
      {notifications.map(n => (
        <NotificationItem
          key={n.id}
          notification={n}
          onClick={() => markAsRead(n.id)}
        />
      ))}
      <Button onClick={markAllAsRead}>Mark all read</Button>
    </DropdownMenu>
  );
}

// Adding a notification programmatically
function SuccessHandler() {
  const { addNotification } = useNotificationStore();

  const onSuccess = () => {
    addNotification({
      title: "Success!",
      message: "Your project was submitted",
      type: "success",
      read: false,
      link: "/projects"
    });
  };
}
```

---

## Best Practices

### 1. Selective Subscriptions
Only subscribe to needed state:
```tsx
// Good - only re-renders when balance changes
const balance = useWalletStore((state) => state.balance);

// Avoid - re-renders on any state change
const store = useWalletStore();
```

### 2. Actions Outside Components
For complex operations, use store actions:
```tsx
// In store
const actions = {
  processPayment: async (amount: number) => {
    set({ isLoading: true });
    try {
      await api.pay(amount);
      set((state) => ({ balance: state.balance - amount }));
    } finally {
      set({ isLoading: false });
    }
  }
};
```

### 3. Computed Values
Use selectors for derived state:
```tsx
const activeProjects = useProjectStore(
  (state) => state.projects.filter(p => p.status === "in_progress")
);
```

### 4. Hydration Handling
For persisted stores, handle hydration:
```tsx
function App() {
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
  }, []);

  if (!hydrated) return <Loading />;

  return <Content />;
}
```

---

## Store Initialization

Stores are initialized automatically on first use. Mock data is loaded from:
- `lib/data/projects.json` - Project store
- Inline mock data - Notification store
- Default values - User and Wallet stores

---

## Testing Stores

```typescript
import { useProjectStore } from "@/stores";

describe("ProjectStore", () => {
  beforeEach(() => {
    useProjectStore.setState({ activeTab: "in_review" });
  });

  it("should filter projects by tab", () => {
    const projects = useProjectStore.getState().getProjectsByTab("in_review");
    expect(projects.every(p =>
      ["analyzing", "quoted", "payment_pending"].includes(p.status)
    )).toBe(true);
  });
});
```
