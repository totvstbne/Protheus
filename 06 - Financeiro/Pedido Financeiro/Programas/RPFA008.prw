#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "topconn.ch"

/*/{Protheus.doc} RPFA008
Tipo do Pedido Financeiro
@author Diogo
@since 09/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA008()
	
	Local  oBrowse
	Private cTabl := 'ZZ'	
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SX5')
	oBrowse:SetDescription('Tipo do Pedido Financeiro')
	oBrowse:DisableDetails()

	oBrowse:SetFilterDefault( "X5_TABELA=='"+cTabl+"'" )

	oBrowse:SetMenuDef( 'RPFA008' ) 
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}	
	
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"			OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.RPFA008"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.RPFA008"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.RPFA008"	OPERATION 4 ACCESS 143
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.RPFA008"	OPERATION 5 ACCESS 144
	ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.RPFA008"	OPERATION 8 ACCESS 0
	
Return aRotina

Static Function ModelDef()
	
	Local oStructSX5 := Nil
	Local oModel := ""
	
	oStructSX5 := FWFormStruct(1,"SX5", {|cCampo| ( AllTrim(upper(cCampo)) + "|" $ "X5_TABELA|X5_CHAVE|X5_DESCRI|")})
	
	oStructSX5:AddTrigger( ;
	"X5_DESCRI"		,;										//[01] Id do campo de origem
	"X5_CHAVE"		,;										//[02] Id do campo de destino
	{ |oModel| .T. }	,;									//[03] Bloco de codigo de validação da execução do gatilho
	{ |oModel| FGatSX5() }  )	                        // [04] Bloco de codigo de execução do gatilho
		
		
	oModel:= MPFormModel():New("YCADMA09",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	
	oModel:AddFields("R09MASTER",/*cOwner*/, oStructSX5 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	
	oModel:SetPrimaryKey({"X5_TABELA"})	
	
	oModel:GetModel("R09MASTER"):GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	oModel:GetModel("R09MASTER"):GetStruct():SetProperty("X5_TABELA",MODEL_FIELD_WHEN,{||.F.})
	oModel:GetModel("R09MASTER"):GetStruct():SetProperty("X5_CHAVE",MODEL_FIELD_WHEN,{||.F.})
	oModel:GetModel("R09MASTER"):GetStruct():SetProperty("X5_TABELA", MODEL_FIELD_INIT,{|| cTabl })
	
Return (oModel)

Static Function ViewDef()

	Local oStructSX5	:= FWFormStruct( 2, 'SX5', {|cCampo| ( AllTrim(upper(cCampo)) + "|" $ "X5_TABELA|X5_CHAVE|X5_DESCRI|")})
	Local oModel		:= FWLoadModel( 'RPFA008' )
	Local oView
		
	oView	:= FWFormView():New()

	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)

	oView:AddField( "R09MASTER",oStructSX5)
	
Return oView

/*/{Protheus.doc} FGatSX5
Gatilho do SX5
@author Diogo
@since 06/09/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function FGatSX5()
	
	Local cChave
	cQuery := " SELECT MAX(X5_CHAVE) + 1 AS CHAVE " 
	cQuery += " FROM "+RetSqlName( 'SX5' ) + " SX5 " 
	cQuery += " WHERE X5_TABELA = '"+cTabl+"' AND LEN(RTRIM(X5_CHAVE)) = 3 "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	TCQuery cquery new alias T04
	
	cChave := STRZERO(T04->CHAVE,3) 
	T04->(dbCloseArea())
	
return cChave