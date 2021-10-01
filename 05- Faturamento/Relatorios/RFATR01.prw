#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RFATR01()

	Private oReport
	Private cPergCont	:= PadR('RFATR01' ,10)
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

	oReport := TReport():New( 'Rel faturamento', 'Rel faturamento', cPergCont, {|oReport| ReportPrint( oReport ), 'Rel faturamento' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Faturamento', { 'SF2'})
	//oSection2 := TRSection():New( oReport, 'Filial', { 'SRA'})
	//oSection3 := TRSection():New( oReport, 'Centro de Custo', { 'SRA'})
	//oSection4 := TRSection():New( oReport, 'Empresa', { 'SRA'})


	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_CTR'		        ,'T01', 'Contrato'               ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_CTR"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_NOMEC'		            ,'T01', 'Nome Cliente'               ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NOMEC"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_RPS'		        	,'T01', 'RPS'                     ,				   		""						,09)
	AAdd( _CAMPTAB1, { "TMP_RPS"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_NF'		            ,'T01', 'Nota Fiscal'               ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_NF"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_EMIS'		    	    ,'T01', 'Data Emissão'              ,						""                      ,08)
	AAdd( _CAMPTAB1, { "TMP_EMIS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_VENCT'		    	    ,'T01', 'Venc. Original'              ,						""                      ,08)
	AAdd( _CAMPTAB1, { "TMP_VENCT"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_VENCR'		    	    ,'T01', 'Venc. Real'              ,						""                      ,08)
	AAdd( _CAMPTAB1, { "TMP_VENCR"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DESCCC"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_VLRT'	    	    ,'T01', 'Valor Total'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VLRT"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_ISS'	    	    ,'T01', 'Valor ISS'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_ISS"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_INSS'	    	    ,'T01', 'Valor INSS'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_INSS"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_PIS'	    	    ,'T01', 'Valor PIS'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_PIS"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_COF'	    	    ,'T01', 'Valor COFINS'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_COF"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_CSLL'	    	    ,'T01', 'Valor CSLL'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_CSLL"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_IR'	    	    ,'T01', 'Valor IR'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_IR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_LIQ'	    	    ,'T01', 'Valor Líquido'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_LIQ"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_BAIXA'		    	    ,'T01', 'Data Baixa'              ,						""                      ,08)
	AAdd( _CAMPTAB1, { "TMP_BAIXA"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_COMP'	    	        ,'T01', 'Competência '         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_COMP"	, 'C', 06, 0 } )

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
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_CTR"})
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




	CQUERY := " SELECT  "
	CQUERY += " (SELECT TOP 1 TFL_CONTRT FROM "+RETSQLNAME("TFL")+" TFL WHERE TFL_FILIAL = F2_FILIAL AND TFL_YCC = C5_YCC AND TFL.D_E_L_E_T_ = ' ' GROUP BY TFL_CONTRT) CONTRATO, "
	CQUERY += " F2_FILIAL, A1_NOME,  F2_NFELETR, F2_DOC,F2_EMISSAO, E1_VENCTO VENC_ORIG, E1_VENCREA VENC_REAL, C5_YCC, CTT_DESC01, "
	CQUERY += " SUM(E1_VALOR) E1_VALOR, SUM(E1_ISS) E1_ISS, SUM(E1_INSS) E1_INSS,  SUM(E1_PIS) PIS , SUM(E1_COFINS) COFINS,  SUM(E1_CSLL) E1_CSLL, SUM(E1_IRRF) E1_IRRF, "
	CQUERY += " SUM(E1_VALOR - E1_ISS - E1_PIS - E1_COFINS - E1_INSS - E1_IRRF- E1_CSLL ) LIQUIDO,E1_BAIXA, SUBSTRING(C5_YCOMPET,1,6) COMPETENCIA "
	CQUERY += " FROM "+RETSQLNAME("SF2")+" F2 "
	CQUERY += " INNER JOIN "+RETSQLNAME("SA1")+" A1 ON A1_FILIAL = ' ' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("SD2")+" D2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D2.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("SC5")+" C5 ON C5_FILIAL = F2_FILIAL AND C5_NUM = D2_PEDIDO AND C5.D_E_L_E_T_ = ' ' AND SUBSTRING(C5_YCOMPET,1,6) BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	CQUERY += " INNER JOIN "+RETSQLNAME("SE1")+" E1 ON E1_TIPO = 'NF' AND E1_FILIAL = SUBSTRING(F2_FILIAL,1,2) AND E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_CLIENTE = D2_CLIENTE AND E1_LOJA = D2_LOJA AND E1.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(F2_FILIAL,1,2) AND CTT_CUSTO = C5_YCC AND CTT.D_E_L_E_T_ = ' ' "
//CQUERY += " --INNER JOIN TFL010 TFL ON TFL_FILIAL = F2_FILIAL AND TFL_YCC = D2_CCUSTO AND TFL.D_E_L_E_T_ = ' ' "
	CQUERY += " WHERE F2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND F2.D_E_L_E_T_ = ' ' AND F2_TIPO = 'N' "
	CQUERY += " GROUP BY  F2_FILIAL, A1_NOME,  F2_NFELETR, F2_DOC,F2_EMISSAO, E1_VENCTO, E1_VENCREA, C5_YCC, CTT_DESC01, E1_BAIXA, SUBSTRING(C5_YCOMPET,1,6) "
	CQUERY += " ORDER BY F2_FILIAL, F2_DOC "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())





		_ALINHA := {}

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->F2_FILIAL+T01->CONTRATO

		(CALIAS1)->TMP_FILIAL   :=T01->F2_FILIAL
		(CALIAS1)->TMP_CTR		:=T01->CONTRATO
		(CALIAS1)->TMP_NOMEC	:=T01->A1_NOME
		(CALIAS1)->TMP_RPS		:=T01->F2_DOC
		(CALIAS1)->TMP_NF		:=T01->F2_NFELETR
		(CALIAS1)->TMP_EMIS		:=STOD(T01->F2_EMISSAO)
		(CALIAS1)->TMP_VENCT	:=STOD(T01->VENC_ORIG)
		(CALIAS1)->TMP_VENCR	:=STOD(T01->VENC_REAL)
		(CALIAS1)->TMP_CC		:=T01->C5_YCC
		(CALIAS1)->TMP_DESCCC	:=T01->CTT_DESC01  
		(CALIAS1)->TMP_VLRT		:=T01->E1_VALOR
		(CALIAS1)->TMP_ISS		:=T01->E1_ISS
		(CALIAS1)->TMP_INSS		:=T01->E1_INSS
		(CALIAS1)->TMP_PIS		:=T01->PIS
		(CALIAS1)->TMP_COF		:=T01->COFINS
		(CALIAS1)->TMP_CSLL		:=T01->E1_CSLL
		(CALIAS1)->TMP_IR		:=T01->E1_IRRF
		(CALIAS1)->TMP_LIQ		:=T01->LIQUIDO
		(CALIAS1)->TMP_BAIXA	:=STOD(T01->E1_BAIXA)
		(CALIAS1)->TMP_COMP		:=T01->COMPETENCIA

		T01->( dbSkip() )
	ENDDO



	(CALIAS1)->(MsUnlock())




	T01->( dbCloseArea() )



Return
