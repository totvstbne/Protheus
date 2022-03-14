#INCLUDE "fwmvcdef.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} RCADSZ1
Campos Planilha
@type function
@version 1.0
@author Saulo Gomes Martins
@since 06/10/2021
//*/
User Function RCADSZ1
	Local oBrowse	:= BrowseDef()
	oBrowse:Activate()
return

Static Function BrowseDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Campos Planilha")
	oBrowse:SetAlias('SZ1')
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( 'RCADSZ1' )
	//Gráfico
	oBrowse:SetAttach(.T.)
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"		ACTION "PesqBrw"				OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RCADSZ1"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RCADSZ1"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RCADSZ1"		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RCADSZ1"		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Cópia"			ACTION "VIEWDEF.RCADSZ1"		OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RCADSZ1"		OPERATION 8 ACCESS 0
Return aRotina

Static Function ModelDef()
	Local oModel as object
	Local oStruSZ1 as object
	oStruSZ1	:= FWFormStruct( 1, 'SZ1',/*bAvalCampo*/,/*lViewUsado*/)

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('YCADSZ1')
	oModel:AddFields( 'SZ1MASTER', /*cOwner*/, oStruSZ1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"Z1_FILIAL", "Z1_CODTV7"})
	oModel:SetDescription( 'Campos Planilha' )
	//oModel:GetModel( '{2:ALIAS}MASTER' ):SetDescription( '' )

	//oModel:AddGrid("SZ1GRID", "SZ1MASTER",oStruSZ1, ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
	//oModel:SetRelation("SZ1GRID",{{"Z1_FILIAL",'xFilial("SZ1")'},{"Z1_COD","Z1_COD"}},SZ1->(IndexKey(1)))
	//oModel:GetModel( 'SZ1GRID' ):SetDescription( '' )
	//oModel:GetModel( 'SZ1GRID' ):SetUniqueLine({"Z1_ITEM"})

	//oModel:InstallEvent("RCADSZ1", /*cOwner*/, RCADSZ1():New())
	oModel:SetSource("RCADSZ1")
Return oModel

Static Function ViewDef()
	Local oModel as object
	Local oStruSZ1 as object
	Local oView as object

	oModel		:= FwLoadModel( 'RCADSZ1' )
	oStruSZ1	:= FWFormStruct( 2, 'SZ1', /*bAvalCampo*/)

	oStruSZ1:RemoveField("Z1_COD")

	//Cria o objeto de View
	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("SZ1MASTER", oStruSZ1 )

	oView:CreateHorizontalBox("CABEC",100)
	oView:SetOwnerView( "SZ1MASTER", "CABEC" )

Return oView
