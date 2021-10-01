#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RCFGR01()

	Private oReport
	Private cPergCont	:= "RCFGR01"
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

	oReport := TReport():New( 'Lista de Fontes', 'Lista de Fontes', cPergCont, {|oReport| ReportPrint( oReport ), 'Lista de Fontes' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Lista de Fontes', { 'CN9'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_CAMPO1'		        ,'T01', 'Campo 1'                  ,			    		""						,02)
	AAdd( _CAMPTAB1, { "TMP_CAMPO1"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_CAMPO2'	    	        ,'T01', 'Campo 2'         ,			    		""						,11)
	AAdd( _CAMPTAB1, { "TMP_CAMPO2"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_CAMPO3'	    	        ,'T01', 'Campo 3'         ,			    		""						,60)
	AAdd( _CAMPTAB1, { "TMP_CAMPO3"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_CAMPO4'	    	    ,'T01', 'Campo 4'         ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_CAMPO4"	, 'D', 08, 0 } )




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
	oTempTab1:AddIndex("1",{"TMP_CAMPO1"})
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


	Local aFontes := {}
	Local nI , nT
	aFontes := GetSrcArray("*.PRW")
	nT := len(aFontes)
	If nT > 0
		For nI := 1 to nT
			aData := GetAPOInfo(aFontes[nI])
			(CALIAS1)->(Reclock( CALIAS1, .T.))

			(CALIAS1)->TMP_CAMPO1   :=  aData[1]
			(CALIAS1)->TMP_CAMPO2   :=  aData[2]
			(CALIAS1)->TMP_CAMPO3   :=  aData[3]
			(CALIAS1)->TMP_CAMPO4   :=  aData[4]
			
			conout("Fonte "+aData[1]+";"+aData[2]+";"+aData[3]+";"+dtoc(aData[4]))

			(CALIAS1)->(MsUnlock())
		Next
		MsgInfo("Fontes encontrados. Verifique log de console.")
	Else
		MsgStop("Nenhum fonte encontrado.")
	Endif



	
Return
