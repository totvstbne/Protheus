#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"

/*/{Protheus.doc} M460FIM
Gravação do centro de custo do pedido para o Financeiro
@author Diogo
@since 11/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function M460FIM()
	Local aaRea:= GetArea() 
	Local cCentro:= ""
	Local cQuery := ""
	Local aRecSE1 := ""
	Local cAlsQuery := ""
	cChave := xFilial("SF2")+SF2->F2_DOC+SF2->F2_SERIE
	cChSE1 := xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC
	dbSelectArea("SD2")
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SD2->(dbSetOrder(3))
	
	cCentro:= SC5->C5_YCC
	While !eof() .and. cChave == xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE
		DbSelectArea("SC6")
		SC6->(dbSetOrder(1))
		If (SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)))
			cCentro := SC5->C5_YCC
			If RecLock("SD2",.F.)
				SD2->D2_CCUSTO  := cCentro
				SD2->(MsUnlock())         
			EndIf			
		EndIf	
		DbSelectArea("SD2")
		SD2->(DbSkip())
	EndDo

	DbSelectArea("SE1")
	SE1->(dbSetOrder(1)) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	SE1->(dbSeek(cChSE1))
	while SE1->(!Eof()) .and. cChSE1 == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM)
		SE1->(RecLock("SE1"), .F.)
			SE1->E1_CCUSTO := cCentro
			SE1->E1_MDCONTR:= SC5->C5_MDCONTR
			SE1->E1_MDPLANI:= SC5->C5_MDPLANI
			SE1->E1_MDCRON := SC5->C5_MDNUMED
			SE1->E1_YCOMPET:= SC5->C5_YCOMPET
		SE1->(MsUnLock()) 		
		SE1->(dbSkip())
	Enddo
	
	
	//EXCLUSÃO DOS TITULOS PROVISORIOS
//	cQuery += "SELECT C5_NUM, R_E_C_N_O_ AS RECNO FROM " + RETSQLNAME("SC5") + " 
//	cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NOTA = '"+SF2->F2_DOC+"' AND C5_SERIE = '"+SF2->F2_SERIE+"'"
//	cAlsQuery := MpSysOpenQuery(cQuery)
//	if !(cAlsQuery)->(EOF())
//		aRecSE1 := fTitProv((cAlsQuery)->RECNO)
//		for nI := 1 to Len(aRecSE1)
//			SE1->(dbGoTop())
//			SE1->(dbGoTo(aRecSE1[nI]))	
//			SE1->(RecLock("SE1",.F.))
//			SE1->(DbDelete())
//			SE1->(MsUnLock())
//		next
//	endIF
	RestArea(aaRea)
Return

static function fTitProv(cRecSC5)
	Local cQuery := ""
	Local aRecno := {}
	dbSelectArea("SC5")
	SC5->(dbGoTo(cRecSC5))
	
	cQuery += "SELECT SE1.R_E_C_N_O_ AS RECNO "
	cQuery += "FROM "+RETSQLNAME("SC5")+" SC5 " 
	cQuery += "INNER JOIN "+RETSQLNAME("CXN")+" CXN ON "
	cQuery += "CXN.CXN_FILIAL = SC5.C5_FILIAL AND C5_MDCONTR = CXN_CONTRA AND C5_MDNUMED = CXN_NUMMED  AND C5_MDPLANI = CXN_NUMPLA "  
	cQuery += "INNER JOIN "+RETSQLNAME("CNF")+" CNF ON " 
	cQuery += "CXN_FILIAL = CNF_FILIAL AND CXN_CONTRA = CNF_CONTRA AND CXN_REVISA = CNF_REVISA  AND CXN_CRONOG = CNF_NUMERO "
	cQuery += "AND CXN_NUMPLA = CNF_NUMPLA  AND CXN_PARCEL = CNF_PARCEL "
	cQuery += "INNER JOIN "+RETSQLNAME("SE1")+" SE1 ON "
	cQuery += "E1_FILIAL = SUBSTRING(C5_FILIAL, 1, 2) AND CNF_CONTRA = E1_MDCONTR AND CNF_REVISA = E1_MDREVIS "
	cQuery += "AND CNF_NUMERO = E1_MDCRON AND CNF_NUMPLA = E1_MDPLANI AND CNF_PARCEL = E1_MDPARCE "
	cQuery += "WHERE CXN.D_E_L_E_T_ = ' ' "
	cQuery += "AND CNF.D_E_L_E_T_ = ' ' "
	cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += "AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += "AND E1_TIPO = 'PR' "
	cQuery += "AND E1_PREFIXO = 'CTR' "
	cQuery += "AND E1_ORIGEM = 'CNTA100' "
	cQuery += "AND C5_MDCONTR = '" + SC5->C5_MDCONTR + "' " 
	cQuery += "AND C5_MDNUMED = '" + SC5->C5_MDNUMED + "' "
	cQuery += "AND C5_MDPLANI = '" + SC5->C5_MDPLANI + "' "
	cQuery += "AND C5_YCOMPET = '" + DtoS(SC5->C5_YCOMPET) + "' "

	MpSysOpenQuery(cQuery, "TMPSC5")
	
	while !TMPSC5->(EOF())
		aAdd(aRecno, TMPSC5->RECNO)
		TMPSC5->(dbSkip())
	endDo
	TMPSC5->(dbCloseArea())
	SC5->(dbCloseArea())
	
return aRecno