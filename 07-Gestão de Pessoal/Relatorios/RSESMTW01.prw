#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"

/*
Autor: RODRIGO LUCAS
Data: 09/11/11
Descrição: WORKFLOW QUE ATUALIZA O CAMPO B1_ycorpro.
*/

User Function RSCHED01()

	If Select('SX2') == 0
		RPCSetType( 3 )                              //Não consome licensa de uso
		RpcSetEnv('01','010101',,,,GetEnvServer(),{ "SRA" })
		sleep( 5000 )                              //Aguarda 5 segundos para que as jobs IPC subam.
		ConOut('Enviando e-mail dos Funcionários x Atestados... '+Dtoc(DATE())+' - '+Time())
		lAuto := .T.
	EndIf

	If     ( ! lAuto )
		LjMsgRun(OemToAnsi('Enviando e-mail dos Funcionários x Atestados...'),,{|| U_RSESMTW01()} )
	Else
		U_RSESMTW01()
	EndIf

	If     ( lAuto )
		RpcClearEnv()                                 //Libera o Environment
		ConOut('E-mail enviado... '+Dtoc(DATE())+' - '+Time())
	EndIf

return

User Function RSESMTW01()

	cQuery := " SELECT
	cQuery += " TNY_FILIAL EMPRESA, RA_MAT,  RA_NOME, CTT_DESC01  , RJ_DESC , RA_NASC,RA_ADMISSA,RA_VCTOEXP, RA_VCTEXP2, RA_SITFOLH, SUM(TNY_QTDIAS) TOTAL_DIAS, COUNT(*) CONT FROM "+RETSQLNAME("TNY")+" TNY "
	cQuery += " INNER JOIN "+RETSQLNAME("TM0")+" TM0 ON  TM0_FILIAL = TNY_FILIAL AND TM0_NUMFIC = TNY_NUMFIC AND TM0.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RETSQLNAME("SRA")+" RA ON RA_FILIAL = TM0_FILFUN AND RA_MAT = TM0_MAT AND RA.D_E_L_E_T_ = ' ' AND RA_SITFOLH <> 'D' "
	cQuery += " INNER JOIN "+RETSQLNAME("TLG")+" TLG ON TLG_FILIAL = TNY_FILIAL AND TLG_GRUPO = TNY_GRPCID AND TLG.D_E_L_E_T_ = ' '  "
	cQuery += " INNER JOIN "+RETSQLNAME("TMR")+" TMR ON TMR_FILIAL = ' ' AND TMR_CID =TNY_CID AND TMR.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RETSQLNAME("SRJ")+" RJ ON RJ_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RJ_FUNCAO = RA_CODFUNC AND RJ.D_E_L_E_T_ = ' '  "
	cQuery += " WHERE "
	cQuery += " SUBSTRING(TNY_DTINIC,1,6) >= '20190101' AND "
//cQuery += " SUBSTRING(TNY_DTFIM,1,6) >= SUBSTRING(CONVERT(CHAR(8), GETDATE(),112),1,6) AND "
	cQuery += " TNY.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY TNY_FILIAL , RA_MAT,  RA_NOME , CTT_DESC01  , RJ_DESC , RA_NASC,RA_ADMISSA,RA_VCTOEXP, RA_VCTEXP2, RA_SITFOLH ORDER BY TNY_FILIAL , RA_MAT "


	TcQuery cQuery new alias "T01"

	DBSELECTAREA("T01")
	T01->(DBGOTOP())

	_cHtml := " <table cellpadding='1' cellspacing='2' height='100%' width='100%' style='font-size:11px;'> "
	_cHtml += " <thead><tr> "
	_cHtml += " <th style='text-align:center;'>Empresa</th>"
	_cHtml += " <th style='text-align:center;'>Matrícula</th>"
	_cHtml += " <th style='text-align:center;'>Nome</th>"
	_cHtml += " <th style='text-align:center;'>Centro Custo</th>"
	_cHtml += " <th style='text-align:center;'>Função</th>"
	_cHtml += " <th style='text-align:center;'>Data Admissão</th>"
	_cHtml += " <th style='text-align:center;'>Venc. Experiência 1</th>"
	_cHtml += " <th style='text-align:center;'>Venc. Experiência 2</th>"
	_cHtml += " <th style='text-align:center;'>Dias Experiência</th>"
//	_cHtml += " <th style='text-align:center;'>Sit. Folha</th>"
	_cHtml += " <th style='text-align:center;'>Qtd. Dias Atestado</th>"
	_cHtml += " <th style='text-align:center;'>Qtd. Atestados</th>"
	_cHtml += " </tr></thead><tbody> "

	_cfilial:= T01->EMPRESA
	_imp := .f.
	WHILE !T01->(eof())

		if (!empty(T01->RA_VCTOEXP) .AND. STOD(T01->RA_VCTOEXP) >= DDATABASE ) .OR. (!empty(T01->RA_VCTEXP2) .AND. STOD(T01->RA_VCTEXP2) >= DDATABASE )
			_imp := .t.
			_cHtml += " <tr> "
			_cHtml += " <td style='text-align:center;'>" + T01->EMPRESA + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(T01->RA_MAT) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(T01->RA_NOME) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(T01->CTT_DESC01) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(T01->RJ_DESC) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(DTOC(STOD(T01->RA_ADMISSA))) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(DTOC(STOD(T01->RA_VCTOEXP))) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + RTRIM(DTOC(STOD(T01->RA_VCTEXP2))) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + cValtoChar(DateDiffDay( STOD(T01->RA_ADMISSA), ddatabase)) + "</td> "
			//	_cHtml += " <td style='text-align:center;'>" + RTRIM(T01->RA_SITFOLH) + "</td> "
			_cHtml += " <td style='text-align:center;'>" + TRANSFORM(T01->TOTAL_DIAS, "@E 9999") + "</td> "
			_cHtml += " <td style='text-align:center;'>" + TRANSFORM(T01->CONT, "@E 9999") + "</td> "
			_cHtml += " </tr> "
		endif
		T01->(dbSkip())
		if substr(_cfilial,1,2) <> substr(T01->EMPRESA,1,2)

			cAssunto := "Funcionário x Temp Experiência x Atestado- "+substr(_cfilial,1,2)
			//cPara := "rodrigolucas@mconsult.com.br;vicentejuniormanager@gmail.com;controller3@gruposervnac.com.br;erinalva@gruposervnac.com.br;gestoraoperacional@gruposervnac.com.br"
			cPara := "controller3@gruposervnac.com.br;erinalva@gruposervnac.com.br;gestoraoperacional@gruposervnac.com.br;gerenteti@gruposervnac.com.br"
			if substr(_cfilial,1,2) $ "03,04,06"
				cPara += ";gerentefacilities@gruposervnac.com.br"
			endif
			if substr(_cfilial,1,2) $ "01,05"
				cPara += ";gerentedeseguranca@gruposervnac.com.br"
			endif
			if substr(_cfilial,1,2) $ "02,04"
				cPara += ";alexandre@gruposervnac.com.br"
			endif
			if _imp
				u_MailSERV(cPara, cAssunto, _cHtml)
			endif
			_imp := .f.
			_cHtml := " <table cellpadding='1' cellspacing='2' height='100%' width='100%' style='font-size:11px;'> "
			_cHtml += " <thead><tr> "
			_cHtml += " <th style='text-align:center;'>Empresa</th>"
			_cHtml += " <th style='text-align:center;'>Matrícula</th>"
			_cHtml += " <th style='text-align:center;'>Nome</th>"
			_cHtml += " <th style='text-align:center;'>Centro Custo</th>"
			_cHtml += " <th style='text-align:center;'>Função</th>"
			_cHtml += " <th style='text-align:center;'>Data Admissão</th>"
			_cHtml += " <th style='text-align:center;'>Venc. Experiência 1</th>"
			_cHtml += " <th style='text-align:center;'>Venc. Experiência 2</th>"
			_cHtml += " <th style='text-align:center;'>Dias Experiência</th>"
//	_cHtml += " <th style='text-align:center;'>Sit. Folha</th>"
			_cHtml += " <th style='text-align:center;'>Qtd. Dias Atestado</th>"
			_cHtml += " <th style='text-align:center;'>Qtd. Atestados</th>"
			_cHtml += " </tr></thead><tbody> "
			_cfilial:= T01->EMPRESA
			_imp := .f.
		endif

	Enddo
	if _imp
		cAssunto := "Funcionário x Tempo Experiência x Atestado - "+substr(_cfilial,1,2)
		//cPara := "rodrigolucas@mconsult.com.br;vicentejuniormanager@gmail.com;controller3@gruposervnac.com.br;erinalva@gruposervnac.com.br;gestoraoperacional@gruposervnac.com.br"
		cPara := "controller3@gruposervnac.com.br;erinalva@gruposervnac.com.br;gestoraoperacional@gruposervnac.com.br"
		if substr(_cfilial,1,2) $ "03,04,06"
			cPara += ";gerentefacilities@gruposervnac.com.br"
		endif
		if substr(_cfilial,1,2) $ "01,05"
			cPara += ";gerentedeseguranca@gruposervnac.com.br"
		endif
		if substr(_cfilial,1,2) $ "02,04"
			cPara += ";alexandre@gruposervnac.com.br"
		endif
		u_MailSERV(cPara, cAssunto, _cHtml)
	endif
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
	T01->(dbCloseArea())


Return
