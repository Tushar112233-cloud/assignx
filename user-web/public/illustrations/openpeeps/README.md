# OpenPeeps Illustrations

Download from: https://www.openpeeps.com/

## Required Assets

Place the following SVG files in this directory:

- `celebrating.svg` - Person celebrating (for success states)
- `relaxing.svg` - Person relaxing in hammock (for empty projects)
- `working.svg` - Person working on laptop (for in-progress)
- `waving.svg` - Person waving hello (for sidebar/greeting)
- `confused.svg` - Person scratching head (for error states)
- `thinking.svg` - Person thinking (for loading states)
- `reading.svg` - Person reading (for empty notifications)

## Usage

```tsx
import Image from "next/image";

<Image
  src="/illustrations/openpeeps/celebrating.svg"
  alt="Celebration"
  width={200}
  height={200}
/>
```

## License

OpenPeeps is CC0 - free for personal and commercial use.
