#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RPFA009
//TODO Rotina para aprovação em lote de pedido financeiro
@author Wilton Lima
@since 30/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA009()
	Local cFiltro		:= "1=1" // "ZB5_TIPO=='1'"
	Private cCadastro	:= "Aprovação em Lote." 
	Private oMark 		:= Nil
	Private cCodUse		:= RetCodUsr()
	
	// Instanciamento do classe
	oMark := FWMarkBrowse():New()

	// Definição da tabela a ser utilizada
	oMark:SetAlias('ZA7')

	// Define se utiliza controle de marcação exclusiva do oMark:SetSemaphore(.T.)

	// Define a titulo do browse de marcacao
	oMark:SetDescription(cCadastro)

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'ZA7_OK' )

	// Define a legenda
	oMark:AddLegend( "ZA7_STATUS == 'P' ", "YELLOW"	, "Pendente de Aprovação")
	oMark:AddLegend( "ZA7_STATUS == 'A' ", "GREEN"	, "Aprovado")
	oMark:AddLegend( "ZA7_STATUS == 'R' ", "BLACK"	, "Rejeitado")
	
	// Definição do filtro de aplicacao
	oMark:SetFilterDefault( cFiltro )

	// Desabilita os detalhes
	oMark:DisableDetails()

	// Ativacao da classe
	oMark:Activate()

Return NIL

//Static Function MenuDef()
//	Local aRotina := {}
//	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.COMP025_MVC' OPERATION 2 ACCESS 0
//	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.COMP025_MVC' OPERATION 3 ACCESS 0
//	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.COMP025_MVC' OPERATION 4 ACCESS 0
//	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.COMP025_MVC' OPERATION 5 ACCESS 0
//	ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.COMP025_MVC' OPERATION 8 ACCESS 0
//	ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.COMP025_MVC' OPERATION 9 ACCESS 0
//	ADD OPTION aRotina TITLE 'Processar'  ACTION 'U_COMP25PROC()'      OPERATION 9 ACCESS 0
//Return aRotina
//

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
		
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.RPFA009_MVC' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.COMP025_MVC' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Processar'  ACTION 'U_RPFA009PROC()'      OPERATION 3 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
//Static Function ModelDef()
// Utilizando um model que ja existe em outra aplicacao
//Return FWLoadModel( 'COMP011_MVC' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruct := Nil
	// Modelo de dados que será construído
	Local oModel := Nil
	
	oStruct := FWFormStruct(1,"ZA7", {|cCampo|  !(AllTrim(cCampo)+"|" $ "ZA7_MSBLQL|")} )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('RPFA009M' )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZA7MASTER', Nil/*cOwner*/, oStruct )
	
	// Adicona chave primaria
	oModel:SetPrimaryKey( {"ZA7_FILIAL", "ZA7_CODIGO"} )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Modelo de dados de Aprovação em Lote' )

	// Adiciona a descrição do Componente do Modelo de Dados
	oModel:GetModel( 'ZA7MASTER' ):SetDescription( 'Dados de Aprovação em Lote' )

	// Retorna o Modelo de dados
Return oModel
//-------------------------------------------------------------------

//Static Function ViewDef()
// Utilizando uma View que ja existe em outra aplicacao
//Return FWLoadView( 'COMP011_MVC' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( 'RPFA009_MVC' )
	// Cria a estrutura a ser usada na View
	Local oStruct := FWFormStruct(2, "ZA7", {|cCampo|  !(AllTrim(cCampo) + "|" $ "ZA7_MSBLQL|")} ) // FWFormStruct( 2, 'ZB5' )
	// Interface de visualização construída
	Local oView
	
	// Remove coluna
	oStruct:RemoveField("ZA7_STATUS")	
	
	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado na View
	oView:SetModel( oModel )
	
	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_ZA7', oStruct, 'ZA7MASTER' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZA7', 'TELA' )

	//oView:EnableControlBar(.T.)
	
	// Retorna o objeto de View criado
Return oView

//-------------------------------------------------------------------
User Function RPFA009PROC()
	Local aArea  := GetArea()
	Local cMarca := oMark:Mark()
	Local nCt    := 0
	
	ZB5->( dbGoTop() )
	
	While !ZB5->( EOF() )
		If oMark:IsMark(cMarca)
			nCt++
		EndIf
		ZB5->( dbSkip() )
	End

	ApMsgInfo( 'Foram marcados ' + AllTrim( Str( nCt ) ) + ' registros.' )
	RestArea( aArea )

Return NIL