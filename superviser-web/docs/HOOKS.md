# Hooks Documentation

> **AdminX Supervisor Panel** - Custom React Hooks Reference

## Table of Contents

1. [Overview](#overview)
2. [State Hooks](#state-hooks)
3. [UI Hooks](#ui-hooks)
4. [Utility Hooks](#utility-hooks)
5. [Analytics Hooks](#analytics-hooks)

---

## Overview

Custom hooks in AdminX provide reusable logic for common patterns. All hooks follow React best practices and TypeScript typing.

**Location:** `hooks/`

---

## State Hooks

### useSupervisorStore

Zustand store hook for supervisor state.

```typescript
import { useSupervisorStore } from "@/store"

function Component() {
  const {
    supervisor,
    isAvailable,
    setSupervisor,
    setAvailability,
  } = useSupervisorStore()

  return (
    <div>
      <p>Welcome, {supervisor?.full_name}</p>
      <Toggle
        checked={isAvailable}
        onCheckedChange={setAvailability}
      />
    </div>
  )
}
```

**State:**
| Property | Type | Description |
|----------|------|-------------|
| supervisor | Supervisor \| null | Current supervisor data |
| isAvailable | boolean | Availability status |
| notifications | Notification[] | Unread notifications |

**Actions:**
| Method | Parameters | Description |
|--------|------------|-------------|
| setSupervisor | supervisor | Set supervisor data |
| setAvailability | boolean | Update availability |
| addNotification | notification | Add new notification |
| clearNotifications | - | Clear all notifications |

---

## UI Hooks

### useMediaQuery

Responsive design media query hook.

```typescript
import { useMediaQuery } from "@/hooks/use-media-query"

function Component() {
  const isMobile = useMediaQuery("(max-width: 768px)")
  const isTablet = useMediaQuery("(max-width: 1024px)")
  const isDarkMode = useMediaQuery("(prefers-color-scheme: dark)")

  return (
    <div>
      {isMobile ? <MobileLayout /> : <DesktopLayout />}
    </div>
  )
}
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| query | string | CSS media query string |

**Returns:** `boolean` - Whether the query matches

**Common Queries:**
```typescript
// Screen sizes
"(max-width: 640px)"   // sm
"(max-width: 768px)"   // md
"(max-width: 1024px)"  // lg
"(max-width: 1280px)"  // xl

// Preferences
"(prefers-color-scheme: dark)"
"(prefers-reduced-motion: reduce)"
```

---

### useFocusTrap

Trap focus within a container for accessibility.

```typescript
import { useFocusTrap } from "@/hooks/use-focus-trap"

function Modal({ isOpen, onClose }) {
  const containerRef = useFocusTrap<HTMLDivElement>(isOpen)

  return (
    <div ref={containerRef} role="dialog">
      <h2>Modal Title</h2>
      <button onClick={onClose}>Close</button>
    </div>
  )
}
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| enabled | boolean | Whether trap is active |

**Returns:** `RefObject<T>` - Ref to attach to container

**Features:**
- Traps Tab and Shift+Tab
- Returns focus on unmount
- Handles edge cases

---

### useKeyboardNavigation

Handle keyboard navigation patterns.

```typescript
import { useKeyboardNavigation } from "@/hooks/use-keyboard-navigation"

function Menu({ items, onSelect }) {
  const {
    activeIndex,
    setActiveIndex,
    handleKeyDown,
  } = useKeyboardNavigation({
    itemCount: items.length,
    onSelect: (index) => onSelect(items[index]),
    orientation: "vertical",
  })

  return (
    <ul onKeyDown={handleKeyDown}>
      {items.map((item, index) => (
        <li
          key={item.id}
          tabIndex={index === activeIndex ? 0 : -1}
          aria-selected={index === activeIndex}
          onFocus={() => setActiveIndex(index)}
        >
          {item.label}
        </li>
      ))}
    </ul>
  )
}
```

**Options:**
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| itemCount | number | required | Total items |
| onSelect | (index) => void | - | Selection callback |
| orientation | "horizontal" \| "vertical" | "vertical" | Navigation direction |
| loop | boolean | true | Loop at ends |
| initialIndex | number | 0 | Starting index |

**Returns:**
| Property | Type | Description |
|----------|------|-------------|
| activeIndex | number | Currently focused index |
| setActiveIndex | (index) => void | Set active index |
| handleKeyDown | (event) => void | Keyboard event handler |

**Supported Keys:**
- Arrow Up/Down (vertical)
- Arrow Left/Right (horizontal)
- Home/End
- Enter/Space (select)

---

## Utility Hooks

### useDebounce

Debounce a value for delayed updates.

```typescript
import { useDebounce } from "@/hooks/use-debounce"

function SearchInput() {
  const [value, setValue] = useState("")
  const debouncedValue = useDebounce(value, 300)

  useEffect(() => {
    // API call with debounced value
    searchAPI(debouncedValue)
  }, [debouncedValue])

  return (
    <input
      value={value}
      onChange={(e) => setValue(e.target.value)}
    />
  )
}
```

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| value | T | required | Value to debounce |
| delay | number | 500 | Delay in ms |

**Returns:** `T` - Debounced value

---

### useLocalStorage

Persist state to localStorage.

```typescript
import { useLocalStorage } from "@/hooks/use-local-storage"

function Settings() {
  const [theme, setTheme] = useLocalStorage("theme", "light")

  return (
    <select
      value={theme}
      onChange={(e) => setTheme(e.target.value)}
    >
      <option value="light">Light</option>
      <option value="dark">Dark</option>
    </select>
  )
}
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| key | string | localStorage key |
| initialValue | T | Default value |

**Returns:** `[T, (value: T) => void]` - State tuple

**Features:**
- SSR safe
- JSON serialization
- Type preservation

---

### useOnClickOutside

Detect clicks outside an element.

```typescript
import { useOnClickOutside } from "@/hooks/use-on-click-outside"

function Dropdown({ onClose }) {
  const ref = useRef<HTMLDivElement>(null)

  useOnClickOutside(ref, () => {
    onClose()
  })

  return (
    <div ref={ref}>
      Dropdown content
    </div>
  )
}
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| ref | RefObject | Element reference |
| handler | (event) => void | Click handler |

---

### usePrevious

Track previous value of a state.

```typescript
import { usePrevious } from "@/hooks/use-previous"

function Counter() {
  const [count, setCount] = useState(0)
  const prevCount = usePrevious(count)

  return (
    <div>
      <p>Current: {count}</p>
      <p>Previous: {prevCount}</p>
      <button onClick={() => setCount(c => c + 1)}>
        Increment
      </button>
    </div>
  )
}
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| value | T | Current value |

**Returns:** `T | undefined` - Previous value

---

### useIsomorphicLayoutEffect

SSR-safe useLayoutEffect.

```typescript
import { useIsomorphicLayoutEffect } from "@/hooks/use-isomorphic-layout-effect"

function Component() {
  useIsomorphicLayoutEffect(() => {
    // DOM measurement code
    const height = element.getBoundingClientRect().height
  }, [])
}
```

Uses `useLayoutEffect` on client, `useEffect` on server.

---

## Analytics Hooks

### useAnalytics

Analytics tracking hook.

```typescript
import { useAnalytics } from "@/hooks/use-analytics"

function ProjectCard({ project }) {
  const { trackEvent, trackPageView } = useAnalytics()

  useEffect(() => {
    trackPageView('/projects')
  }, [])

  const handleClick = () => {
    trackEvent('project_viewed', {
      projectId: project.id,
      subject: project.subject,
    })
  }

  return (
    <div onClick={handleClick}>
      {project.title}
    </div>
  )
}
```

**Returns:**
| Method | Parameters | Description |
|--------|------------|-------------|
| trackEvent | (name, properties?) | Track custom event |
| trackPageView | (path) | Track page view |
| trackError | (error, context?) | Track error |
| setUser | (userId, traits?) | Identify user |

**Event Properties:**
```typescript
interface EventProperties {
  [key: string]: string | number | boolean | undefined
}
```

**Usage Examples:**
```typescript
// Track user action
trackEvent('quote_submitted', {
  projectId: 'proj-123',
  amount: 2500,
  subject: 'Economics',
})

// Track error
trackError(error, {
  component: 'QuoteModal',
  action: 'submit',
})

// Set user identity
setUser(supervisor.id, {
  name: supervisor.full_name,
  email: supervisor.email,
})
```

---

## Creating Custom Hooks

### Guidelines

1. **Naming:** Start with `use` prefix
2. **Location:** Place in `hooks/` directory
3. **Documentation:** Add JSDoc comments
4. **Types:** Export types if needed
5. **Testing:** Add unit tests

### Template

```typescript
/**
 * @fileoverview Custom hook for [purpose].
 * @module hooks/use-hook-name
 */

import { useState, useEffect } from 'react'

interface UseHookNameOptions {
  option1?: string
  option2?: number
}

interface UseHookNameReturn {
  value: string
  setValue: (value: string) => void
}

/**
 * Hook description.
 *
 * @param options - Configuration options
 * @returns Hook return value
 *
 * @example
 * ```tsx
 * const { value, setValue } = useHookName({ option1: 'test' })
 * ```
 */
export function useHookName(
  options: UseHookNameOptions = {}
): UseHookNameReturn {
  const { option1 = 'default', option2 = 0 } = options

  const [value, setValue] = useState('')

  useEffect(() => {
    // Effect logic
  }, [option1, option2])

  return { value, setValue }
}
```

---

## Hook Dependencies

```
hooks/
├── use-analytics.ts        # Analytics tracking
├── use-debounce.ts         # Value debouncing
├── use-focus-trap.ts       # Focus management
├── use-keyboard-navigation.ts  # Keyboard nav
├── use-local-storage.ts    # localStorage sync
├── use-media-query.ts      # Responsive queries
├── use-on-click-outside.ts # Click detection
├── use-previous.ts         # Previous value
└── index.ts                # Barrel exports
```
