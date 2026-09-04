-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_MODEL_VERSIYON
-- ============================================================

CREATE TABLE DWH_AML.DIM_MODEL_VERSIYON (
    MODEL_SK             NUMBER PRIMARY KEY,
    MODEL_ADI            VARCHAR2(100),
    VERSIYON             VARCHAR2(30),
    ESIK_DEGERLERI       VARCHAR2(500),
    GECERLILIK_BASLANGIC DATE,
    GECERLILIK_BITIS     DATE
);