#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"

user function RSERVCB1()

	Local aArea := getarea()
	Local nTraba := DIASTRAB
	Local nFaltas := 0
	Local nValCB  := 0
	Local cValor  := 0
	Local nDiasProporc := 30//(DateDiffDay(dDataDe, dDataAte) + 1 )
	// ACALCRI1[X][1]     // DODIGO BENEFICIO    81- CESTA BASICA
	// ACALCRI1[X][2]     // VALOR CALCULADO 
	// ACALCRI1[X][4]     // VALOR CALCULADO 

	// NFALTAS
	// DIASTRAB  

	IF ALLTRIM(ABENRI1[1][2]) = "81"  .and. diastrab > 0

		cQuery := "  SELECT RGB_MAT  , SUM(RGB_HORAS) DIASFALT
		cQuery += "  FROM "+RetSqlName("RGB")+ " RGB 
		cQuery += "  WHERE RGB_FILIAL ='"+ SRA->RA_FILIAL +"'
		cQuery += "  AND RGB_MAT = '"+ SRA->RA_MAT +"'
		//cQuery += "  AND RGB_PERIOD = '"+ ALLTRIM(MV_PAR03) +"'
		cQuery += "  AND RGB_PD IN ( '201' , '202' )
		cQuery += "  AND RGB.D_E_L_E_T_=''
		cQuery += "  GROUP BY RGB_MAT
		
		If select("TRGB") > 0
			TRGB->(dbCloseArea())
		Endif
		TcQuery cQuery new Alias TRGB

		if !TRGB->(eof())
			nFaltas := TRGB->DIASFALT
		endif

		TRGB->(dbCloseArea())

		// BEGAR VALOR DO VALE 

		cQuery := "  SELECT RIS_TPBENE , RIS_COD , RIS_REF
		cQuery += "  FROM "+RetSqlName("RIS")+" RIS 
		cQuery += "  WHERE RIS_TPBENE = '"+ALLTRIM(ABENRI1[1][2])+"'
		cQuery += "  AND RIS_COD = '"+ALLTRIM(ABENRI1[1][3])+"'
		
		If select("TRIS") > 0
			TRIS->(dbCloseArea())
		Endif
		TcQuery cQuery new Alias TRIS

		if !(TRIS->(eof()))
			nValCB := TRIS->RIS_REF
		endif

		TRIS->(dbCloseArea())
		
		
		cValor := ( nValCB / 30 ) * ( diastrab - nFaltas )
		
		IF (diastrab - nFaltas) <= 0
			cValor := 0
		ENDIF 

		//cValor := ( nValCB / aperiodo[1][18] ) * ( diastrab - nFaltas )
		
		ACALCRI1[1][2] := cValor
		ACALCRI1[1][4] := cValor
		ACALCRI1[1][9] := nDiasProporc - nFaltas
	ENDIF

	restarea(aArea)
return
