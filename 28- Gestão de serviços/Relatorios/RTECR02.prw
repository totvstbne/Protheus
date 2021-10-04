#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RTECR02()

	Private oReport
	Private cPergCont	:= "RTECR02"
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

	oReport := TReport():New( 'Contratos ativos', 'Contratos ativos', cPergCont, {|oReport| ReportPrint( oReport ), 'Contratos ativos' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Contratos ativos', { 'CN9'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_CLIEN'	    	        ,'T01', 'Cliente'         ,			    		""						,60)
	AAdd( _CAMPTAB1, { "TMP_CLIEN"	, 'C', 60, 0 } )
	TRCell():New( oSection1, 'TMP_EST'	    	    ,'T01', 'Estado'                 ,			    		""						,02)
	AAdd( _CAMPTAB1, { "TMP_EST"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_MUNIC'		        ,'T01', 'Municipio'               ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_MUNIC"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_END'	    	        ,'T01', 'Endereço'                  ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_END"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_SETOR'	    	    ,'T01', 'Setor'            ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_SETOR"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_NUM'		            ,'T01', 'Nun. Contrato'               ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_NUM"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_DTINI'		        ,'T01', 'Data Inicial'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTINI"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTFIM'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTFIM"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_VIGEN'	    	    ,'T01', 'Vigência em aberto'        ,			    		""						,04)
	AAdd( _CAMPTAB1, { "TMP_VIGEN"	, 'N', 4, 0 } )
	TRCell():New( oSection1, 'TMP_SALDO'	    	    ,'T01', 'Saldo Contrato'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_SALDO"	, 'N', 14, 2 } )

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
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_SETOR","TMP_NUM"})
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


	CQUERY := " SELECT CN9_FILIAL, TFJ_CODENT, TFJ_LOJA, A1_NOME, A1_EST, A1_MUN,A1_END, AD1_SETOR,  CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, "

	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("TFL")+" TFL WHERE TFL_FILIAL = CN9_FILIAL AND TFL_CONTRT = CN9_NUMERO AND TFL_CODPAI = TFJ_CODIGO AND TFL_CONREV = CN9_REVISA AND TFL.D_E_L_E_T_ = ' ' AND TFL_ENCE <> '1') AS QTD_LOCAL, "
	CQUERY += " ((SELECT COUNT(*) FROM "+RETSQLNAME("CNF")+" CNF,"+RETSQLNAME("TFL")+" TFL WHERE TFL_FILIAL = CN9_FILIAL AND TFL_CONTRT = CN9_NUMERO AND TFL_CODPAI = TFJ_CODIGO AND TFL_CONREV = CN9_REVISA AND TFL.D_E_L_E_T_ = ' ' AND TFL_ENCE <> '1' AND TFL_PLAN = CNF_NUMPLA AND CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_VLREAL = 0 AND CNF_DTVENC >= '"+MV_PAR02+"01' )/(SELECT COUNT(*) FROM "+RETSQLNAME("TFL")+" TFL WHERE TFL_FILIAL = CN9_FILIAL AND TFL_CONTRT = CN9_NUMERO AND TFL_CODPAI = TFJ_CODIGO AND TFL_CONREV = CN9_REVISA AND TFL.D_E_L_E_T_ = ' ' AND TFL_ENCE <> '1')) AS QTD_MES_VIGENCIA , "
	CQUERY += " (SELECT SUM(CNF_VLPREV) FROM "+RETSQLNAME("CNF")+" CNF,"+RETSQLNAME("TFL")+" TFL WHERE TFL_FILIAL = CN9_FILIAL AND TFL_CONTRT = CN9_NUMERO AND TFL_CODPAI = TFJ_CODIGO AND TFL_CONREV = CN9_REVISA AND TFL.D_E_L_E_T_ = ' ' AND TFL_ENCE <> '1' AND TFL_PLAN = CNF_NUMPLA AND CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_VLREAL = 0 AND CNF_DTVENC >= '"+MV_PAR02+"01' ) AS SALDO_TOTAL "

	CQUERY += " FROM "+RETSQLNAME("CN9")+" CN9 "
	CQUERY += " INNER JOIN "+RETSQLNAME("TFJ")+" TFJ ON TFJ_FILIAL = CN9_FILIAL AND TFJ_STATUS IN ('1','3') AND TFJ_CONTRT = CN9_NUMERO AND TFJ_CONREV = CN9_REVISA AND TFJ.D_E_L_E_T_ = ' ' "

	CQUERY += " INNER JOIN "+RETSQLNAME("ADY")+" ADY ON ADY_FILIAL = TFJ_FILIAL AND ADY_PROPOS = TFJ_PROPOS AND ADY_PREVIS = TFJ_PREVIS AND ADY.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("AD1")+" AD1 ON AD1_FILIAL = ADY_FILIAL AND AD1_PROPOS = ADY_PROPOS AND AD1.D_E_L_E_T_ = ' ' "

	CQUERY += " INNER JOIN "+RETSQLNAME("SA1")+" A1 ON A1_FILIAL = ' ' AND A1_COD = TFJ_CODENT AND A1_LOJA = TFJ_LOJA AND A1.D_E_L_E_T_ = ' ' "

	CQUERY += " WHERE "
	CQUERY += " SUBSTRING(CN9_DTINIC,1,6) <= '"+MV_PAR02+"' AND SUBSTRING(CN9_DTFIM,1,6) >='"+MV_PAR02+"' AND CN9_REVATU = ' '  AND CN9.D_E_L_E_T_ = ' ' AND CN9_FILIAL = '"+MV_PAR01+"' "
	CQUERY += " ORDER BY CN9_FILIAL, AD1_SETOR, A1_NOME "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->CN9_FILIAL+T01->AD1_SETOR+T01->CN9_NUMERO
		(CALIAS1)->TMP_FILIAL  :=  T01->CN9_FILIAL
		(CALIAS1)->TMP_CLIEN :=  T01->TFJ_CODENT+" - "+TFJ_LOJA+": "+A1_NOME
		(CALIAS1)->TMP_EST     :=  T01->A1_EST
		(CALIAS1)->TMP_MUNIC   :=  T01->A1_MUN
		(CALIAS1)->TMP_END     :=  T01->A1_END
		(CALIAS1)->TMP_SETOR   :=  IIF(T01->AD1_SETOR=='1',"PUBLICO",IIF(T01->AD1_SETOR=='2',"PRIVADO",""))
		(CALIAS1)->TMP_NUM     :=  T01->CN9_NUMERO
		(CALIAS1)->TMP_DTINI   :=  STOD(T01->CN9_DTINIC)
		(CALIAS1)->TMP_DTFIM   :=  STOD(T01->CN9_DTFIM)
		(CALIAS1)->TMP_VIGEN   :=  T01->QTD_MES_VIGENCIA
		(CALIAS1)->TMP_SALDO   :=  T01->SALDO_TOTAL

		(CALIAS1)->(MsUnlock())

	T01->(DBSKIP())
Enddo


T01->( dbCloseArea() )



Return
