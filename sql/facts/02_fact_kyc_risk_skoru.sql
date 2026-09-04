-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_KYC_RISK_SKORU
-- ============================================================

-- KYC risk skorunun zaman içerisindeki snapshot'ı.
-- Kaynak: müşteri/risk verisi
-- Boyut lookup'ları: DIM_MUSTERI + DIM_TARIH

-- ODI tarafında bu işlem bir Interface olarak uygulanır.
-- IKM: Oracle Incremental Update

-- Örnek yükleme mantığı:

INSERT INTO DWH_AML.FACT_KYC_RISK_SKORU
SELECT
    dm.MUSTERI_SK,
    dt.TARIH_SK,
    dm.KYC_RISK_SEVIYESI
FROM DWH_AML.DIM_MUSTERI dm
JOIN DWH_AML.DIM_TARIH dt
    ON dt.TARIH = DATE '2026-01-01';

COMMIT;