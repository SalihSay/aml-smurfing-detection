-- ============================================================
-- AML Smurfing Detection
-- Dimension: DIM_TARIH
-- ============================================================

CREATE TABLE DWH_AML.DIM_TARIH (
    TARIH_SK        NUMBER PRIMARY KEY,
    TARIH           DATE NOT NULL,
    YIL             NUMBER(4),
    CEYREK          NUMBER(1),
    AY              NUMBER(2),
    AY_ADI          VARCHAR2(20),
    HAFTA_GUNU      NUMBER(1),
    HAFTA_SONU_FLAG CHAR(1),
    IS_GUNU_FLAG    CHAR(1)
);

-- PaySim çalışma dönemini kapsayan tarih boyutu
INSERT INTO DWH_AML.DIM_TARIH (
    TARIH_SK,
    TARIH,
    YIL,
    CEYREK,
    AY,
    AY_ADI,
    HAFTA_GUNU,
    HAFTA_SONU_FLAG,
    IS_GUNU_FLAG
)
SELECT
    TO_NUMBER(TO_CHAR(d, 'YYYYMMDD')) AS TARIH_SK,
    d AS TARIH,
    EXTRACT(YEAR FROM d) AS YIL,
    TO_NUMBER(TO_CHAR(d, 'Q')) AS CEYREK,
    EXTRACT(MONTH FROM d) AS AY,
    TO_CHAR(d, 'MONTH', 'NLS_DATE_LANGUAGE=ENGLISH') AS AY_ADI,
    TO_NUMBER(TO_CHAR(d, 'D')) AS HAFTA_GUNU,
    CASE
        WHEN TO_CHAR(d, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')
             IN ('SAT', 'SUN')
        THEN 'Y'
        ELSE 'N'
    END AS HAFTA_SONU_FLAG,
    CASE
        WHEN TO_CHAR(d, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')
             IN ('SAT', 'SUN')
        THEN 'N'
        ELSE 'Y'
    END AS IS_GUNU_FLAG
FROM (
    SELECT DATE '2026-01-01' + LEVEL - 1 AS d
    FROM DUAL
    CONNECT BY LEVEL <= 60
);

COMMIT;