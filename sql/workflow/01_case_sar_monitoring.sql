-- ============================================================
-- AML Smurfing Detection
-- Case -> SAR Workflow Monitoring
-- ============================================================

SELECT
    c.CASE_SK,
    c.ALARM_TIPI,
    c.ONCELIK,
    d.DURUM_KODU,
    c.ILISKILI_TUTAR,
    s.CASE_SK AS SAR_CASE_SK,
    s.SAR_DURUM
FROM DWH_AML.FACT_CASE c
JOIN DWH_AML.DIM_CASE_DURUM d
    ON d.DURUM_SK = c.DURUM_SK
LEFT JOIN DWH_AML.FACT_SAR_FILING s
    ON s.CASE_SK = c.CASE_SK
ORDER BY c.CASE_SK;