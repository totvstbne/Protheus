#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RSVNV001
Validação do código do plano
RHK_CODFOR: ZA1_CODFOR
RHK_PLANO: ZA1_PLANO
RHL_PLANO: ZA1_PLNDP  
@author Diogo
@since 06/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSVNV001()
	Local cVar := Alltrim(ReadVar())
	Local cTpForn
	Local cCodFor
	Local cTpPlano
	Local cCodPlano
	Local lRet := .T.
	Local oModel
	
	oModel 	:= FWModelActive()
	
	cTpForn	:= oModel:getModel("ZA1DETAIL"):GetValue("ZA1_TPFORN")
	cCodFor	:= oModel:getModel("ZA1DETAIL"):GetValue("ZA1_CODFOR")
	
	If cVar == "M->ZA3_PLNDP"
		cTpPlano := oModel:getModel("ZA1DEP"):GetValue("ZA3_TPLNDP")
		cCodPlano := oModel:getModel("ZA1DEP"):GetValue("ZA3_PLNDP")
	Elseif cVar == "M->ZA1_PLANO"
		cTpPlano := oModel:getModel("ZA1DETAIL"):GetValue("ZA1_TPPLAN")
		cCodPlano := oModel:getModel("ZA1DETAIL"):GetValue("ZA1_PLANO")
	EndIf

	lRet := fValidPlano(cTpForn, cCodFor, cTpPlano, cCodPlano)
Return lRet