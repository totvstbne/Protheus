#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "fwbrowse.ch"

/*/{Protheus.doc} RCOMTT01
//TODO: Ajeitar o problema na tela de locais atendimento. O cursor fica subindo apoós clicar em qualquer linha da grid.
//TODO: Verificar se colocando o grid de locais como array resolve o problema do cursor maluco
//TODO: Double click em todas as telas para abrir a tela padrao correspondentes a cada grid
//TODO: Realizar um teste de todas as funcionalidades juntas
@author Levy Gurgel Chaves
@since 14/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function RCOMTT01()
	local oDlg
	local aCoord := FwGetDialogSize( oMainWnd ) ////Array de coordenadas { nTop, nLeft, nBottom, nRight }.
	local cQuery, oColumn
	local nCont := 3 //posicao inicial da criacao das colunas da grid de atendentes
	local aSkContr := {}, aSkLoc := {}, aSkAten := {}
	local aLocIndex := aContIndex := {}
	local oContra, oLocais, oAtenden //objetos das posicoes na tela
	local aParam := {}
	local aRet := {}
	local bOk := {|| .T. }
	Private lFlag := .T., lCtlFLag := .T.
	Private dDataIni,dDataFim, dIniAux, cStr := nil
	Private aContratos, aLocais, aAtendente

	aAdd(aParam,{1,"Data De ", dDataBase,"@D","","",".T.",110,.T.})
	aAdd(aParam,{1,"Data Ate ", dDataBase,"@D","","",".T.",110,.T.})

	If !ParamBox(aParam,"",@aRet,bOk,,,,,,"TESCFUN",.T.,.T.)
		Return
	Else
		dDataIni := aRet[1]
		dDataFim := aRet[2]
	EndIf

	oDlg := MSDialog():New(aCoord[1], aCoord[2], aCoord[3], aCoord[4], "Tabela de Escalas",,,,,CLR_BLACK,RGB(0,0,0),,,.T.)
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )
	//disposicao da layer na tela
	oFWLayer:addLine("LIN1", 40, .F.) //nome, porcent da tela e se a linha e fixa
	oFWLayer:addLine("LIN2", 60, .F.)
	oFWLayer:addCollumn("COL1", 45, .F., "LIN1")
	oFWLayer:addCollumn("COL2", 55, .F., "LIN1")
	//parte da tela referente a localizacao. Retorno eh um FWBrowse
	lin1c1 := oFWLayer:getColPanel("COL1", "LIN1")
	lin1c2 := oFWLayer:getColPanel("COL2", "LIN1")
	lin2 := oFWLayer:getLinePanel("LIN2")
	
	//BROWSE DE CONTRATOS 
	cQuery := contratQuery()
	//cria o browse
	oContra := FWBrowse():New(lin1c1)
	oContra:setDataQuery(.T.)
	aAdd(aContIndex, "COD")
	aAdd(aContIndex, "CONTRATO")
//	oContra:setQueryIndex(aContIndex) //problema no page up e page down
	oContra:setQuery(cQuery)
	oContra:setAlias("TMPA")
	oContra:setLocate()
	oContra:setDescription("Lista de contratos")
	oContra:setUseFilter()
	oContra:setChange( {|| cliqueContratos(oContra, oLocais, oAtenden) } )
	aAdd(aSkContr,{"Codigo", {{"","N", tamSX3("TFJ_CODIGO")[1], 0, "Codigo"}}, 1, .T. } )
	aAdd(aSkContr,{"Numero Contrato", {{"","N", tamSX3("TFJ_CONTRT")[1], 0, "Numero Contrato"}}, 2, .T. } )
	oContra:setSeek(, aSkContr)
	oContra:setProfileID("TMPGS_A")
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->CONTRATO) } TITLE "Numero" SIZE 10 OF oContra
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->NOME) } TITLE "Cliente" SIZE tamSX3("A1_NOME")[1] OF oContra
	ADD COLUMN oColumn DATA { || StoD(TMPA->INICIO) } TITLE "Inicio" SIZE tamSX3("CN9_DTINIC")[1] OF oContra
	ADD COLUMN oColumn DATA { || StoD(TMPA->FIM) } TITLE "Fim" SIZE tamSX3("CN9_DTFIM")[1] OF oContra
	oContra:disableConfig()
	oContra:disableReport()
	oContra:setDoubleClick({|| cliqueContratos(oContra, oLocais, oAtenden) })
	oContra:setOwner(lin1c1)
	
	//BROWSE DE LOCAIS DE ATENDIMENTO
	cQuery := locaisQuery('00000000')
	oLocais := FWBrowse():New(lin1c2)
	oLocais:setDataQuery(.T.)
	oLocais:setAlias("TMPB")
	oLocais:setQuery(cQuery)
	oLocais:setDescription("Locais de atendimento")
	aAdd(aLocIndex, "ABQ_LOCAL")
	aAdd(aLocIndex, "ABQ_FUNCAO")
	oLocais:setLocate()
//	oLocais:setUseFilter()
	aAdd( aSkLoc, {"Local", {{"","C", tamSX3("ABQ_LOCAL")[1], 0, "Local"}}, 1, .T. })
	aAdd( aSkLoc, {"Funcao", {{"","C", tamSX3("ABQ_FUNCAO")[1], 0, "Funcao"}}, 2, .T. })
	oLocais:setSeek(,aSkLoc)
	oLocais:setProfileID("TMPGS_B")
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->ABQ_LOCAL) } TITLE "Local" SIZE 6 OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->ABS_DESCRI) } TITLE "Descricao" SIZE tamSX3("ABS_DESCRI")[1] OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->B1_COD) } TITLE "Produto" SIZE 6 OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->B1_DESC) } TITLE "Descricao" SIZE 15 OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->ABQ_FUNCAO) } TITLE "Funcao" SIZE 6 OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->RJ_DESC) } TITLE "Descricao" SIZE 15 OF oLocais
	ADD COLUMN oColumn DATA { || StoD(TMPB->ABQ_PERINI) } TITLE "Periodo Ini" SIZE tamSX3("ABQ_PERINI")[1] OF oLocais
	ADD COLUMN oColumn DATA { || StoD(TMPB->ABQ_PERFIM) } TITLE "Periodo Fim" SIZE tamSX3("ABQ_PERFIM")[1] OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->ABQ_TURNO) } TITLE "Turno" SIZE 6 OF oLocais
	ADD COLUMN oColumn DATA { || RTRIM(TMPB->R6_DESC) } TITLE "Descricao" SIZE 15 OF oLocais
	ADD COLUMN oColumn DATA { || TMPB->ABQ_TOTAL } TITLE "Hrs Totais" SIZE 4 OF oLocais
	ADD COLUMN oColumn DATA { || TMPB->ABQ_FATOR } TITLE "Fator" SIZE 4 OF oLocais
	oLocais:disableConfig()	
	oLocais:disableReport()
	//oLocais:setDoubleClick({|oLocais| cliqueLocais(oContra,oLocais,oAtenden)}) //
	oLocais:setOwner(lin1c2)
//	DBCloseArea()

	aAtendente := atendDados()
	aAdd( aSkAten, {"CodAtendente", {{"","N", tamSX3("ABB_CODTEC")[1], 0, "CodAtendente"}}, 1, .T. })
	aAdd( aSkAten, {"Atendente", {{"","N", tamSX3("AA1_NOMTEC")[1], 0, "Atendente"}}, 2, .T. })
	oAtenden := FWBrowse():New()(lin2)
	oAtenden:setDataArray(.T.)
	oAtenden:setDescription("Lista de Atendentes")
	oAtenden:setAlias("TMPC")
	oAtenden:setArray(@aAtendente)
	oAtenden:setLocate()
	oAtenden:setUseFilter()
	oAtenden:setProfileID("TMPGS_C")
	oAtenden:setSeek(,aSkAten)

	ADD COLUMN oColumn DATA { |oAtenden| aAtendente[oAtenden:At()][1]  } TITLE "Atendente" SIZE 10 OF oAtenden 
	ADD COLUMN oColumn DATA { |oAtenden| aAtendente[oAtenden:At()][2]  } TITLE "Nome Atendente" SIZE tamSX3("AA1_NOMTEC")[1] OF oAtenden
	
	dIniAux := dDataIni
	while dIniAux <= dDataFim 
		cStr := getWeekDay(dIniAux) + " " +DTOC(dIniAux)
		bBloco := &("{ || aAtendente[oAtenden:At()]["+cValToChar(nCont)+"] }")
		//macro execucao. recebe uma string, tira as aspas e executa o conteudo da string comando selecionado.
		ADD COLUMN oColumn DATA bBloco TITLE cStr SIZE 6 OF oAtenden
		dIniAux += 1
		nCont += 1 
	endDo
	oAtenden:disableReport()
	oAtenden:disableConfig()
	oAtenden:setOwner(lin2)
	
	oContra:setFocus()
	oContra:Activate()
	oLocais:Activate()
	oAtenden:Activate()
	oAtenden:Browse():nFreeze := 2
	oAtenden:SetLineHeight(25)

	oDlg:Activate(,,,.T.,{||  },, )
return

static function cliqueContratos(oContra, oLocais, oAtenden)
	//so consegui fazer o clique contratos funcionar com o setchange dessa maneira com o boolean.
	//pelo que notei, o setchange realiza um pre-execucao do bloco de codigo, porem o browse nao estava
	//ativo, logo dava erro. Nao gostei dessa maneira. Irei procurar um jeito mais correto de fazer isso. 
	if lCtlFLag
		lCtlFLag := .F.
	else
		 cContrato := (oContra:oData:cAlias)->CONTRATO //cod contrato
		 cQueryLoc := locaisQuery(cContrato)
		 cLocal := (oLocais:oData:cAlias)->ABQ_LOCAL //codigo do local
		aAtendente := {}
		//Alert(cQueryLoc)
		oLocais:setQuery(cQueryLoc)
		oAtenden:setArray(@aAtendente)
		oAtenden:Browse():nFreeze := 0
		oLocais:Refresh()
		oAtenden:Refresh()
		oLocais:Refresh()
	endIf
	
return 

static function cliqueLocais(oContra,oLocais,oAtenden)
	Local cContrato := (oContra:oData:cAlias)->CONTRATO
	Local cFuncao := (oLocais:oData:cAlias)->ABQ_FUNCAO
	Local cTurno := (oLocais:oData:cAlias)->ABQ_TURNO
	Local cLocal	:= (oLocais:oData:cAlias)->ABQ_LOCAL
	aAtendente := atendDados(cLocal, cFuncao, cTurno)
	oAtenden:setArray(@aAtendente)
	oAtenden:Browse():nFreeze := 2
	oAtenden:SetLineHeight(25)
	oAtenden:Refresh()	
return

static function contraArr()
	local aList := {}
	local nI := 0
	For nI := 1 To 50
		Aadd( aList, { LTrim(Str( Randomize(52, 5000) )), "Cliente: "+LTrim(Str(nI))} )
	Next nI

return aClone(aList)

static function locaisArr(cContrato)
	local aList := {}
	local nI := 0
	If !Empty(cContrato)
		for nI := 1 to 10
			aAdd( aList, { LTrim(Str( Randomize(1, 1000) )), "Local: "+LTrim(Str(nI))+"|Contrato:"+cContrato } )
		next nI
	EndIf
return aClone(aList)

static function AtendArr(cContrato,cLocal)
	local aList := {}
	local nI := 0
	If !Empty(cContrato) .AND. !Empty(cLocal)
		for nI := 1 to 10
			aAdd( aList, { LTrim(Str( Randomize(1, 1000) )), "Atendente: "+LTrim(Str(nI))+"|Contrato:"+cContrato+"|Local:"+cLocal, "Funcao "+LTrim(Str(nI)) } )
		next nI 
	EndIf
return aClone(aList)

//funcao que retorna a query de todos os contratos.
static function contratQuery()
	local cQuery := ''
	cQuery := "SELECT DISTINCT TFJ_CODIGO COD, TFJ_CONTRT CONTRATO, CASE WHEN TFJ_ENTIDA='1' THEN A1_NOME ELSE US_NOME END NOME"
	cQuery += " , CN9.CN9_DTINIC INICIO, CN9.CN9_DTFIM FIM "
	cQuery += " FROM " + RETSQLNAME("TFJ") + " TFJ"
	cQuery += " LEFT JOIN " + RETSQLNAME("SA1") + " SA1 "
	cQuery += " ON TFJ_ENTIDA='1' AND A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=TFJ_CODENT AND A1_LOJA=TFJ_LOJA AND SA1.D_E_L_E_T_=' ' "
	cQuery += " LEFT JOIN " + RETSQLNAME("SUS") + " SUS "
	cQuery += " ON TFJ_ENTIDA<>'1' AND US_FILIAL='"+xFilial("SUS")+"' AND US_COD=TFJ_CODENT AND US_LOJA=TFJ_LOJA AND SUS.D_E_L_E_T_=' ' "

	cQuery += " INNER JOIN " + RETSQLNAME("CN9") + " CN9 " 
	cQuery += " ON CN9.CN9_NUMERO = TFJ.TFJ_CONTRT AND CN9.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE TFJ_FILIAL='"+xFilial("TFJ")+"' AND TFJ_STATUS = '1' AND TFJ_CONTRT <> ' ' AND TFJ.D_E_L_E_T_ = ' ' "
	cQuery += " AND CN9.CN9_FILIAL='"+xFilial("CN9")+"' "
	cQuery += " ORDER BY TFJ.TFJ_CONTRT"
return cQuery

//funcao que retorna a query dos locais de atendimento dos contratos
static function locaisQuery(codContrato)
	Local cQuery := ''
	cQuery += "SELECT  ABQ.ABQ_CONTRT, ABQ.ABQ_LOCAL, ABS.ABS_DESCRI , SB1.B1_COD , SB1.B1_DESC, ABQ.ABQ_FUNCAO, SRJ.RJ_DESC, "
	cQuery += " ABQ.ABQ_PERINI, ABQ.ABQ_PERFIM, ABQ.ABQ_TURNO, SR6.R6_DESC, ABQ.ABQ_TOTAL, ABQ.ABQ_FATOR "
	cQuery += " FROM " + RETSQLNAME("ABQ") + " ABQ" 
	cQuery += " LEFT JOIN " + RETSQLNAME("ABS") +" ABS"
	cQuery += " ON ABQ.ABQ_LOCAL = ABS.ABS_LOCAL "
	cQuery += " LEFT JOIN " + RETSQLNAME("SB1") + " SB1"
	cQuery += " ON SB1.B1_COD = ABQ.ABQ_PRODUT "
	cQuery += " LEFT JOIN " + RETSQLNAME("SRJ") + " SRJ"
	cQuery += " ON SRJ.RJ_FUNCAO = ABQ.ABQ_FUNCAO "
	cQuery += " LEFT JOIN " + RETSQLNAME("SR6") + " SR6"
	cQuery += " ON SR6.R6_TURNO = ABQ.ABQ_TURNO "
	cQuery += " WHERE "
	cQuery += " ABQ.ABQ_FILIAL = '"+FWxFilial("ABQ")+"' AND SB1.B1_FILIAL = '"+FWxFilial("SB1")+"' AND "
	cQuery += " ABS.ABS_FILIAL = '"+FWxFilial("ABS")+"' AND SRJ.RJ_FILIAL = '"+FWxFilial("SRJ")+"' AND "
	cQuery += " SR6.R6_FILIAL = '"+FWxFilial("SR6")+"' AND SR6.D_E_L_E_T_ = ' ' AND SRJ.D_E_L_E_T_ = ' ' AND "
	cQuery += " SB1.D_E_L_E_T_ = ' ' AND ABQ.D_E_L_E_T_ = ' ' AND ABS.D_E_L_E_T_ = ' '"
	if Empty(codContrato)
		cQuery += " AND 1 = 2"
	else
	 	cQuery += " AND ABQ.ABQ_CONTRT = '" + codContrato + "' "
	endIf
	cQuery := ChangeQuery(cQuery)
	
return (cQuery) 

//retorna os dados referente as alocacoes dos atendentes. 
static function atendDados(codLocal, codFunc, codTurno)
	local cSql := ''
	Local cQuery
	Local nOffset := 3 //offset para posicao na tabela
	Local aDados := {}

	if Empty(codLocal)
		codLocal := '000000000'
	endIf

	cSql += "SELECT ABB.ABB_CODTEC CODIGO, AA1.AA1_NOMTEC NOME, ABB.ABB_DTINI, ABB.ABB_DTFIM, "
	cSql += " ABB.ABB_HRINI, ABB.ABB_HRFIM, ABQ.ABQ_CONTRT, ABQ.ABQ_CODTFF CODTFF, ABB.ABB_LOCAL LOC, ABQ.ABQ_FUNCAO "
	cSql += " FROM " + RetSqlName('ABB') + " ABB "
	cSql += " JOIN " + RetSqlName('AA1') + " AA1 ON "
	cSql += " AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cSql += " JOIN " + RetSqlName('ABQ') + " ABQ ON  "
	cSql += " ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	cSql += " WHERE "
	//cSql += " WHERE ABQ.ABQ_CODTFF = '" + cCodTFF + "' AND "
	cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
	cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
	cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "'  AND "
	cSql += " ABB.ABB_DTINI >= '" + DTOS(dDataIni) + "' AND "
	cSql += " ABB.ABB_DTFIM <= '" + DTOS(dDataFim) + "' AND "
	cSql += " ABB.ABB_LOCAL = " + codLocal + " AND "
	if !Empty(codFunc)
		cSql += " ABQ.ABQ_FUNCAO = " + codFunc + " AND " 
	endIf
	if !Empty(codTurno)
		cSql += " ABQ.ABQ_TURNO = " + codTurno + " AND"
	endIf
	cSql += " ABB.D_E_L_E_T_ = ' ' AND "		
	cSql += " ABQ.D_E_L_E_T_ = ' ' AND "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
	if Empty(codLocal)
		cSql += " AND 1=2 "
	endIf
	cSql += " ORDER BY ABB.ABB_DTINI "
	cSql := ChangeQuery(cSql)

	nQtdDias	:= dDataFim-dDataIni+1
	aArray := Array(nQtdDias+nOffset-1,"FOLGA") // tamanho qtdias + offset(2) (codigo, nome)
	Alert(cSql) //debug
	
	if !Empty(codLocal)
		MPSysOpenQuery(cSql, "ATENDENTES",{{"ABB_DTINI","D",8,0}})
		while !(ATENDENTES->(EOF()))
			nPos := aScan(aDados,{|x| x[1]==RTRIM(ATENDENTES->CODIGO) })
			If nPos==0
				AADD(aDados,aClone(aArray))
				nPos	:= Len(aDados)
			EndIf
			aDados[nPos][1]	:= RTRIM(ATENDENTES->CODIGO)
			aDados[nPos][2]	:= RTRIM(ATENDENTES->NOME)
			If aDados[nPos][ATENDENTES->ABB_DTINI-dDataIni+nOffset] == "FOLGA"
				aDados[nPos][ATENDENTES->ABB_DTINI-dDataIni+nOffset]	:= ""
			Else
				aDados[nPos][ATENDENTES->ABB_DTINI-dDataIni+nOffset]	+= "|"
			EndIf
			aDados[nPos][ATENDENTES->ABB_DTINI-dDataIni+nOffset] += Substr(ATENDENTES->ABB_HRINI, 1, 2)+'-'+ Substr(ATENDENTES->ABB_HRFIM, 1, 2)
			ATENDENTES->(DBSkip())
		endDo
		ATENDENTES->(DBCloseArea())
		if Len(aDados) == 0 .and. !lFlag
			MsgInfo("Não há nenhuma alocação para o contrato e o local selecionado. ")
		endIf
		
		if lFlag
			lFlag := .F.
		endIf
		//Alert(VarInfo("aDados",aDados,,.F.))
	endIf 

return aClone(aDados)

//funcao para abrir coloca os dados dos locais de atendimento em um array
static function getLocArrFromQuery(codContrato)
	Local aArea := GetArea()
	Local aLocais := {}
	Local cQuery := locaisQuery(codContrato)
	
	MPSysOpenQuery(cQuery, "LOCAIS",{{"ABQ_PERINI","D",8,0}, {"ABQ_PERFIM","D",8,0}})
	while !(LOCAIS->(EOF()))
		aLinha := {}
		aAdd(aLinha, {LOCAIS->ABQ_CONTRT,LOCAIS->ABQ_LOCAL,LOCAIS->ABS_DESCRI,LOCAIS->B1_COD,LOCAIS->B1_DESC,;
						LOCAIS->ABQ_FUNCAO,LOCAIS->RJ_DESC,LOCAIS->ABQ_PERINI,LOCAIS->ABQ_PERFIM,;
						LOCAIS->ABQ_TURNO,LOCAIS->R6_DESC,LOCAIS->ABQ_TOTAL,LOCAIS->ABQ_FATOR})
		aAdd(aLocais, aLinha)
		LOCAIS->(dbSkip())
	endDo
	
	LOCAIS->(dbCloseArea())
	RestArea(aArea)
return aClone(aLocais)

static function getWeekDay(dDate)
	local aDays := {"DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SAB"}
return aDays[DOW(dDate)]