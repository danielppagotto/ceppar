-- Relação de médicos da Atenção Primária à Saúde em Borba durante os anos e meses

SELECT DISTINCT
    SUBSTR(a.COMPETEN, 1, 4) AS ano, -- Data (ex: 202401) = janeiro de 2024
    SUBSTR(a.COMPETEN, 5, 2) AS mes, -- Data (ex: 202401) = janeiro de 2024
    c.uf_sigla, -- UF
    CASE
        WHEN LENGTH(a.CODUFMUN) = 7 THEN SUBSTR(a.CODUFMUN, 1, 6)
        WHEN a.CODUFMUN LIKE '53%' THEN '530010' 
        ELSE a.CODUFMUN
    END AS cod_ibge, -- Código do município
    c.municipio_pad, -- Nome do município
    c.latitude,
    c.longitude,  
    a.CNES, -- Código CNES
    b.FANTASIA, -- Nome do estabelecimento de saúde
    a.TP_UNID, -- Tipo de unidade de saúde
    CASE
        WHEN 
            a.CBO LIKE '225%' OR  
            a.CBO LIKE '2231%'
        THEN 'Médico' -- Código CBO de médicos
        ELSE CBO
    END CATEGORIA, -- Profissão
    a.CPF_PROF, -- CPF 
    a.NOMEPROF -- Nome do profissional
FROM 
    Dados.cnes.PF a
LEFT JOIN
    Dados.cnes.CADGER b
    ON a.CNES = b.CNES
LEFT JOIN 
    "Open Analytics Layer".Territorial."Hierarquia completa dos municípios" c
    ON a.CODUFMUN = CAST(c.cod_municipio AS CHARACTER)
WHERE    
    a.CODUFMUN = '130080' AND -- Código IBGE de Borba
    a.TP_UNID IN ('01', '02', '32', '40', '71', '72', '74') AND -- Código das unidades de atenção primária em saúde 
    (CBO LIKE '225%' OR 
    CBO LIKE '2231%'
    ) -- Código CBO de médicos
ORDER BY
    a.CNES ASC;
