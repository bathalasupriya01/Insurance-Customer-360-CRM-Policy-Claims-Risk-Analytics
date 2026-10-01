-- Insurance Customer 360
-- PostgreSQL schema for the IBM Watson Marketing Customer Value dataset.
-- Import the CSV into this table after standardising column names to snake_case.

DROP TABLE IF EXISTS insurance_customer_360;

CREATE TABLE insurance_customer_360 (
    customer_id                     VARCHAR(20) PRIMARY KEY,
    state                           VARCHAR(30),
    customer_lifetime_value         NUMERIC(14,4),
    response                        VARCHAR(3),
    coverage                        VARCHAR(20),
    education                       VARCHAR(40),
    effective_to_date               DATE,
    employment_status               VARCHAR(40),
    gender                          VARCHAR(10),
    income                          NUMERIC(14,2),
    location_code                   VARCHAR(20),
    marital_status                  VARCHAR(20),
    monthly_premium_auto            NUMERIC(12,2),
    months_since_last_claim         INTEGER,
    months_since_policy_inception   INTEGER,
    number_of_open_complaints       INTEGER,
    number_of_policies              INTEGER,
    policy_type                     VARCHAR(40),
    policy                          VARCHAR(40),
    renew_offer_type                VARCHAR(20),
    sales_channel                   VARCHAR(30),
    total_claim_amount              NUMERIC(14,4),
    vehicle_class                   VARCHAR(40),
    vehicle_size                    VARCHAR(20)
);

CREATE INDEX idx_customer_state ON insurance_customer_360(state);
CREATE INDEX idx_customer_channel ON insurance_customer_360(sales_channel);
CREATE INDEX idx_customer_offer ON insurance_customer_360(renew_offer_type);
CREATE INDEX idx_customer_coverage ON insurance_customer_360(coverage);
CREATE INDEX idx_customer_vehicle ON insurance_customer_360(vehicle_class);
