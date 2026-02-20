# Gemini Execution Strategies for Complex Tasks

## Overview

This reference provides detailed strategies and templates for delegating complex, logic-intensive tasks to Gemini CLI. Use these patterns when facing persistent problems, intricate backend logic, or algorithms that require deep analysis.

> **Note**: While this document provides detailed strategies for manual Gemini invocation,
> Claude Code can automatically apply these patterns when delegating tasks. The skill
> handles context preparation, strategy selection, and execution automatically.

## Execution Mode Selection Matrix

| Task Characteristics      | Recommended Mode            | Key Commands                         |
| ------------------------- | --------------------------- | ------------------------------------ |
| Complex, needs iteration  | Interactive (`gemini`)      | `--model`                            |
| Well-defined, clear scope | One-Shot (`gemini "query"`) | `--yolo`                             |
| Continuing previous work  | Resume (`gemini --resume`)  | `--resume latest`, `--list-sessions` |

## Task Context Templates

### Template 1: Complex Backend Logic

```
I need to implement [feature/system] with the following requirements:

Architecture:
- [Database/framework/language]
- [Key services/modules involved]
- [External dependencies]

Requirements:
1. [Functional requirement 1]
2. [Functional requirement 2]
3. [Non-functional: performance, security, etc.]

Current state:
- [What exists now]
- [Why current approach insufficient]

Files involved:
- [file1]: [current state/problem]
- [file2]: [current state/problem]

Constraints:
- [Technical constraints]
- [Business constraints]
- [Performance requirements]

Goal: [Clear, measurable success criteria]
```

### Template 2: Persistent Bug

```
Bug: [One-line description]

Symptoms:
- [Observable behavior]
- [Frequency/conditions]
- [Impact/severity]

Environment:
- [Language/framework versions]
- [System specifications]
- [Relevant configuration]

Reproduction:
1. [Step to reproduce]
2. [Step to reproduce]
Expected: [What should happen]
Actual: [What happens instead]

Investigation done:
1. [What was checked]
2. [Hypotheses tested]
3. [Results/findings]

Previous fix attempts:
1. [Attempt 1] - [Why it failed]
2. [Attempt 2] - [Why it failed]

Stack trace/logs:
[Relevant error output]

Files involved:
- [file1]: [suspected involvement]
- [file2]: [suspected involvement]

Goal: [Root cause + permanent fix]
```

### Template 3: Algorithm Optimization

```
Algorithm: [Name/location]

Current implementation:
- Complexity: [Time/Space]
- Performance: [Current metrics]
- Location: [File path]

Problem:
- [Why current performance insufficient]
- [Specific bottlenecks identified]

Requirements:
- Target performance: [Metrics]
- Constraints: [Memory/CPU/real-time]
- Must maintain: [Accuracy/correctness requirements]

Profiling data:
[Relevant profiling information]

Optimization attempts:
1. [Approach 1] - [Result]
2. [Approach 2] - [Result]

Data characteristics:
- [Input size ranges]
- [Data distribution]
- [Edge cases]

Goal: [Performance target with constraints]
```

### Template 4: Race Condition / Concurrency

```
Concurrency issue in: [System/component]

Problem:
- [What goes wrong]
- [Under what concurrency conditions]
- [Frequency/reproducibility]

Architecture:
- [Concurrent components involved]
- [Synchronization mechanisms in use]
- [State management approach]

Current synchronization:
- [What's currently implemented]
- [Why it's insufficient]

Attempted fixes:
1. [Approach 1] - [Why it failed/made worse]
2. [Approach 2] - [Why it failed/made worse]

Traces/evidence:
[Race condition evidence, logs, timing diagrams]

Files:
- [file1]: [role in concurrency]
- [file2]: [role in concurrency]

Goal: [Correct synchronization without deadlocks]
```

## Command Patterns for Complex Tasks

### Pattern 1: Interactive Deep Dive

For problems requiring exploration and iteration:

```bash
cd /path/to/project

# Start interactive session
gemini --model gemini-2.5-pro

# In interactive mode, provide full context
# Then iterate:
# - Review changes
# - Switch models with --model if stuck

# If session gets long/confused, exit and resume fresh
# Save session ID for later resume if needed
```

**When to use:**

- Problem requires understanding codebase structure
- Solution approach unclear initially
- Need to iterate on partial solutions
- Want to review changes incrementally

### Pattern 2: Focused Execution

For well-understood problems needing specific solution:

```bash
# Single command with full context
gemini --model gemini-2.5-pro "Detailed problem description with:
- Full context
- Files involved
- Constraints
- Success criteria"

# Add --yolo if trusted and well-scoped
gemini --model gemini-2.5-pro --yolo "Well-defined task with clear scope"
```

**When to use:**

- Problem scope is clear
- Requirements are specific
- Don't need iterative refinement
- Want automated execution

### Pattern 3: Incremental Problem Solving

For problems that need to be broken down:

```bash
# Session 1: Analysis
gemini --model gemini-2.5-pro "Analyze [problem] and identify root cause"

# Review analysis results

# Session 2: Design
gemini --model gemini-2.5-pro --resume latest "Design solution for [root cause] with constraints [...]"

# Review design

# Session 3: Implementation
gemini --model gemini-2.5-pro --resume latest
# Provide design from previous session
# Implement interactively with iterations
```

**When to use:**

- Problem is very large
- Need to validate approach before implementation
- Want to review design before coding
- Problem has multiple phases

### Pattern 4: Enhanced Reasoning Mode

For extremely complex logical problems:

```bash
gemini --model gemini-3-pro-preview

# Then provide complex problem
# System will apply deeper analysis
```

**When to use:**

- Problem requires deep logical analysis
- Previous attempts with standard reasoning failed
- Algorithmic complexity is high
- Need to explore multiple approaches

## Advanced Workflow Patterns

### Workflow A: Persistent Bug Hunt

```bash
# Step 1: Initial diagnosis
gemini --model gemini-2.5-pro "Analyze this bug:
[Full bug description with reproduction]

Focus on:
1. Identifying reproduction pattern
2. Narrowing down to specific files/functions
3. Forming hypotheses about root cause"

# Step 2: Review diagnosis, then test hypotheses
gemini --model gemini-2.5-pro --resume latest "Test hypothesis: [specific hypothesis]
Add instrumentation/logging to verify in [files]"

# Step 3: Once root cause found, implement fix
gemini --model gemini-2.5-pro --resume latest
# Interactively implement fix

# Step 4: Validate fix
# Run tests, check edge cases

# Step 5: If bug persists, resume and pivot
gemini --model gemini-2.5-pro --resume latest
# Provide new evidence/findings
```

### Workflow B: Complex Feature Implementation

```bash
# Step 1: Architecture design
gemini --model gemini-2.5-pro "Design architecture for [feature] with:
Requirements: [...]
Constraints: [...]
Existing system: [...]

Output: High-level design with file structure"

# Step 2: Review design with team

# Step 3: Implement core logic
gemini --model gemini-2.5-pro --resume latest
# Interactive implementation of complex logic

# Step 4: Add edge cases and error handling
gemini --model gemini-2.5-pro --resume latest "Add comprehensive error handling to [files] covering:
[List edge cases and error scenarios]"

# Step 5: Optimize performance
gemini --model gemini-2.5-pro --resume latest "Profile and optimize [component]
Current: [metrics]
Target: [metrics]"
```

### Workflow C: Algorithm Optimization

```bash
# Step 1: Profile current implementation
# (Do profiling externally)

# Step 2: Analyze bottlenecks
gemini --model gemini-2.5-pro "Analyze algorithm in [file]:
Profiling shows: [bottleneck data]
Identify optimization opportunities"

# Step 3: Design optimization
gemini --model gemini-2.5-pro --resume latest
# Interactive design with Gemini

# Step 4: Implement and benchmark
# Implement optimization interactively
# Test performance after each change

# Step 5: If target not met, try alternative approach
gemini --model gemini-2.5-pro --resume latest
# "Previous optimization achieved [X], need [Y]
# Let's try [alternative approach]"
```

## Troubleshooting Delegation Patterns

### Issue: Gemini Doesn't Understand Problem

**Diagnosis:**

- Solution doesn't address root issue
- Implements wrong thing
- Misses key constraints

**Solutions:**

1. **Add concrete examples:**

```
Here's what the code does now:
[Concrete example with input/output]

Here's what it should do:
[Concrete example with desired input/output]
```

2. **Show what NOT to do:**

```
DO NOT:
- [Approach that won't work]
- [Anti-pattern to avoid]

Instead:
- [Preferred approach]
- [Pattern to follow]
```

3. **Reference existing code:**

```
Follow the pattern used in [file]:
[Show code snippet to emulate]

Apply this pattern to [problem]
```

### Issue: Solution Is Incomplete

**Diagnosis:**

- Missing edge cases
- Partial implementation
- Skipped error handling

**Solutions:**

1. **Resume and expand scope:**

```bash
gemini --model gemini-2.5-pro --resume latest
# "The solution works for [basic case] but needs:
# 1. Handle [edge case]
# 2. Add error handling for [scenario]
# 3. Cover [additional requirement]"
```

2. **Use interactive mode for iteration:**

```bash
gemini --model gemini-2.5-pro
# Provide problem, iterate on solution
```

### Issue: Solution Breaks Existing Code

**Diagnosis:**

- Tests fail
- Regressions introduced
- Integration issues

**Solutions:**

1. **Immediate rollback:**

```bash
# Revert git changes
git checkout [files]
```

2. **Resume with constraints:**

```bash
gemini --model gemini-2.5-pro --resume latest
# "Previous solution broke [tests/functionality]
# Must maintain compatibility with:
# - [Constraint 1]
# - [Constraint 2]
#
# Here are the failing tests:
# [Test output]"
```

3. **Incremental approach:**

```bash
# Make changes more incrementally
gemini --model gemini-2.5-pro
# "Implement [feature] but:
# 1. First show design without changing code
# 2. Then implement piece by piece"
```

## Best Practices by Problem Type

### Backend Logic

✅ **Do:**

- Provide database schema
- Specify transaction requirements
- Include security constraints
- Show data flow diagrams
- Reference similar patterns in codebase

❌ **Don't:**

- Leave edge cases unspecified
- Forget to mention scale requirements
- Skip error handling requirements

### Algorithms

✅ **Do:**

- Specify time/space complexity targets
- Provide data characteristics
- Include profiling data
- Show example inputs/outputs
- Mention correctness requirements

❌ **Don't:**

- Optimize prematurely (profile first)
- Ignore memory constraints
- Skip validation of correctness

### Concurrency/Race Conditions

✅ **Do:**

- Show timing diagrams
- Explain concurrent access patterns
- Provide reproduction rate
- Include lock/synchronization context
- Show thread/process architecture

❌ **Don't:**

- Omit concurrency level details
- Skip description of shared state
- Forget to mention deadlock concerns

### Persistent Bugs

✅ **Do:**

- Document reproduction steps
- Include all error messages/logs
- Show investigation work done
- List attempted fixes and why they failed
- Provide environment details

❌ **Don't:**

- Assume context without stating it
- Skip mentioning when bug occurs
- Leave out frequency/conditions

## Session Management Strategies

### When to Start New Session

- Previous session went down wrong path
- Need completely different approach
- Session conversation too long
- Want fresh perspective on problem

### When to Resume Session

- Building on previous analysis
- Refining partial solution
- Need context from earlier discussion
- Iterating on same problem

### Saving Session Context

```bash
# In long sessions, periodically summarize
# Then can start fresh with summary

# Example:
gemini --model gemini-2.5-pro "Previous session found:
1. [Key finding]
2. [Key finding]
3. [Remaining issues]

Now implement solution for [specific issue]"
```

## Command Quick Reference

```bash
# Interactive mode (most flexible)
cd /path/to/project
gemini --model gemini-2.5-pro

# One-shot mode (automation)
gemini --model gemini-2.5-pro "task description"
gemini --model gemini-2.5-pro --yolo "well-scoped task"

# Session management
gemini --model gemini-2.5-pro --resume latest       # Resume latest
gemini --model gemini-2.5-pro --resume <session-id> # Resume specific
gemini --list-sessions       # List sessions

# Flags
--model <name>   # Switch models
--yolo           # Auto-accept
```

## Success Checklist

After delegating to Gemini, verify:

- [ ] Problem is actually solved (not just partially)
- [ ] Solution handles edge cases
- [ ] Tests pass
- [ ] Performance meets requirements
- [ ] No regressions introduced
- [ ] Code follows project patterns
- [ ] Error handling is appropriate
- [ ] Documentation is updated (if needed)
- [ ] Solution can be maintained

If checklist not satisfied, resume session with specific feedback.
