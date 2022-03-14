#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"




//Static aCampos	:= {"A1_NOME","A1_COD","A1_LOJA","AOV_DESSEG","AD1_SETOR","CN9_NUMERO","CN9_REVISA","AD1_DESCRI","TFF_COD","TFF_LOCAL","ABS_DESCRI","TFJ_YVGNHO","CN9_VLINI","CN9_SALDO","AD1_YNRLIC","TFJ_CONDPG","E4_DESCRI","TFJ_YINDC","TFJ_YINDPL","TFJ_YDTRJ","CTT_CUSTO","CTT_DESC01","ABS_ESTADO","ABS_CODMUN","ABS_MUNIC", "TFF_COBCTR","TFF_PRODUT","B1_DESC","TFJ_YQGANH","TFF_QTDVEN","TFF_PERINI","TFF_PERFIM","TFF_FUNCAO","RJ_DESC","TFF_ESCALA","TDW_DESC","TFJ_CODTAB","TV6_DESC"}
//Static aCamposSnt	:= {{"A1_COD","CHV"},{"A1_NOME","ULT"},{"A1_LOJA","CHV"},{"ABS_ESTADO","ULT"},{"TFJ_YQGANH","ULT"},{"TFF_QTDVEN","SUM"},{"CN9_NUMERO","CHV"},{"CN9_REVISA","CHV"},{"AD1_DESCRI","ULT"},{"TFJ_YVGNHO","ULT"},{"CN9_VLINI","ULT"},{"CN9_SALDO","ULT"},{"CN9_DTINIC","ULT"},{"CN9_DTFIM","ULT"},{"TFJ_CODTAB","ULT"},{"TV6_DESC","ULT"},{"AOV_DESSEG","ULT"},{"AD1_SETOR","ULT"},{"AD1_YNRLIC","ULT"},{"TFJ_YINDC","ULT"},{"TFJ_YINDPL","ULT"},{"TFJ_YDTRJ","ULT"},{"TFF_LOCAL","CHV"},{"ABS_DESCRI","ULT"},{"CTT_CUSTO","ULT"}/*,{"CTT_CUSTO","CHV","SUBSTR(CTT_CUSTO,1,16)","TFLYCC16",16,0,"Centro de Custo"}*/}
//Static aCamposAdd	:= {"CN9_DTINIC","CN9_DTFIM"}
//Static aColsSntTo	:= {"T01","T02","T03","T04"}
/*/{Protheus.doc} RGSER003
Relatorio Contratos
@type function
@version 1.0
@author Rodrigo Lucas
@since 21/01/2021
@obs 
aCampos		Campos que vão exibir no analitico
aCamposSnt	Campos que vão exibir no sintetico
aCamposAdd	Campos que não tem no analitico, mas precisa usar no sintetico
/*/
User Function RGSER003
	Local aParam			:= {}
	Local aRet				:= {}
	Local bOk				:= {|| .T. }
	Local cFilIni
	Local cFilFim


	If TYPE("cFilAnt")=="U"
		OpenSm0()
		SM0->(DbGoTop())
		RpcSetEnv(SM0->M0_CODIGO,"060101")
		__cInterNet	:= Nil
	EndIf
	cFilIni		:= Space(FWSizeFilia())
	cFilFim		:= Space(FWSizeFilia())
	cContraIni	:= Space(GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cContraFim	:= Replicate("Z",GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cCliIni		:= Space(GetSx3Cache("TFJ_CODENT","X3_TAMANHO"))
	cCliFim		:= Replicate("Z",GetSx3Cache("TFJ_CODENT","X3_TAMANHO"))
	cCCIni		:= Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO"))
	cCCFim		:= Replicate("Z",GetSx3Cache("CTT_CUSTO","X3_TAMANHO"))
	cPERI		:= Space(6)
	aAdd(aParam,{1,"Empresa De"		,cFilIni	,"@!","","SM0",".T.",110,.F.})
//	aAdd(aParam,{1,"Empresa Até"	,cFilFim	,"@!","","SM0",".T.",110,.F.})
//	aAdd(aParam,{1,"Cliente De"		,cCliIni	,"@!","","SA1",".T.",110,.F.})
//	aAdd(aParam,{1,"Cliente Até"	,cCliFim	,"@!","","SA1",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato De"	,cContraIni	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato Até"	,cContraFim	,"@!","","CN9",".T.",110,.F.})
//	aAdd(aParam,{1,"CC De"		,cCCIni	,"@!","","CTT",".T.",110,.F.})
//	aAdd(aParam,{1,"CC Até"	,cCCFim	    ,"@!","","CTT",".T.",110,.F.})
	aAdd(aParam,{1,"Periodo AAAAMM"	,cPERI	    ,"@!","","",".T.",110,.F.})
	//aAdd(aParam,{2,"Extra"		    ,cExtra     ,	{"1=Não", "2=Sim"},80,".T.",.F.})
	//aAdd(aParam,{4,"Elaboração"		,l02	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Vigente"		,l05	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Em revisão"		,l09	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Revisado"		,l10	,""	,80,".T.",.F.})
	If !ParamBox(aParam,"Filtro",@aRet,bOk,,,,,,"RTECR05",.T.,.T.)
		Return
	EndIf
	cFilIni	:= aRet[1]
	//cFilFim	:= aRet[2]
	//cCliIni		:= aRet[3]
	//cCliFim		:= aRet[4]
	cContraIni	:= aRet[2]
	cContraFim	:= aRet[3]
	//cCCIni		:= aRet[7]
	//cCCFim		:= aRet[8]
	cPERI		:= aRet[4]
	//cExtra		:= aRet[9]
	//l02			:= aRet[10]
	//l05			:= aRet[11]
	//l09			:= aRet[12]
	//l10			:= aRet[13]
	Processa({|lCancelar| RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cCCIni,cCCFim,cPERI,@lCancelar) },,,.T.)
Return

Static Function RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cCCIni,cCCFim,cPERI,lCancelar)

	cQuery(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cCCIni,cCCFim,cPERI)

	Alert("Carga conclu�da")
Return

Static Function cQuery(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cCCIni,cCCFim,cPERI)
/*
	cQuery		:= "SELECT TFF_FILIAL, CN9_NUMERO,CN9_REVISA, CTT_CUSTO  "
	cQuery		+= " FROM "+RetSqlName("TFF")+" TFF"
	cQuery		+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD=TFF_PRODUT AND SB1.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("ABS")+" ABS ON ABS_FILIAL='"+xFilial("ABS")+"' AND ABS_LOCAL=TFF_LOCAL AND ABS.D_E_L_E_T_=' '"
	cQuery		+= " LEFT JOIN "+RetSqlName("CE1")+" CE1 ON CE1_FILIAL='"+xFilial("CE1")+"' AND CE1_CMUISS=ABS_CODMUN AND CE1_CODISS = B1_CODISS AND CE1.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_FILIAL='"+xFilial("TFL")+"' AND TFL_CODIGO=TFF_CODPAI AND TFL_CODSUB=' ' AND TFL.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_FILIAL='"+xFilial("CTT")+"' AND CTT_CUSTO=CTT_CUSTO AND CTT.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFJ_FILIAL='"+xFilial("TFJ")+"' AND TFJ_CODIGO=TFL_CODPAI AND TFJ_STATUS='1' AND TFJ.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("SE4")+" SE4 ON E4_FILIAL='"+xFilial("SE4")+"' AND E4_CODIGO=TFJ_CONDPG AND SE4.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=TFJ_CODENT AND A1_LOJA=TFJ_LOJA AND SA1.D_E_L_E_T_=' '"
	cQuery		+= " LEFT JOIN "+RetSqlName("AOV")+" AOV ON AOV_FILIAL='"+xFilial("AOV")+"' AND AOV_CODSEG=A1_CODSEG AND AOV.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FILIAL='"+xFilial("SRJ")+"' AND RJ_FUNCAO=TFF_FUNCAO AND SRJ.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TDW")+" TDW ON TDW_FILIAL='"+xFilial("TDW")+"' AND TDW_COD=TFF_ESCALA AND TDW.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TV6")+" TV6 ON TV6_FILIAL='"+xFilial("TV6")+"' AND TV6_NUMERO=TFJ_CODTAB AND TV6.D_E_L_E_T_=' ' AND TV6_REVISA = TFJ_TABREV  "
	cQuery		+= " INNER JOIN "+RetSqlName("CN9")+" CN9 ON CN9_FILIAL='"+xFilial("CN9")+"' AND CN9_NUMERO=TFJ_CONTRT AND CN9_REVISA=TFJ_CONREV AND CN9.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("ADY")+" ADY ON ADY_FILIAL='"+xFilial("ADY")+"' AND ADY_PROPOS=TFJ_PROPOS AND ADY_PREVIS=TFJ_PREVIS AND ADY.D_E_L_E_T_=' ' "
	cQuery		+= " INNER JOIN "+RetSqlName("AD1")+" AD1 ON AD1_FILIAL='"+xFilial("AD1")+"' AND AD1_NROPOR=ADY_OPORTU AND AD1_REVISA=ADY_REVISA AND AD1.D_E_L_E_T_=' ' "
	cQuery		+= " WHERE TFF_FILIAL = '"+cFilIni+"'  "
	cQuery		+= " AND TFJ_CONTRT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"'"
	//cQuery		+= " AND TFJ_CODENT BETWEEN '"+cCliIni+"' AND '"+cCliFim+"'"
	//cQuery		+= " AND CTT_CUSTO    BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"
	cQuery		+= " AND TFF.TFF_ENCE <>'1' "//AND TFF_YEXPO1 <> 'S' "
	cQuery		+= " AND TFJ_CODTAB<>' '"
	cQuery		+= " AND TFF.D_E_L_E_T_=' '"
	cQuery		+= " AND NOT EXISTS (SELECT * FROM "+RETSQLNAME("SZ4")+" Z4 WHERE Z4_FILIAL = TFF_FILIAL AND Z4_CONTRAT = CN9_NUMERO AND Z4_CC = CTT_CUSTO AND Z4.D_E_L_E_T_ = ' ' AND Z4_COMPET = '"+cPERI+"' ) "
	cQuery		+= " GROUP BY TFF_FILIAL, CN9_NUMERO,CN9_REVISA, CTT_CUSTO  "
	cQuery		+= " ORDER BY TFF_FILIAL, CN9_NUMERO,CN9_REVISA, CTT_CUSTO  "

*/
	cQuery		:= " SELECT CTT_FILIAL, CTT_CUSTO, CTT_DESC01  "
	cQuery		+= " FROM "+RetSqlName("CTT")+" CTT WHERE CTT_FILIAL = '"+SUBSTR(cFilIni,1,2)+"' AND CTT.D_E_L_E_T_ = ' ' AND (SUBSTRING(CTT_DTEXSF,1,6) >= '"+cPERI+"' OR CTT_DTEXSF = ' ' ) AND  SUBSTRING(CTT_CUSTO,1,1) = '1' AND CTT_CLASSE = '2' "
	cQuery		+= " AND SUBSTRING(CTT_CUSTO,11,6) BETWEEN '"+SUBSTR(cContraIni,10,6)+"' AND '"+SUBSTR(cContraFim,10,6)+"' AND SUBSTRING(CTT_CUSTO,3,2) = '"+SUBSTR(cFilIni,1,2)+"' "
	cQuery		+= " AND NOT EXISTS (SELECT * FROM "+RETSQLNAME("SZ4")+" Z4 WHERE Z4_FILIAL = '"+cFilIni+"' AND Z4_CONTRAT = '000000000'+SUBSTRING(CTT_CUSTO,11,6) AND Z4_CC = CTT_CUSTO AND Z4.D_E_L_E_T_ = ' ' AND Z4_COMPET = '"+cPERI+"' ) ORDER BY CTT_CUSTO"

	TCQUERY cQuery NEW ALIAS T01




	While T01->(!EOF())
		_LGRAVA := .F.


		cquery2 := " SELECT * FROM "+RetSqlName("SZ2")+" "
		//cquery2	+= " LEFT JOIN "+RetSqlName("TV7")+" TV7 ON TV7_FILIAL='"+xFilial("TV7")+"' AND TV7_CODTAB='"+T01->TV6_CODIGO+"' AND TV7.D_E_L_E_T_=' ' AND TV7_TITULO = Z2_FORMULA "
		cquery2 += " WHERE Z2_FILIAL = ' ' AND (Z2_FILGER = ' '  OR Z2_FILGER = '"+SUBSTR(cFilIni,1,4)+"') AND Z2_ROTINA = 'RGSER003' AND Z2_TIPO = 'V' AND Z2_TPFORM = 'R' ORDER BY Z2_SEQVAR "

		TCQUERY cquery2 NEW ALIAS _SZ2

		
		WHILE !_SZ2->(EOF())
			//FOL=Folha;FIN=Financeiro;EST=Estoque;COM=Compras;CTB=Contabilidade;FAT=Faturamento
			IF _SZ2->Z2_TPREAL == "FOL"

				cquery := " SELECT SUM(RD_VALOR) VALOR FROM "+RETSQLNAME("SRD")+" WHERE RD_FILIAL = '"+cFilIni+"' AND RD_PERIODO = '"+cPERI+"' AND RD_CC = '"+T01->CTT_CUSTO+"' AND D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := 0
				ENDIF
				_REA->(DBCLOSEAREA())

			ELSEIF _SZ2->Z2_TPREAL == "FIN"

				cquery := " SELECT SUM(E2_VALOR) VALOR FROM "+RETSQLNAME("SE2")+" WHERE E2_FILIAL = '"+SUBSTR(cFilIni,1,2)+"' AND SUBSTRING(E2_EMISSAO,1,6) = '"+cPERI+"' AND E2_CCUSTO = '"+T01->CTT_CUSTO+"' AND D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := 0
				ENDIF
				_REA->(DBCLOSEAREA())

			ELSEIF _SZ2->Z2_TPREAL == "EST"

				cquery := " SELECT SUM(D3_CUSTO1) VALOR FROM "+RETSQLNAME("SD3")+" D3, "+RETSQLNAME("SB1")+" B1 "
				cquery += " WHERE D3_FILIAL = '"+cFilIni+"' AND D3_TM > '500' AND SUBSTRING(D3_EMISSAO,1,6) = '"+cPERI+"' AND D3_CC = '"+T01->CTT_CUSTO+"' AND B1.D_E_L_E_T_ = ' ' AND"
				cquery += " B1_FILIAL = ' ' AND D3_COD = B1_COD AND D3.D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := 0
				ENDIF
				_REA->(DBCLOSEAREA())

			ELSEIF _SZ2->Z2_TPREAL == "COM"

				cquery := " SELECT SUM(D1_TOTAL) VALOR FROM "+RETSQLNAME("SD1")+" D1, "+RETSQLNAME("SB1")+" B1 "
				cquery += " WHERE D1_FILIAL = '"+cFilIni+"' AND D1_TIPO = 'N' AND SUBSTRING(D1_DTDIGIT,1,6) = '"+cPERI+"' AND D1_CC = '"+T01->CTT_CUSTO+"' AND B1.D_E_L_E_T_ = ' ' "
				cquery += " AND B1_FILIAL = ' ' AND D1_COD = B1_COD AND D1.D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := 0
				ENDIF
				_REA->(DBCLOSEAREA())
			ELSEIF _SZ2->Z2_TPREAL == "CTB"

				cquery := " SELECT SUM(CT2_VALOR) VALOR FROM "+RETSQLNAME("CT2")+" CT2 "
				cquery += " WHERE CT2_FILIAL = '"+SUBSTR(cFilIni,1,2)+"' AND SUBSTRING(CT2_DATA,1,6) = '"+cPERI+"' AND CT2_CCD = '"+T01->CTT_CUSTO+"' AND D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := 0
				ENDIF
				_REA->(DBCLOSEAREA())


				cquery := " SELECT SUM(CT2_VALOR) VALOR FROM "+RETSQLNAME("CT2")+" CT2 "
				cquery += " WHERE CT2_FILIAL = '"+SUBSTR(cFilIni,1,2)+"' AND SUBSTRING(CT2_DATA,1,6) = '"+cPERI+"' AND CT2_CCC = '"+T01->CTT_CUSTO+"' AND D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) -= _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) -= 0
				ENDIF
				_REA->(DBCLOSEAREA())

			ELSEIF _SZ2->Z2_TPREAL == "FAT"
				cquery := " SELECT SUM(D2_TOTAL) VALOR FROM "+RETSQLNAME("SD2")+" D2, "+RETSQLNAME("SB1")+" B1 "
				cquery += " WHERE D2_FILIAL = '"+cFilIni+"' AND D2_TIPO = 'N' AND SUBSTRING(D2_EMISSAO,1,6) = '"+cPERI+"' AND D2_CCUSTO = '"+T01->CTT_CUSTO+"' AND B1.D_E_L_E_T_ = ' ' AND "
				cquery += " B1_FILIAL = ' ' AND D2_COD = B1_COD AND D2.D_E_L_E_T_ = ' ' "
				if !empty(_SZ2->Z2_FILREAL)
					cquery += " AND "+ALLTRIM(_SZ2->Z2_FILREAL)
				endif
				TCQUERY cquery NEW ALIAS _REA

				DBSELECTAREA("_REA")
				IF !_REA->(EOF())
					IF !EMPTY(_REA->VALOR)
						_LGRAVA := .T.
					ENDIF
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := _REA->VALOR
				ELSE
					&(ALLTRIM(_SZ2->Z2_CAMPO)) := 0
				ENDIF
				_REA->(DBCLOSEAREA())
			ENDIF
			_SZ2->(DBSKIP())
		ENDDO
		_SZ2->(DBCLOSEAREA())

		cquery2 := " SELECT * FROM "+RetSqlName("SZ2")+" "
		//cquery2	+= " LEFT JOIN "+RetSqlName("TV7")+" TV7 ON TV7_FILIAL='"+xFilial("TV7")+"' AND TV7_CODTAB='"+T01->TV6_CODIGO+"' AND TV7.D_E_L_E_T_=' ' AND TV7_TITULO = Z2_FORMULA "
		cquery2 += " WHERE Z2_FILIAL = ' ' AND (Z2_FILGER = ' '  OR Z2_FILGER = '"+SUBSTR(cFilIni,1,4)+"') AND Z2_ROTINA = 'RGSER003' AND Z2_TIPO = 'V' AND Z2_TPFORM = 'F' ORDER BY Z2_SEQVAR "

		TCQUERY cquery2 NEW ALIAS _SZ2

		DBSELECTAREA("_SZ2")
		WHILE !_SZ2->(EOF())
			&(ALLTRIM(_SZ2->Z2_CAMPO)) := &(_SZ2->Z2_FORMULA)
			_SZ2->(DBSKIP())
		ENDDO
		_SZ2->(DBCLOSEAREA())
		iF _LGRAVA
			DBSELECTAREA("SZ4")
			Reclock("SZ4",.T.)
			SZ4->Z4_FILIAL		:= cFilIni
			SZ4->Z4_CONTRAT 	:= "000000000"+SUBSTR(T01->CTT_CUSTO,11,6)
			SZ4->Z4_CC		    := T01->CTT_CUSTO
			SZ4->Z4_COMPET      := cPERI

			cquery2 := "SELECT * FROM "+RetSqlName("SZ2")+" WHERE Z2_FILIAL = ' ' AND Z2_ROTINA = 'RGSER003' AND Z2_TIPO = 'C' "

			TCQUERY cquery2 NEW ALIAS _SZ2

			DBSELECTAREA("_SZ2")
			WHILE !_SZ2->(EOF())
				//_NLIN:= aScan(oxml:_fwmodelsheet:_model_sheet:_model_cells:_items:_item,{|x| AllTrim(x:_NICKNAME:TEXT) == ALLTRIM(_SZ2->Z2_FORMULA) })
				&("SZ4->"+ALLTRIM(_SZ2->Z2_CAMPO)) := &(_SZ2->Z2_FORMULA)
				_SZ2->(DBSKIP())
			ENDDO
			SZ4->(MsUnlock())
			_SZ2->(DBCLOSEAREA())
		ENDIF
		
		//Reclock("TFF",.F.)
		//TFF->TFF_YEXPO1 := "S"
		//TFF->(MsUnlock())
/*
		SZ4->Z4_RECBRUT		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_RECBRUT","Z2_FORMULA")))
		SZ4->Z4_PIS    		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_PIS"    ,"Z2_FORMULA")))
		SZ4->Z4_COFINS 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_COFINS" ,"Z2_FORMULA")))
		SZ4->Z4_ISS    		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_ISS"    ,"Z2_FORMULA")))
		SZ4->Z4_RECLIQU		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_RECLIQU","Z2_FORMULA")))
		SZ4->Z4_CUSTODI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_CUSTODI","Z2_FORMULA")))
		SZ4->Z4_MONTA  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_MONTA"  ,"Z2_FORMULA")))
		SZ4->Z4_QTDFUN 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_QTDFUN" ,"Z2_FORMULA")))
		SZ4->Z4_SAL    		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_SAL"    ,"Z2_FORMULA")))
		SZ4->Z4_SALTOT 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_SALTOT" ,"Z2_FORMULA")))
		SZ4->Z4_ADCPER 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_ADCPER" ,"Z2_FORMULA")))
		SZ4->Z4_ADCNOT 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_ADCNOT" ,"Z2_FORMULA")))
		SZ4->Z4_ADCHNR 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_ADCHNR" ,"Z2_FORMULA")))
		SZ4->Z4_ADCIJNO		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_ADCIJNO","Z2_FORMULA")))
		SZ4->Z4_TOTENCP		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_TOTENCP","Z2_FORMULA")))
		SZ4->Z4_TURNOV 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_TURNOV" ,"Z2_FORMULA")))
		SZ4->Z4_PERENCA		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_PERENCA","Z2_FORMULA")))
		SZ4->Z4_MONTB  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_MONTB"  ,"Z2_FORMULA")))
		SZ4->Z4_BENVTR 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_BENVTR" ,"Z2_FORMULA")))
		SZ4->Z4_BENVAL 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_BENVAL" ,"Z2_FORMULA")))
		SZ4->Z4_BENCB  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_BENCB"  ,"Z2_FORMULA")))
		SZ4->Z4_BENPLS 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_BENPLS" ,"Z2_FORMULA")))
		SZ4->Z4_MONTC  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_MONTC"  ,"Z2_FORMULA")))
		SZ4->Z4_INSFARD		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSFARD","Z2_FORMULA")))
		SZ4->Z4_INSEPI 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSEPI" ,"Z2_FORMULA")))
		SZ4->Z4_INSTREI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSTREI","Z2_FORMULA"))) 
		SZ4->Z4_INSMC  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSMC"  ,"Z2_FORMULA")))
		SZ4->Z4_INSEQUI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSEQUI","Z2_FORMULA")))
		SZ4->Z4_INSCELU		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSCELU","Z2_FORMULA")))
		SZ4->Z4_INSRADI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSRADI","Z2_FORMULA")))
		SZ4->Z4_INSVEIC		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSVEIC","Z2_FORMULA")))
		SZ4->Z4_INSCOMB		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSCOMB","Z2_FORMULA")))
		SZ4->Z4_INSSEGV		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSSEGV","Z2_FORMULA")))
		SZ4->Z4_INSCOLB		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSCOLB","Z2_FORMULA")))
		SZ4->Z4_INSSUPR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSSUPR","Z2_FORMULA")))
		SZ4->Z4_INSDEPR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSDEPR","Z2_FORMULA")))
		SZ4->Z4_INSMUNI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSMUNI","Z2_FORMULA")))
		SZ4->Z4_INSBASR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSBASR","Z2_FORMULA")))
		SZ4->Z4_INSMOTO		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSMOTO","Z2_FORMULA")))
		SZ4->Z4_INSGUAR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSGUAR","Z2_FORMULA")))
		SZ4->Z4_INSARMA		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSARMA","Z2_FORMULA")))
		SZ4->Z4_INSTONF		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_INSTONF","Z2_FORMULA")))
		SZ4->Z4_RENTAB 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_RENTAB" ,"Z2_FORMULA")))
		SZ4->Z4_PERMAR 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z4_PERMAR" ,"Z2_FORMULA")))
*/



		T01->(DbSkip())
	EndDo
	T01->(DBCloseArea())


Return

