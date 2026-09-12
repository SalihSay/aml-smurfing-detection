-- ============================================================
-- AML Smurfing Detection
-- BI-Safe Account Masking
-- ============================================================

CREATE OR REPLACE VIEW DWH_AML.DIM_HESAP_MASKELI_VW AS
SELECT
    HESAP_SK,

    CASE
        WHEN LENGTH(HESAP_ID) <= 6 THEN HESAP_ID
        ELSE
            SUBSTR(HESAP_ID, 1, 3)
            || RPAD('*', LENGTH(HESAP_ID) - 6, '*')
            || SUBSTR(HESAP_ID, -3)
    END AS HESAP_ID_MASKELI,

    SUBE_KODU,
    RISK_SKORU,
    KARA_LISTE_FLAG,
    SCD_AKTIF_FLAG

FROM DWH_AML.DIM_HESAP;