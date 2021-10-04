#Include 'Protheus.ch'
#INCLUDE 'rwmake.ch' 
#INCLUDE 'topconn.ch'

/*
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    � Mod11237 � Efetua o c�lculo do d�gito veririficador com base 7 Bradesco ���
���             �          �                                                              ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 18.11.2013 � Wilton Lima                                                ���
�����������������������������������������������������������������������������������������͹��
��� Par�metros  � ExpC1 = String com o c�digo a ser calculado                             ���
�����������������������������������������������������������������������������������������͹��
��� Retorno     � ExpC1 = String com o D�gito Verificador                                 ���
�����������������������������������������������������������������������������������������͹��
��� Observa��es �                                                                         ���
�����������������������������������������������������������������������������������������͹��
��� Altera��es  � 99.99.9999 - Consultor - Descri��o da altera��o                         ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
*/

User Function Mod11237(cData)
	
	Local nResult	:= 0
	Local nSoma		:= 0
	Local cDc		:= ""
	Local i			:= 0
	Local nTam		:= 13
	Local nDc		:= 0
	Local nAlg		:= 2
	Local nCalNum	:= space(13)
		
	nCalNum:= AllTrim(cData)
	
	For i := Len(nCalNum) To 1 Step -1
		nSoma   := Val(Substr(nCalNum, i, 1)) * nAlg
		nResult := nResult + nSoma
		nAlg    := nAlg + 1      	
		
		If nAlg > 7
			nAlg := 2
		Endif
	Next i
	
	nDC  := MOD(nResult, 11)   
	cDig := 11 - nDc
	
	IF nDC == 1
		cDig := "P"
	ElseIf nDC == 0
	   cDig := 0
	   cDig := STR(cDig, 1) 	
	Else
		cDig := STR(cDig, 1)
	EndIF
  
Return(Alltrim(cDig))
