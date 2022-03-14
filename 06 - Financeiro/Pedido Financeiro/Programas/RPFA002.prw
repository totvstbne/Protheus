#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'

/*/{Protheus.doc} RPFA002
Aprovadores por Centro de Custo
@author Diogo
@since 17/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA002()
	Local oBrowse		:= Nil
	Private aRotina		:= MenuDef()
	Private cCadastro	:= "Aprovadores Pedido Financeiro x Centro de Custo"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA5")

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
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RPFA002"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RPFA002"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RPFA002"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RPFA002"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RPFA002"	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"    		ACTION "VIEWDEF.RPFA002"	OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruct		:= Nil
	Local oStructZA5	:= Nil
	Local oModel		:= Nil

	oStruct			:= FWFormStruct(1,"ZA5", {|cCampo|  !(AllTrim(cCampo)+"|" $ "ZA5_CC|ZA5_NMCC|")} )
	oStructZA5		:= FWFormStruct(1,"ZA5", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA5_CC|ZA5_NMCC|")} )
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------

	oModel:= MPFormModel():New("YPFA002",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("CADZA5", Nil/*cOwner*/, oStruct ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey({"ZA5_FILIAL","ZA5_CODAPV"})

	oModel:AddGrid("CADZA5_GRID", "CADZA5"/*cOwner*/,oStructZA5, ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
	oModel:SetRelation("CADZA5_GRID",{{"ZA5_FILIAL",'xFilial("ZA5")'},{"ZA5_CODAPV","ZA5_CODAPV"}},ZA5->(IndexKey(1)))
	oModel:GetModel( 'CADZA5_GRID' ):SetUniqueLine( { 'ZA5_CC' } )
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruct		:= FWFormStruct(2,"ZA5", {|cCampo|  !(AllTrim(cCampo)+"|" $ "ZA5_CC|ZA5_NMCC|")} )
	Local oStructZA5	:= FWFormStruct(2,"ZA5", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA5_CC|ZA5_NMCC|")} )
	Local oModel		:= FWLoadModel( 'RPFA002' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "CADZA5",oStruct)
	oView:AddGrid("CADZA5_GRID",oStructZA5)

	oView:CreateHorizontalBox("CABEC",20)
	oView:CreateHorizontalBox("GRID",80)
	oView:SetOwnerView( "CADZA5","CABEC")
	oView:SetOwnerView( "CADZA5_GRID","GRID")
	oView:EnableControlBar(.T.)
Return oView