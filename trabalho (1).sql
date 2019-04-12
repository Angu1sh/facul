IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Dados_Alunos' )
BEGIN

CREATE TABLE Dados_Alunos
(
	Cod_Aluno INTEGER IDENTITY(1,1) ,
	Nome VARCHAR(100),
	Data VARCHAR(10),
	Idade INTEGER,
	Obj_Grad VARCHAR(1000),
	Genero INTEGER,
	Email VARCHAR(100)
)

ALTER TABLE Dados_Alunos
ADD CONSTRAINT PK_Cod_Aluno PRIMARY KEY (Cod_Aluno)

END
GO

IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Genero' )
BEGIN

CREATE TABLE Genero
(
	Cod_Genero INTEGER IDENTITY(1,1),
	Genero VARCHAR(30)
)

ALTER TABLE Genero
ADD CONSTRAINT PK_Cod_Genero PRIMARY KEY (Cod_Genero)

END
GO

IF NOT EXISTS ( SELECT * FROM SYS.foreign_keys WHERE parent_object_id = OBJECT_ID('Dados_Alunos') AND name = 'FK_Cod_Aluno') 
BEGIN
	ALTER TABLE Dados_Alunos
	ADD CONSTRAINT FK_Cod_Aluno FOREIGN KEY(Genero)
	REFERENCES GENERO(Cod_Genero)
END
GO




IF NOT EXISTS(SELECT * FROM Genero WHERE Genero = 'MASCULINO')
BEGIN
INSERT INTO Genero ( Genero) VALUES ('MASCULINO')
END
GO


IF NOT EXISTS(SELECT * FROM Genero WHERE Genero = 'FEMININO')
BEGIN
INSERT INTO Genero ( Genero) VALUES ('FEMININO')
END


IF OBJECT_ID('Retorna_Genero') IS NOT NULL
BEGIN
	DROP PROCEDURE Retorna_Genero
END
GO


CREATE PROCEDURE Retorna_Genero
AS
BEGIN
	SELECT Genero FROM Genero 
END
GO


IF OBJECT_ID('Insere_Genero') IS NOT NULL
BEGIN
	DROP PROCEDURE Insere_Genero
END
GO

CREATE PROCEDURE Insere_Genero
(
	@Novo_Genero VARCHAR(30)
)

AS
BEGIN
	INSERT INTO Genero (Genero) VALUES (@Novo_Genero)
END
GO


IF OBJECT_ID('FN_VALIDA_TEXTO_SEM_NUMERO') IS NOT NULL
BEGIN
	DROP FUNCTION FN_VALIDA_TEXTO_SEM_NUMERO
END
GO

CREATE FUNCTION FN_VALIDA_TEXTO_SEM_NUMERO
(
	@TEXTO_A_VALIDAR VARCHAR(255)
)
RETURNS VARCHAR(30)
AS
BEGIN
	DECLARE @TEXTO_APENAS VARCHAR(30)
	
	SELECT @TEXTO_APENAS =
		CASE 
			WHEN @TEXTO_A_VALIDAR LIKE '%[0-9]%' 
			THEN 'POSSUI NUMEROS' 
			ELSE 'NÃO POSSUI NUMEROS' 
		END

	-- RETORNA: 0 --> POSSUI NÚMEROS NO TEXTO INFORMADO 
	-- RETORNA: 1 --> SOMENTE TEXTO( NÃO POSSUI NO TEXTO INFORMADO
	RETURN @TEXTO_APENAS
END
GO

IF OBJECT_ID('FN_RESTAM_N_VALORES') IS NOT NULL
BEGIN
	DROP FUNCTION FN_RESTAM_N_VALORES
END
GO

CREATE FUNCTION FN_RESTAM_N_VALORES
(
	@TEXTO_DIGITADO VARCHAR(1000),
	@QUANTIDADE_LIMITE INTEGER
)
RETURNS INTEGER
AS
BEGIN
	DECLARE @QUANTIDADE_DIGITADA INTEGER
	DECLARE @TOTAL_RESTANTE INTEGER

	SELECT @QUANTIDADE_DIGITADA = LEN( @TEXTO_DIGITADO )

	SET @TOTAL_RESTANTE = @QUANTIDADE_LIMITE - @QUANTIDADE_DIGITADA
	
	RETURN @TOTAL_RESTANTE
END
GO


IF OBJECT_ID('SP_RETORNA_DADOS') IS NOT NULL
BEGIN
	DROP PROCEDURE SP_RETORNA_DADOS
END
GO

CREATE PROCEDURE SP_RETORNA_DADOS
(
	@NOME VARCHAR(255) = ''
)
AS
BEGIN
	IF @NOME = ''
		BEGIN
			SELECT * FROM Dados_Alunos
		END
	ELSE
		BEGIN
			SELECT * FROM Dados_Alunos WHERE Nome LIKE '%'+ @NOME + '%'
		END
END

GO


----------------------------------------------------------
-- CRIA PROCEDURE PARA INSERIR DADOS DOS ALUNOS
----------------------------------------------------------
IF OBJECT_ID('INSERE_DADOS') IS NOT NULL
BEGIN
	DROP PROCEDURE INSERE_DADOS
END
GO

CREATE PROCEDURE INSERE_DADOS
(
	@NOME			VARCHAR(255),
	@DATA		VARCHAR(10),
	@IDADE      INTEGER,
	@OBJ_GRAD	VARCHAR(1000),
	@COD_GENERO			INTEGER
)
AS
BEGIN
SET NOCOUNT ON

	-- ---------------------------------------------------------------
	-- SE O CAMPO "NOME COMPLETO" FOR NULO OU VAZIO, RETORNA ERRO:
	-- ---------------------------------------------------------------
	IF ISNULL( LTRIM(RTRIM(@NOME)), '' ) = '' 
		BEGIN
			-- ---------------------------------------------------------------
			-- SE NOME FOR NULO OU VAZIO, RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo [Nome] deve ser preenchido.'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- ---------------------------------------------------------------
	-- SE O CAMPO "DATA" FOR NULO OU VAZIO, RETORNA ERRO:
	-- ---------------------------------------------------------------
	IF ISNULL( LTRIM(RTRIM(@DATA)), '' ) = '' 
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR NULO OU VAZIO, RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo [Data de Nascimento] deve ser preenchido.'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- ---------------------------------------------------------------
	-- SE O CAMPO "COD_GENERO" FOR NULO OU VAZIO, RETORNA ERRO:
	-- ---------------------------------------------------------------
	IF ISNULL( @COD_GENERO, 0 ) <= 0 
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR NULO OU VAZIO, RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o Codigo do Gênero deve ser informado.'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- ----------------------------------------------------------------
	-- REGRA DE NEGÓCIO 2
	-- ----------------------------------------------------------------
	-- NÃO DEVERÁ SER ACEITO NÚMEROS NO CAMPO [NOME]
	-- ----------------------------------------------------------------
	DECLARE @TEXTO_APENAS VARCHAR(30)

	-- FUNÇÃO [FN_VALIDA_TEXTO_SEM_NUMERO ]
	EXECUTE @TEXTO_APENAS = FN_VALIDA_TEXTO_SEM_NUMERO @NOME

	IF @TEXTO_APENAS = 'POSSUI NUMEROS'
		BEGIN
			-- ---------------------------------------------------------------
			-- SE EXISTE NUMEROS NO CAMPO NOME COMPLETO RETORNA ERRO:
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Nome deve ser preenchido sem números'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- -----------------------------------------------------------------------
	-- VALIDA FORMATO DATA ( DD/MM/AAAA
	-- -----------------------------------------------------------------------
	DECLARE @DATA_INVALIDA BIT
	SET @DATA_INVALIDA = 0

	IF ISNUMERIC(LEFT(@DATA, 2)) = 0
		BEGIN
			SET @DATA_INVALIDA = 1
		END 
	
	IF ISNUMERIC(SUBSTRING(@DATA, 4, 2 )) = 0
		BEGIN
			SET @DATA_INVALIDA = 1
		END 

	IF ISNUMERIC(RIGHT(@DATA, 4 )) = 0
		BEGIN
			SET @DATA_INVALIDA = 1
		END 

	IF SUBSTRING(@DATA, 3, 1 ) != '/'
		BEGIN
			SET @DATA_INVALIDA = 1
		END

	IF SUBSTRING(@DATA, 6, 1 ) != '/'
		BEGIN
			SET @DATA_INVALIDA = 1
		END

	IF @DATA_INVALIDA = 1
		BEGIN
			-- ---------------------------------------------------------------
			-- SE ALGUMA DAS VALIDACOES FOI POSITIVA, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Data de Nascimento está fora do padrão DD/MM/AAAA.'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- POSSIBILIDADE DE VALIDAR SE DIGITOS DO MÊS ENTRE 1 E 12

	-- POSSIBILIDADE DE VALIDAR SE DIGITOS DO MÊS ENTRE 1 E 31

	-- -----------------------------------------------------------------------
	-- REGRA DE NEGÓCIO 3:
	-- -----------------------------------------------------------------------
	-- NUMERO DE CARACTERES POSSÍVEIS É (10) SENDO 8 NUMEROS E 2 ALFANUMERICOS(/)
	-- -----------------------------------------------------------------------

	IF LEN(@DATA) != 10
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR MENOR QUE 1950, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Data de Nascimento informado deve conter 10 caracteres( DD/MM/AAAA ).'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- -----------------------------------------------------------------------
	-- REGRA DE NEGÓCIO 3:
	-- -----------------------------------------------------------------------
	-- MENOR DATA A SER ACEITA É 01/01/2015
	-- -----------------------------------------------------------------------

	IF RIGHT(@DATA, 4 ) < 1950
		BEGIN
			-- ---------------------------------------------------------------
			-- SE DATA DE NASCIMENTO FOR MENOR QUE 1950, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'Erro: o campo Data de Nascimento informado deve ser maior que 01/01/1950.'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END

	-- -----------------------------------------------------------------------
	-- REGRA DE NEGÓCIO 4:
	-- -----------------------------------------------------------------------
	-- A IDADE DEVERÁ SER CALCULADA AUTOMATICAMENTE
	-- -----------------------------------------------------------------------
	
	DECLARE @DATA_CONVERTIDA VARCHAR(10)
	SET @DATA_CONVERTIDA = RIGHT(@DATA, 4) + '-' + 
							  SUBSTRING(@DATA, 4, 2 )+ '-' +
							  LEFT(@DATA, 2)   
							  	
	-- SELECT @DATA_CONVERTIDA 
	SET @IDADE = DATEDIFF( YEAR, @DATA_CONVERTIDA  , GETDATE() )
	-- SELECT @IDADE 
	-- -----------------------------------------------------------------------
	-- VALIDA SE O ID DO GÊNERO INFORMADO COINCIDE COM A TABELA DE GENEROS
	-- -----------------------------------------------------------------------
	IF NOT EXISTS( SELECT * FROM Genero WHERE Cod_Genero = @COD_GENERO )
		BEGIN
			-- ---------------------------------------------------------------
			-- SE ALGUMA DAS VALIDACOES FOI POSITIVA, RETORNA ERRO
			-- ---------------------------------------------------------------
			PRINT 'ERRO DE SISTEMA: o campo COD_GENERO informado deve existir na tabela GENERO'

			-- ---------------------------------------------------------------
			-- SAI DA PROCEDURE
			-- ---------------------------------------------------------------
			RETURN
		END
	
	----------------------------------------------------------------------------
	-- FINALMENTE INSERE OS DADOS!!!
	----------------------------------------------------------------------------
	BEGIN TRY
		INSERT INTO [Dados_Alunos]
		(
			Nome,
			Data,
			Idade,
			Obj_Grad,
			Genero
		)
		VALUES
		(
			@NOME,
			@DATA,
			@IDADE,
			@OBJ_GRAD,
			@COD_GENERO
		)

		PRINT 'Registro inserido com sucesso na tabela [Dados_Alunos] com o Cod:' + CAST( @@IDENTITY AS VARCHAR(20) )

	END TRY
	BEGIN CATCH
		-- ---------------------------------------------------------------
		-- SE ALGUMA DAS VALIDACOES FOI POSITIVA, RETORNA ERRO
		-- ---------------------------------------------------------------
		SELECT ERROR_MESSAGE()
		
	END CATCH	

END
GO



SELECT * FROM Dados_Alunos







