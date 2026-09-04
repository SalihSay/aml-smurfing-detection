-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_SAR_FILING
-- ============================================================

-- SAR gönderilmiş case'lerden düzenleyici bildirim kaydı oluşturulur.

INSERT INTO DWH_AML.FACT_SAR_FILING (
    CASE_SK,
    MUSTERI_SK,
    GONDERIM_TARIH_SK,
    ILISKILI_TOPLAM_TUTAR,
    SAR_DURUM
)
SELECT
    CASE_SK,
    MUSTERI_SK,
    KAPANIS_TARIH_SK,
    ILISKILI_TUTAR,
    'Gönderildi'
FROM DWH_AML.FACT_CASE
WHERE DURUM_SK = (
    SELECT DURUM_SK
    FROM DWH_AML.DIM_CASE_DURUM
    WHERE DURUM_KODU = 'SAR_GONDERILDI'
);

COMMIT;