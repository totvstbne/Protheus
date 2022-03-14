#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RTECR03()

	Private oReport
	Private cPergCont	:= "RTECR03"
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

	oReport := TReport():New( 'Atendente x Agenda', 'Atendente x Agenda', cPergCont, {|oReport| ReportPrint( oReport ), 'Atendente x Agenda' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Atendente x Agenda', { 'ABB'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_SITUA'	    	        ,'T01', 'Situação'         ,			    		""						,70)
	AAdd( _CAMPTAB1, { "TMP_SITUA"	, 'C', 70, 0 } )
	TRCell():New( oSection1, 'TMP_SITAFA'	    	        ,'T01', 'Situação Afastamento'         ,			    		""						,60)
	AAdd( _CAMPTAB1, { "TMP_SITAFA"	, 'C', 60, 0 } )
	TRCell():New( oSection1, 'TMP_MAT'	    	        ,'T01', 'Matrícula'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_MAT"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'	    	    ,'T01', 'Nome'                 ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_CC'		        ,'T01', 'CC FUNC'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DESCC'	    	        ,'T01', 'Desc. CC FUNC'                  ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_DESCC"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_CCGS'		        ,'T01', 'CC GS'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_CCGS"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DCCGS'	    	        ,'T01', 'Desc. CC GS'                  ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_DCCGS"	, 'C', 50, 0 } )

	TRCell():New( oSection1, 'TMP_FUNGP'		        ,'T01', 'FUNCAO GPE'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_FUNGP"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DFUGP'	    	    ,'T01', 'Desc. FUNCAO GPE'                  ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_DFUGP"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_FUNGS'		        ,'T01', 'FUNCAO GS'               ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_FUNGS"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DFUGS'	    	    ,'T01', 'Desc. FUNCAO GS'                  ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_DFUGS"	, 'C', 50, 0 } )

	TRCell():New( oSection1, 'TMP_LOCAL'	    	    ,'T01', 'Local'            ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_LOCAL"	, 'C', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DESCL'		            ,'T01', 'Desc. Local'               ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DESCL"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_DTFLO'		        ,'T01', 'Data Fim RH'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTFLO"	, 'D', 08, 0 } )
	
	TRCell():New( oSection1, 'TMP_DTINI'		        ,'T01', 'Data Inicial'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTINI"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_HRINI'		            ,'T01', 'Hora Inicial'               ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_HRINI"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_DTFIM'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTFIM"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_HRFIM'		            ,'T01', 'Hora Fim'               ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_HRFIM"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_ESCAL'		            ,'T01', 'Escala'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_ESCAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_DESESC'		            ,'T01', 'Desc. Escala'               ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DESESC"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_TURTGY'		            ,'T01', 'Turno GS'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_TURTGY"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_TURNO'		            ,'T01', 'Turno Func.'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_TURNO"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_DTURN'		            ,'T01', 'Desc. Turno'               ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DTURN"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_CONTR'		            ,'T01', 'Contrato'               ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_CONTR"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_REVC'		            ,'T01', 'Rev. Contrato'               ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_REVC"	, 'C', 03, 0 } )

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
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_CC","TMP_MAT"})
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


	CQUERY := " SELECT RJ_FUNCAO, RJ_DESC,RA_FILIAL,CTT_CUSTO, CTT_DESC01, RA_MAT, RA_NOME, RA_ADMISSA, RA_DEMISSA, RA_NASC, RA_CIC, RA_PIS, RA_RG, RA_SENHA, RA_CATFUNC, RA_TNOTRAB, RA_SEQTURN "
	CQUERY += " FROM "+RETSQLNAME("SRA")+" RA "
	CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("SRJ")+" RJ  ON RJ_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RJ_FUNCAO = RA_CODFUNC AND RJ.D_E_L_E_T_ = ' ' "
	CQUERY += " WHERE RA_FILIAL = '"+MV_PAR01+"' AND RA.D_E_L_E_T_ = ' ' AND RA_DEMISSA = ' '  AND RA_CATFUNC <> 'A' AND RA_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND RA_CC BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'  ORDER BY RA_FILIAL,CTT_CUSTO,RA_MAT "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		CQUERY := " SELECT  RCM_TIPO, RCM_DESCRI, RA_FILIAL, RA_CC, RA_MAT, RA_NOME, R8_DATAINI, R8_DATAFIM   FROM "+RETSQLNAME("SR8")+" R8
		CQUERY += " INNER JOIN "+RETSQLNAME("SRA")+" SRA ON RA_MAT = '"+T01->RA_MAT+"' AND RA_FILIAL = '"+T01->RA_FILIAL+"' AND SRA.D_E_L_E_T_ = ' '
		CQUERY += " INNER JOIN "+RETSQLNAME("RCM")+" RCM ON RCM_TIPO = R8_TIPOAFA AND RCM_FILIAL = '"+XFILIAL("RCM")+"' AND RCM.D_E_L_E_T_ = ' '
		CQUERY += " WHERE R8_FILIAL = '"+XFILIAL("SR8")+"' AND R8_MAT = RA_MAT AND R8.D_E_L_E_T_  = ' ' AND ((R8_DATAINI  BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"') OR (R8_DATAFIM BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"')  OR (R8_DATAFIM = ' ')) "
		CQUERY += " GROUP BY  RCM_TIPO, RCM_DESCRI, RA_FILIAL, RA_CC, RA_MAT, RA_NOME, R8_DATAINI, R8_DATAFIM
		TcQuery CQUERY New Alias T03
		DbSelectArea("T03")
		_SITAFAS := ""
		While !T03->(Eof())
			_SITAFAS += ALLTRIM(T03->RCM_DESCRI)+"- "+DTOC(STOD(T03->R8_DATAINI))+ " A "+DTOC(STOD(T03->R8_DATAFIM))+" --- "
			T03->(DBSKIP())
		Enddo
		T03->(DBCLOSEAREA())

		CQUERY := " SELECT RJ_FUNCAO, RJ_DESC, TFF_PERFIM, RA_FILIAL, RA_MAT, RA_NOME, CTT.CTT_CUSTO CC, CTT.CTT_DESC01 DCC, CTT2.CTT_CUSTO CCGS, CTT2.CTT_DESC01 DCCGS, TFL_LOCAL, ABS_DESCRI, ABS_LATITU, ABS_LONGIT, ABB_DTINI, ABB_HRINI, ABB_DTFIM, ABB_HRFIM, TGY_ESCALA, TDW_DESC, TGY_CODTFF, TFF_CODPAI, TFL_CONTRT, TFL_CONREV, TGY_TURNO,R6_TURNO, R6_DESC FROM "+RETSQLNAME("ABB")+" ABB "
		CQUERY += " INNER JOIN "+RETSQLNAME("TFL")+" TFL ON TFL_FILIAL = ABB_FILIAL AND TFL_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND TFL.D_E_L_E_T_ = ' ' AND TFL_LOCAL = ABB_LOCAL "
		CQUERY += " INNER JOIN "+RETSQLNAME("TGY")+" TGY ON TGY_FILIAL = ABB_FILIAL AND TGY_ATEND = ABB_CODTEC AND TGY.D_E_L_E_T_ = ' '  "
		CQUERY += " INNER JOIN "+RETSQLNAME("TDW")+" TDW ON TDW_FILIAL = TGY_FILIAL AND TDW_COD = TGY_ESCALA AND TDW.D_E_L_E_T_ = ' '  "
		CQUERY += " INNER JOIN "+RETSQLNAME("TFF")+" TFF ON TFF_FILIAL = ABB_FILIAL AND TFF_COD = TGY_CODTFF AND TFF.D_E_L_E_T_ = ' ' AND TFL_CODIGO = TFF_CODPAI AND TFL_CONREV = TFF_CONREV "
		CQUERY += " INNER JOIN "+RETSQLNAME("SRA")+" RA  ON RA_FILIAL = ABB_FILIAL AND RA_MAT = SUBSTRING(ABB_CODTEC,7,6) AND RA.D_E_L_E_T_ = ' '  "
		CQUERY += " INNER JOIN "+RETSQLNAME("SR6")+" R6  ON R6_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND R6_TURNO = RA_TNOTRAB   AND R6.D_E_L_E_T_ = ' ' "
		CQUERY += " INNER JOIN "+RETSQLNAME("SRJ")+" RJ  ON RJ_FILIAL = SUBSTRING(TFF_FILIAL,1,2) AND RJ_FUNCAO = TFF_FUNCAO AND RJ.D_E_L_E_T_ = ' ' "
		CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT.CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' "
		CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT2 ON CTT2.CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT2.CTT_CUSTO = TFL_YCC AND CTT2.D_E_L_E_T_ = ' ' "
		CQUERY += " INNER JOIN "+RETSQLNAME("ABS")+" ABS ON ABS_FILIAL = ' ' AND ABS_LOCAL = TFL_LOCAL AND ABS.D_E_L_E_T_ = ' ' "
		CQUERY += " WHERE "
		CQUERY += " ABB_FILIAL = '"+T01->RA_FILIAL+"' AND ABB_CODTEC = '"+T01->RA_FILIAL+T01->RA_MAT+"' AND ABB.D_E_L_E_T_ = ' ' AND ABB_DTINI BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"' "

		TcQuery cQuery New Alias T02
		DbSelectArea("T01")

		IF !T02->(Eof())
			While !T02->(Eof())

				(CALIAS1)->(Reclock( CALIAS1, .T.))


				(CALIAS1)->TMP_FILIAL  :=  T02->RA_FILIAL

				_situa := "TEM AGENDA,"
				if alltrim(T02->CC) <> alltrim(T02->CCGS)
					_situa += "CC DIVERGENTE,"
				endif

				IF EMPTY(T02->ABS_LATITU) .OR. EMPTY(T02->ABS_LONGIT)
					_situa += "LATITUDE E LONGITUDE VAZIA,"
				ENDIF

				if alltrim(T02->TGY_TURNO) <> alltrim(T02->R6_TURNO)
					_situa += "TURNOS DIVERGENTE,"
				endif
				(CALIAS1)->TMP_SITUA   := _situa
				(CALIAS1)->TMP_SITAFA   :=_SITAFAS
				(CALIAS1)->TMP_MAT :=  T02->RA_MAT
				(CALIAS1)->TMP_NOME     :=  T02->RA_NOME
				(CALIAS1)->TMP_CC   :=  T02->CC
				(CALIAS1)->TMP_DESCC     :=  T02->DCC
				(CALIAS1)->TMP_LOCAL   :=  T02->TFL_LOCAL
				(CALIAS1)->TMP_CCGS   :=  T02->CCGS
				(CALIAS1)->TMP_DCCGS  := T02->DCCGS
				(CALIAS1)->TMP_FUNGP  := T01->RJ_FUNCAO
				(CALIAS1)->TMP_DFUGP  := T01->RJ_DESC
				(CALIAS1)->TMP_FUNGS  := T02->RJ_FUNCAO
				(CALIAS1)->TMP_DFUGS  := T02->RJ_DESC
				(CALIAS1)->TMP_DTFLO  := STOD(T02->TFF_PERFIM)
				(CALIAS1)->TMP_DESCL     :=  T02->ABS_DESCRI
				(CALIAS1)->TMP_DTINI   :=  STOD(T02->ABB_DTINI)
				(CALIAS1)->TMP_DTFIM   :=  STOD(T02->ABB_DTFIM)
				(CALIAS1)->TMP_HRINI   :=  T02->ABB_HRINI
				(CALIAS1)->TMP_HRFIM   :=  T02->ABB_HRFIM
				(CALIAS1)->TMP_ESCAL   :=  T02->TGY_ESCALA
				(CALIAS1)->TMP_DESESC   :=  T02->TDW_DESC
				(CALIAS1)->TMP_TURTGY  := T02->TGY_TURNO
				(CALIAS1)->TMP_TURNO   :=  T02->R6_TURNO
				(CALIAS1)->TMP_DTURN   :=  T02->R6_DESC
				(CALIAS1)->TMP_CONTR   :=  T02->TFL_CONTRT
				(CALIAS1)->TMP_REVC   :=  T02->TFL_CONREV

				(CALIAS1)->(MsUnlock())
				T02->(DBSKIP())
			Enddo
		else
			(CALIAS1)->(Reclock( CALIAS1, .T.))


			(CALIAS1)->TMP_FILIAL    :=  T01->RA_FILIAL
			(CALIAS1)->TMP_SITUA     := "NÃO AGENDADO"
			(CALIAS1)->TMP_SITAFA    :=_SITAFAS
			(CALIAS1)->TMP_MAT       :=  T01->RA_MAT
			(CALIAS1)->TMP_NOME      :=  T01->RA_NOME
			(CALIAS1)->TMP_CC        :=  T01->CTT_CUSTO
			(CALIAS1)->TMP_DESCC     :=  T01->CTT_DESC01
			(CALIAS1)->TMP_FUNGP     := T01->RJ_FUNCAO
			(CALIAS1)->TMP_DFUGP     := T01->RJ_DESC

			(CALIAS1)->(MsUnlock())
		ENDIF
		T02->(DBCLOSEAREA())
		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )



Return
