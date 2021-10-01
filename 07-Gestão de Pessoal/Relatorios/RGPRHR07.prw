#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR07()

	Private oReport
	Private cPergCont	:= PadR('RGPRHR07' ,10)
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

	oReport := TReport():New( 'Tabela Funcionários', 'Tabela Funcionários', cPergCont, {|oReport| ReportPrint( oReport ), 'Tabela Funcionários' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Funcionários', { 'SRA'})
	//oSection2 := TRSection():New( oReport, 'Filial', { 'SRA'})
	//oSection3 := TRSection():New( oReport, 'Centro de Custo', { 'SRA'})
	//oSection4 := TRSection():New( oReport, 'Empresa', { 'SRA'})

	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_NOME'		            ,'T01', 'Nome Func'               ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NOME"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_CPF'		        	,'T01', 'CPF'                     ,				   		""						,14)
	AAdd( _CAMPTAB1, { "TMP_CPF"	, 'C', 14, 0 } )
	TRCell():New( oSection1, 'TMP_NOMEM'		            ,'T01', 'Nome Mãe'               ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NOMEM"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_CC'	    	        ,'T01', 'Centro de Custo'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_CC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_DESCCC'	    	    ,'T01', 'Desc CC'                 ,			    		""						,40)
	AAdd( _CAMPTAB1, { "TMP_DESCCC"	, 'C', 40, 0 } )
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
	TRCell():New( oSection1, 'TMP_CBO'		        	,'T01', 'CBO'                     ,				   		""						,06)
	AAdd( _CAMPTAB1, { "TMP_CBO"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_RG'	    	        ,'T01', 'RG'                      , 			    	""						,15)
	AAdd( _CAMPTAB1, { "TMP_RG"	, 'C', 15, 0 } )
	TRCell():New( oSection1, 'TMP_TELEFO'		        ,'T01', 'Telefone'                ,				   		""						,10)
	AAdd( _CAMPTAB1, { "TMP_TELEFO"	, 'C', 10, 0 } )
	TRCell():New( oSection1, 'TMP_PIS'	    	        ,'T01', 'PIS'                     ,			    		""						,11)
	AAdd( _CAMPTAB1, { "TMP_PIS"	, 'C', 11, 0 } )
	TRCell():New( oSection1, 'TMP_TURNO'	    	    ,'T01', 'Turno'                   ,			    		""						,03)
	AAdd( _CAMPTAB1, { "TMP_TURNO"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_DESCTU'	    	    ,'T01', 'Desc. Turno'             ,			    		""						,20)
	AAdd( _CAMPTAB1, { "TMP_DESCTU"	, 'C', 20, 0 } )
	TRCell():New( oSection1, 'TMP_SITUAC'		        ,'T01', 'Situação'                ,				    	""						,01)
	AAdd( _CAMPTAB1, { "TMP_SITUAC"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_DEMISS'		        ,'T01', 'Data Demissão'            ,				   		""						,08)
	AAdd( _CAMPTAB1, { "TMP_DEMISS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DEFFIS'	    	    ,'T01', 'Deficiente Físico'       ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_DEFFIS"	, 'C', 01, 0 } )
	TRCell():New( oSection1, 'TMP_APOSEN'	    	    ,'T01', 'Aposentado'         ,			    		""						,01)
	AAdd( _CAMPTAB1, { "TMP_APOSEN"	, 'C', 01, 0 } )


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




	cQuery := " SELECT * FROM "+RETSQLNAME("SR6")+" R6,  "+RETSQLNAME("SRJ")+" RJ, "+RETSQLNAME("SRA")+" RA, "+RETSQLNAME("CTT")+" CTT WHERE R6_FILIAL = SUBSTRING(RA_FILIAL,1,2)  AND RJ_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2)  AND CTT.D_E_L_E_T_ = ' ' AND   R6.D_E_L_E_T_ = ' ' AND RJ.D_E_L_E_T_ = ' ' AND RA.D_E_L_E_T_ = ' ' AND "
	cQuery += " SUBSTRING(RA_FILIAL,1,2) = '"+mv_par01+"' AND RA_AFASFGT NOT IN ('N1','N2') AND RA_CATFUNC <> 'A'  AND CTT_CUSTO BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND CTT_CUSTO = RA_CC AND RJ_FUNCAO = RA_CODFUNC AND R6_TURNO = RA_TNOTRAB "
	cQuery += " ORDER BY RA_FILIAL, RA_CC, RA_MAT, RA_NOME "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())





		_ALINHA := {}

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->RA_FILIAL+T01->RA_MAT

		(CALIAS1)->TMP_FILIAL   :=T01->RA_FILIAL
		(CALIAS1)->TMP_MATRIC := T01->RA_MAT
		(CALIAS1)->TMP_NOME := T01->RA_NOME
		(CALIAS1)->TMP_NOMEM := T01->RA_MAE
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
		(CALIAS1)->TMP_CPF := T01->RA_CIC
		(CALIAS1)->TMP_CBO := T01->RJ_CODCBO
		(CALIAS1)->TMP_RG := T01->RA_RG
		(CALIAS1)->TMP_TELEFO := T01->RA_TELEFON
		(CALIAS1)->TMP_PIS := T01->RA_PIS
		(CALIAS1)->TMP_TURNO := T01->RA_TNOTRAB
		(CALIAS1)->TMP_DESCTU := T01->R6_DESC
		(CALIAS1)->TMP_SITUAC := T01->RA_SITFOLH
		(CALIAS1)->TMP_DEFFIS := IIF(T01->RA_DEFIFIS="1","SIM","NAO")
		(CALIAS1)->TMP_APOSEN := IIF(T01->RA_EAPOSEN=='1',"SIM","NAO")

		T01->( dbSkip() )
	ENDDO



	(CALIAS1)->(MsUnlock())




	T01->( dbCloseArea() )



Return
