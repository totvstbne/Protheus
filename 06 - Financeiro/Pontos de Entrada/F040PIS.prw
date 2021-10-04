#include "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F040PIS                                                       **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Manipular a natureza financeira do PIS gerado pelo contas a   **
**        ** receber.                                                      **
*****************************************************************************
*****************************************************************************
*/

User Function F040PIS()

Local aArea := GetArea()

If Alltrim(SE1->E1_TIPO) == "PI-"
	RecLock("SE1",.F.)
		SE1->E1_NATUREZ    := GetMV("SV_PIS")
	MsUnlock()
Endif

RestArea(aArea)

Return