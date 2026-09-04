-- ============================================================
-- AML Smurfing Detection
-- Rule: DORMANT ACCOUNT REACTIVATION
-- ============================================================

-- İş mantığı:
-- 90 günden uzun süre işlem yapmayan hesabın
-- 50.000 üzeri işlemle tekrar aktive olması.

CREATE OR REPLACE VIEW STG_AML.DORMANT_REACTIVATION_VW AS

WITH son_islemler AS (
    SELECT
        GONDEREN_HESAP AS HESAP,
        ISLEM_TARIHI,

        LAG(ISLEM_TARIHI) OVER (
            PARTITION BY GONDEREN_HESAP
            ORDER BY ISLEM_TARIHI
        ) AS ONCEKI_ISLEM,

        TUTAR

    FROM STG_AML.STG_PARA_TRANSFERLERI
)

SELECT
    HESAP,
    ISLEM_TARIHI,
    TUTAR,
    (ISLEM_TARIHI - ONCEKI_ISLEM) AS BOSLUK_GUN

FROM son_islemler

WHERE (ISLEM_TARIHI - ONCEKI_ISLEM) > 90
  AND TUTAR > 50000;