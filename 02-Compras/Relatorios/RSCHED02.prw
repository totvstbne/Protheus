#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"

/*
Autor: RODRIGO LUCAS
Data: 09/11/11
Descrição: WORKFLOW QUE ATUALIZA O CAMPO B1_ycorpro.
*/

User Function RSCHED02()

	If Select('SX2') == 0
		RPCSetType( 3 )                              //Não consome licensa de uso
		RpcSetEnv('01','010101',,,,GetEnvServer(),{ "SRA" })
		sleep( 5000 )                              //Aguarda 5 segundos para que as jobs IPC subam.
		ConOut('Enviando e-mail dos Funcionários x Atestados... '+Dtoc(DATE())+' - '+Time())
		lAuto := .T.
	EndIf

	If     ( ! lAuto )
		LjMsgRun(OemToAnsi('Enviando e-mail dos Funcionários x Atestados...'),,{|| U_RCOMW01()} )
	Else
		U_RCOMW01()
	EndIf

	If     ( lAuto )
		RpcClearEnv()                                 //Libera o Environment
		ConOut('E-mail enviado... '+Dtoc(DATE())+' - '+Time())
	EndIf

return

User Function RCOMW01()

	CQUERY :=  	"   SELECT CR.CR_FILIAL FILIAL, CR.CR_NUM NUM, CR.CR_TIPO TIPO, CR.CR_NIVEL NIVEL, CR.CR_GRUPO GRUPO, CR.CR_EMISSAO EMISSAO, CR.CR_TOTAL TOTAL, CR2.CR_USER USUARIO, CR2.CR_DATALIB DATALIB "
	CQUERY +=  	" 	FROM "+RETSQLNAME("SCR")+" CR "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("SCR")+" CR2 ON CR2.CR_FILIAL = CR.CR_FILIAL AND CR2.CR_NUM = CR.CR_NUM AND CR2.CR_NIVEL = '02' AND CR2.CR_STATUS = '03' AND CR2.D_E_L_E_T_ = ' ' AND CR2.CR_GRUPO = CR.CR_GRUPO AND CR2.CR_DATALIB <> ' ' "
	CQUERY +=  	" 	WHERE CR.CR_USER = '000069' AND CR.D_E_L_E_T_ = ' ' AND CR.CR_STATUS = '02' ORDER BY CR.CR_TIPO, CR.CR_FILIAL "

	TcQuery cQuery new alias "T01"

	DBSELECTAREA("T01")
	T01->(DBGOTOP())
	_cHtml := "	<p> PC_PF APROVADOS PELA CONTROLADORIA</p>
	_cHtml += " <table cellpadding='1' cellspacing='2' height='100%' width='100%' style='font-size:11px;'> "
	_cHtml += " <thead><tr> "
	_cHtml += " <th style='text-align:left;'>Empresa</th>"
	_cHtml += " <th style='text-align:left;'>Número</th>"
	_cHtml += " <th style='text-align:left;'>Tipo</th>"
	_cHtml += " <th style='text-align:left;'>Fornecedor</th>"
	_cHtml += " <th style='text-align:left;'>Emissão</th>"
	_cHtml += " <th style='text-align:left;'>Aprovador 1</th>"
	_cHtml += " <th style='text-align:left;'>Data Liberação 1</th>"
	_cHtml += " <th style='text-align:left;'>Aprovador 2</th>"
	_cHtml += " <th style='text-align:left;'>Data Liberação 2</th>"
	_cHtml += " <th style='text-align:left;'>Valor</th>"
	_cHtml += " <th style='text-align:left;'>Mensagem</th>"

	_cHtml += " </tr></thead><tbody> "
	_ncont:= 0
	_nvalor := 0
	WHILE !T01->(eof())
		_CNOMEFOR := ""
		_MSG := ""

		DBSELECTAREA("SCR")
		DBSETORDER(2)
		DBSEEK(T01->FILIAL+T01->TIPO+T01->NUM+T01->USUARIO)
		_MSG := MsMM(SCR->CR_OBS)
		IF T01->TIPO == "PC"
			DBSELECTAREA("SC7")
			DBSETORDER(1)
			DBSEEK(T01->FILIAL+ALLTRIM(T01->NUM))
			_CNOMEFOR := POSICIONE("SA2",1,XFILIAL("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NOME")

		ELSEIF T01->TIPO == "PF"
			DBSELECTAREA("ZA7")
			DBSETORDER(2)
			DBSEEK(SUBSTR(T01->FILIAL,1,2)+"    "+T01->NUM)
			_CNOMEFOR := ZA7->ZA7_NOMFOR

		ENDIF
		_imp := .t.
		cquery := " SELECT CR_USERLIB, CR_DATALIB, CR_NIVEL FROM "+RETSQLNAME("SCR")+" WHERE CR_FILIAL = '"+T01->FILIAL+"' AND CR_TIPO = '"+T01->TIPO+"' AND CR_NUM = '"+T01->NUM+"' AND CR_STATUS = '03' AND D_E_L_E_T_ = ' ' ORDER BY CR_NIVEL"

		TcQuery cQuery new alias "T02"

		DBSELECTAREA("T02")
		T02->(DBGOTOP())
		_cHtml += " <tr> "
		_cHtml += " <td style='text-align:left;'>" + T01->FILIAL + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(T01->NUM) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(T01->TIPO) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(_CNOMEFOR) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(DTOC(STOD(T01->EMISSAO))) + "</td> "
		_NCONT4:= 1
		WHILE _NCONT4 <= 2
			IF !T02->(EOF())
				_cHtml += " <td style='text-align:left;'>" + RTRIM(FwGetUserName(T02->CR_USERLIB)) + "</td> "
				_cHtml += " <td style='text-align:left;'>" + RTRIM(DTOC(STOD(T02->CR_DATALIB))) + "</td> "
				T02->(DBSKIP())
			ELSE
				_cHtml += " <td style='text-align:left;'>" + RTRIM("") + "</td> "
				_cHtml += " <td style='text-align:left;'>" + RTRIM(DTOC(STOD(""))) + "</td> "
			ENDIF

			_NCONT4++
		ENDDO
		T02->(dbCloseArea())
		
		_cHtml += " <td style='text-align:left;'>" + TRANSFORM(T01->TOTAL, "@E 999,999,999.99") + "</td> "
		_cHtml += " <td style='text-align:left;'>" + ALLTRIM(_MSG) + "</td> "
		_cHtml += " </tr> "

		_ncont++
		_nvalor += T01->TOTAL

		T01->(dbSkip())


	Enddo
	_cHtml += " </table> "
	T01->(dbCloseArea())
	_cHtml += "	<p> Qtd. Pedidos: "+alltrim(str(_ncont))+"  </p>"
	_cHtml += "	<p> Valor Total Pedidos: R$ "+TRANSFORM(_nvalor, "@E 999,999,999.99") +"  </p>"
	_cHtml += "	<p> ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ </p>
	_cHtml += "	<p> PC_PF por Centro de Custo </p>
	_cHtml += " <table cellpadding='1' cellspacing='2' height='100%' width='100%' style='font-size:11px;'> "
	_cHtml += " <thead><tr> "
	_cHtml += " <th style='text-align:left;'>Empresa</th>"
	_cHtml += " <th style='text-align:left;'>Tipo</th>"
	_cHtml += " <th style='text-align:left;'>Centro de custo</th>"
	_cHtml += " <th style='text-align:left;'>Valor</th>"

	_cHtml += " </tr></thead><tbody> "


	CQUERY :=  	"   SELECT CR.CR_FILIAL FILIAL, CTT_DESC01 CC, CR.CR_TIPO TIPO, SUM(C7_TOTAL) TOTAL "
	CQUERY +=  	" 	FROM "+RETSQLNAME("SCR")+" CR "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("SC7")+" C7  ON C7_FILIAL = CR.CR_FILIAL AND C7_NUM = CR.CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(CR.CR_FILIAL,1,2) AND CTT_CUSTO = C7_CC AND CTT.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	WHERE CR.CR_USER = '000069' AND CR.D_E_L_E_T_ = ' ' AND CR.CR_STATUS = '02' AND CR.CR_TIPO = 'PC' GROUP BY CR.CR_FILIAL, CTT_DESC01 , CR.CR_TIPO  ORDER BY CR.CR_FILIAL, CTT_DESC01 "

	TcQuery cQuery new alias "T01"

	DBSELECTAREA("T01")
	T01->(DBGOTOP())


	WHILE !T01->(eof())

		_imp := .t.
		_cHtml += " <tr> "
		_cHtml += " <td style='text-align:left;'>" + T01->FILIAL + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(T01->TIPO) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + ALLTRIM(T01->CC) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + TRANSFORM(T01->TOTAL, "@E 999,999,999.99") + "</td> "
		_cHtml += " </tr> "

		T01->(dbSkip())


	Enddo
	T01->(dbCloseArea())

	CQUERY :=  	"   SELECT CR.CR_FILIAL FILIAL, CTT_DESC01 CC, CR.CR_TIPO TIPO, SUM(ZA7_VALOR) TOTAL "
	CQUERY +=  	" 	FROM "+RETSQLNAME("SCR")+" CR "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("ZA7")+" ZA7 ON ZA7_FILIAL =  SUBSTRING(CR.CR_FILIAL,1,2) AND ZA7_CODIGO+ZA7_ANO+ZA7_PARCEL = CR_NUM AND ZA7.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(CR.CR_FILIAL,1,2) AND CTT_CUSTO = ZA7_CUSTO AND CTT.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	WHERE CR.CR_USER = '000069' AND CR.D_E_L_E_T_ = ' ' AND CR.CR_STATUS = '02' AND CR.CR_TIPO = 'PF' GROUP BY CR.CR_FILIAL, CTT_DESC01 , CR.CR_TIPO  ORDER BY CR.CR_FILIAL, CTT_DESC01 "

	TcQuery cQuery new alias "T01"

	DBSELECTAREA("T01")
	T01->(DBGOTOP())


	WHILE !T01->(eof())

		_imp := .t.
		_cHtml += " <tr> "
		_cHtml += " <td style='text-align:left;'>" + T01->FILIAL + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(T01->TIPO) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + ALLTRIM(T01->CC) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + TRANSFORM(T01->TOTAL, "@E 999,999,999.99") + "</td> "
		_cHtml += " </tr> "

		T01->(dbSkip())


	Enddo

	_cHtml += " </table> "
	T01->(dbCloseArea())

	_cHtml += "	<p> ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ </p>
	_cHtml += "	<p> PC_PF por Fornecedor </p>
	_cHtml += " <table cellpadding='1' cellspacing='2' height='100%' width='100%' style='font-size:11px;'> "
	_cHtml += " <thead><tr> "
	_cHtml += " <th style='text-align:left;'>Empresa</th>"
	_cHtml += " <th style='text-align:left;'>Tipo</th>"
	_cHtml += " <th style='text-align:left;'>Fornecedor</th>"
	_cHtml += " <th style='text-align:left;'>Valor</th>"

	_cHtml += " </tr></thead><tbody> "


	CQUERY :=  	"   SELECT CR.CR_FILIAL FILIAL, A2_NOME NOME, CR.CR_TIPO TIPO, SUM(C7_TOTAL) TOTAL "
	CQUERY +=  	" 	FROM "+RETSQLNAME("SCR")+" CR "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("SC7")+" C7 ON C7_FILIAL = CR.CR_FILIAL AND C7_NUM = CR.CR_NUM AND C7.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("SA2")+" A2 ON A2_FILIAL = '"+XFILIAL("SA2")+"' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND A2.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	WHERE CR.CR_USER = '000069' AND CR.D_E_L_E_T_ = ' ' AND CR.CR_STATUS = '02' AND CR.CR_TIPO = 'PC' GROUP BY CR.CR_FILIAL, A2_NOME , CR.CR_TIPO  ORDER BY CR.CR_FILIAL, A2_NOME "

	TcQuery cQuery new alias "T01"

	DBSELECTAREA("T01")
	T01->(DBGOTOP())


	WHILE !T01->(eof())

		_imp := .t.
		_cHtml += " <tr> "
		_cHtml += " <td style='text-align:left;'>" + T01->FILIAL + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(T01->TIPO) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + ALLTRIM(T01->NOME) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + TRANSFORM(T01->TOTAL, "@E 999,999,999.99") + "</td> "
		_cHtml += " </tr> "

		T01->(dbSkip())


	Enddo
	T01->(dbCloseArea())

	CQUERY :=  	"   SELECT CR.CR_FILIAL FILIAL, A2_NOME NOME, CR.CR_TIPO TIPO, SUM(ZA7_VALOR) TOTAL "
	CQUERY +=  	" 	FROM "+RETSQLNAME("SCR")+" CR "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("ZA7")+" ZA7 ON ZA7_FILIAL =  SUBSTRING(CR.CR_FILIAL,1,2) AND ZA7_CODIGO+ZA7_ANO+ZA7_PARCEL = CR_NUM AND ZA7.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	INNER JOIN "+RETSQLNAME("SA2")+" A2 ON A2_FILIAL = '"+XFILIAL("SA2")+"' AND A2_COD = ZA7_FORNEC AND A2_LOJA = ZA7_LOJA AND A2.D_E_L_E_T_ = ' ' "
	CQUERY +=  	" 	WHERE CR.CR_USER = '000069' AND CR.D_E_L_E_T_ = ' ' AND CR.CR_STATUS = '02' AND CR.CR_TIPO = 'PF' GROUP BY CR.CR_FILIAL, A2_NOME , CR.CR_TIPO  ORDER BY CR.CR_FILIAL, A2_NOME "

	TcQuery cQuery new alias "T01"

	DBSELECTAREA("T01")
	T01->(DBGOTOP())


	WHILE !T01->(eof())

		_imp := .t.
		_cHtml += " <tr> "
		_cHtml += " <td style='text-align:left;'>" + T01->FILIAL + "</td> "
		_cHtml += " <td style='text-align:left;'>" + RTRIM(T01->TIPO) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + ALLTRIM(T01->NOME) + "</td> "
		_cHtml += " <td style='text-align:left;'>" + TRANSFORM(T01->TOTAL, "@E 999,999,999.99") + "</td> "
		_cHtml += " </tr> "

		T01->(dbSkip())


	Enddo

	_cHtml += " </table> "
	T01->(dbCloseArea())




	cAssunto := "PC_PF APROVADOS PELA CONTROLADORIA"
	cPara := "vicentejuniormanager@gmail.com;controller3@gruposervnac.com.br;controller2@gruposervnac.com.br;gerenteti@gruposervnac.com.br"
	//cPara := "rodrigolucas@mconsult.com.br"

	u_MailSERV(cPara, cAssunto, _cHtml)

/*
nome: Lelis
email: gerentefacilities@gruposervnac.com.br
Filiais: 030101, 040101; 060101

nome: Domingos
Email: gerentedeseguranca@gruposervnac.com.br
Filiais: 010101, 010102, 050101

nome: Alexandre
email: alexandre@gruposervnac.com.br
Filiais: 020101, 040101

Nome: Nalva
Email: erinalva@gruposervnac.com.br
Filiais: todas

Nome: Andressa
email: gestoraoperacional@gruposervnac.com.br
filiais: todas
*/


Return
