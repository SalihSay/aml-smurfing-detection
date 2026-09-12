-- ============================================================
-- AML Smurfing Detection
-- Model Performance Monitoring
-- ============================================================

SELECT
    mv.MODEL_ADI,
    mv.VERSIYON,
    p.TARIH_SK,
    p.TOPLAM_ALARM,
    p.GERCEK_POZITIF,
    p.YANLIS_POZITIF,
    p.RECALL,
    p.PRECISION_DEGERI
FROM DWH_AML.FACT_MODEL_PERFORMANS p
JOIN DWH_AML.DIM_MODEL_VERSIYON mv
    ON mv.MODEL_SK = p.MODEL_SK
ORDER BY
    p.TARIH_SK,
    p.MODEL_SK;