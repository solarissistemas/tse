--================================================================
INSTALL spatial;
LOAD spatial;

CREATE SCHEMA tse;

SELECT * FROM tse.voto LIMIT 10;
select version();

SELECT l.nr_zona, count(DISTINCT l.nr_secao) FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_latitude <> -1 GROUP BY l.nr_zona ORDER BY 2;

SELECT l.nr_zona, l.nr_secao, l.nm_bairro, l.nr_latitude, l.nr_longitude FROM tse.local l WHERE l.cd_municipio = 64777 ORDER BY 1, l.nr_longitude;


SELECT DISTINCT l.nr_zona, l.nm_bairro, l.nr_latitude, l.nr_longitude FROM tse.local l WHERE l.cd_municipio = 64777 ORDER BY 1, l.nr_longitude;


SELECT DISTINCT l.nr_zona, l.nr_longitude || ' ' || l.nr_latitude AS coord 
  FROM tse.local l 
 WHERE l.cd_municipio = 64777 
   AND l.nr_zona = 278 
   AND l.nr_latitude <> -1
 ORDER BY 1, l.nr_longitude;




SELECT ST_Area('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'::GEOMETRY);



SELECT l.nr_zona, l.nm_bairro FROM tse.local l WHERE l.cd_municipio = 64777 ORDER BY 1;

SELECT l.nr_zona, count(*) FROM tse.local l WHERE l.cd_municipio = 64777 GROUP BY l.nr_zona ORDER BY 1;


SELECT l.nr_zona, l.nr_secao, l.nr_latitude, l.nr_longitude FROM tse.local l WHERE l.cd_municipio = 64777;

SELECT v.sg_partido AS partido, sum(v.qt_votos_nominais_validos) AS total
             FROM tse.voto v 
            WHERE v.cd_municipio = 64777 
              AND v.cd_cargo = 11 
            GROUP BY v.sg_partido;

/*
*
* PL			213212
* PT			62031
* PSB			3801
* REPUBLICANOS	129056
* SOLIDARIEDADE	191188
* PDT			42034 
* 
* */


WITH l AS (SELECT DISTINCT l.nr_zona, l.nm_bairro AS bairro, l.nr_latitude AS lat, l.nr_longitude AS lon 
             FROM tse.local l 
            WHERE l.cd_municipio = 64777 
              AND l.nr_latitude <> -1
            ORDER BY 1, l.nr_longitude),
     v AS (SELECT v.sg_partido AS partido, v.nr_zona, sum(v.qt_votos_nominais_validos) AS total
             FROM tse.voto v 
            WHERE v.cd_municipio = 64777 
              AND v.cd_cargo = 11 
            GROUP BY v.sg_partido, v.nr_zona)
SELECT v.partido, 
       v.total, 
       l.bairro, 
       l.lon, 
       l.lat, 
       CASE v.partido 
        WHEN  'PL' THEN 'green' 
		WHEN  'PT' THEN 'red'
		WHEN  'PSB' THEN 'yellow'
		WHEN  'REPUBLICANOS' THEN 'blue'
		WHEN  'SOLIDARIEDADE' THEN 'orange'
		WHEN  'PDT' THEN 'gray'
		ELSE 'black'
	   END AS color 
   FROM l INNER JOIN v ON (l.nr_zona = v.nr_zona);




WITH l AS (SELECT DISTINCT l.nr_zona, l.nm_bairro AS bairro, l.nr_latitude AS lat, l.nr_longitude AS lon 
                     FROM tse.local l 
                    WHERE l.cd_municipio = 64777 
                      AND l.nr_latitude <> -1
                    ORDER BY 1, l.nr_longitude),
     v AS (SELECT v.sg_partido AS partido, v.nr_zona, sum(v.qt_votos_nominais_validos) AS total
                     FROM tse.voto v 
                    WHERE v.cd_municipio = 64777 
                      AND v.cd_cargo = 11 
                    GROUP BY v.sg_partido, v.nr_zona),
     t AS (SELECT v.partido, 
               v.total, 
               --l.bairro, 
               l.lon, 
               l.lat, 
               l.nr_zona as zona,
               CASE v.partido 
                WHEN  'PL' THEN 'green' 
        		WHEN  'PT' THEN 'red'
        		WHEN  'PSB' THEN 'yellow'
        		WHEN  'REPUBLICANOS' THEN 'blue'
        		WHEN  'SOLIDARIEDADE' THEN 'orange'
        		WHEN  'PDT' THEN 'white'
        		ELSE 'black'
        	   END AS color 
           FROM l INNER JOIN v ON (l.nr_zona = v.nr_zona))
--SELECT partido, sum(total) FROM t GROUP BY partido;
SELECT * FROM t WHERE lon = -46.40006295 ORDER BY total desc;


SELECT 213212+62031+3801+129056+191188+42034; 
641.322


WITH l AS (SELECT l.nr_zona AS zona, l.nm_bairro AS bairro, l.nr_latitude AS lat, l.nr_longitude AS lon 
                     FROM tse.local l 
                    WHERE l.cd_municipio = 64777 
                      AND l.nr_latitude <> -1
                    ORDER BY 1, l.nr_longitude),
     l1 AS (SELECT zona, avg(lat) AS lat, avg(lon) AS lon FROM l GROUP BY zona),
     v AS (SELECT v.sg_partido AS partido, v.nr_zona AS zona, sum(v.qt_votos_nominais_validos) AS total
             FROM tse.voto v 
            WHERE v.cd_municipio = 64777 
              AND v.cd_cargo = 11 
            GROUP BY v.sg_partido, v.nr_zona),
     geom_partido AS (SELECT 'PL' AS partido, .5 AS fator UNION ALL
                      SELECT 'PT', .4 UNION ALL
        		      SELECT 'PSB', .3 UNION ALL
        		      SELECT 'REPUBLICANOS', .2 UNION ALL
        		      SELECT 'SOLIDARIEDADE', .1 UNION ALL
        		      SELECT 'PDT', -.1),
     t AS (SELECT v.partido, 
                  v.total,  
                  (SELECT l1.lon FROM l1 WHERE l1.zona = v.zona) AS lon, 
                  (SELECT l1.lat FROM l1 WHERE l1.zona = v.zona) AS lat, 
                  v.zona,
                  CASE v.partido 
                    WHEN 'PL' THEN 'green' 
        		    WHEN 'PT' THEN 'red'
        		    WHEN 'PSB' THEN 'yellow'
        		    WHEN 'REPUBLICANOS' THEN 'blue'
        		    WHEN 'SOLIDARIEDADE' THEN 'orange'
        		    WHEN 'PDT' THEN 'white'
        		ELSE 'black'
        	   END AS color 
           FROM v)
SELECT t.partido, t.total, (t.lon+gp.fator) AS lon, (t.lat+gp.fator) AS lat, t.zona, t.color FROM t INNER JOIN geom_partido gp ON (t.partido = gp.partido) ORDER BY 2 desc;


SELECT * FROM tse.voto;

SELECT l.nr_zona, l.nr_secao, l.nm_bairro, count(*) FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_zona = 176 AND l.nr_turno = 1 GROUP BY l.nr_zona, l.nr_secao, l.nm_bairro HAVING count(*) > 1 ORDER BY 1;

SELECT DISTINCT l.nm_bairro FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_zona = 176 AND l.nr_turno = 1 ORDER BY 1;

CREATE TABLE tse.bairro_zona ()

SELECT count(DISTINCT l.nr_zona) FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_turno = 1;


CREATE TABLE tse.zona_bairro AS SELECT DISTINCT l.nr_zona, '' AS bairro FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_turno = 1;



SELECT DISTINCT l.nm_bairro FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_zona = 394 AND l.nr_turno = 1 ORDER BY 1;

SELECT * FROM tse.zona_bairro;

UPDATE tse.zona_bairro SET bairro = 'BONSUCESSO' WHERE nr_zona = 394;



-- Análise Tabular
WITH l AS (SELECT DISTINCT l.nr_zona, l.nm_bairro AS bairro 
             FROM tse.local l 
            WHERE l.cd_municipio = 64777 
              AND l.nr_turno = 1
              AND l.nr_latitude <> -1
            ORDER BY 1),
     v AS (SELECT v.sg_partido AS partido, v.nr_zona, sum(v.qt_votos_nominais_validos) AS total
             FROM tse.voto v 
            WHERE v.cd_municipio = 64777 
              AND v.cd_cargo = 11 
            GROUP BY v.sg_partido, v.nr_zona)
SELECT v.*, (SELECT count(DISTINCT l.bairro) FROM l WHERE l.nr_zona = v.nr_zona) bairro FROM v ORDER BY v.nr_zona;



WITH v AS (SELECT v.sg_partido AS partido, v.nr_zona, sum(v.qt_votos_nominais_validos) AS total
             FROM tse.voto v 
            WHERE v.cd_municipio = 64777 
              AND v.cd_cargo = 11 
            GROUP BY v.sg_partido, v.nr_zona)
SELECT v.partido, (SELECT z.bairro FROM tse.zona_bairro z WHERE z.nr_zona = v.nr_zona) bairro, v.total
  FROM v 
 ORDER BY 2, v.total desc;


SELECT v.sg_partido AS partido, sum(v.qt_votos_nominais_validos) AS total, sum(v.qt_votos_nominais_anul_subjud) anulados
             FROM tse.voto v 
            WHERE v.cd_municipio = 64777 
              AND v.cd_cargo = 11 
            GROUP BY v.sg_partido
           ORDER BY 2 desc;

          
SELECT * FROM tse.voto LIMIT 100;
          



SELECT * FROM tse.secao s WHERE s.cd_municipio = 64777 AND s.cd_cargo = 11;


SELECT * FROM tse.secao s WHERE s.cd_municipio = 64777 AND s.cd_cargo = 11 AND s.nr_zona = 176;


SELECT * FROM tse.votcan v WHERE v.cd_municipio = 64777 AND v.cd_cargo = 11;

load spatial;
SELECT st_point(l.nr_longitude, l.nr_latitude) AS ponto, l.* FROM tse.local l WHERE l.cd_municipio = 64777 AND l.nr_zona = 176 AND l.nr_turno = 1 AND l.nr_longitude <> -1;


select d.ano_declarado, count(*) from caged.dest d group by d.ano_declarado order by 1;



select * from read_csv('D:\dabase_loads\tse_raw\CESP_2t_SP_261020241121\csec_2t_SP_261020241121.csv', header=True);


DROP TABLE tse.st_secao;
DROP TABLE tse.st_contingencia;

SELECT * FROM tse.st_secao ss WHERE ss.cd_municipio = 64777;
SELECT * FROM tse.st_contingencia sc WHERE sc.cd_municipio = 64777;


/*
 * ===========================================================================================================================================================================================
 * ===========================================================================================================================================================================================
 * ===========================================================================================================================================================================================
 *                                                                         ESTATÍSTICAS DO COMEX
 * ===========================================================================================================================================================================================
 * ===========================================================================================================================================================================================
 * ===========================================================================================================================================================================================
*/

INSTALL postgres;
LOAD postgres;
ATTACH 'dbname=dbtest user=andre host=172.16.48.71 password=y2t1m1j2' AS pg (TYPE postgres);
show tables;

CREATE OR REPLACE TABLE sdceti03.comex.ncm AS FROM pg.comex.ncm;
CREATE OR REPLACE TABLE sdceti03.comex.ncmisic AS FROM pg.comex.ncmisic;
CREATE OR REPLACE TABLE sdceti03.comex.ncmsh AS FROM pg.comex.ncmsh;
CREATE OR REPLACE TABLE sdceti03.comex.novoproduto AS FROM pg.comex.novoproduto;
CREATE OR REPLACE TABLE sdceti03.comex.produto_raw AS FROM pg.comex.produto_raw;

DETACH pg;

DESC comex.exportacao;

SELECT * FROM cnae.vw_cnae vc WHERE vc.subclasse = 500201 ;
SELECT max(mes) FROM comex.exportacao e WHERE ano = 2024;
SELECT * FROM comex.produto p ;

SELECT p.cod_produto, p.nom_produto, sum(e.vl_fob) FROM comex.exportacao e INNER JOIN comex.produto p ON (e.cod_produto = p.cod_produto) WHERE e.sg_uf_mun = 'SP' GROUP BY p.cod_produto, p.nom_produto ORDER BY 3 DESC;

select * from comex.produto_raw;

select * from  comex.produto_raw where upper(nom_sh4_por) like '%AÇ_CARES%';

select * from comex.ncm where co_ncm like '2506%';
select * from comex.ncm where upper(no_ncm_por) like 'QUARTZO'
select * from cnae.vw_cnae where classe = 08991



--Açúcares
select * from comex.ncmsh where co_sh4 = '1701';
select * from comex.ncm where co_sh6 in (select co_sh6 from comex.ncmsh where co_sh4 = '1701');
select * from comex.ncm where co_ncm like '1701%';


select * from cnae.vw_cnae where classe = 07219



select * from comex.ncm where co_ncm like '2304%';
SELECT * FROM comex.ncmsh ;

SELECT * FROM cnae.vw_cnae WHERE classe = 10414;


SELECT * FROM cnae.vw_cnae WHERE classe = 10520;

SELECT * FROM cnae.vw_cnae WHERE upper(dsc_subclasse) LIKE '%NATA%';
select * from comex.produto_raw pr where upper(pr.nom_sh4_por) LIKE '%NATA%';

SELECT * FROM comex.ncmsh where upper(no_sh6_por) LIKE '%NATA%';
select * from comex.ncm where upper(no_ncm_por) LIKE '%NATA%';

select * from comex.ncm WHERE co_ncm like '040291%';

select * from comex.ncm WHERE co_ncm LIKE '%1904%';
select * from comex.ncm WHERE co_ncm in('09012100', '09012200');




select * from comex.ncm WHERE co_ncm LIKE '%53111%';

SELECT * FROM comex.ncm n WHERE n.co_ncm = '19041000';
SELECT * FROM comex.produto p  WHERE p.cod_produto = 1904;


-- teste 1 prodlist - ok
SELECT classe, dsc_classe, SUBSTRING(dsc_classe, 6, 7) FROM comex.prodlist WHERE classe <> SUBSTRING(dsc_classe, 6, 7);


SELECT * FROM comex.prodlist pl WHERE pl.ncm LIKE '%.%';

UPDATE comex.prodlist SET ncm = replace(ncm, '+', ',') WHERE ncm LIKE '%.%';



