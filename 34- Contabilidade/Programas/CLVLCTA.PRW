#include "rwmake.ch"
#include "protheus.ch"
#include "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³P.Entrada ³  ItemCta ³ Autor ³   Plinio Nogueira           ³ Data ³ 10/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusão automática do item contábil referente a fornecedor,     ´±±
±±³ cliente e produto na gravação do lançamento contábil.                       ´±±
±±³ Parametros da Função:  cPar1 - Código de Forncedor/Cliente                  ´±±
±±³ Exemplo para Fornecedor: u_ClVlCta("SA2->A2_COD")                           ´±±
±±³ Exemplo para Cliente:    u_ClVlCta("SA1->A1_COD")                           ´±±
±±³ Exemplo para Produto:    u_ClVlCta("SB1->B1_COD")                           ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/

User Function ClVlCta(cPar1)

Local aAreaCTH := CTH->(GetArea())
Local _lRet
Local _cDesc

If FunName() <> "CTBA080"
	
	If cPar1 == "SA1->A1_COD"     //Cliente
		_cDesc := ALLTRIM(SA1->A1_NOME)
		_lRet  := "C" + ALLTRIM(SA1->A1_COD)+SA1->A1_LOJA
	ElseIf cPar1 == "SA2->A2_COD" //Fornecedor
		_cDesc := ALLTRIM(SA2->A2_NOME)
		_lRet  := "F" + ALLTRIM(SA2->A2_COD)+SA2->A2_LOJA
	ElseIf cPar1 == "SB1->B1_COD" //Produto
		_cDesc := ALLTRIM(SB1->B1_DESC)
		_lRet  := ALLTRIM(SB1->B1_COD) 
	EndIf
	
	XCONCTH:=" SELECT COUNT(*) AS CONT FROM "+RETSQLNAME("CTH")+" WHERE D_E_L_E_T_ = ' ' AND CTH_CLVL = '"+_lRet+"'"
	
	If Select("XCONCTH")> 0
		XCONCTH->(DBCLOSEAREA())
	Endif
	
	TCQUERY XCONCTH NEW ALIAS "XCONCTH"
	
	If XCONCTH->CONT < 1
		
		// Grava conta no CTH
		RecLock("CTH",.T.)
		
		CTH->CTH_FILIAL  := xFilial()
		CTH->CTH_CLVL    := _lRet
		CTH->CTH_DESC01  := _cDesc
		CTH->CTH_CLASSE  := '2'
		CTH->CTH_BLOQ    := '2'
		CTH->CTH_DTEXIS	 := CtoD("01/01/1980")
        CTH->CTH_CRGNV1  := IIF(cPar1$"SA1","C01","F01")
		
		CTH->(MSUNLOCK())
		
	Endif
	
EndIf

RestArea(aAreaCTH)

Return(_lRet)
