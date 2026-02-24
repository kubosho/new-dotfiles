---
name: baseline
description: |
  Check Baseline status of web features using the Web Status API.
  Triggers: "baseline", "ベースライン", "ブラウザ対応状況", "browser support", "web feature status"
  Use cases: (1) check if a web feature is widely/newly available, (2) check browser support for a feature, (3) find features not available in a specific browser
argument-hint: "<feature name, structured query, or natural language, e.g. 'css-grid', 'not:firefox', 'Safariで使えないCSS機能'>"
---

# Baseline Web Feature Status Skill

Query the Web Status API to check browser Baseline status of web features.

## API Reference

**Endpoint**: `GET https://api.webstatus.dev/v1/features?q={query}`

### Query Operators

| Operator | Example |
|----------|---------|
| `name:<keyword>` | `name:grid` |
| `baseline_status:<status>` | `baseline_status:widely` |
| `available_on:<browser>` | `available_on:chrome` |
| `-available_on:<browser>` | `-available_on:firefox` |
| (plain text) | `grid` |

- **Statuses**: `widely`, `newly`, `limited`, `no_data`
- **Browsers**: `chrome`, `edge`, `firefox`, `safari`
- **AND**: separate with spaces — `name:grid baseline_status:widely`
- **OR**: join with `+OR+` — `name:grid+OR+name:flexbox`

### Response Schema

```json
{
  "data": [{
    "feature_id": "string",
    "name": "string",
    "baseline": {
      "status": "widely | newly | limited | no_data",
      "low_date": "YYYY-MM-DD (when first newly available)",
      "high_date": "YYYY-MM-DD (when widely available)"
    },
    "browser_implementations": {
      "<browser>": { "version": "string", "date": "string", "status": "string" }
    },
    "usage": {
      "chrome": { "daily": "number (0-1, fraction of page loads)" }
    }
  }],
  "metadata": { "total": "number" }
}
```

## Input Examples

| User input | API query |
|------------|-----------|
| `css-grid` | `name:css-grid` |
| `name:grid baseline_status:widely` | `name:grid baseline_status:widely` (pass through) |
| `not:firefox` | `-available_on:firefox` |
| `Firefoxで使えないCSS機能` | `-available_on:firefox name:css` |
| `widely availableなgrid関連機能` | `name:grid baseline_status:widely` |
| `Safariで使えるけどFirefoxで使えない機能` | `available_on:safari -available_on:firefox` |
| `最近追加された新しい機能` | `baseline_status:newly` |
| `まだ一部だけの機能` | `baseline_status:limited` |
| `gridかflexboxの対応状況` | `name:grid+OR+name:flexbox` |

## Output Schema

### Single/few features (roughly 5 or fewer)

For each feature, present:

| Field | Source | Note |
|-------|--------|------|
| Feature name | `name` | |
| Baseline status | `baseline.status` | Explain what the status means for practical use |
| Newly available date | `baseline.low_date` | Omit if absent |
| Widely available date | `baseline.high_date` | Omit if absent |
| Browser support | `browser_implementations` | Browser name, version, and date for each |
| Chrome usage | `usage.chrome.daily` | Display as percentage |

### Feature list (more than 5 results)

Summary table with feature name and baseline status. Limit to first 20 results, showing total count.

### Example output (single feature)

```
## Feature: CSS Grid

**Baseline status**: Widely available — safe to use across all major browsers.

**Support dates**:
- Newly available: 2017-10-17
- Widely available: 2020-04-17

**Browser support**:
- Chrome: 57 (2017-03-09)
- Edge: 16 (2017-10-17)
- Firefox: 52 (2017-03-07)
- Safari: 10.1 (2017-03-27)

**Usage (Chrome)**: 42.3%
```

## Constraints

- URL-encode all query parameters
- Timeout after 5 seconds
- When translating natural language, show the translated query so the user can learn the syntax
- If the API returns empty results or an error, suggest alternative queries
- If argument is empty, ask the user for a feature name or query
- Usage `daily` is a fraction (0–1); display as percentage
- Adapt display format to result count — detail for few, table for many
