#include 'topconn.ch'

/*/{Protheus.doc} MTALCDOC
Rotina para aprovação da alçada
@author Diogo
@since 06/01/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function MTALCDOC()
	Local aAreaSCR		:= GetArea()
	Local aDocto		:= PARAMIXB[1]
	Local dDataRef		:= PARAMIXB[2]
	Local nOper			:= PARAMIXB[3]
	Local cDocto		:= alltrim(aDocto[1])
	Local cTipoDoc		:= aDocto[2]
	Local nValDcto		:= aDocto[3]
	Local cAprov		:= If(aDocto[4]==Nil,"",aDocto[4])
	Local cUsuario		:= If(aDocto[5]==Nil,"",aDocto[5])
	Local nMoeDcto		:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
	Local nTxMoeda		:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
	Private cObsAp     	:= If(Len(aDocto)>10,If(aDocto[11]==Nil, "",aDocto[11]),"")

	If cValtochar(nOper) == "4" .and. cTipoDoc == "PF"  //Aprovação do PF
		//Verifica se tem outros níveis de aprovação
		cQuery :="SELECT * FROM "+RetSqlName("SCR")+ " SCR (NOLOCK) "
		cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
		cQuery +="CR_FILIAL = '"+xFilial("SCR")+"' AND  "
		cQuery +="CR_NUM= '"+cDocto+"' AND  "
		cQuery +="CR_STATUS= '02' AND CR_TIPO='PF'" //Pendente de aprovação
		TcQuery cQuery new Alias QSCR
		
		If QSCR->(Eof())
			QSCR->(dbCloseArea())
			// Chama aprovação do pedido financeiro
			U_fAprovPF()
			If alltrim(SE2->E2_NUM+SE2->E2_PARCELA) <> alltrim(aDocto[1])
				cQuery :="SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SCR")+ " SCR (NOLOCK) "
				cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
				cQuery +="CR_FILIAL = '"+xFilial("SCR")+"' AND  "
				cQuery +="CR_NUM= '"+cDocto+"' AND  "
				cQuery +="CR_STATUS= '02' AND CR_TIPO='PF'" //Pendente de aprovação
				TcQuery cQuery new Alias TQE2
				If TQE2->(!eof())
					SCR->(dbGoto(TQE2->RECNO))
					Reclock("SCR",.F.)
						SCR->CR_DATALIB := cTod("")
					MsUnlock()
				Endif
				TQE2->(dbCloseArea())
			Endif
		Else
			QSCR->(dbCloseArea())
		Endif
	Endif	
	RestArea(aAreaSCR)
Return
