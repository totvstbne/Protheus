#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Topconn.ch"

/*
> to do: nome do fornecedor na rotina Liberação de Documento (SCR)
> author: Aurélio Araripe
> since: 02/04/2019
>
*/
User Function SERSCRNFORN()
	Local cNumero :=SCR->CR_NUM
	Local cTip    :=SCR->CR_TIPO
	Local cQuery  := ""
	Local cNome	  :=""
	Local aArea := getArea()
	
	If  cTip == "PC"
		
		cQuery  :="SELECT  "
		cQuery  +="		SC7.C7_FORNECE,   "
		cQuery  +="		SC7.C7_LOJA       "
		cQuery  +=" FROM " +RetSqlName("SC7") + " SC7"
		cQuery  +="		WHERE D_E_L_E_T_ =''"
		cQuery  +="			AND SC7.C7_FILIAL ='" + xFilial("SC7")  + "'"
		cQuery  +="			AND SC7.C7_NUM ='"    + cNumero  + "'"
		
		If Select("TSC7") > 0
			dbSelectArea("TSC7")
			TSC7->(dbCloseArea())
		EndIf
		
		TCQuery cQuery New Alias TSC7
		
		cNome := POSICIONE("SA2",1,XFILIAL("SA2")+ TSC7->C7_FORNECE + TSC7->C7_LOJA ,"A2_NOME")
		
		TSC7->(dbCloseArea())
	
	ElseIf  cTip == "PF"
		
		cQuery  :="SELECT  "
		cQuery  +="		ZA7.ZA7_FORNEC,   "
		cQuery  +="		ZA7.ZA7_LOJA       "
		cQuery  +=" FROM " +RetSqlName("ZA7") + " ZA7"
		cQuery  +="		WHERE D_E_L_E_T_ =''"
		cQuery  +="			AND ZA7.ZA7_FILIAL ='" + xFilial("ZA7")  + "'"
		cQuery  +="			AND ZA7.ZA7_NUM ='"    + cNumero  + "'"
		
		If Select("TZA7") > 0
			dbSelectArea("TZA7")
			TZA7->(dbCloseArea())
		EndIf
		
		TCQuery cQuery New Alias TZA7
		
		cNome := POSICIONE("SA2",1,XFILIAL("SA2")+ TZA7->ZA7_FORNECE + TZA7->ZA7_LOJA ,"A2_NOME")
		
		TZA7->(dbCloseArea())
	
	EndIf
RestArea (aArea)
Return cNome