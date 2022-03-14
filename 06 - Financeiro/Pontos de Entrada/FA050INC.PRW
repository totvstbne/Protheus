#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: FA050INC                                                      **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** Contas a´Pagar (inclusão).
*****************************************************************************
** Autor: Aurélio Araripe
** Complemento: Restrição de títulos com tipo diferente de PR na inclusão
**				no Contas a Pagar.
                                    **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION FA050INC()

	Local lRet	:= .T.

	IF (EMPTY(M->E2_CCUSTO) .OR. EMPTY(M->E2_HIST)) .AND. (M->E2_RATEIO=='N' .OR. EMPTY(M->E2_HIST)) .AND. Alltrim(FUNNAME())$"FINA050/FINA750/FI400GERPA"  
		MsgaLERT("É necessário informar o Histórico e o Centro de Custo.")
		lRet	:= .F.
	ElseIf M->E2_TIPO <> 'PR ' .AND. Alltrim(FUNNAME())$"FINA050/FINA750/FI400GERPA"
		MsgaLERT("Inclusão apenas de títulos do tipo PR são permitidos nesta rotina. Por favor utilize o Pedido Financeiro!")
		lRet	:= .F.
	EndIf

Return lRet