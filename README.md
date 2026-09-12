<img width="1192" height="302" alt="Ekran görüntüsü 2026-09-12 131251" src="https://github.com/user-attachments/assets/9e271f88-bac7-456b-a455-e4114f7f9317" />

# AML Smurfing Detection — Data Warehouse & BI

**End-to-end Data Warehouse & Business Intelligence project built with Oracle 19c, ODI 12c and Metabase OSS.**

A portfolio-oriented AML analytics platform built around **6.36M+ financial transactions**, combining dimensional modeling, ETL, SCD Type 2, data quality, rule-based analytics, network analysis and operational BI.

> **Business problem:** Detect suspicious transaction patterns and transform them into an analyzable workflow from **transaction → alarm → case → SAR → BI reporting**.

---

## 📊 Project at a Glance

| Metric | Result |
|---|---:|
| Financial Transactions | **6,362,620** |
| Active Accounts | **9,073,900** |
| AML Typologies | **6** |
| Cases | **3,508** |
| SAR Filings | **175** |
| DQ Checks | **11 / 11 PASS** |
| Synthetic Smurfing Test Precision | **100%** |

### Core Technology

`Oracle 19c` · `ODI 12c` · `SQL` · `PaySim` · `Metabase OSS` · `Docker` · `Git/GitHub`

---

## 🏗️ Architecture

<img width="1192" height="302" alt="Ekran görüntüsü 2026-09-12 131251" src="https://github.com/user-attachments/assets/9e271f88-bac7-456b-a455-e4114f7f9317" />

The architecture follows an end-to-end data flow:

**PaySim CSV → Oracle Staging → ODI 12c ETL → Oracle DWH → AML Rules → Alarm / Case / SAR → Graph Analysis → Metabase BI**

---

## 🏢 1. Data Warehouse

The warehouse was designed using a **star-schema-oriented dimensional model**.

### Dimensions

- 7 dimension tables
- Surrogate key approach
- Foreign key relationships
- Historical tracking with SCD Type 2
- `DIM_HESAP` and `DIM_MUSTERI` maintain historical versions

### Facts

- `FACT_PARA_TRANSFERLERI`
- `FACT_CASE`
- `FACT_SAR_FILING`
- `FACT_MODEL_PERFORMANS`

The model separates transactional data, operational case management and analytical performance metrics.

---

## ⚙️ 2. ETL with ODI 12c

The ETL layer was implemented with **Oracle Data Integrator 12c**.

### Pipeline

```text
PaySim CSV
    ↓
Oracle Staging
    ↓
ODI ETL / Mappings
    ↓
CKM Validation
    ↓
AML Rule Processing
    ↓
Oracle Data Warehouse
    ↓
BI / Analytics

ODI was used for:

Data movement
Mappings
Lookups
Dimension loading
Fact loading
CKM-based validation
Integration between staging and DWH layers
ODI Portfolio Evidence

The repository contains the exported ODI Designer project:

odi-exports/

🚨 3. AML Rule Engine

Six AML typologies were implemented at the Oracle / ODI CKM layer.

Smurfing

Detects patterns where:

Multiple distinct senders transfer money to the same target account
Transactions occur within a 24-hour window
A short-time outgoing transaction follows the incoming transfers

Scoring view:

STG_AML.SMURFING_SCORE_VW

Structuring

Detects repeated transactions below a defined threshold within a 24-hour window.

Scoring view:

STG_AML.STRUCTURING_SCORE_VW

Layering

Analyzes multi-hop transaction chains using recursive transfer analysis.

Scoring view:

STG_AML.LAYERING_SCORE_VW

Round Trip

Identifies transaction paths returning to the originating account.

A → B → ... → A
Dormant Account Reactivation

Detects significant transactions following long periods of account inactivity.

Round Amount

Identifies high-value round-number transactions as an additional risk signal.

🕸️ 4. Network Risk Analysis

Transaction relationships were transformed into a graph-oriented analytical layer.

GRAPH_EDGE_LIST

Represents account-to-account transaction relationships.

GRAPH_METRICS

Calculates:

Incoming connection count
Outgoing connection count

for active accounts.

This allows suspicious accounts to be evaluated together with their surrounding transaction network rather than only as isolated transactions.

Gephi was intentionally excluded from the final architecture.

Network analysis is handled through the Oracle graph-oriented layer and Metabase reporting.

🗂️ 5. Operational AML Workflow

The project does not stop at detecting suspicious transactions.

The operational flow is:

Transaction
     ↓
AML Rule
     ↓
Alarm
     ↓
FACT_CASE
     ↓
Case Investigation
     ↓
SAR Filing
Case Distribution
Status	Cases
ACIK	2,283
INCELEMEDE	700
KAPALI	350
SAR_GONDERILDI	175
SAR Validation
175 SAR records
175 distinct cases
1,581,043,000 total related amount
0 orphan cases
0 case/SAR mismatches
📈 6. Model Performance
Baseline DWH Output
Metric	Result
Total Alerts	3,508
True Positives	287
False Positives	3,221
Recall	3.49%
Precision	8.18%

The result is reported without artificially improving the metrics.

The high false-positive rate highlights the need for further AML threshold tuning and feature engineering.

This is an important part of the project because the objective is not to present artificially strong model metrics, but to demonstrate how analytical results can be measured and monitored inside the DWH/BI architecture.

🧪 7. Synthetic Rule Validation

A controlled Smurfing scenario was injected to validate the rule engine.

Test Scenario
6 distinct sender accounts
5,000 per sender
Same target account
Transactions within a 24-hour window
Short-time outgoing transaction
Result

The Smurfing pattern was detected successfully.

Metric	Result
Precision	100%
False Positive	0

After validation, the synthetic records were removed and the baseline dataset was restored.

Note: The 100% precision result belongs to the controlled synthetic validation scenario and should not be interpreted as the baseline production performance of the rule.

✅ 8. Data Quality & Audit

Data quality and ETL monitoring were implemented through:

DWH_AML.DQ_LOG
DWH_AML.ETL_AUDIT_LOG
Validation Coverage
Orphan keys
Duplicate business keys
Null checks
Row counts
Referential integrity
Graph integrity
Case/SAR consistency
ETL execution status
Final Validation

11 / 11 DQ checks PASS

🔐 9. KVKK / Data Masking

A masked BI view was created to prevent raw account identifiers from being unnecessarily exposed to BI users.

DWH_AML.DIM_HESAP_MASKELI_VW

Example
C170123456379
      ↓
C17*******379

The BI layer is designed to use the masked representation whenever raw account identifiers are not required.

📊 10. BI Dashboards

Dashboards were built in Metabase OSS for different operational perspectives.

AML — Uyum

Compliance-focused monitoring.

AML — Risk

Risk and suspicious activity analysis.

AML — Şube

Branch-level analytical view.

Model Performance

Monitoring of:

Alert volume
True positives
False positives
Recall
Precision
Dashboard Evidence

Screenshots are available under:

metabase/screenshots/

🧠 11. Technical Challenges
SCD Type 2

Maintaining historical account states while preserving the current active record.

Large-Volume SQL

Working with more than 6.36M transactions in the staging layer.

Recursive Transfer Analysis

Following multi-hop transaction chains for layering detection.

Rule Validation

Creating controlled synthetic scenarios to verify that AML rules detect the intended behavioral pattern.

Data Quality

Validating fact/dimension relationships and preventing orphan records from propagating into analytical layers.

CDC / Journalizing

ODI Journalizing was explored as an advanced option.

Because PaySim is a static file-based source, a real source CDC scenario does not exist in this project, so CDC was intentionally excluded from the main flow.

📁 12. Repository Structure
aml-smurfing-detection/
│
├── README.md
│
├── docs/
│   ├── PORTFOLIO_CHECKLIST.md
│   └── architecture/
│       ├── architecture.mmd
│       └── Architecture.png
│
├── metabase/
│   └── screenshots/
│
├── odi-exports/
│
└── sql/
    ├── dimensions/
    ├── facts/
    ├── rules/
    ├── graph/
    ├── dq/
    ├── masking/
    ├── monitoring/
    └── workflow/
🗃️ 13. SQL Organization

The SQL layer is separated by responsibility:

sql/
├── dimensions/     → Dimension definitions / SCD
├── facts/          → Fact loading logic
├── rules/          → AML rule logic
├── graph/          → Graph metrics / validation
├── dq/             → Data quality checks
├── masking/        → BI masking
├── monitoring/     → Performance / operational monitoring
└── workflow/       → Case / SAR analytical queries

This structure keeps business rules, warehouse loading logic and monitoring queries separated.

🔮 14. Future Improvements

Potential next steps include:

AML threshold tuning
False-positive reduction
Additional feature engineering
Real KYC/customer source integration
Real-time CDC source
Advanced graph centrality / community detection
Model drift monitoring
Hybrid rule + ML detection
Risk-based case prioritization
📚 15. Portfolio Evidence

The repository contains real outputs from the development environment:

ODI Designer project XML export
Architecture diagram
Metabase dashboard screenshots
SQL implementation and validation scripts

No fabricated screenshots or placeholder tool exports are used.

🎯 Project Outcome

This project demonstrates an end-to-end Data Warehouse & Business Intelligence architecture built around a real-world analytical problem.

Data Engineering

Oracle · ODI · ETL · SQL

Data Warehousing

Star Schema · Fact/Dimension Modeling · SCD Type 2

Analytics

AML Rules · Graph Analysis · Performance Metrics

Data Governance

Data Quality · ETL Audit · Data Masking

Business Intelligence

Metabase · Operational Dashboards

The key objective was not simply to identify suspicious transactions, but to build an analytical platform capable of carrying data through the complete lifecycle:

Transaction → Detection → Alarm → Case → SAR → BI
