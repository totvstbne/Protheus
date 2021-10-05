#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'

/*/{Protheus.doc} RPFA004
Rateio de Centro de Custo
@author Diorgo
@since 17/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
user function RPFA004()
	Local oBrowse		:= Nil
	Private aRotina		:= MenuDef()
	Private cCadastro	:= "Rateio Centro de Custo"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA9")

	oBrowse:SetDescription(cCadastro)
	oBrowse:DisableDetails()
	oBrowse:Activate()
return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	ADD OPTION aRotina TITLE "Pesquisar"		ACTION "PesqBrw"			OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RPFA004"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RPFA004"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RPFA004"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RPFA004"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RPFA004"	OPERATION 8 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruct		:= Nil
	Local oStructZA9	:= Nil
	Local oModel		:= Nil

	oStruct			:= FWFormStruct(1,"ZA9", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|ZA9_VALOR|ZA9_NATURE|ZA9_NMNAT|")} )
	oStructZA9		:= FWFormStruct(1,"ZA9", {|cCampo|   !(AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|ZA9_VALOR|ZA9_NATURE|ZA9_NMNAT|")} )

	oModel:= MPFormModel():New("YPFA002",/*Pre-Validacao*/,{|oModel| fValidarForm(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("CABECZA9", Nil/*cOwner*/, oStruct ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey({"ZA9_FILIAL","ZA9_PREFIX","ZA9_NUM","ZA9_PARCEL","ZA9_NATURE"})

	oModel:AddGrid("GRIDZA9", "CABECZA9"/*cOwner*/,oStructZA9, ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
	oModel:SetRelation("GRIDZA9",{{"ZA9_FILIAL",'xFilial("ZA9")'},{"ZA9_PREFIX","ZA9_PREFIX"},;
										{"ZA9_NUM","ZA9_NUM"},{"ZA9_PARCEL","ZA9_PARCEL"},;
										{"ZA9_NATURE","ZA9_NATURE"}},ZA9->(IndexKey(1)))
	oModel:GetModel( 'GRIDZA9' ):SetUniqueLine( { 'ZA9_CUSTO' } )
	oModel:AddCalc( 'CALCPERC04', 'CABECZA9', 'GRIDZA9', 'ZA9_PERC', 'PERC'		, 'SUM',,,'Total Percentual',)
	oModel:AddCalc( 'CALCPERC04', 'CABECZA9', 'GRIDZA9', 'ZA9_VALCC', 'VALCC'	, 'SUM',,,'Total Valor',)
	
	oStructZA9:AddTrigger(	;
	"ZA9_PERC"			,;
	"ZA9_VALCC"		,;
	{ |oModel,cId,xValue,nLinha| ReadVar()=="M->ZA9_PERC" }	,;
	{ |oModel|  fCalcVal(oModel) } )

	oStructZA9:AddTrigger(	;
	"ZA9_VALCC"			,;
	"ZA9_PERC"				,;
	{ |oModel,cId,xValue,nLinha| ReadVar()=="M->ZA9_VALCC" }	,;
	{ |oModel|  fCalcPer(oModel) } )
	
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruct		:= FWFormStruct(2,"ZA9", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|ZA9_VALOR|ZA9_NATURE|ZA9_NMNAT|")} )
	Local oStructZA9	:= FWFormStruct(2,"ZA9", {|cCampo|   !(AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|ZA9_VALOR|ZA9_NATURE|ZA9_NMNAT|")} )
	Local oModel		:= FWLoadModel( 'RPFA004' )
	Local oCalc1		:= FWCalcStruct( oModel:GetModel( 'CALCPERC04') )
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "CABECZA9",oStruct)
	oView:AddGrid("GRIDZA9",oStructZA9)
	oView:AddField('CALC',oCalc1, 'CALCPERC04' )

	oView:CreateHorizontalBox("CABEC",130,,.T.)
	oView:CreateHorizontalBox("GRID",150,,.T.)
	oView:CreateHorizontalBox("CALC",65,,.T.)

	oView:SetOwnerView( "CABECZA9","CABEC")
	oView:SetOwnerView( "GRIDZA9","GRID")
	oView:SetOwnerView( "CALC","CALC")
	oView:EnableControlBar(.T.)

	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)
Return oView

/*/{Protheus.doc} fCalcVal
Gatilho para o total do item
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcVal(oModel)
	Local oModel:= FwModelActive()
	Local nRetC	:= oModel:getModel("CABECZA9"):getValue("ZA9_VALOR")

	If oModel:getModel("GRIDZA9"):getValue("ZA9_PERC") <> 100
	nRetC:= 	Round((oModel:getModel("CABECZA9"):getValue("ZA9_VALOR")*;
				oModel:getModel("GRIDZA9"):getValue("ZA9_PERC"))/100,2)
	//oModel:getModel("CABECZA9"):getValue("ZA9_VALOR") - ;			
	Endif			
Return nRetC


/*/{Protheus.doc} fCalcPer
Gatilho para o percetual do item
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcPer(oModel)
	Local nRet	:= 100
	Local oModel:= FwModelActive()
	If oModel:getModel("GRIDZA9"):getValue("ZA9_VALCC") <> oModel:getModel("CABECZA9"):getValue("ZA9_VALOR")
		nRet:= (Round((oModel:getModel("GRIDZA9"):getValue("ZA9_VALCC")/ ;
		       (oModel:getModel("CABECZA9"):getValue("ZA9_VALOR"))),getSx3Cache("EV_PERC","X3_DECIMAL")))*100
	Endif
Return nRet


/*/{Protheus.doc} fValidarForm
Validação do formulário
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fValidarForm(oModel)
	Local lRet	:= .T.
	Local nTotI	:= 0
	Local oModel:= fwModelActive()
	If oModel:GetOperation()<> MODEL_OPERATION_DELETE
		For nx:=1 To oModel:getModel("GRIDZA9"):length()
			oModel:GetModel("GRIDZA9"):GoLine(nX)
			If oModel:GetModel("GRIDZA9"):IsDeleted()
				Loop
			EndIf
			nTotI+= oModel:GetModel("GRIDZA9"):getValue("ZA9_VALCC")
			If empty(oModel:GetModel("GRIDZA9"):getValue("ZA9_CUSTO"))
				oModel:SetErrorMessage('GRIDZA9',,,,"ATENÇÃO",'Centro de custo não informado', 'Verifique o rateio',)
				Return .F.
			Endif
		Next
		If nTotI <> oModel:getModel("CABECZA9"):getValue("ZA9_VALOR")
			oModel:SetErrorMessage('GRIDZA9',,,,"ATENÇÃO",'Totalizador não confere com o total do rateio', 'Verifique os valores informados',)
			lRet:= .F.
		Endif
	Endif
Return lRet