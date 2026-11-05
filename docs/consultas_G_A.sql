-- =====================================================================
-- Namiê Brasil — Consultas gerenciais (G) e de auditoria (A)
-- Para colar nas seções 8 e 9 do script SQL. Execute após script + massa de dados.
-- Data de referência da massa: 30/09/2026 (último dia simulado).
-- =====================================================================
USE namie_brasil;

-- ===================== CONSULTAS GERENCIAIS =====================

-- G01 — Qual o saldo de cada SKU em cada estoque (Geral, Feira, Online, Defeitão)?
-- Atende: P1 (estoque fragmentado, sem visão única do saldo por SKU e por local)
SELECT v.sku, p.nome AS modelo, v.cor, v.tamanho,
       SUM(CASE WHEN e.localizacao = 'Geral'  THEN ev.quantidade ELSE 0 END) AS saldo_geral,
       SUM(CASE WHEN e.localizacao = 'Feira'  THEN ev.quantidade ELSE 0 END) AS saldo_feira,
       SUM(CASE WHEN e.localizacao = 'Online' THEN ev.quantidade ELSE 0 END) AS saldo_online,
       SUM(CASE WHEN e.localizacao LIKE 'Defeit%' THEN ev.quantidade ELSE 0 END) AS saldo_defeitao,
       COALESCE(SUM(ev.quantidade), 0) AS saldo_total
FROM tb_variacao v
JOIN tb_produto p ON p.id_produto = v.id_produto
LEFT JOIN tb_estoque_variacao ev ON ev.id_variacao = v.id_variacao
LEFT JOIN tb_estoque e ON e.id_estoque = ev.id_estoque
GROUP BY v.id_variacao, v.sku, p.nome, v.cor, v.tamanho
ORDER BY v.sku;

-- G02 — Quantos pares estoque/SKU têm saldo diferente de entradas − saídas, por estoque?
-- Atende: P2 (divergência entre o saldo registrado e o real) e K2
SELECT t.localizacao,
       COUNT(*) AS pares_divergentes,
       SUM(ABS(t.saldo_registrado - t.saldo_movimentacoes)) AS pecas_de_diferenca
FROM (
  SELECT e.localizacao, ev.id_variacao, ev.quantidade AS saldo_registrado,
         COALESCE(SUM(CASE WHEN m.id_estoque_destino = ev.id_estoque THEN m.quantidade ELSE 0 END), 0)
       - COALESCE(SUM(CASE WHEN m.id_estoque_origem  = ev.id_estoque THEN m.quantidade ELSE 0 END), 0) AS saldo_movimentacoes
  FROM tb_estoque_variacao ev
  JOIN tb_estoque e ON e.id_estoque = ev.id_estoque
  LEFT JOIN tb_movimentacao m ON m.id_variacao = ev.id_variacao
       AND (m.id_estoque_origem = ev.id_estoque OR m.id_estoque_destino = ev.id_estoque)
  GROUP BY e.localizacao, ev.id_estoque, ev.id_variacao, ev.quantidade
) t
WHERE t.saldo_registrado <> t.saldo_movimentacoes
GROUP BY t.localizacao
ORDER BY pares_divergentes DESC;

-- G03 — Quais baixas deixaram o saldo de um SKU negativo?
WITH movimentos_com_saldo AS (
    SELECT
        m.id_movimentacao,
        m.data_hora,
        m.tipo,
        m.quantidade,
        m.justificativa,
        m.id_variacao,
        e2.id_estoque,
        SUM(
            CASE
                WHEN m.id_estoque_destino = e2.id_estoque
                THEN m.quantidade
                ELSE -m.quantidade
            END
        ) OVER (
            PARTITION BY e2.id_estoque, m.id_variacao
            ORDER BY m.data_hora, m.id_movimentacao
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS saldo_apos
    FROM tb_movimentacao m
    JOIN tb_estoque e2
      ON e2.id_estoque = m.id_estoque_destino
      OR e2.id_estoque = m.id_estoque_origem
),
movimentos_com_anterior AS (
    SELECT x.*,
        COALESCE(
            LAG(x.saldo_apos) OVER (
                PARTITION BY x.id_estoque, x.id_variacao
                ORDER BY x.data_hora, x.id_movimentacao
            ), 0
        ) AS saldo_antes
    FROM movimentos_com_saldo x
)
SELECT
    x.id_movimentacao,
    x.data_hora,
    e.localizacao,
    v.sku,
    x.quantidade AS qtd_baixada,
    x.saldo_apos,
    x.justificativa
FROM movimentos_com_anterior x
JOIN tb_estoque e ON e.id_estoque = x.id_estoque
JOIN tb_variacao v ON v.id_variacao = x.id_variacao
WHERE x.tipo = 'Saida'
  AND x.saldo_antes >= 0
  AND x.saldo_apos < 0
ORDER BY x.data_hora;

-- G04 — Por canal, quantos pedidos com nota fiscal estão sem baixa de estoque e quanto tempo leva a baixa?
-- Atende: P4 (baixa das peças imediata ou posterior, gerando divergência) — a baixa ocorre na emissão da NF
SELECT p.canal,
       COUNT(*) AS pedidos_com_nf,
       SUM(CASE WHEN b.id_pedido IS NULL THEN 1 ELSE 0 END) AS sem_baixa_de_estoque,
       ROUND(AVG(TIMESTAMPDIFF(HOUR, p.data_hora, b.primeira_baixa)), 1) AS horas_ate_a_baixa
FROM tb_pedido p
JOIN tb_nota_fiscal nf ON nf.id_pedido = p.id_pedido
LEFT JOIN (
  SELECT p2.id_pedido, MIN(m.data_hora) AS primeira_baixa
  FROM tb_pedido p2
  JOIN tb_movimentacao m ON m.tipo = 'Saida'
       AND m.justificativa LIKE CONCAT('%NF do pedido ', p2.id_pedido)
  GROUP BY p2.id_pedido
) b ON b.id_pedido = p.id_pedido
GROUP BY p.canal
ORDER BY p.canal;

-- G05 — Quais SKUs estão com saldo no Estoque Geral igual ou abaixo do estoque mínimo?
-- Atende: P5 (sem estoque mínimo definido) e K1 — RN12
SELECT v.sku, p.nome AS modelo, v.cor, v.tamanho, v.estoque_minimo,
       COALESCE(ev.quantidade, 0) AS saldo_geral,
       CAST(v.estoque_minimo AS SIGNED) - CAST(COALESCE(ev.quantidade, 0) AS SIGNED) AS faltam_para_o_minimo
FROM tb_variacao v
JOIN tb_produto p ON p.id_produto = v.id_produto
JOIN tb_estoque e ON e.localizacao = 'Geral'
LEFT JOIN tb_estoque_variacao ev ON ev.id_estoque = e.id_estoque AND ev.id_variacao = v.id_variacao
WHERE COALESCE(ev.quantidade, 0) <= v.estoque_minimo
ORDER BY faltam_para_o_minimo DESC, v.sku;

-- G06 — Qual o faturamento por canal e por mês (pedidos não cancelados)?
-- Atende: K3 (faturamento por canal)
SELECT SUBSTR(p.data_hora, 1, 7) AS mes, p.canal,
       COUNT(*) AS pedidos, SUM(p.valor_total) AS faturamento
FROM tb_pedido p
WHERE p.status <> 'Cancelado'
GROUP BY SUBSTR(p.data_hora, 1, 7), p.canal
ORDER BY mes, p.canal;

-- G07 — Qual o ticket médio por canal e por mês (pedidos não cancelados)?
-- Atende: K4 (ticket médio por canal)
SELECT SUBSTR(p.data_hora, 1, 7) AS mes, p.canal,
       ROUND(SUM(p.valor_total) / COUNT(*), 2) AS ticket_medio
FROM tb_pedido p
WHERE p.status <> 'Cancelado'
GROUP BY SUBSTR(p.data_hora, 1, 7), p.canal
ORDER BY mes, p.canal;

-- G08 — Qual a taxa de cancelamento de pedidos por mês?
-- Atende: K5 (taxa de cancelamento)
SELECT SUBSTR(p.data_hora, 1, 7) AS mes,
       COUNT(*) AS pedidos,
       SUM(CASE WHEN p.status = 'Cancelado' THEN 1 ELSE 0 END) AS cancelados,
       ROUND(100.0 * SUM(CASE WHEN p.status = 'Cancelado' THEN 1 ELSE 0 END) / COUNT(*), 2) AS taxa_cancelamento_pct
FROM tb_pedido p
GROUP BY SUBSTR(p.data_hora, 1, 7)
ORDER BY mes;

-- G09 — Qual a taxa de devolução (itens devolvidos ÷ itens vendidos) por mês do pedido?
-- Atende: K6 (taxa de devolução)
SELECT vend.mes, vend.itens_vendidos, COALESCE(dev.itens_devolvidos, 0) AS itens_devolvidos,
       ROUND(100.0 * COALESCE(dev.itens_devolvidos, 0) / vend.itens_vendidos, 2) AS taxa_devolucao_pct
FROM (
  SELECT SUBSTR(p.data_hora, 1, 7) AS mes, SUM(pv.quantidade) AS itens_vendidos
  FROM tb_pedido p
  JOIN tb_pedido_variacao pv ON pv.id_pedido = p.id_pedido
  WHERE p.status <> 'Cancelado'
  GROUP BY SUBSTR(p.data_hora, 1, 7)
) vend
LEFT JOIN (
  SELECT SUBSTR(p.data_hora, 1, 7) AS mes, SUM(dv.quantidade) AS itens_devolvidos
  FROM tb_devolucao d
  JOIN tb_devolucao_variacao dv ON dv.id_devolucao = d.id_devolucao
  JOIN tb_pedido p ON p.id_pedido = d.id_pedido
  GROUP BY SUBSTR(p.data_hora, 1, 7)
) dev ON dev.mes = vend.mes
ORDER BY vend.mes;

-- G10 — Quantas peças e quantos SKUs estão hoje no estoque Defeitão?
-- Atende: K7 (peças no Defeitão)
SELECT e.localizacao,
       COUNT(CASE WHEN ev.quantidade > 0 THEN 1 END) AS skus_com_saldo,
       COALESCE(SUM(ev.quantidade), 0) AS pecas_no_defeitao
FROM tb_estoque e
LEFT JOIN tb_estoque_variacao ev ON ev.id_estoque = e.id_estoque
WHERE e.localizacao LIKE 'Defeit%'
GROUP BY e.localizacao;

-- G11 — Que percentual das ordens de produção concluídas terminou dentro do prazo, por mês?
-- Atende: K8 (produção no prazo)
SELECT SUBSTR(o.data_fim, 1, 7) AS mes,
       COUNT(*) AS ordens_concluidas,
       SUM(CASE WHEN o.data_fim <= o.data_prevista THEN 1 ELSE 0 END) AS no_prazo,
       ROUND(100.0 * SUM(CASE WHEN o.data_fim <= o.data_prevista THEN 1 ELSE 0 END) / COUNT(*), 2) AS no_prazo_pct
FROM tb_ordem_producao o
WHERE o.status = 'Concluida' AND o.data_fim IS NOT NULL AND o.data_prevista IS NOT NULL
GROUP BY SUBSTR(o.data_fim, 1, 7)
ORDER BY mes;

-- G12 — Quanto há em contas a pagar vencidas e não pagas, por fornecedor (referência: 30/09/2026)?
-- Atende: K9 (contas a pagar vencidas)
SELECT f.razao_social, COUNT(*) AS titulos_vencidos,
       SUM(cp.valor) AS valor_vencido, MIN(cp.data_vencimento) AS vencimento_mais_antigo
FROM tb_conta_pagar cp
JOIN tb_compra c ON c.id_compra = cp.id_compra
JOIN tb_fornecedor f ON f.id_fornecedor = c.id_fornecedor
WHERE cp.data_pagamento IS NULL AND cp.data_vencimento < '2026-09-30'
GROUP BY f.id_fornecedor, f.razao_social
ORDER BY valor_vencido DESC;

-- ===================== CONSULTAS DE AUDITORIA =====================

-- A01 — Quais pares estoque/SKU têm saldo diferente de entradas − saídas?
-- Verifica: RN03 e RN04 (saldo por local deve refletir as movimentações) — RNF03
SELECT e.localizacao, v.sku, ev.quantidade AS saldo_registrado,
       COALESCE(SUM(CASE WHEN m.id_estoque_destino = ev.id_estoque THEN m.quantidade ELSE 0 END), 0)
     - COALESCE(SUM(CASE WHEN m.id_estoque_origem  = ev.id_estoque THEN m.quantidade ELSE 0 END), 0) AS saldo_pelas_movimentacoes
FROM tb_estoque_variacao ev
JOIN tb_estoque e ON e.id_estoque = ev.id_estoque
JOIN tb_variacao v ON v.id_variacao = ev.id_variacao
LEFT JOIN tb_movimentacao m ON m.id_variacao = ev.id_variacao
     AND (m.id_estoque_origem = ev.id_estoque OR m.id_estoque_destino = ev.id_estoque)
GROUP BY e.localizacao, v.sku, ev.id_estoque, ev.id_variacao, ev.quantidade
HAVING ev.quantidade <>
       COALESCE(SUM(CASE WHEN m.id_estoque_destino = ev.id_estoque THEN m.quantidade ELSE 0 END), 0)
     - COALESCE(SUM(CASE WHEN m.id_estoque_origem  = ev.id_estoque THEN m.quantidade ELSE 0 END), 0)
ORDER BY v.sku, e.localizacao;

-- A02 — Existe pedido registrado sem nenhum item?
-- Verifica: RN07 (todo pedido tem ao menos um item)
SELECT p.id_pedido, p.data_hora, p.canal, p.status
FROM tb_pedido p
LEFT JOIN tb_pedido_variacao pv ON pv.id_pedido = p.id_pedido
WHERE pv.id_pedido IS NULL
ORDER BY p.id_pedido;

-- A03 — Existe pedido faturado, enviado ou entregue sem nota fiscal?
-- Verifica: RN15 (todo pedido faturado tem nota fiscal emitida antes da expedição)
SELECT p.id_pedido, p.data_hora, p.canal, p.status
FROM tb_pedido p
LEFT JOIN tb_nota_fiscal nf ON nf.id_pedido = p.id_pedido
WHERE p.status IN ('Faturado','Enviado','Entregue')
  AND (
      nf.id_pedido IS NULL
      OR (
          p.data_envio IS NOT NULL
          AND nf.data_emissao > p.data_envio
      )
  )

-- A04 — Existe venda a prazo (boleto parcelado ou com vencimento acima de 7 dias) para cliente sem crédito aprovado?
-- Verifica: RN14 (prazo só para revendedora com crédito aprovado; boleto de 1 parcela com vencimento curto é à vista)
SELECT DISTINCT p.id_pedido, p.canal, c.nome, c.tipo, c.status_credito
FROM tb_pedido p
JOIN tb_cliente c ON c.id_cliente = p.id_cliente
JOIN tb_pagamento pg ON pg.id_pedido = p.id_pedido
WHERE pg.forma_pagamento = 'Boleto'
  AND (pg.numero_parcela > 1 OR DATEDIFF(pg.data_vencimento, DATE(p.data_hora)) > 7)
  AND p.status <> 'Cancelado'
  AND (c.tipo <> 'Revendedor' OR c.status_credito <> 'Aprovado')
ORDER BY p.id_pedido;

-- A05 — Existe pedido de atacado não cancelado com menos de 12 peças no total?
-- Verifica: RN13 (pedido mínimo no atacado; o mínimo de 12 peças é o exemplo dado pela gerência)
SELECT p.id_pedido, p.canal, p.status, SUM(pv.quantidade) AS total_pecas
FROM tb_pedido p
JOIN tb_pedido_variacao pv ON pv.id_pedido = p.id_pedido
WHERE p.canal IN ('Atacado Feira','Atacado WhatsApp') AND p.status <> 'Cancelado'
GROUP BY p.id_pedido, p.canal, p.status
HAVING SUM(pv.quantidade) < 12
ORDER BY p.id_pedido;

-- A06 — Existe devolução de venda online solicitada mais de 7 dias depois da entrega?
-- Verifica: RN16 (direito de arrependimento em até 7 dias no site e nos marketplaces)
SELECT d.id_devolucao, d.id_pedido, p.canal, p.data_entrega, d.data_solicitacao,
       DATEDIFF(d.data_solicitacao, p.data_entrega) AS dias_apos_entrega
FROM tb_devolucao d
JOIN tb_pedido p ON p.id_pedido = d.id_pedido
WHERE p.canal IN ('Site','Marketplace')
  AND DATEDIFF(d.data_solicitacao, p.data_entrega) > 7
ORDER BY d.id_devolucao;


-- A07 — Existe compra sem nenhum título em contas a pagar?
-- Verifica: RN19 (toda compra gera obrigação financeira)
SELECT c.id_compra, c.numero_documento_fiscal, c.data_compra, c.valor_total
FROM tb_compra c
LEFT JOIN tb_conta_pagar cp ON cp.id_compra = c.id_compra
WHERE cp.id_compra IS NULL
ORDER BY c.id_compra;

-- A08 — Existe compra feita de fornecedor inativo?
-- Verifica: RN18 (compra só de fornecedor cadastrado e ativo)
SELECT c.id_compra, c.data_compra, f.razao_social, f.ativo
FROM tb_compra c
JOIN tb_fornecedor f ON f.id_fornecedor = c.id_fornecedor
WHERE f.ativo = 0
ORDER BY c.id_compra;

-- A09 — Existe item devolvido com destino incoerente com a condição da peça?
-- Verifica: RN10 e RN11 (perfeita volta ao Online; defeituosa vai ao Defeitão)
SELECT dv.id_devolucao, dv.id_variacao, dv.condicao_peca, dv.estoque_destino
FROM tb_devolucao_variacao dv
WHERE NOT ((dv.condicao_peca = 'Perfeita'   AND dv.estoque_destino = 'Online')
        OR (dv.condicao_peca = 'Defeituosa' AND dv.estoque_destino = 'Defeitao'))
ORDER BY dv.id_devolucao;

-- A10 — Existe movimentação com origem e destino incoerentes com o tipo?
-- Verifica: RN04 (entrada só tem destino; saída só tem origem; transferência tem os dois, diferentes)
SELECT m.id_movimentacao, m.tipo, m.id_estoque_origem, m.id_estoque_destino
FROM tb_movimentacao m
WHERE NOT ((m.tipo = 'Entrada'       AND m.id_estoque_origem IS NULL     AND m.id_estoque_destino IS NOT NULL)
        OR (m.tipo = 'Saida'         AND m.id_estoque_origem IS NOT NULL AND m.id_estoque_destino IS NULL)
        OR (m.tipo = 'Transferencia' AND m.id_estoque_origem IS NOT NULL AND m.id_estoque_destino IS NOT NULL
                                     AND m.id_estoque_origem <> m.id_estoque_destino))
ORDER BY m.id_movimentacao;

-- A11 — Existe pedido com valor_total diferente da soma dos itens mais o frete?
-- Verifica: RN07 (composição do pedido; valor_total é atributo derivado mantido por desempenho)
SELECT p.id_pedido, p.status, p.valor_total,
       SUM(pv.quantidade * pv.preco_unitario) + p.valor_frete AS soma_itens_mais_frete
FROM tb_pedido p
JOIN tb_pedido_variacao pv ON pv.id_pedido = p.id_pedido
GROUP BY p.id_pedido, p.status, p.valor_total, p.valor_frete
HAVING ABS(p.valor_total - (SUM(pv.quantidade * pv.preco_unitario) + p.valor_frete)) > 0.01
ORDER BY p.id_pedido;
