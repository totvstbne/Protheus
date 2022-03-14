#include "rwmake.ch"
#include "TOPCONN.CH"

#Define linha chr(13) + chr(10)

/*/{Protheus.doc} MT410TOK
Gravação do centro de custo - C5_YCC
@author Diogo
@since 11/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function MT410TOK()
	Local aArea   := GetArea()
	Local cMsg	  := "SERVICOS PRESTADOS " + linha
	Local cDPost  := ""
	Local cRevTFF := ""
	
	If funname() == "TECA930" .OR. funname() == "CNTA121" //Medição dos contratos

		cQuery := "SELECT MAX(TFF_CONREV) REVISAO  FROM " + RetSqlName("TFF") + " TFF "
		cQuery += "JOIN " + RetSqlName("TFL") + " TFL "
		cQuery += "ON TFF_LOCAL = TFL_LOCAL AND TFF_FILIAL = TFF_FILIAL AND TFL_CONTRT = TFF_CONTRT AND TFL_CODIGO = TFF_CODPAI "  
		cQuery += "WHERE TFF.D_E_L_E_T_ = ' ' AND "
		cQuery += "TFL.D_E_L_E_T_ = ' ' AND "
		cQuery += "TFF_FILIAL = '" + xFilial("TFF") + "' AND  "
		cQuery += "TFF_CONTRT = '" + M->C5_MDCONTR  + "' AND "
		cQuery += "TFL_FILIAL = '" + xFilial("TFL") + "' AND "
		cQuery += "TFL_CONTRT = '" + M->C5_MDCONTR  + "' AND "
		cQuery += "TFL_PLAN = '"   + M->C5_MDPLANI  + "' "

		TcQuery cQuery new Alias QTFFMAX
		cRevTFF := QTFFMAX->REVISAO
		QTFFMAX->(dbCloseArea())

		cQuery := "SELECT TFF_PRODUT,TFF_QTDVEN FROM " + RetSqlName("TFF") + " TFF "
		cQuery += "JOIN " + RetSqlName("TFL") + " TFL "
		cQuery += "ON TFF_LOCAL = TFL_LOCAL AND TFF_FILIAL = TFF_FILIAL AND TFL_CONTRT = TFF_CONTRT AND TFL_CODIGO = TFF_CODPAI AND TFF_CONREV = TFL_CONREV "  
		cQuery += "WHERE TFF.D_E_L_E_T_ = ' ' AND "
		cQuery += "TFL.D_E_L_E_T_ = ' ' AND "
		cQuery += "TFF_FILIAL = '" + xFilial("TFF") + "' AND  "
		cQuery += "TFF_CONTRT = '" + M->C5_MDCONTR  + "' AND "
		cQuery += "TFL_FILIAL = '" + xFilial("TFL") + "' AND "
		cQuery += "TFL_CONTRT = '" + M->C5_MDCONTR  + "' AND "
		cQuery += "TFL_PLAN = '"   + M->C5_MDPLANI  + "' AND "
		cQuery += "TFF_CONREV = '" + cRevTFF        + "' "
		cQuery += "GROUP BY TFF_PRODUT, TFF_QTDVEN " 

		TcQuery cQuery new Alias QTFF
		
		while QTFF->(!Eof())
			If QTFF->TFF_QTDVEN == 1
				cDPost := "POSTO"
			Else
				cDPost := "POSTOS"
			Endif
			
			cMsg += strzero(QTFF->TFF_QTDVEN,2) + " " + cDPost + " DE " + alltrim(posicione("SB1",1,xFilial("SB1") + QTFF->TFF_PRODUT, "B1_DESC"))
			
			QTFF->(dbSkip())
			
			If QTFF->(!Eof())
				cMsg += linha
			Endif
		Enddo
		QTFF->(dbCloseArea())

		cQuery := "SELECT TFL_YCC FROM "+RetSqlName("TFL")+ " TFL "
		cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
		cQuery += "TFL_FILIAL = '" + xFilial("TFL") + "' AND "
		cQuery += "TFL_CONTRT = '" + M->C5_MDCONTR  + "' AND "
		cQuery += "TFL_PLAN = '"   + M->C5_MDPLANI  + "' "
		TcQuery cQuery new Alias QTFL
		
		M->C5_YCC	  := QTFL->TFL_YCC
		M->C5_MENNOTA := cMsg 
		QTFL->(dbCloseArea())
	Endif
	restArea(aArea)
Return .T.