WITH CTE_PrimeiraAtuacao AS (
    SELECT 
        a.CPF_PROF, -- CPF do profissional
        MIN(a.COMPETEN) AS primeira_competencia -- Data da primeira atuação em CNES de atenção primária em Borba
    FROM 
        Dados.cnes.PF a
    WHERE 
        a.CODUFMUN = '130080' AND -- Código IBGE de Borba
        a.TP_UNID IN ('01', '02', '32', '40', '71', '72', '74') AND -- Apenas atenção primária
        (CBO LIKE '225%' OR 
        CBO = '2231F9'
        ) -- Código CBO dos médicos
    GROUP BY 
        a.CPF_PROF
),
CTE_TodasAtuacoes AS (
    SELECT DISTINCT
        a.COMPETEN, -- Competência
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
        a.CPF_PROF IN (
            SELECT 
                CPF_PROF 
            FROM 
                CTE_PrimeiraAtuacao
        ) AND -- Apenas profissionais que atuaram em Borba
        (CBO LIKE '225%' OR 
        CBO = '2231F9'
        ) -- Código CBO dos médicos    
),
CTE_Filtrada AS (
    SELECT 
        t.*
    FROM 
        CTE_TodasAtuacoes t
    JOIN 
        CTE_PrimeiraAtuacao p
    ON 
        t.CPF_PROF = p.CPF_PROF
    WHERE 
        t.COMPETEN >= p.primeira_competencia -- Mantém apenas as informações a partir da primeira atuação
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
    CTE_Filtrada
ORDER BY 
    CPF_PROF, 
    COMPETEN;
