#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"

/*/{Protheus.doc} RLTGPE01
//TODO Descrição auto-gerada.
@author Levy
@since 25/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

user function RLTGPE01()
	Local oReport 
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
return

static function ReportDef()
	Local oReport
	Local oSection1
	Local oSection2 //dados do empregado , funcoes, folgas	
	Local oSection3 //locacao e cnpj 
	Local oSection4 // assinaturas e rubricas
	Local oSection5 // dias da semana, entrada, saida, intervalo, assinatura
	
	//TFL , YCC
	Private cPerg := "RLTGPE01"
	
	AjustaSX1(cPerg)
	Pergunte(cPerg, .F.)
	
	oReport := TReport():New("RLTSRV001","Horário de trabalho",cPerg, {|oReport| ReportPrint(oReport)},"Impressao da folha de frequencia dos funcionários.")
	oReport:HideParamPage() 
	//oReport:HideHeader()
	oReport:SetPortrait()
	oReport:nFontBody := 8
	oReport:SetLineHeight(45)
	
	oSection1 := TRSection():New(oReport, OemToAnsi("Empresa"), {},,,,,,/* lHeaderPage */,.T.,.T.,,,,,.T.,,,,,)
	TRCell():New(oSection1,"MO_FILIAL"," ","FILIAL","@!",35,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	TRCell():New(oSection1,"MO_CGC"," ","CNPJ","@!",20,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER")
	TRCell():New(oSection1,"MO_ENDCOB"," ","ENDERECO","@!",35,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER")
	
	oSection2 := TRSection():New(oReport, OemToAnsi("Informações Pessoais"), {},,,,,,,.F.,.T.,,,,,.F.,,,,,)
	TRCell():New(oSection2,"MATRICULA"," ","MATRICULA","@!",10,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	TRCell():New(oSection2,"EMPREGADO"," ","EMPREGADO","@!",60,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",,"LEFT" )
	TRCell():New(oSection2,"CTPS"," ","CTPS","@!",17,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	TRCell():New(oSection2,"HORARIOS"," ","HORARIO","@!",40,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	TRCell():New(oSection2,"INTERVALOR"," ","INTERVALOR","@!",20,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
//	TRCell():New(oSection2,"INTERVALO"," ","INTERVALO","@!",20,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
//	TRCell():New(oSection2,"FLGSEMANAL"," ","FOLGA SEMANAL","@!",20,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	TRCell():New(oSection2,"FUNCAO"," ","FUNCAO","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	TRCell():New(oSection2,"PERIODO"," ","PERIODO","@!",35,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	
	oSection3 := TRSection():New(oReport, OemToAnsi("Locação"), {},,,,,,,.T.,.T.,,,,,.T.,,,,,)
	TRCell():New(oSection3,"CTT"," ","CTT","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",,"LEFT" )
	TRCell():New(oSection3,"CTT_DESC"," ","DESCRICAO","@!",50,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",,"LEFT" )
	TRCell():New(oSection3,"RAZAO"," ","LOCACAO","@!",50,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",,"LEFT" )
	
	oSection4 := TRSection():New(oReport, OemToAnsi(" "), {},/*<aOrder> */,/* <lLoadCells>*/,/* <lLoadOrder> */,;
							/* <uTotalText> */,/* <lTotalInLine> */,/* <lHeaderPage> */,/* <lHeaderBreak> */.T.,.T.,/*<lLineBreak>*/,,,,.T.,,,,,)
	TRCell():New(oSection4,"ASSRUB"," "," ","@!",45,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	
	oSection5 := TRSection():New(oReport, OemToAnsi("Horários"), {},,,,,,,.T.,.T.,,,,,.T.,,,,,)
	TRCell():New(oSection5,"DIA"," ","DIA","@!",5,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER")
	TRCell():New(oSection5,"ENTRADA"," ","ENTRADA","@!",15,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",,"CENTER")
	TRCell():New(oSection5,"INTERVALO"," ","INTERVALO","@!",29,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",,"CENTER")
	TRCell():New(oSection5,"SAIDA"," ","SAIDA","@!",15,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",,"CENTER")
	TRCell():New(oSection5,"ASSINATURA"," ","ASSINATURA","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER" )
	
	oSection6 := TRSection():New(oReport, OemToAnsi("Assinaturas"), {},,,,,,,.T.,.T.,,,,,.T.,,,,,)
	TRCell():New(oSection6,"EMPREGADOR"," ","","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER")
	TRCell():New(oSection6,"EMPREGADO"," ","","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER")
	TRCell():New(oSection6,"FISCAL"," ","","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/, "CENTER",,"CENTER")
	
	oSection7 := TRSection():New(oReport, OemToAnsi("Observação"), {},,,,,,,.T.,.T.,,,,,.T.,,,,,)
	TRCell():New(oSection7,"OBS"," ", OemToAnsi("OBSERVAÇÃO"),"@!",100,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER",.T.,"CENTER",,,.T.)
	
	oSection1:SetLinesBefore(5)
	oSection1:SetPageBreak(.F.)
	oSection1:SetLineStyle() // imprime a secao na linha
	oSection2:SetPageBreak(.F.)	
	oSection2:SetLineStyle()
	oSection3:SetPageBreak(.F.)	
	oSection3:SetLineStyle()
	oSection4:SetPageBreak(.F.)
	oSection5:SetPageBreak(.F.)
	oSection6:SetLinesBefore(3)
	oSection6:SetPageBreak(.F.)
	oSection6:HeaderBreak(.F.)
	oSection6:SetHeaderSection(.F.)
	oSection7:SetPageBreak(.F.)
	
return oReport


static function ReportPrint(oReport)
	Local nJ
	Local nK
	Local oSection
	Local nPos
	Local aDias := {}
	Local dProxDt
	Local cQuery
	Local aRegs := {}
	Local cHora
	Local nPos
	Local aPergs := {}
	Local bOk := {|| .T.}
	Local aRet := {}
	Local nTot
	Local nCont := 1
	Local nMesAtual := iif(Empty(mv_par06), month(dDataBase), mv_par06)
	Local nAnoAtual := iif(Empty(mv_par07), year(dDataBase), mv_par07)
	Local aEmpresas := FWLoadSM0()
	Local cEmpPar1 := mv_par01
	Local cEmpPar2 := mv_par02
	Local cEmpini := iif(Empty(mv_par01), "01", Substr(mv_par01, 1, 2))
	Local cEmpFim := iif(Empty(mv_par02), "01", Substr(mv_par02, 1, 2))
	Local cObs := " SR (A). EMPREGADO (A) EVITAR RASURAS, UTILIZAÇÃO DE CORRETIVO E/OU QUALQUER OUTRA EMENDA AO ASSINAR A FOLHA DE FREQUÊNCIA. ESCLARECEMOS "
	cObs += " QUE ESSE CUIDADO SE DEVE A VERDADE DAS INFORMAÇÕES INDICADAS. "
	
	dProxDt := CtoD("01/"+cValToChar(nMesAtual)+"/"+cValToChar(nAnoAtual))
	dDtAux := dProxDt
	while(Month(dDtAux) == Month(dProxDt))
		aAdd(aDias, {cValToChar(Day(dDtAux))+" "+getWeekDay(dDtAux), "_________:__________", ;
					"_________:_________|_________:_________",;
					"__________:__________", "__________________________________________"})
		dDtAux += 1
	endDo
	
	cQuery := FilQuery(dProxDt, LastDate(dProxDt), cEmpPar1, cEmpPar2)
	
	MpSysOpenQuery(cQuery, "ATENDENTES")
	nTot := ATENDENTES->(RECCOUNT())
	
	if (ATENDENTES->(EOF()))
		MsgInfo("Não há dados para serem mostrados. Verifique os parâmetros.")
		ATENDENTES->(dbCloseArea())
		return
	endIf
	
	oReport:setMeter(nTot)
	while !(ATENDENTES->(EOF()))
		oReport:SetMsgPrint("Imprimindo registro de numero "+cValToChar(nCont++)+"...")
		oReport:IncMeter()
		
		nPos := aScan(aEmpresas, {|x| x[1] == cEmpAnt .and. x[2] == cEmpini+"0101" })
		cHora := RTRIM(cValToChar(ATENDENTES->PJ_ENTRA1)) + "-" + RTRIM(cValToChar(ATENDENTES->PJ_SAIDA1)) + " a " ;
		 		+ RTRIM(cValToChar(ATENDENTES->PJ_ENTRA2)) + "-" + RTRIM(cValToChar(ATENDENTES->PJ_SAIDA2))
		
		oSection := oReport:Section(1)
		oSection:Init()
		oSection:Cell("MO_FILIAL"):setValue( aEmpresas[nPos][7]  )
		oSection:Cell("MO_CGC"):setValue( aEmpresas[nPos][18] )
		oSection:Cell("MO_ENDCOB"):setValue( Posicione("SM0",1,cEmpAnt + aEmpresas[nPos][2],"M0_ENDCOB") )
		oSection:PrintLine()
		oSection:Finish()
		oReport:ThinLine()
		
		//SECAO 2
		oSection := oReport:Section(2)
		oSection:Init()
		oSection:Cell("MATRICULA"):setValue( RTRIM(ATENDENTES->RA_MAT) )
		oSection:Cell("EMPREGADO"):setValue( RTRIM(ATENDENTES->RA_NOME) )
		oSection:Cell("CTPS"):setValue(ATENDENTES->CTPS)
		oSection:Cell("HORARIOS"):setValue( RTRIM(ATENDENTES->R6_DESC) )
		oSection:Cell("INTERVALOR"):setValue( cHora )
		oSection:Cell("FUNCAO"):setValue(RTRIM(ATENDENTES->RJ_DESC))
		oSection:Cell("PERIODO"):setValue( DtoC(dProxDt) + " a " + DtoC(LastDate(dProxDt)))
		oSection:PrintLine()
		oSection:Finish()
		oReport:ThinLine()
		
		//SECAO 3
		oSection := oReport:Section(3)
		oSection:Init()
		oSection:Cell("RAZAO"):setValue( RTRIM(ATENDENTES->CTT_DESC01) )
		oSection:Cell("CTT"):setValue(ATENDENTES->RA_CC)
		oSection:Cell("CTT_DESC"):setValue( RTRIM(ATENDENTES->CTT_DESC01) )
		oSection:PrintLine()
		oSection:Finish()
//		oReport:ThinLine()
		
		//SEÇÃO 4
		oSection := oReport:Section(4)
		oSection:Init()
		oSection:Cell("ASSRUB"):setValue("Assinaturas e Rubricas")
		oSection:PrintLine()
		oSection:Finish()
		oReport:ThinLine()
		
		//SEÇÃO 5      
		oSection := oReport:Section(5)	
	    oSection:Init()
	    For nJ:= 1 to len(aDias)
	        If oReport:Cancel()
	            Exit
	        EndIf
	             
	        oSection:Cell("DIA"):SetValue(aDias[nJ][1])
	        oSection:Cell("ENTRADA"):SetValue(aDias[nJ][2])
	        oSection:Cell("INTERVALO"):SetValue(aDias[nJ][3])
	        oSection:Cell("SAIDA"):SetValue(aDias[nJ][4])
	        oSection:Cell("ASSINATURA"):SetValue(aDias[nJ][5])
	        oSection:PrintLine()
	    Next nJ
	    oSection:Finish()
	    
	    //SECAO 6
		oSection := oReport:Section(6)
		oSection:Init()
		oSection:Cell("EMPREGADOR"):setValue( "_____________________________" )
		oSection:Cell("EMPREGADO"):setValue( "_____________________________" )
		oSection:Cell("FISCAL"):setValue( "_____________________________" )
		oSection:PrintLine()
		oSection:Cell("EMPREGADOR"):setValue( "ASSINATURA DO EMPREGADOR" )
		oSection:Cell("EMPREGADO"):setValue( "ASSINATURA DO EMPREGADO" )
		oSection:Cell("FISCAL"):setValue( "FISCAL" )
		oSection:PrintLine()	
		oSection:Finish()
		
		//SECAO 7
		oSection := oReport:Section(7)
		oSection:Init()
		oSection:Cell("OBS"):setValue( OemToAnsi(cObs) )		
		oSection:PrintLine()
		oSection:Finish()
	    
	    oReport:EndPage()
	    ATENDENTES->(dbskip())
	    if !ATENDENTES->(EOF())
	    	oReport:StartPage()
	    endIf
		
	endDo
	ATENDENTES->(dbCloseArea())
	
return 

static function AjustaSX1(cPerg)
	aHelpPor :={}
	aHelpEng :={}
	aHelpSpa :={}		

	u_PutSx1(cPerg, "01","Filial de?"     ,"","","mv_ch1",'C',GetSx3Cache("E1_FILIAL","X3_TAMANHO"),0,0,"G","","SM0"   ,"","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	u_PutSx1(cPerg, "02","Filial até?"    ,"","","mv_ch2",'C',GetSx3Cache("E1_FILIAL","X3_TAMANHO")	,0,0,"G","","SM0"   ,"","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	u_PutSx1(cPerg, "03","Matricula ?"  	,"","","mv_ch3",TamSX3("RA_MAT")[3],GetSx3Cache("RA_MAT","X3_TAMANHO")	,0,0,"G","","SRA","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	u_PutSx1(cPerg, "04","Centro de custo de ?"  	,"","","mv_ch4",TamSX3("CTT_CUSTO")[3],GetSx3Cache("CTT_CUSTO","X3_TAMANHO")	,0,0,"G","","CTT","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	u_PutSx1(cPerg, "05","Centro de custo até ?"  	,"","","mv_ch5",TamSX3("CTT_CUSTO")[3],GetSx3Cache("CTT_CUSTO","X3_TAMANHO")	,0,0,"G","","CTT","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	u_PutSx1(cPerg, "06","Mes?"  	,"","","mv_ch6",'N',2,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	u_PutSx1(cPerg, "07","Ano?"  	,"","","mv_ch7", 'N',4,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
return 

static function FilQuery( DtIni, DtFim, cEmp1, cEmp2)
	Local cQuery := ""
//	cQuery := "SELECT DISTINCT ABB.ABB_FILIAL,SRA.RA_MAT,SRA.RA_NOME, ABB_DTINI,ABB.ABB_CODTEC, RTRIM(SRA.RA_NUMCP) || '/' || SRA.RA_SERCP || SRA.RA_UFCP AS CTPS,"
//	cQuery += "ABQ.ABQ_FUNCAO, SRJ.RJ_DESC ,TFF.TFF_TURNO, ABB.ABB_LOCAL,ABS.ABS_DESCRI,CTT.CTT_CUSTO, SPJA.PJ_ENTRA1, SPJA.PJ_SAIDA1, SPJA.PJ_ENTRA2, SPJA.PJ_SAIDA2"
//	cQuery += "FROM "+ RETSQLNAME("ABB") + " ABB "
//	cQuery += "JOIN "+ RETSQLNAME("ABS") +" ABS ON "
//	cQuery += "ABS.ABS_LOCAL = ABB.ABB_LOCAL AND ABS.D_E_L_E_T_ = ' ' AND ABS.ABS_FILIAL = '      ' "
//	cQuery += "JOIN "+RETSQLNAME('AA1')+" AA1 ON "
//	cQuery += "AA1.AA1_CODTEC = ABB.ABB_CODTEC AND AA1.D_E_L_E_T_ = ' '  AND AA1.AA1_FILIAL = ABB.ABB_FILIAL "
//	cQuery += "JOIN "+RETSQLNAME('SRA')+" SRA ON "
//	cQuery += "SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_FILIAL = ABB.ABB_FILIAL "
//	cQuery += "JOIN "+RETSQLNAME('CTT')+" CTT ON "
//	cQuery += "CTT.CTT_CUSTO = AA1.AA1_CC AND CTT.D_E_L_E_T_ = ' '  AND CTT.CTT_FILIAL = SUBSTRING(ABB.ABB_FILIAL, 1, 2) "
//	cQuery += "JOIN "+RETSQLNAME('TFL')+" TFL ON "
//	cQuery += "TFL.TFL_LOCAL = ABB.ABB_LOCAL AND TFL.TFL_YCC <> ' ' AND TFL.D_E_L_E_T_ = ' ' AND TFL.TFL_FILIAL = ABB.ABB_FILIAL "
//	cQuery += "JOIN "+RETSQLNAME('ABQ')+" ABQ ON "
//	cQuery += "ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND ABQ.D_E_L_E_T_ = ' ' AND ABQ.ABQ_FILIAL = SUBSTRING(ABB.ABB_FILIAL, 1, 4) "
//	cQuery += "JOIN "+RETSQLNAME('SRJ')+" SRJ ON "
//	cQuery += "SRJ.RJ_FUNCAO = ABQ.ABQ_FUNCAO AND SRJ.D_E_L_E_T_ = ' ' AND SRJ.RJ_FILIAL = SUBSTRING(ABB.ABB_FILIAL, 1, 2) "
//	cQuery += "JOIN "+RETSQLNAME('TFF')+" TFF ON "
//	cQuery += "TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_TURNO <> ' ' AND TFF.D_E_L_E_T_ = ' ' AND TFF.TFF_FILIAL = ABB.ABB_FILIAL "
//	cQuery += "JOIN "+RETSQLNAME('SR6')+" SR6 ON "
//	cQuery += "SR6.R6_TURNO = TFF.TFF_TURNO AND SR6.D_E_L_E_T_ = ' ' AND SR6.R6_FILIAL = SUBSTRING(ABB.ABB_FILIAL, 1, 2) "
//	cQuery += "LEFT JOIN "+RETSQLNAME('SPJ')+" SPJ ON "
//	cQuery += "SPJ.PJ_TURNO=TFF.TFF_TURNO AND SPJ.PJ_TPDIA = 'S' AND SPJ.PJ_DIA =DATEPART(DW,ABB.ABB_DTINI) AND SPJ.D_E_L_E_T_=' ' AND SPJ.PJ_FILIAL = SUBSTRING(ABB.ABB_FILIAL, 1, 2) "
//	cQuery += "LEFT JOIN "+RETSQLNAME('SPJ')+" SPJA ON "
//	cQuery += "SPJA.PJ_TURNO=TFF_TURNO AND SPJA.PJ_TPDIA = 'S' AND SPJA.PJ_DIA =DATEPART(DW,ABB_DTINI) AND SPJA.PJ_SEMANA = SPJ.PJ_SEMANA  AND SPJA.D_E_L_E_T_=' ' AND SPJA.PJ_FILIAL=SUBSTRING(ABB.ABB_FILIAL, 1, 2) "
//	cQuery += "WHERE  ABB.ABB_DTINI >= '"+DtoS(DtIni)+"' AND ABB.ABB_DTFIM <= '"+DtoS(DtFim)+"' AND ABB.D_E_L_E_T_ = ' ' AND ABB.ABB_FILIAL BETWEEN '"+cEmp1+ "' AND '"+ cEmp2+"' "
	
	
	cQuery += "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, MAX(ABB_DTINI) AS FIM,ABB.ABB_CODTEC,RA_CC, RTRIM(SRA.RA_NUMCP) || '/' || SRA.RA_SERCP || SRA.RA_UFCP AS CTPS, ABB.ABB_LOCAL "
	cQuery += ",ABS.ABS_DESCRI, CTT.CTT_CUSTO, CTT.CTT_DESC01, SRA.RA_CODFUNC ,RJ_DESC, R6_DESC, SRA.RA_TNOTRAB, SPJ.PJ_ENTRA1, SPJ.PJ_SAIDA1, SPJ.PJ_ENTRA2, SPJ.PJ_SAIDA2,SRA.R_E_C_N_O_,COUNT(*) OVER(PARTITION BY RA_FILIAL) AS CONT "
	cQuery += "FROM "+RETSQLNAME('SRA')+" SRA "
	cQuery += "LEFT JOIN "+RETSQLNAME('SRJ')+" SRJ ON "
	cQuery += "SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.D_E_L_E_T_ = ' ' AND SRJ.RJ_FILIAL = SUBSTRING(RA_FILIAL, 1, 2) "
	cQuery += "LEFT JOIN "+RETSQLNAME('CTT')+" CTT ON "
	cQuery += "CTT.CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' ' AND CTT.CTT_FILIAL = SUBSTRING(SRA.RA_FILIAL, 1, 2) "
	cQuery += "LEFT JOIN "+RETSQLNAME('SR6')+" SR6 ON "
	cQuery += "SR6.R6_TURNO = RA_TNOTRAB AND SR6.R6_FILIAL = SUBSTRING(RA_FILIAL, 1, 2) AND SR6.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+RETSQLNAME('AA1')+" AA1 ON "
	cQuery += "AA1.AA1_CODTEC = SRA.RA_FILIAL + SRA.RA_MAT AND AA1.AA1_FILIAL = SRA.RA_FILIAL AND AA1.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+RETSQLNAME('ABB')+" ABB ON "
	cQuery += "ABB.ABB_CODTEC = AA1_CODTEC AND ABB.D_E_L_E_T_ = ' ' AND ABB.ABB_FILIAL = AA1.AA1_FILIAL AND ABB.ABB_DTINI >= '"+DtoS(DtIni)+"' AND ABB.ABB_DTFIM <= '"+DtoS(DtFim)+"' "
	cQuery += "LEFT JOIN "+RETSQLNAME('ABS')+" ABS ON "
	cQuery += "ABS.ABS_LOCAL = ABB.ABB_LOCAL AND ABS.D_E_L_E_T_ = ' ' AND ABS.ABS_FILIAL = '      ' "
	cQuery += "LEFT JOIN "+RETSQLNAME('ABQ')+" ABQ ON "
	cQuery += "ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND ABQ.D_E_L_E_T_ = ' ' AND ABQ.ABQ_FILIAL = SUBSTRING(ABB.ABB_FILIAL, 1, 4) " //ATENTAR PQ O ITEM AGORA É 6 DIGITOS
	cQuery += "LEFT JOIN "+RETSQLNAME('TFF')+" TFF ON "
	cQuery += "TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.D_E_L_E_T_ = ' ' AND TFF.TFF_FILIAL = ABB.ABB_FILIAL "
	cQuery += "LEFT JOIN "+RETSQLNAME('SPJ')+" SPJ ON "
	cQuery += "SPJ.PJ_TURNO = SRA.RA_TNOTRAB AND SPJ.PJ_FILIAL = SUBSTRING(SRA.RA_FILIAL, 1, 2) AND SPJ.PJ_TPDIA= 'S' "
	cQuery += "WHERE SRA.RA_SITFOLH <> 'D' AND SRA.D_E_L_E_T_ = ' ' AND SRA.RA_FILIAL BETWEEN '"+cEmp1+ "' AND '"+ cEmp2+"' "
	
	if !Empty(mv_par03)
		cQuery += " AND SRA.RA_MAT = " + mv_par03
	endIf
	if !Empty(mv_par04) .and. !Empty(mv_par05)
		cQuery += " AND CTT.CTT_CUSTO BETWEEN '" + mv_par04 + "' AND '"+mv_par05+"'"
	endIf
	cQuery += " GROUP BY SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME,ABB.ABB_CODTEC,RA_CC,CTT.CTT_DESC01,SRA.RA_NUMCP,SRA.RA_SERCP,SRA.RA_UFCP,ABB.ABB_LOCAL,ABS.ABS_DESCRI,CTT.CTT_CUSTO,SRA.RA_CODFUNC,RJ_DESC,R6_DESC,SRA.RA_TNOTRAB " 
	cQuery += " ,SPJ.PJ_ENTRA1, SPJ.PJ_SAIDA1, SPJ.PJ_ENTRA2, SPJ.PJ_SAIDA2,SRA.R_E_C_N_O_ "
	//cQuery += " ORDER BY RA_FILIAL, FIM, RA_NOME "
	cQuery += " ORDER BY RA_FILIAL, RA_CC , RA_NOME ,FIM "
	cQuery := ChangeQuery(cQuery)
//	MsgInfo(cQuery)
	
return cQuery

static function getWeekDay(dDate)
	local aDays := {"DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SAB"}
return aDays[DOW(dDate)]
