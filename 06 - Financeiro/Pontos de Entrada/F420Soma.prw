#include "rwmake.ch"        

User Function F420Soma()        

SetPrvt("_valor,_abat,_juros")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Rotina    � F420SUM.PRW                                               ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada para alterar o valor utilizado na funcao  ���
���          � SOMAVALOR() do sispag                                      ���
�������������������������������������������������������������������������Ĵ��
���Desenvolvi� GERARDO ARAUJO                                             ���
���mento     � 28/04/2014                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Utilizado no sispag do Itau para totalizar os acrescimos   ���
���            e descontos no valor total enviado ao banco.               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���Alteracao �                                                            ���
���          �                                                            ���
�����������������������������������������������������������������������������
/*/                                                                               

_Abat  := somaabat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA)
_Abat  += SE2->E2_DECRESC 
_Juros := (SE2->E2_YMULTA + SE2->E2_YJUROS)
_Valor := SE2->E2_SALDO - _Abat + _Juros

Return(_Valor)       