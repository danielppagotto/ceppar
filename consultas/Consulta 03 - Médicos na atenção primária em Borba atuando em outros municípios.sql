WITH CPFs_BORBA AS (
    SELECT DISTINCT CPF_PROF
    FROM Dados.cnes.PF
    WHERE 
        TP_UNID IN ('01', '02', '32', '40', '71', '72', '74') AND 
        CODUFMUN = '130080' AND 
        (CBO LIKE '225%' OR 
        CBO = '2231F9')
)
SELECT 
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
    a.TP_UNID, -- Tipo de unidade de saúde
    CASE 
        WHEN a.TP_UNID IN ('01', '02', '32', '40', '71', '72', '74') THEN 'Primária'
        WHEN a.TP_UNID IN ('04', '15', '20', '21', '22', '36', '39', '42', '61', '62', '69', '70', '73', '79', '83') THEN 'Secundária'
        WHEN a.TP_UNID IN ('05', '07') THEN 'Terciária'
        ELSE 'OUTROS/MÚLTIPLOS' 
    END AS nivel_atencao, -- Nível de atenção do estabelecimento de saúde
    b.FANTASIA, -- Nome do estabelecimento de saúde
    CASE
        WHEN a.CBO LIKE '225%' OR 
        a.CBO = '2231F9' THEN 'Médico' -- Código CBO de médicos
    END CATEGORIA, -- Profissão
    a.CPF_PROF, -- CPF 
    a.NomePROF -- Nome do profissional
FROM 
    Dados.cnes.PF a
LEFT JOIN 
    Dados.CNES.CADGER b
    ON a.CNES = b.CNES
LEFT JOIN 
    "Open Analytics Layer".Territorial."Hierarquia completa dos municípios" c
    ON a.CODUFMUN = CAST(c.cod_municipio AS CHARACTER)
WHERE
    a.CPF_PROF IN (SELECT CPF_PROF FROM CPFs_BORBA) AND
    (a.CBO LIKE '225%' OR 
    a.CBO = '2231F9');
