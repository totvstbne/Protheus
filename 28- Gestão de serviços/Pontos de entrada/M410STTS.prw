#include 'protheus.ch'
#include 'topconn.ch'
/*/{Protheus.doc} M410STTS
Gravação da competência do contrato no pedido de vendas
@author Diogo
@since 17/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function M410STTS()
	Local aArea	:= getArea()
	Local nX	:= 0
	Local aAGG	:= {}
//	Local nItem	:= 1
	Local nSum	:= 0
	Local cQuery := ""
//	Local cAlsQry := ""
//Local lAgil := .F.
	Local nOperX := !Inclui .and. !Altera //PARAMIXB
	If funname() == "CNTA121" //Encerramento da Medição do contrato
		If CND->CND_YAGRUP == '1' //Agrupa Pedidos
			//Verifica se tem o agrupador para a planilha 
			cQuery:= "SELECT ZC1_AGRUP FROM "+RetSqlName("ZC1")+" ZC1 "
			cQuery+= "WHERE ZC1.D_E_L_E_T_ = ' ' AND "
			cQuery+= "ZC1_FILIAL = '"+xFilial("ZC1")+"' AND "
			cQuery+= "ZC1_CONTRA = '"+SC5->C5_MDCONTR+"' AND "
			cQuery+= "ZC1_NUMPLA = '"+SC5->C5_MDPLANI+"' AND "
			cQuery+= "ZC1_NUMMED = '"+SC5->C5_MDNUMED+"' "
//			cQuery+= "ZC1_AGRUP <> ' ' " //Tem agrupador
			tcQuery cQuery new Alias QRZCT
			If QRZCT->(!Eof())
				Reclock("SC5",.F.)
					SC5->C5_NOTA 	:= "XXXXXXXXX"
					SC5->C5_LIBEROK	:= "S"
					SC5->C5_BLQ		:= " "
				MsUnlock()	
				
				//Marca os itens do pedido como C6_BLQ = R
				cQuery := "SELECT SC6.R_E_C_N_O_  AS RECNO FROM "+RETSQLNAME("SC5")+" SC5 INNER JOIN "+RETSQLNAME("SC6")+" SC6 ON "
				cQuery += "C5_NUM = C6_NUM WHERE SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ' 
				cQuery += "AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '"+SC5->C5_NUM+"' AND C6_BLQ <> 'R' AND C5_NOTA = 'XXXXXXXXX' "
				tcQuery cQuery new Alias QTMPSC6Q
				while QTMPSC6Q->(!EOF())
					SC6->(dbGoTo(QTMPSC6Q->RECNO))
					SC6->(RecLock("SC6", .F.))
						SC6->C6_BLQ := 'R'
					SC6->(MsUnLock())
					QTMPSC6Q->(dbSkip())
				endDo
				QTMPSC6Q->(dbCloseArea())
				
				//Exclui item na SC9
				cQuery := "SELECT SC9.R_E_C_N_O_ AS RECNO FROM "+RETSQLNAME("SC9")+" SC9 WHERE C9_PEDIDO = '"+SC5->C5_NUM+"'
				cQuery += " AND C9_FILIAL = '"+xFilial("SC9")+"' AND SC9.D_E_L_E_T_ = ' ' "
				cQuery += " AND C9_CLIENTE = '"+ SC5->C5_CLIENTE +"' AND C9_LOJA = '"+SC5->C5_LOJACLI+"' "
				tcQuery cQuery new Alias QTMPQSC9
				while QTMPQSC9->(!EOF())
					SC9->(dbGoTo(QTMPQSC9->RECNO))
					SC9->(RecLock("SC9", .F.))
						SC9->(dbDelete())
					SC9->(MsUnLock())
					QTMPQSC9->(dbSkip())
				endDo
				QTMPQSC9->(dbCloseArea())			
			Endif
			QRZCT->(dbCloseArea())
		Endif
	Endif 
	
	If nOperX //5 //Exclusão	 	
	 	If !empty(SC5->C5_YIDMED)
	 		If SC5->C5_NOTA <> "XXXXXXXXX"
	 			//Seleciona os pedidos referente ao agregador
				cQuery:= "SELECT SC5.R_E_C_N_O_ RECNO FROM "+RetSqlName("SC5")+" SC5 "
				cQuery+= "WHERE SC5.D_E_L_E_T_ = ' ' AND "
				cQuery+= "C5_FILIAL = '"+xFilial("SC5")+"' AND "
				cQuery+= "C5_YIDMED = '"+SC5->C5_YIDMED+"' AND "
				cQuery+= "C5_NOTA = 'XXXXXXXXX' AND "
				cQuery+= "C5_CONTRA = '"+SC5->C5_CONTRA+"' "
				tcQuery cQuery new Alias QESTN
				while QESTN->(!Eof())
					SC5->(dbGoto(QESTN->RECNO))
					Reclock("SC5",.F.)
						SC5->C5_NOTA 	:= " "
						SC5->C5_LIBEROK	:= " "
						SC5->C5_BLQ		:= " "
					MsUnlock()	
					QESTN->(dbSkip())
				enddo
				QESTN->(dbCloseArea())	 			
	 		Endif
	 	Endif
	 	RestArea(aArea)
		Return
	Endif
	/*
	// Garante que não terá rateio pré-definido
	cUpd := "UPDATE " + RetSqlName("AGG") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_= R_E_C_N_O_ "
	cUpd += "WHERE AGG_FILIAL = '" + xFilial("AGG") + "' AND "
	cUpd += "AGG_PEDIDO = '" + SC5->C5_NUM + "' "
	
	tcsqlExec(cUpd)
	tcRefresh(RetSqlName("AGG"))

	// Busca Valor Total do Pedido
	cQuery := "SELECT SUM(C6_VALOR) VALOR FROM " + RetSqlName("SC6") + " SC6 "
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
	cQuery += "C6_FILIAL = '" + xFilial("SC6") + "' AND "
	cQuery += "C6_NUM = '" + SC5->C5_NUM + "' "
	
	TcQuery cQuery new Alias QTOTC6
	nvalT := QTOTC6->VALOR
	QTOTC6->(dbCloseArea())

	//Recursos humanos
	cQuery := "SELECT CTD_ITEM ITEM,SUM(TFW_VLRMED) VALOR			"
	cQuery += "FROM " + RetSqlName("SC5") + " SC5					"
	cQuery += "JOIN " + RetSqlName("CND") + " CND					"
	cQuery += "ON CND_CONTRA = C5_MDCONTR AND						"
	cQuery += "   CND_NUMMED = C5_MDNUMED AND						"
	cQuery += "   CND_FILIAL = C5_FILIAL							"
	cQuery += "JOIN " + RetSqlName("TFL") + " TFL					"
	cQuery += "ON TFL_FILIAL = C5_FILIAL AND						"
	cQuery += "TFL_CONTRT = C5_MDCONTR AND							"
	cQuery += "TFL_CONREV = CND_REVISA								"
	cQuery += "JOIN " + RetSqlName("TFF") + " TFF					"
	cQuery += "ON TFF_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI	"
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1					"
	cQuery += "ON TFF_PRODUT = B1_COD								"
	cQuery += "JOIN " + RetSqlName("CTD") + " CTD					"
	cQuery += "ON CTD_ITEM = SUBSTRING(B1_COD,3,8)					"
	cQuery += "JOIN " + RetSqlName("ABS") + " ABS					"
	cQuery += "ON ABS_LOCAL = TFF_LOCAL								"
	cQuery += "JOIN " + RetSqlName("TFW") + " TFW					"
	cQuery += "ON TFW_CODTFF = TFF_COD AND TFW_FILIAL = TFF_FILIAL AND TFW_NUMMED = C5_MDNUMED "
	cQuery += "WHERE SC5.D_E_L_E_T_ =' ' AND							"
	cQuery += "CND.D_E_L_E_T_ =' ' AND								"
	cQuery += "CTD.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFL.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFW.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFF.D_E_L_E_T_ =' ' AND								"
	cQuery += "SB1.D_E_L_E_T_ =' ' AND								"
	cQuery += "ABS.D_E_L_E_T_ =' ' AND								"
	cQuery += "ABS_CODIGO = C5_CLIENTE AND  						"
	cQuery += "ABS_LOJA = C5_LOJACLI AND							"
	cQuery += "C5_NUM = '"    + SC5->C5_NUM    + "' AND 			"
	cQuery += "C5_FILIAL = '" + SC5->C5_FILIAL + "' 				"
	cQuery += "GROUP BY CTD_ITEM									"

	cQuery += "UNION ALL											"
	//Material de implantação
	cQuery += "SELECT CTD_ITEM ITEM,SUM(TFX_VLRMED) VALOR			"
	cQuery += "FROM " + RetSqlName("SC5") + " SC5					"
	cQuery += "JOIN " + RetSqlName("CND") + " CND					"
	cQuery += "ON CND_CONTRA = C5_MDCONTR AND						"
	cQuery += "   CND_NUMMED = C5_MDNUMED AND						"
	cQuery += "   CND_FILIAL = C5_FILIAL							"
	cQuery += "JOIN " + RetSqlName("TFL") + " TFL					"
	cQuery += "ON TFL_FILIAL = C5_FILIAL AND						"
	cQuery += "TFL_CONTRT = C5_MDCONTR AND							"
	cQuery += "TFL_CONREV = CND_REVISA								"
	cQuery += "JOIN " + RetSqlName("TFF") + " TFF					"
	cQuery += "ON TFF_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI	"
	cQuery += "JOIN " + RetSqlName("TFG") + " TFG					"
	cQuery += "ON TFG_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI	"
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1					"
	cQuery += "ON TFG_PRODUT = B1_COD								"
	cQuery += "JOIN " + RetSqlName("ABS") + " ABS					"
	cQuery += "ON ABS_LOCAL = TFF_LOCAL								"
	cQuery += "JOIN " + RetSqlName("CTD") + " CTD					"
	cQuery += "ON CTD_ITEM = SUBSTRING(B1_COD,3,8)					"
	cQuery += "JOIN " + RetSqlName("TFX") + " TFX					"
	cQuery += "ON TFX_CODTFG = TFG_COD AND TFX_FILIAL = TFG_FILIAL AND TFX_NUMMED = C5_MDNUMED 	"
	cQuery += "WHERE SC5.D_E_L_E_T_ =' ' AND							"
	cQuery += "CND.D_E_L_E_T_ =' ' AND								"
	cQuery += "CTD.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFL.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFX.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFG.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFF.D_E_L_E_T_ =' ' AND								"
	cQuery += "SB1.D_E_L_E_T_ =' ' AND								"
	cQuery += "ABS.D_E_L_E_T_ =' ' AND								"
	cQuery += "ABS_CODIGO = C5_CLIENTE AND 							"
	cQuery += "ABS_LOJA = C5_LOJACLI AND							"
	cQuery += "C5_NUM = '"    + SC5->C5_NUM    + "' AND 			"
	cQuery += "C5_FILIAL = '" + SC5->C5_FILIAL + "' 				"
	cQuery += "GROUP BY CTD_ITEM									"

	cQuery += "UNION ALL 											"
	//Material de consumo
	cQuery += "SELECT CTD_ITEM ITEM,SUM(TFY_VLRMED) VALOR			"
	cQuery += "FROM " + RetSqlName("SC5") + " SC5					"
	cQuery += "JOIN " + RetSqlName("CND") + " CND					"
	cQuery += "ON CND_CONTRA = C5_MDCONTR AND						"
	cQuery += "   CND_NUMMED = C5_MDNUMED AND						"
	cQuery += "   CND_FILIAL = C5_FILIAL							"
	cQuery += "JOIN " + RetSqlName("TFL") + " TFL					"
	cQuery += "ON TFL_FILIAL = C5_FILIAL AND						"
	cQuery += "TFL_CONTRT = C5_MDCONTR AND							"
	cQuery += "TFL_CONREV = CND_REVISA								"
	cQuery += "JOIN " + RetSqlName("TFF") + " TFF					"
	cQuery += "ON TFF_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI	"
	cQuery += "JOIN " + RetSqlName("TFH") + " TFH					"
	cQuery += "ON TFH_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI	"
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1					"
	cQuery += "ON TFH_PRODUT = B1_COD								"
	cQuery += "JOIN " + RetSqlName("CTD") + " CTD					"
	cQuery += "ON CTD_ITEM = SUBSTRING(B1_COD,3,8)					"
	cQuery += "JOIN " + RetSqlName("ABS") + " ABS					"
	cQuery += "ON ABS_LOCAL = TFF_LOCAL								"
	cQuery += "JOIN " + RetSqlName("TFY") + " TFY					"
	cQuery += "ON TFY_CODTFH = TFH_COD AND TFY_FILIAL = TFH_FILIAL AND TFY_NUMMED = C5_MDNUMED	"
	cQuery += "WHERE SC5.D_E_L_E_T_ =' ' AND						"
	cQuery += "CND.D_E_L_E_T_ =' ' AND								"
	cQuery += "CTD.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFL.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFY.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFH.D_E_L_E_T_ =' ' AND								"
	cQuery += "TFF.D_E_L_E_T_ =' ' AND								"
	cQuery += "SB1.D_E_L_E_T_ =' ' AND								"
	cQuery += "ABS.D_E_L_E_T_ =' ' AND								"
	cQuery += "ABS_CODIGO = C5_CLIENTE AND 							"
	cQuery += "ABS_LOJA = C5_LOJACLI AND							"
	cQuery += "C5_NUM = '"    + SC5->C5_NUM    + "' AND  			"
	cQuery += "C5_FILIAL = '" + SC5->C5_FILIAL + "' 				"
	cQuery += "GROUP BY CTD_ITEM									"

	TcQuery cQuery new Alias QSC6

	while QSC6->(!Eof())
		aadd(aAGG,{;
		xFilial("AGG"),;	//1
		SC5->C5_NUM,;		//2
		SC5->C5_CLIENTE,;	//3
		SC5->C5_LOJACLI,;	//4
		strzero(nItem,2),;	//5
		Round((QSC6->VALOR / nvalT)*100,2),;	//6
		QSC6->ITEM,;		//7
		SC5->C5_YCC})		//8
		nItem+= 1
		nSum+=Round((QSC6->VALOR / nvalT)*100,2)
		QSC6->(dbSkip())
	Enddo
	QSC6->(dbCloseArea())
*/
	If len(aAGG) > 0
		If nSum <> 100 //Arrendonda para 100%
			If nSum > 100
				aAGG[len(aAGG)][6] := aAGG[len(aAGG)][6] - (nSum - 100)
			Else
				aAGG[len(aAGG)][6] := aAGG[len(aAGG)][6] + (100 - nSum)
			Endif
		Endif
		
		cQuery := "SELECT C6_ITEM FROM " + RetSqlName("SC6") + " SC6 "
		cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
		cQuery += "C6_FILIAL = '" + xFilial("SC6") + "' AND "
		cQuery += "C6_NUM = '" + SC5->C5_NUM + "' "
		cQuery += "ORDER BY C6_ITEM "
		TcQuery cQuery new Alias QITENS

		while QITENS->(!Eof())
			for nX := 1 to len(aAGG)
				recLock("AGG",.T.)
				AGG->AGG_FILIAL	:= aAGG[nX][1]
				AGG->AGG_PEDIDO	:= aAGG[nX][2]
				AGG->AGG_FORNEC	:= aAGG[nX][3]
				AGG->AGG_LOJA	:= aAGG[nX][4]
				AGG->AGG_ITEM	:= aAGG[nX][5]
				AGG->AGG_PERC	:= aAGG[nX][6]
				AGG->AGG_ITEMCT	:= aAGG[nX][7]
				AGG->AGG_CC		:= aAGG[nX][8]
				AGG->AGG_ITEMPD	:= QITENS->C6_ITEM
				msUnlock()
			next
			QITENS->(dbSkip())
		Enddo
		QITENS->(dbCloseArea())
	Endif

	If funname() == "TECA930" .OR. funname() == "CNTA121" //-- Medição dos contratos
		cQuery := " SELECT CND.R_E_C_N_O_ RECNO FROM " + RetSqlName("CND") + " CND "
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND "
		cQuery += " CND_FILIAL = '" + xFilial("CND")  + "' AND  "
		cQuery += " CND_CONTRA = '" + SC5->C5_MDCONTR + "' AND  "
		cQuery += " CND_NUMMED = '" + SC5->C5_MDNUMED + "' "
		
		TcQuery cQuery new Alias QCND

		If QCND->(!Eof())
			dbSelectArea("CND")
			CND->(dbGoto(QCND->RECNO))
			cComp   := stod(substr(CND->CND_COMPET,4,4) + substr(CND->CND_COMPET,1,2) + "01")
			cMesExt := upper(MesExtenso(Month(cComp))) + " DE " + substr(CND->CND_COMPET,4,4)
			cMsg    := "NO PERIODO DE " + cMesExt + chr(13) + chr(10)
			
			Reclock("SC5",.F.)
				SC5->C5_MENNOTA := SC5->C5_MENNOTA + chr(13) + chr(10) + cMsg
				SC5->C5_YCOMPET := cComp
			msUnlock()
		Endif
		QCND->(dbCloseArea())
	Endif

	RestArea(aArea)
return

/*
-- TFF: RECURSOS HUMANOS
-- TFW: MEDIÇÃO RECURSOS HUMANOS

SELECT B1_DESC,B1_COD,TFW_VLRMED
FROM SC5010 SC5
JOIN CND010 CND
ON CND_CONTRA = C5_MDCONTR AND
CND_NUMMED = C5_MDNUMED AND
CND_FILIAL = C5_FILIAL
JOIN TFL010 TFL
ON TFL_FILIAL = C5_FILIAL AND
TFL_CONTRT = C5_MDCONTR AND
TFL_CONREV = CND_REVISA
JOIN TFF010 TFF
ON TFF_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI
JOIN SB1010 SB1
ON TFF_PRODUT = B1_COD
JOIN CTD010 CTD
ON CTD_ITEM = SUBSTRING(B1_COD,3,8)
JOIN ABS010 ABS
ON ABS_LOCAL = TFF_LOCAL
JOIN TFW010 TFW
ON TFW_CODTFF = TFF_COD AND TFW_FILIAL = TFF_FILIAL AND TFW_NUMMED = C5_MDNUMED
WHERE SC5.D_E_L_E_T_ =' ' AND
CND.D_E_L_E_T_ =' ' AND
CTD.D_E_L_E_T_ =' ' AND
TFL.D_E_L_E_T_ =' ' AND
TFW.D_E_L_E_T_ =' ' AND
TFF.D_E_L_E_T_ =' ' AND
SB1.D_E_L_E_T_ =' ' AND
ABS.D_E_L_E_T_ =' ' AND
ABS_CODIGO = C5_CLIENTE AND
ABS_LOJA = C5_LOJACLI AND
C5_MDCONTR='000000000000027'

UNION ALL

-- TFG: MATERIAL DE IMPLANTAÇÃO
-- TFX: MEDIÇÃO MATERIAL DE IMPLANTAÇÃO
SELECT B1_DESC,B1_COD,TFX_VLRMED
FROM SC5010 SC5
JOIN CND010 CND
ON CND_CONTRA = C5_MDCONTR AND
CND_NUMMED = C5_MDNUMED AND
CND_FILIAL = C5_FILIAL
JOIN TFL010 TFL
ON TFL_FILIAL = C5_FILIAL AND
TFL_CONTRT = C5_MDCONTR AND
TFL_CONREV = CND_REVISA
JOIN TFF010 TFF
ON TFF_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI
JOIN TFG010 TFG
ON TFG_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI
JOIN SB1010 SB1
ON TFG_PRODUT = B1_COD
JOIN ABS010 ABS
ON ABS_LOCAL = TFF_LOCAL
JOIN CTD010 CTD
ON CTD_ITEM = SUBSTRING(B1_COD,3,8)
JOIN TFX010 TFX
ON TFX_CODTFG = TFG_COD AND TFX_FILIAL = TFG_FILIAL AND TFX_NUMMED = C5_MDNUMED
WHERE SC5.D_E_L_E_T_ =' ' AND
CND.D_E_L_E_T_ =' ' AND
CTD.D_E_L_E_T_ =' ' AND
TFL.D_E_L_E_T_ =' ' AND
TFX.D_E_L_E_T_ =' ' AND
TFG.D_E_L_E_T_ =' ' AND
TFF.D_E_L_E_T_ =' ' AND
SB1.D_E_L_E_T_ =' ' AND
ABS.D_E_L_E_T_ =' ' AND
ABS_CODIGO = C5_CLIENTE AND
ABS_LOJA = C5_LOJACLI AND
C5_MDCONTR='000000000000027'

UNION ALL

-- TFH: MATERIAL DE CONSUMO
-- TFY: MEDIÇÃO MATERIAL DE CONSUMO

SELECT B1_DESC,B1_COD,TFY_VLRMED
FROM SC5010 SC5
JOIN CND010 CND
ON CND_CONTRA = C5_MDCONTR AND
CND_NUMMED = C5_MDNUMED AND
CND_FILIAL = C5_FILIAL
JOIN TFL010 TFL
ON TFL_FILIAL = C5_FILIAL AND
TFL_CONTRT = C5_MDCONTR AND
TFL_CONREV = CND_REVISA
JOIN TFF010 TFF
ON TFF_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI
JOIN TFH010 TFH
ON TFH_CODPAI = TFL_CODIGO AND TFL_PLAN = C5_MDPLANI
JOIN SB1010 SB1
ON TFH_PRODUT = B1_COD
JOIN CTD010 CTD
ON CTD_ITEM = SUBSTRING(B1_COD,3,8)
JOIN ABS010 ABS
ON ABS_LOCAL = TFF_LOCAL
JOIN TFY010 TFY
ON TFY_CODTFH = TFH_COD AND TFY_FILIAL = TFH_FILIAL AND TFY_NUMMED = C5_MDNUMED
WHERE SC5.D_E_L_E_T_ =' ' AND
CND.D_E_L_E_T_ =' ' AND
CTD.D_E_L_E_T_ =' ' AND
TFL.D_E_L_E_T_ =' ' AND
TFY.D_E_L_E_T_ =' ' AND
TFH.D_E_L_E_T_ =' ' AND
TFF.D_E_L_E_T_ =' ' AND
SB1.D_E_L_E_T_ =' ' AND
ABS.D_E_L_E_T_ =' ' AND
ABS_CODIGO = C5_CLIENTE AND
ABS_LOJA = C5_LOJACLI AND
C5_MDCONTR='000000000000027'
*/
