SELECT DISTINCT
    a.CNES,
    b.FANTASIA
FROM 
    Dados.cnes.PF a
LEFT JOIN
    Dados.cnes.CADGER b
    ON a.CNES = b.CNES
WHERE    
    a.TP_UNID IN ('01', '02', '32', '40', '71', '72', '74') AND 
    a.CODUFMUN = '130080' AND
    COMPETEN = '202410'
ORDER BY
    a.CNES ASC;
