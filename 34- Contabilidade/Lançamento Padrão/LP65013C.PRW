#include "rwmake.ch"
#include "protheus.ch"
#include "Topconn.ch"

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���P.Entrada �  ItemCta � Autor �   Plinio Nogueira           � Data � 10/12/18 ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Inclus�o autom�tica do item cont�bil referente a fornecedor,     ���
��� cliente e produto na grava��o do lan�amento cont�bil.                       ���
��� Parametros da Fun��o:  cPar1 - C�digo de Forncedor/Cliente                  ���
��� Exemplo para Fornecedor: u_ClVlCta("SA2->A2_COD")                           ���
��� Exemplo para Cliente:    u_ClVlCta("SA1->A1_COD")                           ���
��� Exemplo para Produto:    u_ClVlCta("SB1->B1_COD")                           ���
�������������������������������������������������������������������������������Ĵ��
/*/

User Function LP65013C(cPar1)

	Local _caArea := GetArea()
	Local _cRet := ""

	CQUERY := " SELECT E2_NATUREZ FROM "+RETSQLNAME("SE2")+" E2 WHERE E2_FILIAL = '"+SUBSTR(SD1->D1_FILIAL,1,2)+"' AND E2_FORNECE = '"+SD1->D1_FORNECE+"'  "
	CQUERY += " AND E2_LOJA = '"+SD1->D1_LOJA+"' AND E2_NUM = '"+SD1->D1_DOC+"' AND E2_PREFIXO = '"+SD1->D1_SERIE+"' AND E2.D_E_L_E_T_ = ' ' "

	TcQuery CQUERY New Alias T01
	DbSelectArea("T01")

	If !T01->(Eof())

		DbSelectArea("SED")
		DbSetOrder(1)
		If DbSeek(XFILIAL("SED")+T01->E2_NATUREZ)
			_cRet := IIF(EMPTY(SED->ED_YCTPART),SA2->A2_CONTA,SED->ED_YCTPART)
		endif
	Endif
	T01->(DBCLOSEAREA())
	RestArea(_caArea)

Return(_cRet)
