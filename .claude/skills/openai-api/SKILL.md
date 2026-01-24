---
name: openai-api
description: Build with OpenAI APIs including GPT-4, GPT-4o, function calling, embeddings, vision, and Assistants. Covers chat completions, structured outputs, streaming, and token optimization. Use when integrating OpenAI models into applications.
---

# OpenAI API Skill

> Build production-ready applications with OpenAI's GPT-4, GPT-4o, embeddings, vision, and Assistants API.

## Triggers

Use this skill when:
- Integrating OpenAI models into applications
- Building chat completions or conversational AI
- Implementing function calling or tool use
- Working with embeddings or semantic search
- Using vision capabilities for image analysis
- Building with the Assistants API
- Keywords: openai, gpt-4, gpt-4o, chat completion, function calling, embeddings, vision, assistants

## Quick Reference

| Feature            | Model                            | Use Case                       |
| ------------------ | -------------------------------- | ------------------------------ |
| Chat Completions   | `gpt-4o`, `gpt-4-turbo`          | Conversations, reasoning       |
| Structured Outputs | `gpt-4o-2024-08-06+`             | JSON schemas, typed responses  |
| Function Calling   | `gpt-4o`, `gpt-4-turbo`          | Tool use, API integration      |
| Vision             | `gpt-4o`, `gpt-4-vision-preview` | Image analysis                 |
| Embeddings         | `text-embedding-3-small/large`   | Semantic search, RAG           |
| Assistants         | `gpt-4o`, `gpt-4-turbo`          | Stateful agents, file handling |

---

## Installation

```bash
# Python
pip install openai

# Node.js / TypeScript
npm install openai
```

### Client Setup

**Python:**

```python
from openai import OpenAI

# Uses OPENAI_API_KEY env var by default
client = OpenAI()

# Or explicit key
client = OpenAI(api_key="sk-...")
```

**TypeScript:**

```typescript
import OpenAI from "openai";

const openai = new OpenAI(); // Uses OPENAI_API_KEY env var
// Or: new OpenAI({ apiKey: 'sk-...' })
```

---

## Chat Completions

### Basic Chat

**Python:**

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Explain async/await in Python"}
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

**TypeScript:**

```typescript
const response = await openai.chat.completions.create({
  model: "gpt-4o",
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: "Explain async/await in TypeScript" },
  ],
  temperature: 0.7,
  max_tokens: 500,
});

console.log(response.choices[0].message.content);
```

### Multi-Turn Conversation

```python
conversation = [
    {"role": "system", "content": "You are a Python tutor."}
]

def chat(user_message: str) -> str:
    conversation.append({"role": "user", "content": user_message})

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=conversation
    )

    assistant_message = response.choices[0].message.content
    conversation.append({"role": "assistant", "content": assistant_message})

    return assistant_message
```

### Model Selection Guide

| Model           | Context | Best For                | Cost |
| --------------- | ------- | ----------------------- | ---- |
| `gpt-4o`        | 128K    | General purpose, vision | $$   |
| `gpt-4o-mini`   | 128K    | Fast, cost-effective    | $    |
| `gpt-4-turbo`   | 128K    | Complex reasoning       | $$$  |
| `gpt-3.5-turbo` | 16K     | Simple tasks            | $    |

---

## Structured Outputs / JSON Mode

### JSON Mode (Legacy)

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "Output valid JSON only."},
        {"role": "user", "content": "List 3 programming languages with their use cases"}
    ],
    response_format={"type": "json_object"}
)

import json
data = json.loads(response.choices[0].message.content)
```

### Structured Outputs with JSON Schema (Recommended)

**Python with Pydantic:**

```python
from pydantic import BaseModel
from typing import List

class Language(BaseModel):
    name: str
    use_cases: List[str]
    difficulty: str

class LanguageList(BaseModel):
    languages: List[Language]

response = client.beta.chat.completions.parse(
    model="gpt-4o-2024-08-06",
    messages=[
        {"role": "user", "content": "List 3 programming languages"}
    ],
    response_format=LanguageList
)

# Typed response
languages: LanguageList = response.choices[0].message.parsed
for lang in languages.languages:
    print(f"{lang.name}: {lang.difficulty}")
```

**TypeScript with Zod:**

```typescript
import { z } from "zod";
import { zodResponseFormat } from "openai/helpers/zod";

const LanguageSchema = z.object({
  languages: z.array(
    z.object({
      name: z.string(),
      use_cases: z.array(z.string()),
      difficulty: z.enum(["beginner", "intermediate", "advanced"]),
    }),
  ),
});

const response = await openai.beta.chat.completions.parse({
  model: "gpt-4o-2024-08-06",
  messages: [{ role: "user", content: "List 3 programming languages" }],
  response_format: zodResponseFormat(LanguageSchema, "languages"),
});

const languages = response.choices[0].message.parsed;
```

---

## Function Calling / Tools

### Define Tools

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City and state, e.g., San Francisco, CA"
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "default": "fahrenheit"
                    }
                },
                "required": ["location"]
            }
        }
    }
]
```

### Execute Tool Calls

```python
import json

def execute_tool(name: str, args: dict) -> str:
    """Execute tool and return result as string."""
    if name == "get_weather":
        # Call actual weather API
        return json.dumps({"temp": 72, "condition": "sunny"})
    return json.dumps({"error": "Unknown tool"})

def chat_with_tools(user_message: str) -> str:
    messages = [{"role": "user", "content": user_message}]

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        tools=tools,
        tool_choice="auto"  # or "required" to force tool use
    )

    message = response.choices[0].message

    # Check if model wants to call tools
    if message.tool_calls:
        messages.append(message)  # Add assistant message with tool calls

        # Execute each tool call
        for tool_call in message.tool_calls:
            result = execute_tool(
                tool_call.function.name,
                json.loads(tool_call.function.arguments)
            )
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": result
            })

        # Get final response with tool results
        final_response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            tools=tools
        )
        return final_response.choices[0].message.content

    return message.content
```

---

## Vision (Image Inputs)

### Analyze Images

```python
import base64

def encode_image(image_path: str) -> str:
    with open(image_path, "rb") as f:
        return base64.standard_b64encode(f.read()).decode("utf-8")

# From URL
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "What's in this image?"},
            {
                "type": "image_url",
                "image_url": {"url": "https://example.com/image.jpg"}
            }
        ]
    }]
)

# From base64
image_data = encode_image("screenshot.png")
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Describe this UI screenshot"},
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/png;base64,{image_data}",
                    "detail": "high"  # "low", "high", or "auto"
                }
            }
        ]
    }]
)
```

---

## Embeddings

### Generate Embeddings

```python
def get_embedding(text: str, model: str = "text-embedding-3-small") -> list[float]:
    response = client.embeddings.create(
        input=text,
        model=model
    )
    return response.data[0].embedding

# Single text
embedding = get_embedding("OpenAI makes great APIs")
print(f"Dimensions: {len(embedding)}")  # 1536 for small, 3072 for large

# Batch embeddings (more efficient)
texts = ["First document", "Second document", "Third document"]
response = client.embeddings.create(
    input=texts,
    model="text-embedding-3-small"
)
embeddings = [item.embedding for item in response.data]
```

---

## Streaming Responses

### Basic Streaming

**Python:**

```python
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a short story"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
```

**TypeScript:**

```typescript
const stream = await openai.chat.completions.create({
  model: "gpt-4o",
  messages: [{ role: "user", content: "Write a short story" }],
  stream: true,
});

for await (const chunk of stream) {
  const content = chunk.choices[0]?.delta?.content;
  if (content) process.stdout.write(content);
}
```

---

## Assistants API

### Create an Assistant

```python
assistant = client.beta.assistants.create(
    name="Data Analyst",
    instructions="You are a data analyst. Analyze data and create visualizations.",
    model="gpt-4o",
    tools=[
        {"type": "code_interpreter"},
        {"type": "file_search"}
    ]
)
```

### Run a Conversation

```python
# Create thread
thread = client.beta.threads.create()

# Add message
client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Analyze this CSV and create a chart"
)

# Run assistant
run = client.beta.threads.runs.create_and_poll(
    thread_id=thread.id,
    assistant_id=assistant.id
)

if run.status == "completed":
    messages = client.beta.threads.messages.list(thread_id=thread.id)
    for msg in messages.data:
        if msg.role == "assistant":
            print(msg.content[0].text.value)
```

---

## Error Handling & Retries

```python
import time
from openai import RateLimitError, APITimeoutError, APIConnectionError

def chat_with_retry(
    messages: list,
    model: str = "gpt-4o",
    max_retries: int = 3,
    base_delay: float = 1.0
) -> str:
    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(
                model=model,
                messages=messages
            )
            return response.choices[0].message.content

        except RateLimitError as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            print(f"Rate limited. Retrying in {delay}s...")
            time.sleep(delay)

        except (APITimeoutError, APIConnectionError) as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            print(f"Connection error. Retrying in {delay}s...")
            time.sleep(delay)

    raise Exception("Max retries exceeded")
```

---

## Best Practices

| Category        | Recommendation                        |
| --------------- | ------------------------------------- |
| **Security**    | Never expose API keys; use env vars   |
| **Rate Limits** | Implement exponential backoff         |
| **Costs**       | Set usage limits; monitor daily spend |
| **Latency**     | Use streaming for long responses      |
| **Reliability** | Add fallback models (4o -> 4o-mini)   |
| **Logging**     | Log prompts, responses, tokens, costs |
| **Testing**     | Test with edge cases; mock in tests   |

---

## Resources

- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [OpenAI Cookbook](https://cookbook.openai.com/)
- [Pricing](https://openai.com/pricing)
- [Rate Limits](https://platform.openai.com/docs/guides/rate-limits)
- [Tiktoken Tokenizer](https://github.com/openai/tiktoken)
