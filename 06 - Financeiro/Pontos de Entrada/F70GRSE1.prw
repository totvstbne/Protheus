/*//#########################################################################################
Project  : Melhorias nos processos - SERVNAC
Module   : Financeiro
Source   : F70GRSE1
Objective: Personalizar Processos de Retorno de CNAB de Recebimento – Reconciliacao automatica
*///#########################################################################################

#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F70GRSE1
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SE1,SE5
    @since   02-09-2021
    @type    function
/*/

User Function F70GRSE1
   	If RecLock("SE5",.F.)
		SE5->E5_RECONC := "x"
        SE5->(msUnlock())
    Endif
Return
