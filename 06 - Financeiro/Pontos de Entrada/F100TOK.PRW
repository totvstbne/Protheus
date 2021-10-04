#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F100TOK                                                       **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** movimento bancário (inclusão).                                **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION F100TOK()

Local lRet	:= .T.

IF !EMPTY(M->E5_IDMOVI) .AND. M->E5_MOEDA$"M1" .AND. (EMPTY(M->E5_HISTOR) .OR. EMPTY(M->E5_CCUSTO))
	MsgAlert("É necessário informar o Histórico e o Centro de Custo.")
	lRet	:= .F.
EndIf

Return lRet