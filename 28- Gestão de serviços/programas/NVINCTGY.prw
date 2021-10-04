#include 'protheus.ch'
#include 'parmtype.ch'

//----------------------------------------------------------
/*/
As funções a seguir verificam a ocorrência de um atendente nas 
tabelas TGY, TGZ e ABB. Sendo '1' para a não ocorrência e '2' caso contrario.

@author 	Gustavo Florindo	
@since 		03/04/2019
/*/
//----------------------------------------------------------

User Function NVINCTGY(cCodTEC)
Local cRet := ""
Local aArea := GetArea()
Local cAliasLEG	:= GetNextAlias()

BeginSql Alias cAliasLEG
	SELECT	1
	FROM %table:TGY% TGY 
	INNER JOIN %table:TFF% TFF ON (TFF.TFF_COD = TGY.TGY_CODTFF AND TFF.%NotDel% AND TFF.TFF_FILIAL = %xFilial:TGY%)
	INNER JOIN %table:TFL% TFL ON (TFL_CODIGO = TFF_CODPAI AND TFL.%NotDel% AND TFL.TFL_FILIAL = %xFilial:TGY%)
	INNER JOIN %table:TFJ% TFJ ON (TFJ_CODIGO = TFL_CODPAI AND TFJ.%NotDel% AND TFJ.TFJ_FILIAL = %xFilial:TGY%)
	WHERE 
		TGY.TGY_FILIAL = %xFilial:TGY% AND
		TGY.TGY_ATEND = %Exp:cCodTEC% AND
		TFJ.TFJ_STATUS = '1' AND
		TGY.%NotDel% 
		
EndSql

If (cAliasLEG)->(EOF())
	cRet := '1'
Else
	cRet := '2'
EndIf

(cAliasLEG)->(DbCloseArea())
RestArea(aArea)
Return cRet

User Function NVINCTGZ(cCodTEC)
Local cRet := ""
Local aArea := GetArea()
Local cAliasLEG	:= GetNextAlias()

BeginSql Alias cAliasLEG
	SELECT	1
	FROM %table:TGZ% TGZ
	WHERE 
		TGZ.TGZ_FILIAL = %xFilial:TGZ% AND
		TGZ.TGZ_ATEND = %Exp:cCodTEC% AND
		TGZ.%NotDel%
EndSql

If (cAliasLEG)->(EOF())
	cRet := '1'
Else
	cRet := '2'
EndIf

(cAliasLEG)->(DbCloseArea())
RestArea(aArea)
Return cRet


User Function NVINCABB(cCodTEC)
Local cRet := ""
Local aArea := GetArea()
Local cAliasLEG	:= GetNextAlias()

BeginSql Alias cAliasLEG
	SELECT	1
	FROM %table:ABB% ABB
	WHERE 
		ABB.ABB_FILIAL = %xFilial:ABB% AND
		ABB.ABB_CODTEC = %Exp:cCodTEC% AND
		ABB.%NotDel%
EndSql

If (cAliasLEG)->(EOF())
	cRet := '1'
Else
	cRet := '2'
EndIf

(cAliasLEG)->(DbCloseArea())
RestArea(aArea)
Return cRet
