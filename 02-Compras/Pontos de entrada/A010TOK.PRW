#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: A010TOK                                                      **
** Autor: Gerardo Araújo                                                   **
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
	MsgAlert("É necessário informar o Código de Serviço do ISS.")
	lRet	:= .F.
Elseif inclui .and. M->B1_TIPO<>"SV" .and. empty(M->B1_POSIPI) 
	MsgAlert("É necessário informar o Pos.IPI/NCM do produto.")
	lRet	:= .F.
EndIf

If lRet .and. (inclui .or. altera) .and. alltrim(posicione("SBM",1,xFilial("SBM")+M->B1_GRUPO,"BM_YITEMCC")) == "S"
	u_fSetCTD(substr(M->B1_COD,3,len(M->B1_COD)),M->B1_COD) //Inclusão do item contábil
Endif
Return lRet
