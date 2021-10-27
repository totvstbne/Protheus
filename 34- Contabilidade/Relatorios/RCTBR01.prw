#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RCTBR01()

	Private oReport
	Private cPergCont	:= "RCTBR01"
	PRIVATE	_CAMPTAB1 := {}
	PRIVATE cAlias1			:= GetNextAlias()
	PRIVATE oTempTab1
	/*
	PRIVATE	_CAMPTAB2 := {}
	PRIVATE cAlias2		:= GetNextAlias()
	PRIVATE oTempTab2
	PRIVATE	_CAMPTAB3 := {}
	PRIVATE cAlias3			:= GetNextAlias()
	PRIVATE oTempTab3*/
	//************************
	//*Monta pergunte do Log *
	//************************
	//ValidPerg(cPergCont)
	If !Pergunte(cPergCont, .T.)
		Return
	Endif
	//	_cempant := cempant

	//cempant := MV_PAR01
	oReport := ReportDef()
	If oReport == Nil
		Return( Nil )
	EndIf

	oReport:PrintDialog()
	//	cempant := _cempant
return ( Nil )

//_____________________________________________________________________________
/*/{Protheus.doc} ReportDef
Monta impressao via TReport;

@author RODRIGO LUCAS
@since 07/11/2018
@version P12
/*/
//_____________________________________________________________________________


Static Function ReportDef()

	//Local nOrd	:= 1
	Local oReport
	Local oSection1
	//Local oSection2
	//Local oSection3
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'Visão por setor', 'Visão por setor', cPergCont, {|oReport| ReportPrint( oReport ), 'Visão por setor' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Visão por setor', { 'CT2'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_VISAO'	    	        ,'T01', 'Visão Gerencial'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VISAO"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_CONTA'	    	        ,'T01', 'Conta'         ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_CONTA"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DESCO'	        	    ,'T01', 'Desc Conta'                 ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_DESCO"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_CC'		        ,'T01', 'CC'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DESCC'	    	        ,'T01', 'Desc. CC'                  ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_DESCC"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_DATA'		        ,'T01', 'Data '            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DATA"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_LSDL'		            ,'T01', 'LOTE/SUBLOTE/DOC/LINHA'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_LSDL"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_HIST'		            ,'T01', 'Histórico'               ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_HIST"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_CONTR'		            ,'T01', 'Contra partida'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_CONTR"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_ITEM'		            ,'T01', 'Item Contab.'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_ITEM"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_CLVL'		            ,'T01', 'Class. Valor'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_CLVL"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DEBIT'	    	    ,'T01', 'Débito'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_DEBIT"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_CREDI'	    	    ,'T01', 'Crédito'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_CREDI"	, 'N', 14, 2 } )


/*TMP_FILIAL,TMP_MAT,TMP_NOME,TMP_CC,TMP_DESCC,TMP_LOCAL,TMP_DESCL,TMP_DTINI,TMP_HRINI,TMP_DTFIM,TMP_HRFIM,TMP_ESCAL,TMP_DESESC,TMP_CONTR,TMP_REVC
	TRCell():New( oSection2, 'TMP_CC'		        ,'T01', 'Centro de custo'                  ,			    		""						,30)
	AAdd( _CAMPTAB2, { "TMP_CC"	, 'C', 30, 0 } )

	TRCell():New( oSection2, 'TMP_QTDFUN'		        ,'T01', 'Qtd Funcionários'        ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDFUN"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_SALARI'	    	    ,'T01', 'Salario Base'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_SALARI"	, 'N', 14, 2 } )



	TRCell():New( oSection3, 'TMP_FUNC'		        ,'T01', 'Função'                  ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_FUNC"	, 'C', 30, 0 } )

	TRCell():New( oSection3, 'TMP_QTDFUN'		        ,'T01', 'Qtd Funcionários'        ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDFUN"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_SALARI'	    	    ,'T01', 'Salario Base'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_SALARI"	, 'N', 14, 2 } )

*/
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")

Return( oReport )

//_____________________________________________________________________________
/*/{Protheus.doc} ReportPrint
Rotina responsavel pela busca e carregamentos dos dados a serem impressos;

@author Rodrigo Lucas
@since 07 de Novembro de 2018
@version P12
/*/
//_____________________________________________________________________________
Static Function ReportPrint( oReport  )

	Local oSection1 	:= oReport:Section(1)
//	Local oSection2 	:= oReport:Section(2)
//	Local oSection3 	:= oReport:Section(3)

	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_VISAO","TMP_DATA"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())
/*
	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_CC"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_FUNC"})
	oTempTab3:Create()
	(CALIAS3)->(dbGotop())
*/

	Query()

	//oSection1:SetHeaderSection(.T.)
	DBSELECTAREA((CALIAS1))
	(CALIAS1)->(DBGOTOP())
	WHILE !(CALIAS1)->(EOF())
		oSection1:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB1)

			oSection1:Cell(_CAMPTAB1[nx,1]):SetValue( &((CALIAS1)+"->"+_CAMPTAB1[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection1:PrintLine()
		(CALIAS1)->(DBSKIP())
	ENDDO

	oSection1:Finish()
/*
	DBSELECTAREA((CALIAS2))
	(CALIAS2)->(DBGOTOP())
	WHILE !(CALIAS2)->(EOF())
		oSection2:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB2)

			oSection2:Cell(_CAMPTAB2[nx,1]):SetValue( &((CALIAS2)+"->"+_CAMPTAB2[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection2:PrintLine()
		(CALIAS2)->(DBSKIP())
	ENDDO

	oSection2:Finish()

	DBSELECTAREA((CALIAS3))
	(CALIAS3)->(DBGOTOP())
	WHILE !(CALIAS3)->(EOF())
		oSection3:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB3)

			oSection3:Cell(_CAMPTAB3[nx,1]):SetValue( &((CALIAS3)+"->"+_CAMPTAB3[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection3:PrintLine()
		(CALIAS3)->(DBSKIP())
	ENDDO

	oSection3:Finish()
*/


	oTempTab1:DELETE()
//	oTempTab2:DELETE()
//	oTempTab3:DELETE()


Return( Nil )

//_____________________________________________________________________________
/*/{Protheus.doc} AjustaSX1
Cria as perguntas no SX1;

@author Rayanne Meneses
@since 28/07/2018
@version P12
/*/
//_____________________________________________________________________________



//_____________________________________________________________________________
/*/{Protheus.doc} Query
Consulta ao banco

@author Rayanne Meneses
@since 28/07/2018
@version P12
/*/
//_____________________________________________________________________________
Static Function Query( aSection1, aSection2, aSection3, aVLR1,aVLR2,aVLR3 )


	CQUERY := " SELECT CT2_FILIAL, CT2_DEBITO, CT1D.CT1_DESC01 DESCDEB, CT2_CREDIT, CT1C.CT1_DESC01 DESCCRE, CT2_VALOR, CT2_CCC, CTTC.CTT_DESC01 DESCCCC, CT2_CCD, CTTD.CTT_DESC01 DESCCCD, CT2_DATA, CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA LSDL, CT2_HIST, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR "
	CQUERY += " FROM "+RETSQLNAME("CT2")+" CT2 "
	CQUERY += " LEFT JOIN "+RETSQLNAME("CTT")+" CTTD ON CTTD.CTT_FILIAL = SUBSTRING(CT2_FILIAL,1,2) AND CTTD.CTT_CUSTO = CT2_CCD AND CTTD.D_E_L_E_T_ = ' ' "
	CQUERY += " LEFT JOIN "+RETSQLNAME("CTT")+" CTTC ON CTTC.CTT_FILIAL = SUBSTRING(CT2_FILIAL,1,2) AND CTTC.CTT_CUSTO = CT2_CCC AND CTTC.D_E_L_E_T_ = ' ' "
	CQUERY += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1D ON CT1D.CT1_FILIAL = '"+xfilial("CT1")+"' AND CT1D.CT1_CONTA = CT2_DEBITO AND CT1D.D_E_L_E_T_ = ' ' "
	CQUERY += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1C ON CT1C.CT1_FILIAL = '"+xfilial("CT1")+"' AND CT1C.CT1_CONTA = CT2_CREDIT AND CT1C.D_E_L_E_T_ = ' ' "
	CQUERY += " WHERE CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND CT2.D_E_L_E_T_ = ' ' "
	CQUERY += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
	CQUERY += " ( "

	cqrycts := " SELECT * FROM "+RETSQLNAME("CTS")+" CTS WHERE CTS_FILIAL = '"+XFILIAL("CTS")+"' AND CTS_CODPLA = '"+MV_PAR05+"' AND CTS.D_E_L_E_T_ = ' ' AND CTS_CLASSE = '2' "

	TcQuery cqrycts New Alias T02
	DbSelectArea("T02")
	_NCONT := 1
	_DESCVIS := ""
	While !T02->(Eof())
		_DESCVIS := T02->CTS_NOME
		IF _NCONT == 1
			CQUERY += " (  ( CT2_DEBITO BETWEEN '"+T02->CTS_CT1INI+"' AND '"+T02->CTS_CT1FIM+"' AND CT2_CCD BETWEEN '"+T02->CTS_CTTINI+"' AND '"+T02->CTS_CTTFIM+"' ) OR "
			CQUERY += "    ( CT2_CREDIT BETWEEN '"+T02->CTS_CT1INI+"' AND '"+T02->CTS_CT1FIM+"' AND CT2_CCC BETWEEN '"+T02->CTS_CTTINI+"' AND '"+T02->CTS_CTTFIM+"' ) )"
		else
			CQUERY += " OR (  ( CT2_DEBITO BETWEEN '"+T02->CTS_CT1INI+"' AND '"+T02->CTS_CT1FIM+"' AND CT2_CCD BETWEEN '"+T02->CTS_CTTINI+"' AND '"+T02->CTS_CTTFIM+"' ) OR "
			CQUERY += "    ( CT2_CREDIT BETWEEN '"+T02->CTS_CT1INI+"' AND '"+T02->CTS_CT1FIM+"' AND CT2_CCC BETWEEN '"+T02->CTS_CTTINI+"' AND '"+T02->CTS_CTTFIM+"' ) )"
		ENDIF

		_NCONT++
		T02->(DBSKIP())
	ENDDO
	T02->(dbCloseArea())
	CQUERY += " ) "
	CQUERY += " ORDER BY CT2_DATA"


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		//,,,,,

		(CALIAS1)->(Reclock( CALIAS1, .T.))


		(CALIAS1)->TMP_FILIAL  :=  T01->CT2_FILIAL
		(CALIAS1)->TMP_VISAO   := _DESCVIS
		(CALIAS1)->TMP_DATA   :=  STOD(T01->CT2_DATA)
		(CALIAS1)->TMP_LSDL     :=  T01->LSDL
		(CALIAS1)->TMP_HIST   :=  T01->CT2_HIST
		IF !EMPTY(T01->CT2_CCC)
			(CALIAS1)->TMP_CONTA :=  T01->CT2_CREDIT
			(CALIAS1)->TMP_DESCO     :=  T01->DESCCRE
			(CALIAS1)->TMP_CC   :=  T01->CT2_CCC
			(CALIAS1)->TMP_DESCC     :=  T01->DESCCCC
			(CALIAS1)->TMP_CONTR   :=  T01->CT2_DEBITO
			(CALIAS1)->TMP_ITEM   :=  T01->CT2_ITEMC
			(CALIAS1)->TMP_CLVL   :=  T01->CT2_CLVLCR
			(CALIAS1)->TMP_DEBIT   :=  0
			(CALIAS1)->TMP_CREDI   :=  T01->CT2_VALOR
			//(CALIAS1)->TMP_SALDO   -=  T01->CT2_VALOR
		ENDIF

		IF !EMPTY(T01->CT2_CCD)
			(CALIAS1)->TMP_CONTA :=  T01->CT2_DEBITO
			(CALIAS1)->TMP_DESCO     :=  T01->DESCDEB
			(CALIAS1)->TMP_CC   :=  T01->CT2_CCD
			(CALIAS1)->TMP_DESCC     :=  T01->DESCCCD
			(CALIAS1)->TMP_CONTR   :=  T01->CT2_CREDIT
			(CALIAS1)->TMP_ITEM   :=  T01->CT2_ITEMD
			(CALIAS1)->TMP_CLVL   :=  T01->CT2_CLVLDB
			(CALIAS1)->TMP_DEBIT   :=  T01->CT2_VALOR
			(CALIAS1)->TMP_CREDI   :=  0
			//(CALIAS1)->TMP_SALDO   -=  T01->CT2_VALOR
		ENDIF

		(CALIAS1)->(MsUnlock())

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )



Return
