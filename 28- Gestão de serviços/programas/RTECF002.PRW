#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"
#INCLUDE "FWMVCDEF.CH"

//*****************************************************************************
/*/{Protheus.doc} RTECF002
Função para realizar transferencia contrato 
@author edlardo neves - mconsult
@since 14/01/2021
@version 1.0
@return null
/*/
//*****************************************************************************


User Function RTECF002()
	Local aAreaAtual := GetArea()
	Local oModel	 := FWModelActive()
	Local oModelTFJ  := oModel:GetModel('TFJ_REFER')
	Local oModelTFL  := oModel:GetModel('TFL_LOC')
	Local oModelTFF  := oModel:GetModel('TFF_RH')
	Local oModelTFG  := oModel:GetModel('TFG_MI')
	Local oModelTFH  := oModel:GetModel('TFH_MC')
	Local oView 	 := FWViewActive()
	Local cQuery	 := ""
	Local lTFLADD	 := .F.
	Local lTFFADD	 := .F.
	Local lTFGADD	 := .F.
	Local lTFHADD	 := .F.
	Local _MVPAR01   := MV_PAR01

	Local cFuncaoPad := GetNewPar("MV_YFUCPAD", "99999")
	Local cEscalaPad := GetNewPar("MV_YESCPAD", "999999")
	Local cCodEscala := cEscalaPad
	Local cCodFuncao := cFuncaoPad
	Local nLinhaGrd	 := 0
	Local aErro		 := {}
	Local lRet		 := .T.
	Local aParam     := {}
	Local aRetParm	 := {}
	Local _dDtInicio := Ctod(Space(8))
	Private dDtInicio:= Ctod(Space(8))

	aAdd(aParam,{1, "Vigencia Inicial"	, _dDtInicio ,"" ,"" ,"",".T.",80, .T. })

	If ParamBox( aParam, "Parametros Transferencia", @aRetParm,{||.T.} ,,,,,,"U_RTECF002", .F., .F. )
		If Empty(aRetParm[1])
			lRet := .F.
		EndIf
		If  lRet
			dDtInicio := aRetParm[1]
		EndIf
	Else
		lRet := .F.
	EndIf

	If !lRet
		MV_PAR01 := _MVPAR01
		RestArea(aAreaAtual)
		Return
	EndIf

	cQuery := " "
	cQuery += " SELECT TFJ.* FROM "+RetSqlName("CN9")+" CN9 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("TFJ")+" TFJ (NOLOCK) ON TFJ_FILIAL = CN9_FILIAL AND  TFJ_CONTRT = CN9_NUMERO  AND TFJ_CONREV = CN9_REVISA AND TFJ.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName("ADY")+" ADY (NOLOCK) ON ADY_FILIAL = TFJ_FILIAL AND ADY_PROPOS = TFJ_PROPOS AND ADY_PREVIS = TFJ_PREVIS AND ADY.D_E_L_E_T_='' "
	cQuery += " INNER JOIN "+RetSqlName("AD1")+" AD1 (NOLOCK) ON AD1_FILIAL = ADY_FILIAL AND ADY_OPORTU = AD1_NROPOR AND ADY_REVISA = AD1_REVISA AND AD1.D_E_L_E_T_='' "
	cQuery += " WHERE CN9.D_E_L_E_T_ = '' "
	cQuery += " AND CN9_REVATU = '' "
	cQuery += " AND AD1_FILIAL = '"+AD1->AD1_YFILOR+"' "
	cQuery += " AND AD1_NROPOR = '"+AD1->AD1_YNROPO+"' "
	cQuery += " AND AD1_REVISA = '"+AD1->AD1_YREVIS+"' "

	IF SELECT("T01") > 0
		T01->(DbCloseArea())
	ENDIF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T01", .F., .T. )

	If !T01->(EOF())
		oModelTFJ:SetValue("TFJ_CONDPG", T01->TFJ_CONDPG)
		oModelTFJ:SetValue("TFJ_AGRUP" , T01->TFJ_AGRUP)
		oModelTFJ:SetValue("TFJ_GRPRH" , T01->TFJ_GRPRH)
		oModelTFJ:SetValue("TFJ_TES"   , T01->TFJ_TES)
		oModelTFJ:SetValue("TFJ_GRPMI" , T01->TFJ_GRPMI)
		oModelTFJ:SetValue("TFJ_TESMI" , T01->TFJ_TESMI)
		oModelTFJ:SetValue("TFJ_GRPMC" , T01->TFJ_GRPMC)
		oModelTFJ:SetValue("TFJ_TESMC" , T01->TFJ_TESMC)
		oModelTFJ:SetValue("TFJ_LUCRO" , T01->TFJ_LUCRO)
		oModelTFJ:SetValue("TFJ_ADM"   , T01->TFJ_ADM)
		oModelTFJ:SetValue("TFJ_GESMAT", T01->TFJ_GESMAT)
		oModelTFJ:SetValue("TFJ_TPFRET", T01->TFJ_TPFRET)
		oModelTFJ:SetValue("TFJ_GRPCOM", T01->TFJ_GRPCOM)
		oModelTFJ:SetValue("TFJ_ANTECI", T01->TFJ_ANTECI)
		oModelTFJ:SetValue("TFJ_CNTREC", T01->TFJ_CNTREC)
		oModelTFJ:SetValue("TFJ_RGMCX" , T01->TFJ_RGMCX)

		cQuery := " "
		cQuery += " SELECT * FROM "+RetSqlName("TFL")+" TFL (NOLOCK) "
		cQuery += " WHERE TFL.D_E_L_E_T_ = '' "
		cQuery += " AND TFL_FILIAL = '"+T01->TFJ_FILIAL+"' "
		cQuery += " AND TFL_CODPAI = '"+T01->TFJ_CODIGO+"' AND TFL_DTFIM >= '"+DTOS(DDATABASE)+"' "

		IF SELECT("T02") > 0
			T02->(DbCloseArea())
		ENDIF

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T02", .F., .T. )

		While(!T02->(EOF()))
			If lTFLADD
				nLinhaGrd := oModelTFL:Length()
				//oView:REFRESH()
				If nLinhaGrd == oModelTFL:AddLine()
					//erro na inclusão da linha
					lRet := oModel:VldData()
					If !lRet
						aErro   := oModel:GetErrorMessage()
						AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
						AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
						AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
						AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
						AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
						AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
						AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
						AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
						AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
						MostraErro()
						Return
					EndIf
				EndIf
				oView:REFRESH()
				oModelTFL:GoLine(oModelTFL:Length())
			EndIf
			lTFLADD := .T.

			oModelTFL:SetValue("TFL_LOCAL", T02->TFL_LOCAL)
			//oModelTFL:SetValue("TFL_DTINI", StoD(T02->TFL_DTINI))
			oModelTFL:SetValue("TFL_DTINI", dDtInicio)
			oModelTFL:SetValue("TFL_DTFIM", StoD(T02->TFL_DTFIM))
			oModelTFL:SetValue("TFL_PEDTIT", T02->TFL_PEDTIT)
			//oModelTFL:SetValue("TFL_YCC", T02->TFL_YCC)

			cQuery := " "
			cQuery += " SELECT * FROM "+RetSqlName("TFF")+" TFF (NOLOCK) "
			cQuery += " WHERE TFF.D_E_L_E_T_ = '' "
			cQuery += " AND TFF_FILIAL = '"+T02->TFL_FILIAL+"' "
			cQuery += " AND TFF_CODPAI = '"+T02->TFL_CODIGO+"' "
			cQuery += " AND TFF_LOCAL  = '"+T02->TFL_LOCAL+"' "
			cQuery += " AND TFF_PERFIM >= '"+DtoS(dDtInicio)+"' "
			cQuery += " AND TFF_COBCTR = '1' "

			IF SELECT("T03") > 0
				T03->(DbCloseArea())
			ENDIF

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T03", .F., .T. )

			While(!T03->(EOF()))
				If lTFFADD
					//oView:REFRESH()
					//oModelTFF:AddLine()
					//oView:REFRESH()
					nLinhaGrd := oModelTFF:Length()
					//oView:REFRESH()
					If nLinhaGrd == oModelTFF:AddLine()
						//erro na inclusão da linha
						lRet := oModel:VldData()
						If !lRet
							aErro   := oModel:GetErrorMessage()
							AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
							AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
							AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
							AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
							AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
							AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
							AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
							AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
							AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
							MostraErro()
							Return
						EndIf
					EndIf
					oView:REFRESH()
					oModelTFF:GoLine(oModelTFF:Length())
				EndIf
				lTFFADD := .T.

				cCodFuncao := cFuncaoPad
				cCodEscala := cEscalaPad

				cQuery := " "
				cQuery := " SELECT RJ_DESC FROM "+RetSqlName("SRJ")+ " SRJ "
				cQuery += " WHERE RJ_FILIAL = '"+ substr(xFilial('TFF'),1,2)+"' AND RJ_FUNCAO = '"+T03->TFF_FUNCAO+"' AND SRJ.D_E_L_E_T_ = '' "
				IF SELECT("TMPSRJ1") > 0
					TMPSRJ1->(DbCloseArea())
				ENDIF
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPSRJ1", .F., .T. )
				If !TMPSRJ1->(EOF())
					cQuery := " "
					cQuery := " SELECT RJ_DESC FROM "+RetSqlName("SRJ")+ " SRJ "
					cQuery += " WHERE RJ_FILIAL = '"+ substr(T03->TFF_FILIAL,1,2)+"' AND RJ_FUNCAO = '"+T03->TFF_FUNCAO+"' AND SRJ.D_E_L_E_T_ = '' "
					IF SELECT("TMPSRJ2") > 0
						TMPSRJ2->(DbCloseArea())
					ENDIF
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPSRJ2", .F., .T. )
					If !TMPSRJ2->(EOF())
						If Alltrim(TMPSRJ1->RJ_DESC) == Alltrim(TMPSRJ2->RJ_DESC)
							cCodFuncao := T03->TFF_FUNCAO
						EndIf
					EndIf
					TMPSRJ2->(DbCloseArea())
				EndIf
				TMPSRJ1->(DbCloseArea())

				cQuery := " "
				cQuery := " SELECT TDW_DESC FROM "+RetSqlName("TDW")+ " TDW "
				cQuery += " WHERE TDW_FILIAL = '"+ xFilial('TFF')+"' AND TDW_COD = '"+T03->TFF_ESCALA+"' AND TDW.D_E_L_E_T_ = '' "
				IF SELECT("TMPTDW1") > 0
					TMPTDW1->(DbCloseArea())
				ENDIF
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPTDW1", .F., .T. )
				If !TMPTDW1->(EOF())
					cQuery := " "
					cQuery := " SELECT TDW_DESC FROM "+RetSqlName("TDW")+ " TDW "
					cQuery += " WHERE TDW_FILIAL = '"+ T03->TFF_FILIAL+"' AND TDW_COD = '"+T03->TFF_ESCALA+"' AND TDW.D_E_L_E_T_ = '' "
					IF SELECT("TMPTDW2") > 0
						TMPTDW2->(DbCloseArea())
					ENDIF
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPTDW2", .F., .T. )
					If !TMPTDW2->(EOF())
						If Alltrim(TMPTDW1->TDW_DESC) == Alltrim(TMPTDW2->TDW_DESC)
							cCodEscala := T03->TFF_ESCALA
						EndIf
					EndIf
					TMPTDW2->(DbCloseArea())
				EndIf
				TMPTDW1->(DbCloseArea())

				oModelTFF:SetValue("TFF_PRODUT", T03->TFF_PRODUT)
				oModelTFF:SetValue("TFF_QTDVEN", T03->TFF_QTDVEN)
				oModelTFF:SetValue("TFF_PRCVEN", T03->TFF_PRCVEN)
				//oModelTFF:SetValue("TFF_PERINI", StoD(T03->TFF_PERINI))
				oModelTFF:SetValue("TFF_PERINI", dDtInicio)
				oModelTFF:SetValue("TFF_PERFIM", StoD(T03->TFF_PERFIM))
				oModelTFF:SetValue("TFF_HORAIN", T03->TFF_HORAIN)
				oModelTFF:SetValue("TFF_HORAFI", T03->TFF_HORAFI)
				//oModelTFF:SetValue("TFF_FUNCAO", T03->TFF_FUNCAO)
				oModelTFF:SetValue("TFF_FUNCAO", cCodFuncao)
				//oModelTFF:SetValue("TFF_TURNO" , T03->TFF_TURNO)
				//oModelTFF:SetValue("TFF_SEQTRN", T03->TFF_SEQTRN)
				//oModelTFF:SetValue("TFF_CARGO" , T03->TFF_CARGO)
				//oModelTFF:SetValue("TFF_ESCALA", T03->TFF_ESCALA)
				oModelTFF:SetValue("TFF_ESCALA", cCodEscala)
				oModelTFF:SetValue("TFF_CALEND", T03->TFF_CALEND)
				oModelTFF:SetValue("TFF_LUCRO" , T03->TFF_LUCRO)
				oModelTFF:SetValue("TFF_ADM"   , T03->TFF_ADM)
				oModelTFF:SetValue("TFF_NARMA" , T03->TFF_NARMA)
				oModelTFF:SetValue("TFF_NCOLE" , T03->TFF_NCOLE)
				oModelTFF:SetValue("TFF_INSALU", T03->TFF_INSALU)
				oModelTFF:SetValue("TFF_GRAUIN", T03->TFF_GRAUIN)
				oModelTFF:SetValue("TFF_PERICU", T03->TFF_PERICU)
				//oModelTFF:SetValue("TFF_PROCP" , T03->TFF_PROCP)
				oModelTFF:SetValue("TFF_YHE1"  , T03->TFF_YHE1)
				oModelTFF:SetValue("TFF_YHE2"  , T03->TFF_YHE2)
				oModelTFF:SetValue("TFF_YHE3"  , T03->TFF_YHE3)
				oModelTFF:SetValue("TFF_YINTRA", T03->TFF_YINTRA)

			//	oModelTFF:SetValue("TFF_PLACOD", T03->TFF_PLACOD)
			//	oModelTFF:SetValue("TFF_PLAREV", T03->TFF_PLAREV)
				TFF->(DBGOTO(T03->R_E_C_N_O_))
			//	oModelTFF:SetValue("TFF_CALCMD", TFF->TFF_CALCMD)
				oModelTFF:SetValue("TFF_TABXML", TFF->TFF_TABXML)

				cQuery := " "
				cQuery += " SELECT * FROM "+RetSqlName("TFG")+" TFG (NOLOCK) "
				cQuery += " WHERE TFG.D_E_L_E_T_ = '' "
				cQuery += " AND TFG_FILIAL = '"+T03->TFF_FILIAL+"' "
				cQuery += " AND TFG_CODPAI = '"+T03->TFF_COD+"' "
				cQuery += " AND TFG_LOCAL  = '"+T03->TFF_LOCAL+"' "

				IF SELECT("T04") > 0
					T04->(DbCloseArea())
				ENDIF

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T04", .F., .T. )

				While(!T04->(EOF()))
					If lTFGADD
						//oView:REFRESH()
						//oModelTFG:AddLine()
						//oView:REFRESH()
						nLinhaGrd := oModelTFG:Length()
						//oView:REFRESH()
						If nLinhaGrd == oModelTFG:AddLine()
							//erro na inclusão da linha
							lRet := oModel:VldData()
							If !lRet
								aErro   := oModel:GetErrorMessage()
								AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
								AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
								AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
								AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
								AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
								AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
								AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
								AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
								AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
								MostraErro()
								Return
							EndIf
						EndIf
						oView:REFRESH()
						oModelTFG:GoLine(oModelTFG:Length())
					EndIf
					If Empty(oModelTFG:GetValue("TFG_ITEM"))
						oView:REFRESH()
					EndIf
					lTFGADD := .T.

					oModelTFG:SetValue("TFG_PRODUT", T04->TFG_PRODUT)
					oModelTFG:SetValue("TFG_QTDVEN", T04->TFG_QTDVEN)
					oModelTFG:SetValue("TFG_PRCVEN", T04->TFG_PRCVEN)
					//oModelTFG:SetValue("TFG_PERINI", StoD(T04->TFG_PERINI))
					oModelTFG:SetValue("TFG_PERINI", dDtInicio)
					oModelTFG:SetValue("TFG_PERFIM", IIF(StoD(T04->TFG_PERFIM) > dDtInicio , StoD(T04->TFG_PERFIM), dDtInicio) )
					oModelTFG:SetValue("TFG_DESCON", T04->TFG_DESCON)
					oModelTFG:SetValue("TFG_LUCRO" , T04->TFG_LUCRO)
					oModelTFG:SetValue("TFG_ADM"   , T04->TFG_ADM)
					oModelTFG:SetValue("TFG_VIDMES", T04->TFG_VIDMES)
					oModelTFG:SetValue("TFG_RESRET", T04->TFG_RESRET)
					oModelTFG:SetValue("TFG_VLATIV", T04->TFG_VLATIV)
					T04->(DbSkip())
				EndDo
				T04->(DbCloseArea())
				lTFGADD := .F.

				cQuery := " "
				cQuery += " SELECT * FROM "+RetSqlName("TFH")+" TFH (NOLOCK) "
				cQuery += " WHERE TFH.D_E_L_E_T_ = '' "
				cQuery += " AND TFH_FILIAL = '"+T03->TFF_FILIAL+"' "
				cQuery += " AND TFH_CODPAI = '"+T03->TFF_COD+"' "
				cQuery += " AND TFH_LOCAL  = '"+T02->TFL_LOCAL+"' "

				IF SELECT("T05") > 0
					T05->(DbCloseArea())
				ENDIF

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T05", .F., .T. )

				While(!T05->(EOF()))
					If lTFHADD
						//oView:REFRESH()
						//oModelTFH:AddLine()
						//oView:REFRESH()
						nLinhaGrd := oModelTFH:Length()
						//oView:REFRESH()
						If nLinhaGrd == oModelTFH:AddLine()
							//erro na inclusão da linha
							lRet := oModel:VldData()
							If !lRet
								aErro   := oModel:GetErrorMessage()
								AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
								AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
								AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
								AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
								AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
								AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
								AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
								AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
								AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
								MostraErro()
								Return
							EndIf
						EndIf
						oView:REFRESH()
						oModelTFH:GoLine(oModelTFH:Length())
					EndIf
					lTFHADD := .T.

					oModelTFH:SetValue("TFH_PRODUT", T05->TFH_PRODUT )
					oModelTFH:SetValue("TFH_QTDVEN", T05->TFH_QTDVEN )
					oModelTFH:SetValue("TFH_PRCVEN", T05->TFH_PRCVEN )
					//oModelTFH:SetValue("TFH_PERINI", StoD(T05->TFH_PERINI) )
					oModelTFH:SetValue("TFH_PERINI", dDtInicio )
					oModelTFH:SetValue("TFH_PERFIM", IIF(StoD(T05->TFH_PERFIM) > dDtInicio , StoD(T05->TFH_PERFIM), dDtInicio))
					oModelTFH:SetValue("TFH_DESCON", T05->TFH_DESCON )
					oModelTFH:SetValue("TFH_LUCRO" , T05->TFH_LUCRO )
					oModelTFH:SetValue("TFH_ADM"   , T05->TFH_ADM )
					oModelTFH:SetValue("TFH_VIDMES", T05->TFH_VIDMES )
					T05->(DbSkip())
				EndDo
				T05->(DbCloseArea())
				lTFHADD := .F.

				T03->(DbSkip())
			EndDo
			T03->(DbCloseArea())
			lTFFADD := .F.
			oView:REFRESH()
			T02->(DbSkip())
		EndDo
		T02->(DbCloseArea())

	EndIf

	T01->(DbCloseArea())
	oView:REFRESH()

	MV_PAR01 := _MVPAR01
	RestArea(aAreaAtual)
	u_fReplVig() //Chama a rotina de cálculo conforme XML

Return

/*
User Function RTECF002()
	Local aAreaAtual := GetArea()
	Local oModel	 := FWModelActive()
	Local oModelTFJ  := oModel:GetModel('TFJ_REFER')
	Local oModelTFL  := oModel:GetModel('TFL_LOC')
	Local oModelTFF  := oModel:GetModel('TFF_RH')
	Local oModelTFG  := oModel:GetModel('TFG_MI')
	Local oModelTFH  := oModel:GetModel('TFH_MC')
	Local oView 	 := FWViewActive()
	Local cQuery	 := ""
	Local lTFLADD	 := .F.
	Local lTFFADD	 := .F.
	Local lTFGADD	 := .F.
	Local lTFHADD	 := .F.
	Local _MVPAR01   := MV_PAR01

	Local cFuncaoPad := GetNewPar("MV_YFUCPAD", "99999")
	Local cEscalaPad := GetNewPar("MV_YESCPAD", "999999")
	Local cCodEscala := cEscalaPad
	Local cCodFuncao := cFuncaoPad
	Local nLinhaGrd	 := 0
	Local aErro		 := {}
	Local lRet		 := .T.
	Local aParam     := {}
	Local aRetParm	 := {}
	Local _dDtInicio := Ctod(Space(8))
	Private dDtInicio:= Ctod(Space(8))

	aAdd(aParam,{1, "Vigerncia Inicial"	, _dDtInicio ,"" ,"" ,"",".T.",80, .T. })

	If ParamBox( aParam, "Parametros Transferencia", @aRetParm,{||.T.} ,,,,,,"U_RTECF002", .F., .F. )
		If Empty(aRetParm[1])
			lRet := .F.
		EndIf
		If  lRet
			dDtInicio := aRetParm[1]
		EndIf
	Else
		lRet := .F.
	EndIf

	If !lRet
		MV_PAR01 := _MVPAR01
		RestArea(aAreaAtual)
		Return
	EndIf

	cQuery := " "
	cQuery += " SELECT TFJ.* FROM "+RetSqlName("CN9")+" CN9 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("TFJ")+" TFJ (NOLOCK) ON TFJ_FILIAL = CN9_FILIAL AND  TFJ_CONTRT = CN9_NUMERO  AND TFJ_CONREV = CN9_REVISA AND TFJ.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN "+RetSqlName("ADY")+" ADY (NOLOCK) ON ADY_FILIAL = TFJ_FILIAL AND ADY_PROPOS = TFJ_PROPOS AND ADY_PREVIS = TFJ_PREVIS AND ADY.D_E_L_E_T_='' "
	cQuery += " INNER JOIN "+RetSqlName("AD1")+" AD1 (NOLOCK) ON AD1_FILIAL = ADY_FILIAL AND ADY_OPORTU = AD1_NROPOR AND ADY_REVISA = AD1_REVISA AND AD1.D_E_L_E_T_='' "
	cQuery += " WHERE CN9.D_E_L_E_T_ = '' "
	cQuery += " AND CN9_REVATU = '' "
	cQuery += " AND AD1_FILIAL = '"+AD1->AD1_YFILOR+"' "
	cQuery += " AND AD1_NROPOR = '"+AD1->AD1_YNROPO+"' "
	cQuery += " AND AD1_REVISA = '"+AD1->AD1_YREVIS+"' "

	IF SELECT("T01") > 0
		T01->(DbCloseArea())
	ENDIF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T01", .F., .T. )

	If !T01->(EOF())
		oModelTFJ:SetValue("TFJ_CONDPG", T01->TFJ_CONDPG)
		oModelTFJ:SetValue("TFJ_AGRUP" , T01->TFJ_AGRUP)
		oModelTFJ:SetValue("TFJ_GRPRH" , T01->TFJ_GRPRH)
		oModelTFJ:SetValue("TFJ_TES"   , T01->TFJ_TES)
		oModelTFJ:SetValue("TFJ_GRPMI" , T01->TFJ_GRPMI)
		oModelTFJ:SetValue("TFJ_TESMI" , T01->TFJ_TESMI)
		oModelTFJ:SetValue("TFJ_GRPMC" , T01->TFJ_GRPMC)
		oModelTFJ:SetValue("TFJ_TESMC" , T01->TFJ_TESMC)
		oModelTFJ:SetValue("TFJ_LUCRO" , T01->TFJ_LUCRO)
		oModelTFJ:SetValue("TFJ_ADM"   , T01->TFJ_ADM)
		oModelTFJ:SetValue("TFJ_GESMAT", T01->TFJ_GESMAT)
		oModelTFJ:SetValue("TFJ_TPFRET", T01->TFJ_TPFRET)
		oModelTFJ:SetValue("TFJ_GRPCOM", T01->TFJ_GRPCOM)
		oModelTFJ:SetValue("TFJ_ANTECI", T01->TFJ_ANTECI)
		oModelTFJ:SetValue("TFJ_CNTREC", T01->TFJ_CNTREC)
		oModelTFJ:SetValue("TFJ_RGMCX" , T01->TFJ_RGMCX)

		cQuery := " "
		cQuery += " SELECT * FROM "+RetSqlName("TFL")+" TFL (NOLOCK) "
		cQuery += " WHERE TFL.D_E_L_E_T_ = '' "
		cQuery += " AND TFL_FILIAL = '"+T01->TFJ_FILIAL+"' "
		cQuery += " AND TFL_CODPAI = '"+T01->TFJ_CODIGO+"' "

		IF SELECT("T02") > 0
			T02->(DbCloseArea())
		ENDIF

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T02", .F., .T. )

		While(!T02->(EOF()))
			If lTFLADD
				nLinhaGrd := oModelTFL:Length()
				//oView:REFRESH()
				If nLinhaGrd == oModelTFL:AddLine()
					//erro na inclusão da linha
					lRet := oModel:VldData()
					If !lRet
						aErro   := oModel:GetErrorMessage()
						AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
						AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
						AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
						AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
						AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
						AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
						AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
						AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
						AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
						MostraErro()
						Return
					EndIf
				EndIf
				oView:REFRESH()
			EndIf
			lTFLADD := .T.

			oModelTFL:SetValue("TFL_LOCAL", T02->TFL_LOCAL)
			//oModelTFL:SetValue("TFL_DTINI", StoD(T02->TFL_DTINI))
			oModelTFL:SetValue("TFL_DTINI", dDtInicio)
			oModelTFL:SetValue("TFL_DTFIM", StoD(T02->TFL_DTFIM))
			oModelTFL:SetValue("TFL_PEDTIT", T02->TFL_PEDTIT)
			oModelTFL:SetValue("TFL_YCC", T02->TFL_YCC)

			cQuery := " "
			cQuery += " SELECT * FROM "+RetSqlName("TFF")+" TFF (NOLOCK) "
			cQuery += " WHERE TFF.D_E_L_E_T_ = '' "
			cQuery += " AND TFF_FILIAL = '"+T02->TFL_FILIAL+"' "
			cQuery += " AND TFF_CODPAI = '"+T02->TFL_CODIGO+"' "
			cQuery += " AND TFF_LOCAL  = '"+T02->TFL_LOCAL+"' "
			cQuery += " AND TFF_PERFIM >= '"+DtoS(dDtInicio)+"' "
			cQuery += " AND TFF_COBCTR = '1' "

			IF SELECT("T03") > 0
				T03->(DbCloseArea())
			ENDIF

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T03", .F., .T. )

			While(!T03->(EOF()))
				If lTFFADD
					//oView:REFRESH()
					//oModelTFF:AddLine()
					//oView:REFRESH()
					nLinhaGrd := oModelTFF:Length()
					//oView:REFRESH()
					If nLinhaGrd == oModelTFF:AddLine()
						//erro na inclusão da linha
						lRet := oModel:VldData()
						If !lRet
							aErro   := oModel:GetErrorMessage()
							AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
							AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
							AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
							AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
							AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
							AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
							AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
							AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
							AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
							MostraErro()
							Return
						EndIf
					EndIf
					//oView:REFRESH()
				EndIf
				lTFFADD := .T.

				cCodFuncao := cFuncaoPad
				cCodEscala := cEscalaPad

				cQuery := " "
				cQuery := " SELECT RJ_DESC FROM "+RetSqlName("SRJ")+ " SRJ "
				cQuery += " WHERE RJ_FILIAL = '"+ substr(xFilial('TFF'),1,2)+"' AND RJ_FUNCAO = '"+T03->TFF_FUNCAO+"' AND SRJ.D_E_L_E_T_ = '' "
				IF SELECT("TMPSRJ1") > 0
					TMPSRJ1->(DbCloseArea())
				ENDIF
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPSRJ1", .F., .T. )
				If !TMPSRJ1->(EOF())
					cQuery := " "
					cQuery := " SELECT RJ_DESC FROM "+RetSqlName("SRJ")+ " SRJ "
					cQuery += " WHERE RJ_FILIAL = '"+ substr(T03->TFF_FILIAL,1,2)+"' AND RJ_FUNCAO = '"+T03->TFF_FUNCAO+"' AND SRJ.D_E_L_E_T_ = '' "
					IF SELECT("TMPSRJ2") > 0
						TMPSRJ2->(DbCloseArea())
					ENDIF
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPSRJ2", .F., .T. )
					If !TMPSRJ2->(EOF())
						If Alltrim(TMPSRJ1->RJ_DESC) == Alltrim(TMPSRJ2->RJ_DESC)
							cCodFuncao := T03->TFF_FUNCAO
						EndIf
					EndIf
					TMPSRJ2->(DbCloseArea())
				EndIf
				TMPSRJ1->(DbCloseArea())

				cQuery := " "
				cQuery := " SELECT TDW_DESC FROM "+RetSqlName("TDW")+ " TDW "
				cQuery += " WHERE TDW_FILIAL = '"+ xFilial('TFF')+"' AND TDW_COD = '"+T03->TFF_ESCALA+"' AND TDW.D_E_L_E_T_ = '' "
				IF SELECT("TMPTDW1") > 0
					TMPTDW1->(DbCloseArea())
				ENDIF
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPTDW1", .F., .T. )
				If !TMPTDW1->(EOF())
					cQuery := " "
					cQuery := " SELECT TDW_DESC FROM "+RetSqlName("TDW")+ " TDW "
					cQuery += " WHERE TDW_FILIAL = '"+ T03->TFF_FILIAL+"' AND TDW_COD = '"+T03->TFF_ESCALA+"' AND TDW.D_E_L_E_T_ = '' "
					IF SELECT("TMPTDW2") > 0
						TMPTDW2->(DbCloseArea())
					ENDIF
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TMPTDW2", .F., .T. )
					If !TMPTDW2->(EOF())
						If Alltrim(TMPTDW1->TDW_DESC) == Alltrim(TMPTDW2->TDW_DESC)
							cCodEscala := T03->TFF_ESCALA
						EndIf
					EndIf
					TMPTDW2->(DbCloseArea())
				EndIf
				TMPTDW1->(DbCloseArea())

				oModelTFF:SetValue("TFF_PRODUT", T03->TFF_PRODUT)
				oModelTFF:SetValue("TFF_QTDVEN", T03->TFF_QTDVEN)
				oModelTFF:SetValue("TFF_PRCVEN", T03->TFF_PRCVEN)
				//oModelTFF:SetValue("TFF_PERINI", StoD(T03->TFF_PERINI))
				oModelTFF:SetValue("TFF_PERINI", dDtInicio)
				oModelTFF:SetValue("TFF_PERFIM", StoD(T03->TFF_PERFIM))
				oModelTFF:SetValue("TFF_HORAIN", T03->TFF_HORAIN)
				oModelTFF:SetValue("TFF_HORAFI", T03->TFF_HORAFI)
				//oModelTFF:SetValue("TFF_FUNCAO", T03->TFF_FUNCAO)
				oModelTFF:SetValue("TFF_FUNCAO", cCodFuncao)
				//oModelTFF:SetValue("TFF_TURNO" , T03->TFF_TURNO)
				//oModelTFF:SetValue("TFF_SEQTRN", T03->TFF_SEQTRN)
				//oModelTFF:SetValue("TFF_CARGO" , T03->TFF_CARGO)
				//oModelTFF:SetValue("TFF_ESCALA", T03->TFF_ESCALA)
				oModelTFF:SetValue("TFF_ESCALA", cCodEscala)
				oModelTFF:SetValue("TFF_CALEND", T03->TFF_CALEND)
				oModelTFF:SetValue("TFF_LUCRO" , T03->TFF_LUCRO)
				oModelTFF:SetValue("TFF_ADM"   , T03->TFF_ADM)
				oModelTFF:SetValue("TFF_NARMA" , T03->TFF_NARMA)
				oModelTFF:SetValue("TFF_NCOLE" , T03->TFF_NCOLE)
				oModelTFF:SetValue("TFF_INSALU", T03->TFF_INSALU)
				oModelTFF:SetValue("TFF_GRAUIN", T03->TFF_GRAUIN)
				oModelTFF:SetValue("TFF_PERICU", T03->TFF_PERICU)
				//oModelTFF:SetValue("TFF_PROCP" , T03->TFF_PROCP)
				oModelTFF:SetValue("TFF_YHE1"  , T03->TFF_YHE1)
				oModelTFF:SetValue("TFF_YHE2"  , T03->TFF_YHE2)
				oModelTFF:SetValue("TFF_YHE3"  , T03->TFF_YHE3)
				oModelTFF:SetValue("TFF_YINTRA", T03->TFF_YINTRA)

				oModelTFF:SetValue("TFF_PLACOD", T03->TFF_PLACOD)
				oModelTFF:SetValue("TFF_PLAREV", T03->TFF_PLAREV)
				TFF->(DBGOTO(T03->R_E_C_N_O_))
				oModelTFF:SetValue("TFF_CALCMD", TFF->TFF_CALCMD)
				//oModelTFF:LoadValue("TFJ_TABXML", T03->TFJ_TABXML)

				cQuery := " "
				cQuery += " SELECT * FROM "+RetSqlName("TFG")+" TFG (NOLOCK) "
				cQuery += " WHERE TFG.D_E_L_E_T_ = '' "
				cQuery += " AND TFG_FILIAL = '"+T03->TFF_FILIAL+"' "
				cQuery += " AND TFG_CODPAI = '"+T03->TFF_COD+"' "
				cQuery += " AND TFG_LOCAL  = '"+T03->TFF_LOCAL+"' "

				IF SELECT("T04") > 0
					T04->(DbCloseArea())
				ENDIF

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T04", .F., .T. )

				While(!T04->(EOF()))
					If lTFGADD
						//oView:REFRESH()
						//oModelTFG:AddLine()
						//oView:REFRESH()
						nLinhaGrd := oModelTFG:Length()
						//oView:REFRESH()
						If nLinhaGrd == oModelTFG:AddLine()
							//erro na inclusão da linha
							lRet := oModel:VldData()
							If !lRet
								aErro   := oModel:GetErrorMessage()
								AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
								AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
								AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
								AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
								AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
								AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
								AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
								AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
								AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
								MostraErro()
								Return
							EndIf
						EndIf
						//oView:REFRESH()
					EndIf
					If Empty(oModelTFG:GetValue("TFG_ITEM"))
						oView:REFRESH()
					EndIf
					lTFGADD := .T.

					oModelTFG:SetValue("TFG_PRODUT", T04->TFG_PRODUT)
					oModelTFG:SetValue("TFG_QTDVEN", T04->TFG_QTDVEN)
					oModelTFG:SetValue("TFG_PRCVEN", T04->TFG_PRCVEN)
					//oModelTFG:SetValue("TFG_PERINI", StoD(T04->TFG_PERINI))
					oModelTFG:SetValue("TFG_PERINI", dDtInicio)
					oModelTFG:SetValue("TFG_PERFIM", StoD(T04->TFG_PERFIM))
					oModelTFG:SetValue("TFG_DESCON", T04->TFG_DESCON)
					oModelTFG:SetValue("TFG_LUCRO" , T04->TFG_LUCRO)
					oModelTFG:SetValue("TFG_ADM"   , T04->TFG_ADM)
					oModelTFG:SetValue("TFG_VIDMES", T04->TFG_VIDMES)
					oModelTFG:SetValue("TFG_RESRET", T04->TFG_RESRET)
					oModelTFG:SetValue("TFG_VLATIV", T04->TFG_VLATIV)
					T04->(DbSkip())
				EndDo
				T04->(DbCloseArea())
				lTFGADD := .F.

				cQuery := " "
				cQuery += " SELECT * FROM "+RetSqlName("TFH")+" TFH (NOLOCK) "
				cQuery += " WHERE TFH.D_E_L_E_T_ = '' "
				cQuery += " AND TFH_FILIAL = '"+T03->TFF_FILIAL+"' "
				cQuery += " AND TFH_CODPAI = '"+T03->TFF_COD+"' "
				cQuery += " AND TFH_LOCAL  = '"+T02->TFL_LOCAL+"' "

				IF SELECT("T05") > 0
					T05->(DbCloseArea())
				ENDIF

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "T05", .F., .T. )

				While(!T05->(EOF()))
					If lTFHADD
						//oView:REFRESH()
						//oModelTFH:AddLine()
						//oView:REFRESH()
						nLinhaGrd := oModelTFH:Length()
						//oView:REFRESH()
						If nLinhaGrd == oModelTFH:AddLine()
							//erro na inclusão da linha
							lRet := oModel:VldData()
							If !lRet
								aErro   := oModel:GetErrorMessage()
								AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
								AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
								AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
								AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
								AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
								AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
								AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
								AutoGrLog( "Valor atribuído:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
								AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
								MostraErro()
								Return
							EndIf
						EndIf
						//oView:REFRESH()
					EndIf
					lTFHADD := .T.

					oModelTFH:SetValue("TFH_PRODUT", T05->TFH_PRODUT )
					oModelTFH:SetValue("TFH_QTDVEN", T05->TFH_QTDVEN )
					oModelTFH:SetValue("TFH_PRCVEN", T05->TFH_PRCVEN )
					//oModelTFH:SetValue("TFH_PERINI", StoD(T05->TFH_PERINI) )
					oModelTFH:SetValue("TFH_PERINI", dDtInicio )
					oModelTFH:SetValue("TFH_PERFIM", StoD(T05->TFH_PERFIM) )
					oModelTFH:SetValue("TFH_DESCON", T05->TFH_DESCON )
					oModelTFH:SetValue("TFH_LUCRO" , T05->TFH_LUCRO )
					oModelTFH:SetValue("TFH_ADM"   , T05->TFH_ADM )
					oModelTFH:SetValue("TFH_VIDMES", T05->TFH_VIDMES )
					T05->(DbSkip())
				EndDo
				T05->(DbCloseArea())
				lTFHADD := .F.

				T03->(DbSkip())
			EndDo
			T03->(DbCloseArea())
			lTFFADD := .F.
			oView:REFRESH()
			T02->(DbSkip())
		EndDo
		T02->(DbCloseArea())

	EndIf

	T01->(DbCloseArea())
	oView:REFRESH()

	MV_PAR01 := _MVPAR01
	RestArea(aAreaAtual)

Return
*/
