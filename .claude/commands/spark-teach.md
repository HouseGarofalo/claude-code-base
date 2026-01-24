---
description: Use AI tools to teach programming concepts interactively
---

# Spark Teach

Use AI-powered tools to demonstrate programming concepts through working examples.

## When to Use

Use this to:
- Explain programming concepts visually
- Create interactive learning examples
- Demonstrate code patterns in action
- Help learners understand by doing

## Arguments

$ARGUMENTS

---

## Teaching Process

### Step 1: Identify the Concept

- What programming concept?
- What's the learner's experience level?
- Any specific technology focus (React, JavaScript, CSS)?

### Step 2: Create a Teaching Prompt

Design a simple, focused example:

```
Create a simple example of [concept] that:
- Shows [specific behavior]
- Is minimal and focused
- Has clear, commented code

Keep it simple - the goal is to teach [concept], not build a full app.
```

### Step 3: Prepare Explanation Points

List 3-5 key things to point out in the generated code.

### Step 4: Suggest Exercises

Provide 2-3 modifications the learner can try.

---

## Teaching by Experience Level

### For Beginners
- Use very simple examples
- Focus on ONE concept at a time
- Explain every part of the code
- Use familiar analogies

### For Intermediate Learners
- Show practical applications
- Compare different approaches
- Discuss trade-offs
- Connect to real-world patterns

### For Advanced Learners
- Explore edge cases
- Discuss performance implications
- Show production considerations
- Challenge with extensions

---

## Example: Teaching React useState

### Teaching Prompt

```
Create a simple counter app that demonstrates React useState:
- A number display starting at 0
- An "Increment" button that adds 1
- A "Decrement" button that subtracts 1
- A "Reset" button that sets it back to 0

Add comments explaining what useState does.
Keep the styling minimal - focus on the functionality.
```

### Key Points to Explain

1. **useState returns two things**: The current value and a function to update it
   ```javascript
   const [count, setCount] = useState(0);
   //     ^        ^              ^
   //   value   updater      initial value
   ```

2. **Why we use setCount, not count = newValue**: React needs to know when to re-render

3. **The component re-renders when state changes**: Watch how the number updates on screen

4. **Initial value only applies once**: The 0 is just the starting point

### Practice Exercises

1. **Easy**: Add a button that increments by 5 instead of 1
2. **Medium**: Add a maximum limit (can't go above 10)
3. **Challenge**: Add a history of all previous values

### Common Mistakes to Discuss

- `count = count + 1` (won't trigger re-render)
- `setCount(count + 1)` (correct way)
- `setCount(prev => prev + 1)` (even better for reliability)

---

## Concept Library

Common concepts to teach with interactive examples:

| Concept | Good Example App |
|---------|-----------------|
| useState | Counter, Toggle |
| useEffect | Clock, Data fetcher |
| Props | Card with customizable content |
| Events | Button click handlers |
| Forms | Simple input with display |
| Conditional rendering | Show/hide content |
| Lists | Todo list |
| CSS Flexbox | Card layout |
| CSS Grid | Photo gallery |
| Async/await | API data loader |
| Error handling | Form validation |
