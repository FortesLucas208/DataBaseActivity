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

-- 4) INSERT INTO  (massa de dados — a ser adicionada)
-- 5) SELECT com JOIN (a ser adicionado)
-- 6) UPDATE (a ser adicionado)
-- 7) DELETE (a ser adicionado)
-- 8) Consultas gerenciais G01.. (a serem adicionadas)
-- 9) Consultas de auditoria A01.. (a serem adicionadas)
