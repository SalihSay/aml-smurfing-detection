-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_ULKE
-- ============================================================

CREATE TABLE DWH_AML.DIM_ULKE (
    ULKE_SK              NUMBER PRIMARY KEY,
    ULKE_KODU            VARCHAR2(10),
    ULKE_ADI             VARCHAR2(100),
    FATF_RISK_KATEGORI   VARCHAR2(30),
    OFAC_SANCTIONED_FLAG CHAR(1)
);