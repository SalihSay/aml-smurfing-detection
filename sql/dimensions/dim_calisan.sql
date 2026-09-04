-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_CALISAN
-- ============================================================

CREATE TABLE DWH_AML.DIM_CALISAN (
    CALISAN_SK      NUMBER PRIMARY KEY,
    CALISAN_ID      VARCHAR2(30),
    AD_SOYAD        VARCHAR2(100),
    ROL             VARCHAR2(50),
    SUBE_KODU       VARCHAR2(20)
);