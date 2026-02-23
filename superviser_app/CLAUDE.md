# Claude Code Guidelines - Superviser App (Mobile)

## MCP Tools Usage

### Web Search & Documentation
- For any web search or library documentation, **always use Context7 MCP** (`mcp__context7__resolve-library-id` and `mcp__context7__get-library-docs`)
- Use **WebSearch** tool for current events, recent updates, or information beyond knowledge cutoff

### Database Operations
- For **all database operations** (setup, queries, schema, tables info), **always use Supabase MCP**
- This includes:
  - Setting up tables/schemas
  - Querying data
  - Understanding table structures
  - Database migrations

### Code Search
- To search the codebase for files or code, **use claude-context MCP** (`mcp__claude-context__search_code`)
- Index the codebase first if needed (`mcp__claude-context__index_codebase`)

## Mobile App Development Rules

### Component Architecture
- **Always create reusable components** - break UI into small, modular pieces
- Follow component-based architecture strictly
- Keep components single-responsibility

### Documentation
- **Write JSDoc comments** for all functions, components, and complex logic
- Document props, return types, and component purpose

### Skills Usage
- For frontend/UI designing, **always use frontend skills** available
- Leverage mobile UI/UX best practices from skills

## Workflow Rules

### Before Implementation
- **Run `/brainstorm` (superpowers)** before starting any feature
- Ask clarifying questions to understand requirements
- Create a detailed plan specifying:
  - Which files/folders to edit
  - What changes to make where
  - Component structure
  - Data flow

### During Implementation
- Follow the plan created during brainstorm
- Keep changes focused and minimal
- Test as you go

### After Each Feature
1. **Commit immediately** after feature is implemented
2. **Document what was done** - update relevant docs/changelog
3. Then move to the next feature

## Code Quality
- Write clean, readable code
- Follow existing project conventions
- No over-engineering - keep it simple
- Handle errors appropriately at boundaries
