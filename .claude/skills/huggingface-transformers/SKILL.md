---
name: huggingface-transformers
description: Use Hugging Face Transformers for local model inference, embeddings, and fine-tuning. Covers pipelines, model selection, quantization, and optimization. Use when working with local LLMs, embeddings, or custom model training.
---

# Hugging Face Transformers Skill

## Triggers

Use this skill when:
- Running local model inference with Transformers
- Creating embeddings with sentence-transformers
- Fine-tuning models with Trainer or PEFT/LoRA
- Implementing quantization for memory optimization
- Working with HuggingFace models and pipelines
- Keywords: huggingface, transformers, pipeline, embeddings, fine-tuning, lora, quantization, local inference

## Quick Reference

| Task | Approach | Key Class |
|------|----------|-----------|
| Text Generation | `pipeline("text-generation")` | `AutoModelForCausalLM` |
| Classification | `pipeline("text-classification")` | `AutoModelForSequenceClassification` |
| Embeddings | `sentence-transformers` | `SentenceTransformer` |
| NER | `pipeline("ner")` | `AutoModelForTokenClassification` |
| QA | `pipeline("question-answering")` | `AutoModelForQuestionAnswering` |
| Fine-tuning | `Trainer` API | `TrainingArguments` |

## Installation

```bash
# Core transformers
pip install transformers torch

# With all extras
pip install transformers[torch] accelerate

# For embeddings
pip install sentence-transformers

# For quantization
pip install bitsandbytes

# For PEFT/LoRA
pip install peft

# For datasets
pip install datasets
```

## Pipeline API (Fastest Start)

### Text Generation

```python
from transformers import pipeline

# Simple generation
generator = pipeline("text-generation", model="microsoft/DialoGPT-medium")
result = generator("Hello, how are you?", max_length=50, num_return_sequences=1)
print(result[0]["generated_text"])

# With specific model for instruction following
generator = pipeline(
    "text-generation",
    model="mistralai/Mistral-7B-Instruct-v0.2",
    device_map="auto",
    torch_dtype="auto"
)

messages = [{"role": "user", "content": "Explain transformers in 2 sentences"}]
response = generator(messages, max_new_tokens=100)
```

### Text Classification

```python
from transformers import pipeline

# Sentiment analysis
classifier = pipeline("sentiment-analysis")
result = classifier("I love this product!")
# [{'label': 'POSITIVE', 'score': 0.9998}]

# Zero-shot classification
classifier = pipeline("zero-shot-classification")
result = classifier(
    "This is a tutorial about machine learning",
    candidate_labels=["education", "politics", "business"]
)
```

### Named Entity Recognition

```python
from transformers import pipeline

ner = pipeline("ner", aggregation_strategy="simple")
text = "Apple CEO Tim Cook announced new products in Cupertino"
entities = ner(text)

for entity in entities:
    print(f"{entity['word']}: {entity['entity_group']} ({entity['score']:.2f})")
```

## Model and Tokenizer Loading

### Basic Loading

```python
from transformers import AutoTokenizer, AutoModel, AutoModelForCausalLM

# Load tokenizer and model separately
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
model = AutoModel.from_pretrained("bert-base-uncased")

# For text generation models
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-2-7b-hf")
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    device_map="auto",
    torch_dtype="auto"
)
```

### Loading with Options

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-v0.1",
    torch_dtype=torch.float16,      # Half precision
    device_map="auto",              # Automatic GPU placement
    low_cpu_mem_usage=True,         # Reduce RAM during loading
    trust_remote_code=True,         # For custom architectures
    attn_implementation="flash_attention_2"  # If available
)

tokenizer = AutoTokenizer.from_pretrained(
    "mistralai/Mistral-7B-v0.1",
    padding_side="left",            # For batch generation
    use_fast=True                   # Use Rust tokenizer
)
tokenizer.pad_token = tokenizer.eos_token  # Set pad token
```

## Embeddings with Sentence Transformers

### Basic Embeddings

```python
from sentence_transformers import SentenceTransformer

# Load model
model = SentenceTransformer("all-MiniLM-L6-v2")

# Single text
embedding = model.encode("Hello, world!")
print(f"Dimension: {len(embedding)}")  # 384

# Batch encoding
sentences = ["First sentence", "Second sentence", "Third sentence"]
embeddings = model.encode(sentences, show_progress_bar=True)
```

### Semantic Similarity

```python
from sentence_transformers import SentenceTransformer, util

model = SentenceTransformer("all-mpnet-base-v2")

query = "How to learn Python?"
documents = [
    "Python tutorial for beginners",
    "Advanced JavaScript patterns",
    "Machine learning with Python",
    "Cooking recipes for dinner"
]

# Encode
query_embedding = model.encode(query, convert_to_tensor=True)
doc_embeddings = model.encode(documents, convert_to_tensor=True)

# Calculate similarity
scores = util.cos_sim(query_embedding, doc_embeddings)[0]

# Rank results
ranked = sorted(zip(documents, scores.tolist()), key=lambda x: x[1], reverse=True)
for doc, score in ranked:
    print(f"{score:.3f}: {doc}")
```

### Embedding Model Selection

| Model | Dim | Use Case |
|-------|-----|----------|
| `all-MiniLM-L6-v2` | 384 | Fast, general purpose |
| `all-mpnet-base-v2` | 768 | Higher quality, balanced |
| `bge-large-en-v1.5` | 1024 | State-of-the-art retrieval |
| `e5-large-v2` | 1024 | Multilingual support |
| `nomic-embed-text-v1` | 768 | Long context (8K tokens) |

## Quantization

### BitsAndBytes 4-bit Quantization

```python
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
import torch

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",              # Normal float 4
    bnb_4bit_compute_dtype=torch.float16,    # Computation dtype
    bnb_4bit_use_double_quant=True           # Nested quantization
)

model = AutoModelForCausalLM.from_pretrained(
    "mistralai/Mistral-7B-v0.1",
    quantization_config=bnb_config,
    device_map="auto"
)
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")
```

### Memory Comparison

| Model (7B) | Precision | VRAM | Quality |
|------------|-----------|------|---------|
| Full | FP32 | ~28GB | 100% |
| Half | FP16 | ~14GB | ~99% |
| 8-bit | INT8 | ~7GB | ~97% |
| 4-bit | NF4 | ~4GB | ~95% |

## Fine-Tuning with Trainer

### Basic Fine-Tuning

```python
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    TrainingArguments,
    Trainer
)
from datasets import load_dataset

# Load dataset
dataset = load_dataset("imdb")

# Load model and tokenizer
model_name = "distilbert-base-uncased"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name, num_labels=2)

# Tokenize dataset
def tokenize_function(examples):
    return tokenizer(
        examples["text"],
        padding="max_length",
        truncation=True,
        max_length=512
    )

tokenized_datasets = dataset.map(tokenize_function, batched=True)

# Training arguments
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    warmup_steps=500,
    weight_decay=0.01,
    logging_dir="./logs",
    logging_steps=100,
    eval_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True
)

# Create trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_datasets["train"],
    eval_dataset=tokenized_datasets["test"]
)

# Train
trainer.train()
```

## PEFT and LoRA

### LoRA Fine-Tuning

```python
from peft import LoraConfig, get_peft_model, TaskType
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load base model
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    load_in_4bit=True,
    device_map="auto"
)
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-2-7b-hf")

# LoRA configuration
lora_config = LoraConfig(
    r=16,                          # Rank
    lora_alpha=32,                 # Alpha scaling
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type=TaskType.CAUSAL_LM
)

# Apply LoRA
model = get_peft_model(model, lora_config)
model.print_trainable_parameters()
# trainable params: 4,194,304 || all params: 6,742,609,920 || trainable%: 0.06%
```

### Save and Load LoRA Adapters

```python
# Save adapter only (small file)
model.save_pretrained("./lora-adapter")

# Load adapter onto base model
from peft import PeftModel

base_model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-2-7b-hf")
model = PeftModel.from_pretrained(base_model, "./lora-adapter")

# Merge adapter into base model (optional)
merged_model = model.merge_and_unload()
merged_model.save_pretrained("./merged-model")
```

## Best Practices

### 1. Choose the Right Model Size

```python
MODELS_BY_USE_CASE = {
    "quick_prototype": "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
    "production_chat": "microsoft/Phi-3-mini-4k-instruct",
    "code_generation": "codellama/CodeLlama-7b-hf",
    "embeddings": "sentence-transformers/all-MiniLM-L6-v2"
}
```

### 2. Always Set Device and Dtype

```python
import torch
from transformers import AutoModelForCausalLM

device = "cuda" if torch.cuda.is_available() else "cpu"
dtype = torch.float16 if device == "cuda" else torch.float32

model = AutoModelForCausalLM.from_pretrained(
    model_id,
    torch_dtype=dtype,
    device_map="auto" if device == "cuda" else None
)
```

### 3. Handle Tokenizer Edge Cases

```python
tokenizer = AutoTokenizer.from_pretrained(model_id)

# Set pad token for batching
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token

# For left-padding in generation
tokenizer.padding_side = "left"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| CUDA OOM | Use 4-bit quantization or smaller model |
| Slow generation | Enable `use_cache=True`, use Flash Attention |
| Truncated output | Increase `max_new_tokens` |
| Repetitive text | Set `repetition_penalty=1.1` |
| Model not found | Check `HF_TOKEN` for gated models |
| Wrong device | Explicitly set `device_map="auto"` |
