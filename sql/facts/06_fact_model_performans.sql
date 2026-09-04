-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_MODEL_PERFORMANS
-- ============================================================

-- AML kural performansının zaman içerisindeki takibi.
--
-- Ölçümler:
--   TOPLAM_ALARM
--   GERCEK_POZITIF
--   YANLIS_POZITIF
--   RECALL
--   PRECISION

INSERT INTO DWH_AML.FACT_MODEL_PERFORMANS (
    MODEL_SK,
    TARIH_SK,
    TOPLAM_ALARM,
    GERCEK_POZITIF,
    YANLIS_POZITIF,
    RECALL,
    PRECISION_DEGERI
)
SELECT
    (
        SELECT MODEL_SK
        FROM DWH_AML.DIM_MODEL_VERSIYON
        WHERE MODEL_ADI = 'Smurfing'
    ),

    TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')),

    COUNT(*) AS TOPLAM_ALARM,

    SUM(
        CASE
            WHEN t.IS_FRAUD = 1 THEN 1
            ELSE 0
        END
    ) AS GERCEK_POZITIF,

    SUM(
        CASE
            WHEN t.IS_FRAUD = 0 THEN 1
            ELSE 0
        END
    ) AS YANLIS_POZITIF,

    ROUND(
        SUM(
            CASE
                WHEN t.IS_FRAUD = 1 THEN 1
                ELSE 0
            END
        ) * 1.0
        /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM STG_AML.STG_PARA_TRANSFERLERI
                WHERE IS_FRAUD = 1
            ),
            0
        ),
        4
    ) AS RECALL,

    ROUND(
        SUM(
            CASE
                WHEN t.IS_FRAUD = 1 THEN 1
                ELSE 0
            END
        ) * 1.0
        /
        NULLIF(COUNT(*), 0),
        4
    ) AS PRECISION_DEGERI

FROM STG_AML.E$_PARA_TRANSFERLERI e

JOIN STG_AML.STG_PARA_TRANSFERLERI t
    ON e.GONDEREN_HESAP = t.GONDEREN_HESAP
   AND e.ALICI_HESAP = t.ALICI_HESAP
   AND e.ISLEM_TARIHI = t.ISLEM_TARIHI

WHERE e.HATA_SEBEBI = 'SMURFING_PATTERN_DETECTED';

COMMIT;