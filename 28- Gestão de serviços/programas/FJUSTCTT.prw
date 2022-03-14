#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} FJUSTCTT
//TODO Função para ajustar a descrição do centro de custo
antes estava sendo prenchido com o nome do cliente e agora vai passar a serpreenchido com a descrição do local
com isso esse fonte vai ajustar tudo que já foi incluido de acordo com a nova regra.
@author Wilton Lima
@since 24/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function FJUSTCTT() // U_FJUSTCTT()
	Local cId     := ""
	Local cStrSql := ""
	Local cDescri := ""
	Local cNum    := 0
		
	cStrSql := " SELECT DISTINCT " 
	//cStrSql += " 	TFL_FILIAL, TFL_LOCAL, TFL_CODIGO, TFL_YCC, "
	cStrSql += " 	TFL_FILIAL, TFL_LOCAL, TFL_YCC, "
	cStrSql += " 	ABS_LOCAL, ABS_DESCRI, "
	cStrSql += " 	CTT_FILIAL, CTT_CUSTO, CTT_DESC01, CTT.R_E_C_N_O_ AS RECNO "
	cStrSql += " FROM " + RETSQLNAME("TFJ") + " TFJ "
	cStrSql += " INNER JOIN " + RETSQLNAME("TFL") + " TFL ON (TFJ_FILIAL = TFL_FILIAL AND TFJ_CODIGO = TFL_CODPAI) "
	cStrSql += " INNER JOIN " + RETSQLNAME("ABS") + " ABS ON (ABS_LOCAL = TFL_LOCAL) "
	cStrSql += " INNER JOIN " + RETSQLNAME("CTT") + " CTT ON (CTT_CUSTO = TFL_YCC) "
	cStrSql += " WHERE TFJ.D_E_L_E_T_ = '' AND TFL.D_E_L_E_T_ = '' AND ABS.D_E_L_E_T_ = '' AND CTT.D_E_L_E_T_ = '' "
	//cStrSql += " AND CTT_CUSTO = '010004001001'"

	If (Select("AJ01") > 0)
		AJ01->(dbCloseArea())
	endif

	TcQuery cStrSql New Alias AJ01
		
	dbSelectArea("CTT")
	
	While AJ01->(!EOF())			
		
		CTT->(DbGoTo(AJ01->RECNO))
				 
		RecLock("CTT", .F.)			
			CTT->CTT_DESC01 := SUBSTR(AJ01->CTT_DESC01, 1, 11) + AllTrim(AJ01->ABS_DESCRI)
			CTT->CTT_NOME   := SUBSTR(AJ01->CTT_DESC01, 1, 11) + AllTrim(AJ01->ABS_DESCRI)			
		CTT->(MsUnLock())
		
		cNum++				
		AJ01->(DbSkip())		
	EndDo
	
	AJ01->(dbCloseArea())

	MsgInfo("Ajustes realizados, total de " + cValToChar(cNum))

Return