#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.Ch"
#Include "Totvs.Ch"
#Include "Rwmake.Ch"
#Include "TbiConn.Ch"
#Include "TbiCode.Ch"
#INCLUDE "FWPrintSetup.ch"


user function RSERV033()

	Local oReport

	Local aParam		 := {}
	Local cFilde         := "      "
	Local cFilate        := "      "
	Local cMatde         := "      "
	Local cMatate        := "      " 
	Local cPeriod		 := "      "
	Local aBeneficio	 := {'','VT','VA','CB'}

	private aRet  		:= {}


	aAdd(aParam,{1,"Filial De"      ,cFilde 	,"@! 999999",".T.","SM0",".T.",80,.F.})
	aAdd(aParam,{1,"Filial Ate"	    ,cFilate	,"@! 999999",".T.","SM0",".T.",80,.F.})
	aAdd(aParam,{1,"Matricula De"   ,cMatde	    ,GetSx3Cache("RA_MAT","X3_PICTURE"),".T.","SRA",".T.",40,.F.})
	aAdd(aParam,{1,"Matricula Ate"	,cMatate	,GetSx3Cache("RA_MAT","X3_PICTURE"),".T.","SRA",".T.",40,.F.})
	aAdd(aParam,{1,"Periodo"        ,cPeriod 	,"@! 999999",".T.","",".T.",60,.F.})
	aAdd(aParam,{2,"Beneficios"		,,aBeneficio,80,,.F.,})


	If !ParamBox(aParam ,"Parametros ",aRet)      
		return .T.  
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()	

return 

Static Function ReportDef()

	Local oReport
	Local oSection 
	Local aOrdem    := {}



	oReport := TReport():New("RSERV033","Conferencia Beneficio",,{|oReport| ReportPrint(oReport,aOrdem)},"Conferencia Beneficio")
	//oReport:SetLandscape() //Paisagem   
	oReport:SetPortrait() // retrato

	oSection:= TRSection():New(oReport,OemToAnsi("Notas"),,aOrdem) 
	TRCell():New(oSection,"RA_FILIAL"     ,,"Filial"                ,,6)
	TRCell():New(oSection,"RA_MAT"        ,,"Matricula"           	,,10)
	TRCell():New(oSection,"RA_NOME"       ,,"Nome"	                ,,40)
	TRCell():New(oSection,"RA_CODFUNC"    ,,"Cod. Funcao"		    ,,10)
	TRCell():New(oSection,"RJ_DESC"       ,,"Desc. Funcao" 		    ,,20)
	TRCell():New(oSection,"RA_CC"         ,,"Centro de Custo"	    ,,20)
	TRCell():New(oSection,"RA_DESCC"      ,,"Desc C. Custos"	    ,,20)
	TRCell():New(oSection,"RA_TNOTRAB"    ,,"Cod. Turno"         	,,10)
	TRCell():New(oSection,"RA_SEQTURN"    ,,"Sequencia Turno"      	,,10)
	TRCell():New(oSection,"R6_DESC"       ,,"Desc. Turno"      		,,20)
	TRCell():New(oSection,"RCF_DUTEIS"    ,,"Dias Uteis"      	    ,,10)
	TRCell():New(oSection,"RA_DIASFAL"    ,,"Dias de Faltas"      	,,10)
	TRCell():New(oSection,"RA_DIASFER"    ,,"Dias de Ferias"      	,,10)
	TRCell():New(oSection,"RA_CODBEN"     ,,"Cod. Beneficio"      	,,10)
	TRCell():New(oSection,"RA_DESCBEN"    ,,"Desc. Beneficio"      	,,20)
	TRCell():New(oSection,"RA_VALUNIT"    ,,"Valor Unitario"      	,,20)
	TRCell():New(oSection,"RA_DIASOK"     ,,"Dias Sem Ajuste"      	,,20)
	TRCell():New(oSection,"RA_DIAINFO"    ,,"Dias Informados"      	,,20)
	TRCell():New(oSection,"RA_QTDVALE"    ,,"Numero de Vales"      	,,20)
	TRCell():New(oSection,"RA_VALCALC"    ,,"Valor Calculado"      	,,20)
	TRCell():New(oSection,"RA_PEDIDO"     ,,"Numero do Pedido"      ,,20)



return(oReport)


//------------------------------------------------//
//FUN플O: IMPRESSAO								  //
//------------------------------------------------//
Static Function ReportPrint(oReport,aOrdem)

	Local oSection  := oReport:Section(1)   
	Local nOrdem    := oSection:GetOrder()   
	Local cPer      := aret[5]
	Local cPerUm    := ""
	Local cAno      := ""
	Local cMes      := ""

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao do titulo do relatorio                             |
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	oReport:SetTitle(oReport:Title())

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� GERA플O DOS REGISTROS			                             |
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	// tratamento dos periodos posteriores
	//if substr(cPer,5,2) == '12'
	//	cPerUm := CVALTOCHAR( VAL(substr(cPer,1,4)) +  1 )+"01"
	//ELSE 	
	//	cPerUm := CVALTOCHAR( VAL(cPer) +  1 )
	//endif

	cPerUm := cPer
	cAno := substr(cPer,1,4)
	cMes := substr(cPer,5,2)
	if aRet[6] == "VT" // VT 


		cQuery:=" SELECT RA_FILIAL FILIAL , RA_MAT MATRICULA , RA_NOME NOME ,RA_CODFUNC COD_FUNCAO ,RJ_DESC DESC_FUNCAO ,RA_CC ,CTT_DESC01 ,RA_TNOTRAB TURNO ,RA_SEQTURN SEQ_TURNO ,
		cQuery+=" R6_DESC DESC_TURNO , RCF_DUTEIS DIAS_UTEIS_PERIODO ,DIASF DIAS_FALTAS,DIASFE DIAS_FERIAS, M7_CODIGO CODIGO_VALE , RN_DESC DESC_VALE , RN_VUNIATU VALOR_UNIT_VALE , 
		cQuery+=" DIAS_SEM_AJUSTE ,  DIAS_INFORMADOS ,  Qtd_Vale_Dia,Valor_Calculado ,R0_NROPED NUM_PEDIDO
		cQuery+=" FROM "+RETSQLNAME("SR6")+" SR6 ,"+RETSQLNAME("CTT")+" CTT, "+RETSQLNAME("SRJ")+" SRJ ,"+RETSQLNAME("SRA")+" SRA 
		cQuery+=" LEFT JOIN "+RETSQLNAME("RCF")+" RCF ON RCF.D_E_L_E_T_ = ''  AND  RCF_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RCF_MES = '"+ cMes +"' AND RCF_ANO ='"+ cAno +"' AND RCF_PROCES = RA_PROCES AND RCF_TNOTRA = RA_TNOTRAB  
		cQuery+=" LEFT JOIN 
		cQuery+=" (SELECT RGB_FILIAL , RGB_MAT , sum(RGB_HORAS) DIASF
		cQuery+=" FROM "+RETSQLNAME("RGB")+" RGB
		cQuery+=" WHERE RGB_PD = '201'
		cQuery+=" AND RGB_PERIOD = '"+ cPer +"'
		cQuery+=" AND RGB_ROTEIR = 'FOL'
		cQuery+=" AND RGB.D_E_L_E_T_=''
		cQuery+=" group by RGB_FILIAL , RGB_MAT
		cQuery+=" ) RGB1 ON  RGB1.RGB_FILIAL = RA_FILIAL AND RGB1.RGB_MAT = RA_MAT

		cQuery+=" LEFT JOIN (
		cQuery+=" SELECT RGB_FILIAL , RGB_MAT , sum(RGB_HORAS) DIASFE
		cQuery+=" FROM "+RETSQLNAME("RGB")+" RGB , "+RETSQLNAME("SRV")+" SRV
		cQuery+=" WHERE RGB_PD = RV_COD
		cQuery+=" AND RGB_PERIOD = '"+ cPer +"'
		cQuery+=" AND RGB_ROTEIR = 'FOL'
		cQuery+=" AND RGB.D_E_L_E_T_=''

		cQuery+=" AND RV_CODFOL='0072'
		cQuery+=" AND RV_FILIAL = SUBSTRING(RGB_FILIAL,1,2)
		cQuery+=" AND SRV.D_E_L_E_T_=''
		cQuery+=" group by RGB_FILIAL , RGB_MAT
		cQuery+=" ) RGB2 ON  RGB2.RGB_FILIAL = RA_FILIAL AND RGB2.RGB_MAT = RA_MAT

		cQuery+=" LEFT JOIN (

		cQuery+=" SELECT M7_FILIAL , M7_MAT , M7_TPVALE , M7_CODIGO , RN_DESC , RN_VUNIATU , 
		cQuery+=" R0_DIASPRO DIAS_SEM_AJUSTE ,R0_DPROPIN DIAS_INFORMADOS , R0_QDIAINF VALE_POR_DIA , R0_DUTILM DIAS_UTEIS_MES,
		cQuery+=" R0_QDIACAL Qtd_Vale_Dia ,R0_VALCAL Valor_Calculado , R0_NROPED
		cQuery+=" FROM "+RETSQLNAME("SRN")+" SRN ,"+RETSQLNAME("SM7")+" SM7    
		cQuery+=" LEFT JOIN "+RETSQLNAME("SR0")+" SR0 ON  SR0.D_E_L_E_T_='' AND  R0_FILIAL = M7_FILIAL AND R0_TPVALE = M7_TPVALE AND R0_MAT = M7_MAT
		cQuery+=" WHERE SM7.D_E_L_E_T_=''
		cQuery+=" AND M7_TPVALE = '0'
		cQuery+=" AND SUBSTRING(M7_FILIAL,1,2) = RN_FILIAL 
		cQuery+=" AND M7_CODIGO = RN_COD
		cQuery+=" AND R0_ANOMES = '"+ cPerUm +"'
		cQuery+=" )  TSM7 ON TSM7.M7_FILIAL = RA_FILIAL AND TSM7.M7_MAT = RA_MAT


		cQuery+=" WHERE 
		cQuery+=" SRA.D_E_L_E_T_= ''  AND SRJ.D_E_L_E_T_='' AND CTT.D_E_L_E_T_=''
		cQuery+=" AND RA_SITFOLH NOT IN('D' , 'T') 
		cQuery+=" AND RJ_FILIAL = SUBSTRING(RA_FILIAL , 1,2)
		cQuery+=" AND RJ_FUNCAO = RA_CODFUNC
		cQuery+=" AND M7_CODIGO <> ''
		cQuery+=" AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2)
		cQuery+=" AND CTT_CUSTO = RA_CC
		cQuery+=" AND R6_FILIAL = SUBSTRING(RA_FILIAL ,1,2)
		cQuery+=" AND R6_TURNO = RA_TNOTRAB

		cQuery+=" AND RA_FILIAL BETWEEN  '"+ aRet[1] +"' AND '"+ aRet[2] +"'
		cQuery+=" AND RA_MAT BETWEEN  '"+ aRet[3] +"' AND '"+ aRet[4] +"'


		cQuery+=" ORDER BY RA_FILIAL , RA_MAT

	ELSEif aRet[6] == "VA" // VA 


		cQuery:=" SELECT RA_FILIAL FILIAL , RA_MAT MATRICULA , RA_NOME NOME ,RA_CODFUNC COD_FUNCAO ,RJ_DESC DESC_FUNCAO ,RA_CC ,CTT_DESC01 ,RA_TNOTRAB TURNO ,RA_SEQTURN SEQ_TURNO , 
		cQuery+=" R6_DESC DESC_TURNO , RCF_DUTEIS DIAS_UTEIS_PERIODO ,DIASF DIAS_FALTAS,DIASFE DIAS_FERIAS, M7_CODIGO CODIGO_VALE , RFO_DESCR DESC_VALE , RFO_VALOR VALOR_UNIT_VALE , 
		cQuery+=" DIAS_SEM_AJUSTE ,  DIAS_INFORMADOS ,  Qtd_Vale_Dia,Valor_Calculado ,R0_NROPED NUM_PEDIDO
		cQuery+=" FROM "+RETSQLNAME("SR6")+" SR6 ,"+RETSQLNAME("CTT")+" CTT, "+RETSQLNAME("SRJ")+" SRJ ,"+RETSQLNAME("SRA")+" SRA 
		cQuery+=" LEFT JOIN "+RETSQLNAME("RCF")+" RCF ON RCF.D_E_L_E_T_ = ''  AND  RCF_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RCF_MES = '"+ cMes +"' AND RCF_ANO ='"+ cAno +"' AND RCF_PROCES = RA_PROCES AND RCF_TNOTRA = RA_TNOTRAB  
		cQuery+=" LEFT JOIN 
		cQuery+=" (SELECT RGB_FILIAL , RGB_MAT , sum(RGB_HORAS) DIASF
		cQuery+=" FROM "+RETSQLNAME("RGB")+" RGB
		cQuery+=" WHERE RGB_PD = '201'
		cQuery+=" AND RGB_PERIOD = '"+ cPer +"'
		cQuery+=" AND RGB_ROTEIR = 'FOL'
		cQuery+=" AND RGB.D_E_L_E_T_=''
		cQuery+=" group by RGB_FILIAL , RGB_MAT
		cQuery+=" ) RGB1 ON  RGB1.RGB_FILIAL = RA_FILIAL AND RGB1.RGB_MAT = RA_MAT

		cQuery+=" LEFT JOIN (
		cQuery+=" SELECT RGB_FILIAL , RGB_MAT , sum(RGB_HORAS) DIASFE
		cQuery+=" FROM "+RETSQLNAME("RGB")+" RGB , "+RETSQLNAME("SRV")+" SRV
		cQuery+=" WHERE RGB_PD = RV_COD
		cQuery+=" AND RGB_PERIOD = '"+ cPer +"'
		cQuery+=" AND RGB_ROTEIR = 'FOL'
		cQuery+=" AND RGB.D_E_L_E_T_=''

		cQuery+=" AND RV_CODFOL='0072'
		cQuery+=" AND RV_FILIAL = SUBSTRING(RGB_FILIAL,1,2)
		cQuery+=" AND SRV.D_E_L_E_T_=''
		cQuery+=" group by RGB_FILIAL , RGB_MAT
		cQuery+=" ) RGB2 ON  RGB2.RGB_FILIAL = RA_FILIAL AND RGB2.RGB_MAT = RA_MAT

		cQuery+=" LEFT JOIN (

		cQuery+=" SELECT M7_FILIAL , M7_MAT , M7_TPVALE , M7_CODIGO , RFO_DESCR , RFO_VALOR , 
		cQuery+=" R0_DIASPRO DIAS_SEM_AJUSTE ,R0_DPROPIN DIAS_INFORMADOS , R0_QDIAINF VALE_POR_DIA , R0_DUTILM DIAS_UTEIS_MES,
		cQuery+=" R0_QDIACAL Qtd_Vale_Dia ,R0_VALCAL Valor_Calculado , R0_NROPED
		cQuery+=" FROM "+RETSQLNAME("RFO")+"  RFO ,"+RETSQLNAME("SM7")+"  SM7    
		cQuery+=" LEFT JOIN "+RETSQLNAME("SR0")+" SR0 ON  SR0.D_E_L_E_T_='' AND R0_FILIAL = M7_FILIAL AND R0_TPVALE = M7_TPVALE AND R0_MAT = M7_MAT
		cQuery+=" WHERE SM7.D_E_L_E_T_=''
		cQuery+=" AND M7_TPVALE = '2'
		cQuery+=" AND SUBSTRING(M7_FILIAL,1,2) = RFO_FILIAL 
		cQuery+=" AND M7_CODIGO = RFO_CODIGO
		cQuery+=" AND R0_ANOMES = '"+ cPerUm +"'
		cQuery+=" )  TSM7 ON TSM7.M7_FILIAL = RA_FILIAL AND TSM7.M7_MAT = RA_MAT


		cQuery+=" WHERE 
		cQuery+=" SRA.D_E_L_E_T_= ''  AND SRJ.D_E_L_E_T_='' AND CTT.D_E_L_E_T_=''
		cQuery+=" AND RA_SITFOLH NOT IN('D' , 'T') 
		cQuery+=" AND RJ_FILIAL = SUBSTRING(RA_FILIAL , 1,2)
		cQuery+=" AND RJ_FUNCAO = RA_CODFUNC
		cQuery+=" AND M7_CODIGO <> ''
		cQuery+=" AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2)
		cQuery+=" AND CTT_CUSTO = RA_CC
		cQuery+=" AND R6_FILIAL = SUBSTRING(RA_FILIAL ,1,2)
		cQuery+=" AND R6_TURNO = RA_TNOTRAB

		cQuery+=" AND RA_FILIAL BETWEEN  '"+ aRet[1] +"' AND '"+ aRet[2] +"'
		cQuery+=" AND RA_MAT BETWEEN  '"+ aRet[3] +"' AND '"+ aRet[4] +"'


		cQuery+=" ORDER BY RA_FILIAL , RA_MAT

	ELSEif aRet[6] == "CB" // CESTA B핿ICA

		cQuery:=" SELECT RA_FILIAL FILIAL , RA_MAT MATRICULA , RA_NOME NOME ,RA_CODFUNC COD_FUNCAO ,RJ_DESC DESC_FUNCAO ,RA_CC ,CTT_DESC01 ,RA_TNOTRAB TURNO ,RA_SEQTURN SEQ_TURNO ,
		cQuery+=" R6_DESC DESC_TURNO , RCF_DUTEIS DIAS_UTEIS_PERIODO ,DIASF DIAS_FALTAS,DIASFE DIAS_FERIAS, RIS_COD CODIGO_VALE , RIS_DESC DESC_VALE ,
		cQuery+=" RIS_REF VALOR_UNIT_VALE , DIAS_PROPORCIONAL DIAS_INFORMADOS ,DIAS_PROPORCIONAL  DIAS_SEM_AJUSTE ,DIAS_PROPORCIONAL / 30  Qtd_Vale_Dia , Valor_Calculado , ' ' NUM_PEDIDO
		cQuery+=" FROM "+RETSQLNAME("SR6")+" SR6 ,"+RETSQLNAME("CTT")+" CTT, "+RETSQLNAME("SRJ")+" SRJ ,"+RETSQLNAME("SRA")+" SRA 
		cQuery+=" LEFT JOIN RCF010 RCF ON RCF.D_E_L_E_T_ = ''  AND  RCF_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND RCF_MES = '"+ cMes +"' AND RCF_ANO ='"+ cAno +"' AND RCF_PROCES = RA_PROCES AND RCF_TNOTRA = RA_TNOTRAB  
		cQuery+=" LEFT JOIN 
		cQuery+=" (SELECT RGB_FILIAL , RGB_MAT , sum(RGB_HORAS) DIASF
		cQuery+=" FROM RGB010 RGB
		cQuery+=" WHERE RGB_PD = '201'
		cQuery+=" AND RGB_PERIOD = '"+ cPerUm +"'
		cQuery+=" AND RGB_ROTEIR = 'FOL'
		cQuery+=" AND RGB.D_E_L_E_T_=''
		cQuery+=" group by RGB_FILIAL , RGB_MAT
		cQuery+=" ) RGB1 ON  RGB1.RGB_FILIAL = RA_FILIAL AND RGB1.RGB_MAT = RA_MAT

		cQuery+=" LEFT JOIN (
		cQuery+=" SELECT RGB_FILIAL , RGB_MAT , sum(RGB_HORAS) DIASFE
		cQuery+=" FROM "+RETSQLNAME("RGB")+" RGB , "+RETSQLNAME("SRV")+" SRV
		cQuery+=" WHERE RGB_PD = RV_COD
		cQuery+=" AND RGB_PERIOD = '"+ cPerUm +"'
		cQuery+=" AND RGB_ROTEIR = 'FOL'
		cQuery+=" AND RGB.D_E_L_E_T_=''

		cQuery+=" AND RV_CODFOL='0072'
		cQuery+=" AND RV_FILIAL = SUBSTRING(RGB_FILIAL,1,2)
		cQuery+=" AND SRV.D_E_L_E_T_=''
		cQuery+=" group by RGB_FILIAL , RGB_MAT
		cQuery+=" ) RGB2 ON  RGB2.RGB_FILIAL = RA_FILIAL AND RGB2.RGB_MAT = RA_MAT

		cQuery+=" LEFT JOIN (

		cQuery+=" SELECT RIQ_FILIAL , RIQ_MAT , RIQ_TPBENE , RIQ_COD , RIS_DESC , RIS_REF , 
		cQuery+=" RIQ_DIAPRO DIAS_PROPORCIONAL ,RIQ_VALBEN VALOR_CALCULADO ,RIS_COD
		cQuery+=" FROM "+RETSQLNAME("RIQ")+" RIQ , "+RETSQLNAME("RIS")+" RIS 
		cQuery+=" WHERE RIQ.D_E_L_E_T_='' AND RIS.D_E_L_E_T_ = '' 
		cQuery+=" AND RIQ_TPBENE = '81'
		cQuery+=" AND RIQ_COD = RIS_COD
		cQuery+=" AND RIQ_PERIOD = '"+ cPerUm +"'
		cQuery+=" )  TRIQ ON TRIQ.RIQ_FILIAL = RA_FILIAL AND TRIQ.RIQ_MAT = RA_MAT


		cQuery+=" WHERE 
		cQuery+=" SRA.D_E_L_E_T_= ''  AND SRJ.D_E_L_E_T_='' AND CTT.D_E_L_E_T_=''
		cQuery+=" AND RA_SITFOLH NOT IN('D' , 'T') 
		cQuery+=" AND RJ_FILIAL = SUBSTRING(RA_FILIAL , 1,2)
		cQuery+=" AND RJ_FUNCAO = RA_CODFUNC
		cQuery+=" AND RIS_COD <> ''
		cQuery+=" AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2)
		cQuery+=" AND CTT_CUSTO = RA_CC
		cQuery+=" AND R6_FILIAL = SUBSTRING(RA_FILIAL ,1,2)
		cQuery+=" AND R6_TURNO = RA_TNOTRAB

		cQuery+=" AND RA_FILIAL BETWEEN  '"+ aRet[1] +"' AND '"+ aRet[2] +"'
		cQuery+=" AND RA_MAT BETWEEN  '"+ aRet[3] +"' AND '"+ aRet[4] +"'


		cQuery+=" ORDER BY RA_FILIAL , RA_MAT

	Endif

	IF SELECT("TCONF") > 0 
		TCONF->(DBCLOSEAREA())
	ENDIF

	TCQUERY cQuery NEW ALIAS TCONF

	oSection:Init()
	WHILE  TCONF->(!EOF())

		oSection:Cell("RA_FILIAL"  ):SetValue(TCONF->FILIAL)
		oSection:Cell("RA_MAT"     ):SetValue(TCONF->MATRICULA)
		oSection:Cell("RA_NOME"    ):SetValue(ALLTRIM(TCONF->NOME))
		oSection:Cell("RA_CODFUNC" ):SetValue(TCONF->COD_FUNCAO)
		oSection:Cell("RJ_DESC"    ):SetValue(ALLTRIM(TCONF->DESC_FUNCAO))
		oSection:Cell("RA_CC"      ):SetValue(TCONF->RA_CC)
		oSection:Cell("RA_DESCC"   ):SetValue(ALLTRIM(TCONF->CTT_DESC01))
		oSection:Cell("RA_TNOTRAB" ):SetValue(TCONF->TURNO)
		oSection:Cell("RA_SEQTURN" ):SetValue(TCONF->SEQ_TURNO)
		oSection:Cell("R6_DESC"    ):SetValue(ALLTRIM(TCONF->DESC_TURNO))
		oSection:Cell("RCF_DUTEIS" ):SetValue(CVALTOCHAR(TCONF->DIAS_UTEIS_PERIODO))
		oSection:Cell("RA_DIASFAL" ):SetValue(cvaltochar(TCONF->DIAS_FALTAS))
		oSection:Cell("RA_DIASFER" ):SetValue(cvaltochar(TCONF->DIAS_FERIAS))
		oSection:Cell("RA_CODBEN"  ):SetValue(TCONF->CODIGO_VALE)
		oSection:Cell("RA_DESCBEN" ):SetValue(ALLTRIM(TCONF->DESC_VALE))
		oSection:Cell("RA_VALUNIT" ):SetValue(TRANSFORM( TCONF->VALOR_UNIT_VALE , "@E 999.99"))
		oSection:Cell("RA_DIASOK"  ):SetValue(TRANSFORM( TCONF->DIAS_SEM_AJUSTE , "@E 999.99"))
		oSection:Cell("RA_DIAINFO" ):SetValue(TRANSFORM( TCONF->DIAS_INFORMADOS , "@E 999.99"))
		oSection:Cell("RA_QTDVALE" ):SetValue(cvaltochar(TCONF->Qtd_Vale_Dia))
		oSection:Cell("RA_VALCALC" ):SetValue(TRANSFORM( TCONF->Valor_Calculado , "@E 999.99"))
		oSection:Cell("RA_PEDIDO"  ):SetValue(TCONF->NUM_PEDIDO)



		oSection:PrintLine()  //Imprimir a Sec豫o
		oReport:IncMeter(1)


		if oReport:Cancel()
			oSection:Finish()
			TCONF->(dbCloseArea())

			return
		endif

		TCONF->(DBSKIP())

	ENDDO

	TCONF->(dbCloseArea())
	oSection:Finish()


return
