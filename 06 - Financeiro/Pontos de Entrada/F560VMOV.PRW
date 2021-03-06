#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F560VMOV                                                      **
** Autor: Gerardo Ara�jo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade da entidade Centro de Custo na rotina de      **
**        ** Caixinha (inclus�o).                                          **
*****************************************************************************
*****************************************************************************
*/

USER FUNCTION F560VMOV()

Local lRet	:= .T.

IF INCLUI .AND. Alltrim(FUNNAME())$"FINA560" .AND. (EMPTY(M->EU_HISTOR) .OR. EMPTY(M->EU_CCD))
	MsgAlert("� necess�rio informar o Hist�rico e o Centro de Custo.")
	lRet	:= .F.
EndIf

Return lRet