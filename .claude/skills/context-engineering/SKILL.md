---
name: context-engineering
version: 1.0.0
description: Master context engineering for AI applications. Optimize prompt context, manage token budgets, implement RAG patterns, structure system prompts, and design effective context windows. Use when optimizing LLM prompts, managing context limits, implementing retrieval-augmented generation, or designing AI application architectures.
---

# Context Engineering: Optimizing AI Context Windows

Master the art of context engineering for AI applications - optimizing prompts, managing tokens, and designing effective context strategies.

## Triggers

Use this skill when:
- Optimizing LLM prompts for better results
- Managing context window limits
- Implementing RAG (Retrieval Augmented Generation)
- Designing AI application architectures
- Reducing token costs while maintaining quality
- Keywords: context, prompt, tokens, RAG, context window, prompt engineering, token budget, retrieval, embedding

## Core Concepts

### Context Window Anatomy

```
┌─────────────────────────────────────────────────────┐
│                  CONTEXT WINDOW                      │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │           SYSTEM PROMPT (Fixed)               │  │
│  │  - Identity & role                            │  │
│  │  - Behavioral rules                           │  │
│  │  - Output format                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │         RETRIEVED CONTEXT (Dynamic)           │  │
│  │  - Relevant documents                         │  │
│  │  - Code snippets                              │  │
│  │  - Reference data                             │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │        CONVERSATION HISTORY (Growing)         │  │
│  │  - Previous messages                          │  │
│  │  - Tool results                               │  │
│  │  - Intermediate outputs                       │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │           CURRENT INPUT (Variable)            │  │
│  │  - User query                                 │  │
│  │  - Inline context                             │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │         OUTPUT SPACE (Reserved)               │  │
│  │  - max_tokens allocation                      │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Token Budget Planning

| Component | Typical Allocation | Notes |
|-----------|-------------------|-------|
| System Prompt | 500-2000 tokens | Keep stable |
| Retrieved Context | 2000-10000 tokens | Scale with need |
| History | 1000-5000 tokens | Compress over time |
| Current Input | 100-1000 tokens | User controlled |
| Output Reserve | 1000-4096 tokens | Task dependent |

---

## Pattern 1: System Prompt Design

### Layered System Prompt

```markdown
# System Prompt Structure

## Layer 1: Identity (Always First)
You are [role description]. Your purpose is [primary function].

## Layer 2: Capabilities
You have access to:
- [Capability 1]
- [Capability 2]

## Layer 3: Behavioral Rules
ALWAYS:
- [Rule 1]
- [Rule 2]

NEVER:
- [Constraint 1]
- [Constraint 2]

## Layer 4: Output Format
When responding:
- [Format guideline 1]
- [Format guideline 2]

## Layer 5: Context Hints (Dynamic)
Current context: [injected at runtime]
```

### Compression Techniques

**Before (verbose):**
```
You are a helpful AI assistant that specializes in helping users with
coding tasks. When a user asks you to write code, you should first
understand what they're trying to accomplish, then write clean and
well-documented code that follows best practices.
```

**After (compressed):**
```
Role: Coding assistant
Process: Understand task -> Write clean, documented, best-practice code
```

---

## Pattern 2: Dynamic Context Injection

### Context Template System

```python
def build_context(task: str, retrieved_docs: list, history: list) -> str:
    template = """# Task
{task}

# Relevant Context
{context}

# Conversation History
{history}

# Instructions
Respond based on the context provided. If information is missing, say so.
"""
    return template.format(
        task=task,
        context=format_docs(retrieved_docs),
        history=format_history(history)
    )

def format_docs(docs: list, max_tokens: int = 5000) -> str:
    formatted = []
    current_tokens = 0

    for doc in sorted(docs, key=lambda d: d.relevance, reverse=True):
        doc_tokens = count_tokens(doc.content)
        if current_tokens + doc_tokens > max_tokens:
            break
        formatted.append(f"## {doc.title}\n{doc.content}")
        current_tokens += doc_tokens

    return "\n\n".join(formatted)
```

### Priority-Based Inclusion

```python
class ContextPriority:
    CRITICAL = 1    # Always include
    HIGH = 2        # Include if space
    MEDIUM = 3      # Include if plenty of space
    LOW = 4         # Include only if necessary

def select_context(items: list, budget: int) -> list:
    selected = []
    remaining = budget

    # Sort by priority, then relevance
    sorted_items = sorted(items, key=lambda x: (x.priority, -x.relevance))

    for item in sorted_items:
        tokens = count_tokens(item.content)
        if tokens <= remaining:
            selected.append(item)
            remaining -= tokens
        elif item.priority == ContextPriority.CRITICAL:
            # Summarize critical items if they don't fit
            summary = summarize(item.content, remaining)
            selected.append(item._replace(content=summary))
            break

    return selected
```

---

## Pattern 3: Conversation Summarization

### Rolling Summary

```python
class ConversationManager:
    def __init__(self, max_history_tokens: int = 3000):
        self.messages = []
        self.summary = ""
        self.max_tokens = max_history_tokens

    def add_message(self, role: str, content: str):
        self.messages.append({"role": role, "content": content})
        self._maybe_summarize()

    def _maybe_summarize(self):
        total_tokens = sum(count_tokens(m["content"]) for m in self.messages)

        if total_tokens > self.max_tokens:
            # Keep last N messages
            keep_recent = 4
            to_summarize = self.messages[:-keep_recent]
            recent = self.messages[-keep_recent:]

            # Summarize older messages
            new_summary = self._create_summary(to_summarize)
            self.summary = f"{self.summary}\n{new_summary}".strip()
            self.messages = recent

    def get_context(self) -> str:
        parts = []
        if self.summary:
            parts.append(f"[Previous conversation summary: {self.summary}]")
        parts.extend([f"{m['role']}: {m['content']}" for m in self.messages])
        return "\n\n".join(parts)
```

### Hierarchical Memory

```
MEMORY LEVELS

Level 1: Working Memory (Current Context)
- Last few exchanges
- Current task details
- Active tool results

Level 2: Session Memory (Summarized)
- Earlier conversation summary
- Key decisions made
- Important context established

Level 3: Long-term Memory (Retrieved)
- Past session summaries
- User preferences
- Project knowledge
```

---

## Pattern 4: RAG (Retrieval Augmented Generation)

### Basic RAG Pipeline

```python
class RAGPipeline:
    def __init__(self, embedder, vector_store, llm):
        self.embedder = embedder
        self.store = vector_store
        self.llm = llm

    def query(self, question: str, k: int = 5) -> str:
        # 1. Embed query
        query_embedding = self.embedder.embed(question)

        # 2. Retrieve relevant docs
        docs = self.store.similarity_search(query_embedding, k=k)

        # 3. Build context
        context = self._build_context(question, docs)

        # 4. Generate response
        return self.llm.generate(context)

    def _build_context(self, question: str, docs: list) -> str:
        doc_text = "\n\n".join([
            f"Source: {d.metadata.get('source', 'unknown')}\n{d.content}"
            for d in docs
        ])

        return f"""Based on the following context, answer the question.

Context:
{doc_text}

Question: {question}

Answer:"""
```

### Advanced RAG Techniques

**Hybrid Search:**
```python
def hybrid_search(query: str, k: int = 5):
    # Semantic search
    semantic_results = vector_search(query, k=k*2)

    # Keyword search
    keyword_results = bm25_search(query, k=k*2)

    # Combine and dedupe
    combined = merge_results(semantic_results, keyword_results)

    # Rerank
    return rerank(query, combined, k=k)
```

**Query Expansion:**
```python
def expand_query(original_query: str) -> list:
    expansion_prompt = f"""Generate 3 alternative phrasings for this query:
    {original_query}

    Return as JSON list."""

    alternatives = llm.generate(expansion_prompt)
    return [original_query] + json.loads(alternatives)
```

---

## Pattern 5: Token Optimization

### Techniques

| Technique | Savings | Trade-off |
|-----------|---------|-----------|
| Abbreviations | 10-20% | Readability |
| Remove examples | 20-40% | Clarity |
| Bullet points | 15-25% | Formatting |
| Summarization | 50-80% | Detail loss |
| Selective inclusion | Variable | Coverage |

### Implementation

```python
def optimize_context(content: str, target_tokens: int) -> str:
    current_tokens = count_tokens(content)

    if current_tokens <= target_tokens:
        return content

    # Try progressive compression
    strategies = [
        remove_redundant_whitespace,
        abbreviate_common_terms,
        remove_examples,
        extract_key_points,
        aggressive_summarize
    ]

    for strategy in strategies:
        content = strategy(content)
        if count_tokens(content) <= target_tokens:
            return content

    # Last resort: truncate
    return truncate_to_tokens(content, target_tokens)
```

---

## Pattern 6: Context Window Monitoring

### Token Tracking

```python
class TokenTracker:
    def __init__(self, model: str):
        self.model = model
        self.limit = get_context_limit(model)
        self.usage = {
            "system": 0,
            "context": 0,
            "history": 0,
            "input": 0,
            "reserved": 4096  # For output
        }

    def update(self, component: str, content: str):
        self.usage[component] = count_tokens(content)

    @property
    def available(self) -> int:
        used = sum(self.usage.values())
        return self.limit - used

    @property
    def utilization(self) -> float:
        return sum(self.usage.values()) / self.limit

    def can_add(self, content: str) -> bool:
        return count_tokens(content) <= self.available

    def report(self) -> str:
        return f"""Token Usage:
- System: {self.usage['system']}
- Context: {self.usage['context']}
- History: {self.usage['history']}
- Input: {self.usage['input']}
- Reserved: {self.usage['reserved']}
- Available: {self.available}
- Utilization: {self.utilization:.1%}"""
```

---

## Best Practices

### System Prompts

1. **Front-load important instructions**: Models attend more to beginning
2. **Use clear structure**: Headers, bullets, consistent formatting
3. **Be specific**: Vague instructions get vague results
4. **Test variations**: Small changes can have big impacts
5. **Version control**: Track what works

### Context Selection

1. **Relevance over recency**: Most relevant, not most recent
2. **Diversity**: Include different perspectives
3. **Source attribution**: Help model cite correctly
4. **Chunking strategy**: Match chunk size to use case
5. **Metadata inclusion**: Add context about context

### Token Management

1. **Reserve output space**: Don't fill entire context
2. **Monitor utilization**: Track across sessions
3. **Compress proactively**: Before hitting limits
4. **Cache summaries**: Don't re-summarize repeatedly
5. **Profile costs**: Know your token spend

---

## Quick Reference

### Token Counts (Approximate)

| Content Type | Tokens/Item |
|--------------|-------------|
| English word | 1.3 |
| Code line | 10-15 |
| Paragraph | 50-100 |
| Page of text | 500-750 |
| JSON object | 20-50 |

### Model Context Limits

| Model | Context Limit |
|-------|---------------|
| Claude Opus 4.5 | 200K |
| Claude Sonnet 4 | 200K |
| Claude Haiku 3.5 | 200K |
| GPT-4 Turbo | 128K |
| GPT-4o | 128K |

---

## Notes

- Context engineering is iterative - test and refine
- Different tasks need different context strategies
- Monitor both quality and cost
- Cache aggressively where possible
- Document your context architecture
