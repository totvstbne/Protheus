#Include 'Protheus.ch'

User Function AT930PVG()
	Local aArea			:= GetArea()
	Private cFilho 		:= GetSxeNum("SC5", "C5_NUM")
	Private lParam     	:= .F.
	Private aGerados 	:= ParamIxb[1]
	Private lMsErroAuto := .F.
	Private l410Auto    := .F.
	Private aMunicipios := {}

	Begin Transaction
	If !EMPTY(aGerados) .AND. VALTYPE(aGerados) == 'A'
		processa()
	EndIf
	End Transaction
	RestArea(aArea)
Return

Static Function processa()
	Local nCount := 1

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	lParam := if(CND->CND_YFATMU = '1', .T., .F.)
	If lParam
		aMunicipios := municipios()

		For nCount := 1 To Len(aMunicipios)
			processaPedido(nCount)
			cFilho := GetSxeNum("SC5", "C5_NUM")
		Next
		SC5->(dbCloseArea())
		return
	EndIf
	processaPedido()
	SC5->(dbCloseArea())
Return 

Static Function municipios()
	Local cQuery := ""
	Local aMun   := {}
	Local nX 	 := 1
	Local nCont  := 1

	cQuery	:= " SELECT 									"
	cQuery	+= "	C5_ESTPRES,								"
	cQuery  += "	C5_MUNPRES						    	"
	cQuery	+= " FROM "+RetSqlName("SC5")+" SC5				"
	cQuery	+= " INNER JOIN "+RetSqlName("SC6")+" SC6 ON 	"
	cQuery	+= "	C6_FILIAL  = '"+xFilial("SC6")+"' 		"
	cQuery	+= "	AND C6_NUM = C5_NUM 					"
	cQuery	+= "	AND SC6.D_E_L_E_T_ = ' '				"
	cQuery	+= " WHERE 										"
	cQuery	+= "	C5_FILIAL = '" + xFilial("SC5") + 	  "'"
	cQuery	+= "	AND SC5.D_E_L_E_T_ = ' ' 				"
	cQuery	+= "	AND C5_NUM IN (							"

	For nX := 1 To Len(aGerados)
		If aGerados[nX][1] == '2'
			If nCont > 1
				cQuery += ","
			EndIf	
			cQuery += "'"+aGerados[nX][2]+"'"
			nCont++
		EndIf
	Next nX

	cQuery	+= ")"
	cQuery	+= " GROUP BY 			"
	cQuery	+= "	C5_ESTPRES,		"
	cQuery  += "	C5_MUNPRES  	"
	cQuery	+= " ORDER BY 			"
	cQuery	+= "	C5_ESTPRES,		"
	cQuery  += "	C5_MUNPRES 	    "

	MpSysOpenQuery(cQuery, "T01")

	While T01->(!EOF())
		aAdd(aMun, T01->C5_MUNPRES)
		T01->(dbSkip())
	EndDo
	T01->(dbCloseArea())
Return aMun

Static Function processaPedido(nMunicipio)
	Local cQuery 	:= ""
	Local cAliasQry := ""
	Local cChave    := ""
	Local cItem 	:= ""
	Local cItemAGG 	:= StrZero(0, TamSx3('AGG_ITEM')[1])
	Local cItMax	:= ""
	Local cCusto	:= ""
	Local nCount	:= 0
	Local nCont 	:= 0	
	Local nItem 	:= 0
	Local nPosAGG	:= 0
	Local nTotal	:= 0
	Local nTotalPec	:= 0
	Local nItMax	:= 0
	Local nPosIt	:= 0
    Local aCabec    := {}
	Local aItePed	:= {}
	Local aRateio   := {}
	Local aCliente	:= {}
	
	cQuery	:= " SELECT 									"
	cQuery	+= " 	C5_CLIENTE,								"
	cQuery	+= "	C5_LOJACLI,								"
	cQuery	+= "	C5_ESTPRES,								"
	cQuery  += "	C5_MUNPRES,						    	"
	cQuery  += "	C5_DESCMUN,								"
	cQuery	+= "	C5_NUM,									"
    cQuery	+= "    C5_LOJAENT,                             "
    cQuery	+= "    C5_CONDPAG,                             "
	cQuery	+= "	C5_MDCONTR,								"
	cQuery	+= "	C6_PRODUTO,								"
	cQuery	+= "	C6_TES,									"
	cQuery	+= "	C6_CC,									"
	cQuery	+= "	SUM(C6_QTDVEN) C6_QTDVEN,				"
	cQuery	+= "	SUM(C6_VALOR) C6_VALOR 					"
	cQuery	+= " FROM "+RetSqlName("SC5")+" SC5				"
	cQuery	+= " INNER JOIN "+RetSqlName("SC6")+" SC6 ON 	"
	cQuery	+= "	C6_FILIAL  = '"+xFilial("SC6")+"' 		"
	cQuery	+= "	AND C6_NUM = C5_NUM 					"
	cQuery	+= "	AND SC6.D_E_L_E_T_ = ' '				"
	cQuery	+= " WHERE 										"
	cQuery	+= "	C5_FILIAL = '" + xFilial("SC5") + 	  "'"
	cQuery	+= "	AND SC5.D_E_L_E_T_ = ' ' 				"
	If lParam
		cQuery	+= "	AND C5_MUNPRES = '"+aMunicipios[nMunicipio]+"'"
	EndIf
	cQuery	+= "	AND C5_NUM IN (							"
	
	For nCont := 1 To Len(aGerados)
		If aGerados[nCont][1] == '2'
			If nCont > 1
				cQuery += ","
			EndIf
			cQuery += "'"+aGerados[nCont][2]+"'"
		EndIf
	Next

	cQuery	+= ")"
	cQuery	+= " GROUP BY 			"
	cQuery	+= "	C5_CLIENTE,		"
	cQuery	+= "	C5_LOJACLI,		"
	cQuery	+= "	C5_ESTPRES,		"
	cQuery  += "	C5_MUNPRES, 	"
	cQuery  += "	C5_DESCMUN,		"
    cQuery	+= "    C5_LOJAENT,     "
    cQuery	+= "    C5_CONDPAG,     "
	cQuery	+= "	C5_MDCONTR,		"
	cQuery	+= "	C6_PRODUTO,		"
	cQuery	+= "	C5_NUM,			"
	cQuery	+= "	C6_TES,			"
	cQuery	+= "	C6_CC			"
	cQuery	+= " ORDER BY 			"
	cQuery	+= "	C5_CLIENTE,		"
	cQuery	+= "	C5_LOJACLI,		"
	cQuery	+= "	C5_ESTPRES,		"
	cQuery  += "	C5_MUNPRES,	    "
	cQuery	+= "	C6_PRODUTO,		"
	cQuery	+= "	C5_NUM,			"	
	cQuery	+= "	C6_TES,			"
	cQuery	+= "	C6_CC			"
	
	cAliasQry	:= MPSysOpenQuery(cQuery) 
	
	While (cAliasQry)->(!EOF())	
        //----------------------------------------------
        // Cabeçalho do pedido de venda
        //----------------------------------------------
        If nItem == 0	
            aAdd(aCabec, {"C5_NUM", cFilho, Nil})
            aAdd(aCabec, {"C5_TIPO", "N", Nil})
            aAdd(aCabec, {"C5_CLIENTE", (cAliasQry)->C5_CLIENTE, Nil})
            aAdd(aCabec, {"C5_LOJACLI", (cAliasQry)->C5_LOJACLI, Nil})
            aAdd(aCabec, {"C5_LOJAENT", (cAliasQry)->C5_LOJAENT, Nil})
            aAdd(aCabec, {"C5_CONDPAG", (cAliasQry)->C5_CONDPAG, Nil})
			aAdd(aCabec, {"C5_MDCONTR", (cAliasQry)->C5_MDCONTR, Nil})
			aAdd(aCabec, {"C5_YCOMPET", CTOD("01/"+CND->CND_COMPET), Nil})
			aAdd(aCabec, {"C5_MDNUMED", "XXXXXX", Nil})
			If lParam == .F.
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(dbSeek(xFilial("SA1")+(cAliasQry)->C5_CLIENTE+(cAliasQry)->C5_LOJACLI))
					aAdd(aCabec, {"C5_ESTPRES", SA1->A1_EST, Nil})
					aAdd(aCabec, {"C5_MUNPRES", SA1->A1_COD_MUN, Nil})
					aAdd(aCabec, {"C5_DESCMUN", SA1->A1_MUN, Nil})
				EndIf
				SA1->(dbCloseArea())
			Else
				aAdd(aCabec, {"C5_ESTPRES", (cAliasQry)->C5_ESTPRES, Nil})
				aAdd(aCabec, {"C5_MUNPRES", (cAliasQry)->C5_MUNPRES, Nil})
				aAdd(aCabec, {"C5_DESCMUN", Posicione("CC2", 1, xFilial("CC2") + (cAliasQry)->C5_ESTPRES + (cAliasQry)->C5_MUNPRES, "CC2_MUN"), Nil})
			EndIf
        EndIf

        //----------------------------------------------
        // Itens do pedido de venda
        //----------------------------------------------
		nItem++
        cItem  := StrZero(nItem, TamSx3('C6_ITEM')[1])
		cChave := (cAliasQry)->C5_ESTPRES+(cAliasQry)->C5_MUNPRES+(cAliasQry)->C6_PRODUTO

		If Len(aGerados) == 1
			cCusto := (cAliasQry)->C6_CC
		EndIf
		aAdd(aItePed, {  { "C6_ITEM"	, cItem						, Nil };
						,{ "C6_PRODUTO"	, (cAliasQry)->C6_PRODUTO	, Nil };
						,{ "C6_QTDVEN"	, 0							, Nil };
						,{ "C6_PRCVEN"	, 0							, Nil };
						,{ "C6_VALOR"	, 0							, Nil };
						,{ "C6_CC"		, cCusto					, Nil };
						,{ "C6_TES"		, (cAliasQry)->C6_TES		, Nil }})

        aAdd(aRateio, {cItem, {}})                
		nPos 	:= Len(aItePed)
		nPosAGG := Len(aRateio)
		While (cAliasQry)->C5_ESTPRES+(cAliasQry)->C5_MUNPRES+(cAliasQry)->C6_PRODUTO == cChave .OR. (lParam == .F. .AND. (cAliasQry)->(!EOF()))
			//------------------------------------------------------------------------
			// Preenche descrição do município e os pedidos pais com o número do filho
			//------------------------------------------------------------------------
			If SC5->(dbSeek(xFilial("SC5")+(cAliasQry)->C5_NUM)) .AND. RecLock("SC5", .F.)
				SC5->C5_DESCMUN := Posicione("CC2", 1, xFilial("CC2") + (cAliasQry)->C5_ESTPRES + (cAliasQry)->C5_MUNPRES, "CC2_MUN")
				SC5->C5_YPEDFIL := cFilho
				MsUnLock()
				//------------------------------------------
				// Executa rotina de resíduo nos pedidos pais
				//------------------------------------------
				lMsErroAuto := .F.
				l410Auto 	:= .T.
				Ma410Resid("SC5",SC5->(Recno()),2,.T.)
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					return
				EndIf
			EndIf

			//-----------------------------------------
			// Soma os valores dos pedidos a agrutinar
			//-----------------------------------------
			aItePed[nPos][3][2]	:= (cAliasQry)->C6_QTDVEN
			aItePed[nPos][5][2]	+= (cAliasQry)->C6_VALOR
			aItePed[nPos][4][2]	:= aItePed[nPos][5][2]/aItePed[nPos][3][2]
			nTotal				+= (cAliasQry)->C6_VALOR

			//----------------------------------------------
			// Estrutura de rateio para cada centro de custo
			//----------------------------------------------
			cItemAGG := Soma1(cItemAGG)
			aAdd(aRateio[nPosAGG][2], {{ "AGG_ITEMPD", cItem,			 	 Nil };
									  ,{ "AGG_ITEM"	, cItemAGG,				 Nil };
									  ,{ "AGG_CONTA",  "",				 	 Nil };
									  ,{ "AGG_ITEMCT", "",				 	 Nil };
									  ,{ "AGG_CLVL",   "", 					 Nil };
									  ,{ "AGG_PERC", (cAliasQry)->C6_VALOR,  Nil };
									  ,{ "AGG_CC", (cAliasQry)->C6_CC, 	  	 Nil }})

			If (cAliasQry)->C6_VALOR > nItMax
				cItMax	:= cItemAGG
				nItMax	:= (cAliasQry)->C6_VALOR
			EndIf		
			aAdd(aCliente, {(cAliasQry)->C5_CLIENTE, (cAliasQry)->C5_DESCMUN})									
			(cAliasQry)->(DbSkip())
		EndDo
		For nCount := 1 To Len(aRateio[nPosAGG][2])
			nTotalPec							+= NoRound(aRateio[nPosAGG][2][nCount][6][2]/nTotal*100,2)
			aRateio[nPosAGG][2][nCount][6][2]	:= NoRound(aRateio[nPosAGG][2][nCount][6][2]/nTotal*100,2)
		Next
		If nTotalPec != 100	//Ajusta casas decimais
			nPosIt := aScan(aRateio[nPosAGG][2], {|x| x[2][2] == cItMax })
			If nPosIt > 0
				aRateio[nPosAGG][2][nPosIt][6][2]	+= 100 - nTotalPec
			EndIf
		EndIf
	EndDo
	(cAliasQry)->(DbCloseArea())

	//----------------------------------------
	// Verifica se o cliente está diferente
	//----------------------------------------
	For nCount := 1 To Len(aCliente)
		If aCliente[1][1] != aCliente[nCount][1] .AND. lParam 
			AutoGRLog("Não é possível agrupar pedidos por município para clientes diferentes.")
			AutoGRLog(aCliente[1][2])
			AutoGRLog(aCliente[1][1])
			AutoGRLog(aCliente[nCount][1])
            DisarmTransaction()
            MostraErro()
			return 
		EndIf
	Next 
    //--------------------------------------------
    // Cria pedido de venda filho para faturamento
    //--------------------------------------------
    If Len(aCabec) != 0
		MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItePed, 3, .F., aRateio)
        If lMsErroAuto
            AutoGRLog("Não foi possível ajustar pedidos")
            AutoGRLog("Filial:"+xFilial("SC5"))
            AutoGRLog("Pedido:"+cFilho)
            DisarmTransaction()
            MostraErro()
		EndIf
    EndIf
Return
