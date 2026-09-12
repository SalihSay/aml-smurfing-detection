-- ============================================================
-- AML Smurfing Detection
-- Rule: DORMANT ACCOUNT REACTIVATION
-- ============================================================

-- İş mantığı:
-- 90 günden uzun süre işlem yapmayan bir hesabın
-- 50.000 üzerindeki işlemle yeniden aktif hale gelmesi.

CREATE OR REPLACE VIEW STG_AML.DORMANT_REACTIVATION_VW AS
WITH SON_ISLEMLER AS (
    SELECT
        GONDEREN_HESAP AS HESAP,
        ISLEM_TARIHI,
        TUTAR,
        LAG(ISLEM_TARIHI) OVER (
            PARTITION BY GONDEREN_HESAP
            ORDER BY ISLEM_TARIHI
        ) AS ONCEKI_ISLEM
    FROM STG_AML.STG_PARA_TRANSFERLERI
)
SELECT
    HESAP,
    ISLEM_TARIHI,
    TUTAR,
    ISLEM_TARIHI - ONCEKI_ISLEM AS BOSLUK_GUN
FROM SON_ISLEMLER
WHERE ONCEKI_ISLEM IS NOT NULL
  AND ISLEM_TARIHI - ONCEKI_ISLEM > 90
  AND TUTAR > 50000;


-- Şüpheli dormant reactivation kayıtları
SELECT
    HESAP,
    ISLEM_TARIHI,
    TUTAR,
    BOSLUK_GUN
FROM STG_AML.DORMANT_REACTIVATION_VW
ORDER BY ISLEM_TARIHI;