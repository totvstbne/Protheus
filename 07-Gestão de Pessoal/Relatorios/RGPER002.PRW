#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} RGPER002
Função para calculo da periculosidade Servnac
@author edlardo neves - mconsult
@since 12/11/2020
@version 1.0
@return Lógico, .T. se pode calcular .F. caso contrário
/*/
//*****************************************************************************
User Function RGPER002(cPdRot)
//*****************************************************************************
	Local aAreaAtual := GetArea()
	Local nPosPd     := 0
	Local nVlrSalBase:= 0
	Local LTEMPERI := GetValType('L')

	Local dPerDe	:= dDataDe
	Local dPerAte	:= dDataAte
	Local dDtAtual  := dPerDe
	Local nDiasSR8  := 0
	Local nVlrProp  := 0
	Local nDiasProp := 0
	Local nVlrDia   := 0
	Local nDiasAdmi := IIF(SRA->RA_ADMISSA>dDataDe, DATEDIFFDAY(dDataDe,SRA->RA_ADMISSA), 0  )

	DEFAULT cPdRot := ""

	cVerbaRot := cPdRot

	Begin Sequence
		If ( AbortProc() )
			Break
		EndIf

		IF ( ( ( CTIPOROT == "2" .AND. P_SOMAINC ) .OR. (CTIPOROT # "2") ) )

			NPERIC := 0

			CBCALPER := FBUSCARG4("RCE_BCALPE",DDATAATE,.T.,.T.)

			IF ( SRA->RA_ADCPERI == "2" .OR. LDISSIDIO )

				LTEMPERI := IF(SRA->RA_ADCPERI == "2", .T., !EMPTY(GPRETSR9( "SRA", DDATAATE, "RA_PERICUL" )))

				IF ( CBCALPER  $ "1/3/4/5" .AND. LTEMPERI )

					CCODPER := CVERBAROT

					NHRSPERI := SRA->RA_PERICUL

					NPERC_PERI := RCE->RCE_PERPE

					IF ( EMPTY(CCODPER) )

						IF ( CTIPOROT $ "1*2*4" )

							CCODPER := FGETCODFOL('0036')

						EndIF


						IF ( CTIPOROT == "3" )

							CCODPER := FGETCODFOL('1300')

						EndIF

						IF ( CTIPOROT $ "5*6" )

							IF ( CTIPOROT == "5" )

								CCODPER := FGETCODFOL('1632')

								IF ( LVB13MAT2 )

									CCODPERM := FGETCODFOL('1643')

								EndIF


								IF ( !LVB13MAT2 )

									CCODPERM := FGETCODFOL('1440')

								EndIF

							EndIF

							IF ( CTIPOROT == "6" )

								CCODPER := FGETCODFOL('1290')

								CCODPERM := FGETCODFOL('1440')

							EndIF

						EndIF

					EndIF

				EndIF

				IF ( CBCALPER $ "2/6/7/8" .AND. LTEMPERI )

					CCODPER := CVERBAROT

					NHRSPERI := SRA->RA_PERICUL

					NPERC_PERI := RCE->RCE_PERPE

					LPROPDIA := !(CTIPOROT $ "3*5*6")

					IF ( EMPTY(CCODPER) )

						IF ( CTIPOROT $ "1*2*4" )

							CCODPER := FGETCODFOL('1281')

						EndIF

						IF ( CTIPOROT == "3" )

							CCODPER := FGETCODFOL('1302')

						EndIF

						IF ( CTIPOROT $ "5*6" )

							IF ( CTIPOROT == "5" )

								CCODPER := FGETCODFOL('1633')

								IF ( LVB13MAT2 )

									CCODPERM := FGETCODFOL('1644')

								EndIF

								IF ( !LVB13MAT2 )

									CCODPERM := FGETCODFOL('1441')

								EndIF

							EndIF

							IF ( CTIPOROT == "6" )

								CCODPER := FGETCODFOL('1291')

								CCODPERM := FGETCODFOL('1441')

							EndIF

						EndIF

					EndIF

				EndIF

			EndIF


			If Alltrim(CCODPER) <> ""
				nPosPd     := fLocaliaPd(CCODPER)
				nVlrSalBase := Salario//SALHORA*NHRSPERI
				If nVlrSalBase > 0 .and. nPosPd > 0 .AND. NPERC_PERI > 0

					nDiasSR8 := 0
					While dDtAtual <= dPerAte
						//Busca Ferias
						cQuery := "  SELECT R8_MAT "
						cQuery += "  FROM "+RetSqlName("SR8")+ " SR8 "
						cQuery += "  INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = '' "
						cQuery += "  WHERE SR8.D_E_L_E_T_='' "
						cQuery += "  AND R8_MAT = '"+ SRA->RA_MAT +"' AND  R8_FILIAL ='"+ SRA->RA_FILIAL +"' "
						cQuery += "  AND ( '"+dtos(dDtAtual)+"' BETWEEN R8_DATAINI AND R8_DATAFIM  ) "
						cQuery += "  AND RCM_YPERIC = 'S' AND RCM_TIPO = '001' "

						If select("TEMPSR8") > 0
							TEMPSR8->(dbCloseArea())
						Endif
						TcQuery cQuery new Alias TEMPSR8

						If !TEMPSR8->(eof())
							nDiasSR8 += 1
						Endif
						TEMPSR8->(dbCloseArea())


						//Busca Afastamentos P/ Desconto
						cQuery := "  SELECT SR8.* "
						cQuery += "  FROM "+RetSqlName("SR8")+ " SR8 "
						cQuery += "  INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = '' "
						cQuery += "  WHERE SR8.D_E_L_E_T_='' "
						cQuery += "  AND R8_MAT = '"+ SRA->RA_MAT +"' AND  R8_FILIAL ='"+ SRA->RA_FILIAL +"' "
						cQuery += "  AND ( "
						cQuery += "  ( '"+dtos(dDtAtual)+"' BETWEEN R8_DATAINI AND R8_DATAFIM  ) "
						cQuery += "  OR "
						cQuery += "  ( '"+dtos(dDtAtual)+"' >= R8_DATAINI AND R8_DATAFIM = '' ) "
						cQuery += "  ) "
						cQuery += "  AND RCM_YPERIC = 'S' AND RCM_TIPO <> '001' "
						cQuery += "  AND R8_DURACAO <> R8_DPAGAR "

						If select("TEMPSR8") > 0
							TEMPSR8->(dbCloseArea())
						Endif
						TcQuery cQuery new Alias TEMPSR8

						If !TEMPSR8->(eof())
							IF TEMPSR8->R8_DPAGAR <= 0
								nDiasSR8 += 1
							Else
								If dDtAtual >= DaySum( StoD(TEMPSR8->R8_DATAINI), TEMPSR8->R8_DPAGAR )
									nDiasSR8 += 1
								EndIf
							EndIf
						Endif
						TEMPSR8->(dbCloseArea())

						dDtAtual := DaySum(dDtAtual,1)
					ENDDO

					nVlrProp  := 0
					nDiasProp := 0
					nVlrDia   := 0

					nVlrProp  := (nVlrSalBase) * (NPERC_PERI/100)
					nDiasProp := ( Diastrab + nDiasAfas + nDiasAdmi)
					nVlrDia   := nVlrProp / nDiasProp
					nDiasSR8  := IIF( nDiasSR8 > (Diastrab + nDiasAfas), (Diastrab + nDiasAfas), nDiasSR8 )
					nDiasProp := (Diastrab + nDiasAfas) - nDiasSR8
					nVlrProp  := nVlrDia * nDiasProp

					aPd[nPosPd,5] :=  nVlrProp
					aPd[nPosPd,4] :=  nDiasProp

					/*
					If nDiasSR8 == 0
                        aPd[nPosPd,5] :=  (nVlrSalBase) * (NPERC_PERI/100)
                        aPd[nPosPd,4] :=  Diastrab + nDiasAfas
					Else
                        nVlrProp  := 0
                        nDiasProp := 0 
                        nVlrDia   := 0

                        nVlrProp  := (nVlrSalBase) * (NPERC_PERI/100)
                        nDiasProp := ( Diastrab + nDiasAfas )
                        nVlrDia   := nVlrProp / nDiasProp 
                        nDiasSR8  := IIF( nDiasSR8 > (Diastrab + nDiasAfas), (Diastrab + nDiasAfas), nDiasSR8 )
                        nDiasProp := (Diastrab + nDiasAfas) - nDiasSR8
                        nVlrProp  := nVlrDia * nDiasProp

                        aPd[nPosPd,5] :=  nVlrProp
                        aPd[nPosPd,4] :=  nDiasProp

					EndIf
					*/

				EndIf
			EndIf

		EndIF


	End Sequence

	RestArea(aAreaAtual)

Return

