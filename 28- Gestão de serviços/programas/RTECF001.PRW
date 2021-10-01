#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA600.CH"

//*****************************************************************************
/*/{Protheus.doc} RTECF001
Função para realizar transferencia contrato 
@author edlardo neves - mconsult
@since 12/01/2021
@version 1.0
@return null
/*/
//*****************************************************************************
User Function RTECF001()
	Local aAreaAtual := GetArea()
	Local lRet       := .T.
	Local aParam     := {}
	Local aRetParm	 := {}
	Local _cFilDest	 := Space(GetSx3Cache("AD1_FILIAL","X3_TAMANHO"))
	Local _cVendDest := Space(GetSx3Cache("AD1_VEND"  ,"X3_TAMANHO"))

	Private cFilDest  := ''
	Private cVendDest := ''

	aAdd(aParam,{1, "Filial Destino"	,_cFilDest	,"@!" ,".T." ,"SM0" ,".T.",80, .T. })
	aAdd(aParam,{1, "Vendedor Destino"	,_cVendDest	,"@!" ,"ExistCpo('SA3')" ,"SA3",".T.",80, .T. })

	If ParamBox( aParam, "Parametros Transferencia", @aRetParm,{||.T.} ,,,,,,"U_RTECF001", .F., .F. )
		If Empty(aRetParm[1])
			lRet := .F.
		EndIf
		If Empty(aRetParm[2])
			lRet := .F.
		EndIf

		If lRet
			if !EXISTCPO("SM0",cEmpAnt+aRetParm[1])
				lRet := .F.
				MsgAlert("Filial digitada: "+aRetParm[1]+" não é valida!", "Operação cancelada")
			endif
		EndIf

		If  lRet
			cFilDest := aRetParm[1]
			cVendDest:= aRetParm[2]
		EndIf
	Else
		lRet := .F.
	EndIf

	//Realiza a migração
	If lRet
		lRet := MigraContr()
	EndIf

	RestArea(aAreaAtual)

Return


//Migração do contrato
Static Function MigraContr()
	Local lRet      := .T.
	Local cFilBkp   := cFilAnt
	Local aAreaAtual := GetArea()

	Private cNrOportu := ""
	Private cNProposta:= ""

	dbSelectArea("TFJ")
	dbSetOrder(5) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	IF !dbSeek(xFilial("TFJ")+CN9->(CN9_NUMERO+CN9_REVISA))
		lRet := .F.
	EndIf

	/*
	If lRet
		dbSelectArea("AD1")
		dbSetOrder(1)
		IF !dbSeek(xFilial("AD1")+TFJ->(TFJ_PROPOS+TFJ_PREVIS))
			lRet := .F.
		EndIf
	EndIf
    */

	cQuery := " "
	cQuery := " SELECT * FROM "+RetSqlName("AD1")+ " AD1 "
	cQuery += " INNER JOIN "+RetSqlName("ADY")+ " ADY ON AD1_FILIAL = ADY_FILIAL AND ADY_OPORTU = AD1_NROPOR AND ADY_REVISA = AD1_REVISA AND ADY.D_E_L_E_T_='' "
	cQuery += " WHERE AD1_FILIAL = '"+TFJ->TFJ_FILIAL+"' AND ADY_PROPOS = '"+TFJ->TFJ_PROPOS+"' AND ADY_PREVIS = '"+TFJ->TFJ_PREVIS+"' AND AD1.D_E_L_E_T_ = '' "

	IF SELECT("T02") > 0
		T02->(DbCloseArea())
	ENDIF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T02", .F., .T. )

	If !T02->(EOF())
		cFilAnt := cFilDest
		dbSelectArea("AD1")
		dbSetOrder(1)
		cNrOportu := FT300Num()

		Begin Transaction

			//Migra a oportunidade comercial
			If lRet
				lRet := MYFATA300()
			EndIf

			//Migra a Proposta Comercial
			If lRet
				lRet := MYFATA600()
			EndIf

		End Transaction

		cFilAnt := cFilBkp
	EndIf

	T02->(DbCloseArea())

	IF lRet
		MSGINFO("Finalizado a transferencia do contrato! Gerado a Oportunidade Nº "+cNrOportu+ " - Filial "+cFilDest, "Processo Finalizado")
	EndIf
	RestArea(aAreaAtual)

Return lRet


//Migra a oportunidade comercial
Static Function MYFATA300()

	Local aCabec		:= {}
	Local lRet			:= .T.

	Private lMsErroAuto := .F.

	// Monta o array com as informacoes para a gravacao
	aCabec := 	{{ "AD1_FILIAL"      , cFilDest	                  , NIL },;
		{ "AD1_NROPOR"  		     , cNrOportu                  , NIL },;
		{ "AD1_REVISA"  		     , "01"		                  , NIL },;
		{ "AD1_DESCRI"  		     , T02->AD1_DESCRI            , NIL },;
		{ "AD1_CODCLI"  		     , TFJ->TFJ_CODENT            , NIL },;
		{ "AD1_LOJCLI"  		     , TFJ->TFJ_LOJA              , NIL },;
		{ "AD1_DATA" 			     , ddatabase        		  , NIL },;
		{ "AD1_HORA" 			     , T02->AD1_HORA              , NIL },;
		{ "AD1_USER" 			     , T02->AD1_USER              , NIL },;
		{ "AD1_VEND" 			     , cVendDest                  , NIL },;
		{ "AD1_DTINI"   			 , ddatabase	              , NIL },;
		{ "AD1_PROVEN"   			 , "000002"		              , NIL },;
		{ "AD1_STAGE"   			 , "000002"		              , NIL },;
		{ "AD1_DTPFIM"   			 , ddatabase+30               , NIL },;
		{ "AD1_FCS"   			     , "000006"		              , NIL },;
		{ "AD1_COMUNI"   			 , "000006"		              , NIL },;
		{ "AD1_SETOR"   			 , T02->AD1_SETOR		      , NIL },;
		{ "AD1_MOEDA"   			 , T02->AD1_MOEDA		      , NIL },;
		{ "AD1_PRIOR"   			 , T02->AD1_PRIOR		      , NIL },;
		{ "AD1_YFORES"   			 , "1"                        , NIL },;
		{ "AD1_YFILOR"   			 , T02->AD1_FILIAL            , NIL },;
		{ "AD1_YNROPO"   			 , T02->AD1_NROPOR 		      , NIL },;
		{ "AD1_YREVIS"   			 , T02->AD1_REVISA 		      , NIL }}

	dbSelectArea("AD1")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿//³Gravacao da oportunidade³//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCabec) > 0
		MSExecAuto( { |x , y | FATA300(x,y) } , 3, aCabec )
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			lRet := .F.
		Else
			dbSelectArea("AD1")
			dbSetOrder(1)
			IF !dbSeek(cFilDest+cNrOportu+"01")
				DisarmTransaction()
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		EndIf
	EndIf

Return lRet


Static Function MYFATA600()
	Local lRet       := .T.
	/*
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX     := 0
	Local nY     := 0
	*/
	Local cDoc   := ""
	Local lOk	 := .F.
	Local lInclui:= .F. 
	PRIVATE lMsErroAuto := .F.

	dbSelectArea("SA1")
	dbSetOrder(1)
	If !SA1->(MsSeek(xFilial("SA1")+T02->ADY_CODIGO+T02->ADY_LOJA))
		DisarmTransaction()
		lRet := .F.
		ALERT("Cadastrar cliente/loja: "+T02->ADY_CODIGO+"/"+T02->ADY_LOJA)
		Return lRet
	EndIf

	//cNProposta := GetSXENum( "ADY", "ADY_PROPOS" )
	While !lOk
		cNProposta := GetSXENum( "ADY", "ADY_PROPOS" )
		lOk 	:= !( ADY->( DBSeek( cFilDest + cNProposta ) ) )
		If !lOk
			ConfirmSX8()
		EndIf
	End
	//ADY_FILIAL,ADY_PROPOS,ADY_PREVIS,ADY_OPORTU,ADY_REVISA,ADY_ENTIDA,ADY_CODIGO,ADY_LOJA,ADY_STATUS,ADY_DATA,ADY_CLIENT,ADY_LOJENT,ADY_VEND,ADY_TPCONT,ADY_VISTEC,ADY_SITVIS,ADY_DTREVI,ADY_SINCPR,ADY_MSBLQL,ADY_HREMIS,ADY_USREMI,ADY_LRAT
	dbSelectArea("ADY")
	IF RecLock("ADY",.T.)
		ADY->ADY_FILIAL := cFilDest
		ADY->ADY_PROPOS	:= cNProposta
		ADY->ADY_PREVIS	:= "01"
		ADY->ADY_OPORTU	:= cNrOportu
		ADY->ADY_REVISA	:= "01"
		ADY->ADY_ENTIDA	:= T02->ADY_ENTIDA
		ADY->ADY_CODIGO	:= T02->ADY_CODIGO
		ADY->ADY_LOJA	:= T02->ADY_LOJA
		ADY->ADY_STATUS	:= "A"
		ADY->ADY_DATA	:= Stod(T02->ADY_DATA)
		ADY->ADY_CLIENT	:= T02->ADY_CLIENT
		ADY->ADY_LOJENT	:= T02->ADY_LOJENT
		ADY->ADY_VEND	:= cVendDest
		ADY->ADY_TPCONT	:= T02->ADY_TPCONT
		ADY->ADY_VISTEC	:= T02->ADY_VISTEC
		ADY->ADY_SITVIS	:= T02->ADY_SITVIS
		ADY->ADY_DTREVI	:= Stod(T02->ADY_DTREVI)
		ADY->ADY_SINCPR	:= .T. //T02->ADY_SINCPR
		ADY->ADY_MSBLQL	:= T02->ADY_MSBLQL
		ADY->ADY_HREMIS	:= T02->ADY_HREMIS
		ADY->ADY_USREMI	:= T02->ADY_USREMI
		ADY->ADY_LRAT	:= .F.
		ADY->(MsUnLock())
	Else
		DisarmTransaction()
		lRet := .F.
		Return lRet
	EndIf

	dbSelectArea("AD1")
	dbSetOrder(1)
	IF !dbSeek(cFilDest+cNrOportu+"01")
		DisarmTransaction()
		lRet := .F.
		Return lRet
	Else
		IF RecLock("AD1",.F.)
			AD1->AD1_PROPOS := cNProposta
			AD1->(MsUnLock())
		Else
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf
	EndIf
	cQuery := " "
	cQuery := " SELECT * FROM "+RetSqlName("ADZ")+ " ADZ "
	cQuery += " WHERE ADZ_FILIAL = '"+T02->ADY_FILIAL+"' AND ADZ_PROPOS = '"+T02->ADY_PROPOS+"' AND ADZ_REVISA = '"+T02->ADY_PREVIS+"' AND ADZ.D_E_L_E_T_ = '' "

	IF SELECT("T03") > 0
		T03->(DbCloseArea())
	ENDIF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T03", .F., .T. )

	dbSelectArea("SE4")
	dbSetOrder(1)
	If !SE4->(MsSeek(xFilial("SE4")+T03->ADZ_CONDPG	))
		ALERT("Cadastrar condicao de pagamento: "+T03->ADZ_CONDPG)
		DisarmTransaction()
		lRet := .F.
		Return lRet
	EndIf
	/*
	cDoc := GetSxeNum("SCJ","CJ_NUM")
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"CJ_NUM"    ,cDoc,Nil})
	aadd(aCabec,{"CJ_CLIENTE",SA1->A1_COD,Nil})
	aadd(aCabec,{"CJ_LOJACLI",SA1->A1_LOJA,Nil})
	aadd(aCabec,{"CJ_LOJAENT",SA1->A1_LOJA,Nil})
	aadd(aCabec,{"CJ_CONDPAG",SE4->E4_CODIGO,Nil})
	aadd(aCabec,{"CJ_PROPOST",cNProposta,Nil})
	aadd(aCabec,{"CJ_NROPOR",cNrOportu,Nil})
	aadd(aCabec,{"CJ_REVISA","01",Nil})
	*/
	//CJ_FILIAL,CJ_NUM,CJ_EMISSAO,CJ_CLIENTE,CJ_LOJA,CJ_CLIENT,CJ_LOJAENT,CJ_CONDPAG,CJ_STATUS,CJ_VALIDA,CJ_MOEDA,CJ_TIPLIB,CJ_TPCARGA,CJ_PROPOST,CJ_NROPOR,CJ_REVISA,CJ_TXMOEDA,D_E_L_E_T_,CJ_TIPOCLI,R_E_C_D_E_L_,R_E_C_N_O_
	//cDoc := GetSxeNum("SCJ","CJ_NUM")
	lOk := .F. 
	While !lOk
		cDoc := GetSxeNum("SCJ","CJ_NUM")
		lOk 	:= !( SCJ->( DBSeek( cFilDest + cDoc ) ) )
		If !lOk
			ConfirmSX8()
		EndIf
	End
	dbSelectArea("SCJ")
	IF RecLock("SCJ",.T.)
		SCJ->CJ_FILIAL  := cFilDest
		SCJ->CJ_NUM		:= cDoc
		SCJ->CJ_EMISSAO	:= ddatabase
		SCJ->CJ_CLIENTE	:= SA1->A1_COD
		SCJ->CJ_LOJA	:= SA1->A1_LOJA
		SCJ->CJ_CLIENT	:= SA1->A1_COD
		SCJ->CJ_LOJAENT	:= SA1->A1_LOJA
		SCJ->CJ_CONDPAG	:= SE4->E4_CODIGO
		SCJ->CJ_STATUS	:= 'A'
		SCJ->CJ_VALIDA	:= ddatabase+10
		SCJ->CJ_MOEDA	:= 1
		SCJ->CJ_TIPLIB	:= '1'
		SCJ->CJ_TPCARGA	:= '2'
		SCJ->CJ_PROPOST	:= cNProposta
		SCJ->CJ_NROPOR	:= cNrOportu
		SCJ->CJ_REVISA	:= '01'
		SCJ->CJ_TXMOEDA	:= 1
		SCJ->CJ_TIPOCLI	:= SA1->A1_TIPOCLI
		SCJ->(MsUnLock())
	Else
		DisarmTransaction()
		lRet := .F.
		Return lRet
	EndIf

	While(!T03->(EOF()))
		dbSelectArea("SB1")
		dbSetOrder(1)
		If !SB1->(MsSeek(xFilial("SB1")+T03->ADZ_PRODUT))
			ConOut("Cadastrar produto: "+T03->ADZ_PRODUT)
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf

		dbSelectArea("SF4")
		dbSetOrder(1)
		If !SF4->(MsSeek(xFilial("SF4")+T03->ADZ_TES))
			ConOut("Cadastrar TES: "+T03->ADZ_TES)
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf

		dbSelectArea("SE4")
		dbSetOrder(1)
		If !SE4->(MsSeek(xFilial("SE4")+T03->ADZ_CONDPG))
			ConOut("Cadastrar condicao de pagamento: "+T03->ADZ_CONDPG)
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf
		/*
		aLinha := {}
		aadd(aLinha,{"CK_ITEM",StrZero(nX,2),Nil})
		aadd(aLinha,{"CK_PRODUTO",SB1->B1_COD,Nil})
		aadd(aLinha,{"CK_QTDVEN",1,Nil})
		aadd(aLinha,{"CK_PRCVEN",1,Nil})
		aadd(aLinha,{"CK_PRUNIT",1,Nil})
		aadd(aLinha,{"CK_VALOR",1,Nil})
		aadd(aLinha,{"CK_TES",T03->ADZ_TES,Nil})
		aadd(aItens,aLinha)
		*/
		//ADJ_FILIAL,ADJ_NROPOR,ADJ_REVISA,ADJ_ITEM,ADJ_PROD,ADJ_QUANT,ADJ_PRUNIT,ADJ_VALOR,ADJ_NUMORC,ADJ_PROPOS,ADJ_HISTOR,ADJ_CATEG
		dbSelectArea("ADJ")
		DbSetOrder(1) //ADJ_FILIAL+ADJ_NROPOR+ADJ_REVISA+ADJ_ITEM+ADJ_PROD
		If ADJ->(MsSeek(cFilDest+cNrOportu))
			lInclui := .F.
		Else
			lInclui := .T.
		EndIf
		IF RecLock("ADJ",lInclui)
			ADJ->ADJ_FILIAL := cFilDest
			ADJ->ADJ_NROPOR	:= cNrOportu
			ADJ->ADJ_REVISA	:= "01"
			ADJ->ADJ_ITEM	:= StrZero(Val(T03->ADZ_ITEM), TAMSX3("ADJ_ITEM")[1])
			ADJ->ADJ_PROD	:= T03->ADZ_PRODUT
			ADJ->ADJ_QUANT	:= 1
			ADJ->ADJ_PRUNIT	:= 1
			ADJ->ADJ_VALOR	:= 1
			ADJ->ADJ_NUMORC	:= cDoc
			ADJ->ADJ_PROPOS	:= cNProposta
			ADJ->ADJ_HISTOR	:= '2'
			ADJ->ADJ_CATEG	:= ''
			ADJ->(MsUnLock())
		Else
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf

		//ADZ_FILIAL,ADZ_ITEM,ADZ_PRODUT,ADZ_DESCRI,ADZ_UM,ADZ_MOEDA,ADZ_CONDPG,ADZ_TES,ADZ_QTDVEN,ADZ_PRCVEN,ADZ_TOTAL,ADZ_PRDALO,ADZ_ITEMOR,ADZ_ORCAME,ADZ_PROPOS,ADZ_FOLDER,ADZ_REVISA,ADZ_DIASEM
		dbSelectArea("ADZ")
		IF RecLock("ADZ",.T.)
			ADZ->ADZ_FILIAL := cFilDest
			ADZ->ADZ_ITEM	:= T03->ADZ_ITEM
			ADZ->ADZ_PRODUT	:= T03->ADZ_PRODUT
			ADZ->ADZ_DESCRI	:= T03->ADZ_DESCRI
			ADZ->ADZ_UM		:= T03->ADZ_UM
			ADZ->ADZ_MOEDA	:= '1'
			ADZ->ADZ_CONDPG	:= T03->ADZ_CONDPG
			ADZ->ADZ_TES	:= T03->ADZ_TES
			ADZ->ADZ_QTDVEN	:= 1
			ADZ->ADZ_PRCVEN	:= 1
			ADZ->ADZ_TOTAL	:= 1
			ADZ->ADZ_PRDALO	:= T03->ADZ_PRDALO
			ADZ->ADZ_ITEMOR	:= T03->ADZ_ITEMOR
			ADZ->ADZ_ORCAME	:= cDoc
			ADZ->ADZ_PROPOS	:= cNProposta
			ADZ->ADZ_FOLDER	:= T03->ADZ_FOLDER
			ADZ->ADZ_REVISA	:= '01'
			ADZ->ADZ_DIASEM	:= T03->ADZ_DIASEM
			ADZ->(MsUnLock())
		Else
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf

		//CK_FILIAL,CK_ITEM,CK_PRODUTO,CK_UM,CK_QTDVEN,CK_PRCVEN,CK_VALOR,CK_TES,CK_LOCAL,CK_CLIENTE,CK_LOJA,CK_NUM,CK_DESCRI,CK_PRUNIT,CK_ENTREG,CK_CLASFIS,CK_FILVEN,CK_FILENT,CK_PROPOST,CK_ITEMPRO,CK_TPPROD
		dbSelectArea("SCK")
		IF RecLock("SCK",.T.)
			SCK->CK_FILIAL  := cFilDest
			SCK->CK_ITEM	:= T03->ADZ_ITEM
			SCK->CK_PRODUTO	:= T03->ADZ_PRODUT
			SCK->CK_UM		:= T03->ADZ_UM
			SCK->CK_QTDVEN	:= 1
			SCK->CK_PRCVEN	:= 1
			SCK->CK_VALOR	:= 1
			SCK->CK_PRUNIT	:= 1
			SCK->CK_TES		:= T03->ADZ_TES
			SCK->CK_LOCAL	:= "01"
			SCK->CK_CLIENTE	:= SA1->A1_COD
			SCK->CK_LOJA	:= SA1->A1_LOJA
			SCK->CK_NUM		:= cDoc
			SCK->CK_DESCRI	:= T03->ADZ_DESCRI
			SCK->CK_ENTREG	:= ddatabase
			SCK->CK_CLASFIS	:= StrZero(Val(SF4->F4_SITTRIB), TAMSX3("F4_SITTRIB")[1])
			SCK->CK_FILVEN	:= cFilDest
			SCK->CK_FILENT	:= cFilDest
			SCK->CK_PROPOST	:= cNProposta
			SCK->CK_ITEMPRO	:= T03->ADZ_ITEM
			SCK->CK_TPPROD	:= '1'
			SCK->(MsUnLock())
		Else
			DisarmTransaction()
			lRet := .F.
			Return lRet
		EndIf

		T03->(DbSkip())
	EndDo
	T03->(DbCloseArea())

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} FT300Num
Obtem o proximo numero para a oportunidade, verificando se o
numero sugerido na GetSxeNum nao foi utilizado.
@sample	FT300Num()
@param		Nenhum			
@return	cRet, caracter, Numero da Oportunidade.
@author	Anderson Silva
@since		04/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function FT300Num()
	Local aArea		:= GetArea()
	Local aAreaAD1	:= AD1->(GetArea())
	Local cFilter	:= AD1->( DBFilter() )
	Local cRet		:= ""
	Local lOk		:= .F.
	Local cFilAD1	:= ""//xFilial("AD1")

	cFilAD1	:= xFilial("AD1")

	AD1->( DBClearFilter() )
	AD1->( DBSetOrder(1) )

	While !lOk
		cRet	:= GetSXENum( "AD1", "AD1_NROPOR" )
		lOk 	:= !( AD1->( DBSeek( cFilAD1 + cRet ) ) )
		If !lOk
			ConfirmSX8()
		EndIf
	End

	If !Empty( cFilter )
		DBSelectArea( "AD1" )
		SET FILTER TO &cFilter
	EndIf

	RestArea( aAreaAD1 )
	RestArea( aArea )

Return( cRet )


/*
Static Function MYFATA600()

	Local nOperation    := 3
	Local aADZProduto   := {}
	Local aADYMaster    := {}
	Local aADZAcessor   := {}
	Local lRet      := .T.
	//Local lTeste	:= .T.
	Private lMsErroAuto := .F.

	//-----------------------------------------------
	// Cabeçalho da Proposta Comercial
	//----------------------------------------------
	aAdd( aADYMaster, {"ADY_OPORTU", AD1->AD1_NROPOR, Nil } )
	aAdd( aADYMaster, {"ADY_REVISA", AD1->AD1_REVISA, Nil } )
	aAdd( aADYMaster, {"ADY_DATA"  , Stod(T02->ADY_DATA) , Nil } )
	aAdd( aADYMaster, {"ADY_ENTIDA", T02->ADY_ENTIDA, Nil } ) //1=Cliente; 2=Prospect
	aAdd( aADYMaster, {"ADY_CODIGO", T02->ADY_CODIGO, Nil } )
	aAdd( aADYMaster, {"ADY_LOJA"  , T02->ADY_LOJA, Nil } )
	//aAdd( aADYMaster, {"ADY_TABELA", T02->ADY_TABELA, Nil } )

	cQuery := " "
	cQuery := " SELECT * FROM "+RetSqlName("ADZ")+ " ADZ "
	cQuery += " WHERE ADZ_FILIAL = '"+TFJ->TFJ_FILIAL+"' AND ADZ_PROPOS = '"+TFJ->TFJ_PROPOS+"' AND ADZ_REVISA = '"+TFJ->TFJ_PREVIS+"' AND ADZ.D_E_L_E_T_ = '' "

	IF SELECT("T03") > 0
		T03->(DbCloseArea())
	ENDIF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T03", .F., .T. )

	While(!T03->(EOF()))
		//-----------------------------------------------
		// Itens da Proposta Comercial - Folder Produtos
		//-----------------------------------------------
		If T03->ADZ_FOLDER == "1"
			aAdd( aADZProduto,{ {"ADZ_PRODUT", T03->ADZ_PRODUT, Nil } ,;
				{"ADZ_CONDPG", T03->ADZ_CONDPG, Nil } ,;
				{"ADZ_TES", T03->ADZ_TES, Nil } ,;
				{"ADZ_QTDVEN", 1, Nil } ,;
				{"ADZ_PRCVEN", 1, Nil } ,;
				{"ADZ_CODAGR", T03->ADZ_CODAGR, Nil },;
				{"ADZ_CODNIV", T03->ADZ_CODNIV, Nil } } )

			//-------------------------------------------------
			// Itens da Proposta Comercial - Folder Acessórios
			//-------------------------------------------------
		ElseIf T03->ADZ_FOLDER == "2"
			aAdd( aADZAcessor, { {"ADZ_PRODUT", T03->ADZ_PRODUT, Nil },;
				{"ADZ_CONDPG", T03->ADZ_CONDPG, Nil } ,;
				{"ADZ_TES", T03->ADZ_TES, Nil } ,;
				{"ADZ_QTDVEN", 1, Nil },;
				{"ADZ_PRCVEN", 1, Nil } ,;
				{"ADZ_QTDVEN", 1, Nil }} )

		EndIf
		T03->(DbSkip())
	EndDo
	T03->(DbCloseArea())

	FATA600(  , nOperation, aADYMaster, aADZProduto , aADZAcessor )

	If lMsErroAuto
		lRet := .F.
		MostraErro()
		DisarmTransaction()
	Else
		dbSelectArea("ADY")
		dbSetOrder(2)
		IF !dbSeek(cFilDest+cNrOportu)
			DisarmTransaction()
			lRet := .F.
		Else
			lRet := .T.
			Conout( "Proposta incluída com sucesso.!" )
		EndIf
	EndIf

Return(lRet)


Static Function MyMata415()
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX     := 0
	Local nY     := 0
	Local cDoc   := ""
	Local lOk    := .T.
	PRIVATE lMsErroAuto := .F.

	dbSelectArea("SA1")
	dbSetOrder(1)
	If !SA1->(MsSeek(xFilial("SA1")+T02->ADY_CODIGO+T02->ADY_LOJA))
		lOk := .F.
		ConOut("Cadastrar cliente/loja: "+T02->ADY_CODIGO+"/"+T02->ADY_LOJA)
	EndIf

	If lOk

		cDoc := GetSxeNum("SCJ","CJ_NUM")
		RollBAckSx8()
		aCabec := {}
		aItens := {}
		aadd(aCabec,{"CJ_NUM"   ,cDoc,Nil})
		aadd(aCabec,{"CJ_CLIENTE",SA1->A1_COD,Nil})
		aadd(aCabec,{"CJ_LOJACLI",SA1->A1_LOJA,Nil})
		aadd(aCabec,{"CJ_LOJAENT",SA1->A1_LOJA,Nil})
		aadd(aCabec,{"CJ_CONDPAG",SE4->E4_CODIGO,Nil})

		While(!T03->(EOF()))

			dbSelectArea("SB1")
			dbSetOrder(1)
			If !SB1->(MsSeek(xFilial("SB1")+T03->ADZ_PRODUT))
				lOk := .F.
				ConOut("Cadastrar produto: "+T03->ADZ_PRODUT)
				Exit
			EndIf

			dbSelectArea("SF4")
			dbSetOrder(1)
			If !SF4->(MsSeek(xFilial("SF4")+T03->ADZ_TES))
				lOk := .F.
				ConOut("Cadastrar TES: "+T03->ADZ_TES)
				Exit
			EndIf

			dbSelectArea("SE4")
			dbSetOrder(1)
			If !SE4->(MsSeek(xFilial("SE4")+T03->ADZ_CONDPG))
				lOk := .F.
				ConOut("Cadastrar condicao de pagamento: "+T03->ADZ_CONDPG)
				Exit
			EndIf

			aLinha := {}

			aadd(aLinha,{"CK_ITEM",StrZero(nX,2),Nil})
			aadd(aLinha,{"CK_PRODUTO",SB1->B1_COD,Nil})
			aadd(aLinha,{"CK_QTDVEN",1,Nil})
			aadd(aLinha,{"CK_PRCVEN",1,Nil})
			aadd(aLinha,{"CK_PRUNIT",1,Nil})
			aadd(aLinha,{"CK_VALOR",1,Nil})
			aadd(aLinha,{"CK_TES",T03->ADZ_TES,Nil})

			aadd(aItens,aLinha)

			T03->(DbSkip())
		EndDo
		T03->(DbCloseArea())

		If lOk
			MATA415(aCabec,aItens,3)
			If !lMsErroAuto
				ConOut("Incluido com sucesso! "+cDoc)
			Else
				ConOut("Erro na inclusao!")
				lOk := .F.
			EndIf

		Else
			DisarmTransaction()
			lOk := .F.
		EndIf
	EndIf


Return lOk
*/

