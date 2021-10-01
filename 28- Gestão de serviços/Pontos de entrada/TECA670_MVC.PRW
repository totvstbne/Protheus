#include 'protheus.ch'
#include 'parmtype.ch'
//*****************************************************************************
/*/{Protheus.doc} TECA670
Ponto de Entrada para criar alerta para colaboradores que estão cumprindo aviso previo
Ponto de entrada padrão da rotina MVC TECA670
@author edlardo neves - mconsult
@since 19/11/2020
@version 1.0
@return lRet - Lógico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=208345968
/*/
//*****************************************************************************
User Function TECA670()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "FORMPRE" .AND. cIdModel == "GRID1" .AND. Alltrim(FUNNAME()) == "TECA190B"
            oObj:oFormmodel:aAllSubmodels[2]:oFormmodelstruct:aFields[7][7] := {|oMdl, cCampo, xValueNew, nLine, xValueOld| At670Valor(oMdl, cCampo, xValueNew, nLine, xValueOld) .AND. u_RTECR003() }
		EndIf
	EndIf

Return xRet