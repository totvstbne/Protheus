#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: A010TOK                                                      **
** Autor: Gerardo Ara�jo                                                   **
** Data:  06/06/2018                                                       **
*****************************************************************************
** Desc.  ** Obrigatoriedade dos campos B1_POSIPI ou B1_CODISS.            **
**        **                                                               **
*****************************************************************************
*****************************************************************************
*/

User Function A010TOK()

Local lRet	:= .T.

IF inclui .and. M->B1_TIPO=="SV" .and. empty(M->B1_CODISS)	
	MsgAlert("� necess�rio informar o C�digo de Servi�o do ISS.")
	lRet	:= .F.
Elseif inclui .and. M->B1_TIPO<>"SV" .and. empty(M->B1_POSIPI) 
	MsgAlert("� necess�rio informar o Pos.IPI/NCM do produto.")
	lRet	:= .F.
EndIf

If lRet .and. (inclui .or. altera) .and. alltrim(posicione("SBM",1,xFilial("SBM")+M->B1_GRUPO,"BM_YITEMCC")) == "S"
	u_fSetCTD(substr(M->B1_COD,3,len(M->B1_COD)),M->B1_COD) //Inclus�o do item cont�bil
Endif
Return lRet
