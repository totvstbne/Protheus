#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR01()

	Private oReport
	Private cPergCont	:= "RGPRHR01"
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

	oReport := TReport():New( 'Relatorio de Férias', 'Relatorio de Férias', cPergCont, {|oReport| ReportPrint( oReport ), 'Relatorio de Férias' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Funcionários', { 'SRA'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCCC"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_FUNC'	    	        ,'T01', 'Função'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FUNC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_DESCFU'	    	    ,'T01', 'Desc. Função'            ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCFU"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_SITFOL'	    	    ,'T01', 'Sit. Folha'        ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_SITFOL"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_ADMISS'		        ,'T01', 'Data Admiss.'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_ADMISS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_PERAQU'	    	    ,'T01', 'Período Aquisitivo'        ,			    		""						,25)
	AAdd( _CAMPTAB1, { "TMP_PERAQU"	, 'C', 25, 0 } )

	TRCell():New( oSection1, 'TMP_QTDLIM'		    	,'T01', 'Qtd. Limite'             ,						""                      ,03)
	AAdd( _CAMPTAB1, { "TMP_QTDLIM"	, 'N', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DTLIM'		        ,'T01', 'Data Limite'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTLIM"	, 'D', 08, 0 } )

	TRCell():New( oSection1, 'TMP_SALARI'	    	    ,'T01', 'Salario base'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_SALARI"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_STATUS'	    	    ,'T01', 'Status'        ,			    		""						,25)
	AAdd( _CAMPTAB1, { "TMP_STATUS"	, 'C', 25, 0 } )
	TRCell():New( oSection1, 'TMP_BASE'	    	    ,'T01', 'Valor Projetado'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_BASE"	, 'N', 14, 2 } )

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
//	Local oSection2 	:= oReport:Section(2)
//	Local oSection3 	:= oReport:Section(3)

	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
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





	cQuery := " SELECT RA_SITFOLH,RA_ADMISSA,RA_SINDICA , RA_MAT , RA_FILIAL , RA_NOME , RA_CC ,RA_SALARIO ,RA_CODFUNC, RF_PD , RF_MAT , RF_FILIAL , RF_STATUS , RF_DATABAS , RF_DATAFIM , RF_DIASDIR, RCE_YMESLF, CTT_DESC01, RJ_DESC

	cQuery += " FROM "+RETSQLNAME("SRA")+"  SRA
	cQuery += " INNER JOIN "+RETSQLNAME("SRF")+" SRF ON RF_FILIAL = RA_FILIAL AND RF_MAT = RA_MAT AND RF_STATUS = '1' AND SRF.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RETSQLNAME("SRJ")+" SRJ ON RJ_FILIAL  = SUBSTRING(RA_FILIAL,1,2) AND RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RETSQLNAME("RCE")+" RCE ON RCE_FILIAL = '"+XFILIAL("RCE")+"' AND RCE_CODIGO = RA_SINDICA AND RCE.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ''
	cQuery += " WHERE
	cQuery += " SRA.RA_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+MV_PAR02+"'
	cQuery += " AND SRA.RA_MAT BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"'
	cQuery += " AND SRA.RA_SINDICA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery += " AND SRA.RA_CC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
	cQuery += " AND SRA.RA_SITFOLH NOT IN ('D')
	cQuery += " AND SRA.D_E_L_E_T_=''

	cQuery += " ORDER BY RA_CC , RA_NOME


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		IF (MV_PAR09 = 1  .AND. STOD(T01->RF_DATAFIM) >= DDATABASE ) .OR. (MV_PAR09 = 2  .AND. STOD(T01->RF_DATAFIM) < DDATABASE ) .OR. MV_PAR09 = 3

			(CALIAS1)->(Reclock( CALIAS1, .T.))

			_chave := T01->RA_FILIAL+T01->RA_MAT
			(CALIAS1)->TMP_FILIAL   :=T01->RA_FILIAL
			(CALIAS1)->TMP_MATRIC := T01->RA_MAT
			(CALIAS1)->TMP_NOME := T01->RA_NOME
			(CALIAS1)->TMP_SITFOL := T01->RA_SITFOLH
			(CALIAS1)->TMP_CC := T01->RA_CC
			(CALIAS1)->TMP_DESCCC := T01->CTT_DESC01
			(CALIAS1)->TMP_FUNC := T01->RA_CODFUNC
			(CALIAS1)->TMP_DESCFU := T01->RJ_DESC
			(CALIAS1)->TMP_ADMISS := STOD(T01->RA_ADMISSA)
			(CALIAS1)->TMP_SALARI := T01->RA_SALARIO
			(CALIAS1)->TMP_PERAQU := DTOC(STOD(T01->RF_DATABAS))+"-"+DTOC(STOD(T01->RF_DATAFIM))
			(CALIAS1)->TMP_QTDLIM := T01->RCE_YMESLF
			(CALIAS1)->TMP_DTLIM  := (MonthSum(STOD(T01->RF_DATAFIM)+1,T01->RCE_YMESLF))
			if (MonthSum(STOD(T01->RF_DATAFIM)+1,T01->RCE_YMESLF))-1 < ddatabase
				(CALIAS1)->TMP_STATUS := "Vencida"
			else
				(CALIAS1)->TMP_STATUS := "No prazo"
			endif
			cQuery := " SELECT  TOP 1 (RD_VALOR +  (RD_VALOR / 3)) RD_VALOR
			cQuery += " FROM "+RETSQLNAME("SRD")+" SRD
			cQuery += " WHERE D_E_L_E_T_ = ''
			cQuery += " AND RD_FILIAL ='"+ T01->RA_FILIAL +"'
			cQuery += " AND RD_MAT ='"+ T01->RA_MAT +"'
			cQuery += " AND RD_PD = '917'
			cQuery += " AND RD_ROTEIR = 'FOL'
			cQuery += " ORDER BY RD_PERIODO DESC

			IF SELECT("TVAL") > 0
				TVAL->(DBCLOSEAREA())
			ENDIF

			TcQuery cQuery New Alias TVAL

			(CALIAS1)->TMP_BASE := TVAL->RD_VALOR
/*

		DBSELECTAREA((CALIAS2))
		DBSETORDER(1)
			IF DBSEEK(IIF(MV_PAR02==1,T01->RC_FILIAL,T01->RD_FILIAL))
			(CALIAS2)->(Reclock( (CALIAS2), .F.))

			(CALIAS2)->TMP_QTDFUN   += 1
			(CALIAS2)->TMP_QTDEST	+= _NESTG
			(CALIAS2)->TMP_QTDMAP   += _NMAPR
			(CALIAS2)->TMP_QTDDEF	+= _NDEF
			(CALIAS2)->TMP_QTDTEM	+= _NTEMP
			(CALIAS2)->TMP_QTDAFA  += _NAFAS
			(CALIAS2)->TMP_FERIAS  += _NFERIAS
			(CALIAS2)->TMP_SALARI  += T01->RA_SALARIO

			ELSE
			(CALIAS2)->(Reclock( (CALIAS2), .T.))

			(CALIAS2)->TMP_EMPRES := CEMPANT
			(CALIAS2)->TMP_FILIAL := IIF(MV_PAR02==1,T01->RC_FILIAL,T01->RD_FILIAL)
			(CALIAS2)->TMP_QTDFUN   := 1
			(CALIAS2)->TMP_QTDEST	:= _NESTG
			(CALIAS2)->TMP_QTDMAP   := _NMAPR
			(CALIAS2)->TMP_QTDDEF	:= _NDEF
			(CALIAS2)->TMP_QTDTEM	:= _NTEMP
			(CALIAS2)->TMP_QTDAFA := _NAFAS
			(CALIAS2)->TMP_FERIAS  := _NFERIAS
			(CALIAS2)->TMP_SALARI := T01->RA_SALARIO
			//	&((CALIAS2)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR
			//	(CALIAS2)->TMP_VTOTRE := T01->RD_VALOR

			ENDIF

		DBSELECTAREA((CALIAS3))
		DBSETORDER(1)
			IF DBSEEK(IIF(MV_PAR02==1,T01->RC_CC,T01->RD_CC)+T01->CTT_DESC01)
			(CALIAS3)->(Reclock((CALIAS3), .F.))

			(CALIAS3)->TMP_QTDFUN   += 1
			(CALIAS3)->TMP_QTDEST	+= _NESTG
			(CALIAS3)->TMP_QTDMAP   += _NMAPR
			(CALIAS3)->TMP_QTDDEF	+= _NDEF
			(CALIAS3)->TMP_QTDTEM	+= _NTEMP
			(CALIAS3)->TMP_QTDAFA += _NAFAS
			(CALIAS3)->TMP_FERIAS  += _NFERIAS
			(CALIAS3)->TMP_SALARI += T01->RA_SALARIO
			ELSE
			(CALIAS3)->(Reclock( (CALIAS3), .T.))

			(CALIAS3)->TMP_EMPRES := CEMPANT
			(CALIAS3)->TMP_CC := IIF(MV_PAR02==1,T01->RC_CC,T01->RD_CC)+T01->CTT_DESC01
			(CALIAS3)->TMP_QTDFUN   := 1
			(CALIAS3)->TMP_QTDEST	:= _NESTG
			(CALIAS3)->TMP_QTDMAP   := _NMAPR
			(CALIAS3)->TMP_QTDDEF	:= _NDEF
			(CALIAS3)->TMP_QTDTEM	:= _NTEMP
			(CALIAS3)->TMP_QTDAFA := _NAFAS
			(CALIAS3)->TMP_FERIAS  := _NFERIAS
			(CALIAS3)->TMP_SALARI := T01->RA_SALARIO
			//&((CALIAS3)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR
			//	(CALIAS3)->TMP_VTOTRE := T01->RD_VALOR

			ENDIF

*/

			(CALIAS1)->(MsUnlock())
		ENDIF
		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )



Return
