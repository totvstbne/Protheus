#include "protheus.ch"
#include "fwmvcdef.ch"

User Function TECA740F()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.

	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )
		If cIdPonto == 'BUTTONBAR'
			xRet := { }
			AADD(xRet, {'Replicar', 'COPIA', {|| Replicar() }, 'Copia a linha atual para outros locais de atendimento.' } )
			AADD(xRet, {'Copiar Cálculo', 'COPIA', {|| Processa({|| Copiar() },"Copiando cálculo" ) }, 'Copia o cálculo posicionado' } )
			AADD(xRet, {'Colar Cálculo', 'COPIA', {|| Processa({|| Colar() },"Colando cálculo" ) }, 'Cola cálculo copiado' } )
			///AADD(xRet, {'Atualizar Dados', 'SALVAR', {|| Processa({|| TecActivt() },"Atualizar dados " ) }, 'Atualiza dados' } )
		ElseIf cIdPonto == 'MODELPRE'
			If cIdModel=="TFJ_REFER"
				aCopiaTab	:= {}
			EndIf
		ElseIf cIdPonto == 'FORMLINEPRE'
			gatilhoData()
		EndIf
	EndIf
Return xRet

Static aCopiaTab	:= {}
Static Function Copiar()
	Local oModel	:= FWModelActive()
	Local oModelRh	:= oModel:GetModel("TFF_RH")
	Local aPrcOrc	:= At740FORC()
	Local oModelPrc
	Local aFields2
	Local nCont
	Local nI

	If !oModelRh:GetValue("TFF_LOADPRC") .And. !oModelRh:IsInserted()
		At740Load(1)	//Clica no botão consultar para carregar os dados
	EndIf
	//COPIA OS DADOS DO PRC
	aCopiaTab	:= {}
	For nI := 1 To Len(aPrcOrc)
		oModelPrc	:= oModel:GetModel(aPrcOrc[nI][3][2])
		aFields2	:= oModelPrc:GetStruct():GetFields()
		For nCont:=1 to Len(aFields2)
							//{Model,Field,Valor}
			AADD(aCopiaTab,{aPrcOrc[nI][3][2],aFields2[nCont][3],oModelPrc:GetValue(aFields2[nCont][3])})
		Next
	Next
Return

Static Function Colar()
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oModelRh	:= oModel:GetModel("TFF_RH")
	Local nLinha	:= oModelRh:GetLine()
	Local nCont
	If Empty(aCopiaTab)
		MsgAlert("Não existe dados copiado!")
		Return
	EndIf
	//If !oModelRh:GetValue("TFF_LOADPRC") .And. !oModelRh:IsInserted()
	//	At740Load(1)	//Clica no botão consultar para carregar os dados
	//EndIf
	oModelRh:GoLine(1)
	If !isBlind() .AND. VALTYPE(oView) == 'O'
		oView:Refresh()
	EndIf
	oModelRh:GoLine(nLinha)	//Força atualização dos calculos
	If !oModelRh:IsInserted()
		oModelRh:LoadValue("TFF_LOADPRC",.T.)
	EndIf
	For nCont:=1 to Len(aCopiaTab)
		oModel:SetValue(aCopiaTab[nCont][1],aCopiaTab[nCont][2],aCopiaTab[nCont][3])
	Next
	StaticCall(TECA740F,At740fcItem)
	MsgInfo("Cálculo colado com sucesso!")
Return
/*/{Protheus.doc} Replicar
Copiar linha do RH para outros locais de atendimento
@type function
@version 1.0
@author Saulo Gomes Martins
@since 19/11/2020
/*/
Static Function Replicar()
	Local oMarkBrow := Nil
	Local oMarkBrow2:= Nil
	Local oModel	:= FWModelActive()
	Local oModelLoc	:= oModel:GetModel("TFL_LOC")
	Local oModelRh	:= oModel:GetModel("TFF_RH")
	Local aLocais	:= {}
	Local nCont     := 1
	Local nTam		:= oModelLoc:Length()
	Local nLocAtu	:= oModelLoc:GetLine()
	Local aSavLoc	:= FWSaveRows()
	Local aProduto	:= {}
	Local lOk		:= .F.

	//Seleciona Produtos
	For nCont := 1 To oModelRh:Length(.F.)
		If !oModelRh:IsDeleted()
			aAdd(aProduto, {.F.,oModelRh:GetValue("TFF_PRODUT", nCont), oModelRh:GetValue("TFF_DESCRI", nCont), nCont})
		EndIf
	Next
	oMarkBrow2	:= YMARKBROW():new()
	oMarkBrow2:cTitulo	:= "Selecione os produtos"
	aAdd(oMarkBrow2:aCampos, {"#","L",1,0})	//Flag, sempre deve ser a primeira opção
	aAdd(oMarkBrow2:aCampos, {"TFF_PRODUT"})
	aAdd(oMarkBrow2:aCampos, {"TFF_DESCRI"})
	oMarkBrow2:aDados := aProduto
	oMarkBrow2:Browse()
	oMarkBrow2:Activate()
	If !oMarkBrow2:lOk
		return
	EndIf

	//Seleciona Locais
	For nCont := 1 to nTam
		If !oModelLoc:IsDeleted()
			AADD(aLocais,{.F.,oModelLoc:GetValue("TFL_LOCAL",nCont),oModelLoc:GetValue("TFL_DESLOC",nCont),nCont})
		EndIf
	Next

	oMarkBrow	:= YMARKBROW():new()
	oMarkBrow:cTitulo	:= "Seleciona os locais"
	AADD(oMarkBrow:aCampos,{"#","L",1,0})	//Flag, sempre deve ser a primeira opção
	AADD(oMarkBrow:aCampos,{"TFL_LOCAL"})
	AADD(oMarkBrow:aCampos,{"TFL_DESLOC"})
	oMarkBrow:aDados	:= aLocais
	oMarkBrow:Browse()
	oMarkBrow:Activate()
	If oMarkBrow:lOk
		ProcRegua(Len(oMarkBrow:aDados))
		For nCont:=1 to Len(oMarkBrow2:aDados)
			If oMarkBrow2:GetCampo("#",nCont)	//Campo Foi Marcado
				oModelLoc:GoLine(nLocAtu)
				oModelRh:GoLine(oMarkBrow2:aDados[nCont][4])
				If !oModelRh:IsDeleted()
					Processa({|| RunProc(oMarkBrow,oModel,oModelLoc,oModelRh)})
				EndIf
			EndIf
			incProc("Registros: "+cValToChar(nCont)+"/"+cValToChar(Len(oMarkBrow2:aDados)))
			ProcessMessage()
		Next
		lOk	:= .T.
	EndIf
	FWRestRows(aSavLoc)
	FreeObj(oMarkBrow)
	FreeObj(oMarkBrow2)
	If lOk
		MsgInfo("Replicado com sucesso!")
	EndIf
Return

Static Function RunProc(oMarkBrow,oModel,oModelLoc,oModelRh)
	Local cExCampos	:= "TFF_FILIAL|TFF_COD|TFF_ITEM|TFF_LOCAL|TFF_PRCVEN|TFF_SUBTOT|TFF_TOTMI|TFF_TOTMC|TFF_TOTAL|TFF_LOADPRC"	//Campos que não devem ser copiados
	Local aPrcOrc	:= At740FORC()
	Local aDados	:= {}
	Local aDadosPrc	:= {}
	Local aFields
	Local aFields2
	Local cProduto	:= oModelRh:GetValue("TFF_PRODUT")
	Local nCont,nCont2
	Local nI
	If !oModelRh:GetValue("TFF_LOADPRC") .And. !oModelRh:IsInserted()
		At740Load(1)	//Clica no botão consultar para carregar os dados
	EndIf
	//COPIA OS DADOS DA CNB
	aFields	:= oModelRh:GetStruct():GetFields()
	For nCont:=1 to Len(aFields)
		AADD(aDados,{aFields[nCont][3],oModelRh:GetValue(aFields[nCont][3])})
	Next
	//COPIA OS DADOS DO PRC
	For nI := 1 To Len(aPrcOrc)
		oModelPrc	:= oModel:GetModel(aPrcOrc[nI][3][2])
		aFields2	:= oModelPrc:GetStruct():GetFields()
		For nCont:=1 to Len(aFields2)
							//{Model,Field,Valor}
			AADD(aDadosPrc,{aPrcOrc[nI][3][2],aFields2[nCont][3],oModelPrc:GetValue(aFields2[nCont][3])})
		Next
	Next

	For nCont:=1 to Len(oMarkBrow:aDados)
		If oMarkBrow:GetCampo("#",nCont)	//Campo Foi Marcado
			oModelLoc:GoLine(oMarkBrow:aDados[nCont][4])
			If !oModelRh:SeekLine({{"TFF_PRODUT",cProduto}},.F.,.T.)	//Se não existe o produto
				nQtdTmp	:= oModelRh:GetQTDLine()
				If !Empty(oModelRh:GetValue("TFF_PRODUT"))
					oModelRh:AddLine()
				EndIf
				For nCont2:=1 to Len(aDados)
					If !(aDados[nCont2][1] $ cExCampos)
						oModelRh:SetValue(aDados[nCont2][1],aDados[nCont2][2])
					EndIf
				Next
			EndIf
			If !oModelRh:GetValue("TFF_LOADPRC") .And. !oModelRh:IsInserted()
				At740Load(1)	//Clica no botão consultar para carregar os dados
			EndIf
			For nCont2:=1 to Len(aDadosPrc)
				oModel:SetValue(aDadosPrc[nCont2][1],aDadosPrc[nCont2][2],aDadosPrc[nCont2][3])
			Next
			StaticCall(TECA740F,At740fcItem)
		EndIf
	Next
Return

/*/{Protheus.doc} gatilhoData
	(Gatilho de data entre TFL e TFF)
@type  Function
@author Mateus da Silva Teixeira
@since 23/12/2020
@version undefined
	/*/
Static Function gatilhoData()
	Local nCount      := 1
	Local oView		  := FWViewActive()
	Local oModel	  := FWModelActive()
	Private aData     := {}
	Private oModelLoc := Nil
	Private oModelRh  := Nil
	
	If ValType(oModel) != "U"
		oModelLoc := oModel:GetModel("TFL_LOC")
		oModelRh  := oModel:GetModel("TFF_RH")	
		If ValType(oModelLoc) != "U" .AND. ValType(oModelLoc) != "U" 
			If verificaData() .AND. oModelRh:GetValue("TFF_PRODUT") != " "
				For nCount := 1 To Len(aData)
					oModelRh:LoadValue(aData[nCount][1], oModelLoc:GetValue(aData[nCount][2]))
					oView:Refresh()
				Next
			EndIf
		EndIf
	EndIf
Return

Static Function verificaData() As Logical
	Local dLocIni := oModelLoc:GetValue("TFL_DTINI")
	Local dLocFim := oModelLoc:GetValue("TFL_DTFIM")
	Local dRhIni  := oModelRh:GetValue("TFF_PERINI")
	Local dRhFim  := oModelRh:GetValue("TFF_PERFIM")

	If dLocIni == CTOD("//") .OR. dLocFim == CTOD("//")
		return .F.
	EndIf
	If dRhIni == CTOD("//") 
		aAdd(aData, {"TFF_PERINI", "TFL_DTINI"})
	EndIf
	If dRhFim == CTOD("//")
		aAdd(aData, {"TFF_PERFIM", "TFL_DTFIM"})
	EndIf
Return .T.


User Function fReplVig() 
	Local oModel	:= FWModelActive()
	Local oModelLoc	:= oModel:GetModel("TFL_LOC")
	Local oModelRh	:= oModel:GetModel("TFF_RH")
	Local oModelTOT	:= oModel:GetModel("RH003")
	Local oModelTL	:= oModel:getModel("TOTAIS")
	Local aParam	:= {}
	Local aRetParm	:= {}
	Local nCont		:= 0
	Local nZ		:= 0
	Local nDiff		:= 0

	If !oModelRh:GetValue("TFF_LOADPRC") .And. !oModelRh:IsInserted()
		At740Load(1)	//Clica no botão consultar para carregar os dados
	EndIf

	For nCont := 1 To oModelLoc:Length()
		oModelLoc:goline(nCont)
		If !oModelLoc:IsDeleted()
			For nZ := 1 To oModelRh:Length()
				oModelRh:goline(nZ)
				If !oModelRh:IsDeleted()
					If !oModelRh:IsInserted()
						oModelRh:LoadValue("TFF_LOADPRC",.T.)
					EndIf
					fProcesCalc('',nZ)
				Endif
			Next
		Endif
	Next
	oModelLoc:goline(1)
Return


Static Function fProcesCalc( nOrigem,nLinAtu )
Local aPrcOrc	:= At740FORC()
Private oMdl740F:= FWModelActive()
Private aFWSheet := {}
If (!oMdl740F:GetValue('TFF_RH',"TFF_LOADPRC") .And. oMdl740F:GetModel('TFF_RH'):IsInserted()) .Or. (oMdl740F:GetValue('TFF_RH',"TFF_LOADPRC") .And. !oMdl740F:GetModel('TFF_RH'):IsInserted())
	// verifica se é item de contrato
	If (oMdl740F:GetValue('TFF_RH','TFF_COBCTR')<>'2' .AND. !(isInCallStack("At870GerOrc")) .OR.;
			(isInCallStack("At870GerOrc")) .AND. oMdl740F:GetValue('TFF_RH','TFF_COBCTR')=='2' )
		If IsBlind()
			x740EEPC(x740FGSS(oMdl740F,nLinAtu),aPrcOrc,oMdl740F, /*aCampos*/, nOrigem )
		Else
			//Processa({|| At740EEPC(x740FGSS(oMdl740F),aPrcOrc,oMdl740F, /*aCampos*/, nOrigem ) },"Processando cálculo", "Aguarde",.F.)  // executa o cálculo quando item de contrato
			Processa({|| x740EEPC(x740FGSS(oMdl740F,nLinAtu),aPrcOrc,oMdl740F, /*aCampos*/, nOrigem ) },"Processando cálculo", "Aguarde",.F.)  // executa o cálculo quando item de contrato
			oViw740F:= FWViewActive()
			If ValType(oViw740F) == "O"
				oViw740F:Refresh()
			EndIf
		EndIf
	Else
		If oMdl740F:GetValue('TFF_RH','TFF_COBCTR') == '2' .AND. !(isInCallStack("At870GerOrc"))
			Help(,, "CpCalCOBCTR2",,"STR0088",1,0,,,,,,{"STR0089"}) //"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)"
		ElseIf oMdl740F:GetValue('TFF_RH','TFF_COBCTR') <> '2' .AND. isInCallStack("At870GerOrc")
			Help(,, "CpCalCOBCTR1",,"STR0090",1,0,,,,,,{"STR0091"}) //"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf
	EndIf
Else
	Help(,, "At740fcItem",,"Valores da tabela de preço não foram carregadas",1,0,,,,,,{"Clique em consultar para o carregamento dos valores da tabela de preço"})//"Valores da tabela de preço não foram carregadas"##"Clique em consultar para o carregamento dos valores da tabela de preço"
EndIf	
Return


Static Function x740FGSS(oMdlGer,nLinAtu,cAtuXML)
Local uRet		:= Nil
Local oMdlLoc	:= oMdlGer:GetModel("TFL_LOC")
Local oMdlRh	:= oMdlGer:GetModel("TFF_RH")
Local oMdlTFJ	:= oMdlGer:GetModel('TFJ_REFER')
Local aTabRev	:= At600GetTab()
Local lInit		:= isInCallStack("initdados")
Local lTFFXML	:= TFF->( ColumnPos('TFF_TABXML') ) > 0
Local lInsert	:=  oMdlGer:getOperation() == MODEL_OPERATION_INSERT
Local lUpdt	:=  oMdlGer:getOperation() == MODEL_OPERATION_UPDATE
Local nX
Local nBkpLine
Local nLinRH := oMdlRh:GetLine()
Local nPosSht := 0
Local cXMLPrc := ''
Local _fwTFF := 1	// Chave dos Recursos Contidos no Local de Atendimento
Local _fwOBJ :=	2	// Objerto FWSheet - Para precificação de Recursos e Impostos
Local _fwDEL := 3
Default cAtuXML	:= ''

If ((lInit .AND. (!lInsert .OR. lUpdt)) .OR. (lInsert .AND. !lInit) .OR. (lUpdt .AND. !lInit )) .OR.;
		(IsInCallStack("At270Orc") .AND. lInit)
	If !Empty(cAtuXML)
		nPosSht := oMdlLoc:GetLine()
		While Len(aFWSheet[nPosSht][2])    <= nLinRH
			// Adicina uma nova estrutura representando um recurso para o local atual
			AAdd(aFWSheet[nPosSht][2], {nil,nil,.T.})
		End		
		aFWSheet[oMdlLoc:GetLine()][2][nLinRH][_fwOBJ]:LoadXmlModel(cAtuXML)
		// Grava o código do Recurso
		aFWSheet[oMdlLoc:GetLine()][2][nLinRH][_fwTFF] := oMdlRh:GetValue('TFF_COD')
	Else
	// Verifica se o objeto de planilhas tem o mesmo numero de itens dos Recursos Humanos
			nPosSht  := Ascan(aFWSheet,{|x| x[1] == oMdlLoc:GetValue('TFL_CODIGO') })
	         If nPosSht  = 0
				AAdd(aFWSheet, {oMdlLoc:GetValue('TFL_CODIGO'),{},.T.})
				nPosSht := len(aFWSheet)
			EndIf
			While Len(aFWSheet[nPosSht][2]) <= oMdlRh:Length()
						// Adicina uma nova estrutura representando um recurso para o local atual
				AAdd(aFWSheet[nPosSht][2], {nil,nil,.T.})
			End
			//Esta condição verifica os valores do XML da tabela de precificação salvos no BD e carrega-os na var aFWSheet.
			//Isso significa que toda a operação de VISUALIZAÇÃO, ALTERAÇÃO ou EXCLUSÃO precisam passar por aqui
			//	(pois entende-se que, nessas operações, existe um valor de XML já salvo no BD)
			//A função TecActivt é utilizada para evitar o uso de variaveis STATIC
			//Esta condição DEVE FALHAR após o ACTIVATE do modelo (em outras palavras, ela só deve ser executada no momento da ativação do modelo)
			//lInit:= .T.
			If .T.
				nBkpLine := oMdlRh:GetLine()
					oMdlRh:GoLine(nLinAtu)
					If lTFFXML
						cXMLPrc := oMdlRh:GetValue('TFF_TABXML')
					Else
						cXMLPrc := At740FDXML(oMdlTFJ:GetValue('TFJ_TABXML'),aFWSheet[oMdlLoc:GetLine()][1],oMdlRh:GetValue('TFF_COD'))
					EndIf
					aFWSheet[nPosSht][2][oMdlRh:GetLine()][_fwOBJ] := FWUIWorkSheet():New(,.F. )
					aFWSheet[nPosSht][2][oMdlRh:GetLine()][_fwOBJ]:LoadXmlModel(cXMLPrc)
				//Next nX
				oMdlRh:GoLine(nBkpLine)
			Else
			  If aFWSheet[nPosSht][2][nLinRH][_fwOBJ] == Nil
				 // Carrega um arquivo XML relativo à Tabela e Revisão - conteúdo padrão sem preenchimento
				 If Empty(cXMLPrc)
					cXMLPrc := At740ELTP(aTabRev[1], aTabRev[2])
				 EndIf

				aFWSheet[nPosSht][2][nLinRH][_fwOBJ]:= FWUIWorkSheet():New(,.F. )

				aFWSheet[nPosSht][2][nLinRH][_fwOBJ]:LoadXmlModel(cXMLPrc)
			  EndIf
			// Grava o código do Recurso
			aFWSheet[nPosSht][2][nLinRH][_fwTFF] := oMdlRh:GetValue('TFF_COD')
		  EndIf
	EndIf
	// Retorna uma referencia ao Objeto relativo às posições Local X RH
	uRet := aFWSheet[nPosSht][2][nLinRH][_fwOBJ]
EndIf

Return uRet



Static Function x740EEPC(oFWSheet,aPrcTab,oMdlPrc,aCampos, nOrigem)
Local cRet			:= ''
Local nI			:= 0
Local nJ			:= 0
Local oDataSrc		:= nil
Local cCampo		:= ""
Local cMensagem		:= ''
Local lOperation	:= (oMdlPrc:GetOperation() == MODEL_OPERATION_UPDATE) .or. (oMdlPrc:GetOperation() == MODEL_OPERATION_INSERT)
Local oModel		:= oMdlPrc:GetModel()
Local oModRH		:= oModel:GetModel('TFF_RH')
Local lNProces		:= .T.
Local lCpoProc 		:= oModRH:HasField('TFF_PROCES')
Local nVal 			:= 0
Local nPosAbaImposto := 0
Local lOFwSheet 	:= .F.
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local nAbtInss		:= 0
Local nY			:=1
Default aCampos		:= {}
Default nOrigem 	:= 1

If lCpoProc
	lNProces := !oModRH:GetValue('TFF_PROCES')
Else
	lNProces :=  .T.
EndIf

If !Empty(oFWSheet)
	lOFwSheet := .T.
	
	nVal := oFWSheet:GetCellValue("TOTAL_RH")
	If ValType(nVal) == "C"
		nVal := Val(nVal)
	EndIf
	
	// Obter o valor da cálcula TOTAL_ABATE_INS apenas se o campo TFF_ABTINS existir e o contrato for desagrupado
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		nAbtInss := oFWSheet:GetCellValue("TOTAL_ABATE_INS")
		If ValType(nAbtInss) == "C"
			nAbtInss := Val(nAbtInss)
		EndIf
	EndIf
	//Verifica tabela de preço e se ela desativou a verificação circular
	If TV6->(DbSeek(xFilial('TV6')+oModel:GetValue('TFJ_REFER','TFJ_CODTAB')+oModel:GetValue('TFJ_REFER','TFJ_TABREV') ))
		If (TV6->(ColumnPos('TV6_NCIRC')) > 0) .and. TV6->TV6_NCIRC == '1' .And. ASCAN(ClassMethArr(oFWSheet), {|x| UPPER(x[1]) == "SETEVALREFERENCE"}) > 0
			oFWSheet:SetEvalReference(.F.)
		EndIf
	EndIf
EndIf

//   Executa caso tenha ocorrido alteração na formação do preço da planilha
// ou esteja na gravação da Proposta Comercial com o modelo escondido
If lOperation .And. lOFwSheet .And. At740GSC() .And. ;
	!Empty(oMdlPrc) .And. !Empty(aPrcTab) .And. ;
	( lNProces .Or. nOrigem == 2 .Or. nVal == 0 .OR.;
		(((oModRH:GetValue('TFF_COBCTR') <> '2' .AND. !(isInCallStack("At870GerOrc"))) .OR.;
		(oModRH:GetValue('TFF_COBCTR') == '2' .AND. isInCallStack("At870GerOrc"))) .AND. oModRH:GetValue("TFF_PRCVEN") <> nVal))

	ProcRegua(0)
	aPrcOrc:= At740FORC()
	// Pega o valor dos campos de todas em Abas do Modelo
	For nI := 1 To Len(aPrcTab)
		IncProc()

		// O objeto Model da Aba correspondente
		oDataSrc := oMdlPrc:GetModel(aPrcTab[nI][3][2])
		// identifica a aba de imposto para executar depois
		If !Empty( AllTrim( aPrcTab[nI][1] ) )
			// Atribui o valor de cada campo da aba atual ao objeto de calculo
			For nJ := 1 To Len(aPrcTab[nI][2])
				IncProc()
				///x740eProc( aPrcTab, nI, nJ, oFWSheet, oMdlPrc, oModRH, oDataSrc, aCampos )
			Next nJ
		Else
			nPosAbaImposto := nI
		EndIf

		If lCpoProc
			oModRH:LoadValue('TFF_PROCES',.T.)
		EndIf
	Next

	nVal := oFWSheet:GetCellValue("TOTAL_RH")
	If ValType(nVal) <> "N"
		nVal := Val( nVal )
	EndIf
	nVal := Round( nVal, TamSX3("TFF_PRCVEN")[2])
 	If !(oModRH:SetValue('TFF_PRCVEN', nVal))
		If oModel:HasErrorMessage()
			AtErroMvc( oModel )
			If !(isBlind())
				MostraErro()
			EndIf
		EndIf
	EndIf
	
	// Validação para incluir o valor de abatimento do INSS apenas se o campo TFF_ABTINS existir e o contrato for desagrupado
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		nAbtInss := oFWSheet:GetCellValue("TOTAL_ABATE_INS")
		If ValType(nAbtInss) <> "N"
			nAbtInss := Val( nAbtInss )
		EndIf
		If !(oModRH:SetValue('TFF_ABTINS', nAbtInss))
			If oModel:HasErrorMessage()
				AtErroMvc( oModel )
				If !(isBlind())
					MostraErro()
				EndIf
			EndIf
		EndIf
	EndIf
	// Executa o preenchimento dos campos da aba de imposto
	If nPosAbaImposto > 0
		nI := nPosAbaImposto
		// O objeto Model da Aba correspondente
		oDataSrc := oMdlPrc:GetModel(aPrcTab[nI][3][2])
		For nJ := 1 To Len(aPrcTab[nI][2])
			///x740eProc( aPrcTab, nI, nJ, oFWSheet, oMdlPrc, oModRH, oDataSrc, aCampos )
		Next
	EndIf
	oFWSheet:Refresh()

	nCont:= 1
	For nI := 1 To Len(aPrcOrc)
		oModelPrc	:= oModel:GetModel(aPrcOrc[nI][3][2])
		aFields2	:= oModelPrc:GetStruct():GetFields()
		For nY:=1 to Len(aFields2)

			cQuery:="SELECT TV7_DESC FROM "+retSqlName("TV7")+" TV7 "
			cQuery+="INNER JOIN "+retSqlName("TV6")+" TV6 "
			cQuery+="ON TV6_FILIAL = TV7_FILIAL AND "
			cQuery+="TV6_CODIGO = TV7_CODTAB  "
			cQuery+="WHERE TV6.D_E_L_E_T_= ' ' AND "
			cQuery+="TV7.D_E_L_E_T_= ' ' AND "
			cQuery+="TV6_NUMERO = '"+OMODEL:GetModel('TFJ_REFER'):GETVALUE("TFJ_CODTAB")+"' AND "
			cQuery+="TV7_TITULO = '"+alltrim(aFields2[ny][1])+"' "
			cAlias:= MpSysOpenQuery(cQuery)
			If (cAlias)->(eof())
				(cAlias)->(dbCloseArea())
				loop
			Else
				nPos:= Ascan(oFwSheet:acells,{|x| alltrim(x[2]) == alltrim((cAlias)->TV7_DESC) })
				If nPos > 0 //Localizou
					nCont:= nPos
				Else
					(cAlias)->(dbCloseArea())
					loop
				Endif
			endif
			(cAlias)->(dbCloseArea())

			If valtype(oModelPrc:getValue(aFields2[ny][3])) == "C"
			oModelPrc:SetValue(aFields2[ny][3],alltrim(oFWSheet:ACELLS[nCont][3]))
			Elseif valtype(oModelPrc:getValue(aFields2[ny][3])) == "N"
				oModelPrc:SetValue(aFields2[ny][3],val(strtran(strtran(oFWSheet:ACELLS[nCont][3],".",""),",",".")))
			Endif
		Next
	Next

	// atualiza os itens com fórmulas
	For nI := 1 To Len(aPrcTab)
		IncProc()
		// O objeto Model da Aba correspondente
		oDataSrc := oMdlPrc:GetModel(aPrcTab[nI][3][2])

		For nJ := 1 To Len(aPrcTab[nI][6])
			cCampo := AllTrim(aPrcTab[nI][6][nJ][1])
			If cCampo == "TOT_VIMP"
				oDataSrc:SetValue(cCampo, oFWSheet:GetCellValue(cCampo))
			Else
				oDataSrc:LoadValue(cCampo, oFWSheet:GetCellValue(cCampo))
			EndIf
		Next
	Next


	// Extrai a estrutura no formato XML para retorno desta função.
	cRet := oFWSheet:GetXMLModel(,,,,.F.,.T.,.F.)

EndIf
Return(cRet)

Static Function TecActivt()
	oModel	:= FWModelActive()
	u_fReplVig()
Return 


Static Function x740eProc( aPrcTab, nI, nJ, oFWSheet, oMdlPrc, oModRH, oDataSrc, aCampos )
Local cCampo := ""
Local nVal := 0
Local lContinua := .T.

cCampo := AllTrim(aPrcTab[nI][2][nJ][2])
// Filtro para trabalhar Campos especificos
If !Empty(aCampos) .and. (AScan(aCampos,{|e| AllTrim(e) == cCampo}) == 0)
	lContinua := .F.
EndIf

If lContinua
	// Se for um campo com fórmula o seu valor será calculado, portanto, não informar valor algum.
	If !Empty(aPrcTab[nI][2][nJ][9])

		If At( 'U_', aPrcTab[nI][2][nJ][9] ) > 0 .Or. (TV6->(ColumnPos('TV6_NCIRC')) > 0 .And.;
					(ASCAN(ClassDataArr(oFWSheet), {|x| UPPER(x[1]) == "LEVALREFERENCE"}) > 0 .AND. !(oFWSheet:lEvalReference)))
			// quando a fórmula possuir função de usuário realiza a reatribuição na planilha
			oFWSheet:SetCellValue(cCampo, aPrcTab[nI][2][nJ][9])
		EndIf
	// caso tenha inicializador e seja com id
	ElseIf !Empty(aPrcTab[nI][2][nJ][8]) .And. ;
		AtIsCalcId( Alltrim( aPrcTab[nI][2][nJ][8] ) )
		// busca o valor conforme o id de somatória
		nVal := AtCalcIdent( Alltrim( aPrcTab[nI][2][nJ][8] ), oMdlPrc )
		oFWSheet:SetCellValue(cCampo, nVal)
		// atualiza a interface/modelo exibido
		oDataSrc:LoadValue(cCampo, nVal)
	Else
		// Deixa a atribuição somente em caso de alteração pela estrutura interna do framework
		oFWSheet:SetCellValue(cCampo, oDataSrc:GetValue(cCampo))
	EndIf

EndIf

Return
