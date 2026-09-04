-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_MUSTERI
-- ============================================================

CREATE TABLE DWH_AML.DIM_MUSTERI (
    MUSTERI_SK          NUMBER PRIMARY KEY,
    MUSTERI_ID          VARCHAR2(30),
    MUSTERI_TIPI        VARCHAR2(20),
    KYC_RISK_SEVIYESI   VARCHAR2(20),
    ULKE_KODU           VARCHAR2(10),
    SCD_BASLANGIC       DATE,
    SCD_BITIS           DATE,
    SCD_AKTIF_FLAG      CHAR(1)
);