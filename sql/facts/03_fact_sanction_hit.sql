-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_SANCTION_HIT
-- ============================================================

-- Yaptırım / kara liste eşleşmelerinin fact tablosuna aktarılması.
--
-- Boyut lookup'ları:
--   DIM_HESAP
--   DIM_TARIH
--   DIM_ULKE

-- ODI Interface üzerinden yüklenir.
-- Kaynak: sanction hit / kara liste eşleşme verisi

INSERT INTO DWH_AML.FACT_SANCTION_HIT
SELECT
    dh.HESAP_SK,
    du.ULKE_SK,
    dt.TARIH_SK
FROM DWH_AML.DIM_HESAP dh
JOIN DWH_AML.DIM_ULKE du
    ON du.OFAC_SANCTIONED_FLAG = 'Y'
JOIN DWH_AML.DIM_TARIH dt
    ON dt.TARIH = DATE '2026-01-01';

COMMIT;