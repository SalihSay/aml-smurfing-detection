-- ============================================================
-- AML Smurfing Detection
-- Rule: ROUND AMOUNT
-- ============================================================

-- İş mantığı:
-- 10.000 ve üzerindeki, 1.000'in katı olan
-- yuvarlak tutarlı işlemler risk sinyali olarak izlenir.

CREATE OR REPLACE VIEW STG_AML.ROUND_AMOUNT_VW AS
SELECT
    GONDEREN_HESAP,
    ALICI_HESAP,
    ISLEM_TARIHI,
    TUTAR
FROM STG_AML.STG_PARA_TRANSFERLERI
WHERE MOD(TUTAR, 1000) = 0
  AND TUTAR >= 10000;


-- Şüpheli işlemleri görüntüle
SELECT
    GONDEREN_HESAP,
    ALICI_HESAP,
    ISLEM_TARIHI,
    TUTAR
FROM STG_AML.ROUND_AMOUNT_VW
ORDER BY ISLEM_TARIHI;