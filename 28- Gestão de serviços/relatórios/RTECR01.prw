#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RTECR01()

	Private oReport
	Private cPergCont	:= "RTECR01   "
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

	oReport := TReport():New( 'Relatório Contrato x Fataramento x RH x MC', 'Relatório Contrato x Fataramento x RH x MC', cPergCont, {|oReport| ReportPrint( oReport ), 'Relatório Contrato x Fataramento x RH x MC' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Contrato x Fataramento x RH x MC', { 'CN9'})
	oSection2 := TRSection():New( oReport, 'Plan 2', { 'CN9'})
	oSection3 := TRSection():New( oReport, 'Resumo', { 'CN9'})




	TRCell():New( oSection1, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB1, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection1, 'TMP_FILIAL'	    	        ,'T01', 'Empresa/Filial'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_COMP'	    	        ,'T01', 'Competência'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_COMP"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NUMERO'	    	    ,'T01', 'Num. Contrato'                 ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_NUMERO"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_REVCON'		        ,'T01', 'Rev. Contrato'               ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_REVCON"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DTINI'		        ,'T01', 'Data Inicial'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTINI"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTFIM'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTFIM"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_VIGE'	    	        ,'T01', 'Vigencia'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_VIGE"	, 'N', 06, 0 } )
	TRCell():New( oSection1, 'TMP_OPORTU'	    	    ,'T01', 'Oportunidade'            ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_OPORTU"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_PROPOS'		            ,'T01', 'Proposta'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_PROPOS"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_REVPRO'	    	    ,'T01', 'Rev. Proposta'        ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_REVPRO"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_CODCLI'		        ,'T01', 'Cod. Cliente'            ,				   		""						,06)
	AAdd( _CAMPTAB1, { "TMP_CODCLI"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_LOJCLI'	    	    ,'T01', 'Loj. Cliente'        ,			    		""						,02)
	AAdd( _CAMPTAB1, { "TMP_LOJCLI"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'	    	    ,'T01', 'Nome Cliente'        ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_EST'	    	    ,'T01', 'Estado'        ,			    		""						,02)
	AAdd( _CAMPTAB1, { "TMP_EST"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_CONDPJ'	    	    ,'T01', 'Cond. Pagamento'        ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_CONDPJ"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_PLAN'	    	    ,'T01', 'Planilha'        ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_PLAN"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_LOCAL'	    	    ,'T01', 'Local'        ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_LOCAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_DESLO'	    	    ,'T01', 'Desc. Local'        ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_DESLO"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	    ,'T01', 'Cod. CC'        ,			    		""						,12)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 12, 0 } )
	TRCell():New( oSection1, 'TMP_DESCC'	    	    ,'T01', 'Desc. CC'        ,			    		""						,60)
	AAdd( _CAMPTAB1, { "TMP_DESCC"	, 'C', 60, 0 } )

	TRCell():New( oSection1, 'TMP_VLINI'	    	    ,'T01', 'Vlr. Inicial (CON)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLINI"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLATU'	    	    ,'T01', 'Vlr. Atual (CON)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLATU"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_SALDCO'	    	    ,'T01', 'Vlr. Saldo (CON)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_SALDCO"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLRHM'	    	    ,'T01', 'Vlr. RH (CON)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLRHM"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLMIM'	    	    ,'T01', 'Vlr. MI (CON)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLMIM"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLMCM'	    	    ,'T01', 'Vlr. MC (CON)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLMCM"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QTPPLA'	    	    ,'T01', 'Qtd. Parcela total (CRO)'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_QTPPLA"	, 'N', 6, 0 } )

	TRCell():New( oSection1, 'TMP_QTPPLP'	    	    ,'T01', 'Qtd. Parcela pendente (CRO)'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_QTPPLP"	, 'N', 6, 0 } )

	TRCell():New( oSection1, 'TMP_VLSPLA'	    	    ,'T01', 'Vlr. Saldo (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLSPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLPPLA'	    	    ,'T01', 'Vlr. Previsto Mês Total (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLPPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLPPRH'	    	    ,'T01', 'Vlr. Previsto Mês RH (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLPPRH"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLPPMI'	    	    ,'T01', 'Vlr. Previsto Mês MI (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLPPMI"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLPPMC'	    	    ,'T01', 'Vlr. Previsto Mês MC (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLPPMC"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLRPLA'	    	    ,'T01', 'Vlr. Medido (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLRPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLFFAT'	    	    ,'T01', 'Vlr. Faturado Mês (FAT)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLFFAT"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLFFAG'	    	    ,'T01', 'Vlr. Faturado Geral (FAT)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLFFAG"	, 'N', 14, 2 } )

	TRCell():New( oSection1, 'TMP_VLFRE'	    	    ,'T01', 'Vlr. Recebido (FIN)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLFRE"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_VLFIM'	    	    ,'T01', 'Vlr. Imposto retido (FIN)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLFIM"	, 'N', 14, 2 } )

	TRCell():New( oSection1, 'TMP_VLFOL'	    	    ,'T01', 'Vlr. RH (FOL)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLFOL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_QTDRH'	    	    ,'T01', 'Qtd. Funcionários (FOL)'         ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_QTDRH"	, 'N', 6, 0 } )
	TRCell():New( oSection1, 'TMP_VLMIC'	    	    ,'T01', 'Vlr. MI/MC (COM)'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLMIC"	, 'N', 14, 2 } )



	TRCell():New( oSection2, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB2, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection2, 'TMP_FILIAL'	    	        ,'T01', 'Empresa/Filial'         ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_COMP'	    	        ,'T01', 'Competência'         ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_COMP"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_CC'	    	    ,'T01', 'Cod. CC'        ,			    		""						,12)
	AAdd( _CAMPTAB2, { "TMP_CC"	, 'C', 12, 0 } )
	TRCell():New( oSection2, 'TMP_DESCC'	    	    ,'T01', 'Desc. CC'        ,			    		""						,60)
	AAdd( _CAMPTAB2, { "TMP_DESCC"	, 'C', 60, 0 } )


	TRCell():New( oSection2, 'TMP_VLPPLA'	    	    ,'T01', 'Vlr. Previsto Mês Total (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLPPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection2, 'TMP_VLRPLA'	    	    ,'T01', 'Vlr. Medido (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLRPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection2, 'TMP_VLFFAT'	    	    ,'T01', 'Vlr. Faturado Mês (FAT)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLFFAT"	, 'N', 14, 2 } )


	TRCell():New( oSection2, 'TMP_VLFRE'	    	    ,'T01', 'Vlr. Recebido (FIN)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLFRE"	, 'N', 14, 2 } )
	TRCell():New( oSection2, 'TMP_VLFIM'	    	    ,'T01', 'Vlr. Imposto retido (FIN)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLFIM"	, 'N', 14, 2 } )

	TRCell():New( oSection2, 'TMP_VLFOL'	    	    ,'T01', 'Vlr. RH (FOL)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLFOL"	, 'N', 14, 2 } )
	TRCell():New( oSection2, 'TMP_QTDRH'	    	    ,'T01', 'Qtd. Funcionários (FOL)'         ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDRH"	, 'N', 6, 0 } )
	TRCell():New( oSection2, 'TMP_VLMIC'	    	    ,'T01', 'Vlr. MI/MC (COM)'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VLMIC"	, 'N', 14, 2 } )





	TRCell():New( oSection3, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB3, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection3, 'TMP_FILIAL'	    	        ,'T01', 'Empresa/Filial'         ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_COMP'	    	        ,'T01', 'Competência'         ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_COMP"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_QTDLO'	    	    ,'T01', 'Qtd. Local'         ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDLO"	, 'N', 6, 0 } )


	TRCell():New( oSection3, 'TMP_VLPPLA'	    	    ,'T01', 'Vlr. Previsto Mês Total (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLPPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection3, 'TMP_VLRPLA'	    	    ,'T01', 'Vlr. Medido (CRO)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLRPLA"	, 'N', 14, 2 } )
	TRCell():New( oSection3, 'TMP_VLFFAT'	    	    ,'T01', 'Vlr. Faturado Mês (FAT)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLFFAT"	, 'N', 14, 2 } )


	TRCell():New( oSection3, 'TMP_VLFRE'	    	    ,'T01', 'Vlr. Recebido (FIN)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLFRE"	, 'N', 14, 2 } )
	TRCell():New( oSection3, 'TMP_VLFIM'	    	    ,'T01', 'Vlr. Imposto retido (FIN)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLFIM"	, 'N', 14, 2 } )

	TRCell():New( oSection3, 'TMP_VLFOL'	    	    ,'T01', 'Vlr. RH (FOL)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLFOL"	, 'N', 14, 2 } )
	TRCell():New( oSection3, 'TMP_QTDRH'	    	    ,'T01', 'Qtd. Funcionários (FOL)'         ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDRH"	, 'N', 6, 0 } )
	TRCell():New( oSection3, 'TMP_VLMIC'	    	    ,'T01', 'Vlr. MI/MC (COM)'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VLMIC"	, 'N', 14, 2 } )



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
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_NUMERO"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL","TMP_CC"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_FILIAL","TMP_SETOR"})
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



	CQUERY := " SELECT AD1_SETOR, CN9_FILIAL, CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, CN9_VIGE,  ADY_OPORTU, TFJ_PROPOS, TFJ_PREVIS, TFJ_CODENT, TFJ_LOJA, A1_NOME, A1_EST, TFJ_CONDPG, E4_DESCRI, TFL_PLAN, TFL_LOCAL, ABS_DESCRI, TFL_YCC, CTT_DESC01, "
	CQUERY += " CN9_CONDPG, CN9_VLINI, CN9_VLATU, CN9_SALDO, "
	CQUERY += " (SELECT SUM(TFF_QTDVEN*TFF_PRCVEN) FROM "+RETSQLNAME("TFF")+" TFF WHERE TFF_FILIAL = TFL_FILIAL AND TFF_CODPAI = TFL_CODIGO AND TFF.D_E_L_E_T_ = ' ' ) AS VLR_RH, "
	CQUERY += " (SELECT SUM(TFG_QTDVEN*TFG_PRCVEN) FROM "+RETSQLNAME("TFG")+" TFG, "+RETSQLNAME("TFF")+" TFF WHERE TFG_FILIAL = TFL_FILIAL AND TFG_CODPAI = TFF_COD AND TFG.D_E_L_E_T_ = ' ' AND TFF_FILIAL = TFL_FILIAL AND TFF_CODPAI = TFL_CODIGO AND TFF.D_E_L_E_T_ = ' ') AS VLR_MAT_IMP, "
	CQUERY += " (SELECT SUM(TFH_QTDVEN*TFH_PRCVEN) FROM "+RETSQLNAME("TFH")+" TFH, "+RETSQLNAME("TFF")+" TFF WHERE TFH_FILIAL = TFL_FILIAL AND TFH_CODPAI = TFF_COD AND TFH.D_E_L_E_T_ = ' ' AND TFF_FILIAL = TFL_FILIAL AND TFF_CODPAI = TFL_CODIGO AND TFF.D_E_L_E_T_ = ' ') AS VLR_MAT_CONS, "
	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("CNF")+" CNF WHERE CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_NUMPLA = TFL_PLAN ) AS QTD_PARCELA , "
	CQUERY += " (SELECT COUNT(*) FROM "+RETSQLNAME("CNF")+" CNF WHERE CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_NUMPLA = TFL_PLAN AND CNF_VLREAL = 0 ) AS PQTD_PARCELA , "
	CQUERY += " (SELECT SUM(CNF_SALDO) FROM "+RETSQLNAME("CNF")+" CNF WHERE CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_NUMPLA = TFL_PLAN ) AS SALDO_RECEBER, "
	CQUERY += " (SELECT SUM(CNF_VLPREV) FROM "+RETSQLNAME("CNF")+" CNF WHERE CNF_COMPET = '"+SUBSTR(MV_PAR07,5,2)+"/"+SUBSTR(MV_PAR07,1,4)+"'  AND CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_NUMPLA = TFL_PLAN ) AS VALOR_PREVISTO_MES , "
	CQUERY += " (SELECT SUM(CNF_VLREAL) FROM "+RETSQLNAME("CNF")+" CNF WHERE CNF_COMPET = '"+SUBSTR(MV_PAR07,5,2)+"/"+SUBSTR(MV_PAR07,1,4)+"'  AND CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_NUMPLA = TFL_PLAN ) AS VALOR_REAL_MES , "
	CQUERY += " (SELECT SUM(D2_TOTAL) FROM "+RETSQLNAME("SD2")+" D2, "+RETSQLNAME("SC5")+" C5 WHERE D2_FILIAL = CN9_FILIAL AND D2_EMISSAO BETWEEN '"+MV_PAR07+"01' AND '"+MV_PAR07+"31' AND D2_CLIENTE = TFJ_CODENT AND D2_LOJA = TFJ_LOJA AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_YCC = TFL_YCC AND D2.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' ) AS MVALOR_FATURADO_MES, "
	CQUERY += " (SELECT SUM(D2_TOTAL) FROM "+RETSQLNAME("SD2")+" D2, "+RETSQLNAME("SC5")+" C5 WHERE D2_FILIAL = CN9_FILIAL AND D2_EMISSAO BETWEEN CN9_DTINIC AND '"+MV_PAR07+"31' AND D2_CLIENTE = TFJ_CODENT AND D2_LOJA = TFJ_LOJA AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_YCC = TFL_YCC AND D2.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' ) AS GVALOR_FATURADO_GERAL, "
	//1=Provento;2=Desconto;3=Base (Provento);4=Base (Desconto)
	CQUERY += " (SELECT SUM(RD_VALOR) FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE RD_FILIAL = CN9_FILIAL AND RD_PERIODO = '"+MV_PAR07+"' AND RD_ROTEIR = 'FOL' AND RD_CC = TFL_YCC AND RV_FILIAL = SUBSTRING(CN9_FILIAL,1,2) AND RV_COD = RD_PD AND RV_TIPOCOD IN ('1','3') AND RV_YRELCNT = 'S'  AND RD.D_E_L_E_T_ =' ' AND RV.D_E_L_E_T_ = ' ') AS PVALOR_FOLHA, "
	CQUERY += " (SELECT SUM(RD_VALOR) FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE RD_FILIAL = CN9_FILIAL AND RD_PERIODO = '"+MV_PAR07+"' AND RD_ROTEIR = 'FOL' AND RD_CC = TFL_YCC AND RV_FILIAL = SUBSTRING(CN9_FILIAL,1,2) AND RV_COD = RD_PD AND RV_TIPOCOD IN ('2','4') AND RV_YRELCNT = 'S'  AND RD.D_E_L_E_T_ =' ' AND RV.D_E_L_E_T_ = ' ') AS DVALOR_FOLHA, "
	CQUERY += " (SELECT COUNT(distinct RD_MAT) FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE RD_FILIAL = CN9_FILIAL AND RD_PERIODO = '"+MV_PAR07+"' AND RD_ROTEIR = 'FOL' AND RD_CC = TFL_YCC AND RV_FILIAL = SUBSTRING(CN9_FILIAL,1,2) AND RV_COD = RD_PD AND RV_TIPOCOD IN ('1','3','2','4') AND RV_YRELCNT = 'S'  AND RD.D_E_L_E_T_ =' ' AND RV.D_E_L_E_T_ = ' ') AS QTD_FUNC, "
	CQUERY += " (SELECT SUM(D1_TOTAL) FROM "+RETSQLNAME("SD1")+" D1 WHERE D1_FILIAL = CN9_FILIAL AND D1_DTDIGIT BETWEEN '"+MV_PAR07+"01' AND '"+MV_PAR07+"31' AND D1_TES <> ' '  AND D1_CC = TFL_YCC AND D1_TIPO = 'N' ) AS VALOR_COMPRAS_MC_MIMP, "
	CQUERY += " ( SELECT SUM(E1_VALLIQ) FROM "+RETSQLNAME("SE1")+" E1 WHERE E1_FILIAL = SUBSTRING(CN9_FILIAL,1,2) AND E1.D_E_L_E_T_ = ' ' AND SUBSTRING(E1_FILIAL,1,2)+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA IN (SELECT SUBSTRING(D2_FILIAL,1,2)+D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA FROM "+RETSQLNAME("SD2")+" D2, "+RETSQLNAME("SC5")+" C5 WHERE D2_FILIAL = CN9_FILIAL AND D2_EMISSAO BETWEEN '"+MV_PAR07+"01' AND '"+MV_PAR07+"31' AND D2_CLIENTE = TFJ_CODENT AND D2_LOJA = TFJ_LOJA AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_YCC = TFL_YCC AND D2.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' )) AS VLR_RECEBIDO, "
	CQUERY += " ( SELECT SUM(E1_IRRF+E1_INSS+E1_PIS+E1_COFINS+E1_CSLL+E1_ISS) FROM "+RETSQLNAME("SE1")+" E1 WHERE E1_FILIAL = SUBSTRING(CN9_FILIAL,1,2) AND E1.D_E_L_E_T_ = ' ' AND SUBSTRING(E1_FILIAL,1,2)+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA IN (SELECT SUBSTRING(D2_FILIAL,1,2)+D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA FROM "+RETSQLNAME("SD2")+" D2, "+RETSQLNAME("SC5")+" C5 WHERE D2_FILIAL = CN9_FILIAL AND D2_EMISSAO BETWEEN '"+MV_PAR07+"01' AND '"+MV_PAR07+"31' AND D2_CLIENTE = TFJ_CODENT AND D2_LOJA = TFJ_LOJA AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_YCC = TFL_YCC AND D2.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' )) AS VLR_RETIDO_IMP  "
	CQUERY += " FROM "+RETSQLNAME("CN9")+" CN9 "
	CQUERY += " INNER JOIN "+RETSQLNAME("TFJ")+" TFJ ON TFJ_FILIAL = CN9_FILIAL AND TFJ_STATUS IN ('1','3') AND TFJ_CONTRT = CN9_NUMERO AND TFJ_CONREV = CN9_REVISA AND TFJ.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("SE4")+" E4 ON E4_FILIAL = '"+XFILIAL("SE4")+"' AND E4_CODIGO = TFJ_CONDPG AND E4.D_E_L_E_T_ = ' '  "
//--INNER JOIN CNF010 CNF ON CNF_FILIAL = CN9_FILIAL AND CNF_CONTRA = CN9_NUMERO AND CNF_REVISA = CN9_REVISA AND CNF.D_E_L_E_T_ = ' ' AND CNF_COMPET = '09/2020'
	CQUERY += " INNER JOIN "+RETSQLNAME("ADY")+" ADY ON ADY_FILIAL = TFJ_FILIAL AND ADY_PROPOS = TFJ_PROPOS AND ADY_PREVIS = TFJ_PREVIS AND ADY.D_E_L_E_T_ = ' '  "
	CQUERY += " INNER JOIN "+RETSQLNAME("AD1")+" AD1 ON AD1_FILIAL = ADY_FILIAL AND AD1_PROPOS = ADY_PROPOS AND AD1.D_E_L_E_T_ = ' '  "
	CQUERY += " INNER JOIN "+RETSQLNAME("TFL")+" TFL ON SUBSTRING(TFL_DTINI,1,6) <= '"+MV_PAR07+"'  AND SUBSTRING(TFL_DTFIM,1,6) >='"+MV_PAR07+"'  AND TFL_FILIAL = CN9_FILIAL AND TFL_CONTRT = CN9_NUMERO AND TFL_CODPAI = TFJ_CODIGO AND TFL_CONREV = CN9_REVISA AND TFL.D_E_L_E_T_ = ' ' AND TFL_ENCE <> '1'  "
	CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(TFL_FILIAL,1,2) AND CTT_CUSTO = TFL_YCC AND CTT.D_E_L_E_T_ = ' ' AND CTT_CUSTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	CQUERY += " INNER JOIN "+RETSQLNAME("SA1")+" A1  ON A1_FILIAL = ' ' AND A1_COD = TFJ_CODENT AND A1_LOJA = TFJ_LOJA AND A1.D_E_L_E_T_ = ' '  AND A1_COD BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR10+"'  AND A1_LOJA BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR11+"' "
	CQUERY += " INNER JOIN "+RETSQLNAME("ABS")+" ABS ON ABS_FILIAL = ' ' AND ABS_LOCAL = TFL_LOCAL AND ABS.D_E_L_E_T_ = ' ' "
	CQUERY += " WHERE "
	CQUERY += " SUBSTRING(CN9_DTINIC,1,6) <= '"+MV_PAR07+"'  AND SUBSTRING(CN9_DTFIM,1,6) >='"+MV_PAR07+"'  AND CN9_REVATU = ' '  AND CN9.D_E_L_E_T_ = ' ' AND CN9_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND CN9_NUMERO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

	CQUERY += " ORDER BY CN9_FILIAL, CN9_NUMERO "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())


		(CALIAS1)->(Reclock( CALIAS1, .T.))
		(CALIAS1)->TMP_SETOR  := T01->AD1_SETOR
		(CALIAS1)->TMP_FILIAL := T01->CN9_FILIAL
		(CALIAS1)->TMP_COMP   := MV_PAR07
		(CALIAS1)->TMP_NUMERO := T01->CN9_NUMERO
		(CALIAS1)->TMP_REVCON := T01->CN9_REVISA
		(CALIAS1)->TMP_DTINI  := STOD(T01->CN9_DTINIC)
		(CALIAS1)->TMP_DTFIM  := STOD(T01->CN9_DTFIM)
		(CALIAS1)->TMP_VIGE   := T01->CN9_VIGE
		(CALIAS1)->TMP_OPORTU := T01->ADY_OPORTU
		(CALIAS1)->TMP_PROPOS := T01->TFJ_PROPOS
		(CALIAS1)->TMP_REVPRO := T01->TFJ_PREVIS
		(CALIAS1)->TMP_CODCLI := T01->TFJ_CODENT
		(CALIAS1)->TMP_LOJCLI := T01->TFJ_LOJA
		(CALIAS1)->TMP_NOME   := T01->A1_NOME
		(CALIAS1)->TMP_EST    := T01->A1_EST
		(CALIAS1)->TMP_CONDPJ := T01->TFJ_CONDPG+" - "+T01->E4_DESCRI
		(CALIAS1)->TMP_PLAN   := T01->TFL_PLAN
		(CALIAS1)->TMP_LOCAL  := T01->TFL_LOCAL
		(CALIAS1)->TMP_DESLO  := T01->ABS_DESCRI
		(CALIAS1)->TMP_CC     := T01->TFL_YCC
		(CALIAS1)->TMP_DESCC  := T01->CTT_DESC01
		(CALIAS1)->TMP_VLINI  := T01->CN9_VLINI
		(CALIAS1)->TMP_VLATU  := T01->CN9_VLATU
		(CALIAS1)->TMP_SALDCO := T01->CN9_SALDO
		(CALIAS1)->TMP_VLRHM  := T01->VLR_RH
		(CALIAS1)->TMP_VLMIM  := T01->VLR_MAT_IMP
		(CALIAS1)->TMP_VLMCM  := T01->VLR_MAT_CONS
		(CALIAS1)->TMP_QTPPLA := T01->QTD_PARCELA
		(CALIAS1)->TMP_QTPPLP := T01->PQTD_PARCELA
		(CALIAS1)->TMP_VLSPLA := T01->SALDO_RECEBER
		(CALIAS1)->TMP_VLPPLA := T01->VALOR_PREVISTO_MES

		_NPERRH := ROUND(((T01->VLR_RH*100)/T01->CN9_VLATU	),2)
		_NPERMI := ROUND(((T01->VLR_MAT_IMP*100)/T01->CN9_VLATU	),2)
		_NPERMC := ROUND(((T01->VLR_MAT_CONS*100)/T01->CN9_VLATU	),2)

		(CALIAS1)->TMP_VLPPRH := (T01->VALOR_PREVISTO_MES*_NPERRH)/100
		(CALIAS1)->TMP_VLPPMI := (T01->VALOR_PREVISTO_MES*_NPERMI)/100
		(CALIAS1)->TMP_VLPPMC := (T01->VALOR_PREVISTO_MES*_NPERMC)/100
		(CALIAS1)->TMP_VLRPLA := T01->VALOR_REAL_MES
		(CALIAS1)->TMP_VLFFAT := T01->MVALOR_FATURADO_MES
		(CALIAS1)->TMP_VLFFAG := T01->GVALOR_FATURADO_GERAL
		(CALIAS1)->TMP_VLFOL  := T01->PVALOR_FOLHA-T01->DVALOR_FOLHA
		(CALIAS1)->TMP_QTDRH  := T01->QTD_FUNC
		(CALIAS1)->TMP_VLMIC  := T01->VALOR_COMPRAS_MC_MIMP


		(CALIAS1)->TMP_VLFRE := T01->VLR_RECEBIDO
		(CALIAS1)->TMP_VLFIM := T01->VLR_RETIDO_IMP
		_chave := T01->CN9_FILIAL+T01->CN9_NUMERO



		(CALIAS1)->(MsUnlock())





		(CALIAS2)->(Reclock( CALIAS2, .T.))
		(CALIAS2)->TMP_SETOR  := T01->AD1_SETOR
		(CALIAS2)->TMP_FILIAL := T01->CN9_FILIAL
		(CALIAS2)->TMP_COMP   := MV_PAR07
		(CALIAS2)->TMP_CC     := T01->TFL_YCC
		(CALIAS2)->TMP_DESCC  := T01->CTT_DESC01

		(CALIAS2)->TMP_VLPPLA := T01->VALOR_PREVISTO_MES


		(CALIAS2)->TMP_VLRPLA := T01->VALOR_REAL_MES
		(CALIAS2)->TMP_VLFFAT := T01->MVALOR_FATURADO_MES

		(CALIAS2)->TMP_VLFOL  := T01->PVALOR_FOLHA-T01->DVALOR_FOLHA
		(CALIAS2)->TMP_QTDRH  := T01->QTD_FUNC
		(CALIAS2)->TMP_VLMIC  := T01->VALOR_COMPRAS_MC_MIMP


		(CALIAS2)->TMP_VLFRE := T01->VLR_RECEBIDO
		(CALIAS2)->TMP_VLFIM := T01->VLR_RETIDO_IMP

		(CALIAS2)->(MsUnlock())
		DBSELECTAREA((CALIAS3))
		DBSETORDER(1)
		IF DBSEEK(T01->CN9_FILIAL+T01->AD1_SETOR)
			(CALIAS3)->(Reclock( (CALIAS3), .F.))

			(CALIAS3)->TMP_QTDLO  += 1
			(CALIAS3)->TMP_VLPPLA += T01->VALOR_PREVISTO_MES
			(CALIAS3)->TMP_VLRPLA += T01->VALOR_REAL_MES
			(CALIAS3)->TMP_VLFFAT += T01->MVALOR_FATURADO_MES
			(CALIAS3)->TMP_VLFOL  += T01->PVALOR_FOLHA-T01->DVALOR_FOLHA
			(CALIAS3)->TMP_QTDRH  += T01->QTD_FUNC
			(CALIAS3)->TMP_VLMIC  += T01->VALOR_COMPRAS_MC_MIMP
			(CALIAS3)->TMP_VLFRE  += T01->VLR_RECEBIDO
			(CALIAS3)->TMP_VLFIM  += T01->VLR_RETIDO_IMP
		
		ELSE
			(CALIAS3)->(Reclock( (CALIAS3), .T.))
			
			(CALIAS3)->TMP_QTDLO := 1

			(CALIAS3)->TMP_SETOR  := T01->AD1_SETOR
			(CALIAS3)->TMP_FILIAL := T01->CN9_FILIAL
			(CALIAS3)->TMP_COMP   := MV_PAR07
			(CALIAS3)->TMP_VLPPLA := T01->VALOR_PREVISTO_MES
			(CALIAS3)->TMP_VLRPLA := T01->VALOR_REAL_MES
			(CALIAS3)->TMP_VLFFAT := T01->MVALOR_FATURADO_MES
			(CALIAS3)->TMP_VLFOL  := T01->PVALOR_FOLHA-T01->DVALOR_FOLHA
			(CALIAS3)->TMP_QTDRH  := T01->QTD_FUNC
			(CALIAS3)->TMP_VLMIC  := T01->VALOR_COMPRAS_MC_MIMP
			(CALIAS3)->TMP_VLFRE := T01->VLR_RECEBIDO
			(CALIAS3)->TMP_VLFIM := T01->VLR_RETIDO_IMP

		ENDIF

		(CALIAS3)->(MsUnlock())

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )



Return
