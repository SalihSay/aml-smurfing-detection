-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_CASE
-- Alarm -> Case workflow
-- ============================================================

INSERT INTO DWH_AML.FACT_CASE (
    CASE_SK,
    HESAP_SK,
    MUSTERI_SK,
    CALISAN_SK,
    DURUM_SK,
    MODEL_SK,
    ACILIS_TARIH_SK,
    KAPANIS_TARIH_SK,
    ALARM_TIPI,
    ONCELIK,
    ILISKILI_TUTAR
)
SELECT
    DWH_AML.SEQ_FACT_CASE.NEXTVAL,
    dh.HESAP_SK,
    dm.MUSTERI_SK,

    CASE
        WHEN MOD(dh.HESAP_SK, 2) = 0 THEN
            (
                SELECT CALISAN_SK
                FROM DWH_AML.DIM_CALISAN
                WHERE CALISAN_ID = 'EMP001'
            )
        ELSE
            (
                SELECT CALISAN_SK
                FROM DWH_AML.DIM_CALISAN
                WHERE CALISAN_ID = 'EMP002'
            )
    END,

    (
        SELECT DURUM_SK
        FROM DWH_AML.DIM_CASE_DURUM
        WHERE DURUM_KODU = 'ACIK'
    ),

    e.MODEL_SK,

    dt.TARIH_SK,

    NULL,

    e.HATA_SEBEBI,

    CASE
        WHEN e.TUTAR > 100000 THEN 'Kritik'
        WHEN e.TUTAR > 50000 THEN 'Yuksek'
        ELSE 'Orta'
    END,

    e.TUTAR

FROM STG_AML.E$_PARA_TRANSFERLERI e

JOIN DWH_AML.DIM_HESAP dh
    ON dh.HESAP_ID = e.ALICI_HESAP
   AND dh.SCD_AKTIF_FLAG = '1'

JOIN DWH_AML.DIM_MUSTERI dm
    ON dm.MUSTERI_ID = e.ALICI_HESAP
   AND dm.SCD_AKTIF_FLAG = 'Y'

JOIN DWH_AML.DIM_TARIH dt
    ON dt.TARIH = TRUNC(e.ISLEM_TARIHI);


COMMIT;


-- Case distribution
SELECT
    d.DURUM_KODU,
    COUNT(*) AS CASE_SAYISI
FROM DWH_AML.FACT_CASE c
JOIN DWH_AML.DIM_CASE_DURUM d
    ON d.DURUM_SK = c.DURUM_SK
GROUP BY d.DURUM_KODU
ORDER BY CASE_SAYISI DESC;