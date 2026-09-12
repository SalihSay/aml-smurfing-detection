-- ============================================================
-- AML Smurfing Detection
-- Rule: LAYERING
-- ============================================================

-- İş mantığı:
-- A -> B -> C -> D gibi 3 veya daha fazla hop içeren
-- transfer zincirlerinin 6 saatlik pencere içinde izlenmesi.

CREATE OR REPLACE VIEW STG_AML.LAYERING_SCORE_VW AS
WITH RECURSIVE_ZINCIR (
    BASLANGIC_HESAP,
    MEVCUT_HESAP,
    TUTAR,
    HOP_SAYISI,
    ILK_TARIH,
    SON_TARIH
) AS (
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

    SELECT
        z.BASLANGIC_HESAP,
        t.ALICI_HESAP,
        t.TUTAR,
        z.HOP_SAYISI + 1,
        z.ILK_TARIH,
        t.ISLEM_TARIHI
    FROM RECURSIVE_ZINCIR z
    JOIN STG_AML.STG_PARA_TRANSFERLERI t
        ON t.GONDEREN_HESAP = z.MEVCUT_HESAP
       AND t.ISLEM_TARIHI > z.SON_TARIH
       AND t.ISLEM_TARIHI <= z.ILK_TARIH + (6.0 / 24)
    WHERE t.TIP = 'TRANSFER'
      AND z.HOP_SAYISI < 5
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