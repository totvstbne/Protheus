#Include "Protheus.CH"

#Include "TopConn.CH"

/*

Programa:  Rotina    Autor:  Rodrigo Lucas      Data:  24/02/2021

Descrição: Ponto de entrada executado depois da gravação do borderô 
          
Uso: Geração do Borderô 

*/

User Function F240Bord()

	Local aArea  := Getarea()

	Local cQuery := ""

	//cPort240
	cQuery	:= "SELECT "

	cQuery	+= "SEA.R_E_C_N_O_ SEAREC, SE2.R_E_C_N_O_ SE2REC, E2_CODBAR, A2_BANCO, A2_AGENCIA, A2_NUMCON, EA_PORTADO, EA_MODELO "



	cQuery	+= " FROM " + RETSQLNAME("SEA") + " SEA" + ", " + RETSQLNAME("SE2") + " SE2, " + RETSQLNAME("SA2") + " SA2 "

	cQuery +=	" WHERE "

	cQuery	+= "SEA.EA_NUMBOR = '" + cNumBor + "'"

	cQuery	+= " AND SEA.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
	cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += "AND SEA.EA_FILIAL  = '"+XFILIAL("SEA")+"'  "
	cQuery += "AND SA2.A2_FILIAL  = '"+XFILIAL("SA2")+"'  "
	cQuery += "AND SEA.EA_FILIAL  = SE2.E2_FILIAL  "
	cQuery += "AND SEA.EA_PREFIXO = SE2.E2_PREFIXO "
	cQuery += "AND SEA.EA_NUM     = SE2.E2_NUM     "
	cQuery += "AND SEA.EA_PARCELA = SE2.E2_PARCELA "
	cQuery += "AND SEA.EA_TIPO    = SE2.E2_TIPO    "
	cQuery += "AND SEA.EA_FORNECE = SE2.E2_FORNECE "
	cQuery += "AND SEA.EA_LOJA    = SE2.E2_LOJA    "
	cQuery += "AND SEA.EA_FORNECE = SA2.A2_COD "
	cQuery += "AND SEA.EA_LOJA    = SA2.A2_LOJA  ORDER BY EA_NUMBOR, EA_MODELO  "

	TcQuery cQuery New Alias QBOR

	dbSelectarea("QBOR")

	QBOR->(dbGotop())

	While !QBOR->(Eof())
		if ALLTRIM(QBOR->EA_PORTADO) == "237"
			dbSelectarea("SEA")
			If ! ( alltrim(SEA->EA_MODELO) $ "13-16-17" )
				dbGoto(QBOR->SEAREC)
				Reclock("SEA",.F.)
				IF !EMPTY(QBOR->E2_CODBAR)
					if substr(QBOR->E2_CODBAR,1,3) == QBOR->EA_PORTADO
						Replace EA_MODELO   With "30"
						Replace EA_TIPOPAG  With "20"
					ELSE
						Replace EA_MODELO   With "31"
						Replace EA_TIPOPAG  With "20"
					ENDIF
				ElseIf  !EMPTY(QBOR->A2_BANCO) .AND. !EMPTY(QBOR->A2_AGENCIA) .AND.  !EMPTY(QBOR->A2_NUMCON)
					if QBOR->A2_BANCO == QBOR->EA_PORTADO  // TRANSFERENCIA MESMO BANDO
						Replace EA_MODELO   With "01"
						Replace EA_TIPOPAG  With "20"
					ELSE // TED
						Replace EA_MODELO   With "41"
						Replace EA_TIPOPAG  With "20"
					ENDIF

				Endif
				Msunlock()
			EndIf
		Endif


		QBOR->(dbSkip())

	Enddo

	QBOR->(dbCloseArea())

	cQuery	:= "SELECT "
	cQuery	+= "SEA.R_E_C_N_O_ SEAREC, SE2.R_E_C_N_O_ SE2REC, E2_CODBAR, A2_BANCO, A2_AGENCIA, A2_NUMCON, EA_PORTADO, EA_MODELO "
	cQuery	+= " FROM " + RETSQLNAME("SEA") + " SEA" + ", " + RETSQLNAME("SE2") + " SE2, " + RETSQLNAME("SA2") + " SA2 "
	cQuery +=	" WHERE "
	cQuery	+= "SEA.EA_NUMBOR = '" + cNumBor + "'"
	cQuery	+= " AND SEA.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
	cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += "AND SEA.EA_FILIAL  = '"+XFILIAL("SEA")+"'  "
	cQuery += "AND SA2.A2_FILIAL  = '"+XFILIAL("SA2")+"'  "
	cQuery += "AND SEA.EA_FILIAL  = SE2.E2_FILIAL  "
	cQuery += "AND SEA.EA_PREFIXO = SE2.E2_PREFIXO "
	cQuery += "AND SEA.EA_NUM     = SE2.E2_NUM     "
	cQuery += "AND SEA.EA_PARCELA = SE2.E2_PARCELA "
	cQuery += "AND SEA.EA_TIPO    = SE2.E2_TIPO    "
	cQuery += "AND SEA.EA_FORNECE = SE2.E2_FORNECE "
	cQuery += "AND SEA.EA_LOJA    = SE2.E2_LOJA    "
	cQuery += "AND SEA.EA_FORNECE = SA2.A2_COD "
	cQuery += "AND SEA.EA_LOJA    = SA2.A2_LOJA  ORDER BY EA_NUMBOR, EA_MODELO  "

	TcQuery cQuery New Alias QBOR

	dbSelectarea("QBOR")

	QBOR->(dbGotop())

	_CMODELO := ""
	_NCONT := 0
	//cNEWBor := Soma1(cNumBor)
	cNEWBor := cNumBor
	While !QBOR->(Eof())

		IF _CMODELO <> QBOR->EA_MODELO
			_NCONT++
			_CMODELO := QBOR->EA_MODELO
			IF _NCONT > 1
				cNEWBor := Soma1(cNEWBor)
				Alert("Ajustado novo borderô: "+cNEWBor)
			ENDIF
		ENDIF
		IF _NCONT > 1
			dbSelectarea("SEA")
			dbGoto(QBOR->SEAREC)
			Reclock("SEA",.F.)
			Replace EA_NUMBOR  With cNEWBor
			Msunlock()

			dbSelectarea("SE2")
			dbGoto(QBOR->SE2REC)
			Reclock("SE2",.F.)
			Replace E2_NUMBOR  With cNEWBor
			Msunlock()
		ENDIF

		QBOR->(dbSkip())
	ENDDO
	cNumBor := cNEWBor

	dbSelectArea("SX6")
	GetMv("MV_NUMBORP")
	// Garante que o numero do bordero seja sempre superior ao numero anterior
	If __Language == "SPANISH" .And. SX6->X6_CONTSPA < cNumbor
		RecLock("SX6",.F.)
		SX6->X6_CONTSPA := cNumbor
		msUnlock()
	ElseIf SX6->X6_CONTEUD < cNumbor
		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := cNumbor
		msUnlock()
	Endif
	QBOR->(dbCloseArea())

	RestArea(aArea)

return
