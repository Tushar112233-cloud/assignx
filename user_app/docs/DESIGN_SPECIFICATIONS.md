# Design Specifications - Mobile App

## Overview
This document contains detailed design specifications extracted from reference images for the AssignX mobile application.

---

## 1. Mobile Dashboard Design (MobileDashboard_1.png)

### Color Palette

#### Background
- **Main Background**: `#F9FAFB` (Light gray, almost white)
- **Card Background**: `#FFFFFF` (Pure white)
- **Accent Color**: `#6366F1` (Indigo - used for icons and active states)

#### Text Colors
- **Primary Heading**: `#111827` (Near black)
- **Body Text**: `#6B7280` (Medium gray)
- **Subtext**: `#9CA3AF` (Light gray)
- **Badge/Count Text**: `#1F2937` (Dark gray)

#### Status Colors
- **Payment Due**: Red dot indicator `#EF4444`
- **Delivered**: Green indicator (implied by context)

### Typography

#### Header Section
- **App Title (AssignX)**:
  - Font: System default / Inter
  - Size: `16px`
  - Weight: `600` (Semi-bold)
  - Color: `#111827`

- **Greeting Text ("Good Evening,")**:
  - Font: System default / Inter
  - Size: `14px`
  - Weight: `400` (Regular)
  - Color: `#6B7280`

- **User Name ("Om")**:
  - Font: System default / Inter
  - Size: `28px`
  - Weight: `700` (Bold)
  - Color: `#111827`

- **Subtitle Text**:
  - Font: System default / Inter
  - Size: `14px`
  - Weight: `400` (Regular)
  - Color: `#9CA3AF`
  - Line Height: `1.5`

#### Action Cards
- **Card Title**:
  - Font: System default / Inter
  - Size: `16px`
  - Weight: `600` (Semi-bold)
  - Color: `#111827`

- **Card Description**:
  - Font: System default / Inter
  - Size: `12px`
  - Weight: `400` (Regular)
  - Color: `#6B7280`
  - Line Height: `1.4`

#### Section Headers
- **"NEEDS ATTENTION"**:
  - Font: System default / Inter
  - Size: `11px`
  - Weight: `600` (Semi-bold)
  - Color: `#6B7280`
  - Letter Spacing: `0.5px`
  - Text Transform: `uppercase`

- **Badge Count**:
  - Font: System default / Inter
  - Size: `12px`
  - Weight: `600` (Semi-bold)
  - Color: `#1F2937`
  - Background: `#F3F4F6`
  - Border Radius: `12px`
  - Padding: `2px 8px`

#### List Items
- **Item Title**:
  - Font: System default / Inter
  - Size: `14px`
  - Weight: `500` (Medium)
  - Color: `#111827`

- **Item Subtitle**:
  - Font: System default / Inter
  - Size: `12px`
  - Weight: `400` (Regular)
  - Color: `#9CA3AF`

### Layout & Spacing

#### Screen Layout
- **Screen Padding (Horizontal)**: `20px`
- **Screen Padding (Top)**: `16px`
- **Screen Padding (Bottom)**: `100px` (to accommodate bottom nav)

#### Header Section
- **Header Height**: ~`200px`
- **Logo to Greeting Spacing**: `24px`
- **Greeting to Name Spacing**: `4px`
- **Name to Subtitle Spacing**: `8px`
- **Subtitle to Cards Spacing**: `24px`

#### Action Cards Grid
- **Grid Layout**: 2 columns
- **Column Gap**: `12px`
- **Row Gap**: `12px`
- **Card Aspect Ratio**: ~`1:1.2` (slightly taller than square)

#### Card Specifications
- **Card Padding**: `20px`
- **Card Border Radius**: `16px`
- **Card Shadow**:
  - X: `0px`
  - Y: `2px`
  - Blur: `8px`
  - Spread: `0px`
  - Color: `rgba(0, 0, 0, 0.04)`
- **Icon Size**: `24px x 24px`
- **Icon to Title Spacing**: `12px`
- **Title to Description Spacing**: `4px`

#### Needs Attention Section
- **Section Margin Top**: `32px`
- **Header Margin Bottom**: `16px`
- **List Item Height**: `64px`
- **List Item Padding**: `12px 0`
- **List Item Border**: Bottom only, `1px solid #F3F4F6`

#### List Item Layout
- **Indicator Dot Size**: `8px`
- **Indicator to Content Spacing**: `12px`
- **Content to Chevron Spacing**: `auto` (flex end)
- **Chevron Size**: `20px x 20px`
- **Chevron Color**: `#D1D5DB`

### Bottom Navigation Bar

#### Container
- **Background**: `#FFFFFF`
- **Height**: `72px`
- **Position**: Fixed bottom, `40px` from screen bottom
- **Width**: Screen width minus `40px` (20px padding each side)
- **Border Radius**: `24px`
- **Shadow**:
  - X: `0px`
  - Y: `-4px`
  - Blur: `20px`
  - Spread: `0px`
  - Color: `rgba(0, 0, 0, 0.08)`

#### Navigation Items
- **Count**: 5 items
- **Layout**: Flex, evenly distributed
- **Icon Size**: `24px x 24px`
- **Icon Color (Inactive)**: `#9CA3AF`
- **Icon Color (Active)**: `#6366F1`
- **Profile Picture Size**: `32px x 32px`
- **Profile Border**: `2px solid #6366F1` (when active)

### Icons
- **Icon Style**: Outlined (stroke-based)
- **Icon Weight**: `1.5px` stroke
- **Icon Set**: Lucide or similar

#### Icon List
1. Home: House outline
2. Folder: Folder outline
3. Users: People outline
4. Calendar: Calendar outline
5. Profile: Avatar/Image

### Interactive States

#### Card Hover/Press
- **Background**: `#F9FAFB`
- **Scale**: `0.98`
- **Transition**: `150ms ease-in-out`

#### List Item Press
- **Background**: `#F9FAFB`
- **Transition**: `100ms ease-in-out`

#### Bottom Nav Active
- **Icon Color**: `#6366F1`
- **Scale**: `1.1`
- **Transition**: `200ms ease-in-out`

---

## 2. Campus Connect Design (CampusConnect_1.png)

### Color Palette

#### Background
- **Gradient Background**:
  - Start: `#FFE5E5` (Soft peach)
  - Via: `#FFEAA7` (Soft yellow)
  - To: `#B2FFDA` (Soft mint green)
  - Direction: Top-left to bottom-right
  - Style: Soft, pastel gradient

- **Card Background**: `#FFFFFF` (Pure white)
- **Search Bar Background**: `#FFFFFF` (Pure white)

#### Text Colors
- **Primary Heading**: `#111827` (Near black)
- **Body Text**: `#4B5563` (Dark gray)
- **Subtext**: `#9CA3AF` (Light gray)
- **Tag Text**: Various (see tags section)

#### Accent Colors
- **Search Icon**: `#6B7280`
- **Filter Icon**: `#6B7280`
- **Message Icon**: `#6366F1` (Indigo)

### Typography

#### Header Section
- **App Title (AssignX)**:
  - Font: System default / Inter
  - Size: `14px`
  - Weight: `600` (Semi-bold)
  - Color: `#FFFFFF`

- **Page Title (Campus Connect)**:
  - Font: System default / Inter
  - Size: `16px`
  - Weight: `600` (Semi-bold)
  - Color: `#FFFFFF`
  - Background: `#FFFFFF`
  - Padding: `6px 12px`
  - Border Radius: `12px`

#### Search & Filter
- **Search Placeholder**:
  - Font: System default / Inter
  - Size: `14px`
  - Weight: `400` (Regular)
  - Color: `#9CA3AF`

#### Category Tabs
- **Tab Text**:
  - Font: System default / Inter
  - Size: `14px`
  - Weight: `500` (Medium)
  - Color: `#4B5563`
  - Active Color: `#111827`
  - Active Border Bottom: `2px solid #6366F1`

- **Listing Count**:
  - Font: System default / Inter
  - Size: `12px`
  - Weight: `400` (Regular)
  - Color: `#9CA3AF`

#### Post Cards
- **Post Title**:
  - Font: System default / Inter
  - Size: `15px`
  - Weight: `600` (Semi-bold)
  - Color: `#111827`

- **Post Description**:
  - Font: System default / Inter
  - Size: `13px`
  - Weight: `400` (Regular)
  - Color: `#6B7280`
  - Line Height: `1.5`

- **Author Name**:
  - Font: System default / Inter
  - Size: `12px`
  - Weight: `500` (Medium)
  - Color: `#111827`

- **Tag Labels**:
  - Font: System default / Inter
  - Size: `11px`
  - Weight: `500` (Medium)
  - Various colors (see tags section)

### Layout & Spacing

#### Header Section
- **Header Height**: `120px`
- **Header Padding**: `16px 20px`
- **Status Bar Height**: `44px`
- **Navigation Icons Size**: `20px x 20px`

#### Floating Message Icon
- **Position**: Top-right corner
- **Size**: `56px x 56px`
- **Background**: `#FFFFFF`
- **Icon Size**: `24px x 24px`
- **Icon Color**: `#6366F1`
- **Border Radius**: `28px` (circular)
- **Shadow**:
  - X: `0px`
  - Y: `4px`
  - Blur: `12px`
  - Spread: `0px`
  - Color: `rgba(99, 102, 241, 0.2)`
- **Top Position**: `60px` from top
- **Right Position**: `20px` from right

#### Search Section
- **Search Bar Height**: `48px`
- **Search Bar Border Radius**: `12px`
- **Search Bar Padding**: `12px 16px`
- **Search Icon Size**: `20px x 20px`
- **Filter Icon Size**: `20px x 20px`
- **Icon Spacing**: `12px`
- **Search to Tabs Spacing**: `16px`

#### Category Tabs
- **Tab Container Height**: `48px`
- **Tab Padding**: `12px 0`
- **Tab Spacing**: `24px` between tabs
- **Active Indicator Height**: `2px`
- **Active Indicator Bottom**: `0px`

#### Listing Count
- **Margin Top**: `12px`
- **Margin Bottom**: `16px`

#### Post Cards
- **Card Margin Bottom**: `16px`
- **Card Border Radius**: `20px`
- **Card Padding**: `20px`
- **Card Shadow**:
  - X: `0px`
  - Y: `2px`
  - Blur: `12px`
  - Spread: `0px`
  - Color: `rgba(0, 0, 0, 0.06)`

#### Card Icon
- **Icon Background**: `#F9FAFB` (Light gray circle)
- **Icon Size**: `48px x 48px` (container)
- **Icon Inner Size**: `24px x 24px`
- **Icon Border Radius**: `24px` (circular)
- **Icon Margin Bottom**: `12px`
- **Icon Colors**: Various muted pastels

#### Card Content
- **Title Margin Bottom**: `8px`
- **Description Margin Bottom**: `12px`
- **Author Section Margin Bottom**: `12px`

#### Author Section
- **Avatar Size**: `24px x 24px`
- **Avatar Border Radius**: `12px` (circular)
- **Avatar to Name Spacing**: `8px`
- **Name to Tag Spacing**: `auto` (flex end)

#### Tags
- **Tag Padding**: `4px 12px`
- **Tag Border Radius**: `8px`
- **Tag Spacing**: `8px` (if multiple)

### Tag Color Specifications

#### Community Tag
- **Background**: `#DBEAFE`
- **Text Color**: `#1E40AF`

#### Event Tag
- **Background**: `#D1FAE5`
- **Text Color**: `#065F46`

#### Product Tag
- **Background**: `#FCE7F3`
- **Text Color**: `#9F1239`

#### Help Tag
- **Background**: `#FEF3C7`
- **Text Color**: `#92400E`

#### Housing Tag
- **Background**: `#E0E7FF`
- **Text Color**: `#3730A3`

### Post Card Icon Styles

#### Icon Containers
- **Food/Utensils**: `#FFE4E6` background
- **Error/Alert**: `#FEE2E2` background
- **Cloud**: `#F3F4F6` background
- **Bike**: `#F3F4F6` background
- **Book**: `#F3F4F6` background

#### Icon Colors
- **Utensils**: `#9CA3AF`
- **Alert Circle**: `#EF4444`
- **Cloud**: `#9CA3AF`
- **Bike**: `#9CA3AF`
- **Book**: `#9CA3AF`

### Interactive States

#### Search Bar Focus
- **Border**: `2px solid #6366F1`
- **Shadow**: `0 0 0 3px rgba(99, 102, 241, 0.1)`

#### Tab Hover
- **Color**: `#111827`
- **Transition**: `150ms ease-in-out`

#### Tab Active
- **Color**: `#111827`
- **Border Bottom**: `2px solid #6366F1`
- **Font Weight**: `600` (Semi-bold)

#### Card Hover/Press
- **Scale**: `0.98`
- **Shadow**: Slightly increased
- **Transition**: `200ms ease-in-out`

#### Floating Action Button (Message)
- **Hover Scale**: `1.05`
- **Press Scale**: `0.95`
- **Shadow (Hover)**: Increased blur to `16px`

---

## 3. Shared Design Principles

### Border Radius Scale
- **XS**: `8px` (small elements, tags)
- **SM**: `12px` (buttons, inputs)
- **MD**: `16px` (cards)
- **LG**: `20px` (large cards)
- **XL**: `24px` (bottom nav)
- **Full**: `50%` (circles)

### Shadow Scale
- **XS**: `0 1px 2px rgba(0, 0, 0, 0.04)`
- **SM**: `0 2px 8px rgba(0, 0, 0, 0.04)`
- **MD**: `0 2px 12px rgba(0, 0, 0, 0.06)`
- **LG**: `0 4px 20px rgba(0, 0, 0, 0.08)`
- **XL**: `0 8px 32px rgba(0, 0, 0, 0.12)`

### Spacing Scale
- **4px**: Tight spacing (icon to text)
- **8px**: Close spacing (title to description)
- **12px**: Default spacing (elements within cards)
- **16px**: Medium spacing (cards, sections)
- **20px**: Screen padding
- **24px**: Large spacing (sections)
- **32px**: Extra large spacing (major sections)

### Animation Timing
- **Fast**: `100ms` (subtle feedback)
- **Default**: `150ms` (standard interactions)
- **Medium**: `200ms` (transitions)
- **Slow**: `300ms` (complex animations)

### Easing Functions
- **Ease In Out**: Standard interactions
- **Ease Out**: Entrances
- **Ease In**: Exits

---

## 4. Component-Specific Guidelines

### Action Cards (Dashboard)
```typescript
interface ActionCard {
  icon: LucideIcon;
  title: string;
  description: string;
  onPress: () => void;
}

// Styling
const cardStyle = {
  width: 'calc(50% - 6px)', // 2 columns with 12px gap
  aspectRatio: 1 / 1.2,
  padding: 20,
  borderRadius: 16,
  backgroundColor: '#FFFFFF',
  shadowColor: '#000000',
  shadowOffset: { width: 0, height: 2 },
  shadowOpacity: 0.04,
  shadowRadius: 8,
  elevation: 2, // Android
};
```

### List Items (Dashboard)
```typescript
interface ListItem {
  id: string;
  title: string;
  subtitle: string;
  status: 'due' | 'delivered' | 'pending';
  onPress: () => void;
}

// Styling
const listItemStyle = {
  height: 64,
  paddingVertical: 12,
  borderBottomWidth: 1,
  borderBottomColor: '#F3F4F6',
  flexDirection: 'row',
  alignItems: 'center',
};
```

### Post Cards (Campus Connect)
```typescript
interface PostCard {
  id: string;
  icon: LucideIcon;
  iconBg: string;
  title: string;
  description: string;
  author: {
    name: string;
    avatar?: string;
  };
  tag: {
    label: string;
    color: string;
    bgColor: string;
  };
  onPress: () => void;
}

// Styling
const postCardStyle = {
  padding: 20,
  borderRadius: 20,
  backgroundColor: '#FFFFFF',
  marginBottom: 16,
  shadowColor: '#000000',
  shadowOffset: { width: 0, height: 2 },
  shadowOpacity: 0.06,
  shadowRadius: 12,
  elevation: 3, // Android
};
```

### Bottom Navigation Bar
```typescript
interface NavItem {
  id: string;
  icon: LucideIcon;
  label: string;
  route: string;
}

// Styling
const navBarStyle = {
  position: 'absolute',
  bottom: 40,
  left: 20,
  right: 20,
  height: 72,
  backgroundColor: '#FFFFFF',
  borderRadius: 24,
  flexDirection: 'row',
  alignItems: 'center',
  justifyContent: 'space-around',
  paddingHorizontal: 16,
  shadowColor: '#000000',
  shadowOffset: { width: 0, height: -4 },
  shadowOpacity: 0.08,
  shadowRadius: 20,
  elevation: 8, // Android
};
```

### Floating Action Button (Message Icon)
```typescript
// Styling
const fabStyle = {
  position: 'absolute',
  top: 60,
  right: 20,
  width: 56,
  height: 56,
  borderRadius: 28,
  backgroundColor: '#FFFFFF',
  alignItems: 'center',
  justifyContent: 'center',
  shadowColor: '#6366F1',
  shadowOffset: { width: 0, height: 4 },
  shadowOpacity: 0.2,
  shadowRadius: 12,
  elevation: 6, // Android
};
```

---

## 5. Responsive Design Considerations

### Screen Breakpoints
- **Small**: 320px - 374px
- **Medium**: 375px - 413px (iPhone standard)
- **Large**: 414px+ (iPhone Plus, Android large)

### Scaling Rules
- **Padding**: Scale proportionally with screen width
- **Font Sizes**: Use rem/em units, scale with accessibility settings
- **Card Grid**: Maintain 2 columns, adjust gap
- **Bottom Nav**: Always 40px from bottom
- **Touch Targets**: Minimum 44px x 44px

### Safe Areas
- **iOS Top**: Account for status bar and notch
- **iOS Bottom**: Account for home indicator
- **Android**: Account for navigation bar

---

## 6. Accessibility

### Color Contrast
- **Text on White**: Minimum 4.5:1 contrast ratio
- **Interactive Elements**: Minimum 3:1 contrast ratio
- **Focus Indicators**: 3px solid outline, high contrast

### Touch Targets
- **Minimum Size**: 44px x 44px
- **Spacing**: 8px minimum between targets
- **Feedback**: Visual/haptic on press

### Screen Readers
- **Labels**: All interactive elements
- **Hints**: Describe action result
- **States**: Announce state changes

---

## 7. Implementation Notes

### React Native Components
- Use `ScrollView` for dashboard and campus connect
- Use `FlatList` for long lists (needs attention section)
- Use `Pressable` for all interactive elements
- Use `react-native-svg` for icons (Lucide React Native)

### State Management
- Use React Context for theme/navigation
- Use local state for UI interactions
- Use async storage for persistence

### Performance
- Memoize card components
- Lazy load images
- Use `useMemo` for computed styles
- Implement virtualization for long lists

### Testing
- Test all interactive states
- Verify accessibility
- Test on multiple screen sizes
- Test dark mode (future consideration)

---

## 8. Asset Requirements

### Icons
- **Icon Set**: Lucide React Native
- **Weight**: 1.5px stroke
- **Size**: 24px x 24px (default)
- **Color**: Inherit from parent

### Images
- **Profile Pictures**: 32px x 32px minimum
- **Post Icons**: 48px x 48px containers
- **Format**: WebP or PNG
- **Compression**: Optimize for mobile

### Fonts
- **Primary**: System default (San Francisco on iOS, Roboto on Android)
- **Alternative**: Inter (web font)
- **Weights**: 400, 500, 600, 700

---

## 9. Animation Specifications

### Card Press Animation
```typescript
const pressAnimation = {
  scale: 0.98,
  duration: 150,
  easing: 'ease-in-out',
};
```

### Navigation Transition
```typescript
const navTransition = {
  scale: 1.1,
  duration: 200,
  easing: 'ease-in-out',
};
```

### List Item Feedback
```typescript
const listFeedback = {
  backgroundColor: '#F9FAFB',
  duration: 100,
  easing: 'ease-out',
};
```

### FAB Interaction
```typescript
const fabHover = {
  scale: 1.05,
  shadowRadius: 16,
  duration: 200,
  easing: 'ease-out',
};

const fabPress = {
  scale: 0.95,
  duration: 100,
  easing: 'ease-in',
};
```

---

## 10. Platform-Specific Considerations

### iOS
- **Shadow**: Use iOS native shadow properties
- **Haptics**: Implement haptic feedback on interactions
- **Safe Area**: Use `SafeAreaView` from react-native-safe-area-context
- **Navigation**: Consider iOS navigation patterns

### Android
- **Elevation**: Use elevation for shadows (Material Design)
- **Ripple**: Implement ripple effect on press
- **Status Bar**: Adjust for varying status bar colors
- **Back Button**: Handle hardware back button

---

## Conclusion

This specification document provides comprehensive design details for implementing the AssignX mobile application. All measurements, colors, and spacing values are extracted from the reference images and can be used directly in implementation.

For any design decisions not explicitly covered here, follow the established patterns and maintain consistency with the documented specifications.
