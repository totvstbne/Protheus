#include "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F040ISS                                                       **
** Autor: Gerardo Ara?jo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Manipular a natureza financeira do ISS gerado pelo contas a   **
**        ** receber.                                                      **
*****************************************************************************
*****************************************************************************
*/

User Function F040ISS() 

Local aArea := GetArea()

If Alltrim(SE1->E1_TIPO) == "IS-"
	RecLock("SE1",.F.)
		SE1->E1_NATUREZ    := GETMV("SV_ISS")
	MsUnlock()
Endif

dbSelectArea("SE2")

_cpref := SE2->E2_PREFIXO
_cnum := SE2->E2_NUM
_cparcela := SE2->E2_PARCELA

DbSetOrder(1)
If DbSeek(xFilial("SE2")+_cpref+_cnum+_cparcela,.F.)
   While !Eof() .and. SE2->E2_FILIAL==xFilial("SE2") .and. SE2->E2_PREFIXO==_cpref .and. SE2->E2_NUM==_cnum .and. SE2->E2_PARCELA==_cparcela  
      If RecLock("SE2",.F.)
         SE2->E2_NATUREZ := GetMv("SV_ISS") 
         MsUnlock()
      Endif
      DbSkip()
   EndDo
Endif

RestArea(aArea)

Return