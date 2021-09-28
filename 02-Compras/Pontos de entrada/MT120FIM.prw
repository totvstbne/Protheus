#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} MT120FIM
Preenchimento do campo Memo na SCR
@author diogo
@since 28/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function MT120FIM
	Local aArea		:= getArea()
	Local cPedido	:= PARAMIXB[2]
	Local cCampMemo	:= ""
			
	If !Empty(cPedido)
		cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SC7")+" SC7 "
		cQuery+= "WHERE SC7.D_E_L_E_T_ = ' ' AND "
		cQuery+= "C7_FILIAL = '"+xFilial("SC7")+"' AND "
		cQuery+= "C7_NUM = '"+cPedido+"' "
		tcQuery cQuery new Alias QRSC7
		while QRSC7->(!Eof())
			SC7->(dbGoto(QRSC7->RECNO))
			If !Empty(SC7->C7_OBSM)
				cCampMemo+= alltrim(SC7->C7_DESCRI)+": "+SC7->C7_OBSM+chr(13)+chr(10)+chr(13)+chr(10)
			Endif 
		QRSC7->(dbSkip())
		Enddo
		QRSC7->(dbCloseArea())
		//Atualiza a SCR
		cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery+= "WHERE SCR.D_E_L_E_T_ = ' ' AND "
		cQuery+= "CR_FILIAL = '"+xFilial("SCR")+"' AND "
		cQuery+= "CR_NUM = '"+cPedido+"' AND "
		cQuery+= "CR_TIPO = 'PC' "
		tcQuery cQuery new Alias QRSCR
		while QRSCR->(!Eof())
			SCR->(dbGoto(QRSCR->RECNO))
			Reclock("SCR",.F.)
				SCR->CR_OBS := cCampMemo 
			MsUnlock()
		QRSCR->(dbSkip())
		Enddo
		QRSCR->(dbCloseArea())
	endif
 	RestArea(aArea)
return