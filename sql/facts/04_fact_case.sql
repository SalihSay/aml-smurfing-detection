-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_CASE
-- Alarm -> Case workflow
-- ============================================================

-- E$ tablosundaki benzersiz alarm kayıtlarından case oluşturulur.

INSERT INTO DWH_AML.FACT_CASE (
    HESAP_SK,
    MUSTERI_SK,
    CALISAN_SK,
    DURUM_SK,
    MODEL_SK,
    ACILIS_TARIH_SK,
    ALARM_TIPI,
    ONCELIK,
    ILISKILI_TUTAR
)
SELECT
    dh.HESAP_SK,
    dm.MUSTERI_SK,

    -- Basit round-robin analist ataması
    CASE
        WHEN MOD(dh.HESAP_SK, 2) = 0
        THEN (
            SELECT CALISAN_SK
            FROM DWH_AML.DIM_CALISAN
            WHERE CALISAN_ID = 'EMP001'
        )
        ELSE (
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

    (
        SELECT MODEL_SK
        FROM DWH_AML.DIM_MODEL_VERSIYON
        WHERE MODEL_ADI = 'Smurfing'
    ),

    TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')),

    e.HATA_SEBEBI,

    CASE
        WHEN e.TUTAR > 100000 THEN 'Kritik'
        WHEN e.TUTAR > 50000  THEN 'Yüksek'
        ELSE 'Orta'
    END,

    e.TUTAR

FROM STG_AML.E$_PARA_TRANSFERLERI e

JOIN DWH_AML.DIM_HESAP dh
    ON e.ALICI_HESAP = dh.HESAP_ID
   AND dh.SCD_AKTIF_FLAG = 'Y'

JOIN DWH_AML.DIM_MUSTERI dm
    ON e.ALICI_HESAP = dm.MUSTERI_ID
   AND dm.SCD_AKTIF_FLAG = 'Y';


-- ============================================================
-- SAR'a giden kritik/yüksek öncelikli case simülasyonu
-- ============================================================

UPDATE DWH_AML.FACT_CASE
SET
    DURUM_SK = (
        SELECT DURUM_SK
        FROM DWH_AML.DIM_CASE_DURUM
        WHERE DURUM_KODU = 'SAR_GONDERILDI'
    ),
    KAPANIS_TARIH_SK =
        TO_NUMBER(TO_CHAR(SYSDATE + 2, 'YYYYMMDD'))
WHERE ONCELIK IN ('Kritik', 'Yüksek')
  AND MOD(CASE_SK, 3) = 0;

COMMIT;