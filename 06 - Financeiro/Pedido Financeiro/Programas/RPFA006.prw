#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'

/*/{Protheus.doc} RPFA006
Consulta Rateio de Centro de Custo
@author Diorgo
@since 17/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
user function RPFA006()
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
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RPFA006"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RPFA006"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RPFA006"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RPFA006"	OPERATION 5 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruct		:= Nil
	Local oStructZA9	:= Nil
	Local oModel		:= Nil

	oStruct			:= FWFormStruct(1,"ZA9", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|")} )
	oStructZA9		:= FWFormStruct(1,"ZA9", {|cCampo|   !(AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|ZA9_VALOR|")} )

	oModel:= MPFormModel():New("YPFA002",/*Pre-Validacao*/,{|oModel| fValidarForm(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("CABECZA9", Nil/*cOwner*/, oStruct ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey({"ZA9_FILIAL","ZA9_PREFIX","ZA9_NUM","ZA9_PARCEL","ZA9_NATURE"})

	oModel:AddGrid("GRIDZA9", "CABECZA9"/*cOwner*/,oStructZA9, ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
	oModel:SetRelation("GRIDZA9",{{"ZA9_FILIAL",'xFilial("ZA9")'},{"ZA9_PREFIX","ZA9_PREFIX"},;
										{"ZA9_NUM","ZA9_NUM"},{"ZA9_PARCEL","ZA9_PARCEL"};
										},ZA9->(IndexKey(1)))
	oModel:GetModel( 'GRIDZA9' ):SetUniqueLine( {'ZA9_CUSTO'} )
	

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruct		:= FWFormStruct(2,"ZA9", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|")} )
	Local oStructZA9	:= FWFormStruct(2,"ZA9", {|cCampo|   !(AllTrim(cCampo)+"|" $ "ZA9_PREFIX|ZA9_NUM|ZA9_PARCEL|ZA9_CLIFOR|ZA9_LOJA|ZA9_VALOR|")} )
	Local oModel		:= FWLoadModel('RPFA006')
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "CABECZA9",oStruct)
	oView:AddGrid("GRIDZA9",oStructZA9)
	
	oView:CreateHorizontalBox("CABEC",25)
	oView:CreateHorizontalBox("GRID",75)
	oView:SetOwnerView( "CABECZA9","CABEC")
	oView:SetOwnerView( "GRIDZA9","GRID")
	oView:EnableControlBar(.T.)
Return oView


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
	Local nPerc	:= 0
	Local oModel:= fwModelActive()
	If oModel:GetOperation()<> MODEL_OPERATION_DELETE
		For nx:=1 To oModel:getModel("GRIDZA9"):length()
			oModel:GetModel("GRIDZA9"):GoLine(nX)
			If oModel:GetModel("GRIDZA9"):IsDeleted()
				Loop
			EndIf
			nPerc+= oModel:GetModel("GRIDZA9"):getValue("ZA9_PERC")
			If empty(oModel:GetModel("GRIDZA9"):getValue("ZA9_CUSTO"))
				oModel:SetErrorMessage('GRIDZA9',,,,"ATENÇÃO",'Centro de custo não informado', 'Verifique o rateio',)
				Return .F.
			Endif
		Next
		If nPerc <> 100
			oModel:SetErrorMessage('GRIDZA9',,,,"ATENÇÃO",'Percentual informado diverge do total', 'Verifique o rateio',)
			lRet:= .F.
		Endif
	Endif
Return lRet