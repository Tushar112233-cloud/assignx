# Lottie Animations

## Directory Structure

```
lottie/
├── icons/           # Small icon animations
│   ├── checkmark.json
│   ├── loading.json
│   ├── new-project.json
│   ├── proofread.json
│   ├── ai-check.json
│   └── expert.json
├── success.json     # Success celebration
├── error.json       # Error state
└── confetti.json    # Confetti celebration
```

## Recommended Sources

- LottieFiles: https://lottiefiles.com/
- IconScout: https://iconscout.com/lottie-animations

## Usage with lottie-react

```tsx
import Lottie from "lottie-react";
import checkmarkAnimation from "@/public/lottie/icons/checkmark.json";

<Lottie
  animationData={checkmarkAnimation}
  loop={false}
  style={{ width: 48, height: 48 }}
/>
```
