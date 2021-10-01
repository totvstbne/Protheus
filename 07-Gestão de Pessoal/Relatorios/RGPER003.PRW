#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} RGPER003
Função para calculo dos descontos no beneficio Cesta Basica Servnac
@author edlardo neves - mconsult
@since 16/11/2020
@version 1.0
/*/
//*****************************************************************************
User Function RGPER003(cPdRot)
//*****************************************************************************
	Local aAreaAtual := GetArea()
	Local nValCB   := 0
	Local nDiasPeriodo := 30//(DateDiffDay(dDataDe, dDataAte) + 1 )
	Local nDiasProporc := ACALCRI1[1][9]//(DateDiffDay(dDataDe, dDataAte) + 1 )
	Local dDtFimPer := stod(substr(dtos(dDataAte),1,6)+"30")
	Local dPerDe	:= 	MonthSub(stod(Substr(DtoS(dDataDe),1,6)+"21" ), 2)
	Local dPerAte	:=  MonthSub(stod(Substr(DtoS(dDataDe),1,6)+"20" ), 1)
	Local dDtAtual  := dPerDe
	Local nDiasSR8  := 0
	Local nDiasFer  := 0
	Local cQuery    := ""
	//lOCAL _ddatate4 := stod(substr(dtos(dDataAte),1,6)+"30")

	DEFAULT cPdRot := ""

	cVerbaRot := cPdRot
	//Beneficio 81 - Cesta Basica
	IF ALLTRIM(ABENRI1[1][2]) = "81"  .and. diastrab > 0
		//Verifica se o colaborador está cumprindo aviso previo
		DbselectArea("RFY")
		DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
		Dbseek(SRA->(RA_FILIAL+RA_MAT) )
		If FOUND() .AND. EMPTY(RFY->RFY_DTCAP)
			While !EOF() .and. RFY->(RFY_FILIAL+RFY_MAT) == SRA->(RA_FILIAL+RA_MAT)
				If !Empty(RFY->RFY_DTPJAV )
					//Realiza calculo proporcional do beneficio Cesta Basica
					If RFY->RFY_DTPJAV < dDataDE
						ACALCRI1[1][2] := 0
						ACALCRI1[1][4] := 0
						ACALCRI1[1][9] := 0
                        nDiasProporc := 0
						AADD(aGpem020TitLog, "Funcionario encerrando aviso previo na data: "+DtoC(RFY->RFY_DTPJAV)+". Dados funcionario Filial-Matricula-Nome"+ Alltrim(SRA->RA_FILIAL) +" - "+ Alltrim(SRA->RA_MAT) +" - "+ Alltrim(SRA->RA_NOME) )
					ELSEIf RFY->RFY_DTPJAV < dDataAte
						dDtFimPer := RFY->RFY_DTPJAV
						nDiasPeriodo := 30//(DateDiffDay(dDataDe, dDataAte) + 1 )
						nDiasProporc := ACALCRI1[1][9] - DateDiffDay( RFY->RFY_DTPJAV , dDataAte)
						nValCB := (nDiasProporc * RIS->RIS_REF)/nDiasPeriodo
						If nValCB > 0
							ACALCRI1[1][2] := nValCB
							ACALCRI1[1][4] := nValCB
							ACALCRI1[1][9] := nDiasProporc
							AADD(aGpem020TitLog, "Funcionario encerrando aviso previo na data: "+DtoC(RFY->RFY_DTPJAV)+". Dados funcionario Filial-Matricula-Nome"+ Alltrim(SRA->RA_FILIAL) +" - "+ Alltrim(SRA->RA_MAT) +" - "+ Alltrim(SRA->RA_NOME) )
						else
							ACALCRI1[1][2] := 0
							ACALCRI1[1][4] := 0
							ACALCRI1[1][9] := 0
							AADD(aGpem020TitLog, "Funcionario encerrando aviso previo na data: "+DtoC(RFY->RFY_DTPJAV)+". Dados funcionario Filial-Matricula-Nome"+ Alltrim(SRA->RA_FILIAL) +" - "+ Alltrim(SRA->RA_MAT) +" - "+ Alltrim(SRA->RA_NOME) )
						EndIf
					EndIf

					Exit

				EndIf
				dbSkip()
			Enddo
		EndIf

		//Verifica lançamento de ausencias SR8
		If nDiasProporc > 0
			While dDtAtual <=  dPerAte
				cQuery := "  SELECT R8_MAT "
				cQuery += "  FROM "+RetSqlName("SR8")+ " SR8 "
				cQuery += " INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = '' "
				cQuery += "  WHERE SR8.D_E_L_E_T_='' "
				cQuery += "  AND R8_MAT = '"+ SRA->RA_MAT +"' AND  R8_FILIAL ='"+ SRA->RA_FILIAL +"' "
				cQuery += "  AND ( '"+dtos(dDtAtual)+"' BETWEEN R8_DATAINI AND R8_DATAFIM  ) "
				cQuery += "  AND RCM_YCESTA = 'S' "

				If select("TEMPSR8") > 0
					TEMPSR8->(dbCloseArea())
				Endif
				TcQuery cQuery new Alias TEMPSR8

				If !TEMPSR8->(eof())
					nDiasSR8 += 1
				Endif
				TEMPSR8->(dbCloseArea())
				dDtAtual := DaySum(dDtAtual,1)
			ENDDO

			IF nDiasSR8 > 0
				nDiasProporc := IIF(nDiasProporc > nDiasSR8 , nDiasProporc - nDiasSR8, 0  )
				nValCB := (nDiasProporc * RIS->RIS_REF)/nDiasPeriodo
				If nValCB > 0
					ACALCRI1[1][2] := nValCB
					ACALCRI1[1][4] := nValCB
					ACALCRI1[1][9] := nDiasProporc
				else
					ACALCRI1[1][2] := 0
					ACALCRI1[1][4] := 0
					ACALCRI1[1][9] := 0
				EndIf
			EndIf
		EndIf

		//Verifica lançamento de Ferias SRH
		If nDiasProporc > 0
			dDtAtual := dDataDe
			While dDtAtual <=  dDtFimPer
				cQuery := "  SELECT RH_MAT "
				cQuery += "  FROM "+RetSqlName("SRH")+ " SRH "
				cQuery += "  WHERE D_E_L_E_T_='' "
				cQuery += "  AND RH_MAT = '"+ SRA->RA_MAT +"' AND  RH_FILIAL ='"+ SRA->RA_FILIAL +"' "
				cQuery += "  AND ( '"+dtos(dDtAtual)+"' BETWEEN RH_DATAINI AND RH_DATAFIM  ) "

				If select("TEMPSRH") > 0
					TEMPSRH->(dbCloseArea())
				Endif
				TcQuery cQuery new Alias TEMPSRH

				If !TEMPSRH->(eof())
					nDiasFer += 1
				Endif
				TEMPSRH->(dbCloseArea())
				dDtAtual := DaySum(dDtAtual,1)
			ENDDO

			IF nDiasFer > 0
				nDiasProporc := IIF(nDiasProporc > nDiasFer , nDiasProporc - nDiasFer, 0  )
				nValCB := ( nDiasProporc * RIS->RIS_REF ) / nDiasPeriodo
				If nValCB > 0
					ACALCRI1[1][2] := nValCB
					ACALCRI1[1][4] := nValCB
					ACALCRI1[1][9] := nDiasProporc
				else
					ACALCRI1[1][2] := 0
					ACALCRI1[1][4] := 0
					ACALCRI1[1][9] := 0
				EndIf
			EndIf
		EndIf

	ENDIF

	RestArea(aAreaAtual)

Return

