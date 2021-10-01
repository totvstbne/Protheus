#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR08()

	Private oReport
	Private cPergCont	:= PadR('RGPRHR08' ,10)
	PRIVATE _averbper := {}
	PRIVATE	_CAMPTAB1 := {}
	PRIVATE cAlias1			:= GetNextAlias()
	PRIVATE oTempTab1
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
	//Local oSection4
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'Auditoria Benefícios', 'Auditoria Benefícios', cPergCont, {|oReport| ReportPrint( oReport ), 'Auditoria Benefícios' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Benefícios', { 'SRA'})
	//oSection2 := TRSection():New( oReport, 'Filial', { 'SRA'})
	//oSection3 := TRSection():New( oReport, 'Centro de Custo', { 'SRA'})
	//oSection4 := TRSection():New( oReport, 'Empresa', { 'SRA'})

	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_SITUAC'		        	,'T01', 'Situação Folha'                     ,				   		""						,01)
	AAdd( _CAMPTAB1, { "TMP_SITUAC"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DESCCC"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_TURNO'	    	    ,'T01', 'Turno'                   ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_TURNO"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DESCTU'	    	    ,'T01', 'Desc. Turno'             ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCTU"	, 'C', 20, 0 } )

	//TRCell():New( oSection1, 'TMP_FUNC'	    	        ,'T01', 'Função'                  ,			    		""						,06)
	//AAdd( _CAMPTAB1, { "TMP_FUNC"	, 'C', 06, 0 } )
	//TRCell():New( oSection1, 'TMP_DESCFU'	    	    ,'T01', 'Desc. Função'            ,			    		""						,20)
	//AAdd( _CAMPTAB1, { "TMP_DESCFU"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_ADMISS'		        ,'T01', 'Data Admiss.'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_ADMISS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DEMISS'		        ,'T01', 'Data Demissão'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DEMISS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_QDVAL'	    	    ,'T01', 'Qtd. Dias Vale Alimentação'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QDVAL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QVALD'	    	    ,'T01', 'Qtd. Vale Alimentação Dia'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QVALD"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QTVAL'	    	    ,'T01', 'Qtd. Total Vale Alimentação'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QTVAL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VUVAL'	    	    ,'T01', 'Vlr. Unit. Vale Alimentação'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VUVAL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VTVAL'	    	    ,'T01', 'Vlr. Total Vale Alimentação'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VTVAL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VEVAL'	    	    ,'T01', 'Vlr. Emp. Vale Alimentação'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VEVAL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VFVAL'	    	    ,'T01', 'Vlr. Func. Vale Alimentação'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VFVAL"	, 'N', 14, 2 } )

	TRCell():New( oSection1, 'TMP_QDVTR'	    	    ,'T01', 'Qtd. Dias Vale Transporte'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QDVTR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QVTRD'	    	    ,'T01', 'Qtd. Vale Transporte Dia'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QVTRD"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QTVTR'	    	    ,'T01', 'Qtd. Total Vale Transporte'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QTVTR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VUVTR'	    	    ,'T01', 'Vlr. Unit. Vale Transporte'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VUVTR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VTVTR'	    	    ,'T01', 'Vlr. Total Vale Transporte'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VTVTR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VEVTR'	    	    ,'T01', 'Vlr. Emp. Vale Transporte'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VEVTR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VFVTR'	    	    ,'T01', 'Vlr. Func. Vale Transporte'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VFVTR"	, 'N', 14, 2 } )

	TRCell():New( oSection1, 'TMP_QDCB'	    	    ,'T01', 'Qtd. Dias Cesta Básica'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_QDCB"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VTCB'	    	    ,'T01', 'Vlr. Total Cesta Básica'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VTCB"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VECB'	    	    ,'T01', 'Vlr. Emp. Cesta Básica'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VECB"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VFCB'	    	    ,'T01', 'Vlr. Func. Cesta Básica'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VFCB"	, 'N', 14, 2 } )
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
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())



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


	oTempTab1:DELETE()

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





	cquery := " SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_CC, CTT_DESC01, RA_ADMISSA, RA_DEMISSA, RA_TNOTRAB,R6_DESC, "
	cquery += " ISNULL(SUM(R02.R0_DPROPIN),0) DIASVAL, ISNULL(SUM(R02.R0_QDIAINF),0) QTDDIAVAL , ISNULL(SUM(R02.R0_QDIACAL),0) QTDTOTVAL, ISNULL(SUM(R02.R0_VLRVALE),0) VLRUNITVAL, ISNULL(SUM(R02.R0_VALCAL),0) VLRTOTVAL, ISNULL(SUM(R02.R0_VLREMP),0) VLREMPVAL,  ISNULL(SUM(R02.R0_VLRFUNC),0) VLRFUNCVAL, "
	cquery += " ISNULL(SUM(R00.R0_DPROPIN),0) DIASVTR, ISNULL(SUM(R00.R0_QDIAINF),0) QTDDIAVTR , ISNULL(SUM(R00.R0_QDIACAL),0) QTDTOTVTR, ISNULL(SUM(R00.R0_VLRVALE),0) VLRUNITVTR, ISNULL(SUM(R00.R0_VALCAL),0) VLRTOTVTR, ISNULL(SUM(R00.R0_VLREMP),0) VLREMPVTR,  ISNULL(SUM(R00.R0_VLRFUNC),0) VLRFUNCVTR, "
	cquery += " ISNULL(SUM(RIQ_VALBEN),0) VALORCB, ISNULL(SUM(RIQ_VLRFUN),0) VALORFUNCB,ISNULL(SUM(RIQ_VLREMP),0) VALOREMPCB, ISNULL(SUM(RIQ_DIAPRO),0) DIASCB "
	cquery += " FROM "+RETSQLNAME("SRA")+" RA "
	cquery += " INNER JOIN "+RETSQLNAME("SR6")+" R6 ON R6_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND R6_TURNO = RA_TNOTRAB AND R6.D_E_L_E_T_ = ' ' "
	cquery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' "
	cquery += " LEFT JOIN "+RETSQLNAME("SR0")+" R02 ON R02.R0_TPVALE = '2' AND R02.R0_FILIAL = RA_FILIAL AND R02.R0_MAT = RA_MAT AND R02.R0_PERIOD = '"+MV_PAR03+"' AND R02.D_E_L_E_T_ = ' ' "
	cquery += " LEFT JOIN "+RETSQLNAME("SR0")+" R00 ON R00.R0_TPVALE = '0' AND R00.R0_FILIAL = RA_FILIAL AND R00.R0_MAT = RA_MAT AND R00.R0_PERIOD = '"+MV_PAR03+"' AND R00.D_E_L_E_T_ = ' ' "
	cquery += " LEFT JOIN "+RETSQLNAME("RIQ")+" RIQ ON RIQ_FILIAL = RA_FILIAL AND RIQ_MAT = RA_MAT AND RIQ_PERIOD = '"+MV_PAR03+"' AND RIQ_TPBENE = '81' AND RIQ.D_E_L_E_T_ = ' ' "
	cquery += " WHERE RA_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SUBSTRING(RA_ADMISSA,1,6) <= '"+MV_PAR03+"' AND RA.D_E_L_E_T_ = ' ' AND (RA_DEMISSA = ' ' OR SUBSTRING(RA_DEMISSA,1,6) >= '"+MV_PAR03+"' ) "
	cquery += " GROUP BY RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_CC, CTT_DESC01, RA_ADMISSA, RA_DEMISSA,RA_TNOTRAB, R6_DESC "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())





		_ALINHA := {}

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->RA_FILIAL+T01->RA_MAT

		(CALIAS1)->TMP_FILIAL   :=T01->RA_FILIAL
		(CALIAS1)->TMP_MATRIC := T01->RA_MAT
		(CALIAS1)->TMP_NOME := T01->RA_NOME
		(CALIAS1)->TMP_CC := T01->RA_CC
		(CALIAS1)->TMP_DESCCC := T01->CTT_DESC01
		(CALIAS1)->TMP_ADMISS := STOD(T01->RA_ADMISSA)
		(CALIAS1)->TMP_DEMISS := STOD(T01->RA_DEMISSA)
		(CALIAS1)->TMP_TURNO := T01->RA_TNOTRAB
		(CALIAS1)->TMP_DESCTU := T01->R6_DESC
		(CALIAS1)->TMP_SITUAC := T01->RA_SITFOLH
		(CALIAS1)->TMP_QDVAL := T01->DIASVAL
		(CALIAS1)->TMP_QVALD := T01->QTDDIAVAL
		(CALIAS1)->TMP_QTVAL := T01->QTDTOTVAL
		(CALIAS1)->TMP_VUVAL := T01->VLRUNITVAL
		(CALIAS1)->TMP_VTVAL := T01->VLRTOTVAL
		(CALIAS1)->TMP_VEVAL := T01->VLREMPVAL
		(CALIAS1)->TMP_VFVAL := T01->VLRFUNCVAL
		(CALIAS1)->TMP_QDVTR := T01->DIASVTR
		(CALIAS1)->TMP_QVTRD := T01->QTDDIAVTR
		(CALIAS1)->TMP_QTVTR := T01->QTDTOTVTR
		(CALIAS1)->TMP_VUVTR := T01->VLRUNITVTR
		(CALIAS1)->TMP_VTVTR := T01->VLRTOTVTR
		(CALIAS1)->TMP_VEVTR := T01->VLREMPVTR
		(CALIAS1)->TMP_VFVTR := T01->VLRFUNCVTR
		(CALIAS1)->TMP_QDCB := T01->DIASCB
		(CALIAS1)->TMP_VTCB := T01->VALORCB
		(CALIAS1)->TMP_VECB := T01->VALOREMPCB
		(CALIAS1)->TMP_VFCB := T01->VALORFUNCB

		T01->( dbSkip() )
	ENDDO



	(CALIAS1)->(MsUnlock())




	T01->( dbCloseArea() )



Return
