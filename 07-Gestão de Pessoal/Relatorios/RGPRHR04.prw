#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RGPRHR04()

	Private oReport
	Private cPergCont	:= "RGPRHR04"
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
	PRIVATE	_CAMPTAB6 := {}
	PRIVATE cAlias6			:= GetNextAlias()
	PRIVATE oTempTab6
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

	oReport := TReport():New( 'Relatório Ficha Funcionário', 'Relatório Ficha Funcionário', cPergCont, {|oReport| ReportPrint( oReport ), 'Relatório Ficha Funcionário' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Funcionários', { 'SRA'})
	oSection2 := TRSection():New( oReport, 'Férias Pendentes', { 'SRA'})
	oSection3 := TRSection():New( oReport, 'Ausências', { 'SRA'})
	oSection4 := TRSection():New( oReport, 'Disciplina', { 'SRA'})
	oSection5 := TRSection():New( oReport, 'Transferências CC', { 'SRA'})
	oSection6 := TRSection():New( oReport, 'Função', { 'SRA'})



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
	TRCell():New( oSection1, 'TMP_SALARI'	    	    ,'T01', 'Salario base'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_SALARI"	, 'N', 14, 2 } )

	TRCell():New( oSection2, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_PERAQU'	    	    ,'T01', 'Período Aquisitivo'        ,			    		""						,25)
	AAdd( _CAMPTAB2, { "TMP_PERAQU"	, 'C', 25, 0 } )
	TRCell():New( oSection2, 'TMP_QTDLIM'		    	,'T01', 'Qtd. Limite'             ,						""                      ,03)
	AAdd( _CAMPTAB2, { "TMP_QTDLIM"	, 'N', 03, 0 } )
	TRCell():New( oSection2, 'TMP_DTLIM'		        ,'T01', 'Data Limite'            ,				   		""						,08)
	AAdd( _CAMPTAB2, { "TMP_DTLIM"	, 'D', 08, 0 } )
	TRCell():New( oSection2, 'TMP_STATUS'	    	    ,'T01', 'Status'        ,			    		""						,25)
	AAdd( _CAMPTAB2, { "TMP_STATUS"	, 'C', 25, 0 } )
	TRCell():New( oSection2, 'TMP_BASE'	    	    ,'T01', 'Valor Projetado'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_BASE"	, 'N', 14, 2 } )


	TRCell():New( oSection3, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_DESC'		        ,'T01', 'Desc Ausência'               ,			    		""						,40)
	AAdd( _CAMPTAB3, { "TMP_DESC"	, 'C', 40, 0 } )
	TRCell():New( oSection3, 'TMP_COMPE'		        ,'T01', 'Competência'               ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_COMPE"	, 'C', 6, 0 } )
	TRCell():New( oSection3, 'TMP_DTINI'		        ,'T01', 'Data Inicial'            ,				   		""						,08)
	AAdd( _CAMPTAB3, { "TMP_DTINI"	, 'D', 08, 0 } )
	TRCell():New( oSection3, 'TMP_DTFIM'		        ,'T01', 'Data Final'            ,				   		""						,08)
	AAdd( _CAMPTAB3, { "TMP_DTFIM"	, 'D', 08, 0 } )
	TRCell():New( oSection3, 'TMP_QTDDIA'		    	,'T01', 'Qtd. Duração'             ,						""                      ,04)
	AAdd( _CAMPTAB3, { "TMP_QTDDIA"	, 'N', 04, 0 } )
	TRCell():New( oSection3, 'TMP_QTDEMP'		    	,'T01', 'Qtd. Empresa'             ,						""                      ,04)
	AAdd( _CAMPTAB3, { "TMP_QTDEMP"	, 'N', 04, 0 } )


	TRCell():New( oSection4, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection4, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection4, 'TMP_DESC'		            ,'T01', 'Desc Disciplina'               ,			    		""						,40)
	AAdd( _CAMPTAB4, { "TMP_DESC"	, 'C', 40, 0 } )
	TRCell():New( oSection4, 'TMP_MOTIVO'		            ,'T01', 'Motivo Disciplina'               ,			    		""						,40)
	AAdd( _CAMPTAB4, { "TMP_MOTIVO"	, 'C', 40, 0 } )
	TRCell():New( oSection4, 'TMP_LOCAL'		            ,'T01', 'Local'               ,			    		""						,40)
	AAdd( _CAMPTAB4, { "TMP_LOCAL"	, 'C', 40, 0 } )
	TRCell():New( oSection4, 'TMP_DATA'		        ,'T01', 'Data'            ,				   		""						,08)
	AAdd( _CAMPTAB4, { "TMP_DATA"	, 'D', 08, 0 } )
	TRCell():New( oSection4, 'TMP_QTDDIA'		    	,'T01', 'Qtd. Dias'             ,						""                      ,04)
	AAdd( _CAMPTAB4, { "TMP_QTDDIA"	, 'N', 04, 0 } )

	TRCell():New( oSection5, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection5, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_MATRIC"	, 'C', 06, 0 } )
	TRCell():New( oSection5, 'TMP_DATA'		            ,'T01', 'Data Transferência'            ,				   		""						,08)
	AAdd( _CAMPTAB5, { "TMP_DATA"	, 'D', 08, 0 } )
	TRCell():New( oSection5, 'TMP_DESC'		            ,'T01', 'Centro custo'               ,			    		""						,40)
	AAdd( _CAMPTAB5, { "TMP_DESC"	, 'C', 40, 0 } )
	TRCell():New( oSection5, 'TMP_MODULO'		            ,'T01', 'Centro custo'               ,			    		""						,10)
	AAdd( _CAMPTAB5, { "TMP_MODULO"	, 'C', 10, 0 } )

	TRCell():New( oSection6, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB6, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection6, 'TMP_MATRIC'		        ,'T01', 'Matricula'               ,			    		""						,06)
	AAdd( _CAMPTAB6, { "TMP_MATRIC"	, 'C', 06, 0 } )
	//TRCell():New( oSection6, 'TMP_DATA'		            ,'T01', 'Data Transferência'            ,				   		""						,08)
	//AAdd( _CAMPTAB6, { "TMP_DATA"	, 'D', 08, 0 } )
	TRCell():New( oSection6, 'TMP_DESC'		            ,'T01', 'Função'               ,			    		""						,40)
	AAdd( _CAMPTAB6, { "TMP_DESC"	, 'C', 40, 0 } )


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
	Local oSection6 	:= oReport:Section(6)

	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab3:Create()
	(CALIAS3)->(dbGotop())

	oTempTab4:= FWTemporaryTable():New(CALIAS4)
	oTempTab4:SetFields(_CAMPTAB4)
	oTempTab4:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab4:Create()
	(CALIAS4)->(dbGotop())

	oTempTab5:= FWTemporaryTable():New(CALIAS5)
	oTempTab5:SetFields(_CAMPTAB5)
	oTempTab5:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab5:Create()
	(CALIAS5)->(dbGotop())

	oTempTab6:= FWTemporaryTable():New(CALIAS6)
	oTempTab6:SetFields(_CAMPTAB6)
	oTempTab6:AddIndex("1",{"TMP_FILIAL","TMP_MATRIC"})
	oTempTab6:Create()
	(CALIAS6)->(dbGotop())


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

	DBSELECTAREA((CALIAS6))
	(CALIAS6)->(DBGOTOP())
	WHILE !(CALIAS6)->(EOF())
		oSection6:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB6)

			oSection6:Cell(_CAMPTAB6[nx,1]):SetValue( &((CALIAS6)+"->"+_CAMPTAB6[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection6:PrintLine()
		(CALIAS6)->(DBSKIP())
	ENDDO

	oSection6:Finish()


	oTempTab1:DELETE()
	oTempTab2:DELETE()
	oTempTab3:DELETE()
	oTempTab4:DELETE()
	oTempTab5:DELETE()
	oTempTab6:DELETE()


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




	DBSELECTAREA("SRA")
	DBSETORDER(1)
	IF DBSEEK(MV_PAR01+MV_PAR02)
		_cpf := SRA->RA_CIC
		(CALIAS1)->(Reclock( CALIAS1, .T.))

		(CALIAS1)->TMP_FILIAL   :=SRA->RA_FILIAL
		(CALIAS1)->TMP_MATRIC := SRA->RA_MAT
		(CALIAS1)->TMP_NOME := SRA->RA_NOME
		(CALIAS1)->TMP_SITFOL := SRA->RA_SITFOLH
		(CALIAS1)->TMP_CC := SRA->RA_CC
		(CALIAS1)->TMP_DESCCC := POSICIONE("CTT",1,SUBSTR(SRA->RA_FILIAL,1,2)+"    "+SRA->RA_CC,"CTT_DESC01")
		(CALIAS1)->TMP_FUNC := SRA->RA_CODFUNC
		(CALIAS1)->TMP_DESCFU := POSICIONE("SRJ",1,SUBSTR(SRA->RA_FILIAL,1,2)+"    "+SRA->RA_CODFUNC,"RJ_DESC")
		(CALIAS1)->TMP_ADMISS := SRA->RA_ADMISSA

		(CALIAS1)->(MsUnlock())
	ENDIF


	cQuery := " SELECT RA_SITFOLH,RA_ADMISSA,RA_SINDICA , RA_MAT , RA_FILIAL , RA_NOME , RA_CC ,RA_SALARIO ,RA_CODFUNC, RF_PD , RF_MAT , RF_FILIAL , RF_STATUS , RF_DATABAS , RF_DATAFIM , RF_DIASDIR, RCE_YMESLF, CTT_DESC01, RJ_DESC

	cQuery += " FROM "+RETSQLNAME("SRA")+"  SRA
	cQuery += " INNER JOIN "+RETSQLNAME("SRF")+" SRF ON RF_FILIAL = RA_FILIAL AND RF_MAT = RA_MAT AND RF_STATUS = '1' AND SRF.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RETSQLNAME("SRJ")+" SRJ ON RJ_FILIAL  = SUBSTRING(RA_FILIAL,1,2) AND RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RETSQLNAME("RCE")+" RCE ON RCE_FILIAL = '"+XFILIAL("RCE")+"' AND RCE_CODIGO = RA_SINDICA AND RCE.D_E_L_E_T_ = ''
	cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ''
	cQuery += " WHERE
	cQuery += " SRA.RA_FILIAL = '"+ MV_PAR01 +"' "
	cQuery += " AND SRA.RA_MAT = '"+ MV_PAR02 +"' "
	cQuery += " AND SRA.D_E_L_E_T_=''
	cQuery += " ORDER BY RA_CC , RA_NOME


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())


		(CALIAS2)->(Reclock( CALIAS2, .T.))

		_chave := T01->RA_FILIAL+T01->RA_MAT
		(CALIAS2)->TMP_FILIAL   :=T01->RA_FILIAL
		(CALIAS2)->TMP_MATRIC := T01->RA_MAT
		(CALIAS2)->TMP_PERAQU := DTOC(STOD(T01->RF_DATABAS))+"-"+DTOC(STOD(T01->RF_DATAFIM))
		(CALIAS2)->TMP_QTDLIM := T01->RCE_YMESLF
		(CALIAS2)->TMP_DTLIM  := (MonthSum(STOD(T01->RF_DATAFIM)+1,T01->RCE_YMESLF))
		if (MonthSum(STOD(T01->RF_DATAFIM)+1,T01->RCE_YMESLF))-1 < ddatabase
			(CALIAS2)->TMP_STATUS := "Vencida"
		else
			(CALIAS2)->TMP_STATUS := "No prazo"
		endif



		(CALIAS2)->(MsUnlock())

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )

	cQuery := " SELECT R8_TIPOAFA, RCM_DESCRI, R8_FILIAL, R8_MAT, R8_DATAINI, R8_DATAFIM, R8_DURACAO, R8_DIASEMP, R8_SEQ FROM "+RETSQLNAME("SR8")+" R8 "
	cQuery += " INNER JOIN "+RETSQLNAME("RCM")+" RCM ON RCM_FILIAL = SUBSTRING(R8_FILIAL,1,2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = ' '  "
	cQuery += " WHERE R8_FILIAL = '"+MV_PAR01+"' AND R8_MAT = '"+MV_PAR02+"' AND R8.D_E_L_E_T_ = ' '  ORDER BY R8_FILIAL, R8_MAT, R8_DATAINI "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS3)->(Reclock( CALIAS3, .T.))

		(CALIAS3)->TMP_FILIAL := MV_PAR01
		(CALIAS3)->TMP_MATRIC := MV_PAR02
		(CALIAS3)->TMP_DESC := T01->RCM_DESCRI
		(CALIAS3)->TMP_DTINI := STOD(T01->R8_DATAINI)
		(CALIAS3)->TMP_DTFIM := STOD(T01->R8_DATAFIM)
		(CALIAS3)->TMP_QTDDIA := T01->R8_DURACAO
		(CALIAS3)->TMP_QTDEMP := T01->R8_DIASEMP

		(CALIAS3)->(MsUnlock())
		T01->(DBSKIP())
	Enddo
	T01->( dbCloseArea() )


	cQuery := " SELECT RD_PERIODO, SUM(RD_HORAS) DIAS FROM "+RETSQLNAME("SRD")+" RD "
	cQuery += " WHERE RD_FILIAL = '"+MV_PAR01+"' AND RD_PD = '201' AND RD_MAT = '"+MV_PAR02+"' AND RD.D_E_L_E_T_ = ' '  GROUP BY RD_PERIODO "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS3)->(Reclock( CALIAS3, .T.))

		(CALIAS3)->TMP_FILIAL := MV_PAR01
		(CALIAS3)->TMP_MATRIC := MV_PAR02
		(CALIAS3)->TMP_DESC  := "FALTA"
		(CALIAS3)->TMP_COMPE := T01->RD_PERIODO
		(CALIAS3)->TMP_QTDDIA := T01->DIAS
		(CALIAS3)->TMP_QTDEMP := 0

		(CALIAS3)->(MsUnlock())
		T01->(DBSKIP())
	Enddo
	T01->( dbCloseArea() )

	cQuery := " SELECT TIT_QTDDIA, TIT_CODTIQ, TIQ_DESCR, TIS_DESCRI, TIT_DATA, TIT_CODTEC, TIT_CODABS, ABS_DESCRI FROM "+RETSQLNAME("TIT")+" TIT "
	cQuery += " INNER JOIN "+RETSQLNAME("TIQ")+" TIQ ON TIQ_FILIAL = ' '  AND TIQ_CODIGO = TIT_CODTIQ AND TIQ.D_E_L_E_T_ = ' '  "
	cQuery += " INNER JOIN "+RETSQLNAME("TIS")+" TIS ON TIS_FILIAL = ' '  AND TIS_CODIGO = TIT_CODTIS AND TIS.D_E_L_E_T_ = ' '  "
	cQuery += " INNER JOIN "+RETSQLNAME("ABS")+" ABS ON ABS_FILIAL = ' '  AND ABS_LOCAL = TIT_CODABS AND ABS.D_E_L_E_T_ = ' '  "
	cQuery += " WHERE TIT_FILIAL = '"+MV_PAR01+"' AND TIT_CODTEC = '"+MV_PAR01+MV_PAR02+"' AND TIT.D_E_L_E_T_ = ' '  ORDER BY TIT_FILIAL, TIT_CODTEC, TIT_DATA "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS4)->(Reclock( CALIAS4, .T.))

		(CALIAS4)->TMP_FILIAL := MV_PAR01
		(CALIAS4)->TMP_MATRIC := MV_PAR02
		(CALIAS4)->TMP_DESC := T01->TIQ_DESCR
		(CALIAS4)->TMP_MOTIVO := T01->TIS_DESCRI
		(CALIAS4)->TMP_LOCAL := T01->ABS_DESCRI
		(CALIAS4)->TMP_DATA := stod(T01->TIT_DATA)
		(CALIAS4)->TMP_QTDDIA :=  T01->TIT_QTDDIA

		(CALIAS4)->(MsUnlock())
		T01->(DBSKIP())
	Enddo
	T01->( dbCloseArea() )

	cQuery := " SELECT RE_FILIALP, RE_MATP, RE_DATA, RE_CCP FROM "+RETSQLNAME("SRE")+" SRE "
	cQuery += " WHERE SUBSTRING(RE_FILIALP,1,6)+RE_MATP IN (SELECT RA_FILIAL+RA_MAT FROM "+RETSQLNAME("SRA")+" RA WHERE RA.D_E_L_E_T_ = ' ' AND RA_CIC = '"+_CPF+"' GROUP BY RA_FILIAL+RA_MAT ) AND SRE.D_E_L_E_T_ = ' '  ORDER BY RE_DATA, RE_FILIAL "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS5)->(Reclock( CALIAS5, .T.))

		(CALIAS5)->TMP_FILIAL := MV_PAR01
		(CALIAS5)->TMP_MATRIC := MV_PAR02
		(CALIAS5)->TMP_DESC := POSICIONE("CTT",1,SUBSTR(MV_PAR01,1,2)+"    "+T01->RE_CCP,"CTT_DESC01")
		(CALIAS5)->TMP_DATA := stod(T01->RE_DATA)
		(CALIAS5)->TMP_MODULO := "FOLHA"


		(CALIAS5)->(MsUnlock())
		T01->(DBSKIP())
	Enddo
	T01->( dbCloseArea() )

	cQuery := " SELECT ABB_CODTEC, ABB_LOCAL, TFL_YCC FROM "+RETSQLNAME("ABB")+" ABB "
	cQuery += " INNER JOIN "+RETSQLNAME("TFL")+" TFL ON TFL_FILIAL = ABB_FILIAL AND TFL_LOCAL = ABB_LOCAL AND TFL_CONTRT =  SUBSTRING(ABB_IDCFAL,1,15) AND TFL.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE ABB_ATIVO = '1' AND ABB_FILIAL = '"+MV_PAR01+"' AND ABB_CODTEC = '"+MV_PAR01+MV_PAR02+"' AND ABB.D_E_L_E_T_ =' ' GROUP BY ABB_CODTEC, ABB_LOCAL,TFL_YCC "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS5)->(Reclock( CALIAS5, .T.))

		(CALIAS5)->TMP_FILIAL := MV_PAR01
		(CALIAS5)->TMP_MATRIC := MV_PAR02
		(CALIAS5)->TMP_DESC := POSICIONE("CTT",1,SUBSTR(MV_PAR01,1,2)+"    "+T01->TFL_YCC,"CTT_DESC01")
		(CALIAS5)->TMP_MODULO := "GS"

		(CALIAS5)->(MsUnlock())
		T01->(DBSKIP())
	Enddo
	T01->( dbCloseArea() )

	cQuery := " SELECT R7_FILIAL, R7_MAT, R7_FUNCAO, R7_DESCFUN FROM "+RETSQLNAME("SR7")+" SR7 "
	cQuery += " WHERE R7_FILIAL+R7_MAT IN (SELECT RA_FILIAL+RA_MAT FROM "+RETSQLNAME("SRA")+" RA WHERE RA.D_E_L_E_T_ = ' ' AND RA_CIC = '"+_CPF+"' GROUP BY RA_FILIAL+RA_MAT ) AND SR7.D_E_L_E_T_ = ' '  GROUP BY R7_FILIAL, R7_MAT, R7_FUNCAO, R7_DESCFUN "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS6)->(Reclock( CALIAS6, .T.))

		(CALIAS6)->TMP_FILIAL := MV_PAR01
		(CALIAS6)->TMP_MATRIC := MV_PAR02
		(CALIAS6)->TMP_DESC := T01->R7_DESCFUN
		//(CALIAS4)->TMP_DATA := T01->RE_DATA


		(CALIAS6)->(MsUnlock())
		T01->(DBSKIP())
	Enddo
	T01->( dbCloseArea() )

Return
