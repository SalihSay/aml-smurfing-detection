-- ============================================================
-- AML Smurfing Detection
-- Rule: LAYERING
-- ============================================================

-- İş mantığı:
-- Para A -> B -> C -> D şeklinde 3+ hop'ta aktarılıyorsa
-- ve zincir 6 saat içerisinde gerçekleşiyorsa şüpheli kabul edilir.

CREATE OR REPLACE VIEW STG_AML.LAYERING_SCORE_VW AS

WITH RECURSIVE_ZINCIR (
    BASLANGIC_HESAP,
    MEVCUT_HESAP,
    TUTAR,
    HOP_SAYISI,
    ILK_TARIH,
    SON_TARIH
) AS (

    -- İlk transfer
    SELECT
        GONDEREN_HESAP,
        ALICI_HESAP,
        TUTAR,
        1,
        ISLEM_TARIHI,
        ISLEM_TARIHI
    FROM STG_AML.STG_PARA_TRANSFERLERI
    WHERE TIP = 'TRANSFER'

    UNION ALL

    -- Zincirin devamı
    SELECT
        z.BASLANGIC_HESAP,
        t.ALICI_HESAP,
        t.TUTAR,
        z.HOP_SAYISI + 1,
        z.ILK_TARIH,
        t.ISLEM_TARIHI

    FROM RECURSIVE_ZINCIR z

    JOIN STG_AML.STG_PARA_TRANSFERLERI t
        ON z.MEVCUT_HESAP = t.GONDEREN_HESAP
       AND t.ISLEM_TARIHI > z.SON_TARIH
       AND t.ISLEM_TARIHI <= z.ILK_TARIH + (6.0 / 24)
       AND z.HOP_SAYISI < 5

    WHERE t.TIP = 'TRANSFER'
)

SELECT
    BASLANGIC_HESAP,
    MEVCUT_HESAP AS SON_HESAP,
    TUTAR,
    HOP_SAYISI,
    ILK_TARIH,
    SON_TARIH
FROM RECURSIVE_ZINCIR
WHERE HOP_SAYISI >= 3;