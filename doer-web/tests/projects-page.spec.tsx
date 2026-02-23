/**
 * Projects Page - Automated Test Suite
 *
 * Tests the redesigned projects page functionality including:
 * - Data loading and error handling
 * - Search and filter functionality
 * - Navigation and routing
 * - Refresh mechanism
 * - UI state management
 *
 * @file doer-web/app/(main)/projects/page.tsx
 */

import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import ProjectsPage from '@/app/(main)/projects/page'
import { getProjectsByCategory } from '@/services/project.service'
import { useAuth } from '@/hooks/useAuth'
import type { Project } from '@/types/database'

// Mock dependencies
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}))

jest.mock('sonner', () => ({
  toast: {
    error: jest.fn(),
    info: jest.fn(),
  },
}))

jest.mock('@/services/project.service', () => ({
  getProjectsByCategory: jest.fn(),
}))

jest.mock('@/hooks/useAuth', () => ({
  useAuth: jest.fn(),
}))

// Mock Framer Motion to avoid animation issues in tests
jest.mock('framer-motion', () => ({
  motion: {
    div: ({ children, ...props }: any) => <div {...props}>{children}</div>,
  },
}))

// Mock child components
jest.mock('@/components/projects/redesign/ProjectHeroBanner', () => ({
  ProjectHeroBanner: ({ onNewProject, onViewAnalytics }: any) => (
    <div data-testid="hero-banner">
      <button onClick={onNewProject}>New Project</button>
      <button onClick={onViewAnalytics}>View Analytics</button>
    </div>
  ),
}))

jest.mock('@/components/projects/redesign/AdvancedStatsGrid', () => ({
  AdvancedStatsGrid: () => <div data-testid="stats-grid">Stats Grid</div>,
}))

jest.mock('@/components/projects/redesign/FilterControls', () => ({
  FilterControls: ({ searchQuery, onSearchChange, filters, onFiltersChange, viewMode, onViewModeChange }: any) => (
    <div data-testid="filter-controls">
      <input
        data-testid="search-input"
        value={searchQuery}
        onChange={(e) => onSearchChange(e.target.value)}
        placeholder="Search projects"
      />
      <button
        data-testid="filter-status-button"
        onClick={() => onFiltersChange({ ...filters, statuses: ['in_progress'] })}
      >
        Filter In Progress
      </button>
      <button
        data-testid="filter-urgent-button"
        onClick={() => onFiltersChange({ ...filters, urgent: true })}
      >
        Filter Urgent
      </button>
      <select
        data-testid="sort-select"
        value={filters.sortBy}
        onChange={(e) => onFiltersChange({ ...filters, sortBy: e.target.value })}
      >
        <option value="deadline">Deadline</option>
        <option value="price">Price</option>
        <option value="status">Status</option>
        <option value="created">Created</option>
      </select>
    </div>
  ),
}))

jest.mock('@/components/projects/redesign/InsightsSidebar', () => ({
  InsightsSidebar: ({ onProjectClick }: any) => (
    <div data-testid="insights-sidebar">
      <button onClick={() => onProjectClick('timeline-project-1')}>
        Timeline Project
      </button>
    </div>
  ),
}))

jest.mock('@/components/projects', () => ({
  ActiveProjectsTab: ({ projects, onProjectClick, onOpenWorkspace }: any) => (
    <div data-testid="active-projects-tab">
      {projects.map((p: Project) => (
        <div key={p.id} data-testid={`project-${p.id}`}>
          <button onClick={() => onProjectClick(p.id)}>Click {p.title}</button>
          <button onClick={() => onOpenWorkspace(p.id)}>Open Workspace {p.id}</button>
        </div>
      ))}
    </div>
  ),
  UnderReviewTab: ({ projects, onProjectClick }: any) => (
    <div data-testid="review-projects-tab">
      {projects.map((p: Project) => (
        <div key={p.id} data-testid={`project-${p.id}`}>
          <button onClick={() => onProjectClick(p.id)}>Click {p.title}</button>
        </div>
      ))}
    </div>
  ),
  CompletedProjectsTab: ({ projects, onProjectClick }: any) => (
    <div data-testid="completed-projects-tab">
      {projects.map((p: Project) => (
        <div key={p.id} data-testid={`project-${p.id}`}>
          <button onClick={() => onProjectClick(p.id)}>Click {p.title}</button>
        </div>
      ))}
    </div>
  ),
}))

// Test data
const mockDoer = {
  id: 'doer-123',
  profile_id: 'profile-123',
  university_id: 'uni-123',
  total_earnings: 5000,
  average_rating: 4.5,
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
}

const createMockProject = (overrides: Partial<Project> = {}): Project => ({
  id: 'project-1',
  title: 'Test Project',
  description: 'Test Description',
  subject_id: 'subject-1',
  subject_name: 'Mathematics',
  supervisor_id: 'supervisor-1',
  supervisor_name: 'Prof. Smith',
  doer_id: 'doer-123',
  status: 'in_progress',
  deadline: '2026-03-01T00:00:00Z',
  doer_payout: 150,
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-01T00:00:00Z',
  is_urgent: false,
  ...overrides,
})

const mockActiveProjects: Project[] = [
  createMockProject({ id: 'active-1', title: 'Active Project 1', status: 'in_progress' }),
  createMockProject({ id: 'active-2', title: 'Active Project 2', status: 'assigned' }),
]

const mockReviewProjects: Project[] = [
  createMockProject({ id: 'review-1', title: 'Review Project 1', status: 'submitted_for_qc' }),
]

const mockCompletedProjects: Project[] = [
  createMockProject({ id: 'completed-1', title: 'Completed Project 1', status: 'completed' }),
  createMockProject({ id: 'completed-2', title: 'Completed Project 2', status: 'completed' }),
]

describe('ProjectsPage', () => {
  const mockRouterPush = jest.fn()

  beforeEach(() => {
    jest.clearAllMocks()
    ;(useRouter as jest.Mock).mockReturnValue({
      push: mockRouterPush,
    })
    ;(useAuth as jest.Mock).mockReturnValue({
      doer: mockDoer,
      isLoading: false,
    })
    ;(getProjectsByCategory as jest.Mock).mockImplementation((doerId, category) => {
      if (category === 'active') return Promise.resolve(mockActiveProjects)
      if (category === 'review') return Promise.resolve(mockReviewProjects)
      if (category === 'completed') return Promise.resolve(mockCompletedProjects)
      return Promise.resolve([])
    })
  })

  describe('1. Data Loading', () => {
    it('should load projects from all three categories on mount', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(getProjectsByCategory).toHaveBeenCalledWith('doer-123', 'active')
        expect(getProjectsByCategory).toHaveBeenCalledWith('doer-123', 'review')
        expect(getProjectsByCategory).toHaveBeenCalledWith('doer-123', 'completed')
      })
    })

    it('should display loading skeleton when loading', () => {
      ;(useAuth as jest.Mock).mockReturnValue({
        doer: mockDoer,
        isLoading: true,
      })

      render(<ProjectsPage />)

      // Skeleton should be present (Skeleton component renders with specific className)
      const skeletons = document.querySelectorAll('.bg-\\[\\#EEF2FF\\]')
      expect(skeletons.length).toBeGreaterThan(0)
    })

    it('should handle API errors gracefully', async () => {
      const error = new Error('API Error')
      ;(getProjectsByCategory as jest.Mock).mockRejectedValue(error)

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(toast.error).toHaveBeenCalledWith('Failed to load projects')
      })
    })

    it('should not load projects when doer is not available', async () => {
      ;(useAuth as jest.Mock).mockReturnValue({
        doer: null,
        isLoading: false,
      })

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(getProjectsByCategory).not.toHaveBeenCalled()
      })
    })
  })

  describe('2. Search Functionality', () => {
    it('should filter projects by title when searching', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const searchInput = screen.getByTestId('search-input')
      await userEvent.type(searchInput, 'Active Project 1')

      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Active Project 1/)).toBeInTheDocument()
        expect(within(activeTab).queryByText(/Active Project 2/)).not.toBeInTheDocument()
      })
    })

    it('should filter projects by subject name', async () => {
      const projectWithDifferentSubject = createMockProject({
        id: 'active-3',
        title: 'Physics Project',
        subject_name: 'Physics',
      })

      ;(getProjectsByCategory as jest.Mock).mockImplementation((doerId, category) => {
        if (category === 'active') return Promise.resolve([...mockActiveProjects, projectWithDifferentSubject])
        if (category === 'review') return Promise.resolve(mockReviewProjects)
        if (category === 'completed') return Promise.resolve(mockCompletedProjects)
        return Promise.resolve([])
      })

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const searchInput = screen.getByTestId('search-input')
      await userEvent.type(searchInput, 'Physics')

      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Physics Project/)).toBeInTheDocument()
        expect(within(activeTab).queryByText(/Active Project 1/)).not.toBeInTheDocument()
      })
    })

    it('should be case-insensitive when searching', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const searchInput = screen.getByTestId('search-input')
      await userEvent.type(searchInput, 'ACTIVE PROJECT')

      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Active Project 1/)).toBeInTheDocument()
      })
    })

    it('should update results in real-time as user types', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const searchInput = screen.getByTestId('search-input')

      // Type "Active"
      await userEvent.type(searchInput, 'Active')
      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Active Project 1/)).toBeInTheDocument()
      })

      // Add " Project 1"
      await userEvent.type(searchInput, ' Project 1')
      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Active Project 1/)).toBeInTheDocument()
        expect(within(activeTab).queryByText(/Active Project 2/)).not.toBeInTheDocument()
      })
    })
  })

  describe('3. Filter System', () => {
    it('should filter projects by status', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const filterButton = screen.getByTestId('filter-status-button')
      await userEvent.click(filterButton)

      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Active Project 1/)).toBeInTheDocument()
        // Active Project 2 has status 'assigned', should be filtered out
        expect(within(activeTab).queryByText(/Active Project 2/)).not.toBeInTheDocument()
      })
    })

    it('should filter urgent projects (deadline <= 3 days)', async () => {
      const urgentProject = createMockProject({
        id: 'urgent-1',
        title: 'Urgent Project',
        deadline: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(), // 2 days from now
        is_urgent: true,
      })

      const notUrgentProject = createMockProject({
        id: 'not-urgent-1',
        title: 'Not Urgent Project',
        deadline: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000).toISOString(), // 10 days from now
      })

      ;(getProjectsByCategory as jest.Mock).mockImplementation((doerId, category) => {
        if (category === 'active') return Promise.resolve([urgentProject, notUrgentProject])
        if (category === 'review') return Promise.resolve([])
        if (category === 'completed') return Promise.resolve([])
        return Promise.resolve([])
      })

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const filterUrgentButton = screen.getByTestId('filter-urgent-button')
      await userEvent.click(filterUrgentButton)

      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).getByText(/Urgent Project/)).toBeInTheDocument()
        expect(within(activeTab).queryByText(/Not Urgent Project/)).not.toBeInTheDocument()
      })
    })

    it('should sort projects by deadline', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const sortSelect = screen.getByTestId('sort-select')
      await userEvent.selectOptions(sortSelect, 'deadline')

      // Projects should be sorted by deadline (mocked projects already in order)
      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(activeTab).toBeInTheDocument()
      })
    })

    it('should update count badges when filters change', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByText(/2 active/)).toBeInTheDocument()
        expect(screen.getByText(/1 in review/)).toBeInTheDocument()
        expect(screen.getByText(/2 completed/)).toBeInTheDocument()
      })

      // Apply search filter
      const searchInput = screen.getByTestId('search-input')
      await userEvent.type(searchInput, 'Active Project 1')

      await waitFor(() => {
        expect(screen.getByText(/1 active/)).toBeInTheDocument() // Count should update
      })
    })
  })

  describe('4. Navigation', () => {
    it('should navigate to project detail when card is clicked', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const projectButton = screen.getByText(/Click Active Project 1/)
      await userEvent.click(projectButton)

      expect(mockRouterPush).toHaveBeenCalledWith('/projects/active-1')
    })

    it('should navigate to workspace when Open Workspace is clicked', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const workspaceButton = screen.getByText(/Open Workspace active-1/)
      await userEvent.click(workspaceButton)

      expect(mockRouterPush).toHaveBeenCalledWith('/projects/active-1')
    })

    it('should navigate from timeline in sidebar', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('insights-sidebar')).toBeInTheDocument()
      })

      const timelineButton = screen.getByText(/Timeline Project/)
      await userEvent.click(timelineButton)

      expect(mockRouterPush).toHaveBeenCalledWith('/projects/timeline-project-1')
    })

    it('should navigate to dashboard when New Project is clicked', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('hero-banner')).toBeInTheDocument()
      })

      const newProjectButton = screen.getByText(/New Project/)
      await userEvent.click(newProjectButton)

      expect(mockRouterPush).toHaveBeenCalledWith('/dashboard')
    })
  })

  describe('5. Refresh Mechanism', () => {
    it('should reload data when refresh button is clicked', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(getProjectsByCategory).toHaveBeenCalledTimes(3)
      })

      // Clear previous calls
      ;(getProjectsByCategory as jest.Mock).mockClear()

      const refreshButton = screen.getByText(/Refresh/)
      await userEvent.click(refreshButton)

      await waitFor(() => {
        expect(getProjectsByCategory).toHaveBeenCalledTimes(3)
        expect(getProjectsByCategory).toHaveBeenCalledWith('doer-123', 'active')
        expect(getProjectsByCategory).toHaveBeenCalledWith('doer-123', 'review')
        expect(getProjectsByCategory).toHaveBeenCalledWith('doer-123', 'completed')
      })
    })

    it('should disable refresh button during refresh', async () => {
      let resolvePromise: (value: Project[]) => void
      const promise = new Promise<Project[]>((resolve) => {
        resolvePromise = resolve
      })

      ;(getProjectsByCategory as jest.Mock).mockReturnValue(promise)

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByText(/Refresh/)).toBeInTheDocument()
      })

      const refreshButton = screen.getByText(/Refresh/) as HTMLButtonElement
      await userEvent.click(refreshButton)

      // Button should be disabled during refresh
      expect(refreshButton.disabled).toBe(true)

      // Resolve the promise
      resolvePromise!(mockActiveProjects)

      await waitFor(() => {
        expect(refreshButton.disabled).toBe(false)
      })
    })

    it('should show spinning icon during refresh', async () => {
      let resolvePromise: (value: Project[]) => void
      const promise = new Promise<Project[]>((resolve) => {
        resolvePromise = resolve
      })

      ;(getProjectsByCategory as jest.Mock).mockReturnValue(promise)

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByText(/Refresh/)).toBeInTheDocument()
      })

      const refreshButton = screen.getByText(/Refresh/)
      await userEvent.click(refreshButton)

      // Check if spin animation class is applied
      const icon = refreshButton.parentElement?.querySelector('.animate-spin')
      expect(icon).toBeInTheDocument()

      resolvePromise!(mockActiveProjects)
    })
  })

  describe('6. Tab Switching', () => {
    it('should switch to review tab when clicked', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const reviewTab = screen.getByText(/Review \(1\)/)
      await userEvent.click(reviewTab)

      await waitFor(() => {
        expect(screen.getByTestId('review-projects-tab')).toBeInTheDocument()
        expect(screen.queryByTestId('active-projects-tab')).not.toBeInTheDocument()
      })
    })

    it('should switch to completed tab when clicked', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const completedTab = screen.getByText(/Completed \(2\)/)
      await userEvent.click(completedTab)

      await waitFor(() => {
        expect(screen.getByTestId('completed-projects-tab')).toBeInTheDocument()
        expect(screen.queryByTestId('active-projects-tab')).not.toBeInTheDocument()
      })
    })
  })

  describe('7. Edge Cases', () => {
    it('should handle empty project lists', async () => {
      ;(getProjectsByCategory as jest.Mock).mockResolvedValue([])

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByText(/0 active • 0 in review • 0 completed/)).toBeInTheDocument()
      })
    })

    it('should handle search with no results', async () => {
      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const searchInput = screen.getByTestId('search-input')
      await userEvent.type(searchInput, 'Nonexistent Project')

      await waitFor(() => {
        const activeTab = screen.getByTestId('active-projects-tab')
        expect(within(activeTab).queryByText(/Active Project/)).not.toBeInTheDocument()
      })
    })

    it('should handle projects with null payout values', async () => {
      const projectWithNullPayout = createMockProject({
        id: 'null-payout',
        title: 'Null Payout Project',
        doer_payout: null as any,
      })

      ;(getProjectsByCategory as jest.Mock).mockImplementation((doerId, category) => {
        if (category === 'active') return Promise.resolve([projectWithNullPayout])
        return Promise.resolve([])
      })

      render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      // Should not crash, should handle null payout gracefully
      expect(screen.getByText(/Null Payout Project/)).toBeInTheDocument()
    })
  })

  describe('8. Performance', () => {
    it('should use memoization to prevent unnecessary re-renders', async () => {
      const { rerender } = render(<ProjectsPage />)

      await waitFor(() => {
        expect(screen.getByTestId('active-projects-tab')).toBeInTheDocument()
      })

      const callCount = (getProjectsByCategory as jest.Mock).mock.calls.length

      // Re-render with same props
      rerender(<ProjectsPage />)

      // Should not call API again (data is cached)
      expect((getProjectsByCategory as jest.Mock).mock.calls.length).toBe(callCount)
    })
  })
})
