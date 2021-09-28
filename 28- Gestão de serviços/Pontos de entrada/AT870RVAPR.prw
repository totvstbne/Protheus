#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
/*/{Protheus.doc} AT870RVAPR
Ponto de entrada na revisão do contrato, para gravação do centro de custo
@author Diogo
@since 12/02/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/

User function AT870RVAPR()
	//Local lRet := .T.
	//Local cCC  := ""
	//Local cEmp := cEmpAnt
	//Local nQTDCTR
	Local nSecCtr
	//Local nSecLoc
	Local cCodCC
	Local xArea 		:= GetArea()
	Local cFilBkp 		:= cFilant
	Local cDesc01 := ""
	Local aDadosAuto	:= {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
	Private lMsHelpAuto := .F.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .F.

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9")+paramIxb[1]+paramIxb[2]))

	dbSelectArea("TFJ")
	TFJ->(dbSetOrder(5))
	TFJ->(dbSeek(xFilial("TFJ")+CN9->CN9_NUMERO+paramIxb[2]))

	cQuery := ""
	cQuery += " SELECT TFL_FILIAL,TFL_LOCAL,TFL_CODIGO, TFL_YCC "
	cQuery += " FROM " + RETSQLNAME("TFJ") + " TFJ "
	cQuery += " INNER JOIN " + RETSQLNAME("TFL") + " TFL ON TFJ_FILIAL = TFL_FILIAL AND TFJ_CODIGO = TFL_CODPAI "
	cQuery += " WHERE  TFL.D_E_L_E_T_ = '' AND TFL.D_E_L_E_T_ = '' "
	cQuery += " AND TFJ_FILIAL = '" + TFJ->TFJ_FILIAL + "' "
	cQuery += " AND TFJ_CODIGO = '" + TFJ->TFJ_CODIGO + "' ORDER BY TFL_YCC DESC "

	If Select("JF01") > 0
		JF01->(dbCloseArea())
	endif

	TcQuery cQuery New Alias JF01
	nAux := 1
	nSecCtr := "001"
	_cbasecc := ""
	While !JF01->(EOF())

		if Empty(_cbasecc)
			_cbasecc := substr(JF01->TFL_YCC,1,16)
		endif
		If !empty(JF01->TFL_YCC)
			//nSecCtr := substr(JF01->TFL_YCC,7,3) //Garante a mesma sequencia
			//nAux	:= val(substr(JF01->TFL_YCC,10,3))+1 //Garante a mesma sequencia
			//nAux+= 1
			JF01->(dbSkip())
			loop
		Endif

		CQUERY := "SELECT MAX(CTT_CUSTO) CUSTO FROM " + RETSQLNAME("CTT") + " CTT WHERE CTT_CCSUP = '"+_cbasecc+"' AND CTT_CUSTO <> '"+_cbasecc+"G001' AND CTT.D_E_L_E_T_ = ' ' "

		If Select("JF02") > 0
			JF02->(dbCloseArea())
		endif
		TcQuery cQuery New Alias JF02

		nSecCtr:= strzero(1,3)
		cCodCC:=""
		If !JF02->(EOF())
			cCodCC := SUBSTR(JF02->CUSTO,1,16)+strzero((VAL(SUBSTR(JF02->CUSTO,17,4))+1),4)
			//nSecCtr := strzero(nQTDCTR,3)
		endif
		JF02->(dbCloseArea())
		/*
		cQuery2 := " SELECT  COUNT(DISTINCT CNC_NUMERO) QtdCont
		cQuery2 += " FROM " + RETSQLNAME("CNC") + " CNC
		cQuery2 += " WHERE CNC.D_E_L_E_T_=' ' 
		cQuery2 += " AND CNC_CLIENT='"+ TFJ->TFJ_CODENT+"' "
		cQuery2 += " AND CNC_FILIAL='"+ xFilial("CNC")+"' "  
		cQuery2 += " AND CNC_REVISA = '  ' "

		If Select("JF02") > 0
			JF02->(dbCloseArea())
		endif
		TcQuery cQuery2 New Alias JF02

		nSecCtr:= strzero(1,3)
		If !JF02->(EOF())
			nQTDCTR := JF02->QtdCont
			nSecCtr := strzero(nQTDCTR,3)
		endif
		JF02->(dbCloseArea())
		*/
		/*
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+TFJ->TFJ_CODENT+TFJ->TFJ_LOJA))

		// Sequencial do local
		nSecLoc := strzero(nAux,3)
		// MONTANDO CODIGO DO CC
		cCodCC := substr(TFJ->TFJ_FILIAL,1,2)+substr(SA1->A1_COD,3,4)+nSecCtr+nSecLoc
		*/
		// Posiciona o Cliente
		cQuery2 := ""
		cQuery2 += " SELECT * "
		cQuery2 += " FROM " + RETSQLNAME("ABS") + " ABS "
		cQuery2 += " WHERE ABS.D_E_L_E_T_ = '' "
		cQuery2 += " AND ABS_LOCAL = '" + JF01->TFL_LOCAL + "' "

		If Select("JF03") > 0
			JF03->(dbCloseArea())
		endif

		TcQuery cQuery2 New Alias JF03

		If !JF03->(EOF())
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If !(SA1->(dbSeek(xFilial("SA1",JF03->ABS_FILIAL) + JF03->ABS_CODIGO + JF03->ABS_LOJA)))
				Alert("Cliente não encontrado no sistema !!")
				JF03->(dbCloseArea())
				JF01->(dbCloseArea())
				RestArea(xArea)
				// Finaliza a geração do contrato
				Return
			endif
		endif
		
		//======== FIM DO POSICIONAMENTO NO CLIENTE =====
		// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos
		//{'CTT_DESC01' , cValToChar(INT(VAL(substr(CN9->CN9_NUMERO,6,11)))) + "-" + AllTrim(JF03->ABS_DESCRI), Nil},;	// Indica a Nomenclatura do Centro de Custo na Moeda 1
		IF !EMPTY(cCodCC)
			cDesc01 := cValToChar(INT(VAL(substr(CN9->CN9_NUMERO,6,11)))) + "-" + AllTrim(JF03->ABS_DESCRI)

			aDadosAuto := {{'CTT_FILIAL', substr(cFilant,1,2)		, Nil},;	// Especifica qual o Código do Centro de Custo.
			{'CTT_CUSTO'  ,cCodCC	    			    , Nil},;	// Especifica qual o Código do Centro de Custo.
			{'CTT_CLASSE' , "2"						    , Nil},;	// Especifica a classe do Centro de Custo, que  poderá ser: - Sintética: Centros de Custo totalizadores dos Centros de Custo Analíticos - Analítica: Centros de Custo que recebem os valores dos lançamentos contábeis
			{'CTT_NORMAL' , "0"			  			    , Nil},;	// Indica a classificação do centro de custo. 1-Receita ; 2-Despesa
			{'CTT_DESC01' , cDesc01                     , Nil},;	// Indica a Nomenclatura do Centro de Custo na Moeda 1
			{'CTT_BLOQ'   , "2"							, Nil},;	// Indica se o Centro de Custo está ou não bloqueado para os lançamentos contábeis.
			{'CTT_DTEXIS' , CTOD("01/01/80")			, Nil},;	// Especifica qual a Data de Início de Existência para este Centro de Custo
			{'CTT_ITOBRG' , "2"							, Nil},;	// ITEM OBRIGATORIO ?
			{'CTT_CLOBRG' , "2"							, Nil},;	//
			{'CTT_ACITEM' , "1"							, Nil},;	//
			{'CTT_ACCLVL' , "1"							, Nil},;	//
			{'CTT_TIPO'   , "1"							, Nil},;	// TIPO INSCR TOMADOR  1- CNPJ
			{'CTT_TPLOT'  , iif(SA1->A1_PESSOA='J','04','03'), Nil},;	//
			{'CTT_TIPO2'  , iif(SA1->A1_PESSOA='J','1','2')	 , Nil},;	//
			{'CTT_CEI'    , SA1->A1_CGC					, Nil},;	// CNPJ / CEI DO TOMADOR
			{'CTT_NOME'   , AllTrim(JF03->ABS_DESCRI)   , Nil},;	// Nome DO TOMADOR
			{'CTT_ENDER'  , substr(alltrim(SA1->A1_END),1,40)      , Nil},;	// endereço
			{'CTT_BAIRRO' , substr(alltrim(SA1->A1_BAIRRO),1,20)   , Nil},;	// bairro
			{'CTT_CEP'    , alltrim(SA1->A1_CEP)        , Nil},;	// CEP
			{'CTT_ESTADO' , alltrim(SA1->A1_EST)        , Nil},;	// ESTADO
			{'CTT_CODMUN' , alltrim(SA1->A1_COD_MUN)     , Nil},;	// COD MUNICIPIO
			{'CTT_MUNIC'  , SUBSTR(Posicione("CC2",1,xFilial("CC2",SA1->A1_FILIAL) + SA1->A1_EST +SA1->A1_COD_MUN ,"CC2_MUN"),1,20)     , Nil},;	// MUNICIPIO
			{'CTT_CEI2'   , SA1->A1_CGC						 , Nil},;	//
			{'CTT_FPAS'   , superGetMv("SV_FPAS",,"515")	 , Nil},;	//
			{'CTT_CODTER' , superGetMv("SV_CODTER",,"0115")	 , Nil},;	//
			{'CTT_CCLP'   , cCodCC						, Nil},;	// Indica o Centro de Custo de Apuração de Resultado.acmin
			{'CTT_CCSUP'  , substr(cCodCC,1,16)			, Nil}}	    // Indica qual é o Centro de Custo superior ao que está sendo cadastrado (dentro da hierarquia dos Centros de Custo).

			JF03->(dbCloseArea())

			If substr(cFilant,1,2) $ alltrim(superGetMv("SV_GERCC",,"01/02/03/04/05/06/07"))
				lMsErroAuto := .F.
				MSExecAuto({|x, y| CTBA030(x, y)},aDadosAuto, 3)

				If lMsErroAuto
					MostraErro()
					JF01->(dbCloseArea())
					RestArea(xArea)
					Return
				endif
			Endif

			//===== AJUSTANDO CAMPO TFL_YCC ====================
			dbSelectArea("TFL")
			TFL->(dbSetOrder(1))
			TFL->(dbSeek(JF01->TFL_FILIAL + JF01->TFL_CODIGO))

			If Found()
				Reclock("TFL",.F.)
				TFL->TFL_YCC := cCodCC
				MsUnlock()
			endif
			// ======== FIM DO AJUSTE DO TFL_YCC================

			// GERANDO O CENTRO DE CUSTO PARA AS DEMAIS EMPRESAS
			dbSelectArea("SM0")
			SM0->(dbGotop())
			While !SM0->(EOF())

				if alltrim(SM0->M0_CODFIL) == cFilBkp
					SM0->(dbSkip())
				endif

				If substr(SM0->M0_CODFIL,1,2) $ alltrim(superGetMv("SV_GERCC",,"01/02/03/04/05/06/07"))
					aDadosAuto[1][1] := SUBSTR(SM0->M0_CODFIL,1,2)
					aDadosAuto[1][2] := alltrim(SM0->M0_CODFIL)

					cFilant := alltrim(SM0->M0_CODFIL)

					//Verifica se já existe o CC
					cQuery:= "SELECT * FROM " + RetSqlName("CTT") + " CTT "
					cQuery+= "WHERE CTT.D_E_L_E_T_ = ' ' AND "
					cQuery+= "CTT_FILIAL = '" + xFilial("CTT") + "' AND "
					cQuery+= "CTT_CUSTO = '" + cCodCC + "' "

					tcQuery cQuery new Alias QRCTT

					If QRCTT->(!Eof())
						QRCTT->(dbCloseArea())
						SM0->(DbSkip())
						loop
					Endif

					QRCTT->(dbCloseArea())

					lMsErroAuto := .F.
					MSExecAuto({|x, y| CTBA030(x, y)},aDadosAuto, 3)

					If lMsErroAuto
						MostraErro()
						JF01->(dbCloseArea())
						RestArea(xArea)
						Return
					endif
				Endif
				SM0->(dbSkip())
			Enddo
			// volta para a filial logada
			cFilant := cFilBkp
			nAux+= 1
		ENDIF
		JF01->(dbSkip())
	Enddo
	JF01->(dbCloseArea())
	RestArea(xArea)
Return

//user function fTeste1
//	paramIxb:= {"",""}
//	paramIxb[1]:= '000000000000027'
//	paramIxb[2]:= '002'
//	u_AT870RVAPR()
//Return
