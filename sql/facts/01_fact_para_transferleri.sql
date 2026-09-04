-- ============================================================
-- AML Smurfing Detection
-- Fact: FACT_PARA_TRANSFERLERI
-- ============================================================

-- Star Schema fact yükleme mantığı.
--
-- Gönderen ve alıcı için aynı DIM_HESAP iki farklı rolde
-- kullanılır:
--   1. GONDEREN_HESAP_SK
--   2. ALICI_HESAP_SK
--
-- Bu yapıya Role-Playing Dimension denir.

INSERT INTO DWH_AML.FACT_PARA_TRANSFERLERI
SELECT
    -- tarih dimension lookup
    dt.TARIH_SK,

    -- gönderen hesap dimension lookup
    dh_gonderen.HESAP_SK,

    -- alıcı hesap dimension lookup
    dh_alici.HESAP_SK,

    t.TIP,
    t.TUTAR,
    t.IS_FRAUD,
    t.IS_FLAGGED_FRAUD,
    t.ISLEM_TARIHI

FROM STG_AML.STG_PARA_TRANSFERLERI t

JOIN DWH_AML.DIM_HESAP dh_gonderen
    ON t.GONDEREN_HESAP = dh_gonderen.HESAP_ID
   AND dh_gonderen.SCD_AKTIF_FLAG = '1'

JOIN DWH_AML.DIM_HESAP dh_alici
    ON t.ALICI_HESAP = dh_alici.HESAP_ID
   AND dh_alici.SCD_AKTIF_FLAG = '1'

JOIN DWH_AML.DIM_TARIH dt
    ON TRUNC(t.ISLEM_TARIHI) = dt.TARIH;

COMMIT;


-- Referential integrity kontrolü
SELECT COUNT(*)
FROM DWH_AML.FACT_PARA_TRANSFERLERI f
WHERE NOT EXISTS (
    SELECT 1
    FROM DWH_AML.DIM_HESAP d
    WHERE d.HESAP_SK = f.GONDEREN_HESAP_SK
);