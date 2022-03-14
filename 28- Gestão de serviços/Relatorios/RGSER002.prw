#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"

User Function RSCHED03()

	If Select('SX2') == 0
		RPCSetType( 3 )                              //N�o consome licensa de uso
		RpcSetEnv('01','010101',,,,GetEnvServer(),{ "SRA" })
		sleep( 5000 )                              //Aguarda 5 segundos para que as jobs IPC subam.
		ConOut('Processando tabela realizado... '+Dtoc(DATE())+' - '+Time())
		lAuto := .T.
	EndIf

	If     ( ! lAuto )

	Else
		dbSelectArea("SM0")
		SM0->(dbGOTOP())
		While !SM0->(EOF())
			cFilant := alltrim(SM0->M0_CODFIL)

			cFilIni := cFilant
			cFilFim := cFilant
			cContraIni := "               "
			cContraFim := "ZZZZZZZZZZZZZZZ"
			cCliIni := "      "
			cCliFim := "ZZZZZZ"
			cRevIni := "  "
			cRevFim := "ZZZ"

			Processa({|lCancelar| RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,lAuto,@lCancelar) },,,.T.)

		enddo


	EndIf

	If     ( lAuto )
		RpcClearEnv()                                 //Libera o Environment
		ConOut('Processando RGSER002... '+Dtoc(DATE())+' - '+Time())
	EndIf

return
//Static aCampos	:= {"A1_NOME","A1_COD","A1_LOJA","AOV_DESSEG","AD1_SETOR","CN9_NUMERO","CN9_REVISA","AD1_DESCRI","TFF_COD","TFF_LOCAL","ABS_DESCRI","TFJ_YVGNHO","CN9_VLINI","CN9_SALDO","AD1_YNRLIC","TFJ_CONDPG","E4_DESCRI","TFJ_YINDC","TFJ_YINDPL","TFJ_YDTRJ","TFL_YCC","CTT_DESC01","ABS_ESTADO","ABS_CODMUN","ABS_MUNIC", "TFF_COBCTR","TFF_PRODUT","B1_DESC","TFJ_YQGANH","TFF_QTDVEN","TFF_PERINI","TFF_PERFIM","TFF_FUNCAO","RJ_DESC","TFF_ESCALA","TDW_DESC","TFJ_CODTAB","TV6_DESC"}
//Static aCamposSnt	:= {{"A1_COD","CHV"},{"A1_NOME","ULT"},{"A1_LOJA","CHV"},{"ABS_ESTADO","ULT"},{"TFJ_YQGANH","ULT"},{"TFF_QTDVEN","SUM"},{"CN9_NUMERO","CHV"},{"CN9_REVISA","CHV"},{"AD1_DESCRI","ULT"},{"TFJ_YVGNHO","ULT"},{"CN9_VLINI","ULT"},{"CN9_SALDO","ULT"},{"CN9_DTINIC","ULT"},{"CN9_DTFIM","ULT"},{"TFJ_CODTAB","ULT"},{"TV6_DESC","ULT"},{"AOV_DESSEG","ULT"},{"AD1_SETOR","ULT"},{"AD1_YNRLIC","ULT"},{"TFJ_YINDC","ULT"},{"TFJ_YINDPL","ULT"},{"TFJ_YDTRJ","ULT"},{"TFF_LOCAL","CHV"},{"ABS_DESCRI","ULT"},{"TFL_YCC","ULT"}/*,{"TFL_YCC","CHV","SUBSTR(TFL_YCC,1,16)","TFLYCC16",16,0,"Centro de Custo"}*/}
//Static aCamposAdd	:= {"CN9_DTINIC","CN9_DTFIM"}
//Static aColsSntTo	:= {"T01","T02","T03","T04"}
/*/{Protheus.doc} RGSER001
Relatorio Contratos
@type function
@version 1.0
@author RODRIGO lUCAS
@since 21/01/2022
@obs 
aCampos		Campos que vão exibir no analitico
aCamposSnt	Campos que vão exibir no sintetico
aCamposAdd	Campos que não tem no analitico, mas precisa usar no sintetico
/*/
User Function RGSER002
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
	cRevIni		:= Space(GetSx3Cache("CN9_REVISA","X3_TAMANHO"))
	cRevFim		:= Replicate("Z",GetSx3Cache("CN9_REVISA","X3_TAMANHO"))
	aAdd(aParam,{1,"Empresa De"		,cFilIni	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Empresa Até"	,cFilFim	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Cliente De"		,cCliIni	,"@!","","SA1",".T.",110,.F.})
	aAdd(aParam,{1,"Cliente Até"	,cCliFim	,"@!","","SA1",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato De"	,cContraIni	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato Até"	,cContraFim	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Revisão De"		,cRevIni	,"@!","","",".T.",110,.F.})
	aAdd(aParam,{1,"Revisão Até"	,cRevFim	,"@!","","",".T.",110,.F.})
	//aAdd(aParam,{2,"Extra"		    ,cExtra     ,	{"1=Não", "2=Sim"},80,".T.",.F.})
	//aAdd(aParam,{4,"Elaboração"		,l02	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Vigente"		,l05	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Em revisão"		,l09	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Revisado"		,l10	,""	,80,".T.",.F.})
	If !ParamBox(aParam,"Filtro",@aRet,bOk,,,,,,"RGSER001",.T.,.T.)
		Return
	EndIf
	cFilIni	:= aRet[1]
	cFilFim	:= aRet[2]
	cCliIni		:= aRet[3]
	cCliFim		:= aRet[4]
	cContraIni	:= aRet[5]
	cContraFim	:= aRet[6]
	cRevIni		:= aRet[7]
	cRevFim		:= aRet[8]
	//cExtra		:= aRet[9]
	//l02			:= aRet[10]
	//l05			:= aRet[11]
	//l09			:= aRet[12]
	//l10			:= aRet[13]
	Processa({|lCancelar| RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,@lCancelar) },,,.T.)
Return

Static Function RunProc(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,cRevFim,lAuto,lCancelar)

	cQuery(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,lAuto,cRevFim)
	IF !lAuto
		Alert("Carga conclu�da")
	ENDIF
Return

Static Function cQuery(cFilIni,cFilFim,cContraIni,cContraFim,cCliIni,cCliFim,cRevIni,lAuto,cRevFim)

	cQuery		:= "SELECT TFF_FILIAL, CN9_NUMERO, CN9_REVISA, TFF_LOCAL, TFF_COD, TV6_NUMERO, TV6_REVISA, TV6_CODIGO, ISNULL(CE1_ALQISS,0) ALQISS "
	cQuery		+= ", TFF.R_E_C_N_O_ REGTFF"
	cQuery		+= ", TV6_CODIGO CODTV6"
	cQuery		+= " FROM "+RetSqlName("TFF")+" TFF"
	cQuery		+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD=TFF_PRODUT AND SB1.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("ABS")+" ABS ON ABS_FILIAL='"+xFilial("ABS")+"' AND ABS_LOCAL=TFF_LOCAL AND ABS.D_E_L_E_T_=' '"
	cQuery		+= " LEFT JOIN "+RetSqlName("CE1")+" CE1 ON CE1_FILIAL='"+xFilial("CE1")+"' AND CE1_CMUISS=ABS_CODMUN AND CE1_CODISS = B1_CODISS AND CE1.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL_FILIAL='"+xFilial("TFL")+"' AND TFL_CODIGO=TFF_CODPAI AND TFL_CODSUB=' ' AND TFL.D_E_L_E_T_=' '"
	cQuery		+= " INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_FILIAL='"+xFilial("CTT")+"' AND CTT_CUSTO=TFL_YCC AND CTT.D_E_L_E_T_=' '"
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
	cQuery		+= " WHERE TFF_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' "
	cQuery		+= " AND TFJ_CONTRT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"'"
	cQuery		+= " AND TFJ_CODENT BETWEEN '"+cCliIni+"' AND '"+cCliFim+"'"
	cQuery		+= " AND TFJ_CONREV BETWEEN '"+cRevIni+"' AND '"+cRevFim+"'"
	cQuery		+= " AND TFF.TFF_ENCE <>'1' "//AND TFF_YEXPO1 <> 'S' "
	cQuery		+= " AND TFJ_CODTAB<>' '"
	cQuery		+= " AND TFF.D_E_L_E_T_=' '"
	cQuery		+= " AND NOT EXISTS (SELECT * FROM "+RETSQLNAME("SZ3")+" Z3 WHERE Z3_FILIAL = TFF_FILIAL AND Z3_CONTRAT = CN9_NUMERO AND Z3_REVISAO = CN9_REVISA AND Z3_LOCAL = TFF_LOCAL AND Z3_CODRH = TFF_COD AND Z3.D_E_L_E_T_ = ' ' ) "
	cQuery		+= " ORDER BY TFF_FILIAL, CN9_NUMERO, CN9_REVISA, TFF_LOCAL, TFF_COD "

	TCQUERY cQuery NEW ALIAS T01




	While T01->(!EOF())

		TFF->(DbGoTo(T01->REGTFF))
		cErro := ""
		cAviso := ""
		oXml	 := XmlParser(TFF->TFF_TABXML,"_",@cErro,@cAviso)

		//Erro no processamento do XML
		If !Empty(cErro)
			IF !lAuto
				ApMsgStop('RGSER002-001: Erro na leitura do XML: '+CRLF+;
					cErro)
			ENDIF
			Return
		EndIf

		cquery2 := " SELECT * FROM "+RetSqlName("SZ2")+" "
		//cquery2	+= " LEFT JOIN "+RetSqlName("TV7")+" TV7 ON TV7_FILIAL='"+xFilial("TV7")+"' AND TV7_CODTAB='"+T01->TV6_CODIGO+"' AND TV7.D_E_L_E_T_=' ' AND TV7_TITULO = Z2_FORMULA "
		cquery2 += " WHERE Z2_FILIAL = ' ' AND Z2_ROTINA = 'RGSER002' AND Z2_TIPO = 'V' ORDER BY Z2_SEQVAR "

		TCQUERY cquery2 NEW ALIAS _SZ2

		DBSELECTAREA("_SZ2")
		WHILE !_SZ2->(EOF())
			IF _SZ2->Z2_TPFORM == "X"
				cquery3	:= " SELECT * FROM "+RetSqlName("TV7")+" TV7 WHERE TV7_FILIAL='"+xFilial("TV7")+"' AND TV7_CODTAB='"+T01->TV6_CODIGO+"' AND TV7.D_E_L_E_T_=' ' AND TV7_TITULO = '"+ALLTRIM(_SZ2->Z2_FORMULA)+"' "
				TCQUERY cquery3 NEW ALIAS _TV7

				DBSELECTAREA("_TV7")
				IF !_TV7->(EOF())
					_NLIN:= aScan(oxml:_fwmodelsheet:_model_sheet:_model_cells:_items:_item,{|x| AllTrim(x:_NICKNAME:TEXT) == ALLTRIM(_TV7->TV7_IDENT) })
					IF ALLTRIM(oxml:_fwmodelsheet:_model_sheet:_model_cells:_items:_item[_NLIN]:_VALUE:TEXT) $ "S/N"
						&(ALLTRIM(_SZ2->Z2_CAMPO)) := IIF(EMPTY(_NLIN),"",oxml:_fwmodelsheet:_model_sheet:_model_cells:_items:_item[_NLIN]:_VALUE:TEXT)
					ELSE
						&(ALLTRIM(_SZ2->Z2_CAMPO)) := IIF(EMPTY(_NLIN),0,round(val(oxml:_fwmodelsheet:_model_sheet:_model_cells:_items:_item[_NLIN]:_VALUE:TEXT),2))
					ENDIF
				else
					cquery4	:= " SELECT * FROM "+RetSqlName("TV7")+" TV7 WHERE TV7_FILIAL='"+xFilial("TV7")+"' AND TV7.D_E_L_E_T_=' ' AND TV7_TITULO = '"+ALLTRIM(_SZ2->Z2_FORMULA)+"' "
					TCQUERY cquery4 NEW ALIAS _TV72

					DBSELECTAREA("_TV72")
					IF _TV72->(EOF())
						IF !lAuto
							ALERT("T�tulo "+ALLTRIM(_SZ2->Z2_FORMULA)+" cadastrado n�o encontrado na tabela TV7_CODTAB - "+T01->TV6_CODIGO)
						ENDIF
					ENDIF
					IF ALLTRIM(_SZ2->Z2_INICIA) $ "S/N"
						&(ALLTRIM(_SZ2->Z2_CAMPO)) := ALLTRIM(_SZ2->Z2_INICIA)
					ELSE
						&(ALLTRIM(_SZ2->Z2_CAMPO)) := VAL(ALLTRIM(_SZ2->Z2_INICIA))
					ENDIF
					_TV72->(DBCLOSEAREA())
				ENDIF
				_TV7->(DBCLOSEAREA())

			else
				&(ALLTRIM(_SZ2->Z2_CAMPO)) := &(_SZ2->Z2_FORMULA)
			ENDIF
			_SZ2->(DBSKIP())
		ENDDO
		_SZ2->(DBCLOSEAREA())
		DBSELECTAREA("SZ3")
		Reclock("SZ3",.T.)
		SZ3->Z3_FILIAL		:= T01->TFF_FILIAL
		SZ3->Z3_CONTRAT 	:= T01->CN9_NUMERO
		SZ3->Z3_REVISAO		:= T01->CN9_REVISA
		SZ3->Z3_LOCAL   	:= T01->TFF_LOCAL
		SZ3->Z3_CODRH   	:= T01->TFF_COD

		cquery2 := "SELECT * FROM "+RetSqlName("SZ2")+" WHERE Z2_FILIAL = ' ' AND Z2_ROTINA = 'RGSER002' AND Z2_TIPO = 'C' "

		TCQUERY cquery2 NEW ALIAS _SZ2

		DBSELECTAREA("_SZ2")
		WHILE !_SZ2->(EOF())
			//_NLIN:= aScan(oxml:_fwmodelsheet:_model_sheet:_model_cells:_items:_item,{|x| AllTrim(x:_NICKNAME:TEXT) == ALLTRIM(_SZ2->Z2_FORMULA) })
			&("SZ3->"+ALLTRIM(_SZ2->Z2_CAMPO)) := &(_SZ2->Z2_FORMULA)
			_SZ2->(DBSKIP())
		ENDDO
		SZ3->(MsUnlock())
		_SZ2->(DBCLOSEAREA())
		//Reclock("TFF",.F.)
		//TFF->TFF_YEXPO1 := "S"
		//TFF->(MsUnlock())
/*
		SZ3->Z3_RECBRUT		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_RECBRUT","Z2_FORMULA")))
		SZ3->Z3_PIS    		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_PIS"    ,"Z2_FORMULA")))
		SZ3->Z3_COFINS 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_COFINS" ,"Z2_FORMULA")))
		SZ3->Z3_ISS    		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_ISS"    ,"Z2_FORMULA")))
		SZ3->Z3_RECLIQU		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_RECLIQU","Z2_FORMULA")))
		SZ3->Z3_CUSTODI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_CUSTODI","Z2_FORMULA")))
		SZ3->Z3_MONTA  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_MONTA"  ,"Z2_FORMULA")))
		SZ3->Z3_QTDFUN 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_QTDFUN" ,"Z2_FORMULA")))
		SZ3->Z3_SAL    		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_SAL"    ,"Z2_FORMULA")))
		SZ3->Z3_SALTOT 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_SALTOT" ,"Z2_FORMULA")))
		SZ3->Z3_ADCPER 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_ADCPER" ,"Z2_FORMULA")))
		SZ3->Z3_ADCNOT 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_ADCNOT" ,"Z2_FORMULA")))
		SZ3->Z3_ADCHNR 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_ADCHNR" ,"Z2_FORMULA")))
		SZ3->Z3_ADCIJNO		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_ADCIJNO","Z2_FORMULA")))
		SZ3->Z3_TOTENCP		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_TOTENCP","Z2_FORMULA")))
		SZ3->Z3_TURNOV 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_TURNOV" ,"Z2_FORMULA")))
		SZ3->Z3_PERENCA		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_PERENCA","Z2_FORMULA")))
		SZ3->Z3_MONTB  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_MONTB"  ,"Z2_FORMULA")))
		SZ3->Z3_BENVTR 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_BENVTR" ,"Z2_FORMULA")))
		SZ3->Z3_BENVAL 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_BENVAL" ,"Z2_FORMULA")))
		SZ3->Z3_BENCB  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_BENCB"  ,"Z2_FORMULA")))
		SZ3->Z3_BENPLS 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_BENPLS" ,"Z2_FORMULA")))
		SZ3->Z3_MONTC  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_MONTC"  ,"Z2_FORMULA")))
		SZ3->Z3_INSFARD		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSFARD","Z2_FORMULA")))
		SZ3->Z3_INSEPI 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSEPI" ,"Z2_FORMULA")))
		SZ3->Z3_INSTREI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSTREI","Z2_FORMULA"))) 
		SZ3->Z3_INSMC  		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSMC"  ,"Z2_FORMULA")))
		SZ3->Z3_INSEQUI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSEQUI","Z2_FORMULA")))
		SZ3->Z3_INSCELU		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSCELU","Z2_FORMULA")))
		SZ3->Z3_INSRADI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSRADI","Z2_FORMULA")))
		SZ3->Z3_INSVEIC		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSVEIC","Z2_FORMULA")))
		SZ3->Z3_INSCOMB		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSCOMB","Z2_FORMULA")))
		SZ3->Z3_INSSEGV		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSSEGV","Z2_FORMULA")))
		SZ3->Z3_INSCOLB		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSCOLB","Z2_FORMULA")))
		SZ3->Z3_INSSUPR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSSUPR","Z2_FORMULA")))
		SZ3->Z3_INSDEPR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSDEPR","Z2_FORMULA")))
		SZ3->Z3_INSMUNI		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSMUNI","Z2_FORMULA")))
		SZ3->Z3_INSBASR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSBASR","Z2_FORMULA")))
		SZ3->Z3_INSMOTO		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSMOTO","Z2_FORMULA")))
		SZ3->Z3_INSGUAR		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSGUAR","Z2_FORMULA")))
		SZ3->Z3_INSARMA		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSARMA","Z2_FORMULA")))
		SZ3->Z3_INSTONF		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_INSTONF","Z2_FORMULA")))
		SZ3->Z3_RENTAB 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_RENTAB" ,"Z2_FORMULA")))
		SZ3->Z3_PERMAR 		:= &(ALLTRIM(POSICIONE("SZ2",1,XFILIAL("SZ2")+"Z3_PERMAR" ,"Z2_FORMULA")))
*/



		T01->(DbSkip())
	EndDo
	T01->(DBCloseArea())


Return

