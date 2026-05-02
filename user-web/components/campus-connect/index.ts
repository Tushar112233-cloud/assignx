// Campus Connect Components
// Pinterest-inspired community platform for verified college students

// Core Components
export { PostCard } from "./post-card";
export { CampusConnectMasonryGrid } from "./masonry-grid";

// Hero Components (Campus Pulse)
export { CampusPulseHero } from "./campus-pulse-hero";
export { LiveActivityFeed } from "./live-activity-feed";
export { ActivityGlobe } from "./activity-globe";
export { LiveStatsBadge } from "./live-stats-badge";

// Filter Components
export { CategoryFilter, CategoryFilterScrollable } from "./category-filter";
export { CollegeFilter, CollegeFilterCompact } from "./college-filter";

// Internal Filters (Housing, Events, Resources)
export {
  HousingFiltersPanel,
  defaultHousingFilters,
  type HousingFilters,
} from "./housing-filters";
export {
  EventFiltersPanel,
  defaultEventFilters,
  type EventFilters,
} from "./event-filters";
export {
  ResourceFiltersPanel,
  defaultResourceFilters,
  type ResourceFilters,
} from "./resource-filters";
export {
  FilterSheet,
  ActiveFiltersBar,
  defaultCampusConnectFilters,
  type CampusConnectFilters,
} from "./filter-sheet";

// Interaction Components
export { LikeButton, LikeButtonOutline } from "./like-button";
export { SaveButton, SaveButtonOutline } from "./save-button";
export { CommentSection } from "./comment-section";
export { ReportButton, ReportButtonOutline } from "./report-button";
export { ReportDialog } from "./report-dialog";
export { SavedListings } from "./saved-listings";

// Page Components
export { CampusConnectPage } from "./campus-connect-page";
export { CreatePostForm } from "./create-post-form";
export { PostDetailView } from "./post-detail-view";
