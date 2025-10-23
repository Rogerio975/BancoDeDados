-- Criação do banco de dados Supermercado
CREATE DATABASE supermercado;

-- Conectar ao banco de dados
\c supermercado;

-- Tabela de Categorias de Produtos
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL,
    descricao TEXT
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_unitario DECIMAL(10,2) NOT NULL,
    quantidade_estoque INTEGER NOT NULL,
    id_categoria INTEGER REFERENCES categorias(id_categoria),
    codigo_barras VARCHAR(13) UNIQUE,
    data_cadastro DATE DEFAULT CURRENT_DATE
);

-- Tabela de Clientes
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    email VARCHAR(100),
    telefone VARCHAR(15),
    endereco TEXT,
    data_cadastro DATE DEFAULT CURRENT_DATE
);

-- Tabela de Funcionários
CREATE TABLE funcionarios (
    id_funcionario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    cargo VARCHAR(50),
    salario DECIMAL(10,2),
    data_contratacao DATE,
    telefone VARCHAR(15),
    email VARCHAR(100)
);

-- Tabela de Fornecedores
CREATE TABLE fornecedores (
    id_fornecedor SERIAL PRIMARY KEY,
    razao_social VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) UNIQUE,
    contato VARCHAR(100),
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco TEXT
);

-- Tabela de Vendas
CREATE TABLE vendas (
    id_venda SERIAL PRIMARY KEY,
    id_cliente INTEGER REFERENCES clientes(id_cliente),
    id_funcionario INTEGER REFERENCES funcionarios(id_funcionario),
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2),
    forma_pagamento VARCHAR(50)
);

-- Tabela de Itens da Venda
CREATE TABLE itens_venda (
    id_item_venda SERIAL PRIMARY KEY,
    id_venda INTEGER REFERENCES vendas(id_venda),
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED
);

-- Tabela de Compras (do fornecedor)
CREATE TABLE compras (
    id_compra SERIAL PRIMARY KEY,
    id_fornecedor INTEGER REFERENCES fornecedores(id_fornecedor),
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2)
);

-- Tabela de Itens da Compra
CREATE TABLE itens_compra (
    id_item_compra SERIAL PRIMARY KEY,
    id_compra INTEGER REFERENCES compras(id_compra),
    id_produto INTEGER REFERENCES produtos(id_produto),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED
);

-- Índices para melhorar a performance
CREATE INDEX idx_produtos_categoria ON produtos(id_categoria);
CREATE INDEX idx_vendas_cliente ON vendas(id_cliente);
CREATE INDEX idx_vendas_funcionario ON vendas(id_funcionario);
CREATE INDEX idx_itens_venda_venda ON itens_venda(id_venda);
CREATE INDEX idx_itens_venda_produto ON itens_venda(id_produto);
CREATE INDEX idx_compras_fornecedor ON compras(id_fornecedor);
CREATE INDEX idx_itens_compra_compra ON itens_compra(id_compra);
CREATE INDEX idx_itens_compra_produto ON itens_compra(id_produto);

-- Inserir algumas categorias de exemplo
INSERT INTO categorias (nome_categoria, descricao) VALUES
('Mercearia', 'Produtos de mercearia em geral'),
('Hortifruti', 'Frutas, legumes e verduras'),
('Bebidas', 'Bebidas em geral'),
('Carnes', 'Carnes, aves e peixes'),
('Limpeza', 'Produtos de limpeza'),
('Higiene', 'Produtos de higiene pessoal');

-- Trigger para atualizar o estoque após uma venda
CREATE OR REPLACE FUNCTION atualizar_estoque_venda()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE produtos
    SET quantidade_estoque = quantidade_estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_estoque_venda
AFTER INSERT ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque_venda();

-- Trigger para atualizar o estoque após uma compra
CREATE OR REPLACE FUNCTION atualizar_estoque_compra()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE produtos
    SET quantidade_estoque = quantidade_estoque + NEW.quantidade
    WHERE id_produto = NEW.id_produto;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_estoque_compra
AFTER INSERT ON itens_compra
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque_compra();