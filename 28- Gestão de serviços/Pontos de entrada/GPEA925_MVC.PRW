#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'
//*****************************************************************************
/*/{Protheus.doc} GPEA925
Ponto de Entrada para atualizar o preenchimento do campo RA_YAVISOP
Ponto de entrada padrão da rotina MVC GPEA925
@author edlardo neves - mconsult
@since 26/11/2020
@version 1.0
@return lRet - Lógico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=208345968
/*/
//*****************************************************************************
User Function GPEA925()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.
	Local aAreaAtual := GetArea()
	Local oModelRFY
	Local nI := 1
	Local lAviso := .F.
	Local aSaveLines
	If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]
		lIsGrid    := "GRID" $ oObj:ClassName()
		cClasse := oObj:ClassName()
		If lIsGrid
			nQtdLinhas	:= oObj:GetQtdLine()
			nLinha		:= oObj:nLine
		EndIf

		If cIdPonto == "MODELCOMMITTTS"
			If  oObj:GetOperation()==MODEL_OPERATION_INSERT
				IF Alltrim(SRA->RA_YAVISOP)<>"S"
					DbSelectArea("SRA")
					RecLock("SRA", .F.)
					SRA->RA_YAVISOP := "S"
					MsUnLock()
				EndIf
			Elseif oObj:GetOperation()==MODEL_OPERATION_DELETE
				IF Alltrim(SRA->RA_YAVISOP)<>""
					DbSelectArea("SRA")
					RecLock("SRA", .F.)
					SRA->RA_YAVISOP := ""
					MsUnLock()
				EndIf
			Elseif oObj:GetOperation()==MODEL_OPERATION_UPDATE
				oModelRFY := oObj:GetModel('RFYDETAIL')
				aSaveLines := FWSaveRows()
				For nI := 1 To  oModelRFY:Length()
					oModelRFY:GoLine(nI)
					//RFY_DTCAP
					IF Empty(oModelRFY:getValue("RFY_DTCAP")) .AND. !(oModelRFY:IsDeleted())
						lAviso := .T.
					EndIf
				Next
				FWRestRows( aSaveLines )

				DbSelectArea("SRA")
				RecLock("SRA", .F.)
				SRA->RA_YAVISOP := IIF(lAviso,"S","")
				MsUnLock()

			EndIf
		EndIf


	EndIf

	RestArea(aAreaAtual)

Return xRet