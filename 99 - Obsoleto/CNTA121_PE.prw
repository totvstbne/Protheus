#include 'protheus.ch'
#include 'topconn.ch'
#include 'parmtype.ch'
#include 'Fwmvcdef.ch'

Static lRefreshing := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA121
P.E. padrão para MVC

@author	boiani
@since 13/06/2019
/*/
//-------------------------------------------------------------------
User Function CNTA121()
	Local aParam     := PARAMIXB
	Local oObj
	Local cIdPonto
	Local cIdModel
	Local careaBk
	Local nX
	Local xRet:= .T.
	Local nSaveLine
	Local oView := FwViewActive()

	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		If cIdPonto == "FORMPRE" .AND. oObj:Getid() == "CXNDETAIL" .AND. !EMPTY(oObj:GetVALUE("CXN_CONTRA")) .AND. oObj:GetOperation() <> 5
			nSaveLine := oObj:GetLine()
			For nX := 1 To oObj:Length()
				oObj:GoLine(nX)
				oObj:LoadValue("CXN_DESCLO",GetDescABS(oObj:GetVALUE("CXN_CONTRA"), oObj:GetVALUE("CXN_NUMPLA")))
			Next nX
			oObj:GoLine(nSaveLine)
			If VALTYPE(oView) == 'O' .AND. !isBlind() .AND. !lRefreshing
				lRefreshing := .T. //Garante execução única do Refresh
				oView:Refresh()
				lRefreshing := .F.
			EndIf
		Elseif cIdPonto ==  'MODELCOMMITNTTS' //'MODELCOMMITTTS'

			careaBk := getarea()
			// JF ATUALIZA A MENSAGEM NO CAMPO CN9_YMENOT
			if alltrim(oObj:GetModel('CNDMASTER'):getvalue("CND_YAGIL")) == "S"

				cQuery := " SELECT CN9_FILIAL , CN9_NUMERO , CN9_REVISA , CN9_REVATU, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), CN9_YMENOT)),'') CN9_YMENOT 
				cQuery += " FROM "+RETSQLNAME("CN9")+"  CN9
				cQuery += " WHERE CN9_FILIAL = '"+ xfilial("CN9") +"'
				cQuery += " AND   CN9_NUMERO = '"+ oObj:GetModel('CNDMASTER'):getvalue("CND_CONTRA") +"'
				cQuery += " ORDER BY CN9_FILIAL , CN9_NUMERO , CN9_REVISA DESC

				IF SELECT("TCN9") > 0
					TCN9->(DBCLOSEAREA())
				ENDIF

				TcQuery cQuery New Alias TCN9

				WHILE !TCN9->(EOF())

					DbSelectArea("CN9")
					DbSetOrder(1)
					If DbSeek(ALLTRIM(TCN9->CN9_FILIAL)+ALLTRIM(TCN9->CN9_NUMERO)+ALLTRIM(TCN9->CN9_REVISA))	
						RecLock("CN9", .F.)		
						CN9->CN9_YMENOT := oObj:GetModel('CNDMASTER'):getvalue("CND_YMENOT") 
						MsUnLock() //Confirma e finaliza a operação
					EndIf		

					TCN9->(DBSKIP())
				ENDDO

				TCN9->(DBCLOSEAREA())

				Restarea(careaBk)
			endif
			//fim JF


			u_RSRVGRPD()
		Elseif cIdPonto == 'BUTTONBAR'
			xRet := { {'Medição Ágil', 'SALVAR', { || u_RSVNA013()}}}
		elseif cIdPonto ==  'FORMCOMMITTTSPOS' .and. oObj:GetOperation() == 3 //insert
			oView:SetCloseOnOk( { ||.T. } ) 
		EndIf
	elseif FwIsInCallStack("CN121MEDEST")
		u_RESTAGRU()
	EndIf
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN120DTCON
P.E. para a função CN120DTCON

@author	boiani
@since 13/06/2019
/*/
//-------------------------------------------------------------------
User Function CN120DTCON()
	Local oModel := FwModelActive()
	Local oObj := oModel:GetModel("CXNDETAIL")
	Local nSaveLine := oObj:GetLine()
	Local nX

	For nX := 1 To oObj:Length()
		oObj:GoLine(nX)
		oObj:LoadValue("CXN_DESCLO",GetDescABS(oObj:GetVALUE("CXN_CONTRA"), oObj:GetVALUE("CXN_NUMPLA")))
	Next nX
	oObj:GoLine(nSaveLine)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDescABS
Retorna a descrição de uma ABS a partir de um contrato/planilha

@author	boiani
@since 13/06/2019
/*/
//-------------------------------------------------------------------
Static Function GetDescABS(cContra,cPlan)
	Local cRet := ""
	Local cSQl := ""
	Local aArea := GetArea()
	Local cAliasAux := GetNextAlias()

	cSql := " SELECT ABS.ABS_DESCRI FROM " + RetSqlName("TFL") + " TFL "
	cSql += " INNER JOIN " + RetSqlName("ABS") + " ABS ON "
	cSql += " ABS.ABS_LOCAL = TFL.TFL_LOCAL AND "
	cSql += " ABS.D_E_L_E_T_ = ' ' AND "
	cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
	cSql += " WHERE TFL.D_E_L_E_T_ = ' ' AND "
	cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
	cSql += " TFL.TFL_CONTRT = '" + cContra + "' AND "
	cSql += " TFL.TFL_PLAN = '" + cPlan +"' "
	cSQL := ChangeQuery(cSQL)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)
	cRet := (cAliasAux)->(ABS_DESCRI)
	(cAliasAux)->(DbCloseArea())

	RestArea(aArea)
Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CNT121BT
P.E. no MenuDef da rotina

@author	boiani
@since 13/06/2019
/*/
//-------------------------------------------------------------------

User Function CNT121BT()
	If TYPE("aRotina") == "A"
		aAdd(aRotina, {"Apurar Item Extra"	,"At930GerMed(,,2)"	,0	,4	,0	,.T.	})
	EndIf
Return
