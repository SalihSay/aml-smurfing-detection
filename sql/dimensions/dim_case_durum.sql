-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_CASE_DURUM
-- ============================================================

CREATE TABLE DWH_AML.DIM_CASE_DURUM (
    DURUM_SK        NUMBER PRIMARY KEY,
    DURUM_KODU      VARCHAR2(30),
    DURUM_ACIKLAMA  VARCHAR2(200)
);