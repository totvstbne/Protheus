#include "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F040CSL                                                       **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Manipular a natureza financeira do CSLL gerado pelo contas a  **
**        ** receber.                                                      **
*****************************************************************************
*****************************************************************************
*/

User Function F040CSL()

Local aArea := GetArea()

If Alltrim(SE1->E1_TIPO) == "CS-"
	RecLock("SE1",.F.)
		SE1->E1_NATUREZ    := GETMV("SV_CSLL")
	MsUnlock()
Endif

RestArea(aArea)

Return