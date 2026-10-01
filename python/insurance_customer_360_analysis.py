"""
Insurance Customer 360: CRM, Policy & Claims Risk Analytics

Expected raw file:
data/raw/WA_Fn-UseC_-Marketing-Customer-Value-Analysis.csv

This script:
1) validates source data
2) standardises names
3) creates CRM/customer-value segments
4) creates descriptive claim bands
5) exports dashboard-ready summaries
6) trains an interpretable marketing-response classifier

Important:
- Response is a marketing response, not a churn/renewal label.
- There is no fraud label.
- Claim bands are descriptive monitoring, not a live underwriting score.
"""

from pathlib import Path
import re
import json
import numpy as np
import pandas as pd

from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    roc_auc_score,
    average_precision_score,
)

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw" / "WA_Fn-UseC_-Marketing-Customer-Value-Analysis.csv"
OUT = ROOT / "data" / "processed"
OUT.mkdir(parents=True, exist_ok=True)

def snake_case(s: str) -> str:
    s = re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_").lower()
    return s

df = pd.read_csv(RAW)
original_columns = df.columns.tolist()
df.columns = [snake_case(c) for c in df.columns]

# Data-quality checks
quality = {
    "rows": int(len(df)),
    "columns": int(df.shape[1]),
    "missing_cells": int(df.isna().sum().sum()),
    "exact_duplicate_rows": int(df.duplicated().sum()),
}
print("Data quality:", quality)

# Dates
df["effective_to_date"] = pd.to_datetime(df["effective_to_date"], errors="coerce")

# CRM features
df["response_flag"] = (df["response"].str.lower() == "yes").astype(int)
df["clv_tier"] = pd.qcut(
    df["customer_lifetime_value"],
    q=4,
    labels=["Low", "Mid-Low", "Mid-High", "High"],
    duplicates="drop",
)

# Claims-monitoring features
p50 = df["total_claim_amount"].quantile(0.50)
p75 = df["total_claim_amount"].quantile(0.75)
p90 = df["total_claim_amount"].quantile(0.90)

df["claim_band"] = pd.cut(
    df["total_claim_amount"],
    bins=[-np.inf, p50, p75, p90, np.inf],
    labels=["Low", "Moderate", "High", "Very High"],
    include_lowest=True,
)

# Screening proxy only; not an actuarial loss ratio
df["claim_to_annual_premium_proxy"] = (
    df["total_claim_amount"] / (df["monthly_premium_auto"] * 12)
)

df["has_open_complaint"] = (df["number_of_open_complaints"] > 0).astype(int)
df["high_value_nonresponder"] = (
    (df["clv_tier"] == "High") & (df["response_flag"] == 0)
).astype(int)

# Dashboard-ready summaries
def group_summary(col):
    g = (
        df.groupby(col, dropna=False)
        .agg(
            customers=("customer", "count"),
            response_rate=("response_flag", "mean"),
            avg_clv=("customer_lifetime_value", "mean"),
            avg_claim=("total_claim_amount", "mean"),
            avg_monthly_premium=("monthly_premium_auto", "mean"),
            complaint_rate=("has_open_complaint", "mean"),
        )
        .reset_index()
    )
    return g

for col in [
    "sales_channel", "renew_offer_type", "coverage", "policy_type",
    "state", "vehicle_class", "location_code", "clv_tier", "claim_band"
]:
    group_summary(col).to_csv(OUT / f"{col}_summary.csv", index=False)

offer_channel = (
    df.groupby(["renew_offer_type", "sales_channel"])
    .agg(
        customers=("customer", "count"),
        response_rate=("response_flag", "mean"),
        avg_clv=("customer_lifetime_value", "mean"),
        avg_claim=("total_claim_amount", "mean"),
    )
    .reset_index()
)
offer_channel.to_csv(OUT / "offer_channel_summary.csv", index=False)

# Marketing-response model
# Objective: demonstrate modelling workflow, not claim causal impact.
target = "response_flag"

# Avoid customer ID, raw response text and direct target-derived fields.
numeric_features = [
    "customer_lifetime_value",
    "income",
    "monthly_premium_auto",
    "months_since_last_claim",
    "months_since_policy_inception",
    "number_of_open_complaints",
    "number_of_policies",
    "total_claim_amount",
]

categorical_features = [
    "state",
    "coverage",
    "education",
    "employmentstatus",
    "gender",
    "location_code",
    "marital_status",
    "policy_type",
    "policy",
    "renew_offer_type",
    "sales_channel",
    "vehicle_class",
    "vehicle_size",
]

X = df[numeric_features + categorical_features].copy()
y = df[target]

preprocess = ColumnTransformer(
    transformers=[
        ("num", StandardScaler(), numeric_features),
        ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_features),
    ]
)

model = Pipeline(
    steps=[
        ("preprocess", preprocess),
        ("classifier", LogisticRegression(max_iter=2000, class_weight="balanced")),
    ]
)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.25, random_state=42, stratify=y
)

model.fit(X_train, y_train)
pred = model.predict(X_test)
prob = model.predict_proba(X_test)[:, 1]

metrics = {
    "roc_auc": float(roc_auc_score(y_test, prob)),
    "average_precision": float(average_precision_score(y_test, prob)),
    "confusion_matrix": confusion_matrix(y_test, pred).tolist(),
    "classification_report": classification_report(y_test, pred, output_dict=True),
}
(OUT / "model_metrics.json").write_text(json.dumps(metrics, indent=2))

print(json.dumps(metrics, indent=2))
print("Processed outputs written to:", OUT)
