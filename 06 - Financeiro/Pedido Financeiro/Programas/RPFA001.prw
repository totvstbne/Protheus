#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RPFA001
Tela de inclusão do Pedido Financeiro
@author Diogo
@since 17/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA001()
	Local oBrowse		:= Nil
	Local cFiltro		:= "1=1"
	Private aRotina		:= MenuDef()
	Private cCadastro	:= "Pedido Financeiro"
	Private cCodUse		:= RetCodUsr()

	// |->TECLA DE AÇÃO  |->FUNÇÃO CHAMADA
	//SetKey(VK_F12, {|| EpaPerg()})

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA7")

	oVisao := FWDSView():New()
	oVisao:SetID("RPFA001")
	oVisao:SetOrder(1)
	oVisao:SetPublic(.T.)

	oBrowse:SetViewsDefault({oVisao})
	oBrowse:SetAttach(.T.)

	If !(upper(alltrim(cUserName)) $ upper(Alltrim(SuperGetMv("TC_USUAPF",,"administrador"))))
		cFiltro := "ZA7_CODUSE = '" + cCodUse +"' "
	endif

	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:SetDescription(cCadastro)
	oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZA7_STATUS == 'P' ", "YELLOW","Pendente de Aprovação")
	oBrowse:AddLegend( "ZA7_STATUS == 'A' ", "GREEN", "Aprovado")
	oBrowse:AddLegend( "ZA7_STATUS == 'R' ", "BLACK", "Rejeitado")

	oBrowse:Activate()
return

Static Function EpaPerg()

	// Chamada do grupo de perguntas customizado
	If Pergunte("FIN050",.T.)
		Return .T.
	Else
		Return .F.
	EndIf
	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} LEGEND para a opção em outras ações
	/*/
//-------------------------------------------------------------------
User Function LEGEN()

	Local aLegenda := {}
	aAdd( aLegenda, { "BR_VERDE"    ,      "Aprovado" })
	aAdd( aLegenda, { "BR_AMARELO"  ,      "Pendente de Aprovação" })
	aAdd( aLegenda, { "BR_PRETO"    ,      "Rejeitado" })

	BrwLegenda( cCadastro, "Legendas", aLegenda )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	Local aRAprov	:= {}
	Local aRRateios	:= {}

	ADD OPTION aRotina TITLE 	"Pesquisar"				ACTION "PesqBrw"			OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 	"Visualizar"			ACTION "VIEWDEF.RPFA001"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 	"Incluir"				ACTION "VIEWDEF.RPFA001"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 	"Alterar"				ACTION "VIEWDEF.RPFA001"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 	"Excluir"				ACTION "VIEWDEF.RPFA001"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 	"Imprimir"				ACTION "VIEWDEF.RPFA001"	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 	"Relatório Pedido"		ACTION "u_RPFR001()"	OPERATION 8 ACCESS 0

	ADD OPTION aRotina TITLE 	"Aprovação"				ACTION aRAprov				OPERATION 8 ACCESS 0
	//ADD OPTION aRAprov TITLE 	"Aprovar"				ACTION "mata094"			OPERATION 8 ACCESS 0
	ADD OPTION aRAprov TITLE 	"Consulta Aprovação"	ACTION "u_fConsApv"			OPERATION 8 ACCESS 0
	ADD OPTION aRAprov TITLE 	"Histórico Aprovação"	ACTION "u_fHist01A"			OPERATION 8 ACCESS 0
	ADD OPTION aRAprov TITLE 	"Estornar Aprovação"	ACTION "u_fEst01A"			OPERATION 8 ACCESS 0

	ADD OPTION aRotina TITLE 	"Consulta Rateios"		ACTION aRRateios			OPERATION 8 ACCESS 0
	ADD OPTION aRRateios TITLE 	"Multinatureza"			ACTION "u_fMultN01A"		OPERATION 8 ACCESS 0
	ADD OPTION aRRateios TITLE 	"Centro de Custo" 		ACTION "u_fCCR01A"			OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 	"Anexar Documento" 		Action "MSDOCUMENT" 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 	"Legendas" 				ACTION "U_LEGEN()" 			OPERATION 9 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruct	:= Nil
	Local oModel	:= Nil

	oStruct := FWFormStruct(1,"ZA7", {|cCampo|  !(AllTrim(cCampo)+"|" $ "ZA7_MSBLQL|")} )

	oStruct:AddTrigger( ;
	"ZA7_TIPOPF"			,;							//[01] Id do campo de origem
	"ZA7_GPRAPV"			,;							//[02] Id do campo de destino
	{ |oModel,cId,xValue,nLinha| .T.  }	,;				//[03] Bloco de codigo de validação da execução do gatilho
	{ |oModel|  fGetGrupoAp()  }  )						//[04] Bloco de codigo de execução do gatilho

	oModel := MPFormModel():New("YZA7001",/*Pre-Validacao*/,{|oModel| fvalidForm(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("CADZA7", Nil/*cOwner*/, oStruct ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey({"ZA7_FILIAL","ZA7_CODIGO"})
	oModel:SetVldActivate({|oModel| fPreValForm(oModel)}) //Validação no carregamento
	oModel:SetActivate({|oModel|fLoadForm(oModel)}) //Carregamento do status
	oModel:SetCommit({|oModel| ZA7Commit(oModel) },.F.)

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruct		:= FWFormStruct(2,"ZA7", {|cCampo|  !(AllTrim(cCampo)+"|" $ "ZA7_MSBLQL|")} )
	Local oModel		:= FWLoadModel('RPFA001')
	Local oView

	oStruct:RemoveField("ZA7_STATUS")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "CADZA7",oStruct)
	oView:CreateHorizontalBox("CABEC",100)
	oView:SetOwnerView( "CADZA7","CABEC")
	oView:EnableControlBar(.T.)

	oView:AddUserButton( "Consulta Aprovação(F7)" , 'BMPORD1' ,{||u_fConsApv()},,;
		VK_F7,{MODEL_OPERATION_VIEW} )

	oView:AddUserButton( "Rateio Centro Custo(F8)" , 'BMPORD1' ,{||u_fCCR01A()},,;
		VK_F8,{MODEL_OPERATION_VIEW} )

	oView:AddUserButton( "Rateio Multinaturezas(F9)" , 'BMPORD1' ,{||u_fMultN01A()},,;
		VK_F9,{MODEL_OPERATION_VIEW} )

Return oView

Static Function fvalidForm(oModel)
	Local lRet := .T.
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If alltrim(oModel:GetValue("CADZA7","ZA7_TIPO")) == "PA" .and. ;
		  (empty(oModel:GetValue("CADZA7","ZA7_CHQADT")) .or.;
		   empty(oModel:GetValue("CADZA7","ZA7_MOVCHQ")))
			oModel:SetErrorMessage('CADZA7','ZA7_TIPO',,,"ATENÇÃO",;
			'Para tipo PA necessário informar os campos: Cheque Adiantamento e Mov. Sem Cheque',)
			Return .F.
		Endif
		
		If oModel:GetValue("CADZA7","ZA7_MULTNA")=="N" .and. empty(oModel:GetValue("CADZA7","ZA7_NATURE"))
			oModel:SetErrorMessage('CADZA7','ZA7_NATURE',,,"ATENÇÃO",;
			'Natureza obrigatória quando o título for classificado como não multinatureza',"Informe a natureza financeira!" )
			Return .F.
		EndIf

		If oModel:GetValue("CADZA7","ZA7_VENCRE") < oModel:GetValue("CADZA7","ZA7_EMISSA")
			oModel:SetErrorMessage('CADZA7','ZA7_VENCRE',,,"ATENÇÃO",;
			'Emissão superior ao vencimento do título',"Verifique o vencimento informado" )
			Return .F.
		Endif

	Endif

Return lRet

Static Function fPreValForm(oModel)
	Local lRet := .F.
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		If ZA7->ZA7_STATUS <> 'P'
			oModel:SetErrorMessage('CADZA7','',,,"ATENÇÃO",;
				'Somente pedidos financeiros com status pendentes poderão ser modificados', "Verifique o status" )
			Return .F.
		Endif
		
		//Verifica se já teve aprovação de algum aprovador para o pedido
		cQuery := "SELECT CR_USER FROM " + RetSqlName("SCR") + " SCR "
		cQuery += " JOIN " + RetSqlName("SAL") + " SAL ON CR_FILIAL = AL_FILIAL AND CR_GRUPO = AL_COD AND  CR_APROV = AL_APROV "
		cQuery += "WHERE SCR.D_E_L_E_T_ = ' ' AND "
		cQuery += "SAL.D_E_L_E_T_ = ' ' AND "
		cQuery += "CR_FILIAL = '" + xFilial("SCR") + "' AND  "
		cQuery += "CR_NUM = '" + ZA7->(ZA7_NUM + ZA7_PARCEL) + "' AND  "
		cQuery += "CR_TIPO = 'PF' AND "
		cQuery += "CR_STATUS = '03' " //Já aprovado
//		cQuery += "CR_STATUS = '03' AND " //Já aprovado
//		cQuery += "AL_LIBAPR<>'V' " //Não seja visto
		
		tcQuery cQuery new Alias QRSCR1
		
		If QRSCR1->(!Eof())
			QRSCR1->(dbCloseArea())
			oModel:SetErrorMessage('CADZA7','',,,"ATENÇÃO",;
				'Pedido financeiro não poderá ser alterado/excluído por já ter sido aprovado em um dos níveis da alçada',;
				'Verifique a aprovação da alçada')
			Return .F.
		Endif
		
		QRSCR1->(dbCloseArea())
	Endif
Return .T.

Static Function fLoadForm(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:setValue("CADZA7","ZA7_STATUS","P")
	Endif
Return

/*/{Protheus.doc} fHist01A
Historico de Aprovações
@author Diogo
@since 18/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fHist01A
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Local oMark1	:= nil
	Local oDlg1		:= nil
	Local cNumPed	:= space(TamSx3("C5_NUM")[1])
	Local aRetOpc 	:= {}
	Local aPergs	:= {}
	Local cFiltro	:= ""

	aAdd( aPergs, { 1 ,"Titulo de" 	   , space(TamSx3("ZA7_NUM")[1]),"@!",'.T.',''		,'.T.',40,.F. })
	aAdd( aPergs, { 1 ,"Titulo ate"    , space(TamSx3("ZA7_NUM")[1]),"@!",'.T.',''		,'.T.',40,.T. })
	aAdd( aPergs, { 1 ,"Fornecedor de" , space(TamSx3("A2_COD")[1])	,"@!",'.T.','SA2'	,'.T.',40,.F. })
	aAdd( aPergs, { 1 ,"Fornecedor ate", space(TamSx3("A2_COD")[1])	,"@!",'.T.','SA2'	,'.T.',40,.T. })
	aAdd( aPergs, { 1 ,"Liberação de " , ctod("")					,"@!",'.T.',''		,'.T.',40,.F. })
	aAdd( aPergs, { 1 ,"Liberação até ", ctod("")					,"@!",'.T.',''		,'.T.',40,.F. })
	aAdd( aPergs, { 1 ,"Rejeição de "  , ctod("")					,"@!",'.T.',''		,'.T.',40,.F. })
	aAdd( aPergs, { 1 ,"Rejeição até " , ctod("")					,"@!",'.T.',''		,'.T.',40,.F. })

	If !(ParamBox(aPergs,"Consulta aprovações",aRetOpc,,,,,,,"_RFPA01A",.T.,.T.))
		Return
	Else
		If !empty(aRetOpc[1])
			cFiltro += "ZA7_NUM >= '" + aRetOpc[1] + "'"
		Endif
		If !empty(aRetOpc[2])
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "ZA7_NUM <= '" + aRetOpc[2] + "'"
		Endif
		If !empty(aRetOpc[3])
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "ZA7_FORNEC >= '" + aRetOpc[3] + "'"
		Endif
		If !empty(aRetOpc[4])
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "ZA7_FORNEC <= '" + aRetOpc[4] + "'"
		Endif
		If !empty(dTos(aRetOpc[5]))
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "(DTOS(ZA7_DTLIB) >= '" + dtos(aRetOpc[5]) + "' .OR. DTOS(ZA7_DTLIB) =' ')"
		Endif
		If !empty(dTos(aRetOpc[6]))
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "(DTOS(ZA7_DTLIB) <= '" + dtos(aRetOpc[6]) + "' .OR. DTOS(ZA7_DTLIB) =' ')"
		Endif
		If !empty(dTos(aRetOpc[7]))
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "(DTOS(ZA7_DTREJ) >= '" + dtos(aRetOpc[7]) + "' .OR. DTOS(ZA7_DTREJ)=' ')"
		Endif
		If !empty(dTos(aRetOpc[8]))
			If !empty(cFiltro)
				cFiltro += " .AND. "
			Endif
			cFiltro += "(DTOS(ZA7_DTREJ) <= '" + dtos(aRetOpc[8]) + "' .OR. DTOS(ZA7_DTREJ)=' ')"
		Endif
	Endif

	oDlg1 := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],'Histórico de Aprovações',,,.F.,,,,,,.T.,,,.T. )
	aRotina := {{"Visualizar","u_fVisuPF()",0,2}}
	oMark1 := FWMarkBrowse():New()
	oMark1:SetAlias('ZA7')
	cFiltro += " .AND. ZA7_STATUS $ 'A/R' "
	oMark1:DisableDetails()
	oMark1:SetDescription('Histórico de Aprovações')
	oMark1:SetFilterDefault(cFiltro)
	oMark1:SetUseFilter(.T.)
	oMark1:AddLegend( "ZA7_STATUS == 'A' ", "GREEN", "Aprovado")
	oMark1:AddLegend( "ZA7_STATUS == 'R' ", "BLACK", "Rejeitado")
	oMark1:Activate(oDlg1)
	oDlg1:Activate(,,,.T.)
Return

/*/{Protheus.doc} function_method_class_name
Commit do Pedido Financeiro
@author author
@since 18/12/2018
@version version
@example
(examples)
@see (links_or_references)
/*/
Static Function ZA7Commit(oModel)
	Local cUpdte := ""
	Local cQZA7	 := ""
	Local cQZA8	 := ""
	Local aArea  := getArea()
	Local lDesdbr := .F.
	Local nValBkp := 0	

	Begin Transaction
		
		If oModel:GetOperation() = MODEL_OPERATION_UPDATE //Alteração: consulta valor anterior
			cQuery:= "SELECT ZA7_VALOR FROM "+RetSqlName("ZA7")+" ZA7 "
			cQuery+= "WHERE ZA7.D_E_L_E_T_ = ' ' AND "
			cQuery+= "ZA7_FILIAL = '"+xFilial("ZA7")+"' AND "
			cQuery+= "ZA7_NUM = '"+ZA7->ZA7_NUM+"' AND "
			cQuery+= "ZA7_PARCEL = '"+ZA7->ZA7_PARCEL+"' "
			tcQuery cQuery new Alias QRVAL
			nValBkp := QRVAL->ZA7_VALOR
			QRVAL->(dbCloseArea())
		Endif
		FWFormCommit(oModel)
		
		If (oModel:GetOperation() = MODEL_OPERATION_INSERT .or. oModel:GetOperation() = MODEL_OPERATION_UPDATE)
			Reclock("ZA7",.F.)
				ZA7->ZA7_DESPFX := Posicione("SED",1,xFilial("SED")+ZA7->ZA7_NATURE,"ED_YDESPFX") //Grava se é despesa fixa
			MsUnlock()
		Endif

		If ZA7->ZA7_TIPO = 'PA'
			fGrvPA()
		Endif
		
		If oModel:GetOperation() = MODEL_OPERATION_UPDATE .and. ; //Alteração
			nValBkp <> ZA7->ZA7_VALOR .and. ; //Identificado mudança de valores
			ZA7->ZA7_MULTNA = 'S' //Multinatureza
			fSetMultNat()//Refaz o cálculo conforme valor novo
		Endif

		// Chamada da tela de multinatureza
		If ZA7->ZA7_MULTNA == "S" .and. ;
		(oModel:GetOperation() = MODEL_OPERATION_INSERT .or. oModel:GetOperation() = MODEL_OPERATION_UPDATE)

			cQZA8 := "SELECT TOP 1 R_E_C_N_O_ RECNO FROM " + RetSqlName("ZA8") + " ZA8 "
			cQZA8 += "WHERE D_E_L_E_T_ = ' ' AND "
			cQZA8 += "ZA8_FILIAL = '" + xFilial("ZA8") +"' AND "
			cQZA8 += "ZA8_PREFIX = '" + ZA7->ZA7_PREFIX + "' AND "
			cQZA8 += "ZA8_NUM= '" + ZA7->ZA7_NUM + "' AND "
			cQZA8 += "ZA8_PARCEL = '" + ZA7->ZA7_PARCEL + "' AND "
			cQZA8 += "ZA8_CLIFOR = '" + ZA7->ZA7_FORNEC + "' AND "
			cQZA8 += "ZA8_LOJA = '" + ZA7->ZA7_LOJA + "'  "
			TcQuery cQZA8 new Alias QZA8

			If QZA8->(!eof())
				dbSelectArea("ZA8")
				ZA8->(dbGoto(QZA8->RECNO))
			Else
				Reclock("ZA8",.T.)
				ZA8->ZA8_FILIAL := xFilial("ZA8")
				ZA8->ZA8_PREFIX	:= ZA7->ZA7_PREFIX
				ZA8->ZA8_NUM   	:= ZA7->ZA7_NUM
				ZA8->ZA8_PARCEL	:= ZA7->ZA7_PARCEL
				ZA8->ZA8_CLIFOR	:= ZA7->ZA7_FORNEC
				ZA8->ZA8_LOJA  	:= ZA7->ZA7_LOJA
				ZA8->ZA8_TIPO  	:= ZA7->ZA7_TIPO
				ZA8->ZA8_VALOR 	:= ZA7->ZA7_VALOR
				ZA8->ZA8_RECPAG	:= "P"
				ZA8->ZA8_RATEIC	:= "2"
				ZA8->ZA8_PERC	:= 100
				ZA8->ZA8_VALNAT	:= ZA7->ZA7_VALOR
				MsUnlock()
			Endif

			QZA8->(dbCloseArea())
			dbSelectArea("ZA8")
			nRet := FWExecView("Rateio MultiNatureza", "RPFA003", MODEL_OPERATION_UPDATE,,{||.T.},,,,)

			If cvaltochar(nRet) == "1" //Cancelado
				Reclock("ZA7",.F.)
				ZA7->ZA7_MULTNA := "N"
				MsUnlock()

				TcQuery cQZA8 new Alias QZA8
				ZA8->(dbGoto(QZA8->RECNO))
				Reclock("ZA8",.F.)
				ZA8->(dbDelete())
				MsUnlock()
				QZA8->(dbCloseArea())
			Endif
		Endif

		If ZA7->ZA7_TIPO = 'PA' 
			Reclock("ZA7",.F.)
				ZA7->ZA7_DESDOB := "N"
			MsUnlock()
		Endif

		If ( ZA7->ZA7_TIPO != 'PA' .AND. ZA7->ZA7_DESDOB == "S" ) .and. ; 
			oModel:GetOperation() == MODEL_OPERATION_INSERT
			fDesdobr(oModel:GetOperation(), oModel)
			lDesdbr := .T.
		ElseIf ( ZA7->ZA7_TIPO == 'PA' .AND. ZA7->ZA7_DESDOB == "S" )
			msgAlert("Registro do Tipo PA não pode ser desdobrado. O titulo será incluído sem desdobramento.", "Alerta!")
			Reclock("ZA7",.F.)
			ZA7->ZA7_DESDOB := "N"
			MsUnlock()
		Endif

		//Gravação da alçada
		If (!lDesdbr)
			U_RPFA007(oModel:GetOperation(),oModel)
		EndIf
	End Transaction
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} fMultN01A
Consulta de Multinatureza
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fMultN01A

	Local aArea := getArea()
	Local oModel:= fwModelActive()
	Local nModB	:= nModulo
	Local cModB	:= cModulo
	nModulo	:= 6
	cModulo	:= "FIN"
	
	cQuery := "SELECT TOP 1 R_E_C_N_O_ RECNO FROM " + RetSqlName("ZA8") + " ZA8 "
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
	cQuery += "ZA8_FILIAL = '" + xFilial("ZA8") + "' AND "
	cQuery += "ZA8_PREFIX = '" + ZA7->ZA7_PREFIX + "' AND "
	cQuery += "ZA8_NUM= '" + ZA7->ZA7_NUM + "' AND "
	cQuery += "ZA8_PARCEL = '" + ZA7->ZA7_PARCEL + "' AND "
	cQuery += "ZA8_CLIFOR = '" + ZA7->ZA7_FORNEC + "' AND "
	cQuery += "ZA8_LOJA = '" + ZA7->ZA7_LOJA + "'  "
	TcQuery cQuery new Alias QZA8

	If QZA8->(!Eof())
		dbSelectArea("ZA8")
		ZA8->(dbGoto(QZA8->RECNO))
		FWExecView ("Rateio MultiNatureza", "RPFA003", MODEL_OPERATION_VIEW,,{||.T.},,,,)
	Else
		Alert('Não localizado rateio multinatureza')
	Endif
	QZA8->(dbCloseArea())
	nModulo:= nModB
	cModulo:= cModB

	RestArea(aArea)
Return
/*/{Protheus.doc} fCCR01A
Consulta do Rateio CC
@author Diogo
@since 26/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fCCR01A

	Local aArea  := getArea()
	Local oModel := fwModelActive()
	Local nModB	 := nModulo
	Local cModB	 := cModulo

	nModulo	:= 6
	cModulo	:= "FIN"

	cQuery :="SELECT TOP 1 R_E_C_N_O_ RECNO FROM " + RetSqlName("ZA9") + " ZA9 "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="ZA9_FILIAL = '" + xFilial("ZA9") + "' AND "
	cQuery +="ZA9_PREFIX = '" + ZA7->ZA7_PREFIX + "' AND "
	cQuery +="ZA9_NUM= '" + ZA7->ZA7_NUM + "' AND "
	cQuery +="ZA9_PARCEL = '" + ZA7->ZA7_PARCEL  +"' AND "
	cQuery +="ZA9_CLIFOR = '" + ZA7->ZA7_FORNEC + "' AND "
	cQuery +="ZA9_LOJA = '" + ZA7->ZA7_LOJA + "'  "
	TcQuery cQuery new Alias QZA9

	If QZA9->(!Eof())
		dbSelectArea("ZA9")
		ZA9->(dbGoto(QZA9->RECNO))
		FWExecView ("Rateio Centro de Custo", "RPFA006", MODEL_OPERATION_VIEW,,{||.T.},,,,)
	Else
		Alert('Não localizado rateio centro de custo')
	Endif
	QZA9->(dbCloseArea())

	nModulo:= nModB
	cModulo:= cModB
	
	RestArea(aArea)
Return

/*/{Protheus.doc} fGrvPA
Gravação do PA
@author Diogo
@since 25/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fGrvPA
	Local aArea			:= GetArea()
	Local oBcoAdt
	Local oChqAdt
	Local bAction
	Local nMoedAux		:= 1
	Local oDlgPA
	Local aPergs		:= {}
	Local aRetOpc		:= {}
	Local cBancoAdt		:= ZA7->ZA7_BANCO
	Local cAgenciaAdt	:= ZA7->ZA7_AGENCIA
	Local cNumCon	 	:= ZA7->ZA7_CONTA
	Local cChequeAdt	:= CriaVar("EF_NUM")
	Local cHistor		:= ZA7->ZA7_HISTPA
	Local cBenef		:= ZA7->ZA7_BENEF
	Local cPictHist		:= getSx3Cache("EF_HIST","X3_PICTURE")
	cTitulo := ZA7->ZA7_NUM

	While .T.
		nOpca := 0
		DEFINE MSDIALOG oDlgPA FROM 10, 5 TO 26, 60 TITLE OemToAnsi("Pagamento Antecipado " + cTitulo)
		@	.3,1 TO 07.3,26 OF oDlgPA
		@	1.0,2 	Say OemToAnsi("Banco :         ")
		@	1.0,8  	MSGET oBcoAdt 			VAR cBancoAdt F3 "SA6" 	Valid CarregaSa6(@cBancoAdt,,,,,,, @nMoedAux )
		@	2.0,2 	Say OemToAnsi("Agência :       ")
		@	2.0,8 	MSGET cAgenciaAdt 								Valid CarregaSa6(@cBancoAdt,@cAgenciaAdt)
		@	3.0,2 	Say OemToAnsi("Conta :         ")
		@	3.0,8 	MSGET cNumCon 									Valid If(CarregaSa6(@cBancoAdt,@cAgenciaAdt,@cNumCon,,,.T.),,oBcoAdt:SetFocus())
		@	4.0,2 	Say OemToAnsi("Num Cheque :   ")
		@	4.0,8 	MSGET oChqAdt 			VAR cChequeAdt 			When (substr(cvaltochar(ZA7->ZA7_CHQADT),1,1) == "1")  ;
											Valid fa050Cheque(cBancoAdt,cAgenciaAdt,cNumCon,cChequeAdt,Iif(cPaisLoc $ "ARG",.F.,.T.))
		@	5.0,2 	Say OemToAnsi("Historico :    ")
		@	5.0,8 	MSGET cHistor		Picture cPictHist	SIZE 135, 10 OF oDlgPA
		@	6.0,2 	Say OemToAnsi("Beneficiário :    ")
		@	6.0,8 	MSGET cBenef		Picture "@!"	SIZE 135, 10 OF oDlgPA


		bAction := {||	nOpca := 1,;
		Iif(!Empty(cBancoAdt).And.;
		CarregaSa6(@cBancoAdt,@cAgenciaAdt,@cNumCon,,,.T.).And.;
		.T.,;
		oDlgPA:End(),;
		nOpca := 0)}

		DEFINE SBUTTON FROM 105,180.1 TYPE 1 ACTION ( Eval(bAction) ) ENABLE OF oDlgPA
		ACTIVATE MSDIALOG oDlgPA CENTERED
		IF nOpca != 0
			RecLock("ZA7",.F.)
			ZA7->ZA7_BANCO	 	:= cBancoAdt
			ZA7->ZA7_AGENCIA 	:= cAgenciaAdt
			ZA7->ZA7_CONTA   	:= cNumCon
			ZA7->ZA7_HISTPA  	:= cHistor
			ZA7->ZA7_NUMCHQ		:= cChequeAdt
			ZA7->ZA7_BENEF		:= cBenef
			ZA7->(MsUnLock())
			Exit
		EndIf
	EndDo
	RestArea(aArea)
Return

/*/{Protheus.doc} fGetGrupoAp
Regra para gravação da escolha do grupo de aprovação
@author Diogo
@since 09/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetGrupoAp()
	Local oModel := FwModelActive()
	Local cRet	 := ""
	Local aArea	 := getArea()

	cQuery := "SELECT AL_COD,AL_DESC FROM " + RetSqlName("SAL") + " SAL "
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
	cQuery += "AL_FILIAL = '" + xFilial("SAL") + "' AND "
	cQuery += "AL_YTIPOPF = '" + fWFldGet("ZA7_TIPOPF") + "' "
	TcQuery cQuery new Alias QSAL

	if QSAL->(!Eof())
		cRet := QSAL->AL_COD
		oModel:getModel("CADZA7"):setValue("ZA7_GPRAPV",cRet)
		oModel:getModel("CADZA7"):setValue("ZA7_NMGRPF",alltrim(posicione("SAL",1,xFilial("SAL")+fwFldGet("ZA7_GPRAPV"),"AL_DESC")))
	Else
		oModel:getModel("CADZA7"):setValue("ZA7_GPRAPV","")
		oModel:getModel("CADZA7"):setValue("ZA7_NMGRPF","")
	Endif
	If !empty(fWFldGet("ZA7_TIPOPF"))
		oModel:getModel("CADZA7"):setValue("ZA7_NMTIPO",substr(posicione("SX5",1,xFilial("SX5")+"ZZ"+fwFldGet("ZA7_TIPOPF"),"X5_DESCRI"),1,40))
	Endif
	QSAL->(dbCloseArea())
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} fConsApv
Consulta da aprovação
@author diogo
@since 02/04/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fConsApv()
	//Function A120Posic(cAlias,nReg,nOpcx,cTipoDoc,lStatus,lResid)
	Local aArea			:= GetArea()
	Local aSavCols		:= {}
	Local aSavHead		:= {}
	Local cHelpApv		:= "Este documento nao possui controle de aprovacao ou deve ser aprovado pelo controle de alçadas."
	Local cAliasSCR		:= GetNextAlias()
	Local cComprador	:= ""
	Local cSituaca  	:= ""
	Local cNumDoc		:= ""
	Local cStatus		:= "Documento aprovado"
	Local cTitle		:= ""
	Local cTitDoc		:= ""
	Local cAddHeader	:= ""
	Local cAprovador	:= ""
	Local nSavN			:= 0
	Local nX   			:= 0
	Local oDlg			:= NIL
	Local oGet			:= NIL
	Local oBold			:= NIL
	Local lCtCorp		:= .F.
	Local lMdCorp		:= .F.
	Local cQuery   		:= ""
	Local aStruSCR 		:= SCR->(dbStruct())
	Local cFilSCR 		:= xFilial("SCR")
	Local cTipoDoc 		:= "PF"
	Local lStatus  		:= .T.
	Local lResid   		:= .F.
	Local nOpcx    		:= 2
	Local cTipCR		:= 'PF'
	Local lAprPCEC, lAprSAEC, lAprCTEC, lAprMDEC, lAprSCEC := .T.

	Private aCols 		:= {}
	Private aHeader 	:= {}
	Private N 			:= 1

	cTitle  	:= "Aprovacao do Pedido Financeiro"
	cTitDoc 	:= "Pedido Financeiro"
	cHelpApv	:= "Este pedido nao possui controle de aprovação"

	If funname() == "MATA094"
		aRotina := {}
		AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
		nOpc	:= 1
		n		:= 1
		If SCR->CR_TIPO='PF'
			dbSelectArea("ZA7")
			ZA7->(dbSetOrder(3))
			ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM)))
			cNumDoc 	:= ZA7->ZA7_NUM+ZA7->ZA7_PARCEL
			cComprador	:= UsrRetName(ZA7->ZA7_CODUSE)
		Else //Pedido de Compras
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			SC7->(dbSeek(xFilial("SC7")+alltrim(SCR->CR_NUM)))
			cNumDoc 	:= SC7->C7_NUM
			cComprador	:= UsrRetName(SC7->C7_USER)
			cTipCR		:= 'PC'
		Endif
		
	Else
		cNumDoc 	:= alltrim(ZA7->ZA7_NUM+ZA7->ZA7_PARCEL)
		cComprador	:= UsrRetName(ZA7->ZA7_CODUSE)
	Endif

	If !Empty(cNumDoc)
		aHeader:= {}
		aCols  := {}

		//****************************************************************
		//* Faz a montagem do aHeader com os campos fixos.               *
		//****************************************************************
		SX3->(dbSetOrder(1))
		SX3->(MsSeek("SCR"))

		If (cTipoDoc $ "PF|PC|IP" .And. lAprPCEC) .Or.;
		(cTipoDoc == "SA" .And. lAprSAEC) .Or.;
		(cTipoDoc == "SC" .And. lAprSCEC) .Or.;
		(cTipoDoc $ "CT|IC" .And. lAprCTEC) .Or.;
		(cTipoDoc $ "MD|IM" .And. lAprMDEC) .Or.;
		(cTipoDoc $ "SC|IP|PC" .and. MtExistDBM(cTipoDoc,cNumDoc))
			AADD(aHeader,{"Item","bCR_ITEM","",8,0,"","","C","",""} )	// Item
		Endif

		While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == "SCR")
			IF AllTrim(SX3->X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )

				If AllTrim(SX3->X3_CAMPO) == "CR_NIVEL"
					AADD(aHeader,{ "Aprovador Responsável","bCR_NOME",   "",15,0,"","","C","",""} )
					AADD(aHeader,{ "Situação","bCR_SITUACA","",20,0,"","","C","",""} )
					AADD(aHeader,{ "Avaliado por","bCR_NOMELIB","",15,0,"","","C","",""} )
				EndIf

				If AllTrim(SX3->X3_CAMPO) == "CR_DATALIB"
					AADD(aHeader,{ "Grupo","bCR_GRUPO","",6,0,"","","C","",""} )
				EndIf

			Endif

			SX3->(dbSkip())
		EndDo

		ADHeadRec("SCR",aHeader)

		cQuery := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM " + RetSqlName("SCR") + " SCR "
		cQuery += "WHERE SCR.CR_FILIAL='" + cFilSCR + "' AND "
		cQuery += "SCR.CR_NUM = '" + cNumDoc + "' AND "
		cQuery += "SCR.CR_TIPO = '"+cTipCR+"' "
		cQuery += "AND SCR.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY " + SqlOrder(SCR->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

		For nX := 1 To Len(aStruSCR)
			If aStruSCR[nX][2] <> "C"
				TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
			EndIf
		Next nX

		While !(cAliasSCR)->(Eof())
			aAdd(aCols,Array(Len(aHeader) + 1))

			For nX := 1 to Len(aHeader)
				If IsHeadRec(aHeader[nX][2])
					aTail(aCols)[nX] := (cAliasSCR)->SCRRECNO
				ElseIf IsHeadAlias(aHeader[nX][2])
					aTail(aCols)[nX] := "SCR"
				ElseIf aHeader[nX][02] == "bCR_NOME"
					aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USER)
				ElseIf aHeader[nX][02] == "bCR_ITEM"
					If lAprPCEC .Or. lAprSAEC .Or. lAprSCEC .Or. lAprCTEC .Or. lAprMDEC
						If (cAliasSCR)->CR_TIPO $ "SC|SA|IP|IC|IM"
							aTail(aCols)[nX] := AllTrim((cAliasSCR)->DBM_ITEM) + IIF(!Empty((cAliasSCR)->DBM_ITEMRA), "-" + (cAliasSCR)->DBM_ITEMRA,"")
						Else
							aTail(aCols)[nX] := Replicate("-",8)
						Endif
					Endif
				ElseIf aHeader[nX][02] == "bCR_GRUPO"
					aTail(aCols)[nX] := (cAliasSCR)->CR_GRUPO
				ElseIf aHeader[nX][02] == "bCR_SITUACA"
					Do Case
						Case (cAliasSCR)->CR_STATUS == "01"
						cSituaca := "Pendente em níveis anteriores"
						If cStatus == "Documento aprovado"
							cStatus := "Aguardando liberação(ões)"
						EndIf
						Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := "Pendente"
						If cStatus == "Documento aprovado"
							cStatus := "Aguardando liberação(ões)"
						EndIf
						Case (cAliasSCR)->CR_STATUS == "03"
						cSituaca := "Aprovado"
						Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := "Bloqueado"
						If cStatus # "Documento aprovado"
							cStatus := "Documento bloqueado"
						EndIf
						Case (cAliasSCR)->CR_STATUS == "05"
						cSituaca := "Aprovado/rejeitado pelo nível"
						Case (cAliasSCR)->CR_STATUS == "06"
						cSituaca := "Rejeitado"
						If cStatus # "Documento rejeitado"
							cStatus := "Documento rejeitado"
						EndIf
					EndCase

					If cTipoDoc == "SC" .AND. !((lExAprov .AND. !lResid) .OR. !lExAprov)
						If (cAliasSCR)->(FieldPos("C1_RESIDUO")) > 0 .AND. !Empty((cAliasSCR)->C1_RESIDUO)
							cStatus		:= "Elim.Resíduo/ " + cStatus //"Elim.Resíduo/" + Status
							cSituaca 	:= "Elim.Resíduo/ " + cSituaca //"Elim.Resíduo/" + Situação
						EndIf
					ElseIf cTipoDoc == "IP" .AND. !((lExAprov .AND. !lResid) .OR. !lExAprov)
						If (cAliasSCR)->(FieldPos("C7_RESIDUO")) > 0 .AND. !Empty((cAliasSCR)->C7_RESIDUO)
							cStatus		:= "Elim.Resíduo/ " + cStatus //"Elim.Resíduo/" + Status
							cSituaca 	:= "Elim.Resíduo/ " + cSituaca //"Elim.Resíduo/" + Situação
						EndIf
					EndIf

					aTail(aCols)[nX] := cSituaca
				ElseIf aHeader[nX][02] == "bCR_NOMELIB"
					aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
				ElseIf Alltrim(aHeader[nX][02]) == "CR_OBS"//Posicionar para ler
					SCR->(dbGoto((cAliasSCR)->SCRRECNO))
					aTail(aCols)[nX] := SCR->CR_OBS
				ElseIf ( aHeader[nX][10] != "V")
					aTail(aCols)[nX] := FieldGet(FieldPos(aHeader[nX][2]))
				EndIf
			Next nX

			aTail(aCols)[Len(aHeader) + 1] := .F.

			(cAliasSCR)->(dbSkip())
		EndDo

		If !Empty(aCols)
			n := IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds).
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			If !(cTipoDoc $ "MD|RV|CT|IC|IM")
				@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal"
				@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 150,009 OF oDlg FONT oBold
				If cTipoDoc <> "NF"
					@ 015,095 SAY OemToAnsi("Comprador") OF oDlg PIXEL SIZE 045,009 FONT oBold //"Comprador"
					@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
				EndIF
			Else
				@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Medicao"
				@ 014,035 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 50,009 OF oDlg FONT oBold

				@ 015,095 SAY cAprovador OF oDlg PIXEL SIZE 045,009 FONT oBold //"Aprovador"
				@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
			EndIf

			@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009 //'Situacao :'
			@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
			@ 132,205 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
			oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("Atencao","Este pedido nao possui controle de aprovacao.",{"Voltar"}) //"Atencao"###"Este pedido nao possui controle de aprovacao."###"Voltar"
		EndIf

		(cAliasSCR)->(dbCloseArea())

		If lStatus
			aHeader := aClone(aSavHead)
			aCols := aClone(aSavCols)
			N := nSavN
		EndIf
	Else
		Aviso("Atencao","Este Documento nao possui controle de aprovacao.",{"Voltar"}) //"Atencao"###"Este Documento nao possui controle de aprovacao."###"Voltar"
	EndIf

	RestArea(aArea)

Return NIL

/*/{Protheus.doc} fDesdobr
Gravação do Desdobramento do Pedido Financeiro
@author Wilton
@since 29/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fDesdobr(nOpert, oModel)
	Local aArea			:= GetArea()
	Local bAction
	Local oDlgDesdobr
	Local cHistor		:= ZA7->ZA7_HIST
	Local cPictHist		:= getSx3Cache("EF_HIST","X3_PICTURE")
	Local oCondAdt
	Local cCondPgt		:= Space(3)
	Local cPictCond		:= 3
	Local nValTot 		:= ZA7->ZA7_VALOR
	Local aParc 		:= {}
	Local nZa7Ind		:= ZA7->(Recno())
	Local aTit 			:= {ZA7->ZA7_CODIGO,;
	ZA7->ZA7_ANO,;
	ZA7->ZA7_MESREF,;
	ZA7->ZA7_PREFIX,;
	ZA7->ZA7_NUM,;
	ZA7->ZA7_PARCEL,;
	ZA7->ZA7_TIPO,;
	ZA7->ZA7_FORNEC,;
	ZA7->ZA7_LOJA,;
	ZA7->ZA7_NOMFOR,;
	ZA7->ZA7_NATURE,;
	ZA7->ZA7_NOMNAT,;
	ZA7->ZA7_EMISSA,;
	ZA7->ZA7_VENCTO,;
	ZA7->ZA7_VENCRE,;
	ZA7->ZA7_VALOR,;
	ZA7->ZA7_HIST,;
	ZA7->ZA7_CUSTO,;
	ZA7->ZA7_MULTNA,;
	ZA7->ZA7_CODBAR,;
	ZA7->ZA7_DESCRI,;
	ZA7->ZA7_CODUSE,;
	ZA7->ZA7_USECAD,;
	ZA7->ZA7_DTCAD,;
	ZA7->ZA7_HRCAD,;
	ZA7->ZA7_CODLIB,;
	ZA7->ZA7_USELIB,;
	ZA7->ZA7_DTLIB,;
	ZA7->ZA7_HRLIB,;
	ZA7->ZA7_STATUS,;
	ZA7->ZA7_BANCO,;
	ZA7->ZA7_AGENCI,;
	ZA7->ZA7_CONTA,;
	ZA7->ZA7_HISTPA,;
	ZA7->ZA7_OK,;
	ZA7->ZA7_HRREJ,;
	ZA7->ZA7_DTREJ,;
	ZA7->ZA7_USEREJ,;
	ZA7->ZA7_HISTPA,;
	ZA7->ZA7_GPRAPV,;
	ZA7->ZA7_NMGRPF,;
	ZA7->ZA7_TIPOPF,;
	ZA7->ZA7_NMTIPO,;
	ZA7->ZA7_DESDOB,;
	ZA7->ZA7_CHQADT,;
	ZA7->ZA7_MOVCHQ;
	}

	Local i := 0
	Local j := 0

	Local cStrSql 	:= ""
	Local cFilZA8 	:= xFilial("ZA8")
	Local aPercZA8 	:= {}
	Local aPercZA9 	:= {}
	Local lMultNat 	:= IIF(ZA7->ZA7_MULTNA == "S", .T.,.F.)
	Local cQRYZA8 	:= "ZA8"
	Local nNumParc	:= 0	
	Local nNumD		:= 0	
	Local cValorDsd	:= " "	

	cTitulo 	:= ZA7->ZA7_NUM
	cValorDsd	:= "Total"

	While .T.
		nOpca := 0
		

		DEFINE MSDIALOG oDlgDesdobr FROM 10, 5 TO 26, 60 TITLE OemToAnsi("Desdobramento " + cTitulo)
		@ 	.3,1 TO 07.3,26 OF oDlgDesdobr

		@	1.0,2 	Say OemToAnsi("Condição :         ")
		@	1.0,8  	MSGET oCondAdt 			VAR cCondPgt F3 "SE4" OF oDlgDesdobr Valid fValidSE4(@cCondPgt)
		@	2.0,2 	Say OemToAnsi("Historico :    ")
		@	2.0,8 	MSGET cHistor		Picture cPictHist SIZE 135, 10 OF oDlgDesdobr
		@	3.0,2 	Say OemToAnsi("Qtde Parcelas:     ")
		@	3.0,8 	MSGET nNumParc Picture "999" When IIf(Empty(cCondPgt),.T.,.F.)	Valid nNumParc > 0
		@	4.0,2 	Say OemToAnsi("Periodo em Dias :       ")
		@	4.0,8 	MSGET nNumD Picture "999" When IIf(Empty(cCondPgt),.T.,.F.)	Valid nNumParc > 0
//		@ 	5.0,2   SAY "Valor: "
//		@   5.0,8   MSCOMBOBOX oVlDsd VAR cValorDsd ITEMS {"Total","Parcela"} ;
//					When IIf(Empty(cCondPgt),.T.,.F.) 
			
		bAction := { ||	nOpca := 1, Iif( (!Empty(cCondPgt) .OR. nNumParc > 0 ).And. .T., oDlgDesdobr:End(), nOpca := 0 ) }

		DEFINE SBUTTON FROM 105,180.1 TYPE 1 ACTION ( Eval(bAction) ) ENABLE OF oDlgDesdobr
		ACTIVATE MSDIALOG oDlgDesdobr CENTERED

		If nOpca != 0
			If empty(cCondPgt) .and. nNumParc == 0 .and. nNumD == 0
				Alert("Informe os parâmetros")
				loop
			Endif
		
			If !empty(cCondPgt)
				aParc := Condicao(nValTot, cCondPgt,, dDataBase)
			Elseif cValorDsd == "Total"
				aParc	:= {}
				dDatNew	:= date()
				nDiff	:= 0
				For nY:=1 To nNumParc //Percorre a quantidade de parcelas
					nDiff += Round((nValTot/nNumParc),2)
					dDatNew:= dDatNew + nNumD //Data do último + quantidade de dias
					If nY < nNumParc  
						aadd(aParc,{dDatNew,Round((nValTot/nNumParc),2) })
					Else
						aadd(aParc,{dDatNew,Round((nValTot/nNumParc),2) + (nValTot - nDiff)})
					Endif
				Next 
			Else //Parcela
				aParc	:= {}
				dDatNew	:= date()
				For nY:=1 To nNumParc //Percorre a quantidade de parcelas
					dDatNew:= dDatNew + nNumD //Data do último + quantidade de dias
					aadd(aParc,{dDatNew,nValTot})
				Next 
			Endif

			// Tiver multnatureza
			if (lMultNat)
				cStrSql := " SELECT *, R_E_C_N_O_ RECNO "
				cStrSql += " FROM " + RetSqlName("ZA8") + " ZA8 "
				cStrSql += " WHERE ZA8.ZA8_FILIAL = '" + cFilZA8 + "' AND "
				cStrSql += " ZA8.ZA8_PREFIX = '" + ZA7->ZA7_PREFIX + "' AND "
				cStrSql += " ZA8.ZA8_NUM = '" + ZA7->ZA7_NUM + "' AND "
				cStrSql += " ZA8.ZA8_PARCEL = '" + ZA7->ZA7_PARCEL + "' AND "
				cStrSql += " ZA8.ZA8_CLIFOR = '" + ZA7->ZA7_FORNEC + "' AND "
				cStrSql += " ZA8.ZA8_LOJA = '" + ZA7->ZA7_LOJA + "' AND "
				cStrSql += " ZA8.D_E_L_E_T_  = ' ' "
				TcQuery cStrSql new Alias cQRYZA8

				While !cQRYZA8->( EOF() )
					AAdd( aPercZA8,{cQRYZA8->ZA8_PERC,;		//1
									cQRYZA8->ZA8_NATURE,;	//2
									cQRYZA8->ZA8_NMNAT,;	//3
									cQRYZA8->ZA8_RECPAG,;	//4
									cQRYZA8->ZA8_RATEIC})	//5
					cQRYZA8->(dbSkip())
				EndDo
				cQRYZA8->(dbCloseArea())

				cStrSql := " SELECT *,R_E_C_N_O_ RECNO " 
				cStrSql += " FROM " + RetSqlName("ZA9") + " ZA9 "
				cStrSql += " WHERE ZA9.ZA9_FILIAL = '" + xFilial("ZA9") + "' AND "
				cStrSql += " ZA9.ZA9_PREFIX = '" + ZA7->ZA7_PREFIX + "' AND "
				cStrSql += " ZA9.ZA9_NUM = '" + ZA7->ZA7_NUM + "' AND "
				cStrSql += " ZA9.ZA9_PARCEL = '" + ZA7->ZA7_PARCEL + "' AND "
				cStrSql += " ZA9.ZA9_CLIFOR = '" + ZA7->ZA7_FORNEC + "' AND "
				cStrSql += " ZA9.ZA9_LOJA = '" + ZA7->ZA7_LOJA + "' AND "
				cStrSql += " ZA9.D_E_L_E_T_  = ' ' "
				TcQuery cStrSql new Alias cQRYZA9
				aPercZA9:= {}	
				While !cQRYZA9->( EOF() )
					// Adiciona percentual
					aAdd(aPercZA9,{	cQRYZA9->ZA9_NATURE,; 	//1
					 				cQRYZA9->ZA9_CUSTO,;	//2 
					 				cQRYZA9->ZA9_NMCC,; 	//3
					 				cQRYZA9->ZA9_PERC,; 	//4
					 				cQRYZA9->ZA9_VALCC,;	//5
					 				cQRYZA9->ZA9_ITEMCC}) 	//6
					cQRYZA9->(dbSkip())
				EndDo
				cQRYZA9->(dbCloseArea())
			EndIf
			
			For i := 1 to Len(aParc)
				ZA7->(dbGoto(nZa7Ind))
				If i == 1 //Posiciona no registro para atualizar
					Reclock("ZA7",.F.)
						ZA7->ZA7_VENCTO := aParc[i,1]
						ZA7->ZA7_VENCRE := DataValida(aParc[i,1],.T.)
						ZA7->ZA7_VALOR 	:= aParc[i,2]
						ZA7->ZA7_HIST 	:= cHistor
						ZA7->ZA7_PARCEL := cvaltochar(i)
					MsUnlock()
					U_RPFA007(nOpert,oModel)
					
					cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("ZA8")+" ZA8 "
					cQuery+= "WHERE ZA8.D_E_L_E_T_ = ' ' AND "
					cQuery+= "ZA8_FILIAL = '"+xFilial("ZA8")+"' AND "
					cQuery+= "ZA8_NUM= '"+ZA7->ZA7_NUM+"' "
					//cQuery+= "AND ZA8_PARCEL= '"+ZA7->ZA7_PARCEL+"' "
					tcQuery cQuery new Alias QRZA8
					while QRZA8->(!Eof())
						ZA8->(dbGoto(QRZA8->RECNO))
						Reclock("ZA8",.F.)
							ZA8->ZA8_VALOR	:= aParc[i,2]
							ZA8->ZA8_VALNAT := ((aParc[i,2] * ZA8->ZA8_PERC)/100)
							ZA8->ZA8_PARCEL := cvaltochar(i)
						msUnlock()	
					QRZA8->(dbSkip())
					Enddo
					QRZA8->(dbCloseArea())

					cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("ZA9")+" ZA9 "
					cQuery+= "WHERE ZA9.D_E_L_E_T_ = ' ' AND "
					cQuery+= "ZA9_FILIAL = '"+xFilial("ZA9")+"' AND "
					cQuery+= "ZA9_NUM= '"+ZA7->ZA7_NUM+"' "
					//cQuery+= "AND ZA9_PARCEL= '"+ZA7->ZA7_PARCEL+"' "
					tcQuery cQuery new Alias QRZA9
					while QRZA9->(!Eof())
						ZA9->(dbGoto(QRZA9->RECNO))
						//Busca o valor da natureza
						cQuery:= "SELECT ZA8_VALNAT FROM "+RetSqlName("ZA8")+" ZA8 "
						cQuery+= "WHERE ZA8.D_E_L_E_T_ = ' ' AND "
						cQuery+= "ZA8_FILIAL = '"+xFilial("ZA8")+"' AND "
						cQuery+= "ZA8_NUM= '"+ZA9->ZA9_NUM+"' AND "
						//cQuery+= "ZA8_PARCEL= '"+ZA9->ZA9_PARCEL+"' AND "
						cQuery+= "ZA8_NATURE= '"+ZA9->ZA9_NATURE+"'  "
						tcQuery cQuery new Alias QRSUM
						nValNat:= QRSUM->ZA8_VALNAT
						QRSUM->(dbCloseArea())
						
						Reclock("ZA9",.F.)
							ZA9->ZA9_VALOR	:= nValNat
							ZA9->ZA9_VALCC	:= ((nValNat * ZA9->ZA9_PERC) / 100)
							ZA9->ZA9_PARCEL := cvaltochar(i)
						msUnlock()	
					QRZA9->(dbSkip())
					Enddo
					QRZA9->(dbCloseArea())
					
				Else //Próximas parcelas, adiciona registros
					RecLock("ZA7",.T.) // Inclusão
						ZA7->ZA7_FILIAL	:= xFilial("ZA7")
						ZA7->ZA7_CODIGO := aTit[1]
						ZA7->ZA7_ANO 	:= aTit[2]
						ZA7->ZA7_MESREF := aTit[3]
						ZA7->ZA7_PREFIX := aTit[4]
						ZA7->ZA7_NUM 	:= aTit[5]
						ZA7->ZA7_PARCEL := cvaltochar(i)
						ZA7->ZA7_TIPO 	:= aTit[7]
						ZA7->ZA7_FORNEC := aTit[8]
						ZA7->ZA7_LOJA 	:= aTit[9]
						ZA7->ZA7_NOMFOR := aTit[10]
						ZA7->ZA7_NATURE := aTit[11]
						ZA7->ZA7_NOMNAT := aTit[12]
						ZA7->ZA7_EMISSA := aTit[13]
						ZA7->ZA7_VENCTO := aParc[i,1]
						ZA7->ZA7_VENCRE := aParc[i,1]
						ZA7->ZA7_VALOR 	:= aParc[i,2]
						ZA7->ZA7_HIST 	:= cHistor
						ZA7->ZA7_CUSTO 	:= aTit[18]
						ZA7->ZA7_MULTNA := aTit[19]
						ZA7->ZA7_CODBAR := aTit[20]
						ZA7->ZA7_DESCRI := aTit[21]
						ZA7->ZA7_CODUSE := aTit[22]
						ZA7->ZA7_USECAD := aTit[23]
						ZA7->ZA7_DTCAD 	:= aTit[24]
						ZA7->ZA7_HRCAD 	:= aTit[25]
						ZA7->ZA7_CODLIB := aTit[26]
						ZA7->ZA7_USELIB := aTit[27]
						ZA7->ZA7_DTLIB 	:= aTit[28]
						ZA7->ZA7_HRLIB 	:= aTit[29]
						ZA7->ZA7_STATUS := aTit[30]
						ZA7->ZA7_BANCO 	:= aTit[31]
						ZA7->ZA7_AGENCI := aTit[32]
						ZA7->ZA7_CONTA  := aTit[33]
						ZA7->ZA7_HISTPA := aTit[34]
						ZA7->ZA7_OK 	:= aTit[35]
						ZA7->ZA7_HRREJ 	:= aTit[36]
						ZA7->ZA7_DTREJ 	:= aTit[37]
						ZA7->ZA7_USEREJ := aTit[38]
						ZA7->ZA7_HISTPA := aTit[39]
						ZA7->ZA7_GPRAPV := aTit[40]
						ZA7->ZA7_NMGRPF := aTit[41]
						ZA7->ZA7_TIPOPF := aTit[42]
						ZA7->ZA7_NMTIPO := aTit[43]
						ZA7->ZA7_DESDOB := aTit[44]
						ZA7->ZA7_CHQADT	:= aTit[45]
						ZA7->ZA7_MOVCHQ	:= aTit[46]
						ZA7->ZA7_DESPFX := Posicione("SED",1,xFilial("SED")+alltrim(aTit[11]),"ED_YDESPFX") //Grava se é despesa fixa
					ZA7->(MsUnLock())
					U_RPFA007(nOpert, oModel)
				
					For j := 1 to Len(aPercZA8)
						RecLock("ZA8", .T.) // Inclui
							ZA8->ZA8_FILIAL	:= xFilial("ZA8")	
							ZA8->ZA8_PREFIX := ZA7->ZA7_PREFIX
							ZA8->ZA8_NUM 	:= ZA7->ZA7_NUM
							ZA8->ZA8_PARCEL := cvaltochar(i)
							ZA8->ZA8_CLIFOR	:= ZA7->ZA7_FORNEC
							ZA8->ZA8_LOJA	:= ZA7->ZA7_LOJA
							ZA8->ZA8_TIPO 	:= ZA7->ZA7_TIPO
							ZA8->ZA8_VALOR 	:= aParc[i,2]
							ZA8->ZA8_PERC 	:= aPercZA8[j][1]
							ZA8->ZA8_NATURE := aPercZA8[j][2]
							ZA8->ZA8_NMNAT	:= aPercZA8[j][3]
							ZA8->ZA8_RECPAG	:= aPercZA8[j][4]
							ZA8->ZA8_RATEIC	:= aPercZA8[j][5]
							ZA8->ZA8_VALNAT := ((aParc[i,2] * aPercZA8[j][1] )/100)
							ZA8->ZA8_SITUAC := ""
						ZA8->(MsUnLock())
					next
					For y := 1 to Len(aPercZA9)
						//Busca o valor da natureza
						cQuery:= "SELECT ZA8_VALNAT FROM "+RetSqlName("ZA8")+" ZA8 "
						cQuery+= "WHERE ZA8.D_E_L_E_T_ = ' ' AND "
						cQuery+= "ZA8_FILIAL = '"+xFilial("ZA8")+"' AND "
						cQuery+= "ZA8_NUM= '"+ZA7->ZA7_NUM+"' AND "
						cQuery+= "ZA8_PARCEL= '"+ZA7->ZA7_PARCEL+"' AND "
						cQuery+= "ZA8_NATURE= '"+aPercZA9[y][1]+"' "
						tcQuery cQuery new Alias QRSUM
						nValNat:= QRSUM->ZA8_VALNAT
						QRSUM->(dbCloseArea())
						
						RecLock("ZA9", .T.)
							ZA9->ZA9_FILIAL	:= xFilial("ZA9")	
							ZA9->ZA9_PREFIX := ZA7->ZA7_PREFIX
							ZA9->ZA9_NUM 	:= ZA7->ZA7_NUM
							ZA9->ZA9_PARCEL := cvaltochar(i)
							ZA9->ZA9_CLIFOR	:= ZA7->ZA7_FORNEC
							ZA9->ZA9_LOJA	:= ZA7->ZA7_LOJA
							ZA9->ZA9_VALOR 	:= nValNat
							ZA9->ZA9_NATURE := aPercZA9[y][1]
							ZA9->ZA9_CUSTO	:= aPercZA9[y][2]
							ZA9->ZA9_NMCC	:= aPercZA9[y][3]
							ZA9->ZA9_PERC 	:= aPercZA9[y][4]
							ZA9->ZA9_VALCC	:= ((nValNat * aPercZA9[y][4]) / 100)
							ZA9->ZA9_ITEMCC	:= aPercZA9[y][6]
						ZA9->(MsUnLock())
					next					
				Endif
			next
			Exit
		EndIf
	EndDo
	RestArea(aArea)
Return

/*/{Protheus.doc} fValidSE4
Valida se existe Condição cadastrada
@author Wilton
@since 29/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fValidSE4(cCond)
	Local aAreaSE4	:= GetArea()
	Local lRet 		:= .T.

	DbSelectArea("SE4")
	DbSetOrder(1)
	// 	Indice 1 E4_FILIAL + E4_CODIGO
	If !DbSeek(xFilial("SE4") + AllTrim(cCond))
		msgAlert("Condição não encontrada.", "Alerta!")
		lRet := .F.
	Endif
	RestArea(aAreaSE4)
Return lRet
/*/{Protheus.doc} fEst01A
Estornar o financeiro
@author Diogo
@since 11/02/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function fEst01A

	If funname() <> "RPFA001"
		dbSelectArea("ZA7")
		ZA7->(dbSetOrder(3))
		ZA7->(dbSeek(xfilial("ZA7")+alltrim(SCR->CR_NUM)))
	Endif

	If ZA7->ZA7_STATUS <> 'A'
		msgAlert("Pedido Financeiro não aprovado")
		Return
	Endif
	
	cQuery:= "SELECT AL_COD FROM "+RetSqlName("SAL")+" SAL "
	cQuery+= "WHERE SAL.D_E_L_E_T_ = ' ' AND "
	cQuery+= "AL_FILIAL = '"+xFilial("SAL")+"' AND "
	cQuery+= "AL_COD = '"+ZA7->ZA7_GPRAPV+"' AND "
	cQuery+= "AL_USER = '"+retCodUsr()+"' "
	tcQuery cQuery new Alias QRSAL
	If QRSAL->(Eof())
		QRSAL->(dbCloseArea())
		alert("Somente usuário que pertencer ao grupo de aprovadores poderá realizar o estorno")	
		Return
	Endif
	QRSAL->(dbCloseArea())
	
	cQuery :="SELECT R_E_C_N_O_ RECNO, E2_SALDO, E2_VALOR FROM "+RetSqlName("SE2")+ " SE2 "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="E2_FILIAL = '"+xFilial("SE2")+"' AND "
	cQuery +="E2_NUM = '"+ZA7->ZA7_NUM+"' AND "
	cQuery +="E2_PARCELA = '"+ZA7->ZA7_PARCEL+"' AND "
	cQuery +="E2_TIPO = '"+ZA7->ZA7_TIPO+"' "
	TcQuery cQuery new Alias QSE2
	
	If QSE2->(!Eof())
		
		If QSE2->E2_SALDO <> QSE2->E2_VALOR
		  	msgAlert("Titulo financeiro já movimentado e não poderá sofrer estorno")
		Elseif msgyesno("Confirma o estorno do Titulo a Pagar?")
			dbSelectArea("SE2")
			SE2->(dbGoto(QSE2->RECNO))
			
			aExclPc := { 	{ "E2_PREFIXO" 	, SE2->E2_PREFIXO 	, NIL },;
		                	{ "E2_NUM"     	, SE2->E2_NUM     	, NIL },;
		                	{ "E2_FORNECE"  , SE2->E2_FORNECE   , NIL } }

			lMsErroAuto:= .F.
			
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aExclPc,, 5)
			If lMsErroAuto
			    MostraErro()
			Else
				Reclock("ZA7",.F.)
					ZA7->ZA7_STATUS := 'P'
					ZA7->ZA7_CODLIB := ' '
					ZA7->ZA7_USELIB := ' '
					ZA7->ZA7_HRLIB	 := ' '
					ZA7->ZA7_DTLIB 	:= cTod("")
				MsUnlock()
				u_RPFA007(4,nil)
				msgInfo("Titulo financeiro estornado")
			Endif
		Endif
		
	Else
		msgAlert("Titulo financeiro não localizado")
	Endif
	QSE2->(dbCloseArea())
Return

/*/{Protheus.doc} fSetMultNat
Refaz o rateio quando alterado o valor
@author diogo
@since 07/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fSetMultNat

	Local aArea:= getArea()
	Local nUltR:= 0
	Local nTotZ:= 0
	Local nTotG:= 0

	cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("ZA8")+" ZA8 "
	cQuery+= "WHERE ZA8.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZA8_FILIAL = '"+xFilial("ZA8")+"' AND "
	cQuery+= "ZA8_NUM= '"+ZA7->ZA7_NUM+"' "
	cQuery+= "AND ZA8_PARCEL= '"+ZA7->ZA7_PARCEL+"' "
	tcQuery cQuery new Alias QMNAT
	while QMNAT->(!Eof())
		nUltR:= QMNAT->RECNO
		ZA8->(dbGoto(QMNAT->RECNO))
		Reclock("ZA8",.F.)
			ZA8->ZA8_VALOR	:= ZA7->ZA7_VALOR 
			ZA8->ZA8_VALNAT := Round((ZA8->ZA8_VALOR*ZA8->ZA8_PERC)/100,2)
		msUnlock()
		nTotZ+= Round((ZA8->ZA8_VALOR*ZA8_PERC)/100,2)
	QMNAT->(dbSkip())
	Enddo
	QMNAT->(dbCloseArea())
	
	If nTotZ <> ZA7->ZA7_VALOR //Total não confere, joga a diferença para o último item
		ZA8->(dbGoto(nUltR))
		Reclock("ZA8",.F.)
			ZA8->ZA8_VALNAT := ZA8->ZA8_VALNAT + (ZA7->ZA7_VALOR - nTotZ) 
		msUnlock()
	Endif
	
	nTotZ:= 0
	//Rateio Centro de Custo
	cQuery:= "SELECT ZA9.R_E_C_N_O_ RECNO,ZA8_VALNAT FROM "+RetSqlName("ZA9")+" ZA9 "
	cQuery+= "JOIN "+RetSqlName("ZA8")+" ZA8 "
	cQuery+= "ON ZA8_FILIAL = ZA9_FILIAL AND ZA8_NUM = ZA9_NUM AND ZA8_PARCEL = ZA9_PARCEL AND ZA8_NATURE = ZA9_NATURE " 
	cQuery+= "WHERE ZA8.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZA9.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZA8_FILIAL = '"+xFilial("ZA8")+"' AND "
	cQuery+= "ZA8_NUM= '"+ZA7->ZA7_NUM+"' "
	cQuery+= "AND ZA8_PARCEL= '"+ZA7->ZA7_PARCEL+"' "
	tcQuery cQuery new Alias QMRAT
	while QMRAT->(!Eof())
		nUltR:= QMRAT->RECNO
		ZA9->(dbGoto(QMRAT->RECNO))
		Reclock("ZA9",.F.)
			ZA9->ZA9_VALOR	:= QMRAT->ZA8_VALNAT 
			ZA9->ZA9_VALCC  := Round((ZA9->ZA9_VALOR*ZA9->ZA9_PERC)/100,2)
		msUnlock()
		nTotZ+= Round((ZA9->ZA9_VALOR*ZA9->ZA9_PERC)/100,2)
	QMRAT->(dbSkip())
	Enddo
	QMRAT->(dbCloseArea())

	If nTotZ <> ZA7->ZA7_VALOR //Total não confere, joga a diferença para o último item
		ZA9->(dbGoto(nUltR))
		Reclock("ZA8",.F.)
			ZA9->ZA9_VALCC := ZA9->ZA9_VALCC + (ZA7->ZA7_VALOR - nTotZ) 
		msUnlock()
	Endif
	RestArea(aArea)
Return