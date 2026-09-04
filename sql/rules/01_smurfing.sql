-- ============================================================
-- AML Smurfing Detection
-- Rule: SMURFING
-- ============================================================

-- İş mantığı:
-- Bir hesaba 24 saat içinde 5+ farklı hesaptan para gelmesi
-- VE bu paranın 1 saat içinde hesaptan çıkması.

INSERT INTO STG_AML.E$_PARA_TRANSFERLERI
SELECT
    t.*,
    'SMURFING_PATTERN_DETECTED',
    s.MAX_FARKLI_GONDEREN,
    s.MIN_CIKIS_SAAT_FARKI
FROM STG_AML.STG_PARA_TRANSFERLERI t
JOIN STG_AML.SMURFING_SCORE_VW s
    ON t.ALICI_HESAP = s.HESAP
WHERE s.SMURFING_FLAG = 1;

-- Doğrulama:
-- SELECT COUNT(*)
-- FROM STG_AML.E$_PARA_TRANSFERLERI
-- WHERE HATA_SEBEBI = 'SMURFING_PATTERN_DETECTED';