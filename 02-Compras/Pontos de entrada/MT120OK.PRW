#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function  MT120OK()

	Local lRet 		:= .T.
	
	IF Inclui .OR. ALTERA

		IF empty(nCombPCPF)
			lRet := .F.
			Alert("Favor preencher o campo PC/PF. Campo Obrigatório!")
		ENDIF

	ENDIF


Return(lRet)
