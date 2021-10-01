#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RFINR02()

	Private oReport
	Private cPergCont  := "RFINR02"
	PRIVATE	_CAMPTAB1  := {}
	PRIVATE cAlias1	   := GetNextAlias()
	PRIVATE oTempTab1

	PRIVATE	_CAMPTAB2 := {}
	PRIVATE cAlias2	  := GetNextAlias()
	PRIVATE oTempTab2
	PRIVATE	_CAMPTAB3 := {}
	PRIVATE cAlias3	  := GetNextAlias()
	PRIVATE oTempTab3

	PRIVATE	_CAMPTAB4 := {}
	PRIVATE cAlias4	  := GetNextAlias()
	PRIVATE oTempTab4

	PRIVATE	_CAMPTAB5 := {}
	PRIVATE cAlias5	  := GetNextAlias()
	PRIVATE oTempTab5

	PRIVATE	_CAMPTAB6 := {}
	PRIVATE cAlias6	  := GetNextAlias()
	PRIVATE oTempTab6

	PRIVATE	_CAMPTAB7 := {}
	PRIVATE cAlias7	  := GetNextAlias()
	PRIVATE oTempTab7
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
	Local oSection6
	Local oSection7
	//Local oBreak
	//Local oFunctio
	//Local aOrdem:={}

	oReport := TReport():New( 'PMP_PMR_PM1R', 'PMP_PMR_PM1R', cPergCont, {|oReport| ReportPrint( oReport ), 'PMP_PMR_PM1R' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'PMP - Fornecedores', { 'SE2'})
	oSection2 := TRSection():New( oReport, 'PMP - Naturezas', { 'SE2'})
	oSection3 := TRSection():New( oReport, 'PMR - CLiente', { 'SE1'})
	oSection4 := TRSection():New( oReport, 'PMR - Naturezas', { 'SE1'})
	oSection5 := TRSection():New( oReport, 'PM1R - CLiente', { 'SE1'})
	oSection6 := TRSection():New( oReport, 'PM1R - Naturezas', { 'SE1'})
	oSection7 := TRSection():New( oReport, 'Indicadores', { 'SE1'})



	TRCell():New( oSection1, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection1, 'TMP_FORNEC'	    	        ,'T01', 'Cod Fornecedor'         ,			    		""						,09)
	AAdd( _CAMPTAB1, { "TMP_FORNEC"	, 'C', 09, 0 } )
	TRCell():New( oSection1, 'TMP_NOMFOR'	    	    ,'T01', 'Nome fornecedor'                 ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NOMFOR"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_NATURE'	    	    ,'T01', 'Natureza'                 ,			    		""						,50)
	AAdd( _CAMPTAB1, { "TMP_NATURE"	, 'C', 50, 0 } )
	TRCell():New( oSection1, 'TMP_PMP'	    	    ,'T01', 'PMP'         ,			    		""						,15)
	AAdd( _CAMPTAB1, { "TMP_PMP"	, 'N', 05, 0 } )
	TRCell():New( oSection1, 'TMP_VTOT'	    	    ,'T01', 'PMP'         ,			    		""						,16)
	AAdd( _CAMPTAB1, { "TMP_VTOT"	, 'N', 16, 2 } )

	TRCell():New( oSection2, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB2, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection2, 'TMP_NATURE'	    	    ,'T01', 'Natureza'                 ,			    		""						,50)
	AAdd( _CAMPTAB2, { "TMP_NATURE"	, 'C', 50, 0 } )
	TRCell():New( oSection2, 'TMP_PMP'	    	    ,'T01', 'PMP'         ,			    		""						,15)
	AAdd( _CAMPTAB2, { "TMP_PMP"	, 'N', 05, 0 } )
	TRCell():New( oSection2, 'TMP_VTOT'	    	    ,'T01', 'PMP'         ,			    		""						,16)
	AAdd( _CAMPTAB2, { "TMP_VTOT"	, 'N', 16, 2 } )

	TRCell():New( oSection3, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB3, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection3, 'TMP_CLIENT'	    	        ,'T01', 'Cod CLIENTE'         ,			    		""						,09)
	AAdd( _CAMPTAB3, { "TMP_CLIENT"	, 'C', 09, 0 } )
	TRCell():New( oSection3, 'TMP_NOMCLI'	    	    ,'T01', 'Nome CLIENTE'                 ,			    		""						,50)
	AAdd( _CAMPTAB3, { "TMP_NOMCLI"	, 'C', 50, 0 } )
	TRCell():New( oSection3, 'TMP_NATURE'	    	    ,'T01', 'Natureza'                 ,			    		""						,50)
	AAdd( _CAMPTAB3, { "TMP_NATURE"	, 'C', 50, 0 } )
	TRCell():New( oSection3, 'TMP_PMR'	    	    ,'T01', 'PMP'         ,			    		""						,15)
	AAdd( _CAMPTAB3, { "TMP_PMR"	, 'N', 05, 0 } )
	TRCell():New( oSection3, 'TMP_VTOT'	    	    ,'T01', 'PMP'         ,			    		""						,16)
	AAdd( _CAMPTAB3, { "TMP_VTOT"	, 'N', 16, 2 } )

	TRCell():New( oSection4, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB4, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection4, 'TMP_NATURE'	    	    ,'T01', 'Natureza'                 ,			    		""						,50)
	AAdd( _CAMPTAB4, { "TMP_NATURE"	, 'C', 50, 0 } )
	TRCell():New( oSection4, 'TMP_PMR'	    	    ,'T01', 'PMP'         ,			    		""						,15)
	AAdd( _CAMPTAB4, { "TMP_PMR"	, 'N', 05, 0 } )
	TRCell():New( oSection4, 'TMP_VTOT'	    	    ,'T01', 'PMP'         ,			    		""						,16)
	AAdd( _CAMPTAB4, { "TMP_VTOT"	, 'N', 16, 2 } )

	TRCell():New( oSection5, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB5, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection5, 'TMP_CLIENT'	    	        ,'T01', 'Cod CLIENTE'         ,			    		""						,09)
	AAdd( _CAMPTAB5, { "TMP_CLIENT"	, 'C', 09, 0 } )
	TRCell():New( oSection5, 'TMP_NOMCLI'	    	    ,'T01', 'Nome CLIENTE'                 ,			    		""						,50)
	AAdd( _CAMPTAB5, { "TMP_NOMCLI"	, 'C', 50, 0 } )
	TRCell():New( oSection5, 'TMP_CONTRA'	    	        ,'T01', 'Contrato'         ,			    		""						,15)
	AAdd( _CAMPTAB5, { "TMP_CONTRA"	, 'C', 15, 0 } )
	TRCell():New( oSection5, 'TMP_DTINI'	    	    ,'T01', 'Data Inic. '                 ,			    		""						,08)
	AAdd( _CAMPTAB5, { "TMP_DTINI"	, 'D', 08, 0 } )
	TRCell():New( oSection5, 'TMP_DT1P'	    	    ,'T01', 'Data 1 Parcela '                 ,			    		""						,08)
	AAdd( _CAMPTAB5, { "TMP_DT1P"	, 'D', 08, 0 } )
	TRCell():New( oSection5, 'TMP_PMR'	    	    ,'T01', 'PMR'         ,			    		""						,15)
	AAdd( _CAMPTAB5, { "TMP_PMR"	, 'N', 05, 0 } )
//	TRCell():New( oSection5, 'TMP_VTOT'	    	    ,'T01', 'PMR'         ,			    		""						,16)
//	AAdd( _CAMPTAB5, { "TMP_VTOT"	, 'N', 16, 2 } )

	TRCell():New( oSection6, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB6, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection6, 'TMP_NATURE'	    	    ,'T01', 'Natureza'                 ,			    		""						,50)
	AAdd( _CAMPTAB6, { "TMP_NATURE"	, 'C', 50, 0 } )
	TRCell():New( oSection6, 'TMP_PMR'	    	    ,'T01', 'PMR'         ,			    		""						,15)
	AAdd( _CAMPTAB6, { "TMP_PMR"	, 'N', 05, 0 } )
	TRCell():New( oSection6, 'TMP_VTOT'	    	    ,'T01', 'PMR'         ,			    		""						,16)
	AAdd( _CAMPTAB6, { "TMP_VTOT"	, 'N', 16, 2 } )

	TRCell():New( oSection7, 'TMP_FILIAL'		        ,'T01', 'Filial'                  ,			    		""						,06)
	AAdd( _CAMPTAB7, { "TMP_FILIAL"	, 'C', 06, 0 } )
	TRCell():New( oSection7, 'TMP_INDIC'	    	        ,'T01', 'INDICADOR'         ,			    		""						,04)
	AAdd( _CAMPTAB7, { "TMP_INDIC"	, 'C', 04, 0 } )
	TRCell():New( oSection7, 'TMP_VALOR'	    	    ,'T01', 'Valor'         ,			    		""						,15)
	AAdd( _CAMPTAB7, { "TMP_VALOR"	, 'N', 05, 0 } )
	TRCell():New( oSection7, 'TMP_VTOT'	    	    ,'T01', 'PMP'         ,			    		""						,16)
	AAdd( _CAMPTAB7, { "TMP_VTOT"	, 'N', 16, 2 } )

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
	Local oSection7 	:= oReport:Section(7)

	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_FORNEC"})
	oTempTab1:Create()
	(CALIAS1)->(dbGotop())

	oTempTab2:= FWTemporaryTable():New(CALIAS2)
	oTempTab2:SetFields(_CAMPTAB2)
	oTempTab2:AddIndex("1",{"TMP_FILIAL","TMP_NATURE"})
	oTempTab2:Create()
	(CALIAS2)->(dbGotop())

	oTempTab3:= FWTemporaryTable():New(CALIAS3)
	oTempTab3:SetFields(_CAMPTAB3)
	oTempTab3:AddIndex("1",{"TMP_FILIAL","TMP_CLIENT"})
	oTempTab3:Create()
	(CALIAS3)->(dbGotop())

	oTempTab4:= FWTemporaryTable():New(CALIAS4)
	oTempTab4:SetFields(_CAMPTAB4)
	oTempTab4:AddIndex("1",{"TMP_FILIAL","TMP_NATURE"})
	oTempTab4:Create()
	(CALIAS4)->(dbGotop())

	oTempTab5:= FWTemporaryTable():New(CALIAS5)
	oTempTab5:SetFields(_CAMPTAB5)
	oTempTab5:AddIndex("1",{"TMP_FILIAL","TMP_CLIENT"})
	oTempTab5:Create()
	(CALIAS5)->(dbGotop())

	oTempTab6:= FWTemporaryTable():New(CALIAS6)
	oTempTab6:SetFields(_CAMPTAB6)
	oTempTab6:AddIndex("1",{"TMP_FILIAL","TMP_NATURE"})
	oTempTab6:Create()
	(CALIAS6)->(dbGotop())

	oTempTab7:= FWTemporaryTable():New(CALIAS7)
	oTempTab7:SetFields(_CAMPTAB7)
	oTempTab7:AddIndex("1",{"TMP_FILIAL","TMP_INDIC"})
	oTempTab7:Create()
	(CALIAS7)->(dbGotop())

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


	DBSELECTAREA((CALIAS7))
	(CALIAS7)->(DBGOTOP())
	WHILE !(CALIAS7)->(EOF())
		oSection7:Init()
		oReport:IncMeter()

		For nx := 1 to Len(_CAMPTAB7)

			oSection7:Cell(_CAMPTAB7[nx,1]):SetValue( &((CALIAS7)+"->"+_CAMPTAB7[nx,1]) )
			//oSection1:Cell("Nomecomp"):SetAlign("LEFT")
		NEXT
		oSection7:PrintLine()
		(CALIAS7)->(DBSKIP())
	ENDDO

	oSection7:Finish()


	oTempTab1:DELETE()
	oTempTab2:DELETE()
	oTempTab3:DELETE()
	oTempTab4:DELETE()
	oTempTab5:DELETE()
	oTempTab6:DELETE()
	oTempTab7:DELETE()

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


	CQUERY := " SELECT ED_CODIGO , ED_DESCRIC, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NOMFOR, SUM(E2_VALOR) VTOT, SUM(DATEDIFF(DAY,CONVERT(DATE, E2_EMISSAO, 103),CONVERT(DATE, E2_VENCREA, 103) ))/COUNT(*) AS MEDIA_DIAS "
	CQUERY += " FROM "+RETSQLNAME("SE2")+" E2 "
	CQUERY += " INNER JOIN "+RETSQLNAME("SED")+" ED ON ED_FILIAL = ' ' AND ED_CODIGO = E2_NATUREZ AND ED.D_E_L_E_T_ = ' '  "
	CQUERY += " WHERE E2_FILIAL = '"+MV_PAR01+"' AND E2.D_E_L_E_T_ = ' ' AND E2_TIPO NOT IN ('NDF','PA','PR') AND E2_VENCREA < '"+DTOS(DDATABASE-360)+"' "
	CQUERY += " GROUP BY ED_CODIGO , ED_DESCRIC, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_NOMFOR "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")
	_NCONT   := 0
	_NMDDIAS := 0
	While !T01->(Eof())

		(CALIAS1)->(Reclock( CALIAS1, .T.))

		_chave := T01->E2_FILIAL+T01->E2_FORNECE+T01->E2_LOJA
		(CALIAS1)->TMP_FILIAL  :=  T01->E2_FILIAL
		(CALIAS1)->TMP_FORNEC  :=  T01->E2_FORNECE+" - "+T01->E2_LOJA
		(CALIAS1)->TMP_NOMFOR  :=  T01->E2_NOMFOR
		(CALIAS1)->TMP_NATURE  :=  T01->ED_CODIGO +" - "+ T01->ED_DESCRIC
		(CALIAS1)->TMP_PMP     :=  T01->MEDIA_DIAS
		(CALIAS1)->TMP_VTOT    :=  T01->VTOT

		_NCONT++
		_NMDDIAS+= T01->MEDIA_DIAS
		(CALIAS1)->(MsUnlock())


		DBSELECTAREA((CALIAS2))
		DBSETORDER(1)
		IF DBSEEK(T01->E2_FILIAL+T01->ED_CODIGO +" - "+ T01->ED_DESCRIC)
			(CALIAS2)->(Reclock( (CALIAS2), .F.))
			(CALIAS2)->TMP_PMP     :=  ((CALIAS2)->TMP_PMP+T01->MEDIA_DIAS)/2
			(CALIAS2)->TMP_VTOT    +=  T01->VTOT
		ELSE
			(CALIAS2)->(Reclock( (CALIAS2), .T.))

			(CALIAS2)->TMP_FILIAL  :=  T01->E2_FILIAL
			(CALIAS2)->TMP_NATURE  :=  T01->ED_CODIGO +" - "+ T01->ED_DESCRIC
			(CALIAS2)->TMP_PMP     :=  T01->MEDIA_DIAS
			(CALIAS2)->TMP_VTOT    :=  T01->VTOT
		ENDIF

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )

	IF _NCONT >0
		(CALIAS7)->(Reclock( CALIAS7, .T.))


		(CALIAS7)->TMP_FILIAL :=  MV_PAR01
		(CALIAS7)->TMP_INDIC  :=  "PMP"
		(CALIAS7)->TMP_VALOR  :=  INT(_NMDDIAS/_NCONT)

		(CALIAS7)->(MsUnlock())
	ENDIF





	CQUERY := " SELECT ED_CODIGO , ED_DESCRIC, E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NOMCLI, SUM(E1_VALOR) VTOT, SUM(DATEDIFF(DAY,CONVERT(DATE, E1_EMISSAO, 103),CONVERT(DATE, E1_VENCREA, 103) ))/COUNT(*) AS MEDIA_DIAS "
	CQUERY += " FROM "+RETSQLNAME("SE1")+" E1 "
	CQUERY += " INNER JOIN "+RETSQLNAME("SED")+" ED ON ED_FILIAL = ' ' AND ED_CODIGO = E1_NATUREZ AND ED.D_E_L_E_T_ = ' '  AND E1_NATUREZ BETWEEN '100000' AND '199999' "
	CQUERY += " WHERE E1_FILIAL = '"+MV_PAR01+"' AND E1.D_E_L_E_T_ = ' ' AND E1_TIPO NOT IN ('NCC','RA','PR') AND E1_VENCREA < '"+DTOS(DDATABASE-360)+"' "
	CQUERY += " GROUP BY ED_CODIGO , ED_DESCRIC, E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NOMCLI "


	TcQuery cQuery New Alias T01
	DbSelectArea("T01")
	_NCONT := 0
	_NMDDIAS:= 0
	While !T01->(Eof())

		(CALIAS3)->(Reclock( CALIAS3, .T.))

		_chave := T01->E1_FILIAL+T01->E1_CLIENTE+T01->E1_LOJA
		(CALIAS3)->TMP_FILIAL  :=  T01->E1_FILIAL
		(CALIAS3)->TMP_CLIENT  :=  T01->E1_CLIENTE+" - "+T01->E1_LOJA
		(CALIAS3)->TMP_NOMCLI  :=  T01->E1_NOMCLI
		(CALIAS3)->TMP_NATURE  :=  T01->ED_CODIGO +" - "+ T01->ED_DESCRIC
		(CALIAS3)->TMP_PMR     :=  T01->MEDIA_DIAS
		(CALIAS3)->TMP_VTOT    :=  T01->VTOT

		_NCONT++
		_NMDDIAS+= T01->MEDIA_DIAS
		(CALIAS3)->(MsUnlock())


		DBSELECTAREA((CALIAS4))
		DBSETORDER(1)
		IF DBSEEK(T01->E1_FILIAL+T01->ED_CODIGO +" - "+ T01->ED_DESCRIC)
			(CALIAS4)->(Reclock( (CALIAS4), .F.))
			(CALIAS4)->TMP_PMR     :=  ((CALIAS4)->TMP_PMR+T01->MEDIA_DIAS)/2
			(CALIAS4)->TMP_VTOT    +=  T01->VTOT
		ELSE
			(CALIAS4)->(Reclock( (CALIAS4), .T.))

			(CALIAS4)->TMP_FILIAL  :=  T01->E1_FILIAL
			(CALIAS4)->TMP_NATURE  :=  T01->ED_CODIGO +" - "+ T01->ED_DESCRIC
			(CALIAS4)->TMP_PMR     :=  T01->MEDIA_DIAS
			(CALIAS4)->TMP_VTOT    :=  T01->VTOT
		ENDIF

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )

	IF _NCONT >0
		(CALIAS7)->(Reclock( CALIAS7, .T.))


		(CALIAS7)->TMP_FILIAL :=  MV_PAR01
		(CALIAS7)->TMP_INDIC  :=  "PMR"
		(CALIAS7)->TMP_VALOR  :=  INT(_NMDDIAS/_NCONT)

		(CALIAS7)->(MsUnlock())
	ENDIF


	CQUERY := " SELECT CN9_FILIAL, TFJ_CODENT, TFJ_LOJA, A1_NOME, A1_EST, A1_MUN,A1_END, AD1_SETOR,  CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, "

	CQUERY += " ( SELECT TOP 1 E1_VENCREA FROM "+RETSQLNAME("SE1")+" E1 WHERE E1_FILIAL = SUBSTRING(CN9_FILIAL,1,2) AND E1.D_E_L_E_T_ = ' ' AND SUBSTRING(E1_FILIAL,1,2)+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA IN (SELECT SUBSTRING(D2_FILIAL,1,2)+D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA FROM "+RETSQLNAME("SD2")+" D2, "+RETSQLNAME("SC5")+" C5 WHERE D2_FILIAL = CN9_FILIAL AND  D2_CLIENTE = TFJ_CODENT AND D2_LOJA = TFJ_LOJA AND C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_YCC IN (SELECT TFL_YCC FROM "+RETSQLNAME("TFL")+" TFL WHERE TFL_FILIAL = CN9_FILIAL AND TFL_CONTRT = CN9_NUMERO AND TFL_CODPAI = TFJ_CODIGO AND TFL_CONREV = CN9_REVISA AND TFL.D_E_L_E_T_ = ' ' AND TFL_ENCE <> '1'  ) AND D2.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' ) ORDER BY E1_VENCREA) AS DATA_VENC"

	CQUERY += " FROM "+RETSQLNAME("CN9")+" CN9 "
	CQUERY += " INNER JOIN "+RETSQLNAME("TFJ")+" TFJ ON TFJ_FILIAL = CN9_FILIAL AND TFJ_STATUS IN ('1','3') AND TFJ_CONTRT = CN9_NUMERO AND TFJ_CONREV = CN9_REVISA AND TFJ.D_E_L_E_T_ = ' ' "

	CQUERY += " INNER JOIN "+RETSQLNAME("ADY")+" ADY ON ADY_FILIAL = TFJ_FILIAL AND ADY_PROPOS = TFJ_PROPOS AND ADY_PREVIS = TFJ_PREVIS AND ADY.D_E_L_E_T_ = ' ' "
	CQUERY += " INNER JOIN "+RETSQLNAME("AD1")+" AD1 ON AD1_FILIAL = ADY_FILIAL AND AD1_PROPOS = ADY_PROPOS AND AD1.D_E_L_E_T_ = ' ' "

	CQUERY += " INNER JOIN "+RETSQLNAME("SA1")+" A1 ON A1_FILIAL = ' ' AND A1_COD = TFJ_CODENT AND A1_LOJA = TFJ_LOJA AND A1.D_E_L_E_T_ = ' ' "

	CQUERY += " WHERE "
	CQUERY += " SUBSTRING(CN9_DTINIC,1,6) <= '"+DTOS(DDATABASE)+"' AND SUBSTRING(CN9_DTFIM,1,6) >='"+DTOS(DDATABASE)+"' AND CN9_REVATU = ' '  AND CN9.D_E_L_E_T_ = ' ' AND CN9_FILIAL BETWEEN '"+MV_PAR01+"0101' AND  '"+MV_PAR01+"9999' AND CN9_SITUAC <> '01' "
	CQUERY += " ORDER BY CN9_FILIAL, AD1_SETOR, A1_NOME "

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")
	_NCONT := 0
	_NMDDIAS:= 0
	While !T01->(Eof())

		(CALIAS5)->(Reclock( CALIAS5, .T.))

		_chave := T01->CN9_FILIAL+T01->TFJ_CODENT+T01->TFJ_LOJA
		(CALIAS5)->TMP_FILIAL  :=  T01->CN9_FILIAL
		(CALIAS5)->TMP_CLIENT  :=  T01->TFJ_CODENT+" - "+T01->TFJ_LOJA
		(CALIAS5)->TMP_NOMCLI  :=  T01->A1_NOME
		(CALIAS5)->TMP_CONTRA  :=  T01->CN9_NUMERO
		(CALIAS5)->TMP_DT1P    := STOD(T01->DATA_VENC)
		(CALIAS5)->TMP_DTINI   := STOD(T01->CN9_DTINIC)
		(CALIAS5)->TMP_PMR     := (CALIAS5)->TMP_DT1P-(CALIAS5)->TMP_DTINI
		//(CALIAS5)->TMP_VTOT     :=  0
		if !empty((CALIAS5)->TMP_DT1P)
			_NCONT++
			_NMDDIAS+= (CALIAS5)->TMP_PMR
		endif
		(CALIAS5)->(MsUnlock())


		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )

	IF _NCONT >0
		(CALIAS7)->(Reclock( CALIAS7, .T.))


		(CALIAS7)->TMP_FILIAL :=  MV_PAR01
		(CALIAS7)->TMP_INDIC  :=  "PM1R"
		(CALIAS7)->TMP_VALOR  :=  INT(_NMDDIAS/_NCONT)

		(CALIAS7)->(MsUnlock())
	ENDIF
Return

