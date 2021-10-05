#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"


user function FORADNOT()

	Local nQua109 


	//VERIFICA SE O SINDICATO É DOS VIGILANTES (10)
	IF SRA->RA_SINDICA == '10'

		cQuery := " UPDATE "+RETSQLNAME("RGB")+" 
		cQuery += " SET RGB_PD = '161'
		cQuery += " WHERE RGB_MAT = '"+ SRA->RA_MAT +"'
		cQuery += " AND RGB_PROCES = '"+ MV_PAR01 +"'
		cQuery += " AND RGB_ROTEIR = 'FOL'
		cQuery += " AND RGB_PERIOD = '"+ MV_PAR03 +"'
		cQuery += " AND D_E_L_E_T_=''
		cQuery += " AND RGB_ROTORI = 'PON'
		cQuery += " AND RGB_PD = '109'

		TCSQLExec(cQuery)

	ENDIF
return