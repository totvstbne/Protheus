#include "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: F040INS                                                       **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Manipular a natureza financeira do INSS gerado pelo contas a  **
**        ** receber.                                                      **
*****************************************************************************
*****************************************************************************
*/

User Function F040INS()

Local aArea := GetArea()

If Alltrim(SE1->E1_TIPO) == "IN-"
	RecLock("SE1",.F.)
		SE1->E1_NATUREZ    := GETMV("SV_INSS")
	MsUnlock()
Endif

dbSelectArea("SE2")

_cpref := SE2->E2_PREFIXO
_cnum := SE2->E2_NUM

DbSetOrder(1)
If DbSeek(xFilial("SE2")+_cpref+_cnum,.F.)
   While !Eof() .and. SE2->E2_FILIAL==xFilial("SE2") .and. SE2->E2_PREFIXO==_cpref .and. SE2->E2_NUM==_cnum  
      If RecLock("SE2",.F.)
         SE2->E2_NATUREZ := GetMv("SV_INSS") 
         MsUnlock()
      Endif
      DbSkip()
   EndDo
Endif

RestArea(aArea)

Return