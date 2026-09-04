-- ============================================================
-- AML Smurfing Detection
-- Rule: ROUND AMOUNT
-- ============================================================

-- İş mantığı:
-- 10.000 ve üzerindeki yuvarlak tutarlı işlemler
-- risk sinyali olarak işaretlenir.

CREATE OR REPLACE VIEW STG_AML.ROUND_AMOUNT_VW AS
SELECT
    GONDEREN_HESAP,
    ISLEM_TARIHI,
    TUTAR
FROM STG_AML.STG_PARA_TRANSFERLERI
WHERE MOD(TUTAR, 1000) = 0
  AND TUTAR >= 10000;