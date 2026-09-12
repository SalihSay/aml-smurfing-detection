-- ============================================================
-- AML Smurfing Detection
-- Rule: SMURFING
-- ============================================================

-- İş mantığı:
-- Bir hesaba 24 saat içinde en az 5 farklı hesaptan para gelmesi
-- ve hesaptan çıkışın 1 saat içinde gerçekleşmesi.

SELECT
    HESAP,
    MAX_FARKLI_GONDEREN,
    MIN_CIKIS_SAAT_FARKI,
    SMURFING_FLAG
FROM STG_AML.SMURFING_SCORE_VW
WHERE SMURFING_FLAG = 1;