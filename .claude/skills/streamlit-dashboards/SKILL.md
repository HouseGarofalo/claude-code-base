---
name: streamlit-dashboards
description: Build Python-native dashboards with Streamlit. Covers layouts, components, session state, caching, charts, custom components, and deployment. Use for data science dashboards, ML demos, internal tools, and rapid prototyping with Python. Triggers on streamlit, python dashboard, data visualization, ML demo, interactive dashboard, data app.
---

# Streamlit Dashboards

Build interactive Python dashboards without frontend experience.

## Getting Started

```bash
pip install streamlit
streamlit run app.py
```

## Basic App Structure

```python
import streamlit as st
import pandas as pd
import plotly.express as px

# Page config (must be first Streamlit command)
st.set_page_config(
    page_title="My Dashboard",
    page_icon="chart_with_upwards_trend",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Title
st.title("Analytics Dashboard")
st.markdown("Real-time insights into your data")

# Sidebar
with st.sidebar:
    st.header("Filters")
    date_range = st.date_input("Date Range", [])
    category = st.selectbox("Category", ["All", "Sales", "Marketing"])

# Main content
col1, col2, col3 = st.columns(3)

with col1:
    st.metric("Total Revenue", "$45,231", "+12.5%")

with col2:
    st.metric("Active Users", "2,345", "+5.2%")

with col3:
    st.metric("Conversion Rate", "3.2%", "-0.4%", delta_color="inverse")
```

## Layouts

### Columns

```python
# Equal columns
col1, col2, col3 = st.columns(3)

# Custom widths
left, right = st.columns([2, 1])  # 2:1 ratio

# With gaps
col1, col2 = st.columns(2, gap="large")
```

### Containers & Expanders

```python
# Container for grouping
with st.container():
    st.header("Section Header")
    st.write("Content inside container")

# Expandable section
with st.expander("Advanced Options", expanded=False):
    st.slider("Parameter 1", 0, 100, 50)

# Tabs
tab1, tab2, tab3 = st.tabs(["Overview", "Details", "Settings"])
with tab1:
    st.write("Overview content")
```

## Input Widgets

```python
# Text inputs
name = st.text_input("Name", placeholder="Enter your name")
description = st.text_area("Description", height=100)

# Numbers
age = st.number_input("Age", min_value=0, max_value=120, value=25)
price = st.slider("Price Range", 0.0, 1000.0, (100.0, 500.0))

# Selections
option = st.selectbox("Choose one", ["A", "B", "C"])
options = st.multiselect("Choose many", ["A", "B", "C", "D"])

# Date/Time
date = st.date_input("Select date")
time = st.time_input("Select time")

# Files
uploaded_file = st.file_uploader("Upload CSV", type=["csv", "xlsx"])
if uploaded_file:
    df = pd.read_csv(uploaded_file)
    st.dataframe(df)

# Toggles
agree = st.checkbox("I agree to terms")
enabled = st.toggle("Enable feature")
```

## Data Display

```python
# DataFrame
df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Sales': [100, 150, 200],
    'Growth': [0.1, 0.25, 0.15]
})

# Basic table
st.dataframe(df)

# Editable table
edited_df = st.data_editor(df, num_rows="dynamic")

# Column configuration
st.dataframe(
    df,
    column_config={
        "Growth": st.column_config.ProgressColumn(
            "Growth",
            format="%.0f%%",
            min_value=0,
            max_value=1,
        )
    }
)

# Metrics
col1, col2, col3 = st.columns(3)
col1.metric("Revenue", "$45,231", "+12.5%")
col2.metric("Users", "2,345", "+5.2%")
col3.metric("Bounce Rate", "32%", "-8%", delta_color="inverse")
```

## Charts

### Built-in Charts

```python
import numpy as np

chart_data = pd.DataFrame(
    np.random.randn(20, 3),
    columns=['A', 'B', 'C']
)

st.line_chart(chart_data)
st.area_chart(chart_data)
st.bar_chart(chart_data)
st.scatter_chart(chart_data, x='A', y='B', size='C')
```

### Plotly Integration

```python
import plotly.express as px

fig = px.line(df, x='date', y='value', color='category',
              title='Trend Over Time')
st.plotly_chart(fig, use_container_width=True)
```

## Caching

```python
# Cache data loading
@st.cache_data(ttl=3600)  # Cache for 1 hour
def load_data(url: str) -> pd.DataFrame:
    return pd.read_csv(url)

# Cache ML models
@st.cache_resource
def load_model():
    import joblib
    return joblib.load('model.pkl')

# Usage
df = load_data("https://example.com/data.csv")  # Cached
model = load_model()  # Cached singleton
```

## Session State

```python
# Initialize state
if 'counter' not in st.session_state:
    st.session_state.counter = 0

if 'messages' not in st.session_state:
    st.session_state.messages = []

# Update state
if st.button("Increment"):
    st.session_state.counter += 1

st.write(f"Counter: {st.session_state.counter}")

# Form with state
with st.form("my_form"):
    name = st.text_input("Name")
    submitted = st.form_submit_button("Submit")

    if submitted:
        st.session_state.messages.append(f"Hello, {name}!")
```

## Progress & Status

```python
import time

# Progress bar
progress = st.progress(0)
for i in range(100):
    time.sleep(0.01)
    progress.progress(i + 1)

# Spinner
with st.spinner("Loading..."):
    time.sleep(2)
st.success("Done!")

# Status messages
st.success("Operation completed!")
st.info("This is informational")
st.warning("This is a warning")
st.error("This is an error")

# Toast notifications
st.toast("File saved!", icon="check")
```

## Multi-page Apps

```
my_app/
+-- streamlit_app.py
+-- pages/
    +-- 1_Dashboard.py
    +-- 2_Analytics.py
    +-- 3_Settings.py
```

## Deployment

### Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8501
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

## Best Practices

1. **Use wide layout** for dashboards - `layout="wide"`
2. **Cache aggressively** - Data loading and model inference
3. **Group related inputs** in sidebar or expanders
4. **Use columns for KPIs** - Clean metric displays
5. **Add loading indicators** - Spinners for long operations
6. **Handle errors gracefully** - Try/except with `st.error`

## When to Use This Skill

- Data science dashboards and ML demos
- Internal tools and admin panels
- Rapid prototyping
- POCs and MVPs
- Data exploration interfaces
