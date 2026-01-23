---
name: prompt-engineering
description: Advanced prompt engineering techniques for LLMs. Master chain-of-thought, few-shot learning, self-consistency, tree-of-thought, and structured prompting. Use for optimizing AI outputs, building reliable AI systems, and improving model performance.
---

# Prompt Engineering Skill

## Triggers

Use this skill when you see:
- prompt, prompting, system prompt, few-shot
- chain of thought, CoT, reasoning
- structured output, JSON mode
- prompt optimization, prompt design
- LLM, AI output, model performance

## Instructions

### Core Prompting Techniques

#### 1. Zero-Shot Prompting

Direct instruction without examples:

```
Classify the sentiment of this review as positive, negative, or neutral:

Review: "The product arrived on time and works exactly as described."

Sentiment:
```

#### 2. Few-Shot Prompting

Provide examples to guide the model:

```
Classify the sentiment:

Review: "Absolutely terrible, broke after one day."
Sentiment: negative

Review: "It's okay, nothing special."
Sentiment: neutral

Review: "Best purchase I've ever made!"
Sentiment: positive

Review: "The product arrived on time and works exactly as described."
Sentiment:
```

#### 3. Chain-of-Thought (CoT)

Encourage step-by-step reasoning:

```
Solve this problem step by step:

A store has 45 apples. They sell 12 in the morning and receive a shipment of 30 more.
Then they sell 18 in the afternoon. How many apples do they have at the end of the day?

Let's work through this step by step:
1. Starting apples: 45
2. After morning sales: 45 - 12 = 33
3. After shipment: 33 + 30 = 63
4. After afternoon sales: 63 - 18 = 45

Answer: 45 apples
```

#### 4. Self-Consistency

Generate multiple reasoning paths, take majority vote:

```
Solve this problem using three different approaches, then verify:

Problem: [Complex problem]

Approach 1: [Method A]
Result: X

Approach 2: [Method B]
Result: X

Approach 3: [Method C]
Result: X

All approaches agree: X is the answer.
```

#### 5. Tree-of-Thought

Explore multiple reasoning branches:

```
Consider this problem from multiple angles:

Problem: [Problem statement]

Branch 1: If we approach this by [method A]...
- Leads to: [outcome]
- Confidence: [level]

Branch 2: If we approach this by [method B]...
- Leads to: [outcome]
- Confidence: [level]

Evaluation: Branch [X] is most promising because...
```

### System Prompt Design

#### Structure Template

```
You are [role/identity].

## Context
[Background information the model needs]

## Capabilities
You can:
- [Capability 1]
- [Capability 2]

You cannot:
- [Limitation 1]
- [Limitation 2]

## Instructions
1. [Primary instruction]
2. [Secondary instruction]
3. [Output format]

## Examples
[Few-shot examples if needed]

## Constraints
- [Constraint 1]
- [Constraint 2]
```

#### Example System Prompt

```
You are a senior code reviewer with expertise in Python and TypeScript.

## Context
You are reviewing code for a production application that handles sensitive user data.

## Capabilities
You can:
- Identify bugs and security vulnerabilities
- Suggest performance optimizations
- Recommend best practices
- Explain issues clearly

## Instructions
1. Review the provided code thoroughly
2. Categorize issues by severity: Critical, Warning, Suggestion
3. Provide specific line numbers and fixes
4. Explain the reasoning behind each recommendation

## Output Format
For each issue:
- **Severity**: [Critical/Warning/Suggestion]
- **Location**: Line [X]
- **Issue**: [Description]
- **Fix**: [Code suggestion]
- **Reason**: [Explanation]

## Constraints
- Focus on security and correctness first
- Be constructive, not dismissive
- Acknowledge good patterns when you see them
```

### Structured Output Techniques

#### JSON Mode

```
Extract the following information as JSON:

Text: "John Smith, a 32-year-old software engineer from Seattle, joined the company in March 2023."

Output the data in this exact JSON format:
{
  "name": "string",
  "age": number,
  "occupation": "string",
  "location": "string",
  "start_date": "YYYY-MM"
}
```

#### XML Tagging

```
Analyze this text and structure your response:

<text>
[Input text here]
</text>

Provide your analysis in this format:
<analysis>
  <summary>[Brief summary]</summary>
  <key_points>
    <point>[Point 1]</point>
    <point>[Point 2]</point>
  </key_points>
  <sentiment>[positive/negative/neutral]</sentiment>
</analysis>
```

### Advanced Techniques

#### Role Prompting

```
You are a world-class Python developer who has:
- 15 years of experience
- Contributed to major open-source projects
- Deep expertise in performance optimization
- Published books on clean code practices

Given this background, review the following code...
```

#### Constraint Prompting

```
Write a function to sort a list with these constraints:
- Must use O(n log n) time complexity
- Must use O(1) extra space
- Must be stable (preserve order of equal elements)
- Must handle empty lists gracefully
- Must include type hints
```

#### Decomposition

Break complex tasks into steps:

```
Task: Build a REST API for user management

Step 1: Define the data model
- What fields does a User need?
- What are the validation rules?

Step 2: Design the endpoints
- What CRUD operations are needed?
- What are the routes?

Step 3: Implement authentication
- What auth method?
- How to protect routes?

[Continue for each step...]
```

#### Metacognition Prompting

```
Before answering, consider:
1. What assumptions am I making?
2. What information might be missing?
3. What could go wrong with my answer?
4. How confident am I?

Then provide your answer with these reflections.
```

### Prompt Optimization Tips

1. **Be Specific**: Vague prompts get vague answers
2. **Provide Context**: Background improves accuracy
3. **Show Format**: Examples define expected output
4. **Set Constraints**: Limits focus the response
5. **Iterate**: Test and refine prompts
6. **Use Delimiters**: Separate sections clearly (```, """, ---)
7. **Order Matters**: Important info first or last (primacy/recency)
8. **Positive Framing**: Say what TO do, not just what NOT to do

### Common Patterns

#### Classification
```
Classify this [item] into one of these categories: [A, B, C]

[Item]: [content]

Category:
```

#### Extraction
```
Extract all [entities] from this text:

Text: [content]

[Entities] found:
1.
2.
```

#### Transformation
```
Convert this [format A] to [format B]:

Input:
[content in format A]

Output:
```

#### Generation
```
Generate [N] [items] that meet these criteria:
- [Criterion 1]
- [Criterion 2]

Output:
1.
2.
```

#### Evaluation
```
Evaluate this [item] on a scale of 1-10 for:
- [Criterion 1]:
- [Criterion 2]:

Provide reasoning for each score.
```

### Testing Prompts

1. **Edge Cases**: Test with unusual inputs
2. **Adversarial**: Try to break the prompt
3. **Consistency**: Same input should give similar outputs
4. **Robustness**: Slight variations shouldn't change meaning
5. **Measure**: Track success rate quantitatively
