#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F560VMOV                                                      **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** Caixinha (inclusão).                                          **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION F560VMOV()

Local lRet	:= .T.

IF INCLUI .AND. Alltrim(FUNNAME())$"FINA560" .AND. (EMPTY(M->EU_HISTOR) .OR. EMPTY(M->EU_CCD))
	MsgAlert("É necessário informar o Histórico e o Centro de Custo.")
	lRet	:= .F.
EndIf

Return lRet