import pyodbc
from flask import Flask, render_template, request
app = Flask(__name__)

@app.route('/')

def padrao():
	return render_template('formulario.html')

@app.route('/resultado',methods = ['POST', 'GET'])
def resultado():
	if request.method == 'POST':
		result = request.form
		name = request.form['Name']
		email = request.form['Email']
		server = 'EMPYT-4\SQLEXPRESS' 
		database = 'Trabalho'  
		cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database)
		cursor = cnxn.cursor()
		sql = "SELECT email FROM Dados_Alunos where nome ='" + name + "' and email = '" + email + "'"
		cursor.execute(sql)
      
		row = cursor.fetchone()
		if row != None:
			return "Usuario existente na base. Recarregue a pagina e tente outro nome/email."
		else:
			sql1 = "INSERT INTO Dados_Alunos (nome,email) VALUES ('{}','{}')".format(name,email)
			cursor.execute(sql1)
			cursor.commit()
			cursor.close()
			return "Usuario inserido com sucesso!"

		return render_template("resultado.html",result = result)
@app.route('/tabela')
def student():
	server = 'EMPYT-4\SQLEXPRESS' 
	database = 'Trabalho'  
	cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database)
	cursor = cnxn.cursor()
	cursor.execute("SELECT * FROM Dados_Alunos")
	result_set = cursor.fetchall()
	  
	strHtml = '<!DOCTYPE html> '
	strHtml += '<html> '
	strHtml += '<body> '
	strHtml += '<table border="1"> '
	strHtml += '<tr> '
	strHtml += '<th>Nome</th> '
	strHtml += '<th>Email</th> '
	strHtml += '</tr> '

	for row in result_set:
		strHtml += '<tr> '
		strHtml += '<td>'+row.Nome+'</td> '
		strHtml += '<td>'+row.Email+'</td> '
		strHtml += '<td><a href="http://localhost:5555/excluir/'+str(row.Cod_Aluno)+'">Excluir</a></td>'
		strHtml += '</tr> '
  
	strHtml += '</table> '
	strHtml += '</body> '
	strHtml += '</html> '
	return strHtml

@app.route('/excluir/<idUsr>')
def excluir(idUsr):
	server = 'EMPYT-4\SQLEXPRESS' 
	database = 'Trabalho'  
	cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database)
	cursor = cnxn.cursor()

	cursor.execute("delete from Dados_Alunos where Cod_Aluno ='" + idUsr + "'")
	cursor.commit()
	cursor.close()
	return "Usuário com o código:" + idUsr + " excluido com sucesso!"
	  

if __name__ == '__main__':
	import os
	HOST = os.environ.get('SERVER_HOST', 'localhost')
	try:
		PORT = int(os.environ.get('SERVER_PORT', '5555'))
	except ValueError:
		PORT = 5555
	app.run(HOST, PORT)
	app.run(debug = True)