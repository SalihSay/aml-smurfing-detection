-- ============================================================
-- AML Smurfing Detection
-- Rule: ROUND-TRIP
-- ============================================================

-- İş mantığı:
-- Para A -> B -> ... -> A şeklinde başlangıç hesabına
-- geri dönüyorsa round-trip şüphesi oluşturur.

CREATE OR REPLACE VIEW STG_AML.ROUNDTRIP_SCORE_VW AS
SELECT
    z.BASLANGIC_HESAP,
    z.SON_HESAP,
    z.HOP_SAYISI,
    z.ILK_TARIH,
    z.SON_TARIH
FROM STG_AML.LAYERING_SCORE_VW z
WHERE z.BASLANGIC_HESAP = z.SON_HESAP;


-- Şüpheli round-trip zincirlerini görüntüle
SELECT
    BASLANGIC_HESAP,
    SON_HESAP,
    HOP_SAYISI,
    ILK_TARIH,
    SON_TARIH
FROM STG_AML.ROUNDTRIP_SCORE_VW
ORDER BY ILK_TARIH;