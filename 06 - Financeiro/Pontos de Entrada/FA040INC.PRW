#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: FA040INC                                                      **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** Contas a Receber (inclusão).                                  **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION FA040INC()

Local lRet	:= .T.

IF INCLUI .AND. Alltrim(FUNNAME())$"FINA040/FINA740" .AND. (EMPTY(M->E1_CCUSTO) .OR. EMPTY(M->E1_HIST))
	MsgAlert("É necessário informar o Histórico e o Centro de Custo.")
	lRet	:= .F.
EndIf

Return lRet