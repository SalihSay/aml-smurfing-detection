-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_HESAP
-- Slowly Changing Dimension Type 2
-- ============================================================

CREATE TABLE DWH_AML.DIM_HESAP (
    HESAP_SK          NUMBER PRIMARY KEY,
    HESAP_ID          VARCHAR2(30),
    SUBE_KODU         VARCHAR2(20),
    RISK_SKORU        NUMBER,
    KARA_LISTE_FLAG   CHAR(1),
    SCD_BASLANGIC     DATE,
    SCD_BITIS         DATE,
    SCD_AKTIF_FLAG    CHAR(1)
);