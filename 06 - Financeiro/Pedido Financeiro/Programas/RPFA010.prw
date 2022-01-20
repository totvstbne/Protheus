#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
//Static nValsel:= 0
/*/{Protheus.doc} function_method_class_name
Aprovação em Lote
@author author
@since 07/02/2019
@version version
@example
(examples)
@see (links_or_references)
/*/
user function RPFA010(nTipo)
	Local aArea     := getArea()
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local cFiltro	:= ""
	Local cDescrp	:= ""
	Local aLegenda	:= {}
	Local nX
	Private nValsel	:= 0
	If nTipo == 1 //Aprovação Despesas Fixas
		cFiltro := "CR_FILIAL= '"+xFilial("SCR")+"' .And. CR_USER =  '"+RetCodUsr()+"' .AND. CR_STATUS = '02' .AND. CR_TIPO = 'PC' .AND. CR_YTIPOPC = 'PF' .AND. CR_YDESPFX = 'S' "
		cDescrp	:= 'Aprovação Despesas Fixas'
	Else //Aprovação em Lote PF
		cFiltro := "CR_FILIAL= '"+xFilial("SCR")+"' .And. CR_USER =  '"+RetCodUsr()+"' .AND. CR_STATUS = '02' .AND. CR_TIPO = 'PC' .AND. CR_YTIPOPC = 'PF' "
		cDescrp	:= 'Aprovação em Lote'
	Endif

	oDlgAp:= MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],'Aprovação em Lote',,,.F.,,,,,,.T.,,,.T. )

	aAdd(aLegenda, { "CR_STATUS=='01'", "BR_AZUL" , "Bloqueado (aguardando outros niveis)" })
	aAdd(aLegenda, { "CR_STATUS=='02'", "DISABLE" , "Aguardando Liberacao do usuario" })
	aAdd(aLegenda, { "CR_STATUS=='03'", "ENABLE"  , "Documento Liberado pelo usuario" })
	aAdd(aLegenda, { "CR_STATUS=='04'", "BR_PRETO", "Documento Bloqueado pelo usuario" })
	aAdd(aLegenda, { "CR_STATUS=='05'", "BR_CINZA", "Documento Liberado por outro usuario"})
	aAdd(aLegenda, { "CR_STATUS=='06'", "BR_CANCEL","Documento Rejeitado pelo usuário" })

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgAp, .F., .T. )
	oFWLayer:AddLine( 'TOP1', 90, .F. )
	oFWLayer:AddLine( 'TOP2', 10, .F. )
	oPanelTop1 := oFWLayer:getLinePanel( 'TOP1' )
	oPanelTop2 := oFWLayer:getLinePanel( 'TOP2' )

	cMsg:= '<font color=red size="5"><b>TOTAL R$ '+transform(nValsel,"@E 9,999,999.99")+' </b> </font>'
	oTSay	:= TSay():Create(oPanelTop2,{|| cMsg },01,01,,,,,,.T.,,,900,10,,,,,,.T.)

	aRotina	:= {}
	aadd(aRotina, {"Aprovar","U_fAprovSCR",0,4,0,NIL})
	aadd(aRotina, {"Rejeitar","U_fRejSCR",0,4,0,NIL})
	aadd(aRotina, {"Marcar","u_fMarcaTudo",0,4,0,NIL})
	aadd(aRotina, { "Visualizar Pedido Financeiro","u_fVisuPF()",0,4,0,NIL})
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('SCR')
	For nx := 1 to len(aLegenda)
		oMark:AddLegend(aLegenda[nx][1], aLegenda[nx][2], aLegenda[nx][3])
	Next nx
	oMark:SetSemaphore(.T.)
	oMark:SetFieldMark('CR_YOK')
	oMark:SetAllMark( { || nil } )
	oMark:SetAfterMark( { || fSelectSCR() } )
	oMark:SetDescription(cDescrp)
	oMark:SetUseFilter(.T.)
	oMark:SetFilterDefault(cFiltro)
	oMark:Activate(oPanelTop1)
	oDlgAp:Activate(,,,.T.)
	RestArea(aArea)
Return

User Function fAprovSCR
	Local aArea:= getArea()
	Local cLtAp:= ""
	cQuery:= "SELECT R_E_C_N_O_ RECNO  "
	cQuery+= "FROM "+RetSqlName("SCR")+" SCR "
	cQuery+= "WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery+= "CR_YOK = '"+oMark:Mark()+"' "
	cQuery+= "ORDER BY R_E_C_N_O_ "
	TcQuery cQuery new Alias TQCR

	If TQCR->(Eof())
		TQCR->(dbCloseArea())
		Alert("Não há itens selecionados")
		Return
	Endif

	cLtAp	:= GetSXENum("ZA7","ZA7_YLOTE","ZA71")
	ConfirmSx8()

	while TQCR->(!Eof())
		SCR->(dbGoto(TQCR->RECNO))
		// ZA7->(dbSetOrder(3))
		// ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM)))

		Processa({||A097ProcLib(SCR->(Recno()),2,,,,"Aprovado em Lote por "+alltrim(cUserName))}, "Aprovando o Pedido Financeiro "+SCR->CR_NUM)
		
		Reclock("SCR",.F.)
		SCR->CR_YLOTE 	:= cLtAp
		SCR->CR_DATALIB	:= dDataBase
		MsUnlock()

		ZA7->(dbSetOrder(3))
		If ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM)))
			Reclock("ZA7",.F.)
			ZA7->ZA7_YLOTE := cLtAp
			MsUnlock()
		EndIf
		TQCR->(dbSkip())
	Enddo
	TQCR->(dbCloseArea())

	//Seta para garantir que não será utilizada a marca
	cUpd:="UPDATE "+RetSqlName("SCR")+" SET CR_YOK = ' ' WHERE CR_YOK = '"+oMark:Mark()+"' AND CR_FILIAL = '"+xFilial("SCR")+"' "
	tcSqlExec(cUpd)
	TcRefresh(RetSqlName("SCR"))



	msgInfo("Documentos selecionados aprovados")
	RestArea(aArea)
Return

/*/{Protheus.doc} fRejSCR
Rejeitar Pedido Financeiro
@author Diogo
@since 07/02/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fRejSCR
	Local aArea := getArea()
	Local cQuery := ""

	cQuery := " SELECT R_E_C_N_O_ RECNO  "
	cQuery += " FROM " + RetSqlName("SCR") + " SCR "
	cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery += " CR_YOK = '" + oMark:Mark() + "' "
	cQuery += " ORDER BY R_E_C_N_O_ "

	TcQuery cQuery new Alias TQCR

	If TQCR->(Eof())
		TQCR->(dbCloseArea())
		MsgAlert("Não há itens selecionados")
		Return
	Endif

	cLtAp := GetSXENum("ZA7","ZA7_YLOTE","ZA71")
	ConfirmSx8()

	while TQCR->(!Eof())
		SCR->(dbGoto(TQCR->RECNO))
		ZA7->(dbSetOrder(3))
		ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM)))
		Processa({||u_fRejeiPF(.T.)}, "Rejeitando o Pedido Financeiro "+SCR->CR_NUM)

		Reclock("SCR",.F.)
		SCR->CR_YLOTE := cLtAp
		MsUnlock()
		ZA7->(dbSetOrder(3))
		ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM)))
		Reclock("ZA7",.F.)
		ZA7->ZA7_YLOTE := cLtAp
		MsUnlock()

		TQCR->(dbSkip())
	Enddo
	TQCR->(dbCloseArea())

	//Seta para garantir que não será utilizada a marca
	cUpd:="UPDATE "+RetSqlName("SCR")+" SET CR_YOK = ' ' WHERE CR_YOK = '"+oMark:Mark()+"' AND CR_FILIAL = '"+xFilial("SCR")+"' "
	tcSqlExec(cUpd)
	TcRefresh(RetSqlName("SCR"))

	msgInfo("Documentos selecionados rejeitados")
	RestArea(aArea)

Return
/*/{Protheus.doc} fMarcaTudo
Marcação de todos os registros
@author diogo
@since 14/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fMarcaTudo()
	Local lMarc:= .F.

	//Verifica se está marcado
	cQuery:= "SELECT TOP 1 CR_NUM FROM "+RetSqlName("SCR")+" SCR "
	cQuery+= "WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery+= "CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQuery+= "CR_YOK =  '"+oMark:Mark()+"' AND "
	cQuery+="CR_FILIAL= '"+xFilial("SCR")+"' AND CR_USER =  '"+RetCodUsr()+"' AND CR_STATUS = '02' AND CR_YTIPOPC = 'PF' "
	tcQuery cQuery new Alias QRSCR
	//Tem registros
	If QRSCR->(!Eof())
		lMarc:= .T.
	Endif
	QRSCR->(dbCloseArea())

	If lMarc //Desmarca registros
		cUpd:="UPDATE "+RetSqlName("SCR")+" SET CR_YOK = ' ' WHERE CR_YOK  = '"+oMark:Mark()+"' AND CR_FILIAL = '"+xFilial("SCR")+"' "
	Else
		cUpd:="UPDATE "+RetSqlName("SCR")+" SET CR_YOK = '"+oMark:Mark()+"' WHERE CR_YOK <> '"+oMark:Mark()+"' AND CR_FILIAL = '"+xFilial("SCR")+"' "
	Endif
	cUpd+="AND CR_FILIAL= '"+xFilial("SCR")+"' AND CR_USER =  '"+RetCodUsr()+"' AND CR_STATUS = '02' AND CR_YTIPOPC = 'PF' "
	tcSqlExec(cUpd)
	TcRefresh(RetSqlName("SCR"))

	cQuery:= "SELECT SUM(CR_TOTAL) TOTAL FROM "+RetSqlName("SCR")+" SCR "
	cQuery+= "WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery+= "CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQuery+= "CR_USER =  '"+RetCodUsr()+"' AND CR_STATUS = '02' AND CR_YTIPOPC = 'PF' AND "
	cQuery+= "CR_YOK = '"+oMark:Mark()+"' "
	tcQuery cQuery new Alias QRSCR
	nValsel:= QRSCR->TOTAL //Total selecionado
	QRSCR->(dbCloseArea())

	cMsg:= '<font color=red size="5"><b>TOTAL R$ '+transform(nValsel,"@E 9,999,999.99")+' </b> </font>'
	oTSay	:= TSay():Create(oPanelTop2,{|| cMsg },01,01,,,,,,.T.,,,900,10,,,,,,.T.)

	oMark:refresh(.T.)
	oMark:oBrowse:refresh()
	oDlgAp:refresh()
Return

/*/{Protheus.doc} fSelectSCR
Pós marcação
@author diogo
@since 14/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fSelectSCR
	If oMark:IsMark(oMark:Mark())
		nValsel+= SCR->CR_TOTAL
	Else
		nValsel-= SCR->CR_TOTAL
	Endif
	cMsg:= '<font color=red size="5"><b>TOTAL R$ '+transform(nValsel,"@E 9,999,999.99")+' </b> </font>'
	oTSay:= TSay():Create(oPanelTop2,{|| cMsg },01,01,,,,,,.T.,,,900,10,,,,,,.T.)
	oMark:oBrowse:refresh()
	oDlgAp:refresh()
Return
