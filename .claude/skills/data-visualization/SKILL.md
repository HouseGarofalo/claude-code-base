---
name: data-visualization
description: Create effective data visualizations with React charting libraries. Covers chart selection, Recharts, Chart.js, D3.js basics, real-time data, accessible charts, and color palettes. Use for charts, graphs, dashboards, and data-driven displays.
---

# Data Visualization

Build effective, accessible charts and graphs for data-driven applications.

## Instructions

1. **Choose the right chart type** - Match visualization to data relationships
2. **Keep it simple** - Avoid chart junk and unnecessary decoration
3. **Use color purposefully** - Semantic colors, accessible palettes
4. **Label clearly** - Axes, legends, and data points should be readable
5. **Make it accessible** - Screen reader support and keyboard navigation

## Chart Type Selection

| Data Relationship | Chart Type |
|-------------------|------------|
| Trend over time | Line chart |
| Comparison | Bar chart |
| Part of whole | Pie/Donut chart |
| Distribution | Histogram |
| Correlation | Scatter plot |
| Ranking | Horizontal bar |
| Geographic | Map |

## Recharts (Recommended)

### Basic Line Chart

```tsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const data = [
  { month: 'Jan', revenue: 4000 },
  { month: 'Feb', revenue: 3000 },
  { month: 'Mar', revenue: 5000 },
  { month: 'Apr', revenue: 4500 },
  { month: 'May', revenue: 6000 },
];

function RevenueChart() {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={data} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
        <XAxis dataKey="month" stroke="#6b7280" fontSize={12} />
        <YAxis stroke="#6b7280" fontSize={12} tickFormatter={(v) => `$${v / 1000}k`} />
        <Tooltip
          formatter={(value: number) => [`$${value.toLocaleString()}`, 'Revenue']}
          contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
        />
        <Line
          type="monotone"
          dataKey="revenue"
          stroke="#2563eb"
          strokeWidth={2}
          dot={{ fill: '#2563eb', strokeWidth: 2 }}
          activeDot={{ r: 6 }}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

### Multi-Line Chart with Legend

```tsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

function ComparisonChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={400}>
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="date" />
        <YAxis />
        <Tooltip />
        <Legend />
        <Line type="monotone" dataKey="thisYear" stroke="#2563eb" name="This Year" />
        <Line type="monotone" dataKey="lastYear" stroke="#9ca3af" name="Last Year" strokeDasharray="5 5" />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

### Bar Chart

```tsx
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

function SalesChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={data}>
        <CartesianGrid strokeDasharray="3 3" vertical={false} />
        <XAxis dataKey="category" />
        <YAxis />
        <Tooltip />
        <Bar dataKey="sales" fill="#2563eb" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}
```

### Pie/Donut Chart

```tsx
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

const COLORS = ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

function CategoryPieChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          innerRadius={60}
          outerRadius={100}
          paddingAngle={2}
          dataKey="value"
          label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
        >
          {data.map((entry, index) => (
            <Cell key={entry.name} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
}
```

## Sparklines

```tsx
import { LineChart, Line, ResponsiveContainer } from 'recharts';

function Sparkline({ data, color = '#2563eb', height = 40 }) {
  return (
    <ResponsiveContainer width="100%" height={height}>
      <LineChart data={data}>
        <Line
          type="monotone"
          dataKey="value"
          stroke={color}
          strokeWidth={2}
          dot={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}

// Usage in KPI card
function KPICardWithSparkline({ title, value, trend }) {
  return (
    <div className="bg-white p-4 rounded-lg shadow">
      <div className="text-sm text-gray-500">{title}</div>
      <div className="text-2xl font-bold">{value}</div>
      <div className="mt-2 h-10">
        <Sparkline data={trend} />
      </div>
    </div>
  );
}
```

## Real-Time Charts

```tsx
function RealTimeChart() {
  const [data, setData] = useState<{ time: string; value: number }[]>([]);

  useEffect(() => {
    const interval = setInterval(() => {
      setData((prev) => {
        const newPoint = {
          time: new Date().toLocaleTimeString(),
          value: Math.random() * 100,
        };
        const updated = [...prev, newPoint];
        // Keep last 20 points
        return updated.slice(-20);
      });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={data}>
        <XAxis dataKey="time" />
        <YAxis domain={[0, 100]} />
        <Line
          type="monotone"
          dataKey="value"
          stroke="#2563eb"
          isAnimationActive={false}
          dot={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

## Accessible Charts

```tsx
function AccessibleChart({ data, title, description }) {
  return (
    <div role="img" aria-label={title} aria-describedby="chart-desc">
      <p id="chart-desc" className="sr-only">{description}</p>

      {/* Visual chart */}
      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={data}>
          <XAxis dataKey="name" />
          <YAxis />
          <Bar dataKey="value" fill="#2563eb" />
        </BarChart>
      </ResponsiveContainer>

      {/* Data table for screen readers */}
      <table className="sr-only">
        <caption>{title}</caption>
        <thead>
          <tr>
            <th>Category</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          {data.map((item) => (
            <tr key={item.name}>
              <td>{item.name}</td>
              <td>{item.value}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

## Color Palettes

```tsx
// Categorical (distinct items)
const categorical = ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4'];

// Sequential (low to high)
const sequential = ['#dbeafe', '#93c5fd', '#3b82f6', '#1d4ed8', '#1e3a8a'];

// Diverging (negative to positive)
const diverging = ['#ef4444', '#fca5a5', '#fef3c7', '#86efac', '#22c55e'];

// Status colors
const status = {
  success: '#22c55e',
  warning: '#f59e0b',
  error: '#ef4444',
  info: '#3b82f6',
};
```

## Chart.js Integration

```tsx
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js';
import { Line } from 'react-chartjs-2';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

function ChartJSLine({ data }) {
  const chartData = {
    labels: data.map(d => d.label),
    datasets: [{
      label: 'Revenue',
      data: data.map(d => d.value),
      borderColor: '#2563eb',
      backgroundColor: 'rgba(37, 99, 235, 0.1)',
      fill: true,
      tension: 0.4,
    }],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
    },
    scales: {
      y: { beginAtZero: true },
    },
  };

  return (
    <div style={{ height: 300 }}>
      <Line data={chartData} options={options} />
    </div>
  );
}
```

## Best Practices

1. **Start Y-axis at zero** for bar charts (prevents misleading comparisons)
2. **Use consistent colors** across related charts
3. **Limit data points** - aggregate if too dense
4. **Add context** - show comparisons, targets, benchmarks
5. **Format numbers** - use abbreviations for large numbers (1.2M not 1,200,000)
6. **Test color blindness** - use patterns or labels as backup

## When to Use

- Analytics dashboards
- Financial reports
- Performance monitoring
- Scientific data display
- Business intelligence tools
- Marketing metrics

## Notes

- Recharts is best for React integration and customization
- Chart.js is lighter but less React-native
- D3.js offers maximum control but steeper learning curve
- Consider SVG export for print/sharing
