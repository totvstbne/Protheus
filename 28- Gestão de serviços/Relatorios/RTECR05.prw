#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RTECR05()

	Private oReport
	Private cPergCont	:= "RTECR05"
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

	oReport := TReport():New( 'CC x Realizado', 'CC x Realizado', cPergCont, {|oReport| ReportPrint( oReport ), 'CC x Realizado' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'CC x Realizado', { 'SZ4'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})

	TRCell():New( oSection1, 'Z4_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "Z4_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'Z4_CODCLI'	    	        ,'T01', 'Cod. Cliente'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "Z4_CODCLI"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'Z4_CLIENTE'	    	        ,'T01', 'Cliente'         ,			    		""						,50)
	AAdd( _CAMPTAB1, { "Z4_CLIENTE"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'Z4_CONTRAT'	    	        ,'T01', 'Contrato'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "Z4_CONTRAT"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'Z4_CC'	    	        ,'T01', 'CC'         ,			    		""						,20)
	AAdd( _CAMPTAB1, { "Z4_CC"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'Z4_COMPET'	    	        ,'T01', 'Competencia'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "Z4_COMPET"	, 'C', 06, 0 } )

	cQUERY := " SELECT * FROM "+RETSQLNAME("SX3")+" WHERE X3_ARQUIVO = 'SZ4' AND X3_ORDEM > '04' ORDER BY X3_ARQUIVO, X3_ORDEM  "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		TRCell():New( oSection1, T01->X3_CAMPO		        ,'T01', T01->X3_DESCRIC                  ,			    		""						,06)
		AAdd( _CAMPTAB1, { T01->X3_CAMPO	, T01->X3_TIPO, T01->X3_TAMANHO, T01->X3_DECIMAL } )
		T01->(DBSKIP())
	ENDDO
	T01->(DBCLOSEAREA())

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
	oTempTab1:AddIndex("1",{"Z4_FILIAL","Z4_CONTRAT","Z4_CC","Z4_COMPET"})
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

	CQUERY := " SELECT Z4_FILIAL Z4FILIAL, Z4_CONTRAT Z4CONTRAT, Z4_CC Z4CC, Z4_COMPET Z4COMPET, * FROM "+RETSQLNAME("SZ4")+" SZ4 "
	//CQUERY += " INNER JOIN "+RETSQLNAME("SA1")+" A1   ON A1_FILIAL = ' ' AND A1_COD = ABS_CODIGO AND A1_LOJA = ABS_LOJA AND A1.D_E_L_E_T_ = ' ' "
	//CQUERY += " INNER JOIN "+RETSQLNAME("TFF")+" TFF  ON TFF_FILIAL = Z3_FILIAL AND TFF_COD = Z3_CODRH AND TFF_CONTRT = Z3_CONTRAT AND TFF_CONREV = Z3_REVISAO AND TFF.D_E_L_E_T_ = ' ' AND TFF_COBCTR = '1'  "
	//CQUERY += " INNER JOIN "+RETSQLNAME("CN9")+" CN9  ON CN9_FILIAL = TFF_FILIAL AND CN9_NUMERO = TFF_CONTRT AND CN9_REVISA = TFF_CONREV AND CN9.D_E_L_E_T_ = ' ' AND CN9_REVATU = ' ' AND CN9_SITUAC NOT IN  ('10','08') AND CN9_DTENCE = ' '   "
	CQUERY += " WHERE Z4_FILIAL = '"+MV_PAR01+"' AND Z4_CONTRAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND Z4_COMPET = '"+MV_PAR04+"'  AND SZ4.D_E_L_E_T_ = ' ' ORDER BY Z4FILIAL, Z4CONTRAT, Z4CC, Z4COMPET "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		DBSELECTAREA((CALIAS1))
		DBSETORDER(1)
		IF DBSEEK(T01->(Z4FILIAL+Z4CONTRAT+Z4cc))
			(CALIAS1)->(Reclock((CALIAS1), .F.))


			cQUERY := " SELECT * FROM "+RETSQLNAME("SX3")+" WHERE X3_ARQUIVO = 'SZ4' AND X3_ORDEM > '04' ORDER BY X3_ARQUIVO, X3_ORDEM  "

			TcQuery cQuery New Alias T02
			DbSelectArea("T02")

			While !T02->(Eof())
				
					&((CALIAS1)+"->"+T02->X3_CAMPO) +=  &("T01->"+T02->X3_CAMPO)
			
				T02->(DBSKIP())
			ENDDO
			T02->(DBCLOSEAREA())

		ELSE
			(CALIAS1)->(Reclock((CALIAS1), .T.))

			(CALIAS1)->Z4_FILIAL   :=  T01->Z4FILIAL
			(CALIAS1)->Z4_CONTRAT  :=  T01->Z4CONTRAT
			(CALIAS1)->Z4_CC       :=  T01->Z4CC
			(CALIAS1)->Z4_COMPET   :=  T01->Z4COMPET

			cQUERY := " SELECT * FROM "+RETSQLNAME("SX3")+" WHERE X3_ARQUIVO = 'SZ4' AND X3_ORDEM > '04' ORDER BY X3_ARQUIVO, X3_ORDEM  "

			TcQuery cQuery New Alias T02
			DbSelectArea("T02")

			While !T02->(Eof())
				&((CALIAS1)+"->"+T02->X3_CAMPO) :=  &("T01->"+T02->X3_CAMPO)

				T02->(DBSKIP())
			ENDDO
			T02->(DBCLOSEAREA())

		ENDIF
		(CALIAS1)->(MsUnlock())





		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )



Return
