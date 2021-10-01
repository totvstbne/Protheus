#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR02()

	Private oReport
	Private cPergCont	:= "RGPRHR02"
	PRIVATE	_CAMPTAB1 := {}
	PRIVATE cAlias1			:= GetNextAlias()
	PRIVATE oTempTab1

	PRIVATE	_CAMPTAB2 := {}
	PRIVATE cAlias2		:= GetNextAlias()
	PRIVATE oTempTab2
	PRIVATE	_CAMPTAB3 := {}
	PRIVATE cAlias3			:= GetNextAlias()
	PRIVATE oTempTab3
	PRIVATE	_CAMPTAB4 := {}
	PRIVATE cAlias4			:= GetNextAlias()
	PRIVATE oTempTab4

	PRIVATE	_CAMPTAB5 := {}
	PRIVATE cAlias5			:= GetNextAlias()
	PRIVATE oTempTab5
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
	Local oSection4
	Local oSection5
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'Relatorio Posto x Atendente', 'Relatorio Posto x Atendente', cPergCont, {|oReport| ReportPrint( oReport ), 'Relatorio Posto x Atendente' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Posto x Atendente', { 'SRA'})
	oSection2 := TRSection():New( oReport, 'Contrato', { 'CTT'})
	oSection3 := TRSection():New( oReport, 'Local x Produto', { 'SRJ'})
	oSection4 := TRSection():New( oReport, 'Local', { 'SRJ'})
	oSection5 := TRSection():New( oReport, 'Local x Contrato', { 'SRJ'})


	TRCell():New( oSection1, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB1, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_COD'		        ,'T01', 'Código'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_COD"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NCONTR'	    	        ,'T01', 'Número Contrato'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_NCONTR"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'	    	    ,'T01', 'Nome'                 ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_ESCAL'		        ,'T01', 'Escala'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_ESCAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_LOCAL'	    	        ,'T01', 'Local'                  ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_LOCAL"	, 'C', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DESLOC'	    	    ,'T01', 'Desc. Local'            ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DESLOC"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_MUNIC'	    	    ,'T01', 'Municipio'            ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_MUNIC"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_PROD'		            ,'T01', 'Produto'               ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_PROD"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_DESPRO'		        ,'T01', 'Desc. Produto'            ,				   		""						,30)
	AAdd( _CAMPTAB1, { "TMP_DESPRO"	, 'C', 30, 0 } )

	TRCell():New( oSection1, 'TMP_CNAE'		            ,'T01', 'Cod CNAE'               ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_CNAE"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_DESCNA'		        ,'T01', 'Desc. CNAE'            ,				   		""						,55)
	AAdd( _CAMPTAB1, { "TMP_DESCNA"	, 'C', 55, 0 } )

	TRCell():New( oSection1, 'TMP_VUNIT'		        ,'T01', 'Valor Unit.'            ,				   		""						,15)
	AAdd( _CAMPTAB1, { "TMP_VUNIT"	, 'N', 14, 2 } )

	TRCell():New( oSection1, 'TMP_PERIC'	    	    ,'T01', 'Periculosidade'        ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_PERIC"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_INSALU'	    	    ,'T01', 'Insalubridade'        ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_INSALU"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_CODATE'	    	    ,'T01', 'Atendente'        ,			    		""						,12)
	AAdd( _CAMPTAB1, { "TMP_CODATE"	, 'C', 12, 0 } )
	TRCell():New( oSection1, 'TMP_NOMATE'	    	    ,'T01', 'Nome Atendente'                 ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_NOMATE"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_SITFOL'	    	    ,'T01', 'Sit. Folha'                 ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_SITFOL"	, 'C', 01, 0 } )

	TRCell():New( oSection1, 'TMP_DTINI'		    	,'T01', 'Data ini.'             ,						""                      ,08)
	AAdd( _CAMPTAB1, { "TMP_DTINI"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTFIM'		        ,'T01', 'Data fim'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTFIM"	, 'D', 08, 0 } )


	TRCell():New( oSection1, 'TMP_TPMOV'	    	    ,'T01', 'Tipo Mov.'        ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_TPMOV"	, 'C', 3, 0 } )

	TRCell():New( oSection1, 'TMP_CODAUS'	    	        ,'T01', 'Cod. Ausencia'         ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_CODAUS"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DESAUS'	    	    ,'T01', 'Desc Ausencia'                 ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_DESAUS"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_DATAIN'		        ,'T01', 'Data Inicio'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DATAIN"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DATAFI'		        ,'T01', 'Data Fim'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DATAFI"	, 'D', 08, 0 } )

	TRCell():New( oSection2, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB2, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection2, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 06, 0 } )

	TRCell():New( oSection2, 'TMP_NCONTR'		        ,'T01', 'Número Contrato'                  ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_NCONTR"	, 'C', 15, 0 } )

	TRCell():New( oSection2, 'TMP_PROD'		            ,'T01', 'Produto'               ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_PROD"	, 'C', 15, 0 } )
	TRCell():New( oSection2, 'TMP_DESPRO'		        ,'T01', 'Desc. Produto'            ,				   		""						,30)
	AAdd( _CAMPTAB2, { "TMP_DESPRO"	, 'C', 30, 0 } )

	TRCell():New( oSection2, 'TMP_CNAE'		            ,'T01', 'Cod CNAE'               ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_CNAE"	, 'C', 15, 0 } )
	TRCell():New( oSection2, 'TMP_DESCNA'		        ,'T01', 'Desc. CNAE'            ,				   		""						,55)
	AAdd( _CAMPTAB2, { "TMP_DESCNA"	, 'C', 55, 0 } )

	TRCell():New( oSection2, 'TMP_QTDVEN'		        ,'T01', 'Qtd Contrato'        ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDVEN"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDALO'		        ,'T01', 'Qtd Alocado'        ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDALO"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDAUS'		        ,'T01', 'Qtd Ausente'        ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDAUS"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDSAL'		        ,'T01', 'Qtd Saldo'        ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDSAL"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_VUNIT'		        ,'T01', 'Valor Unit.'            ,				   		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VUNIT"	, 'N', 14, 2 } )

	TRCell():New( oSection2, 'TMP_VTOT'		        ,'T01', 'Valor Total'            ,				   		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VTOT"	, 'N', 14, 2 } )

	TRCell():New( oSection2, 'TMP_VPGM'		        ,'T01', 'Vlr Alocado +'            ,				   		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VPGM"	, 'N', 14, 2 } )

	TRCell():New( oSection2, 'TMP_VDFAT'		        ,'T01', 'Vlr não Alocado'            ,				   		""						,15)
	AAdd( _CAMPTAB2, { "TMP_VDFAT"	, 'N', 14, 2 } )

	TRCell():New( oSection2, 'TMP_STATUS'		        ,'T01', 'STATUS'            ,				   		""						,15)
	AAdd( _CAMPTAB2, { "TMP_STATUS"	, 'C', 15, 0 } )


	TRCell():New( oSection3, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB3, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection3, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_FILIAL"	, 'C', 06, 0 } )

	TRCell():New( oSection3, 'TMP_LOCAL'		        ,'T01', 'Local'                  ,			    		""						,08)
	AAdd( _CAMPTAB3, { "TMP_LOCAL"	, 'C', 08, 0 } )

	TRCell():New( oSection3, 'TMP_DESLOC'	    	    ,'T01', 'Desc. Local'            ,			    		""						,40)
	AAdd( _CAMPTAB3, { "TMP_DESLOC"	, 'C', 40, 0 } )
	TRCell():New( oSection3, 'TMP_MUNIC'	    	    ,'T01', 'Municipio'            ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_MUNIC"	, 'C', 30, 0 } )
	TRCell():New( oSection3, 'TMP_PROD'		            ,'T01', 'Produto'               ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_PROD"	, 'C', 15, 0 } )
	TRCell():New( oSection3, 'TMP_DESPRO'		        ,'T01', 'Desc. Produto'            ,				   		""						,30)
	AAdd( _CAMPTAB3, { "TMP_DESPRO"	, 'C', 30, 0 } )

	TRCell():New( oSection3, 'TMP_CNAE'		            ,'T01', 'Cod CNAE'               ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_CNAE"	, 'C', 15, 0 } )
	TRCell():New( oSection3, 'TMP_DESCNA'		        ,'T01', 'Desc. CNAE'            ,				   		""						,55)
	AAdd( _CAMPTAB3, { "TMP_DESCNA"	, 'C', 55, 0 } )

	TRCell():New( oSection3, 'TMP_QTDVEN'		        ,'T01', 'Qtd Contrato'        ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDVEN"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDALO'		        ,'T01', 'Qtd Alocado'        ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDALO"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDAUS'		        ,'T01', 'Qtd Ausente'        ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDAUS"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDSAL'		        ,'T01', 'Qtd Saldo'        ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDSAL"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_VUNIT'		        ,'T01', 'Valor Unit.'            ,				   		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VUNIT"	, 'N', 14, 2 } )

	TRCell():New( oSection3, 'TMP_VTOT'		        ,'T01', 'Valor Total'            ,				   		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VTOT"	, 'N', 14, 2 } )

	TRCell():New( oSection3, 'TMP_VPGM'		        ,'T01', 'Vlr Alocado +'            ,				   		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VPGM"	, 'N', 14, 2 } )

	TRCell():New( oSection3, 'TMP_VDFAT'		        ,'T01', 'Vlr não Alocado'            ,				   		""						,15)
	AAdd( _CAMPTAB3, { "TMP_VDFAT"	, 'N', 14, 2 } )

	TRCell():New( oSection3, 'TMP_STATUS'		        ,'T01', 'STATUS'            ,				   		""						,15)
	AAdd( _CAMPTAB3, { "TMP_STATUS"	, 'C', 15, 0 } )

	TRCell():New( oSection4, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB4, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection4, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_FILIAL"	, 'C', 06, 0 } )

	TRCell():New( oSection4, 'TMP_LOCAL'		        ,'T01', 'Local'                  ,			    		""						,08)
	AAdd( _CAMPTAB4, { "TMP_LOCAL"	, 'C', 08, 0 } )

	TRCell():New( oSection4, 'TMP_DESLOC'	    	    ,'T01', 'Desc. Local'            ,			    		""						,40)
	AAdd( _CAMPTAB4, { "TMP_DESLOC"	, 'C', 40, 0 } )

	TRCell():New( oSection4, 'TMP_EST'	    	    ,'T01', 'Estado'            ,			    		""						,02)
	AAdd( _CAMPTAB4, { "TMP_EST"	, 'C', 02, 0 } )

	TRCell():New( oSection4, 'TMP_MUNIC'	    	    ,'T01', 'Municipio'            ,			    		""						,30)
	AAdd( _CAMPTAB4, { "TMP_MUNIC"	, 'C', 30, 0 } )

	TRCell():New( oSection4, 'TMP_BAIRR'	    	    ,'T01', 'Bairro'            ,			    		""						,30)
	AAdd( _CAMPTAB4, { "TMP_BAIRR"	, 'C', 30, 0 } )

	TRCell():New( oSection4, 'TMP_END'	    	    ,'T01', 'Endereço'            ,			    		""						,60)
	AAdd( _CAMPTAB4, { "TMP_END"	, 'C', 60, 0 } )


	TRCell():New( oSection5, 'TMP_SETOR'		        ,'T01', 'Público/Privado'                  ,			    		""						,07)
	AAdd( _CAMPTAB5, { "TMP_SETOR"	, 'C', 07, 0 } )
	TRCell():New( oSection5, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_FILIAL"	, 'C', 06, 0 } )

	TRCell():New( oSection5, 'TMP_NCONTR'		        ,'T01', 'Número Contrato'                  ,			    		""						,15)
	AAdd( _CAMPTAB5, { "TMP_NCONTR"	, 'C', 15, 0 } )

	TRCell():New( oSection5, 'TMP_LOCAL'		            ,'T01', 'Local'               ,			    		""						,08)
	AAdd( _CAMPTAB5, { "TMP_LOCAL"	, 'C', 08, 0 } )

	TRCell():New( oSection5, 'TMP_DESLOC'		        ,'T01', 'Desc. Local'            ,				   		""						,40)
	AAdd( _CAMPTAB5, { "TMP_DESLOC"	, 'C', 40, 0 } )

	TRCell():New( oSection5, 'TMP_MUNIC'	    	    ,'T01', 'Municipio'            ,			    		""						,30)
	AAdd( _CAMPTAB5, { "TMP_MUNIC"	, 'C', 30, 0 } )

	TRCell():New( oSection5, 'TMP_QTDVEN'		        ,'T01', 'Qtd Contrato'        ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_QTDVEN"	, 'N', 06, 0 } )

	TRCell():New( oSection5, 'TMP_QTDALO'		        ,'T01', 'Qtd Alocado'        ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_QTDALO"	, 'N', 06, 0 } )

	TRCell():New( oSection5, 'TMP_QTDAUS'		        ,'T01', 'Qtd Ausente'        ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_QTDAUS"	, 'N', 06, 0 } )

	TRCell():New( oSection5, 'TMP_QTDSAL'		        ,'T01', 'Qtd Saldo'        ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_QTDSAL"	, 'N', 06, 0 } )

	TRCell():New( oSection5, 'TMP_VUNIT'		        ,'T01', 'Valor Unit.'            ,				   		""						,15)
	AAdd( _CAMPTAB5, { "TMP_VUNIT"	, 'N', 14, 2 } )

	TRCell():New( oSection5, 'TMP_VTOT'		        ,'T01', 'Valor Total'            ,				   		""						,15)
	AAdd( _CAMPTAB5, { "TMP_VTOT"	, 'N', 14, 2 } )

	TRCell():New( oSection5, 'TMP_VPGM'		        ,'T01', 'Vlr Alocado +'            ,				   		""						,15)
	AAdd( _CAMPTAB5, { "TMP_VPGM"	, 'N', 14, 2 } )

	TRCell():New( oSection5, 'TMP_VDFAT'		        ,'T01', 'Vlr não Alocado'            ,				   		""						,15)
	AAdd( _CAMPTAB5, { "TMP_VDFAT"	, 'N', 14, 2 } )

	TRCell():New( oSection5, 'TMP_STATUS'		        ,'T01', 'STATUS'            ,				   		""						,15)
	AAdd( _CAMPTAB5, { "TMP_STATUS"	, 'C', 15, 0 } )

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
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)
	Local oSection4 	:= oReport:Section(4)
	Local oSection5 	:= oReport:Section(5)


	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_NCONTR"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL","TMP_NCONTR","TMP_PROD"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_FILIAL","TMP_LOCAL","TMP_PROD"})
	oTempTab3:Create()
	(CALIAS3)->(dbGotop())

	oTempTab4:= FWTemporaryTable():New(CALIAS4)
	oTempTab4:SetFields(_CAMPTAB4)
	oTempTab4:AddIndex("1",{"TMP_FILIAL","TMP_LOCAL"})
	oTempTab4:Create()
	(CALIAS4)->(dbGotop())

	oTempTab5:= FWTemporaryTable():New(CALIAS5)
	oTempTab5:SetFields(_CAMPTAB5)
	oTempTab5:AddIndex("1",{"TMP_FILIAL","TMP_NCONTR","TMP_LOCAL"})
	oTempTab5:Create()
	(CALIAS5)->(dbGotop())


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

	DBSELECTAREA((CALIAS4))
	(CALIAS4)->(DBGOTOP())
	WHILE !(CALIAS4)->(EOF())
		oSection4:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB4)

			oSection4:Cell(_CAMPTAB4[nx,1]):SetValue( &((CALIAS4)+"->"+_CAMPTAB4[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection4:PrintLine()
		(CALIAS4)->(DBSKIP())
	ENDDO

	oSection4:Finish()


	DBSELECTAREA((CALIAS5))
	(CALIAS5)->(DBGOTOP())
	WHILE !(CALIAS5)->(EOF())
		oSection5:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB5)

			oSection5:Cell(_CAMPTAB5[nx,1]):SetValue( &((CALIAS5)+"->"+_CAMPTAB5[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection5:PrintLine()
		(CALIAS5)->(DBSKIP())
	ENDDO

	oSection5:Finish()


	oTempTab1:DELETE()
	oTempTab2:DELETE()
	oTempTab3:DELETE()
	oTempTab4:DELETE()
	oTempTab5:DELETE()

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




	cquery := " SELECT "
	cquery += " B1_CODISS, X5_DESCRI, AD1_SETOR, RCM_TIPO, RCM_DESCRI, R8_DATAFIM, R8_DATAINI, R8_DURACAO, TFF_FILIAL, TFF_QTDVEN, TFF_COD, TFF_CONTRT, AD1_DESCRI, TFF_ESCALA, TFF_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_BAIRRO, ABS_END, ABS_ESTADO, TFF_PRODUT, B1_DESC, TFF_PERICU, TFF_INSALU, TGY_ATEND, AA1_NOMTEC, TGY_ESCALA, TGY_DTINI, TGY_DTFIM, TGY_TIPALO, RA_SITFOLH, TFF_PRCVEN, TFF_PERINI, TFF_PERFIM  "
	cquery += " FROM "+RETSQLNAME("TFF")+" TFF "
	cquery += " INNER JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9.D_E_L_E_T_ = ' ' AND CN9_FILIAL = TFF_FILIAL AND CN9_NUMERO = TFF_CONTRT AND CN9_REVISA = TFF_CONREV AND CN9_REVATU = ' ' AND CN9_SITUAC <> '01' "
	cquery += " LEFT JOIN "+RETSQLNAME("TGY")+" TGY ON TGY.D_E_L_E_T_ = ' ' AND TGY_CODTFF = TFF_COD AND TGY_FILIAL = TFF_FILIAL AND TGY_DTFIM >= '"+DTOS(DDATABASE)+"' "
	cquery += " INNER JOIN "+RETSQLNAME("TFL")+" TFL ON TFL.D_E_L_E_T_ = ' ' AND TFL_CODIGO = TFF_CODPAI AND TFL_FILIAL = TFF_FILIAL AND TFL_TOTRH > 500 "
	cquery += " INNER JOIN "+RETSQLNAME("TFJ")+" TFJ ON TFJ.D_E_L_E_T_ = ' ' AND TFJ_CODIGO = TFL_CODPAI AND TFJ_FILIAL = TFL_FILIAL "
	cquery += " INNER JOIN "+RETSQLNAME("ADY")+" ADY ON ADY.D_E_L_E_T_ = ' ' AND ADY_PROPOS = TFJ_PROPOS AND ADY_FILIAL = TFJ_FILIAL "
	cquery += " INNER JOIN "+RETSQLNAME("AD1")+" AD1 ON AD1.D_E_L_E_T_ = ' ' AND AD1_NROPOR = ADY_OPORTU AND AD1_FILIAL = ADY_FILIAL "
	cquery += " LEFT JOIN "+RETSQLNAME("AA1")+" AA1 ON AA1.D_E_L_E_T_ = ' ' AND AA1_CODTEC = TGY_ATEND AND AA1_FILIAL = TGY_FILIAL "
	cquery += " INNER JOIN "+RETSQLNAME("ABS")+" ABS ON ABS.D_E_L_E_T_ = ' ' AND ABS_LOCAL = TFF_LOCAL AND ABS_FILIAL = ' ' "
	cquery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_COD = TFF_PRODUT AND B1_FILIAL = ' ' "
	cquery += " LEFT JOIN "+RETSQLNAME("SRA")+" SRA ON SRA.D_E_L_E_T_ = ' ' AND RA_FILIAL = SUBSTRING(TGY_ATEND,1,6) AND RA_MAT = SUBSTRING(TGY_ATEND,7,6) AND RA_SITFOLH <> 'D' "
	cquery += " LEFT JOIN "+RETSQLNAME("SR8")+" SR8 ON SR8.D_E_L_E_T_ = ' ' AND R8_FILIAL = SUBSTRING(TGY_ATEND,1,6) AND R8_MAT = SUBSTRING(TGY_ATEND,7,6) AND R8_DATAINI <= '"+DTOS(DDATABASE)+"' AND R8_DATAFIM >= '"+DTOS(DDATABASE)+"' "
	CQUERY += " LEFT JOIN "+RETSQLNAME("RCM")+" RCM ON RCM_TIPO = R8_TIPOAFA AND RCM_FILIAL = SUBSTRING(TGY_ATEND,1,2) AND RCM.D_E_L_E_T_ = ' ' "
	CQUERY += " LEFT JOIN "+RETSQLNAME("SX5")+" SX5 ON X5_CHAVE = B1_CODISS AND X5_FILIAL = ' ' AND SX5.D_E_L_E_T_ = ' ' AND X5_TABELA = '60'  "
	cquery += " WHERE "
	cquery += " TFF_FILIAL = '"+MV_PAR01+"' AND  "
	cquery += " TFF.D_E_L_E_T_ =' ' AND TFF_CODSUB = ' ' AND "
	cquery += " TFF_CONTRT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND "
	cquery += " TFF_PERINI BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' AND "
	cquery += " TFF_PERFIM BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"' AND "
	cquery += " TFF_ENCE <> '1' AND TFF_PRODUT <> 'SV11880001' "
	cquery += " ORDER BY TFF_FILIAL,TFF_COD,TFF_CONTRT,TFF_LOCAL,TFF_PRODUT "



	TcQuery cQuery New Alias T01
	DbSelectArea("T01")
	_chave := ""
	_chavecnt := ""
	_nqtdcnt := 0
	_chaveloc := ""
	_nqtdloc := 0
	_chavelXC := ""
	_nqtdlXC := 0
	_nvuLOC := 0
	_nvuCNT := 0
	_nvulXC := 0

	While !T01->(Eof())



		(CALIAS1)->(Reclock( CALIAS1, .T.))
		if _chave <> T01->TFF_FILIAL+T01->TFF_COD+T01->TFF_CONTRT+T01->TFF_LOCAL+T01->TFF_PRODUT


			//IF _chaveloc <> T01->TFF_FILIAL+T01->TFF_LOCAL+T01->TFF_PRODUT
			DBSELECTAREA((CALIAS3))
			DBSETORDER(1)
			IF DBSEEK(_chaveloc)
				(CALIAS3)->(Reclock((CALIAS3), .F.))

				(CALIAS3)->TMP_QTDVEN += _nqtdloc
				(CALIAS3)->TMP_QTDSAL := (CALIAS3)->TMP_QTDVEN - (CALIAS3)->TMP_QTDALO + (CALIAS3)->TMP_QTDAUS
				(CALIAS3)->TMP_VTOT += round(_nvuLOC*_nqtdloc,2)
				(CALIAS3)->TMP_VUNIT := (CALIAS3)->TMP_VTOT/(CALIAS3)->TMP_QTDVEN
				IF ALLTRIM((CALIAS3)->TMP_SETOR) == '1'
					if (CALIAS3)->TMP_QTDSAL > 0
						(CALIAS3)->TMP_VDFAT := (CALIAS3)->TMP_QTDSAL * (CALIAS3)->TMP_VUNIT
					ENDIF
					if (CALIAS3)->TMP_QTDSAL < 0
						(CALIAS3)->TMP_VPGM := abs((CALIAS3)->TMP_QTDSAL) * (CALIAS3)->TMP_VUNIT
					ENDIF
				ELSE
					if ((CALIAS3)->TMP_QTDVEN - (CALIAS3)->TMP_QTDALO) > 0
						(CALIAS3)->TMP_VDFAT := ((CALIAS3)->TMP_QTDVEN - (CALIAS3)->TMP_QTDALO) * (CALIAS3)->TMP_VUNIT
					ENDIF
					if ((CALIAS3)->TMP_QTDVEN - (CALIAS3)->TMP_QTDALO) < 0
						(CALIAS3)->TMP_VPGM := abs((CALIAS3)->TMP_QTDVEN - (CALIAS3)->TMP_QTDALO) * (CALIAS3)->TMP_VUNIT
					ENDIF
				ENDIF
				if (CALIAS3)->TMP_QTDSAL <> 0
					(CALIAS3)->TMP_STATUS := "JUSTIFICAR"
				ELSE
					(CALIAS3)->TMP_STATUS := "JUSTIFICADO"
				endif
			ENDIF

			_chaveloc := T01->TFF_FILIAL+T01->TFF_LOCAL+T01->TFF_PRODUT
			_nqtdloc := T01->TFF_QTDVEN
			_nmeSLOC := (DateDiffDay(stod(T01->TFF_PERINI),stod(T01->TFF_PERFIM)))/30
			_nvuLOC  := round(T01->TFF_PRCVEN/_nmeSLOC,2)
			//ENDIF
			//IF _chavecnt <> T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_PRODUT
			DBSELECTAREA((CALIAS2))
			DBSETORDER(1)
			IF DBSEEK(_chavecnt)
				(CALIAS2)->(Reclock((CALIAS2), .F.))

				(CALIAS2)->TMP_QTDVEN += _nqtdcnt
				(CALIAS2)->TMP_QTDSAL := (CALIAS2)->TMP_QTDVEN - (CALIAS2)->TMP_QTDALO + (CALIAS2)->TMP_QTDAUS

				(CALIAS2)->TMP_VTOT += round(_nvuCNT*_nqtdcnt,2)
				(CALIAS2)->TMP_VUNIT := (CALIAS2)->TMP_VTOT/(CALIAS2)->TMP_QTDVEN


				IF ALLTRIM((CALIAS2)->TMP_SETOR) == '1'
					if (CALIAS2)->TMP_QTDSAL > 0
						(CALIAS2)->TMP_VDFAT := (CALIAS2)->TMP_QTDSAL * (CALIAS2)->TMP_VUNIT
					ENDIF
					if (CALIAS2)->TMP_QTDSAL < 0
						(CALIAS2)->TMP_VPGM := abs((CALIAS2)->TMP_QTDSAL) * (CALIAS2)->TMP_VUNIT
					ENDIF
				ELSE
					if ((CALIAS2)->TMP_QTDVEN - (CALIAS2)->TMP_QTDALO) > 0
						(CALIAS2)->TMP_VDFAT := ((CALIAS2)->TMP_QTDVEN - (CALIAS2)->TMP_QTDALO) * (CALIAS2)->TMP_VUNIT
					ENDIF
					if ((CALIAS2)->TMP_QTDVEN - (CALIAS2)->TMP_QTDALO) < 0
						(CALIAS2)->TMP_VPGM := abs((CALIAS2)->TMP_QTDVEN - (CALIAS2)->TMP_QTDALO) * (CALIAS2)->TMP_VUNIT
					ENDIF
				ENDIF

				if (CALIAS2)->TMP_QTDSAL <> 0
					(CALIAS2)->TMP_STATUS := "JUSTIFICAR"
				ELSE
					(CALIAS2)->TMP_STATUS := "JUSTIFICADO"
				endif
			ENDIF
			_chavecnt := T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_PRODUT
			_nqtdcnt := T01->TFF_QTDVEN
			_nmeScnt := (DateDiffDay(stod(T01->TFF_PERINI),stod(T01->TFF_PERFIM)))/30
			_nvucnt  := round(T01->TFF_PRCVEN/_nmeScnt,2)
			//ENDIF

			DBSELECTAREA((CALIAS5))
			DBSETORDER(1)
			IF DBSEEK(_chavelXC)
				(CALIAS5)->(Reclock((CALIAS5), .F.))

				(CALIAS5)->TMP_QTDVEN += _nqtdlXC
				(CALIAS5)->TMP_QTDSAL := (CALIAS5)->TMP_QTDVEN - (CALIAS5)->TMP_QTDALO + (CALIAS5)->TMP_QTDAUS
				(CALIAS5)->TMP_VTOT += round(_nvulXC*_nqtdlXC,2)
				(CALIAS5)->TMP_VUNIT := (CALIAS5)->TMP_VTOT/(CALIAS5)->TMP_QTDVEN


				IF ALLTRIM((CALIAS5)->TMP_SETOR) == '1'
					if (CALIAS5)->TMP_QTDSAL > 0
						(CALIAS5)->TMP_VDFAT := (CALIAS5)->TMP_QTDSAL * (CALIAS5)->TMP_VUNIT
					ENDIF
					if (CALIAS5)->TMP_QTDSAL < 0
						(CALIAS5)->TMP_VPGM := abs((CALIAS5)->TMP_QTDSAL) * (CALIAS5)->TMP_VUNIT
					ENDIF
				ELSE
					if ((CALIAS5)->TMP_QTDVEN - (CALIAS5)->TMP_QTDALO) > 0
						(CALIAS5)->TMP_VDFAT := ((CALIAS5)->TMP_QTDVEN - (CALIAS5)->TMP_QTDALO) * (CALIAS5)->TMP_VUNIT
					ENDIF
					if ((CALIAS5)->TMP_QTDVEN - (CALIAS5)->TMP_QTDALO) < 0
						(CALIAS5)->TMP_VPGM := abs((CALIAS5)->TMP_QTDVEN - (CALIAS5)->TMP_QTDALO) * (CALIAS5)->TMP_VUNIT
					ENDIF
				ENDIF

				if (CALIAS5)->TMP_QTDSAL <> 0
					(CALIAS5)->TMP_STATUS := "JUSTIFICAR"
				ELSE
					(CALIAS5)->TMP_STATUS := "JUSTIFICADO"
				endif
			ENDIF
			_chavelXC := T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_LOCAL
			_nqtdlXC := T01->TFF_QTDVEN
			_nmeSlXC := (DateDiffDay(stod(T01->TFF_PERINI),stod(T01->TFF_PERFIM)))/30
			_nvulXC  := round(T01->TFF_PRCVEN/_nmeSlXC,2)

			_chave := T01->TFF_FILIAL+T01->TFF_COD+T01->TFF_CONTRT+T01->TFF_LOCAL+T01->TFF_PRODUT




		endif



		//TFF_PRCVEN, TFF_PERINI, TFF_PERFIM
		//TMP_VPGM
		//TMP_VDFAT
		(CALIAS1)->TMP_SETOR   :=T01->AD1_SETOR
		(CALIAS1)->TMP_FILIAL   :=T01->TFF_FILIAL
		(CALIAS1)->TMP_COD   :=T01->TFF_COD
		(CALIAS1)->TMP_NCONTR := T01->TFF_CONTRT
		(CALIAS1)->TMP_NOME := T01->AD1_DESCRI
		(CALIAS1)->TMP_ESCAL := T01->TFF_ESCALA
		(CALIAS1)->TMP_LOCAL := T01->TFF_LOCAL
		(CALIAS1)->TMP_DESLOC := T01->ABS_DESCRI
		(CALIAS1)->TMP_MUNIC := T01->ABS_MUNIC
		(CALIAS1)->TMP_PROD := T01->TFF_PRODUT
		(CALIAS1)->TMP_DESPRO := T01->B1_DESC
		(CALIAS1)->TMP_CNAE := T01->B1_CODISS
		(CALIAS1)->TMP_DESCNA := T01->X5_DESCRI
		//(CALIAS1)->TMP_PERIC := T01->TFF_PERICU
		IF (T01->TFF_PERICU == "1")
			(CALIAS1)->TMP_PERIC := "NAO POSSUI"
		ELSEIF (T01->TFF_PERICU == "2")
			(CALIAS1)->TMP_PERIC := "INTEGRAL"
		ELSEIF (T01->TFF_PERICU == "3")
			(CALIAS1)->TMP_PERIC :="PROPORCIONAL"
		ENDIF

		//(CALIAS1)->TMP_INSALU := T01->TFF_INSALU
		IF (T01->TFF_INSALU == "1")
			(CALIAS1)->TMP_INSALU := "NENHUMA"
		ELSEIF (T01->TFF_INSALU == "2")
			(CALIAS1)->TMP_INSALU := "MINIMA"
		ELSEIF (T01->TFF_INSALU == "3")
			(CALIAS1)->TMP_INSALU := "MEDIA"
		ELSEIF (T01->TFF_INSALU == "4")
			(CALIAS1)->TMP_INSALU := "MAXIMA"
		ENDIF
		(CALIAS1)->TMP_CODATE := T01->TGY_ATEND
		(CALIAS1)->TMP_NOMATE  := T01->AA1_NOMTEC
		(CALIAS1)->TMP_SITFOL := T01->RA_SITFOLH
		(CALIAS1)->TMP_DTINI := stod(T01->TGY_DTINI)
		(CALIAS1)->TMP_DTFIM := stod(T01->TGY_DTFIM)
		(CALIAS1)->TMP_TPMOV := T01->TGY_TIPALO
		(CALIAS1)->TMP_CODAUS :=  T01->RCM_TIPO
		(CALIAS1)->TMP_DESAUS := T01->RCM_DESCRI
		(CALIAS1)->TMP_DATAIN := STOD(T01->R8_DATAINI)
		(CALIAS1)->TMP_DATAFI := STOD(T01->R8_DATAFIM)
		_nmeS := (DateDiffDay(stod(T01->TFF_PERINI),stod(T01->TFF_PERFIM)))/30
		_nvul  := round(T01->TFF_PRCVEN/_nmeS,2)
		(CALIAS1)->TMP_VUNIT := _nvul
//TMP_QTDVEN,TMP_QTDALO,TMP_QTDSAL
		DBSELECTAREA((CALIAS2))
		DBSETORDER(1)
		IF DBSEEK(T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_PRODUT)
			(CALIAS2)->(Reclock( (CALIAS2), .F.))
			if !empty(T01->TGY_ATEND)
				(CALIAS2)->TMP_QTDALO   += 1
			endif
			if !empty(T01->RCM_TIPO)
				(CALIAS2)->TMP_QTDAUS   += 1
			Endif
		ELSE
			(CALIAS2)->(Reclock( (CALIAS2), .T.))
			(CALIAS2)->TMP_SETOR   :=T01->AD1_SETOR
			(CALIAS2)->TMP_FILIAL := T01->TFF_FILIAL
			(CALIAS2)->TMP_NCONTR := T01->TFF_CONTRT
			(CALIAS2)->TMP_PROD := T01->TFF_PRODUT
			(CALIAS2)->TMP_DESPRO := T01->B1_DESC
			(CALIAS2)->TMP_CNAE := T01->B1_CODISS
			(CALIAS2)->TMP_DESCNA := T01->X5_DESCRI

			if !empty(T01->TGY_ATEND)
				(CALIAS2)->TMP_QTDALO   := 1
			endif
			if !empty(T01->RCM_TIPO)
				(CALIAS2)->TMP_QTDAUS   := 1
			Endif


		ENDIF

		DBSELECTAREA((CALIAS3))
		DBSETORDER(1)
		IF DBSEEK(T01->TFF_FILIAL+T01->TFF_LOCAL+T01->TFF_PRODUT)
			(CALIAS3)->(Reclock((CALIAS3), .F.))
			if !empty(T01->TGY_ATEND)
				(CALIAS3)->TMP_QTDALO   += 1
			endif
			if !empty(T01->RCM_TIPO)
				(CALIAS3)->TMP_QTDAUS   += 1
			Endif

		ELSE
			(CALIAS3)->(Reclock( (CALIAS3), .T.))
			(CALIAS3)->TMP_SETOR   :=T01->AD1_SETOR
			(CALIAS3)->TMP_FILIAL := T01->TFF_FILIAL
			(CALIAS3)->TMP_LOCAL := T01->TFF_LOCAL
			(CALIAS3)->TMP_DESLOC := T01->ABS_DESCRI
			(CALIAS3)->TMP_MUNIC := T01->ABS_MUNIC
			(CALIAS3)->TMP_PROD := T01->TFF_PRODUT
			(CALIAS3)->TMP_DESPRO := T01->B1_DESC
			(CALIAS3)->TMP_CNAE := T01->B1_CODISS
			(CALIAS3)->TMP_DESCNA := T01->X5_DESCRI
			if !empty(T01->TGY_ATEND)
				(CALIAS3)->TMP_QTDALO   := 1
			endif
			if !empty(T01->RCM_TIPO)
				(CALIAS3)->TMP_QTDAUS   := 1
			Endif

		ENDIF

		DBSELECTAREA((CALIAS4))
		DBSETORDER(1)
		IF DBSEEK(T01->TFF_FILIAL+T01->TFF_LOCAL)

		ELSE
			(CALIAS4)->(Reclock( (CALIAS4), .T.))
			(CALIAS4)->TMP_SETOR   :=T01->AD1_SETOR
			(CALIAS4)->TMP_FILIAL := T01->TFF_FILIAL
			(CALIAS4)->TMP_LOCAL := T01->TFF_LOCAL
			(CALIAS4)->TMP_DESLOC := T01->ABS_DESCRI
			(CALIAS4)->TMP_MUNIC := T01->ABS_MUNIC
			(CALIAS4)->TMP_BAIRR := T01->ABS_BAIRRO
			(CALIAS4)->TMP_END := T01->ABS_END
			(CALIAS4)->TMP_EST := T01->ABS_ESTADO

		ENDIF

		DBSELECTAREA((CALIAS5))
		DBSETORDER(1)
		IF DBSEEK(T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_LOCAL)
			(CALIAS5)->(Reclock((CALIAS5), .F.))
			if !empty(T01->TGY_ATEND)
				(CALIAS5)->TMP_QTDALO   += 1
			endif
			if !empty(T01->RCM_TIPO)
				(CALIAS5)->TMP_QTDAUS   += 1
			Endif

		ELSE
			(CALIAS5)->(Reclock( (CALIAS5), .T.))
			(CALIAS5)->TMP_SETOR   :=T01->AD1_SETOR
			(CALIAS5)->TMP_FILIAL := T01->TFF_FILIAL
			(CALIAS5)->TMP_LOCAL := T01->TFF_LOCAL
			(CALIAS5)->TMP_DESLOC := T01->ABS_DESCRI
			(CALIAS5)->TMP_MUNIC := T01->ABS_MUNIC
			(CALIAS5)->TMP_NCONTR := T01->TFF_CONTRT

			if !empty(T01->TGY_ATEND)
				(CALIAS5)->TMP_QTDALO   := 1
			endif
			if !empty(T01->RCM_TIPO)
				(CALIAS5)->TMP_QTDAUS   := 1
			Endif

		ENDIF

		(CALIAS1)->(MsUnlock())

		T01->(DBSKIP())
	Enddo
	IF _chavecnt <> T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_PRODUT
		DBSELECTAREA((CALIAS2))
		DBSETORDER(1)
		IF DBSEEK(_chavecnt)
			(CALIAS2)->(Reclock((CALIAS2), .F.))

			(CALIAS2)->TMP_QTDVEN += _nqtdcnt
			(CALIAS2)->TMP_QTDSAL := (CALIAS2)->TMP_QTDVEN - (CALIAS2)->TMP_QTDALO + (CALIAS2)->TMP_QTDAUS
			if (CALIAS2)->TMP_QTDSAL <> 0
				(CALIAS2)->TMP_STATUS := "JUSTIFICAR"
			ELSE
				(CALIAS2)->TMP_STATUS := "JUSTIFICADO"
			endif
		ENDIF
		_chavecnt := T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_PRODUT
		//_nqtdcnt := T01->TFF_QTDVEN
	ENDIF
	IF _chaveloc <> T01->TFF_FILIAL+T01->TFF_LOCAL+T01->TFF_PRODUT
		DBSELECTAREA((CALIAS3))
		DBSETORDER(1)
		IF DBSEEK(_chaveloc)
			(CALIAS3)->(Reclock((CALIAS3), .F.))

			(CALIAS3)->TMP_QTDVEN += _nqtdloc
			(CALIAS3)->TMP_QTDSAL := (CALIAS3)->TMP_QTDVEN - (CALIAS3)->TMP_QTDALO + (CALIAS3)->TMP_QTDAUS
			if (CALIAS3)->TMP_QTDSAL <> 0
				(CALIAS3)->TMP_STATUS := "JUSTIFICAR"
			ELSE
				(CALIAS3)->TMP_STATUS := "JUSTIFICADO"
			endif
		ENDIF

		_chaveloc := T01->TFF_FILIAL+T01->TFF_LOCAL+T01->TFF_PRODUT
		//_nqtdloc := T01->TFF_QTDVEN
	ENDIF

	IF _chavelXC <> T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_LOCAL
		DBSELECTAREA((CALIAS5))
		DBSETORDER(1)
		IF DBSEEK(_chavelXC)
			(CALIAS5)->(Reclock((CALIAS5), .F.))

			(CALIAS5)->TMP_QTDVEN += _nqtdlXC
			(CALIAS5)->TMP_QTDSAL := (CALIAS5)->TMP_QTDVEN - (CALIAS5)->TMP_QTDALO + (CALIAS5)->TMP_QTDAUS
			if (CALIAS5)->TMP_QTDSAL <> 0
				(CALIAS5)->TMP_STATUS := "JUSTIFICAR"
			ELSE
				(CALIAS5)->TMP_STATUS := "JUSTIFICADO"
			endif
		ENDIF

		_chavelXC := T01->TFF_FILIAL+T01->TFF_CONTRT+T01->TFF_LOCAL
		//_nqtdloc := T01->TFF_QTDVEN
	ENDIF

	T01->( dbCloseArea() )



Return
