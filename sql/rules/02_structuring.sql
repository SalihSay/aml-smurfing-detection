-- ============================================================
-- AML Smurfing Detection
-- Rule: STRUCTURING
-- ============================================================

-- İş mantığı:
-- Aynı gönderici hesaptan 24 saat içinde,
-- 10.000'in altında en az 3 işlem gerçekleşmesi.

CREATE OR REPLACE VIEW STG_AML.STRUCTURING_SCORE_VW AS
SELECT
    GONDEREN_HESAP AS HESAP,
    ISLEM_TARIHI,

    COUNT(*) OVER (
        PARTITION BY GONDEREN_HESAP
        ORDER BY ISLEM_TARIHI
        RANGE BETWEEN INTERVAL '24' HOUR PRECEDING AND CURRENT ROW
    ) AS ISLEM_SAYISI_24S,

    SUM(TUTAR) OVER (
        PARTITION BY GONDEREN_HESAP
        ORDER BY ISLEM_TARIHI
        RANGE BETWEEN INTERVAL '24' HOUR PRECEDING AND CURRENT ROW
    ) AS TOPLAM_TUTAR_24S

FROM STG_AML.STG_PARA_TRANSFERLERI
WHERE TIP IN ('CASH_IN', 'TRANSFER')
  AND TUTAR < 10000;


-- Şüpheli structuring pencerelerini görüntüle
SELECT
    HESAP,
    ISLEM_TARIHI,
    ISLEM_SAYISI_24S,
    TOPLAM_TUTAR_24S
FROM STG_AML.STRUCTURING_SCORE_VW
WHERE ISLEM_SAYISI_24S >= 3
ORDER BY ISLEM_TARIHI;