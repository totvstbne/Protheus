#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"

User Function RSERVTRB()

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
	cQuery += "  FROM "+RetSqlName("SM7")+ " SM7 
	cQuery += "  WHERE M7_FILIAL ='"+ SRA->RA_FILIAL +"'
	cQuery += "  AND M7_MAT = '"+ SRA->RA_MAT +"'
	cQuery += "  AND M7_TPVALE = '0'

	cQuery += "  AND SM7.D_E_L_E_T_=''
	

	If select("TSM7") > 0
		TSM7->(dbCloseArea())
	Endif
	TcQuery cQuery new Alias TSM7

	IF TSM7->(EOF())

		TSM7->(dbCloseArea())
		restarea(aArea)
		return
	ENDIF

	if TSM7->M7_DPROPIN == 0
		avTcalc[1][2] := 0
		avTcalc[1][4] := 0
		avTcalc[1][5] := 0
		avTcalc[1][6] := 0
		avTcalc[1][7] := 0
		avTcalc[1][11] := 0
		avTcalc[1][12] := 0
		avTcalc[1][13] := 0

	endif




	TSM7->(dbCloseArea())
	restarea(aArea)
return
