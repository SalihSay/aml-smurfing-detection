-- ============================================================
-- AML Smurfing Detection
-- Case / SAR Monitoring
-- ============================================================


-- Case workload
SELECT
    d.DURUM_KODU,
    COUNT(*) AS CASE_SAYISI
FROM DWH_AML.FACT_CASE c
JOIN DWH_AML.DIM_CASE_DURUM d
    ON d.DURUM_SK = c.DURUM_SK
GROUP BY d.DURUM_KODU
ORDER BY CASE_SAYISI DESC;


-- SAR summary
SELECT
    COUNT(*) AS SAR_SAYISI,
    COUNT(DISTINCT CASE_SK) AS DISTINCT_CASE_SAYISI,
    SUM(ILISKILI_TOPLAM_TUTAR) AS TOPLAM_SAR_TUTARI
FROM DWH_AML.FACT_SAR_FILING;


-- SAR -> CASE consistency
SELECT COUNT(*) AS SAR_CASE_MISMATCH
FROM DWH_AML.FACT_SAR_FILING s
LEFT JOIN DWH_AML.FACT_CASE c
    ON c.CASE_SK = s.CASE_SK
WHERE c.CASE_SK IS NULL;