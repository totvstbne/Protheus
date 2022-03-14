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

User Function LP65013C(cPar1)

	Local _caArea := GetArea()
	Local _cRet := ""

	DbSelectArea("SE2")
	DbSetOrder(6)
	If DbSeek(SUBSTR(SD1->D1_FILIAL,1,2)+SPACE(4)+SD1->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC))
		DbSelectArea("SED")
		DbSetOrder(1)
		If DbSeek(XFILIAL("SED")+SE2->E2_NATUREZ)
			_cRet := IIF(EMPTY(SED->ED_YCTPART),SA2->A2_CONTA,SED->ED_YCTPART)                                                                                                                                                                                                 
		endif
	Endif
	RestArea(_caArea)

Return(_cRet)
