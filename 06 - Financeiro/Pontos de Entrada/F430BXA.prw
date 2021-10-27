/*//#########################################################################################
Project  : Melhorias nos processos - SERVNAC
Module   : Financeiro
Source   : F430BXA
Objective: Personalizar Processos de Retorno de CNAB de Pagamento – Reconciliacao automatica
*///#########################################################################################

#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F430BXA
    Gerenciador de Processamento
    @type    function
    @author  Dilson Castro
    @since   06-09-2021
    @table   SE2,SE5
/*/

User Function F430BXA()
	// Definicao de variaveis
	Local aArea := GetArea()
	Local lRet := .T.
	If RecLock("SE5",.F.)
		SE5->E5_RECONC := "x"
		SE5->(msUnlock())
	Endif
	RestArea(aArea)
Return(lRet)
