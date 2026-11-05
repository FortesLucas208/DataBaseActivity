-- =====================================================================
-- Namiê Brasil — Script SQL (Entrega 2)
-- SGBD: MySQL 8.0.16 ou superior (testado em modelo; compatível com MariaDB/XAMPP)
-- Engine: InnoDB | Charset: utf8mb4 | Collation: utf8mb4_unicode_ci
-- Versão do dicionário de dados correspondente: 2.0
-- Ordem: 1) CREATE DATABASE  2) CREATE TABLE + constraints
--        4) INSERT (massa de dados)  5) SELECT/JOIN  6) UPDATE  7) DELETE
--        8) Consultas gerenciais (G)  9) Consultas de auditoria (A)
-- Observação: todas as chaves estrangeiras usam ON UPDATE RESTRICT e
-- ON DELETE RESTRICT (o MySQL 8.0 não permite CHECK sobre colunas de FK com
-- ação referencial CASCADE/SET NULL).
-- =====================================================================

-- 1) CREATE DATABASE ---------------------------------------------------
DROP DATABASE IF EXISTS namie_brasil;
CREATE DATABASE namie_brasil DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE namie_brasil;

-- 2) e 3) CREATE TABLE e CONSTRAINTS (PK, FK, UNIQUE, NOT NULL, DEFAULT, CHECK)
-- Coleções de produtos
CREATE TABLE tb_colecao (
  id_colecao INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(80) NOT NULL,
  tipo ENUM('Normal','Especial','Linha Permanente') NOT NULL DEFAULT 'Normal',
  ano_temporada VARCHAR(20) NOT NULL,
  cartela_cores VARCHAR(255) NULL,
  PRIMARY KEY (id_colecao),
  UNIQUE KEY uq_colecao_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Modelos de produto
CREATE TABLE tb_produto (
  id_produto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  descricao VARCHAR(500) NULL,
  id_colecao INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_produto),
  KEY idx_produto_nome (nome),
  CONSTRAINT fk_produto_colecao FOREIGN KEY (id_colecao) REFERENCES tb_colecao (id_colecao) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Variações (SKU): modelo + cor + tamanho
CREATE TABLE tb_variacao (
  id_variacao INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(30) NOT NULL,
  cor VARCHAR(40) NOT NULL,
  tamanho VARCHAR(10) NOT NULL,
  id_produto INT UNSIGNED NOT NULL,
  estoque_minimo INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_variacao),
  UNIQUE KEY uq_variacao_sku (sku),
  UNIQUE KEY uq_variacao_modelo_cor_tam (id_produto, cor, tamanho),
  CONSTRAINT fk_variacao_produto FOREIGN KEY (id_produto) REFERENCES tb_produto (id_produto) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Preços de atacado e varejo do modelo
CREATE TABLE tb_preco (
  id_preco INT UNSIGNED NOT NULL AUTO_INCREMENT,
  preco_atacado DECIMAL(10,2) NOT NULL,
  preco_varejo DECIMAL(10,2) NOT NULL,
  id_produto INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_preco),
  UNIQUE KEY uq_preco_produto (id_produto),
  CONSTRAINT fk_preco_produto FOREIGN KEY (id_produto) REFERENCES tb_produto (id_produto) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_preco_valores CHECK (preco_atacado > 0 AND preco_varejo >= preco_atacado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Locais de estoque (Geral, Feira, Online, Defeitão)
CREATE TABLE tb_estoque (
  id_estoque INT UNSIGNED NOT NULL AUTO_INCREMENT,
  localizacao VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_estoque),
  UNIQUE KEY uq_estoque_localizacao (localizacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuários e perfis de acesso
CREATE TABLE tb_usuario (
  id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  perfil VARCHAR(30) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  login VARCHAR(60) NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuario_login (login),
  CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('Administrador','Vendas','Estoque','Producao','Financeiro'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Entradas, saídas e transferências de estoque
CREATE TABLE tb_movimentacao (
  id_movimentacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo ENUM('Entrada','Saida','Transferencia') NOT NULL,
  quantidade INT UNSIGNED NOT NULL,
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  justificativa VARCHAR(255) NULL,
  id_estoque_origem INT UNSIGNED NULL,
  id_estoque_destino INT UNSIGNED NULL,
  id_variacao INT UNSIGNED NOT NULL,
  id_usuario INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_movimentacao),
  KEY idx_mov_variacao_data (id_variacao, data_hora),
  KEY idx_mov_data (data_hora),
  CONSTRAINT fk_movimentacao_estoque_origem FOREIGN KEY (id_estoque_origem) REFERENCES tb_estoque (id_estoque) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_movimentacao_estoque_destino FOREIGN KEY (id_estoque_destino) REFERENCES tb_estoque (id_estoque) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_movimentacao_variacao FOREIGN KEY (id_variacao) REFERENCES tb_variacao (id_variacao) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_movimentacao_usuario FOREIGN KEY (id_usuario) REFERENCES tb_usuario (id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_mov_quantidade CHECK (quantidade > 0),
  CONSTRAINT ck_mov_estoques CHECK ((tipo='Entrada' AND id_estoque_origem IS NULL AND id_estoque_destino IS NOT NULL) OR (tipo='Saida' AND id_estoque_origem IS NOT NULL AND id_estoque_destino IS NULL) OR (tipo='Transferencia' AND id_estoque_origem IS NOT NULL AND id_estoque_destino IS NOT NULL AND id_estoque_origem <> id_estoque_destino))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ordens de produção
CREATE TABLE tb_ordem_producao (
  id_ordem INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_inicio DATE NOT NULL,
  data_prevista DATE NULL,
  data_fim DATE NULL,
  status ENUM('Planejada','Em Corte','Em Costura','Em Lavanderia','Em Acabamento','Concluida') NOT NULL DEFAULT 'Planejada',
  PRIMARY KEY (id_ordem),
  KEY idx_ordem_status (status, data_inicio),
  CONSTRAINT ck_ordem_datas CHECK ((data_prevista IS NULL OR data_prevista >= data_inicio) AND (data_fim IS NULL OR data_fim >= data_inicio))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- N:N Estoque x Variação (saldo)
CREATE TABLE tb_estoque_variacao (
  id_estoque INT UNSIGNED NOT NULL,
  id_variacao INT UNSIGNED NOT NULL,
  quantidade INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_estoque, id_variacao),
  KEY idx_estoque_variacao_id_variacao (id_variacao),
  CONSTRAINT fk_estoque_variacao_estoque FOREIGN KEY (id_estoque) REFERENCES tb_estoque (id_estoque) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_estoque_variacao_variacao FOREIGN KEY (id_variacao) REFERENCES tb_variacao (id_variacao) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_ev_saldo CHECK (quantidade >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- N:N Ordem de Produção x Variação (quantidade produzida)
CREATE TABLE tb_ordem_variacao (
  id_ordem INT UNSIGNED NOT NULL,
  id_variacao INT UNSIGNED NOT NULL,
  quantidade INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_ordem, id_variacao),
  KEY idx_ordem_variacao_id_variacao (id_variacao),
  CONSTRAINT fk_ordem_variacao_ordem_producao FOREIGN KEY (id_ordem) REFERENCES tb_ordem_producao (id_ordem) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_ordem_variacao_variacao FOREIGN KEY (id_variacao) REFERENCES tb_variacao (id_variacao) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_ov_qtd CHECK (quantidade > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clientes (revendedores e consumidores finais)
CREATE TABLE tb_cliente (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  tipo ENUM('Consumidor Final','Revendedor') NOT NULL,
  documento VARCHAR(20) NOT NULL,
  telefone VARCHAR(20) NOT NULL,
  email VARCHAR(120) NOT NULL,
  status_credito ENUM('Sem Credito','Aprovado','Bloqueado') NOT NULL DEFAULT 'Sem Credito',
  limite_credito DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  logradouro VARCHAR(150) NOT NULL,
  numero VARCHAR(10) NOT NULL,
  complemento VARCHAR(60) NULL,
  bairro VARCHAR(80) NOT NULL,
  cidade VARCHAR(80) NOT NULL,
  uf CHAR(2) NOT NULL,
  cep CHAR(8) NOT NULL,
  anonimizado TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_cliente),
  KEY idx_cliente_nome (nome),
  UNIQUE KEY uq_cliente_documento (documento),
  CONSTRAINT ck_cliente_credito CHECK (limite_credito >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pedidos de venda
CREATE TABLE tb_pedido (
  id_pedido BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  canal ENUM('Atacado Feira','Atacado WhatsApp','Varejo Feira','Site','Marketplace') NOT NULL,
  status ENUM('Aguardando Pagamento','Pago','Faturado','Enviado','Entregue','Cancelado') NOT NULL DEFAULT 'Aguardando Pagamento',
  valor_frete DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  valor_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  endereco_entrega VARCHAR(300) NULL,
  data_envio DATETIME NULL,
  codigo_rastreio VARCHAR(40) NULL,
  transportadora VARCHAR(80) NULL,
  data_entrega DATETIME NULL,
  id_cliente INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_pedido),
  KEY idx_pedido_cliente_data (id_cliente, data_hora),
  KEY idx_pedido_canal_status (canal, status),
  KEY idx_pedido_data (data_hora),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES tb_cliente (id_cliente) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_pedido_valores CHECK (valor_frete >= 0 AND valor_total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- N:N Pedido x Variação (itens vendidos)
CREATE TABLE tb_pedido_variacao (
  id_pedido BIGINT UNSIGNED NOT NULL,
  id_variacao INT UNSIGNED NOT NULL,
  quantidade INT UNSIGNED NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_pedido, id_variacao),
  KEY idx_pedido_variacao_id_variacao (id_variacao),
  CONSTRAINT fk_pedido_variacao_pedido FOREIGN KEY (id_pedido) REFERENCES tb_pedido (id_pedido) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_pedido_variacao_variacao FOREIGN KEY (id_variacao) REFERENCES tb_variacao (id_variacao) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_pv_valores CHECK (quantidade > 0 AND preco_unitario > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Parcelas de pagamento dos pedidos
CREATE TABLE tb_pagamento (
  id_pagamento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  numero_parcela TINYINT UNSIGNED NOT NULL DEFAULT 1,
  valor_parcela DECIMAL(10,2) NOT NULL,
  forma_pagamento ENUM('Pix','Cartao_Credito','Cartao_Debito','Boleto','Dinheiro') NOT NULL,
  data_vencimento DATE NOT NULL,
  data_liquidacao DATETIME NULL,
  situacao ENUM('Pendente','Pago','Cancelado') NOT NULL DEFAULT 'Pendente',
  id_pedido BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_pagamento),
  UNIQUE KEY uq_pagamento_parcela (id_pedido, numero_parcela),
  KEY idx_pagamento_venc (data_vencimento, situacao),
  CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido) REFERENCES tb_pedido (id_pedido) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_pagamento_valores CHECK (numero_parcela BETWEEN 1 AND 3 AND valor_parcela > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notas fiscais dos pedidos faturados
CREATE TABLE tb_nota_fiscal (
  id_nota_fiscal INT UNSIGNED NOT NULL AUTO_INCREMENT,
  numero INT UNSIGNED NOT NULL,
  serie SMALLINT UNSIGNED NOT NULL,
  chave_acesso CHAR(44) NOT NULL,
  data_emissao DATETIME NOT NULL,
  valor_fiscal DECIMAL(12,2) NOT NULL,
  id_pedido BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_nota_fiscal),
  UNIQUE KEY uq_nf_pedido (id_pedido),
  UNIQUE KEY uq_nf_chave (chave_acesso),
  UNIQUE KEY uq_nf_serie_numero (serie, numero),
  CONSTRAINT fk_nota_fiscal_pedido FOREIGN KEY (id_pedido) REFERENCES tb_pedido (id_pedido) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_nf_valores CHECK (CHAR_LENGTH(chave_acesso) = 44 AND valor_fiscal > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Devoluções de pedidos
CREATE TABLE tb_devolucao (
  id_devolucao INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_solicitacao DATETIME NOT NULL,
  motivo VARCHAR(255) NOT NULL,
  id_pedido BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_devolucao),
  KEY idx_devolucao_data (data_solicitacao),
  CONSTRAINT fk_devolucao_pedido FOREIGN KEY (id_pedido) REFERENCES tb_pedido (id_pedido) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- N:N Devolução x Variação
CREATE TABLE tb_devolucao_variacao (
  id_devolucao INT UNSIGNED NOT NULL,
  id_variacao INT UNSIGNED NOT NULL,
  quantidade INT UNSIGNED NOT NULL,
  condicao_peca ENUM('Perfeita','Defeituosa') NOT NULL,
  estoque_destino ENUM('Online','Defeitao') NOT NULL,
  PRIMARY KEY (id_devolucao, id_variacao),
  KEY idx_devolucao_variacao_id_variacao (id_variacao),
  CONSTRAINT fk_devolucao_variacao_devolucao FOREIGN KEY (id_devolucao) REFERENCES tb_devolucao (id_devolucao) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_devolucao_variacao_variacao FOREIGN KEY (id_variacao) REFERENCES tb_variacao (id_variacao) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_dv_valores CHECK (quantidade > 0 AND ((condicao_peca='Perfeita' AND estoque_destino='Online') OR (condicao_peca='Defeituosa' AND estoque_destino='Defeitao')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fornecedores de insumos
CREATE TABLE tb_fornecedor (
  id_fornecedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
  razao_social VARCHAR(150) NOT NULL,
  nome_fantasia VARCHAR(150) NULL,
  cnpj CHAR(14) NOT NULL,
  inscricao_estadual VARCHAR(20) NULL,
  telefone VARCHAR(20) NOT NULL,
  email VARCHAR(120) NOT NULL,
  contato_representante VARCHAR(120) NULL,
  categoria_insumo ENUM('Tecido','Aviamento','Quimico','Embalagem') NOT NULL,
  logradouro VARCHAR(150) NOT NULL,
  numero VARCHAR(10) NOT NULL,
  complemento VARCHAR(60) NULL,
  bairro VARCHAR(80) NOT NULL,
  cidade VARCHAR(80) NOT NULL,
  uf CHAR(2) NOT NULL,
  cep CHAR(8) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_fornecedor),
  UNIQUE KEY uq_fornecedor_cnpj (cnpj),
  KEY idx_fornecedor_razao (razao_social)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insumos (matéria-prima e aviamentos)
CREATE TABLE tb_insumo (
  id_insumo INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  tipo ENUM('Tecido','Aviamento','Quimico','Embalagem') NOT NULL,
  unidade_medida VARCHAR(20) NOT NULL,
  PRIMARY KEY (id_insumo),
  KEY idx_insumo_tipo_nome (tipo, nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Compras de insumos
CREATE TABLE tb_compra (
  id_compra INT UNSIGNED NOT NULL AUTO_INCREMENT,
  numero_documento_fiscal VARCHAR(20) NOT NULL,
  data_compra DATE NOT NULL,
  data_entrega DATE NULL,
  valor_total DECIMAL(12,2) NOT NULL,
  id_fornecedor INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_compra),
  KEY idx_compra_forn_data (id_fornecedor, data_compra),
  CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES tb_fornecedor (id_fornecedor) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_compra_valores CHECK (valor_total > 0 AND (data_entrega IS NULL OR data_entrega >= data_compra))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- N:N Compra x Insumo
CREATE TABLE tb_compra_insumo (
  id_compra INT UNSIGNED NOT NULL,
  id_insumo INT UNSIGNED NOT NULL,
  quantidade DECIMAL(12,3) NOT NULL,
  valor_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_compra, id_insumo),
  KEY idx_compra_insumo_id_insumo (id_insumo),
  CONSTRAINT fk_compra_insumo_compra FOREIGN KEY (id_compra) REFERENCES tb_compra (id_compra) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_compra_insumo_insumo FOREIGN KEY (id_insumo) REFERENCES tb_insumo (id_insumo) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_ci_valores CHECK (quantidade > 0 AND valor_unitario > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contas a pagar geradas pelas compras
CREATE TABLE tb_conta_pagar (
  id_conta_pagar INT UNSIGNED NOT NULL AUTO_INCREMENT,
  valor DECIMAL(12,2) NOT NULL,
  data_emissao DATE NOT NULL,
  data_vencimento DATE NOT NULL,
  data_pagamento DATE NULL,
  forma_pagamento ENUM('Pix','Cartao_Credito','Cartao_Debito','Boleto','Dinheiro') NULL,
  status ENUM('Aberto','Liquidado','Vencido') NOT NULL DEFAULT 'Aberto',
  id_compra INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_conta_pagar),
  KEY idx_cp_venc (data_vencimento, status),
  CONSTRAINT fk_conta_pagar_compra FOREIGN KEY (id_compra) REFERENCES tb_compra (id_compra) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_cp_valores CHECK (valor > 0 AND data_vencimento >= data_emissao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log imutável de acessos e operações
CREATE TABLE tb_log_acesso (
  id_log BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario INT UNSIGNED NOT NULL,
  data_hora DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  operacao ENUM('Login','Logout','Consulta','Inclusao','Alteracao','Exclusao','Anonimizacao') NOT NULL,
  tabela_afetada VARCHAR(64) NULL,
  id_registro BIGINT UNSIGNED NULL,
  dado_pessoal TINYINT(1) NOT NULL DEFAULT 0,
  ip_origem VARCHAR(45) NOT NULL,
  resultado ENUM('Sucesso','Negado') NOT NULL,
  PRIMARY KEY (id_log),
  KEY idx_log_usuario_data (id_usuario, data_hora),
  KEY idx_log_tabela_registro (tabela_afetada, id_registro),
  KEY idx_log_data (data_hora),
  CONSTRAINT fk_log_acesso_usuario FOREIGN KEY (id_usuario) REFERENCES tb_usuario (id_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
--
--
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

