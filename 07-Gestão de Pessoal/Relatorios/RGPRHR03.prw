#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR03()

	Private oReport
	Private cPergCont	:= "TECR030"
	PRIVATE	_CAMPTAB1 := {}
	PRIVATE cAlias1			:= GetNextAlias()
	PRIVATE oTempTab1

	PRIVATE	_CAMPTAB2 := {}
	PRIVATE cAlias2		:= GetNextAlias()
	PRIVATE oTempTab2
	
	PRIVATE	_CAMPTAB3 := {}
	PRIVATE cAlias3			:= GetNextAlias()
	PRIVATE oTempTab3
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
	Local oSection2
	Local oSection3
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'Manutenção Alocações', 'Manutenção Alocações', cPergCont, {|oReport| ReportPrint( oReport ), 'Manutenção Alocações' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Manutenções', { 'SRA'})
	oSection2 := TRSection():New( oReport, 'Férias', { 'SRH'})
	oSection3 := TRSection():New( oReport, 'Ausências', { 'SR8'})



	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_DESCCC"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_CODFUN'	    	        ,'T01', 'Cod. Função'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_CODFUN"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_DESFUN'	    	    ,'T01', 'Desc Função'                 ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_DESFUN"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_CODTUR'	    	        ,'T01', 'Cod. Turno'         ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_CODTUR"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DESTUR'	    	    ,'T01', 'Desc Turno'                 ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_DESTUR"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_FERIAS'	    	    ,'T01', 'Férias'                 ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_FERIAS"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DIAS'	    	    ,'T01', 'Dia Semana'        ,			    		""						,10)
	AAdd( _CAMPTAB1, { "TMP_DIAS"	, 'C', 10, 0 } )
	TRCell():New( oSection1, 'TMP_DATAIN'		        ,'T01', 'Data Inicio'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DATAIN"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_HORAIN'	    	    ,'T01', 'Hora Inicio'        ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_HORAIN"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_DATAFI'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DATAFI"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_HORAFI'	    	    ,'T01', 'Hora Fim'        ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_HORAFI"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_LOCAL'	    	    ,'T01', 'Local'        ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_LOCAL"	, 'C', 08, 0 } )
	TRCell():New( oSection1, 'TMP_NOMLOC'	    	    ,'T01', 'Desc. Local'        ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_NOMLOC"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_HORATA'	    	    ,'T01', 'Horas Trabalhadas'        ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_HORATA"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_HORANA'	    	    ,'T01', 'Horas Não Trabalhadas'        ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_HORANA"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_MOTIV'	    	    ,'T01', 'Motivo'        ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_MOTIV"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_AUSEN'	    	    ,'T01', 'Ausência'        ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_AUSEN"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_OBS'	    	    ,'T01', 'Obs.'        ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_OBS"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_DATA'		            ,'T01', 'DATA'               ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DATA"	, 'C', 08, 0 } )






	TRCell():New( oSection2, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB2, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection2, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,30)
	AAdd( _CAMPTAB2, { "TMP_DESCCC"	, 'C', 30, 0 } )
	TRCell():New( oSection2, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,30)
	AAdd( _CAMPTAB2, { "TMP_NOME"	, 'C', 30, 0 } )
	TRCell():New( oSection2, 'TMP_CODFUN'	    	        ,'T01', 'Cod. Função'         ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_CODFUN"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_DESFUN'	    	    ,'T01', 'Desc Função'                 ,			    		""						,30)
	AAdd( _CAMPTAB2, { "TMP_DESFUN"	, 'C', 30, 0 } )
	TRCell():New( oSection2, 'TMP_CODTUR'	    	        ,'T01', 'Cod. Turno'         ,			    		""						,03)
	AAdd( _CAMPTAB2, { "TMP_CODTUR"	, 'C', 03, 0 } )
	TRCell():New( oSection2, 'TMP_DESTUR'	    	    ,'T01', 'Desc Turno'                 ,			    		""						,30)
	AAdd( _CAMPTAB2, { "TMP_DESTUR"	, 'C', 30, 0 } )
	TRCell():New( oSection2, 'TMP_DATAIN'		        ,'T01', 'Data Inicio'            ,				   		""						,08)
	AAdd( _CAMPTAB2, { "TMP_DATAIN"	, 'D', 08, 0 } )
	TRCell():New( oSection2, 'TMP_DATAFI'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB2, { "TMP_DATAFI"	, 'D', 08, 0 } )


	TRCell():New( oSection3, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB3, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection3, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_DESCCC"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_NOME"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_CODFUN'	    	        ,'T01', 'Cod. Função'         ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_CODFUN"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_DESFUN'	    	    ,'T01', 'Desc Função'                 ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_DESFUN"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_CODTUR'	    	        ,'T01', 'Cod. Turno'         ,			    		""						,03)
	AAdd( _CAMPTAB3, { "TMP_CODTUR"	, 'C', 03, 0 } )
	TRCell():New( oSection3, 'TMP_DESTUR'	    	    ,'T01', 'Desc Turno'                 ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_DESTUR"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_CODAUS'	    	        ,'T01', 'Cod. Ausencia'         ,			    		""						,03)
	AAdd( _CAMPTAB3, { "TMP_CODAUS"	, 'C', 03, 0 } )
	TRCell():New( oSection3, 'TMP_DESAUS'	    	    ,'T01', 'Desc Ausencia'                 ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_DESAUS"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_DATAIN'		        ,'T01', 'Data Inicio'            ,				   		""						,08)
	AAdd( _CAMPTAB3, { "TMP_DATAIN"	, 'D', 08, 0 } )
	TRCell():New( oSection3, 'TMP_DATAFI'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB3, { "TMP_DATAFI"	, 'D', 08, 0 } )


/*
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
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)

	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC","TMP_DATA","TMP_MOTIV"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab3:Create()
	(CALIAS3)->(dbGotop())

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



	oTempTab1:DELETE()
	oTempTab2:DELETE()
	oTempTab3:DELETE()


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


	cSql := " SELECT RJ_FUNCAO, RJ_DESC, R6_TURNO, R6_DESC, ABN_DESC,ABN_YGRFAL,ABR_TEMPO, ABB_HRTOT, RA_FILIAL, RA_MAT, RA_CC,  RA_NOME, CTT_DESC01, ABS_DESCRI, ABS_LOCAL, ABS_DESCRI, ABS_CCUSTO, ABB_DTINI, ABB_HRINI, ABB_DTFIM, ABB_HRFIM,
	cSql += " AA1_NOMTEC, ABR_MOTIVO, ABR_CODSUB, COALESCE(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047),ABR_OBSERV)),' ') AS ABR_OBSERV, RA_CIC

	cSql += " FROM "+RETSQLNAME("ABS")+" ABS
	cSql += " INNER JOIN "+RETSQLNAME("ABB")+" ABB ON ABB_LOCAL = ABS_LOCAL
	cSql += " INNER JOIN "+RETSQLNAME("AA1")+" AA1 ON AA1_CODTEC = ABB_CODTEC
	cSql += " INNER JOIN "+RETSQLNAME("ABR")+" ABR ON ABR_AGENDA = ABB_CODIGO
	cSql += " INNER JOIN "+RETSQLNAME("ABN")+" ABN ON ABN_CODIGO = ABR_MOTIVO
	cSql += " INNER JOIN "+RETSQLNAME("SRA")+" SRA ON RA_MAT = AA1_CDFUNC
	cSql += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_CUSTO = RA_CC
	cSql += " INNER JOIN "+RETSQLNAME("SRJ")+" SRJ ON RJ_FUNCAO = RA_CODFUNC
	cSql += " INNER JOIN "+RETSQLNAME("SR6")+" SR6 ON R6_TURNO = AA1_TURNO

	cSql += " WHERE ABS_FILIAL =  '"+XFILIAL("ABS")+"'
	cSql += " AND	ABB_FILIAL =  '"+XFILIAL("ABB")+"'
	cSql += " AND AA1_FILIAL = '"+XFILIAL("AA1")+"'
	cSql += " AND ABR_FILIAL = '"+XFILIAL("ABR")+"'
	cSql += " AND RA_FILIAL = '"+XFILIAL("SRA")+"'
	cSql += " AND CTT_FILIAL = '"+XFILIAL("CTT")+"'
	cSql += " AND ABN_FILIAL = '"+XFILIAL("ABN")+"'
	cSql += " AND R6_FILIAL = '"+XFILIAL("SR6")+"'
	cSql += " AND RJ_FILIAL = '"+XFILIAL("SRJ")+"'
	cSql += " AND ABS.D_E_L_E_T_ = ' '
	cSql += " AND ABB.D_E_L_E_T_ = ' '
	cSql += " AND AA1.D_E_L_E_T_ = ' '
	cSql += " AND ABR.D_E_L_E_T_ = ' '
	cSql += " AND SRA.D_E_L_E_T_ = ' '
	cSql += " AND CTT.D_E_L_E_T_ = ' '
	cSql += " AND ABN.D_E_L_E_T_ = ' '
	cSql += " AND SR6.D_E_L_E_T_ = ' '
	cSql += " AND SRJ.D_E_L_E_T_ = ' '
	cSql += " AND ABS_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	cSql += " AND ABB_CODTEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cSql += " AND ABB_DTINI BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cSql += " AND ABR_MOTIVO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"

	cSql += " ORDER BY ABB_CODTEC, ABB_DTINI



	TcQuery cSql New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())
		nDia := DOW(stod(T01->ABB_DTINI))
		If nDia == 1
			cDia := "Domingo"
		ElseIf nDia == 2
			cDia := "Segunda"
		ElseIf nDia == 3
			cDia := "Terça"
		ElseIf nDia == 4
			cDia := "Quarta"
		ElseIf nDia == 5
			cDia := "Quinta"
		ElseIf nDia == 6
			cDia := "Sexta"
		ElseIf nDia == 7
			cDia := "Sábado"
		EndIf

		nHora1 := horaToInt(T01->ABB_HRINI)
		nHora2 := horaToInt(T01->ABB_HRFIM)
		If nHora1 < nHora2
			nQtdHora := SUBHORAS(nHora2,nHora1)
		ElseIf nHora1 > nHora2
			nQtdHora := SOMAHORAS(nHora2,nHora1)
			nQtdHora := nQtdHora - 24
		Else
			nQtdHora := 0
		EndIf

		_chave := T01->RA_FILIAL+T01->RA_MAT+T01->ABB_DTINI+T01->ABN_DESC


		CQUERY := " SELECT COUNT(*) CONT_FER FROM "+RETSQLNAME("SRH")+" RH WHERE RH_ROTEIR = 'FER' AND RH_FILIAL = '"+T01->RA_FILIAL+"' AND RH_MAT = '"+T01->RA_MAT+"' AND RH.D_E_L_E_T_  = ' ' AND RH_DATAINI <= '"+T01->ABB_DTINI+"' AND RH_DATAFIM >= '"+T01->ABB_DTINI+"' "

		TcQuery CQUERY New Alias T02
		DbSelectArea("T02")
		_CFER := "NÃO"
		IF !EMPTY(T02->CONT_FER)
			_CFER := "SIM"
		ENDIF
		T02->(DBCLOSEAREA())

		DBSELECTAREA((CALIAS1))
		DBSETORDER(1)
		IF DBSEEK(_chave) .AND. T01->ABN_YGRFAL == "S"

			(CALIAS1)->(Reclock( CALIAS1, .F.))
			(CALIAS1)->TMP_DATAFI := STOD(T01->ABB_DTFIM)
			(CALIAS1)->TMP_HORAFI := T01->ABB_HRFIM
			(CALIAS1)->TMP_HORATA  := ""
			(CALIAS1)->TMP_HORANA := ""
		else
			(CALIAS1)->(Reclock( CALIAS1, .T.))
			(CALIAS1)->TMP_FILIAL   :=T01->RA_FILIAL
			(CALIAS1)->TMP_CC := T01->RA_CC
			(CALIAS1)->TMP_DESCCC := T01->CTT_DESC01
			(CALIAS1)->TMP_MATRIC := T01->RA_MAT
			(CALIAS1)->TMP_NOME := T01->RA_NOME
			(CALIAS1)->TMP_CODFUN :=  T01->RJ_FUNCAO
			(CALIAS1)->TMP_DESFUN := T01->RJ_DESC
			(CALIAS1)->TMP_CODTUR :=  T01->R6_TURNO
			(CALIAS1)->TMP_DESTUR := T01->R6_DESC
			(CALIAS1)->TMP_FERIAS := _CFER
			(CALIAS1)->TMP_DIAS := cDia
			(CALIAS1)->TMP_DATA := T01->ABB_DTINI
			(CALIAS1)->TMP_DATAIN := STOD(T01->ABB_DTINI)
			(CALIAS1)->TMP_HORAIN := T01->ABB_HRINI
			(CALIAS1)->TMP_DATAFI := STOD(T01->ABB_DTFIM)
			(CALIAS1)->TMP_HORAFI := T01->ABB_HRFIM
			(CALIAS1)->TMP_LOCAL := T01->ABS_LOCAL
			(CALIAS1)->TMP_NOMLOC := AllTrim(T01->ABS_DESCRI)
			IF T01->ABN_YGRFAL == "N"
				(CALIAS1)->TMP_HORATA  := SUBSTR(T01->ABB_HRTOT,6,5)//AllTrim(IntToHora(nQtdHora))
				(CALIAS1)->TMP_HORANA := T01->ABR_TEMPO
			ENDIF
			(CALIAS1)->TMP_MOTIV := T01->ABN_DESC

			(CALIAS1)->TMP_OBS := AllTrim(T01->ABR_OBSERV)


			cQuery := " SELECT RCM_TIPO, RCM_DESCRI
			cQuery += " FROM "+RETSQLNAME("SR8")+" SR8
			cQuery += " INNER JOIN "+RETSQLNAME("RCM")+" RCM ON RCM_FILIAL = SUBSTRING(R8_FILIAL,1,2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = ' '
			cQuery += " WHERE SR8.D_E_L_E_T_ = ' '
			cQuery += " AND R8_FILIAL ='"+ T01->RA_FILIAL +"'
			cQuery += " AND R8_MAT ='"+ T01->RA_MAT +"'
			cQuery += " AND R8_DATAINI >= '"+T01->ABB_DTINI+"'
			cQuery += " AND R8_DATAFIM <= '"+T01->ABB_DTINI+"'

			IF SELECT("TVAL") > 0
				TVAL->(DBCLOSEAREA())
			ENDIF

			TcQuery cQuery New Alias TVAL

			(CALIAS1)->TMP_AUSEN := TVAL->RCM_TIPO+"-"+RCM_DESCRI
		endif

		(CALIAS1)->(MsUnlock())

		T01->(DBSKIP())
	Enddo

	T01->( dbCloseArea() )
	CQUERY := " SELECT RJ_FUNCAO, RJ_DESC, RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, R6_TURNO, R6_DESC, RH_DATAINI, RH_DATAFIM   FROM "+RETSQLNAME("SRH")+" RH
	CQUERY += " INNER JOIN "+RETSQLNAME("AA1")+" AA1 ON AA1_CODTEC = RH_FILIAL+RH_MAT AND AA1_FILIAL = RH_FILIAL AND AA1.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("ABB")+" ABB ON  ABB_CODTEC = AA1_CODTEC AND AA1.D_E_L_E_T_ = ' ' AND  ABB_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'  AND  ABB_CODTEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'
	CQUERY += " INNER JOIN "+RETSQLNAME("SRA")+" SRA ON RA_MAT = AA1_CDFUNC AND RA_FILIAL = AA1_FILIAL AND SRA.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_CUSTO = RA_CC AND CTT_FILIAL = '"+XFILIAL("CTT")+"' AND CTT.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("SR6")+" SR6 ON R6_TURNO = AA1_TURNO AND R6_FILIAL = '"+XFILIAL("SR6")+"' AND SR6.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("SRJ")+" SRJ ON RJ_FUNCAO = RA_CODFUNC AND RJ_FILIAL = '"+XFILIAL("SRJ")+"' AND SRJ.D_E_L_E_T_ = ' '
	CQUERY += " WHERE RH_FILIAL = '"+XFILIAL("SRH")+"' AND RH_ROTEIR = 'FER' AND RH.D_E_L_E_T_  = ' ' AND ((RH_DATAINI  BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') OR (RH_DATAFIM BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') ) "
	CQUERY += " GROUP BY RJ_FUNCAO, RJ_DESC, RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, R6_TURNO, R6_DESC, RH_DATAINI, RH_DATAFIM
	TcQuery CQUERY New Alias T03
	DbSelectArea("T03")

	While !T03->(Eof())

		(CALIAS2)->(Reclock( CALIAS2, .T.))
		(CALIAS2)->TMP_FILIAL   :=T03->RA_FILIAL
		(CALIAS2)->TMP_CC := T03->RA_CC
		(CALIAS2)->TMP_DESCCC := T03->CTT_DESC01
		(CALIAS2)->TMP_MATRIC := T03->RA_MAT
		(CALIAS2)->TMP_NOME := T03->RA_NOME
		(CALIAS2)->TMP_CODFUN :=  T03->RJ_FUNCAO
		(CALIAS2)->TMP_DESFUN := T03->RJ_DESC
		(CALIAS2)->TMP_CODTUR :=  T03->R6_TURNO
		(CALIAS2)->TMP_DESTUR := T03->R6_DESC
		(CALIAS2)->TMP_DATAIN := STOD(T03->RH_DATAINI)
		(CALIAS2)->TMP_DATAFI := STOD(T03->RH_DATAFIM)
		(CALIAS2)->(MsUnlock())
		T03->(DBSKIP())
	ENDDO

	T03->(DBCLOSEAREA())


	CQUERY := " SELECT RCM_TIPO, RCM_DESCRI, RJ_FUNCAO, RJ_DESC, RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, R6_TURNO, R6_DESC, R8_DATAINI, R8_DATAFIM   FROM "+RETSQLNAME("SR8")+" R8
	CQUERY += " INNER JOIN "+RETSQLNAME("AA1")+" AA1 ON AA1_CODTEC = R8_FILIAL+R8_MAT AND AA1_FILIAL = R8_FILIAL AND AA1.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("ABB")+" ABB ON  ABB_CODTEC = AA1_CODTEC AND AA1.D_E_L_E_T_ = ' ' AND  ABB_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'  AND  ABB_CODTEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'
	CQUERY += " INNER JOIN "+RETSQLNAME("SRA")+" SRA ON RA_MAT = AA1_CDFUNC AND RA_FILIAL = AA1_FILIAL AND SRA.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_CUSTO = RA_CC AND CTT_FILIAL = '"+XFILIAL("CTT")+"' AND CTT.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("SR6")+" SR6 ON R6_TURNO = AA1_TURNO AND R6_FILIAL = '"+XFILIAL("SR6")+"' AND SR6.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("SRJ")+" SRJ ON RJ_FUNCAO = RA_CODFUNC AND RJ_FILIAL = '"+XFILIAL("SRJ")+"' AND SRJ.D_E_L_E_T_ = ' '
	CQUERY += " INNER JOIN "+RETSQLNAME("RCM")+" RCM ON RCM_TIPO = R8_TIPOAFA AND RCM_FILIAL = '"+XFILIAL("RCM")+"' AND RCM.D_E_L_E_T_ = ' '
	CQUERY += " WHERE R8_FILIAL = '"+XFILIAL("SR8")+"' AND R8.D_E_L_E_T_  = ' ' AND ((R8_DATAINI  BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') OR (R8_DATAFIM BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"')  OR (R8_DATAFIM = ' ')) "
	CQUERY += " GROUP BY RCM_TIPO, RCM_DESCRI, RJ_FUNCAO, RJ_DESC, RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, R6_TURNO, R6_DESC, R8_DATAINI, R8_DATAFIM
	TcQuery CQUERY New Alias T03
	DbSelectArea("T03")

	While !T03->(Eof())

		(CALIAS3)->(Reclock( CALIAS3, .T.))
		(CALIAS3)->TMP_FILIAL   :=T03->RA_FILIAL
		(CALIAS3)->TMP_CC := T03->RA_CC
		(CALIAS3)->TMP_DESCCC := T03->CTT_DESC01
		(CALIAS3)->TMP_MATRIC := T03->RA_MAT
		(CALIAS3)->TMP_NOME := T03->RA_NOME
		(CALIAS3)->TMP_CODFUN :=  T03->RJ_FUNCAO
		(CALIAS3)->TMP_DESFUN := T03->RJ_DESC
		(CALIAS3)->TMP_CODTUR :=  T03->R6_TURNO
		(CALIAS3)->TMP_DESTUR := T03->R6_DESC
		(CALIAS3)->TMP_CODAUS :=  T03->RCM_TIPO
		(CALIAS3)->TMP_DESAUS := T03->RCM_DESCRI
		(CALIAS3)->TMP_DATAIN := STOD(T03->R8_DATAINI)
		(CALIAS3)->TMP_DATAFI := STOD(T03->R8_DATAFIM)
		(CALIAS3)->(MsUnlock())
		T03->(DBSKIP())
	ENDDO

	T03->(DBCLOSEAREA())
Return
