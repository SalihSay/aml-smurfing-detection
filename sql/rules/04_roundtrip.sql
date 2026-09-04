-- ============================================================
-- AML Smurfing Detection
-- Rule: ROUND-TRIP
-- ============================================================

-- İş mantığı:
-- A -> B -> ... -> A
-- Para dolaşıp başlangıç hesabına geri dönüyorsa şüpheli.

CREATE OR REPLACE VIEW STG_AML.ROUNDTRIP_SCORE_VW AS
SELECT
    z.BASLANGIC_HESAP,
    z.SON_HESAP,
    z.HOP_SAYISI,
    z.ILK_TARIH,
    z.SON_TARIH
FROM STG_AML.LAYERING_SCORE_VW z
WHERE z.BASLANGIC_HESAP = z.SON_HESAP;