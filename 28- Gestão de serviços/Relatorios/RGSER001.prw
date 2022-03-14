#include "totvs.ch"

Static aCampos	:= {"A1_NOME","A1_COD","A1_LOJA","AOV_DESSEG","AD1_SETOR","CN9_NUMERO","CN9_REVISA","AD1_DESCRI","TFF_COD","TFF_LOCAL","ABS_DESCRI","TFJ_YVGNHO","CN9_VLINI","CN9_SALDO","AD1_YNRLIC","TFJ_CONDPG","E4_DESCRI","TFJ_YINDC","TFJ_YINDPL","TFJ_YDTRJ","TFL_YCC","CTT_DESC01","ABS_ESTADO","ABS_CODMUN","ABS_MUNIC", "TFF_COBCTR","TFF_PRODUT","B1_DESC","TFJ_YQGANH","TFF_QTDVEN","TFF_PERINI","TFF_PERFIM","TFF_FUNCAO","RJ_DESC","TFF_ESCALA","TDW_DESC","TFJ_CODTAB","TV6_DESC"}
Static aCamposSnt	:= {{"A1_COD","CHV"},{"A1_NOME","ULT"},{"A1_LOJA","CHV"},{"ABS_ESTADO","ULT"},{"TFJ_YQGANH","ULT"},{"TFF_QTDVEN","SUM"},{"CN9_NUMERO","CHV"},{"CN9_REVISA","CHV"},{"AD1_DESCRI","ULT"},{"TFJ_YVGNHO","ULT"},{"CN9_VLINI","ULT"},{"CN9_SALDO","ULT"},{"CN9_DTINIC","ULT"},{"CN9_DTFIM","ULT"},{"TFJ_CODTAB","ULT"},{"TV6_DESC","ULT"},{"AOV_DESSEG","ULT"},{"AD1_SETOR","ULT"},{"AD1_YNRLIC","ULT"},{"TFJ_YINDC","ULT"},{"TFJ_YINDPL","ULT"},{"TFJ_YDTRJ","ULT"},{"TFF_LOCAL","CHV"},{"ABS_DESCRI","ULT"},{"TFL_YCC","ULT"}/*,{"TFL_YCC","CHV","SUBSTR(TFL_YCC,1,16)","TFLYCC16",16,0,"Centro de Custo"}*/}
Static aCamposAdd	:= {"CN9_DTINIC","CN9_DTFIM"}
Static aColsSntTo	:= {"T01","T02","T03","T04"}
/*/{Protheus.doc} RGSER001
Relatorio Contratos
@type function
@version 1.0
@author Saulo Gomes Martins
@since 06/10/2021
@obs 
aCampos		Campos que vão exibir no analitico
aCamposSnt	Campos que vão exibir no sintetico
aCamposAdd	Campos que não tem no analitico, mas precisa usar no sintetico
/*/
User Function RGSER001
	Local aParam			:= {}
	Local aRet				:= {}
	Local bOk				:= {|| .T. }
	Local cFilIni
	Local cFilFim
	Local cExtra 			:= 1
	Local l02				:= .F.
	Local l05				:= .T.
	Local l09				:= .F.
	Local l10				:= .F.
	
	If TYPE("cFilAnt")=="U"
		OpenSm0()
		SM0->(DbGoTop())
		RpcSetEnv(SM0->M0_CODIGO,"060101")
		__cInterNet	:= Nil
	EndIf
	cFilIni		:= Space(FWSizeFilia())
	cFilFim		:= Space(FWSizeFilia())
	cContraIni	:= Space(GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cContraFim	:= Replicate("Z",GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cCliIni		:= Space(GetSx3Cache("TFJ_CODENT","X3_TAMANHO"))
	cCliFim		:= Replicate("Z",GetSx3Cache("TFJ_CODENT","X3_TAMANHO"))
	cRevIni		:= Space(GetSx3Cache("CN9_REVISA","X3_TAMANHO"))
	cRevFim		:= Replicate("Z",GetSx3Cache("CN9_REVISA","X3_TAMANHO"))
	aAdd(aParam,{1,"Empresa De"		,cFilIni	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Empresa Até"	,cFilFim	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Cliente De"		,cCliIni	,"@!","","SA1",".T.",110,.F.})
	aAdd(aParam,{1,"Cliente Até"	,cCliFim	,"@!","","SA1",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato De"	,cContraIni	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato Até"	,cContraFim	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Revisão De"		,cRevIni	,"@!","","",".T.",110,.F.})
	aAdd(aParam,{1,"Revisão Até"	,cRevFim	,"@!","","",".T.",110,.F.})
	aAdd(aParam,{2,"Extra"		    ,cExtra     ,	{"1=Não", "2=Sim"},80,".T.",.F.})
	aAdd(aParam,{4,"Elaboração"		,l02	,""	,80,".T.",.F.})
	aAdd(aParam,{4,"Vigente"		,l05	,""	,80,".T.",.F.})
	aAdd(aParam,{4,"Em revisão"		,l09	,""	,80,".T.",.F.})
	aAdd(aParam,{4,"Revisado"		,l10	,""	,80,".T.",.F.})
	If !ParamBox(aParam,"Filtro",@aRet,bOk,,,,,,"RGSER001",.T.,.T.)
		Return
	EndIf
	cFilIni	:= aRet[1]
	cFilFim	:= aRet[2]
	cCliIni		:= aRet[3]
	cCliFim		:= aRet[4]
	cContraIni	:= aRet[5]
	cContraFim	:= aRet[6]
	cRevIni		:= aRet[7]
	cRevFim		:= aRet[8]
	cExtra		:= aRet[9]
	l02			:= aRet[10]
	l05			:= aRet[11]
	l09			:= aRet[12]
	l10			:= aRet[13]
	Processa({|lCancelar| RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,cExtra,l02,l05,l09,l10,@lCancelar) },,,.T.)
Return

Static Function RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,cExtra,l02,l05,l09,l10,lCancelar)
	Local oExcel
	Local oTabTmp,oTabTmp2
	Local cAliasTmp
	Local nLinha
	Local nCont
	Local nTamCampo
	Local cAba
	Local oCampoDet,oCmpTotSnt
	Local nColIni,nColFim
	Local nLinIni
	Local nColuna
	Local nCont2
	Local nPos
	Local cFormula
	Local aCamposTab	:= {}
	Local oFields		//Campos da tabela
	Local aAbas		:= {}
	Local nQtdAbas	:= 0
	Local nLenCampo
	Local nLenCmpTab
	Local nLenStruct
	Local nQtdRegTot	:= 0
	Local nRegistro
	Local nBordaAll
	Local nPosCor1,nPosCor2,nPosCor3
	Local nPosFont1
	Local oAlinhamento,oAlinham2
	Local oPosStyl0,oPosStyl1,oPosStyl2,oPosStyl3,oPosStyl4
	Local aTabTmp
	Private nIdStyle0,nIDMoeda,nIDPorc
	aTabTmp	:= cQuery(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,cExtra,l02,l05,l09,l10,@aCamposTab,@oFields,@oCampoDet,@aAbas,@oCmpTotSnt,@nQtdRegTot,@lCancelar)
	oTabTmp			:= aTabTmp[1]
	oTabTmp2		:= aTabTmp[2]
	nLenCampo		:= Len(aCampos)
	nLenCmpTab		:= Len(aCamposTab)
	cAliasTmp		:= oTabTmp:GetAlias()
	(cAliasTmp)->(DbGoTop())
	oExcel			:= YExcel():new()
	nBordaAll		:= oExcel:Borda("ALL")
	nPosCor1		:= oExcel:CorPreenc("AEAAAA")
	nPosCor2		:= oExcel:CorPreenc("B4C6E7")
	nPosCor3		:= oExcel:CorPreenc("C6E0B4")
	nPosFont1		:= oExcel:AddFont(11,"FF000000","Calibri","2",,.T.)
	oAlinhamento	:= oExcel:Alinhamento("center","center")
	oAlinham2		:= oExcel:Alinhamento("general","top",,.T.)
	oPosStyl0		:= oExcel:NewStyle():Setborder(nBordaAll)
	oPosStyl1		:= oExcel:NewStyle(oPosStyl0):Setfont(nPosFont1):Setfill(nPosCor1):SetaValores({oAlinham2})
	oPosStyl2		:= oExcel:NewStyle(oPosStyl0):Setfont(nPosFont1):Setfill(nPosCor2):SetaValores({oAlinham2})
	oPosStyl3		:= oExcel:NewStyle(oPosStyl0):Setfont(nPosFont1):Setfill(nPosCor2):SetaValores({oAlinhamento})
	oPosStyl4		:= oExcel:NewStyle(oPosStyl0):Setfont(nPosFont1):Setfill(nPosCor3):SetaValores({oAlinhamento})
	nIDMoeda		:= oExcel:NewStyle(oPosStyl0):SetnumFmt(44):GetId()
	nIDPorc			:= oExcel:NewStyle(oPosStyl0):SetnumFmt(10):GetId()
	nIdStyle0		:= oPosStyl0:GetId()

	oExcel:ADDPlan("Analítico")		//Adiciona uma planilha em branco
	oExcel:showGridLines(.F.)				//Oculta linhas de grade
	IncProc("Cabeçalho")
	ProcessMessage()
	nLinha	:= 1
	//Imprimi abas(primeira linha)
	For nCont:=1 to nLenCmpTab
		cAba	:= aCamposTab[nCont][2]
		nQtdAbas++
		nColIni	:= nCont+1+nLenCampo
		nColFim	:= nColIni
		If nCont<nLenCmpTab
			While nCont<=nLenCmpTab .AND. cAba==aCamposTab[nCont][2]
				nCont++
			EndDo
			nCont--
		EndIf
		nColFim	:= nCont+1+nLenCampo
		oExcel:Pos(nLinha,nColIni):SetValue(cAba)
		If nQtdAbas % 2 == 1
			oExcel:SetStyle(oPosStyl3)
		Else
			oExcel:SetStyle(oPosStyl4)
		EndIf
		oExcel:mergeCells(nLinha,nColIni,nLinha,nColFim)
	Next

	//Imprimi cabeçalho(segunda linha)
	oExcel:SetRowH(30)
	nLinha++
	oExcel:Pos(nLinha,1):SetValue("Filial"):SetStyle(oPosStyl1)
	For nCont:=1 to nLenCampo
		oExcel:Pos(nLinha,nCont+1):SetValue(Rtrim(oCampoDet[aCampos[nCont]]["X3_DESCRIC"])):SetStyle(oPosStyl1)
		nTamCampo	:= oCampoDet[aCampos[nCont]]["TAMCOL"]
		oExcel:AddTamCol(nCont+1,nCont+1,nTamCampo)
		oCampoDet[aCampos[nCont]]["STYLEID"]	:= oExcel:Masc2Style(oCampoDet[aCampos[nCont]]["X3_PICTURE"],oPosStyl0):GetId()
	Next
	SZ1->(DbSetOrder(1))
	For nCont:=1 to nLenCmpTab
		oExcel:Pos(nLinha,nCont+1+nLenCampo):SetValue(aCamposTab[nCont][5]):SetStyle(oPosStyl2)
		oExcel:AddComment("Titulo:"+aCamposTab[nCont][3]+"|Aba:"+aCamposTab[nCont][2])
		nTamCampo	:= NoRound(Len(aCamposTab[nCont][5])*0.75,2)
		nTamCampo	:= Max(nTamCampo,14)
		oExcel:AddTamCol(nCont+1+nLenCampo,nCont+1+nLenCampo,nTamCampo)
		If SZ1->(DbSeek(xFilial("SZ1")+aCamposTab[nCont][3])) .AND. !Empty(SZ1->Z1_TPCAMPO) .AND. SZ1->Z1_TPCAMPO!="N"
			If SZ1->Z1_TPCAMPO=="M"
				oFields[aCamposTab[nCont][3]]["styleid"]	:= nIDMoeda
			ElseIf SZ1->Z1_TPCAMPO=="P"
				oFields[aCamposTab[nCont][3]]["styleid"]	:= nIDPorc
			EndIf
		Else
			oFields[aCamposTab[nCont][3]]["styleid"]	:= oExcel:Masc2Style(oFields[aCamposTab[nCont][3]]["picture"],oPosStyl0):GetId()
		Endif
	Next
	nLinha++
	oExcel:SetRowH(nil)
	//Imprmir linhas
	nLinIni	:= nLinha
	ProcRegua(nQtdRegTot)
	nRegistro	:= 0
	While (cAliasTmp)->(!EOF())
		nRegistro++
		IncProc("Gerando relatório "+CValToChar(nRegistro)+"/"+CValToChar(nQtdRegTot))
		ProcessMessage()
		oExcel:Pos(nLinha,1):SetValue((cAliasTmp)->FILIAL):SetStyle(nIdStyle0)
		For nCont:=1 to nLenCampo
			oExcel:Pos(nLinha,nCont+1):SetValue((cAliasTmp)->(&(aCampos[nCont]))):SetStyle(oCampoDet[aCampos[nCont]]["STYLEID"])
		Next
		For nCont:=1 to nLenCmpTab
			nColuna	:= nCont+1+nLenCampo
			oExcel:Pos(nLinha,nColuna):SetValue((cAliasTmp)->(&(aCamposTab[nCont][1]))):SetStyle(oFields[aCamposTab[nCont][3]]["styleid"])
		Next
		nLinha++
		(cAliasTmp)->(DbSkip())
		If lCancelar
			Exit
		EndIf
	EndDo
	nLinha--
	If nRegistro>0
		oExcel:AutoFilter(2,1,nLinha-1,nLenCampo+nLenCmpTab+1)	//Auto filtro
	EndIf
	nLinha++
	IncProc("TOTAL")
	ProcessMessage()
	oExcel:Pos(nLinha,1):SetValue("TOTAL")
	SZ1->(DbSetOrder(1))
	For nCont:=1 to nLenCmpTab
		nColuna	:= nCont+1+nLenCampo
		If SZ1->(DbSeek(xFilial("SZ1")+aCamposTab[nCont][4]))
			If SZ1->Z1_TPTOTAL=="S"
				oExcel:Pos(nLinha,nColuna):SetValue(0,"SUBTOTAL(109,"+oExcel:Ref(nLinIni,nColuna)+":"+oExcel:Ref(nLinha-1,nColuna)+")"):SetStyle(oFields[aCamposTab[nCont][3]]["styleid"])
			ElseIf SZ1->Z1_TPTOTAL=="M"
				oExcel:Pos(nLinha,nColuna):SetValue(0,"SUBTOTAL(101,"+oExcel:Ref(nLinIni,nColuna)+":"+oExcel:Ref(nLinha-1,nColuna)+")"):SetStyle(oFields[aCamposTab[nCont][3]]["styleid"])
			ElseIf SZ1->Z1_TPTOTAL=="U"
				oExcel:Pos(nLinha,nColuna):SetValue(0,oExcel:Ref(nLinha-1,nColuna)):SetStyle(oFields[aCamposTab[nCont][3]]["styleid"])
			ElseIf SZ1->Z1_TPTOTAL=="F"
				cFormula	:= RTRIM(SZ1->Z1_FORMULA)
				For nCont2:=1 to nLenCmpTab
					nPos	:= At('"'+aCamposTab[nCont2][3]+'"',cFormula)
					If nPos>0
						cFormula	:= Replace(cFormula,'"'+aCamposTab[nCont2][3]+'"',oExcel:Ref(nLinha,nCont2+1+nLenCampo))
					EndIf
				Next
				oExcel:Pos(nLinha,nColuna):SetValue(0,cFormula):SetStyle(oFields[aCamposTab[nCont][3]]["styleid"])
			EndIf
		Else
			oExcel:Pos(nLinha,nColuna):SetValue(0,"SUBTOTAL(109,"+oExcel:Ref(nLinIni,nColuna)+":"+oExcel:Ref(nLinha-1,nColuna)+")"):SetStyle(oFields[aCamposTab[nCont][3]]["styleid"])
		EndIf
	Next
	oExcel:AddPane(2,2)	//Congela primeira linha e primeira coluna
	nLinha++
	If lCancelar
		oExcel:Pos(nLinha,1):SetValue("OPERAÇÃO CANCELADO PELO USUÝRIO!")
	EndIf

	oExcel:ADDPlan("Sintético")
	oExcel:showGridLines(.F.)				//Oculta linhas de grade
	cAliasTmp		:= oTabTmp2:GetAlias()
	(cAliasTmp)->(DbGoTop())
	nLinha	:= 1
	oExcel:Pos(nLinha,1):SetValue("Filial"):SetStyle(oPosStyl1)
	For nCont:=1 to Len(aCamposSnt)
		cNomeCampo	:= aCamposSnt[nCont][1]
		If Len(aCamposSnt[nCont])>=4
			cNomeCampo	:= aCamposSnt[nCont][4]
		Endif
		oExcel:Pos(nLinha,nCont+1):SetValue(oCampoDet[cNomeCampo]["X3_DESCRIC"]):SetStyle(oPosStyl1)
		nTamCampo	:= oCampoDet[cNomeCampo]["TAMCOL"]
		oExcel:AddTamCol(nCont+1,nCont+1,nTamCampo)
		If !oCampoDet[cNomeCampo]:HasProperty("STYLEID")
			oCampoDet[cNomeCampo]["STYLEID"]	:= oExcel:Masc2Style(oCampoDet[cNomeCampo]["X3_PICTURE"],oPosStyl0):GetId()
		EndIf
	Next
	For nCont:=1 to Len(aColsSntTo)
		oExcel:Pos(nLinha,nCont+1+Len(aCamposSnt)):SetValue(X3Combo("Z1_TOTSINT",aColsSntTo[nCont])):SetStyle(oPosStyl1)
		If !oCmpTotSnt:HasProperty(aColsSntTo[nCont])
			oCmpTotSnt[aColsSntTo[nCont]]	:= "0"
		EndIf
		oExcel:AddTamCol(nCont+1+Len(aCamposSnt),nCont+1+Len(aCamposSnt),17)
	Next
	//aStruct2	:= (cAliasTmp)->(DbStruct())
	nLenStruct	:= Len(aCamposSnt)
	While (cAliasTmp)->(!EOF())
		nLinha++
		oExcel:Pos(nLinha,1):SetValue((cAliasTmp)->FILIAL):SetStyle(nIdStyle0)
		For nCont:=1 to nLenStruct
			cNomeCampo	:= aCamposSnt[nCont][1]
			If Len(aCamposSnt[nCont])>=4
				cNomeCampo	:= aCamposSnt[nCont][4]
			Endif
			oExcel:Pos(nLinha,nCont+1):SetValue((cAliasTmp)->(&(cNomeCampo))):SetStyle(oCampoDet[cNomeCampo]["STYLEID"])
		Next
		For nCont:=1 to Len(aColsSntTo)
			oExcel:Pos(nLinha,nCont+1+Len(aCamposSnt)):SetValue((cAliasTmp)->(&(oCmpTotSnt[aColsSntTo[nCont]]))):SetStyle(nIDPorc)
		Next
		(cAliasTmp)->(DbSkip())
		If lCancelar
			Exit
		EndIf
	EndDo
	nLinha++
	If lCancelar
		oExcel:Pos(nLinha,1):SetValue("OPERAÇÃO CANCELADO PELO USUÝRIO!")
	EndIf
	oExcel:AddPane(1,3)	//Congela linha e coluna

	oExcel:Save(GetTempPath())
	oExcel:OpenApp()
	oExcel:Close()

	oTabTmp:Delete()
	oTabTmp2:Delete()
	FreeObj(oTabTmp)
	FreeObj(oTabTmp2)
	FreeObj(oExcel)
Return

Static Function cQuery(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,cExtra,l02,l05,l09,l10,aCamposTab,oFields,oCampoDet,aAbas,oCmpTotSnt,nQtdRegTot,lCancelar)
	Local cQuery,cAliasQry,cAliasQry2
	Local aStruct		:= {}
	Local aStruct2		:= {}
	Local cAliasTmp
	Local nCont,nContEmp
	Local nCont2
	Local cFilBkp		:= cFilAnt
	Local aSM0			:= FWLoadSM0()
	Local aFldData		:= {}
	Local cTipo
	Local aSituacao		:= {}
	Local nQtdReg		:= 0
	Local nRegistro
	Local nCont3
	Local nTam
	Local aCambos
	Local oTabTmp
	Local oTabTmp2
	Local aIndice		:= {}
	Local cChv
	Local oError
	Local cExtraQuery	:= ''
	oFields		:= jSonObject():New()
	SZ1->(DbSetOrder(1))
	nQtdRegTot	:= 0
	oCampoDet			:= jSonObject():New()
	oCmpTotSnt			:= jSonObject():New()
	//Private oDadosXML	:= tHashMap():New()
	If cValToChar(cExtra) == "1"
		cExtraQuery := " 	AND TFF.TFF_COBCTR='1'"
	EndIF
	If l02
		AADD(aSituacao,"02")
	EndIf
	If l05
		AADD(aSituacao,"05")
	EndIf
	If l09
		AADD(aSituacao,"09")
	EndIf
	If l10
		AADD(aSituacao,"10")
	EndIf
	AADD(aStruct,{"FILIAL"		,"C", FWSizeFilia()	, 00})
	AADD(aStruct2,{"FILIAL"		,"C", FWSizeFilia()	, 00})
	For nCont:=1 to Len(aColsSntTo)
		AADD(aStruct2,{aColsSntTo[nCont]		,"N", 18, 04})
	Next
	//CAMPOS DA QUERY PRINCIPAL
	For nCont:=1 to Len(aCampos)
		oCampoDet[aCampos[nCont]]				:= jSonObject():New()
		oCampoDet[aCampos[nCont]]["X3_CBOX"]	:= GetSx3Cache(aCampos[nCont],"X3_CBOX")
		oCampoDet[aCampos[nCont]]["X3_TAMANHO"]	:= GetSx3Cache(aCampos[nCont],"X3_TAMANHO")
		oCampoDet[aCampos[nCont]]["X3_DECIMAL"]	:= GetSx3Cache(aCampos[nCont],"X3_DECIMAL")
		oCampoDet[aCampos[nCont]]["X3_PICTURE"]	:= GetSx3Cache(aCampos[nCont],"X3_PICTURE")
		oCampoDet[aCampos[nCont]]["TAMANHO"]	:= oCampoDet[aCampos[nCont]]["X3_TAMANHO"]
		oCampoDet[aCampos[nCont]]["X3_DESCRIC"]	:= RTRIM(GetSx3Cache(aCampos[nCont],"X3_DESCRIC"))
		cTipo	:= GetSx3Cache(aCampos[nCont],"X3_TIPO")
		If Empty(oCampoDet[aCampos[nCont]]["X3_CBOX"])
			AADD(aStruct,{aCampos[nCont]	,cTipo, oCampoDet[aCampos[nCont]]["X3_TAMANHO"]	, oCampoDet[aCampos[nCont]]["X3_DECIMAL"]})
		Else
			nTam	:= 1
			aCambos	:= RetSx3Box(oCampoDet[aCampos[nCont]]["X3_CBOX"],,@nTam,oCampoDet[aCampos[nCont]]["X3_TAMANHO"])
			oCampoDet[aCampos[nCont]]["TAMANHO"]	:= nTam
			AADD(aStruct,{aCampos[nCont]	,cTipo, nTam	, 0})
		EndIf
		If cTipo=="D"
			AADD(aFldData,{aCampos[nCont],"D",8,0})
		EndIf
		oCampoDet[aCampos[nCont]]["TAMCOL"]		:= Min(100,Max(oCampoDet[aCampos[nCont]]["TAMANHO"],Len(oCampoDet[aCampos[nCont]]["X3_DESCRIC"])))
	Next
	For nCont:=1 to Len(aCamposAdd)
		cTipo	:= GetSx3Cache(aCamposAdd[nCont],"X3_TIPO")
		AADD(aStruct,{aCamposAdd[nCont]	,cTipo, GetSx3Cache(aCamposAdd[nCont],"X3_TAMANHO")	, GetSx3Cache(aCamposAdd[nCont],"X3_DECIMAL")})
		If cTipo=="D"
			AADD(aFldData,{aCamposAdd[nCont],"D",8,0})
		EndIf
	Next
	//CAMPOS DA TV7
	cQuery		:= "SELECT MIN(ORDABA) ORDABA,MIN(TV7_CODIGO) TV7_CODIGO,MIN(TV7_ORDEM) ORDEM,MAX(TV7_ABA) TV7_ABA,TV7_TITULO,MAX(TV7_TAM) TV7_TAM,MAX(TV7_DEC) TV7_DEC,MAX(TV7_DESC) TV7_DESC"
	cQuery		+= " FROM "+RetSqlName("TFF")+" TFF"
	cQuery		+= " INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_FILIAL=TFF_FILIAL AND TFL_CODIGO=TFF_CODPAI AND TFL_CODSUB=' ' AND TFL.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFJ_FILIAL=TFL_FILIAL AND TFJ_CODIGO=TFL_CODPAI AND TFJ_STATUS='1' AND TFJ.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TV6")+" TV6 ON TV6_FILIAL='"+xFilial("TV6")+"' AND TV6_NUMERO=TFJ_CODTAB AND TV6.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TV7")+" TV7 ON TV7_FILIAL='"+xFilial("TV7")+"' AND TV7_CODTAB=TV6_CODIGO AND TV7.D_E_L_E_T_=' '
	cQuery		+= " INNER JOIN "+RetSqlName("CN9")+" CN9 ON CN9_FILIAL=TFJ_FILIAL AND CN9_NUMERO=TFJ_CONTRT AND CN9_REVISA=TFJ_CONREV AND CN9.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN (SELECT MIN(TV7_CODIGO) ORDABA, TV7_ABA ABA"
	cQuery		+= " 	FROM "+RetSqlName("TFF")+" TFF"
	cQuery		+= " 	INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_FILIAL=TFF_FILIAL AND TFL_CODIGO=TFF_CODPAI AND TFL_CODSUB=' ' AND TFL.D_E_L_E_T_=' '"
	cQuery		+= " 	INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFJ_FILIAL=TFL_FILIAL AND TFJ_CODIGO=TFL_CODPAI AND TFJ_STATUS='1' AND TFJ.D_E_L_E_T_=' '"
	cQuery		+= " 	INNER JOIN "+RetSqlName("TV6")+" TV6 ON TV6_FILIAL='"+xFilial("TV6")+"' AND TV6_NUMERO=TFJ_CODTAB AND TV6.D_E_L_E_T_=' '"
	cQuery		+= " 	INNER JOIN "+RetSqlName("TV7")+" TV7 ON TV7_FILIAL='"+xFilial("TV7")+"' AND TV7_CODTAB=TV6_CODIGO AND TV7.D_E_L_E_T_=' '
	cQuery		+= " 	INNER JOIN "+RetSqlName("CN9")+" CN9 ON CN9_FILIAL=TFJ_FILIAL AND CN9_NUMERO=TFJ_CONTRT AND CN9_REVISA=TFJ_CONREV AND CN9.D_E_L_E_T_=' '"
	cQuery		+= " 	WHERE TFF_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"'"
	cQuery		+= " 	AND TFJ_CONTRT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"'"
	cQuery		+= " 	AND TFJ_CODENT BETWEEN '"+cCliIni+"' AND '"+cCliFim+"'"
	cQuery		+= " 	AND TFJ_CONREV BETWEEN '"+cRevIni+"' AND '"+cRevFim+"'"
	cQuery		+= " 	AND CN9_SITUAC IN ("
	For nCont:=1 to Len(aSituacao)
		If nCont>1
			cQuery		+= ","
		EndIf
		cQuery		+= "'"+aSituacao[nCont]+"'"
	Next
	If Empty(aSituacao)
		cQuery		+= "'!!'"
	EndIf
	cQuery		+= ")"
	cQuery		+= " 	AND TFF.D_E_L_E_T_=' '"
	cQuery		+= " 	AND TFF.TFF_ENCE <>'1'"
	cQuery		+= cExtraQuery
	cQuery		+= " 	AND TFJ_CODTAB<>' '"
	cQuery		+= " 	GROUP BY TV7_ABA) TABABA"
	cQuery		+= " ON ABA=TV7_ABA"
	cQuery		+= " WHERE TFF_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"'"
	cQuery		+= " AND TFJ_CONTRT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"'"
	cQuery		+= " AND TFJ_CODENT BETWEEN '"+cCliIni+"' AND '"+cCliFim+"'"
	cQuery		+= " AND TFJ_CONREV BETWEEN '"+cRevIni+"' AND '"+cRevFim+"'"
	cQuery		+= " AND CN9_SITUAC IN ("
	For nCont:=1 to Len(aSituacao)
		If nCont>1
			cQuery		+= ","
		EndIf
		cQuery		+= "'"+aSituacao[nCont]+"'"
	Next
	If Empty(aSituacao)
		cQuery		+= "'!!'"
	EndIf
	cQuery		+= ")"
	cQuery		+= " AND TFF.D_E_L_E_T_=' '"
	cQuery		+= " AND TFF.TFF_ENCE <>'1'"
	cQuery		+= cExtraQuery
	cQuery		+= " AND TFJ_CODTAB<>' '"
	cQuery		+= " GROUP BY TV7_TITULO"
	cQuery		+= " ORDER BY 1,2"
	cAliasQry	:= MpSysOpenQuery(cQuery)
	nCont:=1
	While (cAliasQry)->(!EOF())
		cCampo	:= "FLD"+STRZERO(nCont,4)
		AADD(aStruct,{cCampo,"N",(cAliasQry)->TV7_TAM,(cAliasQry)->TV7_DEC})
		AADD(aStruct2,{cCampo,"N",(cAliasQry)->TV7_TAM,(cAliasQry)->TV7_DEC})
		AADD(aCamposTab,{cCampo,RTRIM((cAliasQry)->TV7_ABA),RTRIM((cAliasQry)->TV7_TITULO),PadR((cAliasQry)->TV7_TITULO,GetSx3Cache("Z1_CODTV7","X3_TAMANHO")),RTRIM((cAliasQry)->TV7_DESC)})
		nCont++
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]				:= jSonObject():New()
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["campo"]	:= cCampo
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["descricao"]:= RTRIM((cAliasQry)->TV7_TITULO)
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["aba"]		:= RTRIM((cAliasQry)->TV7_ABA)
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["picture"]	:= ""
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["mult"]		:= 1
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["tab"]		:= ""
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["totalizador"]:= "SUM"
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["tamanho"]	:= (cAliasQry)->TV7_TAM
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["decimal"]	:= (cAliasQry)->TV7_DEC
		oFields[RTRIM((cAliasQry)->TV7_TITULO)]["styleid"]	:= nil
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DBCloseArea())
	
	//CAMPOS DO SINTETICO
	cChv	:= "cFilAnt"
	aIndice	:= {"FILIAL"}
	For nCont:=1 to Len(aCamposSnt)
		nPos		:= aScan(aStruct,{|x| x[1]==aCamposSnt[nCont][1] })
		If nPos>0
			cNomeCampo	:= aCamposSnt[nCont][1]
			AADD(aStruct2,aClone(aStruct[nPos]))
			If aCamposSnt[nCont][2]=="CHV"
				cChv	+= "+"
				If Len(aCamposSnt[nCont])>=3
					cChv		+= aCamposSnt[nCont][3]
					cNomeCampo	:= aCamposSnt[nCont][4]
					aStruct2[Len(aStruct2)][1]	:= aCamposSnt[nCont][4]
					aStruct2[Len(aStruct2)][3]	:= aCamposSnt[nCont][5]
					aStruct2[Len(aStruct2)][4]	:= aCamposSnt[nCont][6]
				ElseIf aStruct[nPos][2]=="D"
					cChv	+= "DTOS("+aCamposSnt[nCont][1]+")"
				Else
					cChv	+= aCamposSnt[nCont][1]
				EndIf
				AADD(aIndice,cNomeCampo)
			ElseIf aCamposSnt[nCont][2]=="AVG"
				//Cria mais dois campo para apoiar
				cCampo	:= "T_"+STRZERO(nCont,4)
				AADD(aStruct2,{cCampo,"N",aStruct[nPos][3],aStruct[nPos][4]})
				cCampo	:= "Q_"+STRZERO(nCont,4)
				AADD(aStruct2,{cCampo,"N",aStruct[nPos][3],aStruct[nPos][4]})
			EndIf
			If !oCampoDet:HasProperty(cNomeCampo)
				oCampoDet[cNomeCampo]				:= jSonObject():New()
				oCampoDet[cNomeCampo]["X3_CBOX"]	:= GetSx3Cache(aCamposSnt[nCont][1],"X3_CBOX")
				If Len(aCamposSnt[nCont])>=5
					oCampoDet[cNomeCampo]["X3_TAMANHO"]	:= aCamposSnt[nCont][5]
				Else
					oCampoDet[cNomeCampo]["X3_TAMANHO"]	:= GetSx3Cache(aCamposSnt[nCont][1],"X3_TAMANHO")
				Endif
				If Len(aCamposSnt[nCont])>=6
					oCampoDet[cNomeCampo]["X3_DECIMAL"]	:= aCamposSnt[nCont][6]
				Else
					oCampoDet[cNomeCampo]["X3_DECIMAL"]	:= GetSx3Cache(aCamposSnt[nCont][1],"X3_DECIMAL")
				Endif
				oCampoDet[cNomeCampo]["X3_PICTURE"]	:= GetSx3Cache(aCamposSnt[nCont][1],"X3_PICTURE")
				oCampoDet[cNomeCampo]["TAMANHO"]	:= oCampoDet[cNomeCampo]["X3_TAMANHO"]
				If Len(aCamposSnt[nCont])>=7
					oCampoDet[cNomeCampo]["X3_DESCRIC"]	:= aCamposSnt[nCont][7]
				Else
					oCampoDet[cNomeCampo]["X3_DESCRIC"]	:= RTRIM(GetSx3Cache(cNomeCampo,"X3_DESCRIC"))
				Endif
				oCampoDet[cNomeCampo]["TAMCOL"]		:= Min(100,Max(oCampoDet[cNomeCampo]["TAMANHO"],Len(oCampoDet[cNomeCampo]["X3_DESCRIC"])*0.75))
			EndIf
		EndIf
	Next

	nLenCmpTab	:= Len(aCamposTab)
	For nCont:=1 to nLenCmpTab	
		If SZ1->(DbSeek(xFilial("SZ1")+aCamposTab[nCont][4]))
			If !Empty(SZ1->Z1_TOTSINT)
				oCmpTotSnt[SZ1->Z1_TOTSINT]	:= aCamposTab[nCont][1]
			EndIf
			oCmpTotSnt["STYLEID"]	:= nil
			If SZ1->Z1_TPCAMPO=="M"
				oFields[aCamposTab[nCont][3]]["styleid"]	:= nIDMoeda
			ElseIf SZ1->Z1_TPCAMPO=="P"
				oFields[aCamposTab[nCont][3]]["styleid"]	:= nIDPorc
				oFields[aCamposTab[nCont][3]]["mult"]		:= 0.01	//Transforma em porcento
				nPos	:= aScan(aStruct2,{|x| x[1]==aCamposTab[nCont][1] })
				If nPos>0	//Adiciona casas decimais por é por 100
					aStruct2[nPos][3]	+= 2
					aStruct2[nPos][4]	+= 2
				EndIf
				nPos	:= aScan(aStruct,{|x| x[1]==aCamposTab[nCont][1] })
				If nPos>0	//Adiciona casas decimais por é por 100
					aStruct[nPos][3]	+= 2
					aStruct[nPos][4]	+= 2
				EndIf
				oFields[aCamposTab[nCont][3]]["tamanho"]	+= 2
				oFields[aCamposTab[nCont][3]]["decimal"]	+= 2
			EndIf

			If SZ1->Z1_TPTOTAL=="S"
				oFields[aCamposTab[nCont][3]]["totalizador"]:= "SUM"
			ElseIf SZ1->Z1_TPTOTAL=="M"
				//Cria mais dois campo para apoiar
				cCampo	:= "T_"+aCamposTab[nCont][1]
				AADD(aStruct2,{cCampo,"N",oFields[aCamposTab[nCont][3]]["tamanho"],oFields[aCamposTab[nCont][3]]["decimal"]})
				cCampo	:= "Q_"+aCamposTab[nCont][1]
				AADD(aStruct2,{cCampo,"N",oFields[aCamposTab[nCont][3]]["tamanho"],oFields[aCamposTab[nCont][3]]["decimal"]})
				oFields[aCamposTab[nCont][3]]["totalizador"]	:= "AVG"
			ElseIf SZ1->Z1_TPTOTAL=="U"
				oFields[aCamposTab[nCont][3]]["totalizador"]	:= "ULT"
			ElseIf SZ1->Z1_TPTOTAL=="F"
				cFormula	:= RTRIM(SZ1->Z1_FORMULA)
				For nCont2:=1 to nLenCmpTab
					nPos	:= At('"'+aCamposTab[nCont2][3]+'"',cFormula)
					If nPos>0
						cFormula	:= Replace(cFormula,'"'+aCamposTab[nCont2][3]+'"',aCamposTab[nCont2][1] )
					EndIf
				Next
				oFields[aCamposTab[nCont][3]]["totalizador"]	:= cFormula
			EndIf
		Else
			oFields[aCamposTab[nCont][3]]["totalizador"]	:= "SUM"
		EndIF
	Next

	oTabTmp	:= FWTemporaryTable():New()
	oTabTmp:SetFields( aStruct )
	oTabTmp:Create()
	cAliasTmp	:= oTabTmp:GetAlias()
	oTabTmp2	:= FWTemporaryTable():New()
	oTabTmp2:SetFields( aStruct2 )
	oTabTmp2:AddIndex("indice1", aIndice )
	oTabTmp2:Create()
	cAliasTmp2	:= oTabTmp2:GetAlias()
	For nContEmp:=1 to Len(aSM0)
		If lCancelar
			Exit
		Endif
		If aSM0[nContEmp][1]!=cEmpAnt
			Loop
		EndIf
		If aSM0[nContEmp][16]=="1"
			Loop	//Empresa bloqueada
		EndIf
		If !(cFilIni<=Alltrim(aSM0[nContEmp][2]) .AND. cFilFim>=Alltrim(aSM0[nContEmp][2]))
			Loop
		EndIf
		cFilAnt	:= Alltrim(aSM0[nContEmp][2])

		cQuery		:= "SELECT TFF_FILIAL"
		For nCont:=1 to Len(aCampos)
			cQuery		+= ","+aCampos[nCont]
		Next
		For nCont:=1 to Len(aCamposAdd)
			cQuery		+= ","+aCamposAdd[nCont]
		Next
		cQuery		+= ", TFF.R_E_C_N_O_ REGTFF"
		cQuery		+= ", TV6_CODIGO CODTV6"
		cQuery		+= " FROM "+RetSqlName("TFF")+" TFF"
		cQuery		+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD=TFF_PRODUT AND SB1.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("ABS")+" ABS ON ABS_FILIAL='"+xFilial("ABS")+"' AND ABS_LOCAL=TFF_LOCAL AND ABS.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_FILIAL='"+xFilial("TFL")+"' AND TFL_CODIGO=TFF_CODPAI AND TFL_CODSUB=' ' AND TFL.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_FILIAL='"+xFilial("CTT")+"' AND CTT_CUSTO=TFL_YCC AND CTT.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFJ_FILIAL='"+xFilial("TFJ")+"' AND TFJ_CODIGO=TFL_CODPAI AND TFJ_STATUS='1' AND TFJ.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("SE4")+" SE4 ON E4_FILIAL='"+xFilial("SE4")+"' AND E4_CODIGO=TFJ_CONDPG AND SE4.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=TFJ_CODENT AND A1_LOJA=TFJ_LOJA AND SA1.D_E_L_E_T_=' '"
		cQuery		+= " LEFT JOIN "+RetSqlName("AOV")+" AOV ON AOV_FILIAL='"+xFilial("AOV")+"' AND AOV_CODSEG=A1_CODSEG AND AOV.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FILIAL='"+xFilial("SRJ")+"' AND RJ_FUNCAO=TFF_FUNCAO AND SRJ.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("TDW")+" TDW ON TDW_FILIAL='"+xFilial("TDW")+"' AND TDW_COD=TFF_ESCALA AND TDW.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("TV6")+" TV6 ON TV6_FILIAL='"+xFilial("TV6")+"' AND TV6_NUMERO=TFJ_CODTAB AND TV6.D_E_L_E_T_=' ' AND TV6_REVISA = TFJ_TABREV  "
		cQuery		+= " INNER JOIN "+RetSqlName("CN9")+" CN9 ON CN9_FILIAL='"+xFilial("CN9")+"' AND CN9_NUMERO=TFJ_CONTRT AND CN9_REVISA=TFJ_CONREV AND CN9.D_E_L_E_T_=' '"
		cQuery		+= " INNER JOIN "+RetSqlName("ADY")+" ADY ON ADY_FILIAL='"+xFilial("ADY")+"' AND ADY_PROPOS=TFJ_PROPOS AND ADY_PREVIS=TFJ_PREVIS AND ADY.D_E_L_E_T_=' ' "
		cQuery		+= " INNER JOIN "+RetSqlName("AD1")+" AD1 ON AD1_FILIAL='"+xFilial("AD1")+"' AND AD1_NROPOR=ADY_OPORTU AND AD1_REVISA=ADY_REVISA AND AD1.D_E_L_E_T_=' ' "
		cQuery		+= " WHERE TFF_FILIAL='"+xFilial("TFF")+"'"
		cQuery		+= " AND TFJ_CONTRT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"'"
		cQuery		+= " AND TFJ_CODENT BETWEEN '"+cCliIni+"' AND '"+cCliFim+"'"
		cQuery		+= " AND TFJ_CONREV BETWEEN '"+cRevIni+"' AND '"+cRevFim+"'"
		cQuery		+= " AND CN9_SITUAC IN ("
		For nCont:=1 to Len(aSituacao)
			If nCont>1
				cQuery		+= ","
			EndIf
			cQuery		+= "'"+aSituacao[nCont]+"'"
		Next
		If Empty(aSituacao)
			cQuery		+= "'!!'"
		EndIf
		cQuery		+= ")"
		cQuery		+= " AND TFF.TFF_ENCE <>'1'"	
		cQuery		+= cExtraQuery	
		cQuery		+= " AND TFJ_CODTAB<>' '"
		cQuery		+= " AND TFF.D_E_L_E_T_=' '"
		cAliasQry	:= MpSysOpenQuery("SELECT COUNT(*) QTD FROM ("+cQuery+") TAB01",,aFldData)
		nQtdReg		:= (cAliasQry)->QTD
		(cAliasQry)->(DBCloseArea())
		ProcRegua(nQtdReg)
		nQtdRegTot	+= nQtdReg
		nRegistro	:= 0
		cAliasQry	:= MpSysOpenQuery(cQuery,,aFldData)
		While (cAliasQry)->(!EOF())
			If lCancelar
				Exit
			EndIf
			nRegistro++
			IncProc("Consultando dados "+CValToChar(nRegistro)+"/"+CValToChar(nQtdReg))
			ProcessMessage()
			TFF->(DbGoTo((cAliasQry)->REGTFF))
			
			//Analitico
			RecLock(cAliasTmp, .T.)
			(cAliasTmp)->FILIAL		:= cFilAnt
			For nCont:=1 to Len(aCampos)
				If Empty(oCampoDet[aCampos[nCont]]["X3_CBOX"])
					(cAliasTmp)->(&(aCampos[nCont]))	:= (cAliasQry)->(&(aCampos[nCont]))
				Else
					(cAliasTmp)->(&(aCampos[nCont]))	:= X3Combo(aCampos[nCont],(cAliasQry)->(&(aCampos[nCont])))
				EndIf
			Next
			For nCont:=1 to Len(aCamposAdd)
				(cAliasTmp)->(&(aCamposAdd[nCont]))	:= (cAliasQry)->(&(aCamposAdd[nCont]))
			Next
			//preenche a tabela temporaria com o xml
			oXml	:= TXmlManager():New()
			oXml:Parse('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'+TFF->TFF_TABXML)
			For nCont2:=1 to oXml:XPathChildCount("/FWMODELSHEET/MODEL_SHEET/MODEL_CELLS/items")
				If lCancelar
					Exit
				EndIf
				//Impa é o nome da coluna, par é os valores
				//cNomeCampo	:= oXml:XPathGetNodeValue("/FWMODELSHEET/MODEL_SHEET/MODEL_CELLS/items/item["+cValToChar(nCont2)+"]/VALUE")
				nCont2++
				//If Empty(cNomeCampo)
				//	Loop
				//EndIF
				aChildren	:= oXml:XPathGetChildArray("/FWMODELSHEET/MODEL_SHEET/MODEL_CELLS/items/item["+cValToChar(nCont2)+"]")
				oTmp		:= jSonObject():New()
				For nCont3:=1 to Len(aChildren)
					oTmp[aChildren[nCont3][1]]	:= aChildren[nCont3][3]
				Next
				cNomeCampo	:= ""
				cQuery		:= "SELECT TV7_TITULO"
				cQuery		+= " FROM "+RetSqlName("TV7")+" TV7"
				cQuery		+= " WHERE TV7_FILIAL='"+xFilial("TV7")+"'"
				cQuery		+= " AND TV7_CODTAB='"+(cAliasQry)->CODTV6+"'"
				cQuery		+= " AND TV7_IDENT='"+oTmp["NICKNAME"]+"'"
				cQuery		+= " AND TV7.D_E_L_E_T_=' '"
				cAliasQry2	:= MpSysOpenQuery(cQuery)
				If (cAliasQry2)->(!EOF())
					cNomeCampo	:= RTRIM((cAliasQry2)->TV7_TITULO)
					(cAliasQry2)->(DbSkip())
				EndIf
				(cAliasQry2)->(DBCloseArea())
				
				If !Empty(cNomeCampo) .AND. ValType(oFields[cNomeCampo])=="J"
					(cAliasTmp)->(&(oFields[cNomeCampo]["campo"]))	:= Val(oTmp["VALUE"])*oFields[cNomeCampo]["mult"]
					oFields[cNomeCampo]["picture"]	:= oTmp["PICTURE"]
				EndIf
				FreeObj(oTmp)
			Next
			(cAliasTmp)->(MsUnlock())

			//Sintetico
			If (cAliasTmp2)->(DbSeek( (cAliasQry)->( &(cChv) ) ))
				RecLock(cAliasTmp2, .F.)
			Else
				RecLock(cAliasTmp2, .T.)
			EndIf
			(cAliasTmp2)->FILIAL		:= cFilAnt
			For nCont:=1 to Len(aCamposSnt)
				cNomeCampo	:= aCamposSnt[nCont][1]
				If Len(aCamposSnt[nCont])>=4
					cNomeCampo	:= aCamposSnt[nCont][4]
				Endif
				If aCamposSnt[nCont][2]=="CHV"
					(cAliasTmp2)->(&(cNomeCampo))	:= (cAliasQry)->(&(aCamposSnt[nCont][1]))
				ElseIf aCamposSnt[nCont][2]=="SUM"
					(cAliasTmp2)->(&(cNomeCampo))	+= (cAliasQry)->(&(aCamposSnt[nCont][1]))
				ElseIf aCamposSnt[nCont][2]=="ULT"
					(cAliasTmp2)->(&(cNomeCampo))	:= (cAliasQry)->(&(aCamposSnt[nCont][1]))
				ElseIf aCamposSnt[nCont][2]=="AVG"
					(cAliasTmp2)->(&("T_"+STRZERO(nCont,4)))	+= (cAliasQry)->(&(aCamposSnt[nCont][1]))
					(cAliasTmp2)->(&("Q_"+STRZERO(nCont,4)))	+= 1
					(cAliasTmp2)->(&(cNomeCampo))				+= (cAliasTmp2)->(&("T_"+STRZERO(nCont,4)))/(cAliasTmp2)->(&("Q_"+STRZERO(nCont,4)))
				ElseIf aCamposSnt[nCont][2]=="MAX"
					If (cAliasQry)->(&(aCamposSnt[nCont][1])) > (cAliasTmp2)->(&(cNomeCampo))
						(cAliasTmp2)->(&(cNomeCampo))	:= (cAliasQry)->(&(aCamposSnt[nCont][1]))
					EndIf
				EndIf
			Next
			//Sintetico tabela do xml
			For nCont:=1 to nLenCmpTab
				If oFields[aCamposTab[nCont][3]]["totalizador"]=="SUM"
					(cAliasTmp2)->(&(aCamposTab[nCont][1]))			+= (cAliasTmp)->(&(aCamposTab[nCont][1]))
				ElseIf oFields[aCamposTab[nCont][3]]["totalizador"]=="ULT"
					(cAliasTmp2)->(&(aCamposTab[nCont][1]))			:= (cAliasTmp)->(&(aCamposTab[nCont][1]))
				ElseIf oFields[aCamposTab[nCont][3]]["totalizador"]=="AVG"
					(cAliasTmp2)->(&("T_"+aCamposTab[nCont][1]))	+= (cAliasTmp)->(&(aCamposTab[nCont][1]))
					(cAliasTmp2)->(&("Q_"+aCamposTab[nCont][1]))	+= 1
					(cAliasTmp2)->(&(aCamposTab[nCont][1]))			:= (cAliasTmp2)->(&("T_"+aCamposTab[nCont][1]))/(cAliasTmp2)->(&("Q_"+aCamposTab[nCont][1]))
				EndIF
			Next
			//As formulas depois, pois primeiro tem que compor os valores
			oError := ErrorBlock({|e| Erro(e,@lCancelar) } )
			For nCont:=1 to nLenCmpTab
				If oFields[aCamposTab[nCont][3]]["totalizador"]!="SUM" .AND. oFields[aCamposTab[nCont][3]]["totalizador"]!="ULT" .AND. oFields[aCamposTab[nCont][3]]["totalizador"]!="AVG"
					(cAliasTmp2)->(&(aCamposTab[nCont][1]))	:= (cAliasTmp2)->(&(oFields[aCamposTab[nCont][3]]["totalizador"]))
				EndIf
				If lCancelar
					Exit
				Endif
			Next
			ErrorBlock(oError)
			(cAliasTmp2)->(MsUnlock())

			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DBCloseArea())
	Next
	cFilAnt	:= cFilBkp
Return {oTabTmp,oTabTmp2}

Static Function Erro(e,lCancelar)
	MsgAlert("Erro na formula")
	lCancelar	:= .T.
Return
//User Function ytst
//oExcel			:= YExcel():new()
//oExcel:ADDPlan("Teste")
//oExcel:Pos(1,1):SetValue("Teste 123")
//oExcel:AddComment("codigo")
//oExcel:Save(GetTempPath())
//oExcel:OpenApp()
//oExcel:Close()
//Return
