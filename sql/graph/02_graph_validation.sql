-- ============================================================
-- AML Smurfing Detection
-- Graph Validation
-- ============================================================

-- Active accounts represented in graph metrics
SELECT COUNT(*) AS ACTIVE_ACCOUNTS
FROM DWH_AML.GRAPH_METRICS;


-- Incoming / outgoing connection statistics
SELECT
    COUNT(CASE
        WHEN GELEN_BAGLANTI_SAYISI > 0 THEN 1
    END) AS ACCOUNTS_WITH_INCOMING,

    SUM(GELEN_BAGLANTI_SAYISI) AS TOTAL_INCOMING_CONNECTIONS,

    COUNT(CASE
        WHEN GIDEN_BAGLANTI_SAYISI > 0 THEN 1
    END) AS ACCOUNTS_WITH_OUTGOING,

    SUM(GIDEN_BAGLANTI_SAYISI) AS TOTAL_OUTGOING_CONNECTIONS
FROM DWH_AML.GRAPH_METRICS;


-- Orphan graph edges
SELECT COUNT(*) AS ORPHAN_GRAPH_EDGES
FROM DWH_AML.GRAPH_EDGE_LIST e
WHERE NOT EXISTS (
    SELECT 1
    FROM DWH_AML.DIM_HESAP h
    WHERE h.HESAP_SK = e.SOURCE_NODE
)
OR NOT EXISTS (
    SELECT 1
    FROM DWH_AML.DIM_HESAP h
    WHERE h.HESAP_SK = e.TARGET_NODE
);