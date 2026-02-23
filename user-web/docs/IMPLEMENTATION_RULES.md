# Implementation Rules & Workflow

## CRITICAL: These rules MUST be followed for every change

---

## 1. Change Selection
- Always refer to `DASHBOARD_CHANGES.md` for the list of changes
- When user requests a change, locate it in the changes document
- Understand the full scope before starting implementation
- Ask clarifying questions if requirements are unclear

---

## 2. Before Implementation
- Read all relevant files that will be affected
- Understand the current implementation
- Plan the changes clearly
- Identify potential side effects or breaking changes
- Ensure you have all necessary information/screenshots/mockups

---

## 3. During Implementation
- Make focused, minimal changes
- Follow existing code patterns and conventions
- Write clean, readable code
- Add JSDoc comments for new functions/components
- Maintain component reusability
- Follow the project's architecture rules from `CLAUDE.md`
- **NEVER save files to root folder** - use appropriate subdirectories

---

## 4. After Implementation - QUALITY ASSURANCE (MANDATORY)

### Step 4.1: Deep Quality Check
Perform a comprehensive quality assurance check:

#### A. Code Quality
- [ ] Code follows existing patterns
- [ ] No syntax errors
- [ ] No TypeScript errors
- [ ] Proper imports and exports
- [ ] No unused variables or imports
- [ ] Clean, readable code structure
- [ ] JSDoc comments added where needed

#### B. Functionality Check
- [ ] Change implemented as specified
- [ ] No breaking changes to existing features
- [ ] All interactive elements work correctly
- [ ] Forms validate properly (if applicable)
- [ ] Data flows correctly

#### C. Visual Check
- [ ] Layout matches requirements/screenshot
- [ ] Responsive on all screen sizes (mobile, tablet, desktop)
- [ ] Animations work smoothly
- [ ] No visual glitches or overflow issues
- [ ] Proper spacing and alignment
- [ ] Colors match design specifications

#### D. Performance Check
- [ ] No console errors
- [ ] No console warnings
- [ ] Page loads quickly
- [ ] Animations are performant (60fps)
- [ ] No memory leaks
- [ ] Smooth scrolling behavior

#### E. Accessibility Check
- [ ] Proper semantic HTML
- [ ] Keyboard navigation works
- [ ] Proper ARIA labels (if needed)
- [ ] Sufficient color contrast

### Step 4.2: Testing
- Test the implementation thoroughly
- Check all edge cases
- Test on different screen sizes
- Verify no regressions in other areas

### Step 4.3: Verify Against Requirements
- Compare implementation with the change description in `DASHBOARD_CHANGES.md`
- Ensure ALL requirements are met
- Check if "Expected Outcome" is achieved
- Verify against any provided screenshots or mockups

---

## 5. Only If QA Passes - Commit

### Commit Rules
- **ONLY commit if quality assurance passes completely**
- **If ANY issue is found, fix it before committing**
- Never commit incomplete work
- Never commit broken functionality

### Commit Message Format
```
<type>: <change-description>

- Detailed change 1
- Detailed change 2

Refs: DASHBOARD_CHANGES.md #<change-number>
```

### Commit Types
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring
- `style` - Styling changes
- `perf` - Performance improvements
- `docs` - Documentation

### Example Commit Message
```
feat: complete dashboard screen and fix abrupt cutoff

- Added proper container height management
- Fixed viewport scrolling behavior
- Ensured all sections are visible
- Added smooth scroll to bottom sections

Refs: DASHBOARD_CHANGES.md #1
```

---

## 6. After Commit - User Confirmation

### Mandatory Workflow
1. Inform user that the change is complete and committed
2. Provide a summary of what was implemented
3. Mention the commit message
4. **ASK THE USER**: "Should I start with the next change?"
5. **WAIT** for user response
6. Do NOT proceed to the next change without explicit user approval

### Response Template
```
✅ Change #X completed and committed!

Summary:
- [What was implemented]
- [Key changes made]
- [Files modified]

Commit: [commit message]

Should I start with the next change?
```

---

## 7. Update Change Status

After committing, update the status in `DASHBOARD_CHANGES.md`:
- Change status from "Pending" to "Completed"
- Add completion date
- Add commit reference
- Update any relevant notes

---

## 8. Error Handling

If errors occur during QA:
1. **DO NOT commit**
2. Fix all errors immediately
3. Re-run quality assurance
4. Only commit when everything passes
5. If unable to fix, inform user and ask for guidance

---

## 9. User Feedback Loop

If user reports issues after completion:
1. Acknowledge the issue
2. Investigate thoroughly
3. Fix the problem
4. Re-run quality assurance
5. Create a new commit with the fix
6. Inform user of the resolution

---

## 10. Documentation Updates

After each change:
- Update `DASHBOARD_CHANGES.md` status
- Document any important decisions made
- Note any deviations from original plan
- Add any learnings or gotchas

---

## Summary Workflow Checklist

- [ ] 1. Refer to `DASHBOARD_CHANGES.md`
- [ ] 2. Read all relevant files
- [ ] 3. Implement the change
- [ ] 4. Perform deep quality assurance (ALL checks)
- [ ] 5. Fix any issues found
- [ ] 6. Verify against requirements
- [ ] 7. Commit ONLY if everything passes
- [ ] 8. Update change status in `DASHBOARD_CHANGES.md`
- [ ] 9. Inform user with summary
- [ ] 10. Ask: "Should I start with the next change?"
- [ ] 11. WAIT for user approval
- [ ] 12. Proceed only after user confirmation

---

## CRITICAL REMINDERS

🚨 **NEVER commit without complete quality assurance**
🚨 **NEVER proceed to next change without user approval**
🚨 **ALWAYS refer to DASHBOARD_CHANGES.md for change details**
🚨 **ALWAYS ask "Should I start with the next change?" after commit**
🚨 **ALWAYS wait for user response before proceeding**

---

**These rules are MANDATORY and must be followed for EVERY change.**
