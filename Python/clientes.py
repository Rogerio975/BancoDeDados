import sqlite3

# Conectar ao banco de dados (ou criá-lo se não existir)
conn = sqlite3.connect('clientes.db')

# Criar um cursor para executar comandos SQL
cursor = conn.cursor()

# Criar tabela Clientes
cursor.execute('''
    CREATE TABLE IF NOT EXISTS Clientes (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        Nome TEXT NOT NULL,
        Endereco TEXT,
        CPF TEXT NOT NULL UNIQUE,
        Email TEXT UNIQUE
    )
''')

# Função para inserir um novo cliente no banco de dados
def inserir_cliente(nome, endereco, cpf, email):
    cursor.execute('''
        INSERT INTO Clientes (Nome, Endereco, CPF, Email)
        VALUES (?, ?, ?, ?)
    ''', (nome, endereco, cpf, email))
    conn.commit()
    print("Cliente inserido com sucesso.")

# Exemplo de inserção de cliente
inserir_cliente('João da Silva', 'Rua A, 123', '123.456.789-10', 'joao@example.com')
inserir_cliente('Maria Oliveira', 'Avenida B, 456', '987.654.321-00', 'maria@example.com')

# Fechar conexão com o banco de dados
conn.close()