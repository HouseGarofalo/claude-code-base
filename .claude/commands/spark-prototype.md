---
description: Quickly prototype an app idea using AI-powered app builders
---

# Spark Prototype

Create a rapid prototype using AI-powered app builders like GitHub Copilot Spark, v0, or similar tools.

## When to Use

Use this for:
- Quick proof-of-concept apps
- Visual prototypes to share ideas
- Exploring UI/UX approaches
- Learning by building

## Arguments

$ARGUMENTS

---

## Prototype Generation Process

### Step 1: Gather Requirements

Answer these questions:
- What is the app's main purpose?
- What are the 2-3 core features?
- Any styling preferences?

### Step 2: Generate Optimized Prompt

Create a focused prompt following this structure:

```
Create a [app type] that [primary function] with:
- [Feature 1]
- [Feature 2]
- [Feature 3]

Style: [design preferences]
```

### Step 3: Use the Prompt

**GitHub Copilot Spark**: spark.github.com
**Vercel v0**: v0.dev
**Similar tools**: bolt.new, lovable.dev

### Step 4: Iterate and Refine

- Review the generated code
- Request specific changes
- Add features incrementally

---

## Example Prompts

### Expense Tracker

```
Create a personal expense tracker app with:
- Add expenses with amount, category, and date
- View expenses in a list sorted by date
- Show total spending by category with a simple chart
- Filter expenses by date range

Style: Clean and minimal with a white background and green accents
```

### Task Manager

```
Create a task management app with:
- Add tasks with title, due date, and priority
- Mark tasks as complete
- Filter by priority (high/medium/low)
- Show overdue tasks highlighted in red

Style: Modern with a dark theme option
```

### Dashboard

```
Create a dashboard showing:
- Key metrics in card format at the top
- A line chart showing trends over time
- A data table with sorting and filtering
- Responsive layout for mobile

Style: Professional with blue and gray colors
```

---

## Tips for Better Results

| Tip | Why |
|-----|-----|
| Be specific | "Filter by date range" > "good filtering" |
| Limit features | 3-5 core features, not 20 |
| Describe style | "Minimal with green accents" > "nice looking" |
| Use examples | Reference known apps for style inspiration |

## Next Steps After Prototyping

1. **Export code** from the tool
2. **Review and refactor** for production
3. **Add proper error handling**
4. **Implement backend/data persistence**
5. **Add authentication if needed**

## Suggested Additions

After initial prototype works:
- User authentication
- Data persistence
- Export functionality
- Settings/preferences
- Mobile responsiveness
