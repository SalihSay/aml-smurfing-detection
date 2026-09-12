-- ============================================================
-- AML Smurfing Detection
-- Graph Metrics Refresh
-- ============================================================

TRUNCATE TABLE DWH_AML.GRAPH_METRICS;

INSERT INTO DWH_AML.GRAPH_METRICS (
    HESAP_SK,
    GELEN_BAGLANTI_SAYISI,
    GIDEN_BAGLANTI_SAYISI
)
SELECT
    h.HESAP_SK,
    NVL(g.GELEN, 0),
    NVL(g.GIDEN, 0)
FROM DWH_AML.DIM_HESAP h
LEFT JOIN (
    SELECT
        NODE,
        SUM(GELEN) AS GELEN,
        SUM(GIDEN) AS GIDEN
    FROM (
        SELECT
            TARGET_NODE AS NODE,
            1 AS GELEN,
            0 AS GIDEN
        FROM DWH_AML.GRAPH_EDGE_LIST

        UNION ALL

        SELECT
            SOURCE_NODE AS NODE,
            0 AS GELEN,
            1 AS GIDEN
        FROM DWH_AML.GRAPH_EDGE_LIST
    )
    GROUP BY NODE
) g
    ON g.NODE = h.HESAP_SK
WHERE h.SCD_AKTIF_FLAG = '1';

COMMIT;