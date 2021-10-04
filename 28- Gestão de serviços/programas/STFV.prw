#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Topconn.ch"

/*
TODO Fonte que retorna o valor total da medição na rotina de Apurações e Medições (TFV).
@author Aurélio Araripe
@since 13/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
*/

user function STFV()
	
	Local cApuracao :=TFV->TFV_CODIGO
	Local cTFVFILIAL :=TFV->TFV_FILIAL
	Local cQuery  := ""
	Local cValorTFW  :=""
	Local cValorTFX  :=""
	Local cValorTFY  :=""
	Local cValorTotal  :=""
	Local aarea := getarea()
	
	
	/* Encontrar Valor Total da Apuração através do Material de Recursos Humanos TFW*/
	cQuery  :="SELECT  "
	cQuery  +="	SUM(TFW_VLRMED) AS TFWVALORTOTAL, SUM(TFX_VLRMED) AS TFXVALORTOTAL, SUM(TFY_VLRMED) AS TFYVALORTOTAL   "
	cQuery  +=" FROM " +RetSqlName("TFV") + " TFV"
	cQuery  +=" LEFT JOIN " +RetSqlName("TFW") + " TFW"
	cQuery  +=" 	ON TFV.TFV_FILIAL = TFW.TFW_FILIAL AND"
	cQuery  +=" 	TFV.TFV_CODIGO = TFW.TFW_APURAC AND"
	cQuery  +=" 	TFW.D_E_L_E_T_ = ''"	
	cQuery  +=" LEFT JOIN " +RetSqlName("TFX") + " TFX"
	cQuery  +=" 	ON TFW.TFW_FILIAL = TFX.TFX_FILIAL AND"
	cQuery  +=" 	TFW.TFW_APURAC = TFX.TFX_APURAC AND"
	cQuery  +=" 	TFW.TFW_CODTFF = TFX.TFX_CODTFF AND"
	cQuery  +=" 	TFX.D_E_L_E_T_ = ''"
	cQuery  +=" LEFT JOIN TFY010 AS TFY"
	cQuery  +=" 	ON TFW.TFW_FILIAL = TFY.TFY_FILIAL AND"
	cQuery  +=" 	TFW.TFW_APURAC = TFY.TFY_APURAC AND"
	cQuery  +=" 	TFW.TFW_CODTFF = TFY.TFY_CODTFF AND"
	cQuery  +=" 	TFY.D_E_L_E_T_ = '' "
	cQuery  +="	WHERE TFV.D_E_L_E_T_ ='' AND"
	cQuery  +="		TFW.TFW_FILIAL = '" + cTFVFILIAL + "' AND"
	cQuery  +="		TFW.TFW_APURAC = '" + cApuracao + "'"
		
	If Select("TTFV") > 0
		dbSelectArea("TTFV")
		TTFV->(dbCloseArea())
	EndIf

	TCQuery cQuery New Alias TTFV
	
	cValorTFW := TTFV->TFWVALORTOTAL
	cValorTFX := TTFV->TFXVALORTOTAL
	cValorTFY := TTFV->TFYVALORTOTAL
	cValorTotal := cValorTFW + cValorTFX + cValorTFY
	TTFV->(dbCloseArea())
	
	restarea(aarea)
return cValorTotal