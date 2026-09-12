-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_MODEL_PERFORMANS
-- ============================================================

INSERT INTO DWH_AML.FACT_MODEL_PERFORMANS (
    MODEL_PERFORMANS_SK,
    MODEL_SK,
    TARIH_SK,
    TOPLAM_ALARM,
    GERCEK_POZITIF,
    YANLIS_POZITIF,
    RECALL,
    PRECISION_DEGERI
)
SELECT
    DWH_AML.SEQ_MODEL_PERFORMANS.NEXTVAL,
    e.MODEL_SK,
    dt.TARIH_SK,

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
        )
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
        )
        / NULLIF(COUNT(*), 0),
        4
    ) AS PRECISION_DEGERI

FROM STG_AML.E$_PARA_TRANSFERLERI e

JOIN STG_AML.STG_PARA_TRANSFERLERI t
    ON t.GONDEREN_HESAP = e.GONDEREN_HESAP
   AND t.ALICI_HESAP = e.ALICI_HESAP
   AND t.ISLEM_TARIHI = e.ISLEM_TARIHI

JOIN DWH_AML.DIM_TARIH dt
    ON dt.TARIH = TRUNC(e.ISLEM_TARIHI)

WHERE e.HATA_SEBEBI = 'SMURFING_PATTERN_DETECTED'

GROUP BY
    e.MODEL_SK,
    dt.TARIH_SK;


COMMIT;


-- Current model performance
SELECT
    MODEL_SK,
    TARIH_SK,
    TOPLAM_ALARM,
    GERCEK_POZITIF,
    YANLIS_POZITIF,
    RECALL,
    PRECISION_DEGERI
FROM DWH_AML.FACT_MODEL_PERFORMANS
ORDER BY TARIH_SK, MODEL_SK;