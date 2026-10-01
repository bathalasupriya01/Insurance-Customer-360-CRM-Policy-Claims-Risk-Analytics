# Insurance Customer 360: CRM, Policy & Claims Risk Analytics

An end-to-end portfolio project using the **IBM Watson Marketing Customer Value Analysis** sample dataset to answer practical insurance customer, CRM, policy and claims questions.

The project is designed to demonstrate the type of work expected across **Data Analyst, BI Analyst, CRM Analyst, Customer Analyst, Insurance Analyst and Risk Analyst** roles.

## Business problem

An auto insurer wants a clearer view of its customer base and marketing response while keeping an eye on claims-heavy customer segments. The analysis focuses on four practical questions:

1. Which customer and policy segments are most valuable?
2. Which offer/channel combinations are associated with stronger marketing response?
3. Where are the main high-value customer engagement opportunities?
4. Which policy/vehicle segments show higher observed claim amounts and deserve deeper risk review?

This is an **analytical portfolio exercise**, not a live underwriting, pricing or fraud model.

## Dataset

- Dataset: IBM Watson Marketing Customer Value Analysis
- Records: **9,134**
- Fields: **24**
- Date coverage in `Effective To Date`: **1 Jan 2011 – 28 Feb 2011**
- Missing values found: **0**
- Exact duplicate rows found: **0**
- Marketing responses: **1,308 Yes / 7,826 No**
- Overall response rate: **14.32%**

The raw IBM sample file is **not bundled** in this repository. Place the source file at:

`data/raw/WA_Fn-UseC_-Marketing-Customer-Value-Analysis.csv`

The project code expects the original 24-column schema.

## Tools

- **SQL / PostgreSQL** — customer, policy, CRM and claims analysis
- **Python / Pandas / Scikit-learn** — data quality, feature engineering, segmentation and marketing-response modelling
- **Power BI** — report design, DAX measures and dashboard specification
- **Excel** — portfolio-ready dashboard preview and analysis tables

## Key findings from the source data

### CRM and offer performance
- Overall marketing response is **14.32%**.
- **Agent** is the strongest sales channel in the sample at **19.15% response**, compared with 11.45% for Branch, 10.88% for Call Center and 11.77% for Web.
- **Offer2** has the highest observed response rate at **23.38%**.
- The strongest large offer/channel combination is **Offer2 + Agent**, with **31.90% observed response** across 978 customers.
- These are observational results. They do **not** prove that the offer or channel caused the higher response.

### Customer value
- Average Customer Lifetime Value (CLV): **$8,004.94**
- Median CLV: **$5,780.18**
- Top-quartile CLV starts at approximately **$8,962.17**.
- There are **1,936 high-value customers in the top CLV quartile who did not respond** to the campaign, representing a useful CRM targeting pool for further controlled testing.

### Claims and risk monitoring
- Average observed claim amount: **$434.09**
- Top 10% of claim amounts begin at approximately **$773.43**.
- The very-high-claim band averages **$1,066.42** per customer in the sample.
- Premium coverage customers have the highest average CLV (**$10,895.60**) but also a higher average claim amount (**$651.39**).
- Luxury vehicle segments have very high average claim amounts, but their sample sizes are small, so they should be treated as a review signal rather than a stand-alone pricing conclusion.

## Business recommendations

1. **Test, do not assume.** Use controlled campaign tests to validate whether Offer2 delivered through Agent channels genuinely improves response for comparable customer segments.
2. **Prioritise high-value non-responders.** Build a CRM follow-up audience from high-CLV customers who did not respond, then test message, offer and channel variations.
3. **Monitor claim-heavy segments.** Review high-claim vehicle/coverage combinations and investigate whether the differences persist after controlling for customer mix and exposure.
4. **Add complaint follow-up.** About **20.6%** of customers have at least one open complaint. Track complaint resolution alongside future campaign/renewal outcomes if later data becomes available.
5. **Do not use this sample for live pricing.** The dataset is old, sample-based and lacks exposure, incurred-loss development, fraud labels and regulatory context needed for real underwriting or pricing decisions.

## Dashboard structure

The report is intentionally split into focused pages rather than one crowded screen.

1. **Executive Overview** — customers, CLV, response, premium, claims, complaints
2. **CRM & Customer Insights** — value tiers, offers, channels, high-value non-responders
3. **Policy & Claims** — coverage, policy type, vehicle class and claim severity
4. **Claims Risk Review** — claim bands and claim-heavy segments with clear limitations

## Repository structure

```text
Insurance_Customer_360_CRM_Claims_Risk_Analytics/
├── README.md
├── requirements.txt
├── .gitignore
├── data/
│   ├── README_DATA.md
│   └── processed/
├── sql/
│   ├── 01_schema.sql
│   └── 02_business_analysis.sql
├── python/
│   └── insurance_customer_360_analysis.py
├── notebooks/
│   └── 01_insurance_customer_360.ipynb
├── powerbi/
│   ├── POWER_BI_BUILD_GUIDE.md
│   ├── DAX_Measures.txt
│   └── Insurance_Customer_360_Theme.json
├── excel/
│   └── Insurance_Customer_360_Analytics.xlsx
└── docs/
    ├── business_questions.md
    ├── data_dictionary.md
    ├── key_findings.md
    ├── cv_bullets.md
    ├── linkedin_project.md
    └── interview_talking_points.md
```

## Important analytical limitations

- `Response` is a **marketing response** field, not a confirmed renewal or churn outcome.
- `Total Claim Amount` is an observed amount; the dataset does not contain a fraud label.
- The project therefore uses **claims risk monitoring**, not “fraud detection”.
- The claim-to-premium metric in the analysis is only a **portfolio screening proxy**. It is not an actuarial loss ratio because exposure periods and incurred-loss development are not available.
- Results are associations from a sample dataset and should not be interpreted as causal effects.

## Data source

IBM Cognos Analytics documentation includes the **Customer analysis** data module within its insurance samples. The widely circulated Watson Marketing Customer Value Analysis CSV contains the 9,134 × 24 customer/policy/claims schema used here.

For portfolio publication, cite IBM as the dataset source and keep the raw file out of the public repository unless the exact redistribution terms for the copy you obtained clearly permit it.
