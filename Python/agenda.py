import sqlite3
conexao = sqlite3.connect("agenda2.db")
cursor = conexao.cursor()
cursor.execute('''create table agenda2(nome text, telefone text)''')
cursor.execute('''insert into agenda2 (nome, telefone) values(?, ?)''', ("Nilo", "7788-1432"))
conexao.commit()
cursor.close()
conexao.close()
