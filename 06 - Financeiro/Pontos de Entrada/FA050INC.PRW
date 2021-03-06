#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: FA050INC                                                      **
** Autor: Gerardo Ara�jo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** Contas a�Pagar (inclus�o).
*****************************************************************************
** Autor: Aur�lio Araripe
** Complemento: Restri��o de t�tulos com tipo diferente de PR na inclus�o
**				no Contas a Pagar.
                                    **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION FA050INC()

	Local lRet	:= .T.

	IF (EMPTY(M->E2_CCUSTO) .OR. EMPTY(M->E2_HIST)) .AND. (M->E2_RATEIO=='N' .OR. EMPTY(M->E2_HIST)) .AND. Alltrim(FUNNAME())$"FINA050/FINA750/FI400GERPA"  
		MsgaLERT("� necess�rio informar o Hist�rico e o Centro de Custo.")
		lRet	:= .F.
	ElseIf M->E2_TIPO <> 'PR ' .AND. Alltrim(FUNNAME())$"FINA050/FINA750/FI400GERPA"
		MsgaLERT("Inclus�o apenas de t�tulos do tipo PR s�o permitidos nesta rotina. Por favor utilize o Pedido Financeiro!")
		lRet	:= .F.
	EndIf

Return lRet