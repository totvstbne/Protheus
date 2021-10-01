#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RFINR01()

	Private oReport
	Private cPergCont	:= "RFINR01"
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

	oReport := TReport():New( 'Inadimplência', 'Inadimplência', cPergCont, {|oReport| ReportPrint( oReport ), 'Inadimplência' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Inadimplência', { 'CN9'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_EMP'		        ,'T01', 'Empresa'                  ,			    		""						,02)
	AAdd( _CAMPTAB1, { "TMP_EMP"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_CCLI'	    	        ,'T01', 'Cod. Cliente'         ,			    		""						,11)
	AAdd( _CAMPTAB1, { "TMP_CCLI"	, 'C', 11, 0 } )
	TRCell():New( oSection1, 'TMP_CLIEN'	    	        ,'T01', 'Cliente'         ,			    		""						,60)
	AAdd( _CAMPTAB1, { "TMP_CLIEN"	, 'C', 60, 0 } )
	TRCell():New( oSection1, 'TMP_BRUTO'	    	    ,'T01', 'Valor bruto'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_BRUTO"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_PAGO'	    	    ,'T01', 'Valor Pago'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_PAGO"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_SALDO'	    	    ,'T01', 'Saldo Aberto'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_SALDO"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QTDTI'	    	    ,'T01', 'Qtd. Títulos'        ,			    		""						,04)
	AAdd( _CAMPTAB1, { "TMP_QTDTI"	, 'N', 4, 0 } )
	TRCell():New( oSection1, 'TMP_DIAS'	    	    ,'T01', 'Média Dias'        ,			    		""						,04)
	AAdd( _CAMPTAB1, { "TMP_DIAS"	, 'N', 4, 0 } )



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
	oTempTab1:AddIndex("1",{"TMP_EMP","TMP_CCLI"})
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


CQUERY:= " SELECT E1_FILIAL, A1_COD, A1_LOJA, A1_NOME, SUM(E1_VALOR-E1_IRRF-E1_INSS-E1_PIS-E1_COFINS-E1_CSLL-E1_ISS) AS BRUTO, SUM(E1_SALDO) AS SALDO, "
CQUERY+= " SUM(E1_VALLIQ) AS PAGO, SUM(E1_IRRF+E1_INSS+E1_PIS+E1_COFINS+E1_CSLL+E1_ISS) IMPOSTOS,  COUNT(*) QTD_TITULOS, SUM(DATEDIFF(DAY,CONVERT(DATE, E1_VENCREA, 103),getdate()-1))/COUNT(*) AS MEDIA_DIAS, "
CQUERY+= " (SELECT SUM(E11.E1_SALDO) FROM "+RETSQLNAME("SE1")+" E11 WHERE E11.E1_FILIAL = '01' AND E11.E1_CLIENTE = A1_COD AND E11.E1_LOJA = A1_LOJA AND E11.E1_TIPO IN ('RA','NCC') AND E11.E1_SALDO > 0 AND E11.D_E_L_E_T_ = ' ') AS CREDITOS "
CQUERY+= " FROM "+RETSQLNAME("SE1")+" E1 "
CQUERY+= " INNER JOIN "+RETSQLNAME("SA1")+" A1 ON A1_FILIAL = ' ' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1.D_E_L_E_T_ = ' ' "
CQUERY+= " WHERE "
CQUERY+= " E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
CQUERY+= " E1_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
CQUERY+= " E1_NATUREZ BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
CQUERY+= " E1_TIPO NOT IN ('RA','NCC', 'PR') AND "
CQUERY+= " E1.D_E_L_E_T_ = ' ' AND E1_TITPAI = ' ' AND "
CQUERY+= " E1_VENCREA <= convert(CHAR(8),getdate()-1,112) AND E1_SALDO > 0 "
CQUERY+= " GROUP BY E1_FILIAL, A1_COD, A1_LOJA, A1_NOME ORDER BY E1_FILIAL, A1_COD, A1_LOJA "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->E1_FILIAL+T01->A1_COD+" - "+T01->A1_LOJA+": "+T01->A1_NOME 

		(CALIAS1)->TMP_EMP   :=  T01->E1_FILIAL
		(CALIAS1)->TMP_CCLI  :=  T01->A1_COD+" - "+T01->A1_LOJA
		(CALIAS1)->TMP_CLIEN :=  T01->A1_NOME 
		(CALIAS1)->TMP_BRUTO :=  T01->BRUTO
		(CALIAS1)->TMP_PAGO  :=  T01->PAGO
		(CALIAS1)->TMP_SALDO :=  T01->SALDO
		(CALIAS1)->TMP_QTDTI :=  T01->QTD_TITULOS
		(CALIAS1)->TMP_DIAS  :=  T01->MEDIA_DIAS



		(CALIAS1)->(MsUnlock())

	T01->(DBSKIP())
Enddo


T01->( dbCloseArea() )



Return
