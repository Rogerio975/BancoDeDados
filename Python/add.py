import sqlite3
dados = [("Joao", "98901-0109"), ("Andre", "98902-8900"), ("Maria", "97891-3321"), ("Julia", "99302-8614"), ("Nadjane", "96570-2874")]
conexao = sqlite3.connect("agenda.db")
cursor = conexao.cursor()
cursor.executemany('''insert into agenda (nome, telefone) values(?, ?)''', dados)
conexao.commit()
cursor.close()
conexao.close()
