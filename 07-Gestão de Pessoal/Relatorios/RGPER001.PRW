#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} RGPER001
Função para calculo da insalubridade Servnac
@author edlardo neves - mconsult
@since 09/11/2020
@version 1.0
@return Lógico, .T. se pode calcular .F. caso contrário
/*/
//*****************************************************************************
User Function RGPER001()
//*****************************************************************************
	Local aAreaAtual := GetArea()
	Local nPosPd     := 0 //fLocaliaPd("107")
	Local nVlrSalBase:= 0
	Local dPerDe	:= dDataDe
	Local dPerAte	:= dDataAte
	Local dDtAtual  := dPerDe
	Local nDiasSR8  := 0
	Local nVlrProp  := 0
	Local nDiasProp := 0
	Local nVlrDia   := 0
	//Local nDiasPer	:= IIF(DATEDIFFDAY(dDataDe,dDataAte)+1<30,30,31)
	Local nDiasAdmi := IIF(SRA->RA_ADMISSA>dDataDe, DATEDIFFDAY(dDataDe,SRA->RA_ADMISSA), 0  )
	Begin Sequence
		If ( AbortProc() )
			Break
		EndIf
		IF ( ( ( CTIPOROT == "2" .AND. P_SOMAINC ) .OR. ( CTIPOROT # "2" ) ) )

			IF ( CTIPOINS <> "1" .AND. CBCALINS $ "3*4*7*8" )

				CCODINS := CVERBAROT

				IF ( EMPTY(CCODINS) )

					IF ( CTIPOROT $ "1*2*4" )

						CCODINS := FGETCODFOL('1282')

					EndIF

					IF ( CTIPOROT == "3" )

						CCODINS := FGETCODFOL('1306')

					EndIF

					IF ( CTIPOROT $ "5*6" )

						IF ( CTIPOROT == "5" )

							CCODINS := FGETCODFOL('1635')

							IF ( LVB13MAT2 )

								CCODINSM := FGETCODFOL('1646')

							EndIF

							IF ( !LVB13MAT2 )

								CCODINSM := FGETCODFOL('1443')

							EndIF

						EndIF

						IF ( CTIPOROT == "6" )

							CCODINS := FGETCODFOL('1293')

							CCODINSM := FGETCODFOL('1443')

						EndIF

					EndIF

				EndIF
			ElseIF ( CTIPOINS == "2" .AND. CBCALINS $ "1256" )

				CCODINS := CVERBAROT

				IF ( EMPTY(CCODINS) )

					IF ( CTIPOROT $ "1*2*4" )

						CCODINS := FGETCODFOL('0037')

					EndIF

				EndIF

			ElseIF ( CTIPOINS == "3" .AND. CBCALINS $ "1256" )

				CCODINS := CVERBAROT

				IF ( EMPTY(CCODINS) )

					IF ( CTIPOROT $ "1*2*4" )

						CCODINS := FGETCODFOL('0038')

					EndIF

				EndIF

			ElseIF ( CTIPOINS == "4" .AND. CBCALINS $ "1256" )

				CCODINS := CVERBAROT

				IF ( EMPTY(CCODINS) )

					IF ( CTIPOROT $ "1*2*4" )

						CCODINS := FGETCODFOL('0039')

					EndIF

				EndIF

			EndIF

			If Alltrim(CCODINS) <> ""
				nPosPd     := fLocaliaPd(CCODINS)
				nVlrSalBase := IIF(CBCALINS == "1" , VAL_SALMIN, Salario ) //nVlrSalBase := IIF(CBCALINS == "1" , VAL_SALMIN, SALHORA*NHRSINSAL )
				If nVlrSalBase > 0 .and. nPosPd > 0 .AND. NPERC_INS > 0

					nDiasSR8 := 0
					While dDtAtual <= dPerAte
						//Busca Ferias
						cQuery := "  SELECT R8_MAT "
						cQuery += "  FROM "+RetSqlName("SR8")+ " SR8 "
						cQuery += "  INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = '' "
						cQuery += "  WHERE SR8.D_E_L_E_T_='' "
						cQuery += "  AND R8_MAT = '"+ SRA->RA_MAT +"' AND  R8_FILIAL ='"+ SRA->RA_FILIAL +"' "
						cQuery += "  AND ( '"+dtos(dDtAtual)+"' BETWEEN R8_DATAINI AND R8_DATAFIM  ) "
						cQuery += "  AND RCM_YINSAL = 'S' AND RCM_TIPO = '001' "

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
						cQuery += "  AND RCM_YINSAL = 'S' AND RCM_TIPO <> '001' "
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

					nVlrProp  := ( nVlrSalBase ) * ( NPERC_INS/100 )
					nDiasProp := ( Diastrab + nDiasAfas + nDiasAdmi  )
					nVlrDia   := nVlrProp / nDiasProp
					nDiasSR8  := IIF(nDiasSR8 > (Diastrab+nDiasAfas), (Diastrab+nDiasAfas), nDiasSR8 )
					nDiasProp := (Diastrab+nDiasAfas) - nDiasSR8
					nVlrProp  := nVlrDia * nDiasProp

					aPd[nPosPd,5] :=  nVlrProp
					aPd[nPosPd,4] :=  nDiasProp

					/*
					If nDiasSR8 == 0
						aPd[nPosPd,5] :=  (nVlrSalBase) * (NPERC_INS/100)
						aPd[nPosPd,4] :=  Diastrab+nDiasAfas
					Else
                        nVlrProp  := 0
                        nDiasProp := 0 
                        nVlrDia   := 0

                        nVlrProp  := ( nVlrSalBase ) * ( NPERC_INS/100 )
                        nDiasProp := ( Diastrab + nDiasAfas + nDiasAdmi  )
                        nVlrDia   := nVlrProp / nDiasProp 
                        nDiasSR8  := IIF(nDiasSR8 > (Diastrab+nDiasAfas), (Diastrab+nDiasAfas), nDiasSR8 )
                        nDiasProp := (Diastrab+nDiasAfas) - nDiasSR8
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

