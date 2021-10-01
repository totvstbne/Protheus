#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"

User Function RSERVALB()

	Local aArea := getarea()
	Local nValCa := 0
	Local nPercdes
	Local nValFun
	Local nValem



	// avacalc[1][2]   -> dias calculados (qunatidade de vales por dia calculado )
	// avacalc[1][4]   -> valor calculado
	// avacalc[1][5]   -> valor funcionário  --- aplicar perc de desconto com o limite no teto do vale
	// avacalc[1][6]   -> valor empresa ( total - pago pelo funcionário )
	// avacalc[1][7]   -> dias proporcionais  (informado na m7_DPROPIN)
	// avacalc[1][10]  -> dias proporcionais incluidos
	// avacalc[1][11]  -> R0_QDIAINF (numero de vales dia)
	// avacalc[1][12]  -> DIAS NAO UTIL R0_QDNUTIL


	// posicionar na sm7 do funcionário
	cQuery := "  SELECT *
	cQuery += "  FROM "+RetSqlName("SM7")+ " SM7 , "+RetSqlName("RFO")+ " RFO
	cQuery += "  WHERE M7_FILIAL ='"+ SRA->RA_FILIAL +"'
	cQuery += "  AND M7_MAT = '"+ SRA->RA_MAT +"'
	cQuery += "  AND M7_TPVALE = '2'

	cQuery += "  AND RFO_FILIAL = SUBSTRING(M7_FILIAL,1,2)
	cQuery += "  AND RFO_TPVALE = '2'
	cQuery += "  AND RFO_CODIGO = M7_CODIGO
	cQuery += "  AND SM7.D_E_L_E_T_=''
	cQuery += "  AND RFO.D_E_L_E_T_=''


	If select("TSM7") > 0
		TSM7->(dbCloseArea())
	Endif
	TcQuery cQuery new Alias TSM7

	IF TSM7->(EOF())

		TSM7->(dbCloseArea())
		restarea(aArea)
		return
	ENDIF

	// verifico se o valor ta zerado e se na sm7 tem dias proporcional igual a 1
	if TSM7->M7_DPROPIN <> 0 .AND. TSM7->M7_QDIAINF <> 0 .AND. (TSM7->M7_DPROPIN * TSM7->M7_QDIAINF) <> avacalc[1][4]


		// CORREÇÃO DOS VALORES
		nValCa := TSM7->M7_DPROPIN * TSM7->M7_QDIAINF * avacalc[1][3]

		// verificando descontos
		nPercdes := TSM7->RFO_PERC / 100


		// VALOR DO FUNCIONARIO
		nValFun := nValCa * nPercdes

		// verifico limite de desconto
		if nValFun > TSM7->RFO_TETO .and. TSM7->RFO_TETO > 0
			nValFun := TSM7->RFO_TETO

		endif

		//VALOR DA EMPRESA
		nValem := nValCa - nValFun



		avacalc[1][2] := TSM7->M7_QDIAINF * TSM7->M7_DPROPIN
		avacalc[1][4] := nValCa
		avacalc[1][5] := nValFun
		avacalc[1][6] := nValem
		avacalc[1][7] := TSM7->M7_DPROPIN
		avacalc[1][10] := TSM7->M7_DPROPIN
		avacalc[1][11] := TSM7->M7_QDIAINF
		avacalc[1][12] := TSM7->M7_QDNUTIL
	elseif TSM7->M7_DPROPIN == 0
		avacalc[1][2] := 0
		avacalc[1][4] := 0
		avacalc[1][5] := 0
		avacalc[1][6] := 0
		avacalc[1][7] := 0
		avacalc[1][10] := 0
		avacalc[1][11] := 0
		avacalc[1][12] := 0

	endif




	TSM7->(dbCloseArea())
	restarea(aArea)
return
