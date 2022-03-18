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

User Function LP65013V()

	Local _LRet := .F.
	Local _caArea := GetArea()

	CQUERY := " SELECT E2_NATUREZ FROM "+RETSQLNAME("SE2")+" E2 WHERE E2_FILIAL = '"+SUBSTR(SD1->D1_FILIAL,1,2)+"' AND E2_FORNECE = '"+SD1->D1_FORNECE+"'  "
	CQUERY += " AND E2_LOJA = '"+SD1->D1_LOJA+"' AND E2_NUM = '"+SD1->D1_DOC+"' AND E2_PREFIXO = '"+SD1->D1_SERIE+"' AND E2.D_E_L_E_T_ = ' ' "

	TcQuery CQUERY New Alias T01
	DbSelectArea("T01")

	If !T01->(Eof())

		DbSelectArea("SED")
		DbSetOrder(1)
		If DbSeek(XFILIAL("SED")+T01->E2_NATUREZ)
			_LRet := IIF(ALLTRIM(SED->ED_YPROVI)$"N",.F.,.T.)
		endif

	Endif
	T01->(DBCLOSEAREA())
	RestArea(_caArea)

Return(_LRet)
