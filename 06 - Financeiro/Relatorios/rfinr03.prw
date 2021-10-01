/*
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function RFINR03()

	Private oReport
	Private cPergCont	:= "RFINR03"
	PRIVATE	_CAMPTAB1 := {}
	PRIVATE cAlias1			:= GetNextAlias()
	PRIVATE oTempTab1
	/*
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
/{Protheus.doc} ReportDef
Monta impressao via TReport;

@author RODRIGO LUCAS
@since 07/11/2018
@version P12
/
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

	oReport := TReport():New( 'Títulos contas a pagar', 'Títulos contas a pagar', cPergCont, {|oReport| ReportPrint( oReport ), 'Títulos contas a pagar' } )
	oReport:cFontBody := 'calibri'
	oReport:nfontbody:=8
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:lParamReadOnly := .T.
	oReport:ShowHeader()

	oSection1 := TRSection():New( oReport, 'Títulos contas a pagar', { 'SE2'})
//	oSection2 := TRSection():New( oReport, 'Centro de Custo', { 'CTT'})
//	oSection3 := TRSection():New( oReport, 'Funções', { 'SRJ'})



	TRCell():New( oSection1, 'TMP_FILIAL','T01','FILIAL',,02,.f.,,,,,,,.f.)
	//TRCell():New(oSection1,"VAL_NOMI",,STR0068+CRLF+STR0069,cPictTit,nTamVal+1,.F.,,,,,,,.f.)  //"Tit Vencidos" + "Valor Nominal"
	AAdd( _CAMPTAB1, { "TMP_FILIAL"	, 'C', 02, 0 } )
	//TRCell():New( oSection1, 'TMP_PREFIX'	    	        ,'T01', 'Prefixo'         ,,03,.f.,,,,,,,.f.)
	//AAdd( _CAMPTAB1, { "TMP_PREFIX"	, 'C', 03, 0 } )
	TRCell():New( oSection1, 'TMP_NUM'	    	        ,'T01', 'Número'         , ,13,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_NUM"	, 'C', 13, 0 } )
	//TRCell():New( oSection1, 'TMP_PARCE'	    	    ,'T01', 'Parcela'         , ,1,.f.,,,,,,,.f.)
	//AAdd( _CAMPTAB1, { "TMP_PARCE"	, 'C', 1, 0 } )
	//TRCell():New( oSection1, 'TMP_TIPO'	    	    ,'T01', 'Tipo'         , ,4,.f.,,,,,,,.f.)
	//AAdd( _CAMPTAB1, { "TMP_TIPO"	, 'C', 3, 0 } )
//	TRCell():New( oSection1, 'TMP_NATURE'	    	    ,'T01', 'Natureza'         , ,25,.f.,,,,,,,.f.)
//	AAdd( _CAMPTAB1, { "TMP_NATURE"	, 'C', 25, 0 } )
	TRCell():New( oSection1, 'TMP_FORNEC'	    	    ,'T01', 'FORNEC'         , ,25,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_FORNEC"	, 'C', 25, 0 } )
	TRCell():New( oSection1, 'TMP_DTEMIS'	    	    ,'T01', 'Emissão'         , ,08,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_DTEMIS"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTLIB'	    	    ,'T01', 'DT Liberação'         , ,08,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_DTLIB"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTVENC'	    	    ,'T01', 'Vencimento'         , ,08,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_DTVENC"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_DTVREA'	    	    ,'T01', 'Vencimento Real'         , ,08,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_DTVREA"	, 'D', 08, 0 } )
	TRCell():New( oSection1, 'TMP_VALOR'	    	    ,'T01', 'Valor'         ,	PesqPict("SE1","E1_VALOR")						,15,.f.,,"RIGHT",,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_VALOR"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_SALDO'	    	    ,'T01', 'Saldo'         ,	PesqPict("SE1","E1_VALOR")						,15,.f.,,"RIGHT",,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_SALDO"	, 'N', 14, 2 } )
	TRCell():New( oSection1, 'TMP_DTMOV'	    	    ,'T01', 'Data Movimento'         , ,08,.f.,,,,,,,.f.)
	AAdd( _CAMPTAB1, { "TMP_DTMOV"	, 'D', 08, 0 } )



	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")

Return( oReport )

//_____________________________________________________________________________
/{Protheus.doc} ReportPrint
Rotina responsavel pela busca e carregamentos dos dados a serem impressos;

@author Rodrigo Lucas
@since 07 de Novembro de 2018
@version P12
/
//_____________________________________________________________________________
Static Function ReportPrint( oReport  )

	Local oSection1 	:= oReport:Section(1)
//	Local oSection2 	:= oReport:Section(2)
//	Local oSection3 	:= oReport:Section(3)

	LOCAL nx
	oTempTab1:= FWTemporaryTable():New(CALIAS1)
	oTempTab1:SetFields(_CAMPTAB1)
	oTempTab1:AddIndex("1",{"TMP_FILIAL","TMP_NUM","TMP_FORNEC"})
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



	oTempTab1:DELETE()
//	oTempTab2:DELETE()
//	oTempTab3:DELETE()


Return( Nil )

//_____________________________________________________________________________
/{Protheus.doc} AjustaSX1
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
/
//_____________________________________________________________________________
Static Function Query( aSection1, aSection2, aSection3, aVLR1,aVLR2,aVLR3 )


	CQUERY := " SELECT E2_FILIAL, ED_DESCRIC,A2_NOME,E2_HIST,E2_NUM,E2_PARCELA,E2_PREFIXO,E2_TIPO,E2_VENCREA,E2_VENCTO, E2_DATALIB, E2_BAIXA, E2_EMISSAO, E2_VALOR, E2_SALDO "
	CQUERY += " FROM "+RETSQLNAME("SE2")+" SE2 (NOLOCK) "
	CQUERY += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 (NOLOCK)  ON A2_FILIAL = ' '  AND SA2.D_E_L_E_T_=' '  AND E2_FORNECE=A2_COD AND E2_LOJA=A2_LOJA "
	CQUERY += " INNER JOIN "+RETSQLNAME("SED")+" SED (NOLOCK)  ON ED_FILIAL = ' ' AND SED.D_E_L_E_T_=' '  AND E2_NATUREZ=ED_CODIGO "
	CQUERY += " WHERE SE2.D_E_L_E_T_=' ' "
	CQUERY += " AND E2_TIPO <> 'PA' "
	CQUERY += " AND E2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	CQUERY += " AND E2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	CQUERY += " AND E2_VENCREA BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
	IF MV_PAR09 == 1
		CQUERY += " AND E2_DATALIB BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
	ELSEIF MV_PAR09 == 2
		CQUERY += " AND E2_DATALIB = ' '  "
	ENDIF
	//CQUERY += " GROUP BY ED_DESCRIC,A2_NOME,E2_HIST,E2_NUM,E2_PARCELA,E2_PREFIXO,E2_TIPO,E2_VENCREA,E2_VENCTO

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		(CALIAS1)->(Reclock( CALIAS1, .T.))


		(CALIAS1)->TMP_FILIAL :=  T01->E2_FILIAL
		//	(CALIAS1)->TMP_PREFIX  :=  T01->E2_PREFIXO
		(CALIAS1)->TMP_NUM  :=  T01->E2_PREFIXO+T01->E2_NUM+T01->E2_PARCELA
		//(CALIAS1)->TMP_PARCE  :=  T01->E2_PARCELA
		//(CALIAS1)->TMP_TIPO  :=  T01->E2_TIPO
		//(CALIAS1)->TMP_NATURE  :=  SUBSTR(T01->ED_DESCRIC,1,25)
		(CALIAS1)->TMP_FORNEC  :=  SUBSTR(T01->A2_NOME,1,25)
		(CALIAS1)->TMP_DTEMIS  :=  stod(T01->E2_EMISSAO)
		(CALIAS1)->TMP_DTLIB  :=  stod(T01->E2_DATALIB)
		(CALIAS1)->TMP_DTVENC  :=  stod(T01->E2_VENCTO)
		(CALIAS1)->TMP_DTVREA  :=  stod(T01->E2_VENCREA)
		(CALIAS1)->TMP_VALOR  :=  T01->E2_VALOR
		(CALIAS1)->TMP_SALDO  :=  T01->E2_SALDO
		(CALIAS1)->TMP_DTMOV :=  stod(T01->E2_BAIXA)

		(CALIAS1)->(MsUnlock())

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )



Return
*/


#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function RFINR03()

	Local cDesc1	:= "ESTA ROTINA TEM COMO OBJETIVO IMPRIMIR RELATÓRIOS "
	Local cDesc2	:= "DE ACORDO COM OS PARÂMETROS NFORMADOS PELO USUÁRIO."
	Local cDesc3	:= "CONTAS A PAGAR#"
	Local cTitulo	:= "CONTAS A PAGAR#"
	//Local lImprime	:= .T.

// Parametros da SetPrint()
	Local cString	:= "SE2"
	Local cPerg		:= "RFINR03"
	Local lDic		:= .T. // Habilita a visalizacao do dicionario
	Local aOrd		:= {}
	Local lCompres	:= .T. // .F. - Normal / .T. - Comprimido
	Local lFilter	:= .T. // Habilita o filtro para o usuario
	Local cNomeProg	:= "RFINR03"
	Local cTamanho	:= "G"
	Local nTipo		:= 18
	Local nLimite	:= 132
	Private _cChave
	Private _nVal
	Private _CRESPON
	Private _cnome

//Default lCriaTrab	:= .T.

	Private lEnd		:= .F.
	Private lAbortPrint	:= .F.
	Private aReturn		:= { "ZEBRADO", 1, "ADMINISTRAÇÃO", 2, 2, 1, "", 1}
//aReturn[4] 1- Retrato, 2- Paisagem
//aReturn[5] 1- Em Disco, 2- Via Spool, 3- Direto na Porta, 4- Email

	Private nLastKey	:= 0
	Private m_pag		:= 01
	Private wnrel		:= "RFINR03"


// Monta a interface padrao com o usuario...
	PERGUNTE(CPERG,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDic,aOrd,lCompres,cTamanho,,lFilter)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString,,,cTamanho,aReturn[4]) // nFormato: 1- Retrato, 2-Paisagem

	If nLastKey == 27
		Return
	Endif

	nTipo := IIF(aReturn[4]==1,15,18)

// Processamento. RPTSTATUS monta janela com a regua de processamento.

	RptStatus({|| RunReport(cTitulo,cString,cNomeProg,cTamanho,nTipo,nLimite,_NVAL)},cTitulo)


Return

//Função interna de processamento utilizada pela MPTR001()

Static Function RunReport(cTitulo,cString,cNomeProg,cTamanho,nTipo,nLimite,_NVAL)

	Local nLin 		:= 80
	Local cCabec1 	:= ""
	Local cCabec2 	:= ""
//	Local cArqInd

	CQUERY := " SELECT E2_FILIAL, ED_DESCRIC,A2_NOME,E2_HIST,E2_NUM,E2_PARCELA,E2_PREFIXO,E2_TIPO,E2_VENCREA,E2_VENCTO, E2_DATALIB, E2_BAIXA, E2_EMISSAO, E2_VALOR, E2_SALDO, E2_VALLIQ "
	CQUERY += " FROM "+RETSQLNAME("SE2")+" SE2 (NOLOCK) "
	CQUERY += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 (NOLOCK)  ON A2_FILIAL = ' '  AND SA2.D_E_L_E_T_=' '  AND E2_FORNECE=A2_COD AND E2_LOJA=A2_LOJA "
	CQUERY += " INNER JOIN "+RETSQLNAME("SED")+" SED (NOLOCK)  ON ED_FILIAL = ' ' AND SED.D_E_L_E_T_=' '  AND E2_NATUREZ=ED_CODIGO "
	CQUERY += " WHERE SE2.D_E_L_E_T_=' ' "
	CQUERY += " AND E2_TIPO <> 'PA' "
	CQUERY += " AND E2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	CQUERY += " AND E2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	CQUERY += " AND E2_VENCREA BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
	IF MV_PAR09 == 1
		CQUERY += " AND E2_DATALIB BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' "
	ELSEIF MV_PAR09 == 2
		CQUERY += " AND E2_DATALIB = ' '  "
	ENDIF
	CQUERY += " ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM  "
	TCQUERY CQUERY NEW ALIAS "T01"


	cCabec1 := "Filial"+Space(3)+"Pref"+Space(2)+"Num"+Space(4)+"Parcela"+Space(6)+"Natureza"+SPACE(22)+"Fornecedor"+SPACE(20)+"Data Emissão"+space(09)+"Data Liberação"+space(06)+"Vencimento"+space(17)+"Valor"+space(12)+"Saldo"+space(08)+"Data Movimentação"

	SetRegua(RecCount())

	DBSELECTAREA("T01")
	T01->(DBGOTOP())
	_atot := {}
	_CFIL := ""
	While !T01->(EOF())
		If lAbortPrint .OR. nLastKey == 27
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...

			Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo)
			nLin := 8

		Endif
		IF _CFIL <> T01->E2_FILIAL
			_NSC1 := aScan(_atot,{|x| x[1] == alltrim(_CFIL)})
			If _NSC1 > 0

				nLin++
				nLin++
				@nLin,010 PSAY "Valor total empresa: "+_atot[_NSC1,1]

				@nLin,035 PSAY transform(_atot[_NSC1,2],"@E 999,999,999.99")

				@nLin,055 PSAY "Liberado: "
				@nLin,080 PSAY transform(_atot[_NSC1,3],"@E 999,999,999.99")
				@nLin,100 PSAY "Bloqueado: "
				@nLin,125 PSAY transform(_atot[_NSC1,4],"@E 999,999,999.99")
				@nLin,145 PSAY "Baixados: "
				@nLin,170 PSAY transform(_atot[_NSC1,5],"@E 999,999,999.99")
				nLin++
				nLin++
			ENDIF

			_CFIL := T01->E2_FILIAL
		ENDIF

		@nLin,002 PSAY T01->E2_FILIAL
		@nLin,010 PSAY T01->E2_PREFIXO
		@nLin,014 PSAY T01->E2_NUM
		@nLin,022 PSAY T01->E2_PARCELA
		@nLin,035 PSAY SUBSTR(T01->ED_DESCRIC,1,25)
		@nLin,065 PSAY SUBSTR(T01->A2_NOME,1,25)
		//@nLin,095 PSAY SUBSTR(T01->A2_NOME,1,25)
		@nLin,095 PSAY stod(T01->E2_EMISSAO)
		@nLin,115 PSAY stod(T01->E2_DATALIB)
		@nLin,135 PSAY stod(T01->E2_VENCREA)
		@nLin,155 PSAY transform(T01->E2_VALOR,"@E 999,999,999.99")
		@nLin,171 PSAY transform(T01->E2_SALDO,"@E 999,999,999.99")
		@nLin,195 PSAY stod(T01->E2_BAIXA)
		nLin++
		_nAscan := aScan(_atot,{|x| x[1] == alltrim(T01->E2_FILIAL)})
		If _nAscan == 0
			if empty(T01->E2_DATALIB)
				aAdd(_atot, {alltrim(T01->E2_FILIAL),T01->E2_VALOR,0,T01->E2_VALOR,T01->E2_VALLIQ})
			else
				aAdd(_atot, {alltrim(T01->E2_FILIAL),T01->E2_VALOR,T01->E2_VALOR,0,T01->E2_VALLIQ})
			endif
		else
			_atot[_nAscan,2] += T01->E2_VALOR
			_atot[_nAscan,5] += T01->E2_VALLIQ
			if empty(T01->E2_DATALIB)
				_atot[_nAscan,4] += T01->E2_VALOR
			ELSE
				_atot[_nAscan,3] += T01->E2_VALOR
			ENDIF
		EndIf

		T01->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo
	_ncont := 1
	nLin++
	nLin++
	_vtot:= 0
	_vtotl:= 0
	_vtotb:= 0
	_vbai := 0

	IF _CFIL <> T01->E2_FILIAL
			_NSC1 := aScan(_atot,{|x| x[1] == alltrim(_CFIL)})
		If _NSC1 > 0

				@nLin,010 PSAY "Valor total empresa: "+_atot[_NSC1,1]

				@nLin,035 PSAY transform(_atot[_NSC1,2],"@E 999,999,999.99")

				@nLin,055 PSAY "Liberado: "
				@nLin,080 PSAY transform(_atot[_NSC1,3],"@E 999,999,999.99")
				@nLin,100 PSAY "Bloqueado: "
				@nLin,125 PSAY transform(_atot[_NSC1,4],"@E 999,999,999.99")
				@nLin,145 PSAY "Baixados: "
				@nLin,170 PSAY transform(_atot[_NSC1,5],"@E 999,999,999.99")

		ENDIF

			_CFIL := T01->E2_FILIAL
	ENDIF
nLin++
	nLin++
	While len(_atot) >= _ncont
	
	
		_vtot += _atot[_ncont,2]
		_vtotl += _atot[_ncont,3]
		_vtotb += _atot[_ncont,4]
		_vbai  += _atot[_ncont,5]
		
		_ncont++
	Enddo

		@nLin,010 PSAY "Valor total Geral: "

		@nLin,035 PSAY transform(_vtot,"@E 999,999,999.99")

		@nLin,055 PSAY "Liberado: "
		@nLin,080 PSAY transform(_vtotl,"@E 999,999,999.99")
		@nLin,100 PSAY "Bloqueado: "
		@nLin,125 PSAY transform(_vtotb,"@E 999,999,999.99")
		@nLin,145 PSAY "Baixados: "
		@nLin,170 PSAY transform(_vbai,"@E 999,999,999.99")
	T01->(DBCLOSEAREA())
	SET DEVICE TO SCREEN



	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
RETURN
