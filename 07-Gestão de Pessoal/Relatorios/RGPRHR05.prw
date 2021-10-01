#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR05()

	Private oReport
	Private cPergCont	:= PadR('RGPRHR05' ,10)
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
	Local oSection4
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'Gerencial Funcionários', 'Gerencial Funcionários', cPergCont, {|oReport| ReportPrint( oReport ), 'Gerencial Funcionários' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Funcionários', { 'SRA'})
	oSection2 := TRSection():New( oReport, 'Filial', { 'SRA'})
	oSection3 := TRSection():New( oReport, 'Centro de Custo', { 'SRA'})
	oSection4 := TRSection():New( oReport, 'Empresa', { 'SRA'})

	//Indicador Comprador
	TRCell():New( oSection1, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,15)
	AAdd( _CAMPTAB1, { "TMP_EMPRES"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,30)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 30, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCCC"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_FUNC'	    	        ,'T01', 'Função'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FUNC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_DESCFU'	    	    ,'T01', 'Desc. Função'            ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCFU"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_CATEG'	    	    ,'T01', 'Categoria'               ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_CATEG"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_NASC'		    	    ,'T01', 'Data Nasc.'              ,						""                      ,08)
	AAdd( _CAMPTAB1, { "TMP_NASC"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_IDADE'		        ,'T01', 'Idade'                   ,				   		""						,03)
	AAdd( _CAMPTAB1, { "TMP_IDADE"	, 'N', 03, 0 } )
	TRCell():New( oSection1, 'TMP_ADMISS'		        ,'T01', 'Data Admiss.'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_ADMISS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_TEMPOA'	    	    ,'T01', 'Tempo de Empresa'        ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_TEMPOA"	, 'N', 03, 0 } )
	TRCell():New( oSection1, 'TMP_SEXO'	    	        ,'T01', 'Sexo'                    ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_SEXO"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_ESTCIV'	    	    ,'T01', 'Estado Civil'            ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_ESTCIV"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_INSTRU'	    	    ,'T01', 'Cod. Instrução'          ,			    		""						,02)
	AAdd( _CAMPTAB1, { "TMP_INSTRU"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_DESCIN'	    	,'T01', 'Desc. Instrução'         ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCIN"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_QTDFIL'		    	,'T01', 'Qtd. Filhos'             ,						""                      ,03)
	AAdd( _CAMPTAB1, { "TMP_QTDFIL"	, 'N', 03, 0 } )
	TRCell():New( oSection1, 'TMP_CPF'		        	,'T01', 'CPF'                     ,				   		""						,14)
	AAdd( _CAMPTAB1, { "TMP_CPF"	, 'C', 14, 0 } )
	TRCell():New( oSection1, 'TMP_CBO'		        	,'T01', 'CBO'                     ,				   		""						,06)
	AAdd( _CAMPTAB1, { "TMP_CBO"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_RG'	    	        ,'T01', 'RG'                      , 			    	""						,15)
	AAdd( _CAMPTAB1, { "TMP_RG"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_ENDER'	    	    ,'T01', 'Endereço'                ,			    		""						,35)
	AAdd( _CAMPTAB1, { "TMP_ENDER"	, 'C', 35, 0 } )
	TRCell():New( oSection1, 'TMP_COMPEN'	    	    ,'T01', 'Complemento End.'        ,			    		""						,16)
	AAdd( _CAMPTAB1, { "TMP_COMPEN"	, 'C', 16, 0 } )
	TRCell():New( oSection1, 'TMP_BAIRRO'	    	    ,'T01', 'Bairro'                  ,			    		""						,16)
	AAdd( _CAMPTAB1, { "TMP_BAIRRO"	, 'C', 16, 0 } )
	TRCell():New( oSection1, 'TMP_MUNICI'	    	,'T01', 'Municipio'               ,			    		""						,16)
	AAdd( _CAMPTAB1, { "TMP_MUNICI"	, 'C', 16, 0 } )
	TRCell():New( oSection1, 'TMP_ESTADO'		    	,'T01', 'Estado'                  ,						""                      ,02)
	AAdd( _CAMPTAB1, { "TMP_ESTADO"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_CEP'		        	,'T01', 'CEP'                     ,				   		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CEP"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_TELEFO'		        ,'T01', 'Telefone'                ,				   		""						,10)
	AAdd( _CAMPTAB1, { "TMP_TELEFO"	, 'C', 10, 0 } )
	//TRCell():New( oSection1, 'TMP_POSTOT'	    	,'T01', 'Posto Trabalho'          ,			    		""						,16)
	//AAdd( _CAMPTAB1, { "TMP_POSTOT"	, 'C', 16, 0 } )
	TRCell():New( oSection1, 'TMP_CATGHO'	    	    ,'T01', 'Carga Horaria'           ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_CATGHO"	, 'N', 06, 0 } )
	TRCell():New( oSection1, 'TMP_PIS'	    	        ,'T01', 'PIS'                     ,			    		""						,11)
	AAdd( _CAMPTAB1, { "TMP_PIS"	, 'C', 11, 0 } )
	TRCell():New( oSection1, 'TMP_CTPS'	    	        ,'T01', 'Carteira Trab.'          ,			    		""						,10)
	AAdd( _CAMPTAB1, { "TMP_CTPS"	, 'C', 10, 0 } )
	TRCell():New( oSection1, 'TMP_SERCTP'	    	    ,'T01', 'Serie CTPS'              ,			    		""						,05)
	AAdd( _CAMPTAB1, { "TMP_SERCTP"	, 'C', 05, 0 } )
	TRCell():New( oSection1, 'TMP_UFCP'		        	,'T01', 'UF CTPS'                 ,				   		""						,02)
	AAdd( _CAMPTAB1, { "TMP_UFCP"	, 'C', 02, 0 } )
	TRCell():New( oSection1, 'TMP_TURNO'	    	    ,'T01', 'Turno'                   ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_TURNO"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DESCTU'	    	    ,'T01', 'Desc. Turno'             ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCTU"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_SIND'	    	        ,'T01', 'Cod. Sindicato'          ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_SIND"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DESCSI'	    	    ,'T01', 'Desc. Sindicato'         ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCSI"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_DTTERM'	    	,'T01', 'Data Termino Contrato'   ,			    		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTTERM"	, 'D', 08, 0 } )
	//TRCell():New( oSection1, 'TMP_SUBSTI'		    	,'T01', 'Substit'                 ,						""                      ,01)
	//AAdd( _CAMPTAB1, { "TMP_SUBSTI"	, 'C', 01, 0 } )
	//TRCell():New( oSection1, 'TMP_NOMESU'		    ,'T01', 'Nome Sobustit.'          ,				    	""						,40)
	//AAdd( _CAMPTAB1, { "TMP_NOMESU"	, 'C', 40, 0 } )
	TRCell():New( oSection1, 'TMP_SITUAC'		        ,'T01', 'Situação'                ,				    	""						,01)
	AAdd( _CAMPTAB1, { "TMP_SITUAC"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_DEMISS'		        ,'T01', 'Data Demissão'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DEMISS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_SITMP'		        ,'T01', 'Situação MP'                ,				    	""						,10)
	AAdd( _CAMPTAB1, { "TMP_SITMP"	, 'C', 10, 0 } )
	TRCell():New( oSection1, 'TMP_DTINMP'		        ,'T01', 'Data Ini. MP'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTINMP"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTFIMP'		        ,'T01', 'Data Fim MP'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DTFIMP"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_PERMP'	    	    ,'T01', 'Percen. MP%'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_PERMP"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_DEFFIS'	    	    ,'T01', 'Deficiente Físico'       ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_DEFFIS"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_APOSEN'	    	    ,'T01', 'Aposentado'         ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_APOSEN"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_SALARI'	    	    ,'T01', 'SALARIO CADASTRO'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_SALARI"	, 'N', 14, 2 } )




	//Indicador filial
	TRCell():New( oSection2, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,15)
	AAdd( _CAMPTAB2, { "TMP_EMPRES"	, 'C', 15, 0 } )

	TRCell():New( oSection2, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 15, 0 } )

	TRCell():New( oSection2, 'TMP_QTDFUN'		        ,'T01', 'Qtd Funcionários'        ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDFUN"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDEST'	            ,'T01', 'Qtd Estagiário'          ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDEST"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDMAP'	        ,'T01', 'Qtd Menor Aprendiz'      ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDMAP"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDDEF'	    	    ,'T01', 'Qtd PCDS'                ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDDEF"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDTEM'	   	        ,'T01', 'Qtd Temporarios'         ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDTEM"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_QTDAFA'	    	    ,'T01', 'Qtd Afastados'           ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_QTDAFA"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_FERIAS'	    	    ,'T01', 'Qtd Férias'           ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_FERIAS"	, 'N', 06, 0 } )

	TRCell():New( oSection2, 'TMP_SALARI'	    	    ,'T01', 'SALARIO CADASTRO'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_SALARI"	, 'N', 14, 2 } )



	//Indicador CC
	TRCell():New( oSection3, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,15)
	AAdd( _CAMPTAB3, { "TMP_EMPRES"	, 'C', 15, 0 } )

	TRCell():New( oSection3, 'TMP_CC'		        ,'T01', 'Centro de custo'                  ,			    		""						,30)
	AAdd( _CAMPTAB3, { "TMP_CC"	, 'C', 30, 0 } )

	TRCell():New( oSection3, 'TMP_QTDFUN'		        ,'T01', 'Qtd Funcionários'        ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDFUN"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDEST'	            ,'T01', 'Qtd Estagiário'          ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDEST"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDMAP'	        ,'T01', 'Qtd Menor Aprendiz'      ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDMAP"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDDEF'	    	    ,'T01', 'Qtd PCDS'                ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDDEF"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDTEM'	   	        ,'T01', 'Qtd Temporarios'         ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDTEM"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_QTDAFA'	    	    ,'T01', 'Qtd Afastados'           ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_QTDAFA"	, 'N', 06, 0 } )

	TRCell():New( oSection3, 'TMP_FERIAS'	    	    ,'T01', 'Qtd Férias'           ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_FERIAS"	, 'N', 06, 0 } )


	TRCell():New( oSection3, 'TMP_SALARI'	    	    ,'T01', 'SALARIO CADASTRO'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_SALARI"	, 'N', 14, 2 } )


	//Geral
	TRCell():New( oSection4, 'TMP_EMPRES'		    	,'T01', 'Empresa'                 ,						""                      ,15)
	AAdd( _CAMPTAB4, { "TMP_EMPRES"	, 'C', 15, 0 } )

	TRCell():New( oSection4, 'TMP_QTDFUN'		        ,'T01', 'Qtd Funcionários'        ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_QTDFUN"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_QTDEST'	            ,'T01', 'Qtd Estagiário'          ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_QTDEST"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_QTDMAP'	        ,'T01', 'Qtd Menor Aprendiz'      ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_QTDMAP"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_QTDDEF'	    	    ,'T01', 'Qtd PCDS'                ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_QTDDEF"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_QTDTEM'	   	        ,'T01', 'Qtd Temporarios'         ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_QTDTEM"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_QTDAFA'	    	    ,'T01', 'Qtd Afastados'           ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_QTDAFA"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_FERIAS'	    	    ,'T01', 'Qtd Férias'           ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_FERIAS"	, 'N', 06, 0 } )

	TRCell():New( oSection4, 'TMP_SALARI'	    	    ,'T01', 'SALARIO CADASTRO'         ,			    		""						,15)
	AAdd( _CAMPTAB4, { "TMP_SALARI"	, 'N', 14, 2 } )



	// voltar yrelger cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP , RV_YGERREL FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE RV_TIPOCOD = '1' AND  RV_FILIAL = '"+XFILIAL("SRV")+"' AND RD_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP,RV_YGERREL  "
	IF MV_PAR02 == 2
		cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP , RV_YGERREL FROM "+RETSQLNAME("SRC")+" RC, "+RETSQLNAME("SRV")+" RV WHERE SUBSTRING(RC_FILIAL,1,2) = '"+mv_par03+"' AND RV_TIPOCOD = '1' AND  RV_FILIAL = SUBSTRING(RC_FILIAL,1,2) AND RC_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RC.D_E_L_E_T_ = ' ' AND RC_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	ELSEIF MV_PAR02 == 1
		cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP , RV_YGERREL  FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE SUBSTRING(RD_FILIAL,1,2) = '"+mv_par03+"' AND  RV_TIPOCOD = '1' AND  RV_FILIAL = SUBSTRING(RD_FILIAL,1,2) AND RD_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	ENDIF
	TcQuery cQuery New Alias T01

	DbSelectArea("T01")

	While !T01->(Eof())
		IF (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. T01->RV_YGERREL = 'S')
		//IF (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. .t.) .AND. T01->RV_CODFOL <> '0006'
		
			Aadd( _averbper, {T01->RV_COD})
			TRCell():New( oSection1, "TMP_"+T01->RV_COD		    	,'T01', "P - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB1, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection2, "TMP_"+T01->RV_COD		    	,'T01', "P - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB2, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection3, "TMP_"+T01->RV_COD		    	,'T01', "P - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB3, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection4, "TMP_"+T01->RV_COD		    	,'T01', "P - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB4, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
		ENDIF
		T01->(DBSKIP())
	ENDDO
	T01->(DBCLOSEAREA())
	TRCell():New( oSection1,"TMP_VTOTRE"		    	    ,'T01',"Valor Total Proven."                 ,						""                      ,15)
	AAdd( _CAMPTAB1, { "TMP_VTOTRE"	, 'N', 14, 2 } )
	TRCell():New( oSection2,"TMP_VTOTRE"		        	,'T01', "Valor Total Proven."                ,						""                      ,15)
	AAdd( _CAMPTAB2, { "TMP_VTOTRE"	, 'N', 14, 2 } )
	TRCell():New( oSection3,"TMP_VTOTRE"		    	    ,'T01', "Valor Total Proven."                ,						""                      ,15)
	AAdd( _CAMPTAB3, {"TMP_VTOTRE"	, 'N', 14, 2 } )
	TRCell():New( oSection4,"TMP_VTOTRE"		    	    ,'T01', "Valor Total Proven."                ,						""                      ,15)
	AAdd( _CAMPTAB4, { "TMP_VTOTRE"	, 'N', 14, 2 } )


	// voltar yrelger cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE RV_TIPOCOD = '2' AND  RV_FILIAL = '"+XFILIAL("SRV")+"' AND RD_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	IF MV_PAR02 == 2
		cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL FROM "+RETSQLNAME("SRC")+" RC, "+RETSQLNAME("SRV")+" RV WHERE SUBSTRING(RC_FILIAL,1,2) = '"+mv_par03+"' AND  RV_TIPOCOD = '2' AND  RV_FILIAL = SUBSTRING(RC_FILIAL,1,2) AND RC_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RC.D_E_L_E_T_ = ' ' AND RC_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	ELSEIF MV_PAR02 == 1
		cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE SUBSTRING(RD_FILIAL,1,2) = '"+mv_par03+"' AND  RV_TIPOCOD = '2' AND  RV_FILIAL = SUBSTRING(RD_FILIAL,1,2) AND RD_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	ENDIF	
	TcQuery cQuery New Alias T01

	DbSelectArea("T01")

	While !T01->(Eof())
		IF (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. T01->RV_YGERREL = 'S')
		//IF (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. .T. ) .AND. T01->RV_CODFOL <> '0006'
			Aadd( _averbper, {T01->RV_COD})
			TRCell():New( oSection1, "TMP_"+T01->RV_COD		    	,'T01', "D - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB1, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection2, "TMP_"+T01->RV_COD		    	,'T01', "D - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB2, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection3, "TMP_"+T01->RV_COD		    	,'T01', "D - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB3, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection4, "TMP_"+T01->RV_COD		    	,'T01', "D - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB4, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
		ENDIF
		T01->(DBSKIP())
	ENDDO

	TRCell():New( oSection1,"TMP_VTOTDE"		    	    ,'T01',"Valor Total Descon."                 ,						""                      ,15)
	AAdd( _CAMPTAB1, { "TMP_VTOTDE"	, 'N', 14, 2 } )
	TRCell():New( oSection2,"TMP_VTOTDE"		        	,'T01', "Valor Total Descon."                ,						""                      ,15)
	AAdd( _CAMPTAB2, { "TMP_VTOTDE"	, 'N', 14, 2 } )
	TRCell():New( oSection3,"TMP_VTOTDE"		    	    ,'T01', "Valor Total Descon."                ,						""                      ,15)
	AAdd( _CAMPTAB3, {"TMP_VTOTDE"	, 'N', 14, 2 } )
	TRCell():New( oSection4,"TMP_VTOTDE"		    	    ,'T01', "Valor Total Descon."                ,						""                      ,15)
	AAdd( _CAMPTAB4, { "TMP_VTOTDE"	, 'N', 14, 2 } )


	TRCell():New( oSection1,"TMP_VTOTLI"		    	    ,'T01',"Valor Total Líquido"                 ,						""                      ,15)
	AAdd( _CAMPTAB1, { "TMP_VTOTLI"	, 'N', 14, 2 } )
	TRCell():New( oSection2,"TMP_VTOTLI"		        	,'T01', "Valor Total Líquido"                ,						""                      ,15)
	AAdd( _CAMPTAB2, { "TMP_VTOTLI"	, 'N', 14, 2 } )
	TRCell():New( oSection3,"TMP_VTOTLI"		    	    ,'T01', "Valor Total Líquido"                ,						""                      ,15)
	AAdd( _CAMPTAB3, {"TMP_VTOTLI"	, 'N', 14, 2 } )
	TRCell():New( oSection4,"TMP_VTOTLI"		    	    ,'T01', "Valor Total Líquido"                ,						""                      ,15)
	AAdd( _CAMPTAB4, { "TMP_VTOTLI"	, 'N', 14, 2 } )

	T01->(DBCLOSEAREA())

	// VOLTAR YRELGER cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE RV_TIPOCOD = '3' AND  RV_FILIAL = '"+XFILIAL("SRV")+"' AND RD_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	IF MV_PAR02 == 2
		cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL FROM "+RETSQLNAME("SRC")+" RC, "+RETSQLNAME("SRV")+" RV WHERE SUBSTRING(RC_FILIAL,1,2) = '"+mv_par03+"' AND  RV_TIPOCOD = '3' AND  RV_FILIAL = SUBSTRING(RC_FILIAL,1,2) AND RC_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RC.D_E_L_E_T_ = ' ' AND RC_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	ELSEIF MV_PAR02 == 1
		cQuery := "SELECT RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SRV")+" RV WHERE SUBSTRING(RD_FILIAL,1,2) = '"+mv_par03+"' AND  RV_TIPOCOD = '3' AND  RV_FILIAL = SUBSTRING(RD_FILIAL,1,2) AND RD_PD = RV_COD AND RV.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"'  GROUP BY RV_COD, RV_DESC, RV_CODFOL, RV_INCORP, RV_YGERREL  "
	ENDIF
	TcQuery cQuery New Alias T01

	DbSelectArea("T01")

	While !T01->(Eof())
		IF (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. T01->RV_YGERREL = 'S')
		//IF (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. .T. ) .AND. T01->RV_CODFOL <> '0006'
			Aadd( _averbper, {T01->RV_COD})
			TRCell():New( oSection1, "TMP_"+T01->RV_COD		    	,'T01', "B - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB1, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection2, "TMP_"+T01->RV_COD		    	,'T01', "B - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB2, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection3, "TMP_"+T01->RV_COD		    	,'T01', "B - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB3, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
			TRCell():New( oSection4, "TMP_"+T01->RV_COD		    	,'T01', "B - "+T01->RV_COD+" - "+ALLTRIM(T01->RV_DESC)                 ,						""                      ,15)
			AAdd( _CAMPTAB4, { "TMP_"+T01->RV_COD	, 'N', 14, 2 } )
		ENDIF
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
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)
	Local oSection4 	:= oReport:Section(4)
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
	oTempTab1:AddIndex("1",{"TMP_EMPRES","TMP_FILIAL","TMP_MATRIC"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_CC"})
	oTempTab3:Create()
	(CALIAS3)->(dbGotop())

	oTempTab4:= FWTemporaryTable():New(CALIAS4)
	oTempTab4:SetFields(_CAMPTAB4)
	oTempTab4:AddIndex("1",{"TMP_EMPRES"})
	oTempTab4:Create()
	(CALIAS4)->(dbGotop())

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

	oTempTab1:DELETE()
	oTempTab2:DELETE()
	oTempTab3:DELETE()
	oTempTab4:DELETE()

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


	IF MV_PAR02 == 2
		
		cQuery := " SELECT * FROM "+RETSQLNAME("SRC")+" RC, "+RETSQLNAME("SR6")+" R6,  "+RETSQLNAME("SRV")+" RV, "+RETSQLNAME("SRJ")+" RJ, "+RETSQLNAME("SRA")+" RA, "+RETSQLNAME("CTT")+" CTT WHERE R6_FILIAL = SUBSTRING(RA_FILIAL,1,2)  AND RJ_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RV_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RC_PD = RV_COD AND CTT.D_E_L_E_T_ = ' ' AND  RV.D_E_L_E_T_ = ' ' AND R6.D_E_L_E_T_ = ' ' AND RJ.D_E_L_E_T_ = ' ' AND RA.D_E_L_E_T_ = ' ' AND RC.D_E_L_E_T_ = ' ' AND RC_PERIODO = '"+MV_PAR01+"' AND "
		cQuery += " SUBSTRING(RC_FILIAL,1,2) = '"+mv_par03+"' AND RV_TIPOCOD IN ('1','2','3') AND RA_CATFUNC <> 'A' AND RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT AND CTT_CUSTO = RA_CC AND RJ_FUNCAO = RA_CODFUNC AND R6_TURNO = RA_TNOTRAB "
		cQuery += " ORDER BY RA_FILIAL, RA_CC, RA_MAT, RA_NOME, RV_TIPOCOD"
		
	ELSEIF MV_PAR02 = 1
		
		cQuery := " SELECT * FROM "+RETSQLNAME("SRD")+" RD, "+RETSQLNAME("SR6")+" R6,  "+RETSQLNAME("SRV")+" RV, "+RETSQLNAME("SRJ")+" RJ, "+RETSQLNAME("SRA")+" RA, "+RETSQLNAME("CTT")+" CTT WHERE R6_FILIAL = SUBSTRING(RA_FILIAL,1,2)  AND RJ_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RV_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RD_PD = RV_COD AND CTT.D_E_L_E_T_ = ' ' AND  RV.D_E_L_E_T_ = ' ' AND R6.D_E_L_E_T_ = ' ' AND RJ.D_E_L_E_T_ = ' ' AND RA.D_E_L_E_T_ = ' ' AND RD.D_E_L_E_T_ = ' ' AND RD_PERIODO = '"+MV_PAR01+"' AND "
		cQuery += " SUBSTRING(RD_FILIAL,1,2) = '"+mv_par03+"' AND RV_TIPOCOD IN ('1','2','3') AND RA_CATFUNC <> 'A' AND RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT AND CTT_CUSTO = RA_CC AND RJ_FUNCAO = RA_CODFUNC AND R6_TURNO = RA_TNOTRAB "
		cQuery += " ORDER BY RA_FILIAL, RA_CC, RA_MAT, RA_NOME, RV_TIPOCOD"
		
	ENDIF
	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())


		_NFilh  := 0
		QR_SRB := "SELECT COUNT(*) AS QTD FROM "
		QR_SRB += " "+RETSQLNAME("SRB")+"  "
		QR_SRB += "WHERE RB_FILIAL = '" + T01->RA_FILIAL + "' AND RB_MAT = '" + T01->RA_MAT + "' AND "
		QR_SRB += "RB_GRAUPAR = 'F' AND "
		QR_SRB += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(QR_SRB)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,QR_SRB),"QR_SRB",.F.,.T.)   
		_NFilh  := QR_SRB->QTD
		QR_SRB->(dbCloseArea())

		_DIASAFAST := 0
		QR_SR8 := "SELECT SUM(R8_DURACAO) QTD, R8_TIPOAFA, R8_PD,R8_DATAINI,R8_DATAFIM  FROM "
		QR_SR8 += " "+RETSQLNAME("SR8")+"  "
		QR_SR8 += "WHERE R8_FILIAL = '" + T01->RA_FILIAL + "' AND R8_MAT = '" + T01->RA_MAT + "' AND "
		QR_SR8 += " R8_DATAINI <= '"+MV_PAR01+"31' AND (R8_DATAFIM >= '"+MV_PAR01+"31' OR R8_DATAFIM = ' ') AND "
		QR_SR8 += "D_E_L_E_T_ = ' ' GROUP BY R8_TIPOAFA, R8_PD,R8_DATAINI,R8_DATAFIM "
		cQuery := ChangeQuery(QR_SR8)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,QR_SR8),"QR_SR8",.F.,.T.)   

		_DIASAFAST   := 0
		_DIASAFERIAS := 0
		_SITMP := ""
		_DTINIMP := STOD("")
		_DTFIMMP := STOD("")
		_PERCMP := 0
		WHILE !QR_SR8->(EOF())
			IF	QR_SR8->R8_TIPOAFA == '001'
				_DIASAFERIAS += QR_SR8->QTD
			ELSE
				_DIASAFAST += QR_SR8->QTD
			ENDIF
			IF QR_SR8->R8_PD = '544'
				_SITMP := "Suspenção"
				_DTINIMP := STOD(QR_SR8->R8_DATAINI)
				_DTFIMMP := STOD(QR_SR8->R8_DATAFIM)
				_PERCMP := 0
			ENDIF

			QR_SR8->(DBSKIP())
		ENDDO

		QR_SR8->(dbCloseArea())

		IF EMPTY(_SITMP)

			T50 := "SELECT * FROM "
			T50 += " "+RETSQLNAME("RGE")+"  "
			T50 += "WHERE RGE_FILIAL = '" + T01->RA_FILIAL + "' AND RGE_MAT = '" + T01->RA_MAT + "' AND D_E_L_E_T_ = ' ' AND RGE_PPE = '1' "

			cQuery := ChangeQuery(T50)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,T50),"T50",.F.,.T.)   
			IF !T50->(EOF())
				_SITMP := "Redução"
				_DTINIMP := STOD(T50->RGE_DATAIN)
				_DTFIMMP := STOD(T50->RGE_DATAFI)
				_PERCMP := 0

				QR_RCC := "SELECT * FROM "
				QR_RCC += " "+RETSQLNAME("RCC")+"  "
				QR_RCC += "WHERE RCC_FILIAL = '" + XFILIAL("RCC") + "' AND RCC_CODIGO = 'S061' AND D_E_L_E_T_ = ' ' AND SUBSTRING(RCC_CONTEU,1,2) = '"+T50->RGE_COD+"' "

				cQuery := ChangeQuery(QR_RCC)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,QR_RCC),"QR_RCC",.F.,.T.)   
				IF !QR_RCC->(EOF())
					_PERCMP := val(substr(QR_RCC->RCC_CONTEU,22,2))
				ENDIF
				QR_RCC->(dbCloseArea())
				
			ENDIF

			T50->(dbCloseArea())
		ENDIF

		_ALINHA := {}

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->RA_FILIAL+T01->RA_MAT
		(CALIAS1)->TMP_EMPRES  :=CEMPANT
		(CALIAS1)->TMP_FILIAL   :=T01->RA_FILIAL
		(CALIAS1)->TMP_MATRIC := T01->RA_MAT
		(CALIAS1)->TMP_NOME := T01->RA_NOME
		(CALIAS1)->TMP_CC := T01->RA_CC
		(CALIAS1)->TMP_DESCCC := T01->CTT_DESC01
		(CALIAS1)->TMP_FUNC := T01->RA_CODFUNC
		(CALIAS1)->TMP_DESCFU := T01->RJ_DESC
		(CALIAS1)->TMP_CATEG := T01->RA_CATFUNC
		(CALIAS1)->TMP_NASC := STOD(T01->RA_NASC)
		(CALIAS1)->TMP_IDADE := IIF(!EMPTY(T01->RA_NASC),DateDiffYear( STOD(T01->RA_NASC), ddatabase ),0)
		(CALIAS1)->TMP_ADMISS := STOD(T01->RA_ADMISSA)
		(CALIAS1)->TMP_DEMISS := STOD(T01->RA_DEMISSA)
		(CALIAS1)->TMP_TEMPOA := DateDiffYear( STOD(T01->RA_ADMISSA), ddatabase )
		(CALIAS1)->TMP_SEXO := T01->RA_SEXO
		(CALIAS1)->TMP_ESTCIV := T01->RA_ESTCIVI
		(CALIAS1)->TMP_INSTRU := T01->RA_GRINRAI
		(CALIAS1)->TMP_DESCIN := Retfield("SX5",1,xFilial("SX5")+"26"+T01->RA_GRINRAI,"SX5->X5_DESCRI")
		(CALIAS1)->TMP_QTDFIL := _NFilh
		(CALIAS1)->TMP_CPF := T01->RA_CIC
		(CALIAS1)->TMP_CBO := T01->RJ_CODCBO
		(CALIAS1)->TMP_RG := T01->RA_RG
		(CALIAS1)->TMP_ENDER := T01->RA_ENDEREC
		(CALIAS1)->TMP_COMPEN := T01->RA_COMPLEM
		(CALIAS1)->TMP_BAIRRO := T01->RA_BAIRRO
		(CALIAS1)->TMP_MUNICI := T01->RA_MUNICIP
		(CALIAS1)->TMP_ESTADO := T01->RA_ESTADO
		(CALIAS1)->TMP_CEP := T01->RA_CEP
		(CALIAS1)->TMP_TELEFO := T01->RA_TELEFON
		//(CALIAS1)->TMP_POSTOT := T01->RA_YDPOSTO
		(CALIAS1)->TMP_CATGHO := T01->RA_HRSMES
		(CALIAS1)->TMP_PIS := T01->RA_PIS
		(CALIAS1)->TMP_CTPS := T01->RA_NUMCP
		(CALIAS1)->TMP_SERCTP := T01->RA_SERCP
		(CALIAS1)->TMP_UFCP := T01->RA_UFCP
		(CALIAS1)->TMP_TURNO := T01->RA_TNOTRAB
		(CALIAS1)->TMP_DESCTU := T01->R6_DESC
		(CALIAS1)->TMP_SIND := T01->RA_SINDICA
		(CALIAS1)->TMP_DESCSI :=POSICIONE("RCE",1,XFILIAL("RCE")+T01->RA_SINDICA,"RCE_DESCRI")
		(CALIAS1)->TMP_DTTERM := STOD(T01->RA_DTFIMCT)
		//(CALIAS1)->TMP_SUBSTI := T01->RA_YSUBSTI
		//(CALIAS1)->TMP_NOMESU := T01->RA_YNOMANT
		(CALIAS1)->TMP_SITUAC := T01->RA_SITFOLH
		(CALIAS1)->TMP_SALARI := T01->RA_SALARIO
		(CALIAS1)->TMP_DEFFIS := IIF(T01->RA_DEFIFIS="1","SIM","NAO")
		(CALIAS1)->TMP_APOSEN := IIF(T01->RA_EAPOSEN=='1',"SIM","NAO")  
		(CALIAS1)->TMP_SITMP  := _SITMP
		(CALIAS1)->TMP_DTINMP := _DTINIMP
		(CALIAS1)->TMP_DTFIMP := _DTFIMMP
		(CALIAS1)->TMP_PERMP  := _PERCMP

		_NMAPR := 0
		_NESTG := 0
		_NDEF  := 0
		_NTEMP := 0
		_NAFAS := 0
		_NFERIAS := 0
		IF T01->RA_CATFUNC == 'E'
			_NESTG := 1
		ENDIF
		IF T01->RA_DEFIFIS == '1'
			_NDEF := 1
		ENDIF
		IF T01->RA_CATEFD == '103'
			_NMAPR := 1
		ENDIF

		IF !EMPTY(T01->RA_DTFIMCT)
			_NTEMP := 1
		ENDIF

		IF _DIASAFAST >= 15
			_NAFAS := 1
			(CALIAS1)->TMP_SITUAC := "A"
		ENDIF

		IF _DIASAFERIAS >= 10
			_NFERIAS := 1
			(CALIAS1)->TMP_SITUAC := "F"
		ENDIF
		DBSELECTAREA((CALIAS2))
		DBSETORDER(1)
		IF DBSEEK(IIF(MV_PAR02==2,T01->RC_FILIAL,T01->RD_FILIAL))
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
			(CALIAS2)->TMP_FILIAL := IIF(MV_PAR02==2,T01->RC_FILIAL,T01->RD_FILIAL)
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
		IF DBSEEK(IIF(MV_PAR02==2,T01->RC_CC,T01->RD_CC)+T01->CTT_DESC01)
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
			(CALIAS3)->TMP_CC := IIF(MV_PAR02==2,T01->RC_CC,T01->RD_CC)+T01->CTT_DESC01
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

		DBSELECTAREA((CALIAS4))
		DBSETORDER(1)
		IF DBSEEK(CEMPANT)
			(CALIAS4)->(Reclock( (CALIAS4), .F.))

			(CALIAS4)->TMP_QTDFUN   += 1	
			(CALIAS4)->TMP_QTDEST	+= _NESTG			
			(CALIAS4)->TMP_QTDMAP   += _NMAPR			
			(CALIAS4)->TMP_QTDDEF	+= _NDEF			
			(CALIAS4)->TMP_QTDTEM	+= _NTEMP	
			(CALIAS4)->TMP_QTDAFA += _NAFAS
			(CALIAS4)->TMP_FERIAS  += _NFERIAS
			(CALIAS4)->TMP_SALARI += T01->RA_SALARIO
		ELSE
			(CALIAS4)->(Reclock( (CALIAS4), .T.))

			(CALIAS4)->TMP_EMPRES := CEMPANT
			(CALIAS4)->TMP_QTDFUN := 1
			(CALIAS4)->TMP_QTDEST	:= _NESTG			
			(CALIAS4)->TMP_QTDMAP := _NMAPR			
			(CALIAS4)->TMP_QTDDEF	:= _NDEF			
			(CALIAS4)->TMP_QTDTEM	:= _NTEMP			
			(CALIAS4)->TMP_QTDAFA := _NAFAS
			(CALIAS4)->TMP_FERIAS  := _NFERIAS
			(CALIAS4)->TMP_SALARI := T01->RA_SALARIO
			//&((CALIAS4)+"->TMP_"+T01->RD_PD) := T01->RD_VALOR	
			//(CALIAS4)->TMP_VTOTRE := T01->RD_VALOR

		ENDIF


		_NMAPR := 0
		_NESTG := 0
		_NDEF  := 0
		_NTEMP := 0
		_NAFAS := 0
		_NFERIAS := 0
		WHILE _chave == T01->RA_FILIAL+T01->RA_MAT
			IF  (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. T01->RV_YGERREL = 'S')
			//IF  (T01->RV_CODFOL = '0031' .OR. T01->RV_CODFOL = '0032' .OR. T01->RV_CODFOL = '0033' .OR. T01->RV_CODFOL = '0219' .OR. T01->RV_INCORP = 'S' .OR. .T.) .AND. T01->RV_CODFOL <> '0006'
				IF T01->RV_TIPOCOD == '1'
					(CALIAS1)->TMP_VTOTRE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS1)->TMP_VTOTLI += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ELSEIF T01->RV_TIPOCOD == '2'
					(CALIAS1)->TMP_VTOTDE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS1)->TMP_VTOTLI -= IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ENDIF
				&((CALIAS1)+"->TMP_"+IIF(MV_PAR02==2,T01->RC_PD,T01->RD_PD)) += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				IF T01->RV_TIPOCOD == '1'
					(CALIAS2)->TMP_VTOTRE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS2)->TMP_VTOTLI += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ELSEIF T01->RV_TIPOCOD == '2'
					(CALIAS2)->TMP_VTOTDE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS2)->TMP_VTOTLI -= IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ENDIF
				&((CALIAS2)+"->TMP_"+IIF(MV_PAR02==2,T01->RC_PD,T01->RD_PD)) += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				IF T01->RV_TIPOCOD == '1'
					(CALIAS3)->TMP_VTOTRE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS3)->TMP_VTOTLI += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ELSEIF T01->RV_TIPOCOD == '2'
					(CALIAS3)->TMP_VTOTDE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS3)->TMP_VTOTLI -= IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ENDIF
				&((CALIAS3)+"->TMP_"+IIF(MV_PAR02==2,T01->RC_PD,T01->RD_PD)) += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				IF T01->RV_TIPOCOD == '1'
					(CALIAS4)->TMP_VTOTRE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS4)->TMP_VTOTLI += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ELSEIF T01->RV_TIPOCOD == '2'
					(CALIAS4)->TMP_VTOTDE += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
					(CALIAS4)->TMP_VTOTLI -= IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)
				ENDIF
				&((CALIAS4)+"->TMP_"+IIF(MV_PAR02==2,T01->RC_PD,T01->RD_PD)) += IIF(MV_PAR02==2,T01->RC_VALOR,T01->RD_VALOR)

			ENDIF
			T01->( dbSkip() )
		ENDDO



		(CALIAS1)->(MsUnlock())

	Enddo


	T01->( dbCloseArea() )



Return
