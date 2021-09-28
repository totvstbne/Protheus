#include "protheus.ch"
#include "FWMBROWSE.CH"
#include "FWMVCDEF.CH"
#include "colors.ch"
#include "topconn.ch"
#include "vkey.ch"

/*/{Protheus.doc} RSVNA009
@author diogo
@since 23/04/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
user function RSVNA009()
	Local oBrowse	
	Local aArea:= getArea()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZB1')
	oBrowse:SetDescription('Planilha Orçamentária')
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( 'RSVNA009' ) 
	oBrowse:Activate()
	RestArea(aArea)
Return

Static Function MenuDef()
	Local aRotina := {}	
	Local aArea:= getArea()
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"			OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.RSVNA009"	OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.RSVNA009"	OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.RSVNA009"	OPERATION 4 ACCESS 143
	//ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.RSVNA009"	OPERATION 5 ACCESS 144
	//ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.RSVNA009"	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Importar"   ACTION "u_RSVNA008"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Executar De/Para"   ACTION "u_fDePara09"		OPERATION 3 ACCESS 0
	RestArea(aArea)
Return aRotina

Static Function ModelDef()
	Local oStructZB1 := Nil
	Local oModel := ""
	oStructZB1 := FWFormStruct(1,"ZB1")
	oModel:= MPFormModel():New("YCADZB1",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("ZB1MASTER",/*cOwner*/, oStructZB1 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey({"ZB1_ANO","ZB1_COMPET"})	
Return (oModel)

Static Function ViewDef()
	Local oStructZB1	:= FWFormStruct( 2, 'ZB1' )	
	Local oModel		:= FWLoadModel( 'RSVNA009' )
	Local oView
	oView	:= FWFormView():New()
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	oView:AddField("ZB1MASTER",oStructZB1)
Return oView

/*/{Protheus.doc} fDePara09
Executar o de-para
@author diogo
@since 23/04/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fDePara09
If msgYesNo("Confirma o de-para de Centro de Custo e Conta Contabil?")
	
	cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("ZB1")+" ZB1 "
	cQuery+= "WHERE ZB1.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZB1_DEPARA = 'N' "
	tcQuery cQuery new Alias QRZB1
	while QRZB1->(!Eof())
		ZB1->(dbGoto(QRZB1->RECNO))
		
		//Busca a informação do centro de custo
		cQuery:= "SELECT CTT_CUSTO FROM "+RetSqlName("CTT")+" CTT "
		cQuery+= "WHERE CTT.D_E_L_E_T_ = ' ' AND "
		cQuery+= "CTT_YDEPAR = '"+ZB1->ZB1_CCUSTO+"' AND "
		cQuery+= "CTT_YDEPAR <> ' ' "
		tcQuery cQuery new Alias QRCTT
		If QRCTT->(!Eof())
			cUpd:= "UPDATE "+RetSqlName("ZB1")+" SET ZB1_CCUSTO = '"+QRCTT->CTT_CUSTO+"', ZB1_DEPARA = 'S'  " 
			cUpd+= "WHERE ZB1_CCUSTO = '"+ZB1->ZB1_CCUSTO+"' AND ZB1_DEPARA = 'N' "
			tcSqlExec(cUpd)
		Endif
		QRCTT->(dbCloseArea())

		//Busca informação da conta contabil
		cQuery:= "SELECT CT1_CONTA FROM "+RetSqlName("CT1")+" CT1 "
		cQuery+= "WHERE CT1.D_E_L_E_T_ = ' ' AND "
		cQuery+= "CT1_YDEPAR = '"+ZB1->ZB1_CONTA+"' AND "
		cQuery+= "CT1_YDEPAR <> ' ' "
		tcQuery cQuery new Alias QRCT1
		If QRCT1->(!Eof())
			cUpd:= "UPDATE "+RetSqlName("ZB1")+" SET ZB1_CONTA = '"+QRCT1->CT1_CONTA+"', ZB1_DEPARA = 'S' "
			cUpd+= "WHERE ZB1_CONTA = '"+ZB1->ZB1_CONTA+"' AND ZB1_DEPARA = 'N' "
			tcSqlExec(cUpd)
		Endif
		QRCT1->(dbCloseArea())
	QRZB1->(dbSkip())
	Enddo
	QRZB1->(dbCloseArea())
	msgInfo("Processo finalizado")
Endif
Return