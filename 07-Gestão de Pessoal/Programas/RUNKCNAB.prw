#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"


user function RUNKCNAB(cFat)

	cQuery := " SELECT * FROM "+RetSqlName("SEE")+" SEE
	cQuery += " WHERE D_E_L_E_T_ = '' AND EE_FILIAL = '"+xfilial("SEE",cFat)+"' AND EE_CODIGO = '237'
	cQuery += " AND EE_SUBCTA = '000' 

	IF SELECT("TGPE") > 0
		TGPE->(DBCLOSEAREA())
	ENDIF 
	TcQuery cQuery New Alias TGPE

	cRet := TGPE->EE_ULTDSK
	cNum := PADL(VAL(TGPE->EE_ULTDSK) + 1 ,6,"0") 

	cQuery := " UPDATE "+RETSQLNAME("SEE")+" 
	cQuery += " SET EE_ULTDSK = '"+ cNum+"'
	cQuery += " WHERE D_E_L_E_T_ = '' AND EE_FILIAL = '"+xfilial("SEE",cFat)+"' AND EE_CODIGO = '237'
	cQuery += " AND EE_SUBCTA = '000'

	TCSQLExec(cQuery)


return cRet