#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'

/*/{Protheus.doc} RSVNA002
Reabertura da oportunidade
@author Diogo
@since 05/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
user function RSVNA002()
	Local aArea	:= getArea()
	If AD1->AD1_STATUS <> '9'
		alert("Somente oportunidades com status de ganha poderão ser reabertas")
		Return
	Endif
	
	cQuery :="SELECT TFJ_CONTRT FROM "+RetSqlName("TFJ")+ " TFJ "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="TFJ_FILIAL = '"+xFilial("TFJ")+"' AND "
	cQuery +="TFJ_PROPOS = '"+AD1->AD1_PROPOS+"'  "
	TcQuery cQuery new Alias QTFJ
	
	If QTFJ->(!Eof())
		If !empty(QTFJ->TFJ_CONTRT) //Contrato já gerado
			alert("Contrato já gerado para a oportunidade e não poderá ser reaberta")
			QTFJ->(dbCloseArea())
		 	Return
		Endif
	Endif
	QTFJ->(dbCloseArea())
	
	If msgYesNo("Confirma a reabertura da oportunidade?")
		reclock("AD1",.F.)
			AD1->AD1_STATUS:= '1'
			AD1->AD1_DTASSI:= cTod("")
			AD1->AD1_CNTPRO:= ""
			AD1->AD1_PROPOS:= ""
		msUnlock()
		//Atualiza as propostas
		cUpd:="UPDATE "+RetSqlName("ADY")+" SET ADY_STATUS = 'A' "
		cUpd+="WHERE ADY_FILIAL = '"+xFilial("ADY")+"' AND "
		cUpd+="ADY_OPORTU = '"+AD1->AD1_NROPOR+"' "
		tcSqlExec(cUpd)
		TcRefresh(RetSqlName("ADY"))

		cUpd:="UPDATE "+RetSqlName("SCJ")+" SET CJ_STATUS = 'A' "
		cUpd+="WHERE CJ_FILIAL = '"+xFilial("SCJ")+"' AND "
		cUpd+="CJ_NROPOR = '"+AD1->AD1_NROPOR+"' "
		tcSqlExec(cUpd)
		TcRefresh(RetSqlName("SCJ"))

	Endif
	RestArea(aArea)
Return