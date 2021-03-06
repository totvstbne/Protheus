#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F100TOK                                                       **
** Autor: Gerardo Ara�jo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** movimento banc�rio (inclus�o).                                **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION F100TOK()

Local lRet	:= .T.

IF !EMPTY(M->E5_IDMOVI) .AND. M->E5_MOEDA$"M1" .AND. (EMPTY(M->E5_HISTOR) .OR. EMPTY(M->E5_CCUSTO))
	MsgAlert("� necess�rio informar o Hist�rico e o Centro de Custo.")
	lRet	:= .F.
EndIf

Return lRet