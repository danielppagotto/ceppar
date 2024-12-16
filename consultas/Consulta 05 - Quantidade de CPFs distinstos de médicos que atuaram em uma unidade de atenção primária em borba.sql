SELECT 
    COUNT(DISTINCT a.CPF_PROF) AS qtd_cpfs_unicos -- Contagem de CPFs únicos
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
    ); -- Código CBO dos médicos
