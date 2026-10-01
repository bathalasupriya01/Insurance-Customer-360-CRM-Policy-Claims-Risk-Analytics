# Data Dictionary

| Field | Meaning in this project |
|---|---|
| Customer | Customer identifier |
| State | US state in the sample |
| Customer Lifetime Value | Customer value measure supplied in the dataset |
| Response | Whether the customer responded to the marketing activity |
| Coverage | Basic / Extended / Premium |
| Education | Customer education category |
| Effective To Date | Policy effective date field in the sample |
| EmploymentStatus | Employment category |
| Gender | Gender field in the sample |
| Income | Reported income |
| Location Code | Rural / Suburban / Urban |
| Marital Status | Marital-status category |
| Monthly Premium Auto | Monthly auto premium |
| Months Since Last Claim | Claim recency |
| Months Since Policy Inception | Policy tenure proxy |
| Number of Open Complaints | Open customer complaints |
| Number of Policies | Count of policies associated with customer |
| Policy Type | Personal / Corporate / Special Auto |
| Policy | Policy-level category |
| Renew Offer Type | Offer category (Offer1–Offer4) |
| Sales Channel | Agent / Branch / Call Center / Web |
| Total Claim Amount | Observed claim amount |
| Vehicle Class | Vehicle category |
| Vehicle Size | Vehicle-size category |

## Derived fields

- `Response Flag` — 1 if Response = Yes, otherwise 0
- `CLV Tier` — quartile-based Low / Mid-Low / Mid-High / High
- `Claim Band` — percentile-based Low / Moderate / High / Very High
- `Has Open Complaint` — 1 when Number of Open Complaints > 0
- `Claim to Annual Premium Proxy` — Total Claim Amount ÷ (Monthly Premium Auto × 12)

The last metric is a screening proxy only. It is **not** an actuarial loss ratio.
