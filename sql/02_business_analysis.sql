-- Insurance Customer 360: CRM, Policy & Claims Risk Analytics
-- PostgreSQL business-analysis queries
-- Notes:
-- * response = marketing response, not churn/renewal outcome.
-- * claim_to_annual_premium_proxy is a screening metric only, not an actuarial loss ratio.

-- 1. Portfolio KPI overview
SELECT
    COUNT(*) AS customers,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct,
    ROUND(100.0 * AVG(CASE WHEN number_of_open_complaints > 0 THEN 1 ELSE 0 END), 2) AS open_complaint_customer_pct
FROM insurance_customer_360;

-- 2. Marketing response by sales channel
SELECT
    sales_channel,
    COUNT(*) AS customers,
    SUM(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END) AS responders,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv
FROM insurance_customer_360
GROUP BY sales_channel
ORDER BY response_rate_pct DESC;

-- 3. Marketing response by renewal offer
SELECT
    renew_offer_type,
    COUNT(*) AS customers,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_customer_360
GROUP BY renew_offer_type
ORDER BY response_rate_pct DESC;

-- 4. Offer x channel matrix
SELECT
    renew_offer_type,
    sales_channel,
    COUNT(*) AS customers,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct
FROM insurance_customer_360
GROUP BY renew_offer_type, sales_channel
HAVING COUNT(*) >= 50
ORDER BY response_rate_pct DESC, customers DESC;

-- 5. Customer-value quartiles
WITH ranked AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY customer_lifetime_value) AS clv_quartile
    FROM insurance_customer_360
)
SELECT
    clv_quartile,
    COUNT(*) AS customers,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(number_of_policies), 2) AS avg_policies
FROM ranked
GROUP BY clv_quartile
ORDER BY clv_quartile;

-- 6. High-value non-responders: CRM follow-up pool
WITH thresholds AS (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY customer_lifetime_value) AS clv_p75
    FROM insurance_customer_360
)
SELECT
    COUNT(*) AS high_value_nonresponders,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium
FROM insurance_customer_360 c
CROSS JOIN thresholds t
WHERE c.customer_lifetime_value >= t.clv_p75
  AND c.response = 'No';

-- 7. High-value single-policy customers: possible cross-sell review
WITH thresholds AS (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY customer_lifetime_value) AS clv_p75
    FROM insurance_customer_360
)
SELECT
    customer_id,
    customer_lifetime_value,
    number_of_policies,
    monthly_premium_auto,
    total_claim_amount,
    sales_channel,
    renew_offer_type,
    response
FROM insurance_customer_360 c
CROSS JOIN thresholds t
WHERE c.customer_lifetime_value >= t.clv_p75
  AND c.number_of_policies = 1
ORDER BY customer_lifetime_value DESC;

-- 8. Coverage economics
SELECT
    coverage,
    COUNT(*) AS customers,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct
FROM insurance_customer_360
GROUP BY coverage
ORDER BY avg_clv DESC;

-- 9. Policy-type mix
SELECT
    policy_type,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS portfolio_share_pct,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_customer_360
GROUP BY policy_type
ORDER BY customers DESC;

-- 10. Vehicle-class claim severity
SELECT
    vehicle_class,
    COUNT(*) AS customers,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv
FROM insurance_customer_360
GROUP BY vehicle_class
ORDER BY avg_claim_amount DESC;

-- 11. Vehicle class x coverage combinations
SELECT
    vehicle_class,
    coverage,
    COUNT(*) AS customers,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv
FROM insurance_customer_360
GROUP BY vehicle_class, coverage
HAVING COUNT(*) >= 20
ORDER BY avg_claim_amount DESC;

-- 12. Descriptive claim bands using portfolio percentiles
WITH p AS (
    SELECT
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_claim_amount) AS p50,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_claim_amount) AS p75,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_claim_amount) AS p90
    FROM insurance_customer_360
),
banded AS (
    SELECT
        c.*,
        CASE
            WHEN total_claim_amount <= p.p50 THEN 'Low'
            WHEN total_claim_amount <= p.p75 THEN 'Moderate'
            WHEN total_claim_amount <= p.p90 THEN 'High'
            ELSE 'Very High'
        END AS claim_band
    FROM insurance_customer_360 c
    CROSS JOIN p
)
SELECT
    claim_band,
    COUNT(*) AS customers,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(100.0 * AVG(CASE WHEN number_of_open_complaints > 0 THEN 1 ELSE 0 END), 2) AS complaint_customer_pct
FROM banded
GROUP BY claim_band
ORDER BY
    CASE claim_band
        WHEN 'Low' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'High' THEN 3
        WHEN 'Very High' THEN 4
    END;

-- 13. Claim-to-annual-premium screening proxy
SELECT
    customer_id,
    monthly_premium_auto,
    total_claim_amount,
    ROUND(total_claim_amount / NULLIF(monthly_premium_auto * 12, 0), 3) AS claim_to_annual_premium_proxy,
    vehicle_class,
    coverage
FROM insurance_customer_360
ORDER BY claim_to_annual_premium_proxy DESC
LIMIT 100;

-- 14. Complaints by channel
SELECT
    sales_channel,
    COUNT(*) AS customers,
    SUM(CASE WHEN number_of_open_complaints > 0 THEN 1 ELSE 0 END) AS customers_with_open_complaints,
    ROUND(100.0 * AVG(CASE WHEN number_of_open_complaints > 0 THEN 1 ELSE 0 END), 2) AS complaint_customer_pct,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct
FROM insurance_customer_360
GROUP BY sales_channel
ORDER BY complaint_customer_pct DESC;

-- 15. State portfolio view
SELECT
    state,
    COUNT(*) AS customers,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct
FROM insurance_customer_360
GROUP BY state
ORDER BY customers DESC;

-- 16. Location-code view
SELECT
    location_code,
    COUNT(*) AS customers,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct
FROM insurance_customer_360
GROUP BY location_code
ORDER BY avg_claim_amount DESC;

-- 17. Policy tenure bands
SELECT
    CASE
        WHEN months_since_policy_inception < 12 THEN '<1 year'
        WHEN months_since_policy_inception < 36 THEN '1-3 years'
        WHEN months_since_policy_inception < 60 THEN '3-5 years'
        ELSE '5+ years'
    END AS tenure_band,
    COUNT(*) AS customers,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(100.0 * AVG(CASE WHEN response = 'Yes' THEN 1 ELSE 0 END), 2) AS response_rate_pct
FROM insurance_customer_360
GROUP BY tenure_band
ORDER BY
    CASE tenure_band
        WHEN '<1 year' THEN 1
        WHEN '1-3 years' THEN 2
        WHEN '3-5 years' THEN 3
        ELSE 4
    END;

-- 18. Months-since-last-claim bands
SELECT
    CASE
        WHEN months_since_last_claim <= 6 THEN '0-6 months'
        WHEN months_since_last_claim <= 12 THEN '7-12 months'
        WHEN months_since_last_claim <= 24 THEN '13-24 months'
        ELSE '25+ months'
    END AS recency_band,
    COUNT(*) AS customers,
    ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount,
    ROUND(AVG(monthly_premium_auto), 2) AS avg_monthly_premium,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv
FROM insurance_customer_360
GROUP BY recency_band
ORDER BY recency_band;

-- 19. Top customers by CLV within each state
WITH ranked AS (
    SELECT
        state,
        customer_id,
        customer_lifetime_value,
        RANK() OVER (PARTITION BY state ORDER BY customer_lifetime_value DESC) AS state_clv_rank
    FROM insurance_customer_360
)
SELECT *
FROM ranked
WHERE state_clv_rank <= 10
ORDER BY state, state_clv_rank;

-- 20. Channel performance versus portfolio average
WITH channel AS (
    SELECT
        sales_channel,
        COUNT(*) AS customers,
        AVG(CASE WHEN response = 'Yes' THEN 1.0 ELSE 0.0 END) AS response_rate
    FROM insurance_customer_360
    GROUP BY sales_channel
),
portfolio AS (
    SELECT AVG(CASE WHEN response = 'Yes' THEN 1.0 ELSE 0.0 END) AS portfolio_response_rate
    FROM insurance_customer_360
)
SELECT
    c.sales_channel,
    c.customers,
    ROUND(100.0 * c.response_rate, 2) AS response_rate_pct,
    ROUND(100.0 * p.portfolio_response_rate, 2) AS portfolio_rate_pct,
    ROUND(100.0 * (c.response_rate - p.portfolio_response_rate), 2) AS percentage_point_gap
FROM channel c
CROSS JOIN portfolio p
ORDER BY percentage_point_gap DESC;
