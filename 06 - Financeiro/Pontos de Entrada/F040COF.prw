#include "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F040COF                                                       **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Manipular a natureza financeira do COFINS gerado pelo contas  **
**        ** a receber.                                                    **
*****************************************************************************
*****************************************************************************
*/

User Function F040COF()

Local aArea := GetArea()

If Alltrim(SE1->E1_TIPO) == "CF-"
	RecLock("SE1",.F.)
		SE1->E1_NATUREZ    := GETMV("SV_COFINS")
	MsUnlock()
Endif

RestArea(aArea)

Return