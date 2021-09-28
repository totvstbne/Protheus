#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "Topconn.ch"

/*{Protheus.doc} SCRCONDPGTO
> TODO Módulo de Compras - Liberação de Dcto
> TODO alimentação no campo criado Descrição da Condição de Pgto.
> author aurelio
> since 21/03/2019
> version undefined
> example
>(examples)
> see (links_or_references)
*/

user function SCRCPGTO()

	Local cNumero 	:=SCR->CR_NUM
	Local cTip    	:=SCR->CR_TIPO
	Local cQuery  	:= ""
	Local cCondPgto	:=""
	Local aArea := getArea()
	
	If  cTip == "PC"
		
		cQuery  :="SELECT  "
		cQuery  +="		SC7.C7_COND       "
		cQuery  +=" FROM " +RetSqlName("SC7") + " SC7"
		cQuery  +="		WHERE D_E_L_E_T_ =''"
		cQuery  +="			AND SC7.C7_FILIAL ='" + xFilial("SC7")  + "'"
		cQuery  +="			AND SC7.C7_NUM ='"    + cNumero  + "'"
		
		If Select("TSC7") > 0
			dbSelectArea("TSC7")
			TSC7->(dbCloseArea())
		EndIf
		
		TCQuery cQuery New Alias TSC7
		
		cCondPgto := POSICIONE("SE4",1,XFILIAL("SE4")+ TSC7->C7_COND,"E4_DESCRI")
		
		TSC7->(dbCloseArea())
	
	EndIf
RestArea (aArea)
Return cCondPgto	   
	
