#include "protheus.ch"
#include "fwmvcdef.ch"

User Function TECA740F()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.

	//Local nLinha     := 0
	//Local nQtdLinhas := 0
	//Local cMsg       := ''


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
