#INCLUDE 'PROTHEUS.CH'

//Ponto de entrada para alterar o percentual do desconto do funcionário - Vale transporte
User Function GP210SAL()

	Local _Alias   := GetArea()
	/*
	If SRA->RA_CATFUNC == "E" 
	nPercentual := 0.00
	Else
	nPercentual := posicione("RCE",1,SRA->RA_FILIAL+SRA->RA_SINDICA,"RCE_YPERVT")
	EndIf
	*/

	If POSICIONE("SR6",1,XFILIAL("SR6")+ SRA->RA_TNOTRAB , "R6_TPJORN") == "02" 
		nPercentual := posicione("RCE",1,XFILIAL("RCE",SRA->RA_FILIAL)+SRA->RA_SINDICA,"RCE_YPERVT")
	Else
		nPercentual := 6
	EndIf

	RestArea(_Alias)

Return