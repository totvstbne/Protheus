#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'
//*****************************************************************************
/*/{Protheus.doc} TECA580E
Ponto de Entrada utilizado para criar validação: Não alocar funcionários a mais que a quantidade do local de atendimento (TFF_QTDVEN)
Ponto de entrada padrão da rotina MVC TECA580E
@author edlardo neves - mconsult
@since 26/11/2020
@version 1.0
@return lRet - Lógico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=208345968
/*/
//*****************************************************************************
User Function TECA580E()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid := .F.
	Local nI := 1
	Local aSaveLines
	Local aAreaAtual := GetArea()
	Local nDtInicio
	Local nDtFim
	Local nTotAtivo := 0
	Local dDtAtual 
	Local lBloqueia := GetNewPar("MV_YTEC580", .F.)

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

		If cIdPonto == "FORMPRE"
			IF cIdModel == "TGYDETAIL"
				IF aParam[5] == "SETVALUE"
					If aParam[6] == "TGY_DTINI" .OR. aParam[6] == "TGY_DTFIM"
						nDtInicio 	:= FwFldGet("TGY_DTINI")
						nDtFim 		:= FwFldGet("TGY_DTFIM")		
						If !EMPTY(nDtInicio) .AND. !EMPTY(nDtFim) 
							aSaveLines 	:= FWSaveRows()
							nTotAtivo  	:= 0
							dDtAtual	:= nDtInicio
							While dDtAtual <= nDtFim
								nI := 1
								nTotAtivo := 0
								For nI := 1 To  oObj:Length()
									oObj:GoLine(nI)
									If oObj:IsDeleted()
										Loop
									EndIf
									
									IF nI == nLinha
										nTotAtivo += 1
										Loop
									EndIf
									
									IF dDtAtual >= oObj:getValue("TGY_DTINI") .AND. dDtAtual <= oObj:getValue("TGY_DTFIM") 
										nTotAtivo += 1
									EndIf

									IF nTotAtivo > FwFldGet("TFF_QTDVEN")
										Exit
									EndIf
								Next
								
								IF nTotAtivo > FwFldGet("TFF_QTDVEN")
									If lBloqueia
										xRet := .F.
										MSGINFO( "Não é possivel alocar quantidade de funcionários maior que a quantidade maxima cadastrada no local de atendimento - Data alocação invalida: "+DtoC(dDtAtual), "Operação Bloqueada" )
									Else
										MSGINFO( "Quantidade de funcionários alocados maior que a quantidade maxima cadastrada no local de atendimento - Data alocação invalida: "+DtoC(dDtAtual), "Atenção" )
									EndIf
									Exit
								EndIf
								dDtAtual := DaySum(dDtAtual,1)
							EndDo
							FWRestRows( aSaveLines )
						EndIF
					EndIf
				ENDIF
			ENDIF
		EndIf
	EndIf

	RestArea(aAreaAtual)

Return xRet
