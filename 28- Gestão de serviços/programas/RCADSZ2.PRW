#INCLUDE "fwmvcdef.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} RCADSZ2
Campos Planilha
@type function
@version 1.0
@author Saulo Gomes Martins
@since 06/10/2021
//*/
User Function RCADSZ2
	Local oBrowse	:= BrowseDef()
	oBrowse:Activate()
return

Static Function BrowseDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Campos Tabela")
	oBrowse:SetAlias('SZ2')
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( 'RCADSZ2' )
	//Gráfico
	oBrowse:SetAttach(.T.)
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"		ACTION "PesqBrw"				OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RCADSZ2"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RCADSZ2"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RCADSZ2"		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RCADSZ2"		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Cópia"			ACTION "VIEWDEF.RCADSZ2"		OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RCADSZ2"		OPERATION 8 ACCESS 0
Return aRotina

Static Function ModelDef()
	Local oModel as object
	Local oStruSZ2 as object
	oStruSZ2	:= FWFormStruct( 1, 'SZ2',/*bAvalCampo*/,/*lViewUsado*/)

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('YCADSZ2')
	oModel:AddFields( 'SZ2MASTER', /*cOwner*/, oStruSZ2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"Z2_FILIAL", "Z2_CAMPO"})
	oModel:SetDescription( 'Campos Planilha' )
	//oModel:GetModel( '{2:ALIAS}MASTER' ):SetDescription( '' )


	oModel:SetSource("RCADSZ2")
Return oModel

Static Function ViewDef()
	Local oModel as object
	Local oStruSZ2 as object
	Local oView as object

	oModel		:= FwLoadModel( 'RCADSZ2' )
	oStruSZ2	:= FWFormStruct( 2, 'SZ2', /*bAvalCampo*/)

	//oStruSZ2:RemoveField("Z2_COD")

	//Cria o objeto de View
	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("SZ2MASTER", oStruSZ2 )

	oView:CreateHorizontalBox("CABEC",100)
	oView:SetOwnerView( "SZ2MASTER", "CABEC" )

Return oView
