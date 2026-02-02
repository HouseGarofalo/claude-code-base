[Home](../../README.md) > [Docs](../index.md) > Spark Workflow

# Claude Spark Workflow Guide

> **Last Updated**: 2026-02-02
> **Purpose**: Complete guide for rapid prototyping and teaching with AI assistance

---

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Prototyping Workflow](#prototyping-workflow)
- [Teaching Workflow](#teaching-workflow)
- [From Prototype to Production](#from-prototype-to-production)
- [Best Practices](#best-practices)
- [Quick Reference](#quick-reference)

---

## Overview

Rapid prototyping with Claude Code enables quick transformation of natural language descriptions into working code. This is ideal for:

| Use Case | Description |
|----------|-------------|
| **Rapid Prototyping** | Quickly test ideas before committing to full implementation |
| **Teaching** | Demonstrate programming concepts interactively |
| **Client Demos** | Create impressive mockups for presentations |
| **Exploration** | Try different approaches quickly |

### When to Use Rapid Prototyping

Use rapid prototyping when:
- Quick prototype needed
- Learning a new concept
- Client demo required
- Exploring UI approaches

Use traditional development when:
- Production code required
- Complex backend logic
- Team collaboration needed
- Performance critical

---

## Getting Started

### Quick Start

1. **Open Claude Code** in your terminal or IDE
2. **Describe your app** clearly:
   ```
   Create a simple todo list app with:
   - Add new tasks
   - Mark tasks as complete
   - Delete tasks
   ```
3. **Review** the generated code
4. **Iterate** by adding more features

---

## Prototyping Workflow

### Step 1: Define Your Goal

Before starting, clarify:
- What problem does this solve?
- Who is the target user?
- What are the 3 most important features?

### Step 2: Craft Your Prompt

Use this structure for best results:

```
Create a [app type] that [primary function] with:
- [Feature 1]
- [Feature 2]
- [Feature 3]

Style: [design preferences]
Tech: [preferred framework/library]
```

**Example:**
```
Create a personal expense tracker app with:
- Add expenses with amount and category
- View expenses by date
- Show spending summary with charts

Style: Clean and minimal with blue accents
Tech: React with TypeScript
```

### Step 3: Iterate

After initial generation:

| Action | Example Prompt |
|--------|---------------|
| Add feature | "Add a dark mode toggle" |
| Change style | "Make the buttons more rounded with shadows" |
| Fix behavior | "The form should clear after submitting" |
| Refine UI | "Use a card layout for expenses" |

### Step 4: Export and Refine

When satisfied:
1. Review generated code
2. Add proper error handling
3. Add TypeScript types
4. Add tests
5. Integrate into project

---

## Teaching Workflow

Claude Code is an excellent teaching tool. Here's how to use it:

### Teaching Approach

1. **Identify Concept** - What to teach
2. **Build Example** - Generate working code
3. **Walk Through** - Explain the code
4. **Modify Together** - Make changes
5. **Practice Exercise** - Independent work

### Example: Teaching React useState

**Step 1: Create Example**
```
Create a simple counter app that demonstrates React useState:
- A number display starting at 0
- Increment and Decrement buttons
- A Reset button

Add comments explaining what useState does.
```

**Step 2: Explain Key Points**
```typescript
// useState returns two things:
const [count, setCount] = useState(0);
//     ^         ^              ^
//   value    updater    initial value
```

**Step 3: Practice Exercises**
1. Add a button that increments by 5
2. Add a maximum limit
3. Show the previous value

### Concepts to Teach

| Concept | Example App |
|---------|-------------|
| useState | Counter, Toggle switch |
| useEffect | Clock, Data fetcher |
| Props | Customizable card component |
| Events | Interactive button |
| Forms | Simple input with validation |
| Lists | Todo list, shopping cart |

---

## From Prototype to Production

### The Bridge Process

1. **Prototype** - Generate initial code
2. **Export** - Save to project
3. **Review & Assess** - Understand the code
4. **Add TypeScript** - Proper types
5. **Add Error Handling** - Try/catch, boundaries
6. **Add Tests** - Unit and integration
7. **Apply Conventions** - Project patterns
8. **Code Review** - Team review
9. **Production Ready** - Deploy

### Production Checklist

When moving prototype code to production:

- [ ] **TypeScript**: Add proper types and interfaces
- [ ] **Error Handling**: Add try/catch, error boundaries
- [ ] **Loading States**: Add spinners, skeletons
- [ ] **Edge Cases**: Handle empty states, errors
- [ ] **Accessibility**: Add ARIA labels, keyboard nav
- [ ] **Tests**: Unit tests, integration tests
- [ ] **Documentation**: Add JSDoc comments
- [ ] **Security**: Input validation, XSS prevention
- [ ] **Performance**: Memoization, lazy loading

### Integration Example

```bash
# 1. Generate prototype code with Claude

# 2. Create feature branch
git checkout -b feature/expense-tracker

# 3. Copy relevant components
mkdir src/components/expense-tracker
# Move generated code

# 4. Refactor for production
# - Add TypeScript
# - Apply project styling
# - Add tests

# 5. Create PR with context
gh pr create --title "feat: Add expense tracker from prototype" \
  --body "Based on Claude-generated prototype."
```

---

## Best Practices

### Effective Prompts

| DO | DON'T |
|-------|----------|
| Be specific about features | Use vague descriptions |
| Mention styling preferences | Expect perfect styling |
| Start simple, then iterate | Try to build everything at once |
| Reference known patterns | Assume complex backend support |

### Iteration Tips

1. **Save working versions** before major changes
2. **Add one feature at a time** for better control
3. **Be explicit** about what you want changed
4. **Reference the existing UI** when making modifications

### Common Mistakes

| Mistake | Solution |
|---------|----------|
| Too many features at once | Break into smaller requests |
| Expecting production code | Plan for refactoring |
| No iteration | Review and refine |
| Skipping review | Always understand generated code |

---

## Quick Reference

### Prompt Templates

**New App:**
```
Create a [type] app that [purpose] with:
- [Feature 1]
- [Feature 2]
Style: [preferences]
Tech: [framework]
```

**Add Feature:**
```
Add [feature] that [behavior] when [trigger]
```

**Modify Style:**
```
Change [element] to [new style]
```

**Fix Behavior:**
```
Fix: [current behavior]
Should: [expected behavior]
```

### Available Claude Code Commands

| Tool | Purpose | Invocation |
|------|---------|------------|
| Prototype Command | Quick prototype | `/spark-prototype` |
| Teach Command | Teaching mode | `/spark-teach` |

---

## Related Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [React TypeScript Skill](../../.claude/skills/react-typescript/SKILL.md)
- [Testing Skill](../../.claude/skills/testing/SKILL.md)
