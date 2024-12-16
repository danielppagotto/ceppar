WITH CTE_Profissionais AS (
    SELECT DISTINCT
        SUBSTR(a.COMPETEN, 1, 4) AS ano, -- Ano
        SUBSTR(a.COMPETEN, 5, 2) AS mes, -- Mês
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
            WHEN a.CBO LIKE '225%' OR 
            a.CBO = '2231F9' THEN 'Médico' -- Código CBO de médicos
            ELSE a.CBO
        END CATEGORIA, -- Profissão
        a.CPF_PROF, -- CPF 
        a.NOMEPROF, -- Nome do profissional
        ROW_NUMBER() OVER (PARTITION BY a.CPF_PROF, a.CNES ORDER BY a.COMPETEN ASC) AS ordem -- Ordena por competência
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
        CBO = '2231F9'
        ) -- Código CBO dos médicos
)

SELECT 
    ano, 
    mes, 
    uf_sigla, 
    cod_ibge, 
    municipio_pad, 
    latitude, 
    longitude, 
    CNES, 
    FANTASIA, 
    TP_UNID, 
    CATEGORIA, 
    CPF_PROF, 
    NOMEPROF
FROM 
    CTE_Profissionais
WHERE 
    ordem = 1 -- Mantém apenas a primeira aparição de cada profissional em cada CNES
ORDER BY 
    CPF_PROF, 
    CNES;
