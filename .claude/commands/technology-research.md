---
name: technology-research
description: Research a technology or pattern and provide structured findings for implementation planning
---

# /technology-research - Technology Research

Research a technology or pattern and provide structured findings for implementation planning.

## Research Framework

### 1. Overview
- What is it?
- What problem does it solve?
- When should it be used?

### 2. Best Practices
- Recommended patterns
- Common configurations
- Performance considerations

### 3. Alternatives Considered
- What other options exist?
- Comparison matrix
- Why choose this over alternatives?

### 4. Integration Notes
- How to integrate with existing systems
- Required dependencies
- Configuration requirements

### 5. Gotchas and Pitfalls
- Common mistakes to avoid
- Known limitations
- Edge cases to handle

## Research Process

1. Search Archon knowledge base
   ```python
   rag_search_knowledge_base(query="[technology] [keyword]", match_count=5)
   ```

2. Search for code examples
   ```python
   rag_search_code_examples(query="[technology] [pattern]", match_count=3)
   ```

3. If needed, search the web
   ```python
   mcp__brave-search__brave_web_search(query="[technology] best practices 2024")
   ```

4. Compile findings into structured report

## Output Format

```markdown
# Research: [Technology/Pattern]

## Decision
[What was chosen and why]

## Rationale
[Detailed reasoning]

## Alternatives Considered

| Option | Pros | Cons | Why Rejected |
|--------|------|------|--------------|
| [Alt 1] | ... | ... | ... |
| [Alt 2] | ... | ... | ... |

## Implementation Notes

### Getting Started
- [Step 1]
- [Step 2]

### Configuration
[Key configuration options]

### Best Practices
- [Practice 1]
- [Practice 2]

### Common Pitfalls
- [Pitfall 1]: [How to avoid]
- [Pitfall 2]: [How to avoid]

## Code Example

[Minimal working example]

## Sources
- [Link to documentation]
- [Link to examples]
- [Link to tutorials]
```

## Arguments

$ARGUMENTS

Specify the technology or pattern to research.
Example: `GraphQL vs REST for mobile API`
Example: `State management options for React`
