import pyodbc

#CRUD de alunos junto do pyodbc + SQL

#instanciar objeto > classe = objeto
def trac():
    print('--------------------------------------')

def all():
    print('COD |   NOME   | IDADE | GENERO | OBJ-GRAD | E-MAIL | DT-NASC')
    

class Aluno():    #parametro \/
    def __init__(self,nomeAluno,DtNascimentoAluno,idadeAluno,objetivoGraduacaoAluno,GeneroAluno,EmailAluno):
        self.nome = nomeAluno  # <-- propriedade
        self.dtNascimento = DtNascimentoAluno
        self.idade = idadeAluno
        self.objetivoGraduacao = objetivoGraduacaoAluno
        self.genero = GeneroAluno
        self.email = EmailAluno
        
    def ListarPorEmail(self):
        server = 'EMPYT-4\SQLEXPRESS'
        database = 'Trabalho'
        conn = 'DRIVER={SQL Server};SERVER='+server+';DATABASE='+database
        cnxn = pyodbc.connect(conn)
        cursor = cnxn.cursor()
        cursor.execute("SELECT Cod_Aluno, Nome, Idade, Data, Email, Obj_Grad, Genero FROM Dados_Alunos where email = '{}'" .format(self.email))
        result_set = cursor.fetchall()
        for row in result_set:
            trac()
            print(row.Cod_Aluno, ' | ',row.Nome, ' | ' , row.Idade, ' | ', row.Genero, ' | ', row.Data, ' | ', row.Email, ' | ', row.Obj_Grad )
            trac()

    def ListarTodos(self):
        server = 'EMPYT-4\SQLEXPRESS'
        database = 'Trabalho'
        conn = 'DRIVER={SQL Server};SERVER='+server+';DATABASE='+database
        cnxn = pyodbc.connect(conn)
        cursor = cnxn.cursor()
        cursor.execute("SELECT * FROM Dados_Alunos ")
        result_set = cursor.fetchall()
        all()
        for row in result_set:
            print(row.Cod_Aluno, '  |  ',row.Nome, '  |  ', row.Idade, ' | ', row.Genero, ' | ', row.Obj_Grad, ' | ', row.Email, ' | ', row.Data)
            trac()

    def InserirUsuario(self):
        server = 'EMPYT-4\SQLEXPRESS'
        database = 'Trabalho'
        conn = 'DRIVER={SQL Server};SERVER='+server+';DATABASE='+database
        cnxn = pyodbc.connect(conn)
        cursor = cnxn.cursor()
        sql = "INSERT INTO Dados_Alunos (nome,Data,idade,obj_grad,genero,email) VALUES ('{}','{}','{}','{}','{}','{}')".format(self.nome,self.dtNascimento,self.idade,self.objetivoGraduacao,self.genero,self.email)
        cursor.execute(sql)
        cursor.commit()
        cursor.close()

    def AlterarUsuario(self):
        server = 'EMPYT-4\SQLEXPRESS'
        database = 'Trabalho'
        conn = 'DRIVER={SQL Server};SERVER='+server+';DATABASE='+database
        cnxn = pyodbc.connect(conn)
        cursor = cnxn.cursor()
        sql = "Update Dados_Alunos SET ".format(self.nome)
        if (self.nome != ''):
            sql += "Nome = '{}', ".format(self.nome)
        if (self.idade != ""):
            sql += "Idade = {}, ".format(self.idade)
        if (self.dtNascimento != ""):
            sql += "Data = '{}', ".format(self.dtNascimento)
        if (self.objetivoGraduacao != ""):
            sql += "Obj_Grad = '{}', ".format(self.objetivoGraduacao)
        if (self.genero != ""):
            sql += "Genero = '{}', ".format(self.genero)
        sql = sql[:-2]
        sql += " WHERE email = '{}'".format(self.email)
        print (sql)
        cursor.execute(sql)
        cursor.commit()
        cursor.close()

    def DeletarUsuario(self):
        server = 'EMPYT-4\SQLEXPRESS'
        database = 'Trabalho'
        conn = 'DRIVER={SQL Server};SERVER='+server+';DATABASE='+database
        cnxn = pyodbc.connect(conn)
        cursor = cnxn.cursor()
        sql = "DELETE FROM Dados_Alunos WHERE email = '{}'".format(self.email)
        cursor.execute(sql)
        cursor.commit()
        cursor.close()

    




print('######  #####   #    #####  ######   ')   
print('#       #   #   #    #      #    #   ')   
print('#####   #####   #    #####  ######   ')  
print('#       #   #   #        #  #        ') 
print('#       #   #   #    #####  #        ') 
msg = ("Inserir usuário -> (1) \nDeletar usuário -> (2) \nAlterar usuario -> (3) \nListar usuários -> (4) \nListar por E-Mail (5) \nSair (6) \t\nFaça sua escolha: ")
ret = int(input(msg))
certeza = 'nao'
while (certeza == 'nao'):
    print('\n')

          



        
    if (ret == 1):
        nome = input("Digite o nome: ")
        dtNascimento = input("Digite a data de Nascimento: ")
        idade = input("Digite a idade: ")
        objetivoGraduacao = input("Digite a graduação: ")
        genero = input("Digite o genero(1 - Masculino | 2 - Feminino):  ")
        email = input("Digite o E-mail: ")
        trac()
        print('Informações gravadas com sucesso!')
        trac()
        objAluno = Aluno(nome,dtNascimento,idade,objetivoGraduacao,genero,email,)
        objAluno.InserirUsuario()
        
        

    elif (ret == 2):
        objAluno = Aluno("","","","","","")
        objAluno.ListarTodos()
        email = input("Digite o E-Mail: ")
        objAluno = Aluno("","","","","",email)
        if (input('Tem certeza que deseja excluir o usuário? A ação não poderá ser desfeita (S/N): ') == 'S'):
            trac()
            print('\tUsuario deletado com sucesso!')
            trac()
            objAluno.DeletarUsuario()

        

    elif (ret == 3):
        objAluno = Aluno("","","","","","")
        objAluno.ListarTodos()
        email = input("Digite o E-Mail que deseja alterar: ")
        nome = input("Digite o nome (deixe em branco se não quiser alterar): ")
        dtNascimento = input("Digite a data de Nascimento (deixe em branco se não quiser alterar): ")
        idade = input("Digite o idade (deixe em branco se não quiser alterar): ")
        obetivoGraduacao = input("Digite a graduação (deixe em branco se não quiser alterar): ")
        genero = input("Digite o genero (deixe em branco se não quiser alterar): ")
        objAluno = Aluno(nome,dtNascimento,idade,obetivoGraduacao,genero,email)
        objAluno.AlterarUsuario()
        trac()
        print('Usuario alterado com sucesso!')
        trac()
        
    
        

    elif (ret == 4):
        objAluno = Aluno("","","","","","")
        email = input("Digite o E-Mail: ")
        objAluno.ListarTodos()

        

    elif (ret == 5):
        email = input("Digite o E-Mail: ")
        objAluno = Aluno("","","","","",email)
        objAluno.ListarPorEmail()

    


    elif (ret == 6):
        certeza = input('\tTem certeza que deseja sair?\n As informações não salvas serão perdidas! (sim/nao): ')
        if certeza =='sim':
            continue
    
    ret = int(input(msg))
