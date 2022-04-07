#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RPFA010
//TODO Função para aprovação de pedido de compras em lote
@author Wilton Lima
@since 29/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSVNA010()
	Private nValsel	:= 0
	//Local cParFilDe	:= GetNewPar("MV_ULTDEPR", STOD("19800101"))
	//Local cParFilDe := SuperGetMv(cParametro, lHelp, cPadrao, cFilial)
	//Local cParFilDe := SuperGetMv("MV_RSVILDE", .F., cPadrao, "")
	//Local cParFilAte := SuperGetMv("MV_RSVILATE", .F., cPadrao, "")
//	Local aPars := {}
//	Local lHelp := .F.
//	 
//	aAdd( aPars, {"MV_X_FILDE", "C", "FT: RSVNA010 Filial de",  REPL(" ", GETSX3CACHE("CR_FILIAL", "X3_TAMANHO")) } )
//	aAdd( aPars, {"MV_X_FILAT", "C", "FT: RSVNA010 Filial Ate", REPL("Z", GETSX3CACHE("CR_FILIAL", "X3_TAMANHO")) } )
//	aAdd( aPars, {"MV_X_PEDDE", "C", "FT: RSVNA010 Pedido de",  REPL(" ", GETSX3CACHE("CR_NUM", "X3_TAMANHO")) } )
//	aAdd( aPars, {"MV_X_PEDAT", "C", "FT: RSVNA010 Pedido Ate", REPL("Z", GETSX3CACHE("CR_NUM", "X3_TAMANHO")) } )
//	aAdd( aPars, {"MV_X_EMISD", "D", "FT: RSVNA010 Dt Emissão de", Space(10) } )
//	aAdd( aPars, {"MV_X_EMISA", "D", "FT: RSVNA010 Dt Emissão Ate", Space(10) } )
//	
//	// DTOS	Converte de data para string no formato aaaammdd	DTOS(Data)
//	// STOD	Converte de String para data no formato dd/mm/aaaa	STOD(Data)
//		
//	// Função para criar os parâmetros	 
//	u_zCriaPar( aPars )
//		
//	Private cFilialDe   := IIF( AllTrim(GetMv("MV_X_FILDE")) == "", Space(GETSX3CACHE("CR_FILIAL", "X3_TAMANHO")), GetMv("MV_X_FILDE") ) 
//	Private cFilialAte  := IIF( AllTrim(GetMv("MV_X_FILAT")) == "", Space(GETSX3CACHE("CR_FILIAL", "X3_TAMANHO")), GetMv("MV_X_FILAT") )  
//	Private cPedPCDe    := IIF( AllTrim(GetMv("MV_X_PEDDE")) == "", Space(GETSX3CACHE("CR_NUM", "X3_TAMANHO")), GetMv("MV_X_PEDDE") ) 
//	Private cPedPCAte   := IIF( AllTrim(GetMv("MV_X_PEDAT")) == "", Space(GETSX3CACHE("CR_NUM", "X3_TAMANHO")), GetMv("MV_X_PEDAT") )  
//	Private dEmissaoDe  := GravaData(SuperGetMv("MV_X_EMISD", lHelp, CTOD(""), ""), .T., 5) 
//	Private dEmissaoAte := GravaData(SuperGetMv("MV_X_EMISA", lHelp, CTOD(""), ""), .T., 5)   
//
//
//	DEFINE MSDIALOG oAprovPC TITLE "Parâmetros..." FROM 000,000 TO 300,500 PIXEL
//	@005,005 TO 130,247 OF oAprovPC PIXEL
//	@010,010 SAY "Filial de : " SIZE 040,010 OF oAprovPC PIXEL
//	@010,060 MSGET cFilialDe SIZE 050,010 OF oAprovPC PIXEL F3 "SM0" 
//	@010,130 SAY "Filial até : " SIZE 040,010 OF oAprovPC PIXEL
//	@010,180 MSGET cFilialAte SIZE 050,010 OF oAprovPC PIXEL F3 "SM0"
//	@025,010 SAY "Pedido de : " SIZE 040,010 OF oAprovPC PIXEL 
//	@025,060 MSGET cPedPCDe SIZE 060,010 OF oAprovPC PIXEL F3 "SCR"
//	@025,130 SAY "Pedido até : " SIZE 040,010 OF oAprovPC PIXEL
//	@025,180 MSGET cPedPCAte SIZE 060,010 OF oAprovPC PIXEL F3 "SCR"
//	@040,010 SAY "Dt Emissão de : " SIZE 050,010 OF oAprovPC PIXEL
//	@040,060 MSGET dEmissaoDe SIZE 050,010 OF oAprovPC PIXEL
//	@040,130 SAY "Dt Emissão até : " SIZE 050,010 OF oAprovPC PIXEL
//	@040,180 MSGET dEmissaoAte SIZE 050,010 OF oAprovPC PIXEL
//
//	DEFINE SBUTTON oBtnOk FROM 133,150 TYPE 01 Action fTelaAprov() OF oAprovPC ENABLE
//	DEFINE SBUTTON oBtnCan FROM 133,200 TYPE 02 Action Close(oAprovPC) OF oAprovPC ENABLE
//
//	oAprovPC:Refresh()
//	ACTIVATE MSDIALOG oAprovPC CENTERED	
//Exemplo: 
//GravaData(ExpD1,ExpL1,ExpN1)                               
//
//
//Parâmetros:
//
//ExpD1 (Date)
//       Data a ser convertida                                 
//
//ExpL1  (Boolean)
//    Tipo (Se .T., apresenta data utilizando barra, se .F., não apresenta a barra)
//
//
//ExpN1 (Integeger)
//    Formato do retorno
//
//    Sendo: 
//           1 = ddmmaa                                                  
//           2 = mmddaa                                                 
//           3 = aaddmm                                                 
//           4 = aammdd                                               
//           5 = ddmmaaaa                                             
//           6 = mmddaaaa                                             
//           7 = aaaaddmm                                              
//           8 = aaaammdd
//           	
	
	// Mudado dia 05/06/2019 a pedido do gerardo para retirar a tela de parametros
	fTelaAprov()
Return
/*/{Protheus.doc} fTelaAprov
//TODO Monta a consulta para aprovação em lote
@author Wilton Lima
@since 29/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fTelaAprov()
	Local cFiltro	:= ""
	Local cDescrp	:= ""
	Local aLegenda	:= {}
	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local nx  
	// cFiltro := "CR_FILIAL = '" + xFilial("SCR") + "' .AND. CR_USER ==  '" + RetCodUsr() + "' .AND. CR_STATUS = '02' .AND. CR_TIPO = 'PC' "
	cFiltro := "CR_FILIAL = '" + xFilial("SCR") + "' .AND. CR_USER ==  '" + RetCodUsr() + "' .AND. CR_STATUS = '02' .AND. CR_TIPO = 'PC' "
//	if ( AllTrim(cFilialDe) != "" .AND. (AllTrim(cFilialAte) != "" .AND. AllTrim(cFilialAte) != REPL("Z", LEN(cFilialAte))))
//		cFiltro += " .AND. CR_FILIAL >= " + cFilialDe + " .AND. CR_FILIAL <= " + cFilialAte + " "
//	EndIf
//
//	if ( AllTrim(cPedPCDe) != "" .AND. (AllTrim(cPedPCAte) != "" .AND. AllTrim(cPedPCAte) != REPL("Z", LEN(cPedPCAte))))
//		cFiltro += " .AND. CR_NUM >= " + cPedPCDe + " .AND. CR_NUM <= " + cPedPCAte + " "
//	EndIf
//
//	if ( !Empty(dEmissaoDe) .AND. !Empty(dEmissaoAte) )
//		cFiltro += " .AND. CR_EMISSAO >= " + DTOS( dEmissaoDe ) + " .AND. CR_EMISSAO <= " + DTOS( dEmissaoAte ) + " "
//	EndIf
//
//	PutMV( "MV_X_FILDE", cFilialDe )
//	PutMV( "MV_X_FILAT", cFilialAte )
//	PutMV( "MV_X_PEDDE", cPedPCDe )
//	PutMV( "MV_X_PEDAT", cPedPCAte )
//	PutMV( "MV_X_EMISD", GravaData(dEmissaoDe, .F., 5) )
//	PutMV( "MV_X_EMISA", GravaData(dEmissaoAte, .F., 5) )
	cDescrp	:= 'Aprovação de Pedido de Compras.'
	oDlgAp := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],'Aprovação em Lote',,,.F.,,,,,,.T.,,,.T. )
	aAdd( aLegenda, { "CR_STATUS=='01'", "BR_AZUL" , "Bloqueado (aguardando outros niveis)" })
	aAdd( aLegenda, { "CR_STATUS=='02'", "DISABLE" , "Aguardando Liberacao do usuario"      })
	aAdd( aLegenda, { "CR_STATUS=='03'", "ENABLE"  , "Documento Liberado pelo usuario"      })
	aAdd( aLegenda, { "CR_STATUS=='04'", "BR_PRETO", "Documento Bloqueado pelo usuario"     })
	aAdd( aLegenda, { "CR_STATUS=='05'", "BR_CINZA", "Documento Liberado por outro usuario" })
	aAdd( aLegenda, { "CR_STATUS=='06'", "BR_CANCEL","Documento Rejeitado pelo usuário"     })
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgAp, .F., .T. )
	oFWLayer:AddLine( 'TOP1', 90, .F. )
	oFWLayer:AddLine( 'TOP2', 10, .F. )
	oPanelTop1 := oFWLayer:getLinePanel( 'TOP1' )
	oPanelTop2 := oFWLayer:getLinePanel( 'TOP2' )
	cMsg  := '<font color=red size="5"><b>TOTAL R$ ' + transform(nValsel, "@E 9,999,999.99") + ' </b> </font>'
	oTSay := TSay():Create(oPanelTop2, { || cMsg }, 01,01,,,,,,.T.,,,900,10,,,,,,.T.)
	aRotina	:= {}
	aadd(aRotina, { "Aprovar",  "U_fAprPC",    0, 4, 0, NIL })
	aadd(aRotina, { "Rejeitar", "U_fRejPC",    0, 4, 0, NIL })
	aadd(aRotina, { "Marcar",   "u_fMarcaTPC", 0, 4, 0, NIL })
	//aadd(aRotina, { "Visualizar Pedido Financeiro", "u_fVisuPC()",0,4,0,NIL})
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('SCR')
	For nx := 1 to len(aLegenda)
		oMark:AddLegend(aLegenda[nx][1], aLegenda[nx][2], aLegenda[nx][3])
	Next nx
	oMark:SetSemaphore(.F.)
	oMark:SetFieldMark('CR_YOK')
	//oMark:SetAllMark( { || nil } )
	oMark:SetAllMark( { || u_fMarkPCTOk() } )
	oMark:SetAfterMark( { || fSelectPC() } )
	oMark:SetDescription(cDescrp)
	oMark:SetUseFilter(.T.)
	oMark:SetFilterDefault(cFiltro)
	oMark:Activate(oPanelTop1)
	oDlgAp:Activate(,,,.T.)	 
	//oAprovPC:End()
Return
/*/{Protheus.doc} fAprPC
//TODO Aprovação em lote do pedido de compras
@author Wilton Lima
@since 29/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fAprPC()
	Local aArea  := getArea()
	Local cLtAp  := ""
	Local cQuery := ""
	cQuery := " SELECT R_E_C_N_O_ RECNO  "
	cQuery += " FROM " + RetSqlName("SCR") + " SCR "
	cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery += " CR_YOK = '" + oMark:Mark() + "' "
	cQuery += " ORDER BY R_E_C_N_O_ "
	TcQuery cQuery new Alias TQCR
	If TQCR->(Eof())
		TQCR->(dbCloseArea())
		MsgAlert("Não há itens selecionados", "Atenção!")	
		Return
	Endif
	//cLtAp := GetSXENum("ZA7", "ZA7_YLOTE", "ZA71")
	//ConfirmSx8()
	while TQCR->(!Eof())
		SCR->(dbGoto(TQCR->RECNO))
		// ZA7->(dbSetOrder(3))
		// ZA7->(dbSeek(xFilial("ZA7") + AllTrim(SCR->CR_NUM)))
		//Processa({||A097ProcLib(SCR->(Recno()),2,,,,"Aprovado em Lote por " + AllTrim(cUserName))}, "Aprovando o Pedido de Compras. " + SCR->CR_NUM)
		/*Alterado por Alana Oliveira em 21.12.21 - Liberação por execauto*/
		Processa({||U_MyExec094()}, "Aprovando o Pedido de Compras. " + SCR->CR_NUM)
		
		//Reclock("SCR",.F.)
		//	SCR->CR_DATALIB	:= dDataBase
		//MsUnlock()
		//		ZA7->(dbSetOrder(3))
		//		ZA7->(dbSeek(xFilial("ZA7") + AllTrim(SCR->CR_NUM)))
		//		
		//		Reclock("ZA7",.F.)
		//			ZA7->ZA7_YLOTE := cLtAp
		//		MsUnlock()
		TQCR->(dbSkip())
	Enddo
	TQCR->(dbCloseArea())
	//Seta para garantir que não será utilizada a marca
	cUpd := "UPDATE " + RetSqlName("SCR") + " SET CR_YOK = ' ' WHERE CR_YOK = '" + oMark:Mark() + "' AND CR_FILIAL = '" + xFilial("SCR") + "' "
	tcSqlExec(cUpd)
	TcRefresh(RetSqlName("SCR"))
	MsgInfo("Documentos selecionados aprovados","Sucesso")
	nValsel:= 0
	oMark:refresh(.T.)
	oMark:oBrowse:refresh()
	RestArea(aArea)
Return
/*/{Protheus.doc} fRejPC
Rejeitar Pedido de Compras
@author Wilton
@since 29/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fRejPC()
	Local aArea  := getArea()
	Local cQuery := "" 
	cQuery := "SELECT R_E_C_N_O_ RECNO  "
	cQuery += "FROM " + RetSqlName("SCR") + " SCR "
	cQuery += "WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery += "CR_YOK = '" + oMark:Mark() + "' "
	cQuery += "ORDER BY R_E_C_N_O_ "
	TcQuery cQuery new Alias TQCR
	If TQCR->(Eof())
		TQCR->(dbCloseArea())
		MsgAlert("Não há itens selecionados", "Atenção!")	
		Return
	Endif
	If !(msgYesNo("Confirma a rejeição do Pedido de Compras?","Rejeição em Lote"))
		Return
	Endif
	//	cLtAp := GetSXENum("ZA7", "ZA7_YLOTE", "ZA71")
	//	ConfirmSx8()
	while TQCR->(!Eof())
		DbSelectArea("SCR")
		SCR->(dbGoto(TQCR->RECNO))
		ZA7->(dbSetOrder(3))
		ZA7->(dbSeek(xFilial("ZA7") + AllTrim(SCR->CR_NUM)))
		//Processa( { ||u_fRejeiPC( .T., TQCR->RECNO ) }, "Rejeitando o Pedido de Compras " + SCR->CR_NUM )
		// Alterado por Alana Olivera em 21.12.21 -> Rejeita através de execauto
		Processa( { ||u_RExec094()}, "Rejeitando o Pedido de Compras " + SCR->CR_NUM )
//		Reclock("SCR",.F.)
//		SCR->CR_YLOTE := cLtAp
//		MsUnlock()
		//		ZA7->(dbSetOrder(3))
		//		ZA7->(dbSeek(xFilial("ZA7") + AllTrim(SCR->CR_NUM)))
		//
		//		Reclock("ZA7",.F.)
		//			ZA7->ZA7_YLOTE := cLtAp
		//		MsUnlock()
		TQCR->(dbSkip())
	Enddo
	
	TQCR->(dbCloseArea())
	//Seta para garantir que não será utilizada a marca
	cUpd := "UPDATE " + RetSqlName("SCR") + " SET CR_YOK = ' ' WHERE CR_YOK = '" + oMark:Mark() + "' AND CR_FILIAL = '" + xFilial("SCR") + "' " 
	tcSqlExec(cUpd)
	TcRefresh(RetSqlName("SCR"))
	msgInfo("Documentos selecionados rejeitados","Sucesso")
	RestArea(aArea)
Return
/*/{Protheus.doc} fMarcaTudoPC
Marcação de todos os registros
@author Wilton
@since 29/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fMarcaTPC()
	Local lMarc  := .F.
	Local cQuery := "" 
	//Verifica se está marcado
	cQuery := " SELECT TOP 1 CR_NUM FROM " + RetSqlName("SCR") + " SCR "
	cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery += " CR_FILIAL = '" + xFilial("SCR") + "' AND "
	cQuery += " CR_YOK =  '" + oMark:Mark() + "' AND "
	cQuery += " CR_FILIAL= '" + xFilial("SCR") + "' AND CR_USER = '" + RetCodUsr() + "' AND CR_STATUS = '02' AND CR_TIPO = 'PC' "
	tcQuery cQuery new Alias QRSCR
	//Tem registros
	If QRSCR->(!Eof())
		lMarc := .T.
	Endif
	QRSCR->(dbCloseArea())
	If lMarc //Desmarca registros
		cUpd := "UPDATE " + RetSqlName("SCR") + " SET CR_YOK = ' ' WHERE CR_YOK  = '" + oMark:Mark() + "' AND CR_FILIAL = '" + xFilial("SCR") + "' "
	Else
		cUpd := "UPDATE " + RetSqlName("SCR") + " SET CR_YOK = '" + oMark:Mark() + "' WHERE CR_YOK <> '" + oMark:Mark() + "' AND CR_FILIAL = '" + xFilial("SCR") + "' "
	Endif
	cUpd += "AND CR_FILIAL= '" + xFilial("SCR") + "' AND CR_USER = '" + RetCodUsr() + "' AND CR_STATUS = '02' AND CR_TIPO = 'PC' "
	tcSqlExec(cUpd)
	TcRefresh(RetSqlName("SCR"))
	cQuery := " SELECT SUM(CR_TOTAL) TOTAL FROM " + RetSqlName("SCR") + " SCR "
	cQuery += " WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery += " CR_FILIAL = '" + xFilial("SCR") + "' AND "
	cQuery += " CR_USER =  '" + RetCodUsr() + "' AND CR_STATUS = '02' AND CR_TIPO = 'PC' AND "
	cQuery += " CR_YOK = '" + oMark:Mark() + "' "
	tcQuery cQuery new Alias QRSCR
	nValsel := QRSCR->TOTAL //Total selecionado
	QRSCR->(dbCloseArea())
	cMsg  := '<font color=red size="5"><b>TOTAL R$ ' + transform(nValsel, "@E 9,999,999.99") + ' </b> </font>'
	oTSay := TSay():Create(oPanelTop2,{|| cMsg },01,01,,,,,,.T.,,,900,10,,,,,,.T.)
	oMark:refresh(.T.)
	oMark:oBrowse:refresh()
	oDlgAp:refresh()
Return
/*/{Protheus.doc} fSelectPC
Pós marcação
@author Wilton
@since 29/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fSelectPC()
	If oMark:IsMark(oMark:Mark())
		nValsel += SCR->CR_TOTAL
	Else
		nValsel -= SCR->CR_TOTAL
	Endif
	cMsg  := '<font color=red size="5"><b>TOTAL R$ ' + transform(nValsel,"@E 9,999,999.99") + ' </b> </font>'
	oTSay := TSay():Create(oPanelTop2,{|| cMsg },01,01,,,,,,.T.,,,900,10,,,,,,.T.)
	oMark:oBrowse:refresh()
	oDlgAp:refresh()
Return
 
/*/{Protheus.doc} zCriaPar
Função para criação de parâmetros (SX6)
@type function
@author Wilton Lima
@since 04/06/2019
@version 1.0
    @param aPars, Array, Array com os parâmetros do sistema
    @example
    u_zCriaPar(aParametros)
    @see https://terminaldeinformacao.com
    @obs Abaixo a estrutura do array:
        [01] - Parâmetro (ex.: "MV_X_TST")
        [02] - Tipo (ex.: "C")
        [03] - Descrição (ex.: "Parâmetro Teste")
        [04] - Conteúdo (ex.: "123;456;789")
/*/
 
User Function zCriaPar(aPars)
    Local nAtual	 := 0
    Local aArea      := GetArea()
    Local aAreaX6    := SX6->(GetArea())
    Default aPars    := {}
     
    DbSelectArea("SX6")
    SX6->(DbGoTop())
     
    //Percorrendo os parâmetros e gerando os registros
    For nAtual := 1 To Len(aPars)
        //Se não conseguir posicionar no parâmetro cria
        If !(SX6->(DbSeek(xFilial("SX6") + aPars[nAtual][1])))
            RecLock("SX6",.T.)
                //Geral
                X6_VAR        :=    aPars[nAtual][1]
                X6_TIPO       :=    aPars[nAtual][2]
                X6_PROPRI     :=    "U"
                //Descrição
                X6_DESCRIC    :=    aPars[nAtual][3]
                X6_DSCSPA     :=    aPars[nAtual][3]
                X6_DSCENG     :=    aPars[nAtual][3]
                //Conteúdo
                X6_CONTEUD    :=    aPars[nAtual][4]
                X6_CONTSPA    :=    aPars[nAtual][4]
                X6_CONTENG    :=    aPars[nAtual][4]
            SX6->(MsUnlock())
        EndIf
    Next
     
    RestArea(aAreaX6)
    RestArea(aArea)
Return
/*/{Protheus.doc} fRejeiPC
Rejeição do Pedido Compras
@author Diogo
@since 18/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fRejeiPC(lProcLote, cRECNO)
	Local lRet		:= .T.
	Local aRetOpc 	:= {}
	Local aPergs  	:= {}
	Local cDescMot	:= ""
	DbSelectArea("SCR")
	SCR->(dbGoto(cRECNO))
	If SCR->CR_TIPO = "06"
		Return
	Endif
	If SCR->CR_TIPO <> "PC"
		MsgAlert("Rejeição apenas para Pedidos de Compras!", "Atenção!")
		Return
	Endif
	
	If SCR->CR_STATUS <> "02" // Pendente de aprovação
		lRet := A097LibVal("MATA094")
	Endif
	
	DbSelectArea("SC7")
    SC7->(dbSetOrder(1))
    		
	If (!SC7->(dbSeek(xFilial("SC7") + AllTrim(SCR->CR_NUM))))
		MsgAlert("Pedido de Compras não localizado", "Atenção!")
		Return
	Endif
	If (!lRet)
		Return
	Endif
	If (lRet)
		If !lProcLote
			If !(msgYesNo("Confirma a rejeição do Pedido de Compras?"))
				Return
			Endif
			
			aAdd( aPergs, { 1, "Motivo Rejeição", space(100), "@!",'.T.','','.T.',100,.T.} )
			
			If ParamBox(aPergs, "Motivo", aRetOpc,,,,,,,"_RFA01A",.F.,.F.)
				cDescMot := aRetOpc[1]
			Endif
		Else
			cDescMot := "Rejeição em lote"
		Endif
		Reclock("SCR", .F.)
			SCR->CR_STATUS	:= "06"
			SCR->CR_DATALIB	:= date()
			SCR->CR_USERLIB	:= retcodusr()
		msUnlock()
		If (!lProcLote)
			msgInfo("Pedido de Compras rejeitado com sucesso", "Rejeição.")
		Endif
	Endif
Return
/*Execauto para liberação de documentos*/
User Function MyExec094()
 
    Local oModel094 := Nil      //-- Objeto que receberá o modelo da MATA094
    Local cNum      := SCR->CR_NUM //-- Recebe o número do documento a ser avaliado
    Local cTipo     := SCR->CR_TIPO  //-- Recebe o tipo do documento a ser avaliado
    Local cAprov    := RetCodUsr() //-- Recebe o código do aprovador do documento
    Local nLenSCR   := 0        //-- Controle de tamanho de campo do documento
    Local lOk       := .T.      //-- Controle de validação e commit
    Local aErro     := {}       //-- Recebe msg de erro de processamento
	Local aArea     := getArea()
    nLenSCR := TamSX3("CR_NUM")[1] //-- Obtem tamanho do campo CR_NUM
    DbSelectArea("SCR")
    SCR->(DbSetOrder(2)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
	DbSelectArea("SC7")
    SC7->(dbSetOrder(1))
    		
	SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
 
    If SCR->(DbSeek(xFilial("SCR") + cTipo + Padr(cNum, nLenSCR) + cAprov))
 
        //-- Códigos de operações possíveis:
        //--    "001" // Liberado
        //--    "002" // Estornar
        //--    "003" // Superior
        //--    "004" // Transferir Superior
        //--    "005" // Rejeitado
        //--    "006" // Bloqueio
        //--    "007" // Visualizacao
 
        //-- Seleciona a operação de aprovação de documentos
        A094SetOp('001')
 
        //-- Carrega o modelo de dados e seleciona a operação de aprovação (UPDATE)
        oModel094 := FWLoadModel('MATA094')
        oModel094:SetOperation( MODEL_OPERATION_UPDATE )
        oModel094:Activate()
 
        //-- Valida o formulário
        lOk := oModel094:VldData()
 
        If lOk
            //-- Se validou, grava o formulário
            lOk := oModel094:CommitData()
        EndIf
 
        //-- Avalia erros
        If !lOk
            //-- Busca o Erro do Modelo de Dados
            aErro := oModel094:GetErrorMessage()
                  
            //-- Monta o Texto que será mostrado na tela
            AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
            AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
            AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
            AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
            AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
            AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
            AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
            AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
            AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
 
            //-- Mostra a mensagem de Erro
            MostraErro()
	
        EndIf
 
        //-- Desativa o modelo de dados
        oModel094:DeActivate()
 
    Else
        MsgInfo("Documento não encontrado!", "MyExec094")
    EndIf
	RestArea(aArea) 
 
Return Nil
/* Execauto para rejeição de documento*/
User Function RExec094()   
    Local oModel094 := Nil                    //-- Objeto que receberá o modelo da MATA094
    Local cNum      := SCR->CR_NUM            //-- Recebe o número do documento a ser avaliado
    Local cTipo     := SCR->CR_TIPO          //-- Recebe o tipo do documento a ser avaliado
    Local cAprov    := RetCodUsr()           //-- Recebe o código do aprovador do documento
    Local cJustif   := "Rejeição em lote"    //-- Recebe a justificativa para rejeição
    Local nLenSCR   := 0                      //-- Controle de tamanho de campo do documento
    Local lOk       := .T.                    //-- Controle de validação e commit
    Local aErro     := {}                     //-- Recebe msg de erro de processamento
	Local aArea     := getArea()
    nLenSCR := TamSX3("CR_NUM")[1] //-- Obtem tamanho do campo CR_NUM
    DbSelectArea("SCR")
    SCR->(DbSetOrder(2)) //-- CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
 	DbSelectArea("SC7")
    SC7->(dbSetOrder(1))
    		
	SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
	
    If SCR->(DbSeek(xFilial("SCR") + cTipo + Padr(cNum, nLenSCR) + cAprov))
 
        //-- Códigos de operações possíveis:
        //-- "001" // Liberado
        //-- "002" // Estornar
        //-- "003" // Superior
        //-- "004" // Transferir Superior
        //-- "005" // Rejeitado
        //-- "006" // Bloqueio
        //-- "007" // Visualizacao
 
        //-- Seleciona a operação de rejeição de documentos
        A094SetOp('005')
 
        //-- Carrega o modelo de dados e seleciona a operação de aprovação (UPDATE)
        oModel094 := FWLoadModel('MATA094')
        oModel094:SetOperation( MODEL_OPERATION_UPDATE )
        oModel094:Activate()
 
        //-- Preenche justificativa
        oModel094:GetModel('FieldSCR'):SetValue('CR_OBS', cJustif)
 
        //-- Valida o formulário
        lOk := oModel094:VldData()
 
        If lOk
            //-- Se validou, grava o formulário
            lOk := oModel094:CommitData()
        EndIf
 
        //-- Avalia erros
        If !lOk
            //-- Busca o Erro do Modelo de Dados
            aErro := oModel094:GetErrorMessage()
 
            //-- Monta o Texto que será mostrado na tela
            AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
            AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
            AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
            AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
            AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
            AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
            AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
            AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
            AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
 
            //-- Mostra a mensagem de Erro
            If aErro[05] <> "PCOVLDLAN "
            	MostraErro()
            Endif
        EndIf
 
        //-- Desativa o modelo de dados
        oModel094:DeActivate()
		
    Else
        MsgInfo("Documento não encontrado!", "MyExec094")
    EndIf
	RestArea(aArea)
Return Nil
User Function fMarkPCTOk
	//oMark:AllMark()
	nValsel:= 0
	cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SCR")+" SCR "
	cQuery+= "WHERE SCR.D_E_L_E_T_ = ' ' AND "
	cQuery+= "CR_FILIAL = '"+xFilial("SCR")+"' AND "
	cQuery+="CR_FILIAL= '"+xFilial("SCR")+"' AND CR_USER =  '"+RetCodUsr()+"' AND CR_STATUS = '02' AND  "
	cQuery+="CR_TIPO = 'PC' "
	tcQuery cQuery new Alias QTOT
	while QTOT->(!eof())
		SCR->(dbGoto(QTOT->RECNO))
		Reclock("SCR",.F.)
		If SCR->CR_YOK = oMark:Mark()
			SCR->CR_YOK:= space(2)
		Else
			SCR->CR_YOK:= oMark:Mark()
			nValsel+= SCR->CR_TOTAL
		Endif
		MsUnlock()
		QTOT->(dbSkip())
	enddo
	QTOT->(dbCloseArea())
	cMsg:= '<font color=red size="5"><b>TOTAL R$ '+transform(nValsel,"@E 9,999,999.99")+' </b> </font>'
	oTSay:= TSay():Create(oPanelTop2,{|| cMsg },01,01,,,,,,.T.,,,900,10,,,,,,.T.)
	oMark:oBrowse:refresh()
	oMark:Refresh(.T.)
	oDlgAp:refresh()
Return
