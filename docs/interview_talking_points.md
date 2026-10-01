# Interview Talking Points

## 30-second explanation

“I built an Insurance Customer 360 project using the IBM Watson Marketing Customer Value sample. I wanted one project that showed CRM, insurance and risk-analysis skills together. I used SQL and Python to analyse customer value, campaign response, policy mix and claims. I then structured the findings into executive, CRM, policy and claims-risk dashboard views. I was careful not to call the response field churn or the claims analysis fraud, because the dataset does not support those conclusions.”

## Why this dataset?
It contains customer, policy, premium, channel, offer, complaints and claims fields in one sample, so it supports a coherent business story instead of disconnected charts.

## Strongest CRM finding
Overall response is 14.32%. Agent has the highest channel response at 19.15%, while Offer2 has 23.38%. Offer2 + Agent reaches 31.90% in the sample.

## What would you do next in a real company?
Run a controlled test on comparable customer groups rather than assuming the historical association is causal.

## Strongest customer-value finding
1,936 customers are in the top CLV quartile but did not respond. That is a useful CRM audience for different offer/channel testing.

## Strongest risk finding
The top 10% of claims begin around $773, and the very-high-claim group averages about $1,066. Luxury vehicle categories show high observed claims, but they are small segments, so I would not make a pricing decision from that alone.

## Why no fraud model?
There is no fraud label. Calling high claims “fraud” would be misleading.

## Why is the claim-to-premium metric only a proxy?
The sample does not provide aligned exposure periods, earned premium or incurred-loss development, so it is not a proper loss ratio.

## What would improve the project?
Longitudinal policy history, actual renewals/lapses, claim counts and dates, earned exposure, incurred losses, fraud outcomes, acquisition cost and campaign-test assignment.
