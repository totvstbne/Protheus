#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: FA040INC                                                      **
** Autor: Gerardo Ara�jo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** Contas a Receber (inclus�o).                                  **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION FA040INC()

Local lRet	:= .T.

IF INCLUI .AND. Alltrim(FUNNAME())$"FINA040/FINA740" .AND. (EMPTY(M->E1_CCUSTO) .OR. EMPTY(M->E1_HIST))
	MsgAlert("� necess�rio informar o Hist�rico e o Centro de Custo.")
	lRet	:= .F.
EndIf

Return lRet