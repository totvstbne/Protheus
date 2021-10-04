#include "protheus.ch"
#include "parmtype.ch"
#include "rwmake.ch"
#include "TOPCONN.CH"

#define linha chr(13) + chr(10)

/*/{Protheus.doc} ASVUP001
//TODO Update nos paedidos de compras onde gravou sem guardar informações da mennota e competencia
@author Wilton Lima
@since 19/06/2019
@version undefined
@example
(examples) U_ASVUP001()
@see (links_or_references)
/*/
user function ASVUP001()

	Local aArea   := GetArea()
	Local STRG001 := "Update na SC5"
	Local STRG002 := "Realiza o UPDATE na tabela SC5, onde não gravou informações do contrato, mensagem para nota e centro de custo. "

	//TNewProcess():New("ASVUP001", STRG001, {|oSelf| U_fASVUPD(oSelf)}, STRG002, "ASVUP001", NIL, NIL, NIL, NIL, .T., .F.)
	MsAguarde({| oSelf | U_fASVUPD(oSelf)}, "Processamento", "Aguarde a finalização do processamento...",.F.)
	
	RestArea(aArea)
Return

/*/{Protheus.doc} ASVUP001
//TODO Update nos paedidos de compras onde gravou sem guardar informações da mennota e competencia
@author Wilton Lima
@since 19/06/2019
@version undefined
@example
(examples) U_ASVUP001() TRB->(RECCOUNT())
@see (links_or_references)
/*/
user function fASVUPD(oProcess)

	Local cStrSql   := ""
	Local cMsg	    := "SERVICOS PRESTADOS " + linha
	Local cDPost    := ""
	Local cRevTFF   := ""
	Local cYCC      := ""
	Local cMenNota  := ""
	Local cComp     := ""
	Local nCount    := 0

	//ProcINI(oProcess)

	cStrSql := " SELECT C5_FILIAL, C5_NUM, C5_TIPO, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_NOTA, C5_SERIE, "
	cStrSql += " C5_MDCONTR, C5_MDNUMED, C5_MDPLANI, C5_YCC, C5_YCOMPET, "
	cStrSql += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C5_MENNOTA)),'') AS C5_MENNOTA, R_E_C_N_O_ AS RECNO "
	cStrSql += " FROM " + RetSqlName("SC5") + " SC5 "
	cStrSql += " WHERE D_E_L_E_T_  != '*' "
	cStrSql += " AND C5_MDCONTR != '' "
	cStrSql += " AND C5_EMISSAO >= '20190614' "
	cStrSql += " AND C5_MENNOTA IS NULL "
	cStrSql += " ORDER BY C5_FILIAL, C5_NUM "

	cStrSql := ChangeQuery(cStrSql)

	If (Select("QSC5") > 0)
		Dbselectarea("QSC5")
		QSC5->(DbCloseArea())
	EndIf

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cStrSql),"QSC5", .F., .T. )

	oProcess:SetRegua1(QSC5->(RECCOUNT()))

	while QSC5->(!Eof())
		nCount++
		oProcess:IncRegua1(nCount)

		cStrSql := " SELECT MAX(TFF_CONREV) REVISAO "
		cStrSql += " FROM " + RetSqlName("TFF") + " TFF "
		cStrSql += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		cStrSql += " 	ON TFF_LOCAL = TFL_LOCAL AND TFF_FILIAL = TFF_FILIAL AND TFL_CONTRT = TFF_CONTRT AND TFL_CODIGO = TFF_CODPAI "
		cStrSql += " WHERE TFF.D_E_L_E_T_ != '*' "
		cStrSql += " 	AND TFL.D_E_L_E_T_ != '*' "
		cStrSql += " 	AND TFF_FILIAL = '" + QSC5->C5_FILIAL  + "' "
		cStrSql += " 	AND TFL_FILIAL = '" + QSC5->C5_FILIAL  + "' "
		cStrSql += " 	AND TFF_CONTRT = '" + QSC5->C5_MDCONTR + "' "
		cStrSql += " 	AND TFL_CONTRT = '" + QSC5->C5_MDCONTR + "' "
		cStrSql += " 	AND TFL_PLAN = '"   + QSC5->C5_MDPLANI + "' "

		cStrSql := ChangeQuery(cStrSql)

		If (Select("QTFFMAX") > 0)
			Dbselectarea("QTFFMAX")
			QTFFMAX->(DbClosearea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cStrSql),"QTFFMAX", .F., .T. )

		cRevTFF := QTFFMAX->REVISAO
		QTFFMAX->(dbCloseArea())

		cStrSql := " SELECT TFF_PRODUT,TFF_QTDVEN "
		cStrSql += " FROM " + RetSqlName("TFF") + " TFF "
		cStrSql += " INNER JOIN " + RetSqlName("TFL") + " TFL "
		cStrSql += " 	ON TFF_LOCAL = TFL_LOCAL AND TFF_FILIAL = TFF_FILIAL AND TFL_CONTRT = TFF_CONTRT AND TFL_CODIGO = TFF_CODPAI AND TFF_CONREV = TFL_CONREV "
		cStrSql += " WHERE TFF.D_E_L_E_T_ != '*' "
		cStrSql += " 	AND TFL.D_E_L_E_T_ != '*' "
		cStrSql += " 	AND TFF_FILIAL = '" + QSC5->C5_FILIAL  + "' "
		cStrSql += " 	AND TFL_FILIAL = '" + QSC5->C5_FILIAL  + "' "
		cStrSql += " 	AND TFF_CONTRT = '" + QSC5->C5_MDCONTR + "' "
		cStrSql += " 	AND TFL_CONTRT = '" + QSC5->C5_MDCONTR + "' "
		cStrSql += " 	AND TFL_PLAN = '"   + QSC5->C5_MDPLANI + "' "
		cStrSql += " 	AND TFF_CONREV = '" + cRevTFF          + "' "
		cStrSql += " GROUP BY TFF_PRODUT, TFF_QTDVEN "

		cStrSql := ChangeQuery(cStrSql)

		If (Select("QTFF") > 0)
			Dbselectarea("QTFF")
			QTFF->(DbClosearea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cStrSql),"QTFF", .F., .T. )

		while QTFF->(!Eof())
			If ( QTFF->TFF_QTDVEN == 1 )
				cDPost := "POSTO"
			Else
				cDPost := "POSTOS"
			Endif

			cMsg += StrZero(QTFF->TFF_QTDVEN, 2) + " " + cDPost + " DE " + AllTrim( Posicione("SB1",1,xFilial("SB1") + QTFF->TFF_PRODUT, "B1_DESC"))

			QTFF->(dbSkip())

			If QTFF->(!Eof())
				cMsg += linha
			Endif
		Enddo

		QTFF->(dbCloseArea())

		cStrSql := " SELECT TFL_YCC FROM " + RetSqlName("TFL") + " TFL "
		cStrSql += " WHERE D_E_L_E_T_ != '*' "
		cStrSql += " 	AND TFL_FILIAL = '" + QSC5->C5_FILIAL  + "' "
		cStrSql += " 	AND TFL_CONTRT = '" + QSC5->C5_MDCONTR + "' "
		cStrSql += " 	AND TFL_PLAN = '"   + QSC5->C5_MDPLANI + "' "

		cStrSql := ChangeQuery(cStrSql)

		If (Select("QTFL") > 0)
			Dbselectarea("QTFL")
			QTFL->(DbClosearea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cStrSql),"QTFL", .F., .T. )

		cYCC	 := QTFL->TFL_YCC
		cMenNota := cMsg

		QTFL->(dbCloseArea())

		cStrSql := " SELECT CND.R_E_C_N_O_ RECNO "
		cStrSql += " FROM " + RetSqlName("CND") + " CND "
		cStrSql += " WHERE D_E_L_E_T_ != '*' "
		cStrSql += " 	AND CND_FILIAL = '" + QSC5->C5_FILIAL  + "' "
		cStrSql += " 	AND CND_CONTRA = '" + QSC5->C5_MDCONTR + "' "
		cStrSql += " 	AND CND_NUMMED = '" + QSC5->C5_MDNUMED + "' "

		cStrSql := ChangeQuery(cStrSql)

		If (Select("QCND") > 0)
			Dbselectarea("QCND")
			QCND->(DbClosearea())
		EndIf

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cStrSql),"QCND", .F., .T. )

		If QCND->(!Eof())
			dbSelectArea("CND")
			CND->(dbGoto(QCND->RECNO))

			cComp   := stod(SubStr(CND->CND_COMPET, 4, 4) + SubStr(CND->CND_COMPET, 1, 2) + "01")
			cMesExt := upper(MesExtenso(Month(cComp))) + " DE " + substr(CND->CND_COMPET, 4, 4)
			cMsg    := "NO PERIODO DE " + cMesExt + linha

			dbSelectArea("SC5")
			SC5->(dbGoto(QSC5->RECNO))

			//UPDATE DEPARTAMENTO
			//SET NOME = "HELBERT CARVALHO",SALARIO = 1000
			//WHERE CODIGO = 1

//			cStrUpd := " UPDATE " + RetSqlName("SC5") + " SET C5_MENNOTA = " + cMenNota + linha + cMsg 
//			cStrUpd += " , C5_YCOMPET = " + cComp
//			cStrUpd += " , C5_YCC = " + cYCC
//			cStrUpd += " WHERE R_E_C_N_O_ = " + QSC5->RECNO
//			
//			nStatus := TCSqlExec(cStrUpd)
//
//			if ( nStatus < 0 )
//				MsgAlert("TCSQLError() " + TCSQLError(), "Atenção!")
//			endif

			Reclock("SC5",.F.)
			SC5->C5_MENNOTA := cMenNota + linha + cMsg
			SC5->C5_YCOMPET := cComp
			SC5->C5_YCC	    := cYCC
			SC5->(MsUnlock())
		Endif
		QCND->(dbCloseArea())

		QSC5->(dbSkip())
	EndDo

	MsgAlert("Total de pedidos " + nCount, "Atenção!")

	QSC5->(dbCloseArea())
Return