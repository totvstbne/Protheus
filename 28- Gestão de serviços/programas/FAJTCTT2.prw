#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} FJUSTCTT2
//TODO Ajusta a descrição dos centros de custos, para retirar os zeros a esquerda do numero do contrato
@author Wilton Lima
@since 21/06/2019
@version undefined
@example
(examples) U_FAJTCTT2()
@see (links_or_references)
/*/
user function FAJTCTT2()
	Local cId     := ""
	Local cStrSql := ""
	Local cDescri := ""
	Local cNum    := 0

	cStrSql := " SELECT DISTINCT "
	cStrSql += " 	TFL_FILIAL, TFL_LOCAL, TFL_YCC, TFL_CONTRT, "
	cStrSql += " 	ABS_LOCAL, ABS_DESCRI, "
	cStrSql += " 	CTT_FILIAL, CTT_CUSTO, CTT_DESC01, CTT.R_E_C_N_O_ AS RECNO "
	cStrSql += " FROM " + RETSQLNAME("TFJ") + " TFJ "
	cStrSql += " INNER JOIN " + RETSQLNAME("TFL") + " TFL ON (TFJ_FILIAL = TFL_FILIAL AND TFJ_CODIGO = TFL_CODPAI) "
	cStrSql += " INNER JOIN " + RETSQLNAME("ABS") + " ABS ON (ABS_LOCAL = TFL_LOCAL) "
	cStrSql += " INNER JOIN " + RETSQLNAME("CTT") + " CTT ON (CTT_CUSTO = TFL_YCC) "
	cStrSql += " WHERE TFJ.D_E_L_E_T_ != '*' AND TFL.D_E_L_E_T_ != '*' AND ABS.D_E_L_E_T_ != '*' AND CTT.D_E_L_E_T_ != '*' "

	If (Select("AJ02") > 0)		
		AJ02->(dbCloseArea())
	endif

	TcQuery cStrSql New Alias AJ02

	dbSelectArea("CTT")

	While AJ02->(!EOF())

		CTT->(DbGoTo(AJ02->RECNO))

		RecLock("CTT", .F.)
		CTT->CTT_DESC01 := CVALTOCHAR(INT(VAL(AJ02->TFL_CONTRT))) + "-" + AllTrim(AJ02->ABS_DESCRI)
		CTT->CTT_NOME   := AllTrim(AJ02->ABS_DESCRI)
		CTT->(MsUnLock())

		cNum++
		AJ02->(DbSkip())
	EndDo

	AJ02->(dbCloseArea())

	MsgInfo("Ajustes realizados, total de " + cValToChar(cNum))

Return