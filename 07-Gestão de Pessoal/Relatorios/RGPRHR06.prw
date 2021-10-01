#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR06()

	Private oReport
	Private cPergCont	:= PadR('RGPRHR06' ,10)
	PRIVATE _averbper := {}
	PRIVATE	_CAMPTAB1 := {}
	PRIVATE _CAMPTAB2 := {}
	PRIVATE _CAMPTAB3 := {}
	PRIVATE _CAMPTAB4 := {}
	PRIVATE cAlias1			:= GetNextAlias()
	PRIVATE cAlias2			:= GetNextAlias()
	PRIVATE cAlias3			:= GetNextAlias()
	PRIVATE cAlias4			:= GetNextAlias()
	PRIVATE oTempTab1
	PRIVATE oTempTab2
	PRIVATE oTempTab3
	PRIVATE oTempTab4
	************************
	*Monta pergunte do Log *
	************************
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
//	Local oSection4
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'TurnOver', 'TurnOver', cPergCont, {|oReport| ReportPrint( oReport ), 'TurnOver' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

//	oSection1 := TRSection():New( oReport, 'Geral', { 'SRA'})
	oSection1 := TRSection():New( oReport, 'Empresa', { 'SRA'})
	oSection2 := TRSection():New( oReport, 'Filial', { 'SRA'})
	oSection3 := TRSection():New( oReport, 'CC', { 'SRA'})

	//Indicador Comprador
	TRCell():New( oSection1, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,02)
	AAdd( _CAMPTAB1, { "TMP_EMPRES"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_PERIOD'		    	,'T01', 'Período'                 ,						""                      ,06)
	AAdd( _CAMPTAB1, { "TMP_PERIOD"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_ATIVOS'		    	,'T01', 'Total de funcionários'                 ,						""                      ,06)
	AAdd( _CAMPTAB1, { "TMP_ATIVOS"	, 'N', 6, 0 } )
	TRCell():New( oSection1, 'TMP_ADMISS'		    	,'T01', 'Admissões'                 ,						""                      ,06)
	AAdd( _CAMPTAB1, { "TMP_ADMISS"	, 'N', 6, 0 } )
	TRCell():New( oSection1, 'TMP_DEMISS'		    	,'T01', 'Demissões'                 ,						""                      ,06)
	AAdd( _CAMPTAB1, { "TMP_DEMISS"	, 'N', 6, 0 } )
	TRCell():New( oSection1, 'TMP_TURNT'		    	,'T01', '% Turnover tradicional'                 ,						""                      ,12)
	AAdd( _CAMPTAB1, { "TMP_TURNT"	, 'N', 10, 4 } )
	TRCell():New( oSection1, 'TMP_TURND'		    	,'T01', '% Turnover demissional'                 ,						""                      ,12)
	AAdd( _CAMPTAB1, { "TMP_TURND"	, 'N', 10, 4 } )
	TRCell():New( oSection1, 'TMP_ADMDET'		    	,'T01', 'Admissões Determinado'                 ,						""                      ,06)
	AAdd( _CAMPTAB1, { "TMP_ADMDET"	, 'N', 6, 0 } )
	TRCell():New( oSection1, 'TMP_DEMDET'		    	,'T01', 'Demissões Determinado'                 ,						""                      ,06)
	AAdd( _CAMPTAB1, { "TMP_DEMDET"	, 'N', 6, 0 } )
	TRCell():New( oSection1, 'TMP_TURGT'		    	,'T01', '% Turnover trad. - Determinados'                 ,						""                      ,12)
	AAdd( _CAMPTAB1, { "TMP_TURGT"	, 'N', 10, 4 } )
	TRCell():New( oSection1, 'TMP_TURGD'		    	,'T01', '% Turnover demi. - Determinado'                 ,						""                      ,12)
	AAdd( _CAMPTAB1, { "TMP_TURGD"	, 'N', 10, 4 } )

	TRCell():New( oSection2, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,02)
	AAdd( _CAMPTAB2, { "TMP_EMPRES"	, 'C', 02, 0 } )
	TRCell():New( oSection2, 'TMP_FILIAL'		    	,'T01', 'Filial'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_PERIOD'		    	,'T01', 'Período'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_PERIOD"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_ATIVOS'		    	,'T01', 'Total de funcionários'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_ATIVOS"	, 'N', 6, 0 } )
	TRCell():New( oSection2, 'TMP_ADMISS'		    	,'T01', 'Admissões'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_ADMISS"	, 'N', 6, 0 } )
	TRCell():New( oSection2, 'TMP_DEMISS'		    	,'T01', 'Demissões'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_DEMISS"	, 'N', 6, 0 } )
	TRCell():New( oSection2, 'TMP_TURNT'		    	,'T01', '% Turnover tradicional'                 ,						""                      ,12)
	AAdd( _CAMPTAB2, { "TMP_TURNT"	, 'N', 10, 4 } )
	TRCell():New( oSection2, 'TMP_TURND'		    	,'T01', '% Turnover demissional'                 ,						""                      ,12)
	AAdd( _CAMPTAB2, { "TMP_TURND"	, 'N', 10, 4 } )
	TRCell():New( oSection2, 'TMP_ADMDET'		    	,'T01', 'Admissões Determinado'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_ADMDET"	, 'N', 6, 0 } )
	TRCell():New( oSection2, 'TMP_DEMDET'		    	,'T01', 'Demissões Determinado'                 ,						""                      ,06)
	AAdd( _CAMPTAB2, { "TMP_DEMDET"	, 'N', 6, 0 } )
	TRCell():New( oSection2, 'TMP_TURGT'		    	,'T01', '% Turnover trad. - Determinados'                 ,						""                      ,12)
	AAdd( _CAMPTAB2, { "TMP_TURGT"	, 'N', 10, 4 } )
	TRCell():New( oSection2, 'TMP_TURGD'		    	,'T01', '% Turnover demi. - Determinado'                 ,						""                      ,12)
	AAdd( _CAMPTAB2, { "TMP_TURGD"	, 'N', 10, 4 } )


	TRCell():New( oSection3, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,02)
	AAdd( _CAMPTAB3, { "TMP_EMPRES"	, 'C', 02, 0 } )
	TRCell():New( oSection3, 'TMP_CODCC'		    	,'T01', 'Cod CC'                 ,						""                      ,30)
	AAdd( _CAMPTAB3, { "TMP_CODCC"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_CC'		    	,'T01', 'Centro custo'                 ,						""                      ,60)
	AAdd( _CAMPTAB3, { "TMP_CC"	, 'C', 60, 0 } )
	TRCell():New( oSection3, 'TMP_PERIOD'		    	,'T01', 'Período'                 ,						""                      ,06)
	AAdd( _CAMPTAB3, { "TMP_PERIOD"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_ATIVOS'		    	,'T01', 'Total de funcionários'                 ,						""                      ,06)
	AAdd( _CAMPTAB3, { "TMP_ATIVOS"	, 'N', 6, 0 } )
	TRCell():New( oSection3, 'TMP_ADMISS'		    	,'T01', 'Admissões'                 ,						""                      ,06)
	AAdd( _CAMPTAB3, { "TMP_ADMISS"	, 'N', 6, 0 } )
	TRCell():New( oSection3, 'TMP_DEMISS'		    	,'T01', 'Demissões'                 ,						""                      ,06)
	AAdd( _CAMPTAB3, { "TMP_DEMISS"	, 'N', 6, 0 } )
	TRCell():New( oSection3, 'TMP_TURNT'		    	,'T01', '% Turnover tradicional'                 ,						""                      ,12)
	AAdd( _CAMPTAB3, { "TMP_TURNT"	, 'N', 10, 4 } )
	TRCell():New( oSection3, 'TMP_TURND'		    	,'T01', '% Turnover demissional'                 ,						""                      ,12)
	AAdd( _CAMPTAB3, { "TMP_TURND"	, 'N', 10, 4 } )
	TRCell():New( oSection3, 'TMP_ADMDET'		    	,'T01', 'Admissões Determinado'                 ,						""                      ,06)
	AAdd( _CAMPTAB3, { "TMP_ADMDET"	, 'N', 6, 0 } )
	TRCell():New( oSection3, 'TMP_DEMDET'		    	,'T01', 'Demissões Determinado'                 ,						""                      ,06)
	AAdd( _CAMPTAB3, { "TMP_DEMDET"	, 'N', 6, 0 } )
	TRCell():New( oSection3, 'TMP_TURGT'		    	,'T01', '% Turnover trad. - Determinados'                 ,						""                      ,12)
	AAdd( _CAMPTAB3, { "TMP_TURGT"	, 'N', 10, 4 } )
	TRCell():New( oSection3, 'TMP_TURGD'		    	,'T01', '% Turnover demi. - Determinado'                 ,						""                      ,12)
	AAdd( _CAMPTAB3, { "TMP_TURGD"	, 'N', 10, 4 } )
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
	//Local oSection4 	:= oReport:Section(4)
	//Local aSection1 		:= { }
	//Local aSection2 		:= { }
//	Local aSection3 		:= { }
//	Local aSection4 		:= { }
	//Local aVLR1 	     	:= { }
//	Local aVLR2 		    := { }
	//Local aVLR3 		    := { }
	//Local aVLR4 	    	:= { }
	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_EMPRES","TMP_PERIOD"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL","TMP_PERIOD"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_CC","TMP_PERIOD"})
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
Static Function Query( aSection1, aSection2, aSection3, aSection4,aVLR1,aVLR2,aVLR3,aVLR4 )


	CQUERY := " SELECT RD_FILIAL, RD_CC, CTT_DESC01, RD_PERIODO, COUNT(DISTINCT RD_FILIAL+RD_MAT) ATIVO, "
	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("SRA")+" RA WHERE RA_FILIAL = RD_FILIAL AND RA_CC = RD_CC AND SUBSTRING(RA_ADMISSA,1,6) = RD_PERIODO AND RA.D_E_L_E_T_ = ' ' )  ADMISSAO, "
	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("SRA")+" RA WHERE RA_FILIAL = RD_FILIAL AND RA_CC = RD_CC AND SUBSTRING(RA_DEMISSA,1,6) = RD_PERIODO AND RA.D_E_L_E_T_ = ' ' AND RA_AFASFGT NOT IN ('N1','N2') )  DEMISSAO, "
	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("SRA")+" RA WHERE RA_TPCONTR = '2' AND RA_FILIAL = RD_FILIAL AND RA_CC = RD_CC AND SUBSTRING(RA_ADMISSA,1,6) = RD_PERIODO AND RA.D_E_L_E_T_ = ' ' )  ADM_DETER, "
	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("SRA")+" RA WHERE RA_TPCONTR = '2' AND RA_FILIAL = RD_FILIAL AND RA_CC = RD_CC AND SUBSTRING(RA_DEMISSA,1,6) = RD_PERIODO AND RA.D_E_L_E_T_ = ' ' AND RA_AFASFGT NOT IN ('N1','N2') )  DEM_DETER "
	CQUERY += " FROM "+RETSQLNAME("SRD")+"  RD "
	CQUERY += " INNER JOIN "+RETSQLNAME("SRA")+"  RA ON RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT AND (RA_DEMISSA = ' ' OR RA_DEMISSA >= RD_PERIODO) AND RD.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN CTT010 CTT ON CTT_FILIAL = SUBSTRING(RD_FILIAL,1,2) AND CTT_CUSTO = RD_CC AND CTT.D_E_L_E_T_ = ' ' "
	CQUERY += " WHERE SUBSTRING(RD_PERIODO,1,4) = '"+MV_PAR01+"' AND RD.D_E_L_E_T_ = ' ' GROUP BY RD_FILIAL, RD_CC,CTT_DESC01, RD_PERIODO ORDER BY RD_FILIAL, RD_PERIODO,  RD_CC "
//ra_tpcontr = '2'
	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())


		DBSELECTAREA((CALIAS1))
		DBSETORDER(1)
		IF DBSEEK("**"+T01->RD_PERIODO)
			(CALIAS1)->(Reclock( (CALIAS1), .F.))


			(CALIAS1)->TMP_ADMISS  += T01->ADMISSAO
			(CALIAS1)->TMP_DEMISS  += T01->DEMISSAO
			(CALIAS1)->TMP_ADMDET  += T01->ADM_DETER
			(CALIAS1)->TMP_DEMDET  += T01->DEM_DETER
			(CALIAS1)->TMP_ATIVOS  += T01->ATIVO
			(CALIAS1)->TMP_TURNT   := round((((CALIAS1)->TMP_ADMISS+(CALIAS1)->TMP_DEMISS)/2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURND   := round(((CALIAS1)->TMP_DEMISS/(CALIAS1)->TMP_ATIVOS),4)*100
			(CALIAS1)->TMP_TURGT   := round( ( ( ((CALIAS1)->TMP_ADMISS - (CALIAS1)->TMP_ADMDET) + ( (CALIAS1)->TMP_DEMISS -(CALIAS1)->TMP_DEMDET) ) /2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURGD   := round(( ((CALIAS1)->TMP_DEMISS - (CALIAS1)->TMP_DEMDET)/(CALIAS1)->TMP_ATIVOS),4)*100

		ELSE
			(CALIAS1)->(Reclock( (CALIAS1), .T.))

			(CALIAS1)->TMP_EMPRES  := "**"
			(CALIAS1)->TMP_PERIOD  := T01->RD_PERIODO
			(CALIAS1)->TMP_ADMISS  := T01->ADMISSAO
			(CALIAS1)->TMP_DEMISS  := T01->DEMISSAO
			(CALIAS1)->TMP_ADMDET  := T01->ADM_DETER
			(CALIAS1)->TMP_DEMDET  := T01->DEM_DETER
			(CALIAS1)->TMP_ATIVOS  := T01->ATIVO
			(CALIAS1)->TMP_TURNT   := round((((CALIAS1)->TMP_ADMISS+(CALIAS1)->TMP_DEMISS)/2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURND   := round(((CALIAS1)->TMP_DEMISS/(CALIAS1)->TMP_ATIVOS),4)*100
			(CALIAS1)->TMP_TURGT   := round( ( ( ((CALIAS1)->TMP_ADMISS - (CALIAS1)->TMP_ADMDET) + ( (CALIAS1)->TMP_DEMISS -(CALIAS1)->TMP_DEMDET) ) /2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURGD   := round(( ((CALIAS1)->TMP_DEMISS - (CALIAS1)->TMP_DEMDET)/(CALIAS1)->TMP_ATIVOS),4)*100

			//	&((CALIAS2)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR
			//	(CALIAS2)->TMP_VTOTRE := T01->RD_VALOR

		ENDIF

		DBSELECTAREA((CALIAS1))
		DBSETORDER(1)
		IF DBSEEK(SUBSTRING(T01->RD_FILIAL,1,2)+T01->RD_PERIODO)
			(CALIAS1)->(Reclock( (CALIAS1), .F.))


			(CALIAS1)->TMP_ADMISS  += T01->ADMISSAO
			(CALIAS1)->TMP_DEMISS  += T01->DEMISSAO
			(CALIAS1)->TMP_ADMDET  += T01->ADM_DETER
			(CALIAS1)->TMP_DEMDET  += T01->DEM_DETER
			(CALIAS1)->TMP_ATIVOS  += T01->ATIVO
			(CALIAS1)->TMP_TURNT   := round((((CALIAS1)->TMP_ADMISS+(CALIAS1)->TMP_DEMISS)/2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURND   := round(((CALIAS1)->TMP_DEMISS/(CALIAS1)->TMP_ATIVOS),4)*100
			(CALIAS1)->TMP_TURGT   := round( ( ( ((CALIAS1)->TMP_ADMISS - (CALIAS1)->TMP_ADMDET) + ( (CALIAS1)->TMP_DEMISS -(CALIAS1)->TMP_DEMDET) ) /2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURGD   := round(( ((CALIAS1)->TMP_DEMISS - (CALIAS1)->TMP_DEMDET)/(CALIAS1)->TMP_ATIVOS),4)*100

		ELSE
			(CALIAS1)->(Reclock( (CALIAS1), .T.))

			(CALIAS1)->TMP_EMPRES  := SUBSTRING(T01->RD_FILIAL,1,2)
			(CALIAS1)->TMP_PERIOD  := T01->RD_PERIODO
			(CALIAS1)->TMP_ADMISS  := T01->ADMISSAO
			(CALIAS1)->TMP_DEMISS  := T01->DEMISSAO
			(CALIAS1)->TMP_ADMDET  := T01->ADM_DETER
			(CALIAS1)->TMP_DEMDET  := T01->DEM_DETER
			(CALIAS1)->TMP_ATIVOS  := T01->ATIVO
			(CALIAS1)->TMP_TURNT   := round((((CALIAS1)->TMP_ADMISS+(CALIAS1)->TMP_DEMISS)/2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURND   := round(((CALIAS1)->TMP_DEMISS/(CALIAS1)->TMP_ATIVOS),4)*100
			(CALIAS1)->TMP_TURGT   := round( ( ( ((CALIAS1)->TMP_ADMISS - (CALIAS1)->TMP_ADMDET) + ( (CALIAS1)->TMP_DEMISS -(CALIAS1)->TMP_DEMDET) ) /2)/(CALIAS1)->TMP_ATIVOS,4)*100
			(CALIAS1)->TMP_TURGD   := round(( ((CALIAS1)->TMP_DEMISS - (CALIAS1)->TMP_DEMDET)/(CALIAS1)->TMP_ATIVOS),4)*100

			//	&((CALIAS2)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR
			//	(CALIAS2)->TMP_VTOTRE := T01->RD_VALOR

		ENDIF

		DBSELECTAREA((CALIAS2))
		DBSETORDER(1)
		IF DBSEEK(T01->RD_FILIAL+T01->RD_PERIODO)
			(CALIAS2)->(Reclock( (CALIAS2), .F.))


			(CALIAS2)->TMP_ADMISS  += T01->ADMISSAO
			(CALIAS2)->TMP_DEMISS  += T01->DEMISSAO
			(CALIAS2)->TMP_ADMDET  += T01->ADM_DETER
			(CALIAS2)->TMP_DEMDET  += T01->DEM_DETER
			(CALIAS2)->TMP_ATIVOS  += T01->ATIVO
			(CALIAS2)->TMP_TURNT   := round((((CALIAS2)->TMP_ADMISS+(CALIAS2)->TMP_DEMISS)/2)/(CALIAS2)->TMP_ATIVOS,4)*100
			(CALIAS2)->TMP_TURND   := round(((CALIAS2)->TMP_DEMISS/(CALIAS2)->TMP_ATIVOS),4)*100
			(CALIAS2)->TMP_TURGT   := round( ( ( ((CALIAS2)->TMP_ADMISS - (CALIAS2)->TMP_ADMDET) + ( (CALIAS2)->TMP_DEMISS -(CALIAS2)->TMP_DEMDET) ) /2)/(CALIAS2)->TMP_ATIVOS,4)*100
			(CALIAS2)->TMP_TURGD   := round(( ((CALIAS2)->TMP_DEMISS - (CALIAS2)->TMP_DEMDET)/(CALIAS2)->TMP_ATIVOS),4)*100

		ELSE
			(CALIAS2)->(Reclock( (CALIAS2), .T.))

			(CALIAS2)->TMP_EMPRES  := SUBSTRING(T01->RD_FILIAL,1,2)
			(CALIAS2)->TMP_FILIAL  := T01->RD_FILIAL
			(CALIAS2)->TMP_PERIOD  := T01->RD_PERIODO
			(CALIAS2)->TMP_ADMISS  := T01->ADMISSAO
			(CALIAS2)->TMP_DEMISS  := T01->DEMISSAO
			(CALIAS2)->TMP_ADMDET  := T01->ADM_DETER
			(CALIAS2)->TMP_DEMDET  := T01->DEM_DETER
			(CALIAS2)->TMP_ATIVOS  := T01->ATIVO
			(CALIAS2)->TMP_TURNT   := round((((CALIAS2)->TMP_ADMISS+(CALIAS2)->TMP_DEMISS)/2)/(CALIAS2)->TMP_ATIVOS,4)*100
			(CALIAS2)->TMP_TURND   := round(((CALIAS2)->TMP_DEMISS/(CALIAS2)->TMP_ATIVOS),4)*100
			(CALIAS2)->TMP_TURGT   := round( ( ( ((CALIAS2)->TMP_ADMISS - (CALIAS2)->TMP_ADMDET) + ( (CALIAS2)->TMP_DEMISS -(CALIAS2)->TMP_DEMDET) ) /2)/(CALIAS2)->TMP_ATIVOS,4)*100
			(CALIAS2)->TMP_TURGD   := round(( ((CALIAS2)->TMP_DEMISS - (CALIAS2)->TMP_DEMDET)/(CALIAS2)->TMP_ATIVOS),4)*100

			//	&((CALIAS2)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR
			//	(CALIAS2)->TMP_VTOTRE := T01->RD_VALOR

		ENDIF

		DBSELECTAREA((CALIAS3))
		DBSETORDER(1)
		IF DBSEEK(T01->RD_CC+T01->RD_PERIODO)
			(CALIAS3)->(Reclock( (CALIAS3), .F.))


			(CALIAS3)->TMP_ADMISS  += T01->ADMISSAO
			(CALIAS3)->TMP_DEMISS  += T01->DEMISSAO
			(CALIAS3)->TMP_ADMDET  += T01->ADM_DETER
			(CALIAS3)->TMP_DEMDET  += T01->DEM_DETER
			(CALIAS3)->TMP_ATIVOS  += T01->ATIVO
			(CALIAS3)->TMP_TURNT   := round((((CALIAS3)->TMP_ADMISS+(CALIAS3)->TMP_DEMISS)/2)/(CALIAS3)->TMP_ATIVOS,4)*100
			(CALIAS3)->TMP_TURND   := round(((CALIAS3)->TMP_DEMISS/(CALIAS3)->TMP_ATIVOS),4)*100
			(CALIAS3)->TMP_TURGT   := round( ( ( ((CALIAS3)->TMP_ADMISS - (CALIAS3)->TMP_ADMDET) + ( (CALIAS3)->TMP_DEMISS -(CALIAS3)->TMP_DEMDET) ) /2)/(CALIAS3)->TMP_ATIVOS,4)*100
			(CALIAS3)->TMP_TURGD   := round(( ((CALIAS3)->TMP_DEMISS - (CALIAS3)->TMP_DEMDET)/(CALIAS3)->TMP_ATIVOS),4)*100


		ELSE
			(CALIAS3)->(Reclock( (CALIAS3), .T.))

			(CALIAS3)->TMP_EMPRES  := SUBSTRING(T01->RD_FILIAL,1,2)
			(CALIAS3)->TMP_CODCC   := T01->RD_CC
			(CALIAS3)->TMP_CC      := T01->CTT_DESC01
			(CALIAS3)->TMP_PERIOD  := T01->RD_PERIODO
			(CALIAS3)->TMP_ADMISS  := T01->ADMISSAO
			(CALIAS3)->TMP_DEMISS  := T01->DEMISSAO
			(CALIAS3)->TMP_ADMDET  := T01->ADM_DETER
			(CALIAS3)->TMP_DEMDET  := T01->DEM_DETER
			(CALIAS3)->TMP_ATIVOS  := T01->ATIVO 
			(CALIAS3)->TMP_TURNT   := round((((CALIAS3)->TMP_ADMISS+(CALIAS3)->TMP_DEMISS)/2)/(CALIAS3)->TMP_ATIVOS,4)*100
			(CALIAS3)->TMP_TURND   := round(((CALIAS3)->TMP_DEMISS/(CALIAS3)->TMP_ATIVOS),4)*100
			(CALIAS3)->TMP_TURGT   := round( ( ( ((CALIAS3)->TMP_ADMISS - (CALIAS3)->TMP_ADMDET) + ( (CALIAS3)->TMP_DEMISS -(CALIAS3)->TMP_DEMDET) ) /2)/(CALIAS3)->TMP_ATIVOS,4)*100
			(CALIAS3)->TMP_TURGD   := round(( ((CALIAS3)->TMP_DEMISS - (CALIAS3)->TMP_DEMDET)/(CALIAS3)->TMP_ATIVOS),4)*100

			//	&((CALIAS2)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR
			//	(CALIAS2)->TMP_VTOTRE := T01->RD_VALOR

		ENDIF
		(CALIAS1)->(MsUnlock())
		(CALIAS2)->(MsUnlock())
		(CALIAS3)->(MsUnlock())
		T01->( dbSkip() )
	ENDDO








	T01->( dbCloseArea() )



Return
