#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function  MT120OK()

	Local lRet 		:= .T.
	Local i
	Local nC7_TES    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TES"})
	Local nC7_YNATUR    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_YNATUR"})
	
	IF Inclui .OR. ALTERA

		IF empty(nCombPCPF)
			lRet := .F.
			Alert("Favor preencher o campo PC/PF. Campo Obrigatório!")
		ENDIF

		IF lRet .and. nCombPCPF == "PF"
			For i:=1 to len(aCols)
				If empty(alltrim(aCols[i, nC7_TES]))
					lRet := .f.
					Alert("TES obrigatório para o tipo 'PF' - Linha: "+cvaltochar(i))
					exit
				EndIf
				If empty(alltrim(aCols[i, nC7_YNATUR]))
					lRet := .f.
					Alert("Natureza obrigatório para o tipo 'PF' - Linha: "+cvaltochar(i))
					exit
				EndIf
			Next i
		EndIf

	ENDIF


Return(lRet)
