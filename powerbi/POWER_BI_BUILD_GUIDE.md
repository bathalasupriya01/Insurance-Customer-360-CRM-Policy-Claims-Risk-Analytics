# Power BI Build Guide

## Design direction

The report should look like a business dashboard built by an analyst, not a template.

Use:
- left-aligned page title and one-line subtitle;
- a single restrained KPI row;
- consistent chart alignment;
- limited use of borders;
- white space between sections;
- one clear analytical purpose per page;
- short insight callouts only where the data supports them.

Avoid:
- giant centred headings;
- excessive coloured cards;
- unnecessary donut charts;
- repeated visuals;
- decorative icons that do not add meaning.

## Data

Import the original IBM CSV and rename the table to:

`CustomerAnalysis`

Set:
- Effective To Date → Date
- Customer Lifetime Value → Decimal
- Income → Whole number / Currency as appropriate
- Monthly Premium Auto → Decimal/Currency
- Total Claim Amount → Decimal/Currency
- Months Since Last Claim → Whole number
- Months Since Policy Inception → Whole number
- Number of Open Complaints → Whole number
- Number of Policies → Whole number

## Page 1 — Executive Overview

### Header
**Insurance Customer 360**
Subtitle: CRM, policy and claims view | IBM sample data

### KPI row
1. Customers
2. Average CLV
3. Response Rate
4. Average Monthly Premium
5. Average Claim Amount
6. Open Complaint Customer Rate

### Main visuals
- Response Rate by Sales Channel — horizontal bar
- Average CLV and Average Claim by Coverage — clustered column or combo
- Customer mix by Policy Type — bar
- Small insight panel with 3 evidence-based findings

Recommended insight wording:
- Overall response: 14.32%
- Agent channel: 19.15% response
- Offer2: 23.38% observed response

Do not say the channel or offer “caused” the improvement.

## Page 2 — CRM & Customer Insights

### KPI row
- Responders
- High Value Customers
- High Value Non-Responders
- Avg Policies per Customer

### Visuals
- Offer response rate — sorted bar
- Offer x Channel — matrix with conditional formatting
- Customer Value Tier — customers + response rate
- Sales Channel — customers vs response
- Detail table for high-value non-responders

### Slicers
- State
- Coverage
- Sales Channel
- Renew Offer Type

Keep slicers in one compact row or side panel.

## Page 3 — Policy & Claims

### KPI row
- Average Claim
- Claim P90
- Very High Claim Customers
- Claim-to-Annual-Premium Proxy

### Visuals
- Average Claim by Vehicle Class
- Average Claim by Coverage
- Vehicle Class x Coverage matrix
- Claim Amount by Location Code
- Customers by Claim Band

Important:
The proxy metric is not an actuarial loss ratio because the dataset lacks aligned exposure and loss-development information.

## Page 4 — Claims Risk Review

This page is descriptive, not a fraud model.

### Visuals
- Claim Band profile: customers / avg claim / avg premium / avg CLV
- High-claim segment table with sample size
- Open complaint rate by segment
- Scatter: Average Monthly Premium vs Average Claim by Vehicle Class (bubble size = customers)

### Footer note
“Observed sample patterns for analytical review only. Not suitable for live underwriting, pricing or fraud decisions.”

## Human-made layout rules

- Page title: top-left.
- 32–36 px equivalent title size, not oversized.
- KPI numbers should be more prominent than labels.
- Use consistent margins.
- Use no more than 5–6 main visuals per page.
- Sort bars intentionally.
- Show sample size when highlighting small segments.
- Use tooltips for secondary metrics instead of cluttering the canvas.
- Use the supplied theme JSON as a starting point, then adjust if needed.
