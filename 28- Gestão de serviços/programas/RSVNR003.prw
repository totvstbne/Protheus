#Include 'Protheus.ch'
#include 'TopConn.CH'



User Function RSVNR003()

	Local oReport := Nil
	Local cPerg := Padr("RSVNR003",10)
	
	Pergunte(cPerg,.T.) //SX1
	
	oReport := RptStruc(cPerg)
	oReport:PrintDialog()
Return

Static Function RPTPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cQuery := ""

    oSection1:Init()
	
    cQuery := " SELECT AA1_FILIAL, AA1_CODTEC, AA1_NOMTEC, AA1_CDFUNC, AA1_FUNCAO, RJ_DESC, RA_CC, CTT_DESC01 " 
    cQuery += " FROM "+RetSqlName("AA1")+" " 
    cQuery += " INNER JOIN "+RetSqlName("SRA")+" AS SRA ON RA_FILIAL = '"+xFilial("SRA")+"' AND RA_MAT = AA1_CDFUNC AND RA_SITFOLH <> 'D' AND SRA.D_E_L_E_T_ = ' '"
    cQuery += " INNER JOIN "+RetSqlName("SRJ")+" AS SRJ ON RJ_FILIAL = '"+xFilial("SRJ")+"' AND RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_ = ' '"
    cQuery += " INNER JOIN "+RetSqlName("CTT")+" AS CTT ON CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = ' '"
    cQuery += " LEFT JOIN "+RetSqlName("ABB")+" AS ABB ON ABB_FILIAL = '"+xFilial("ABB")+"' AND ABB_CODTEC = AA1_CODTEC AND  ABB_DTINI >= '"+dtos(MV_PAR03)+"'  AND ABB_DTINI <=  '"+dtos(MV_PAR04)+"'  AND ABB.D_E_L_E_T_ = ' '"
    cQuery += " LEFT JOIN "+RetSqlName("SR8")+" AS SR8 ON R8_FILIAL  = '"+xFilial("SR8")+"' AND R8_MAT = AA1_CDFUNC AND R8_DATAINI <= '"+dtos(MV_PAR03)+"' AND (R8_DATAFIM >= '"+dtos(MV_PAR04)+"' OR R8_DATAFIM = '')  AND SR8.D_E_L_E_T_ = ' '"
    cQuery += " LEFT JOIN "+RetSqlName("SRF")+" AS SRF ON RF_FILIAL  = '"+xFilial("SRF")+"' AND RF_MAT = AA1_CDFUNC AND RF_DATAINI <= '"+dtos(MV_PAR03)+"' AND (RF_DATAINI + RF_DFEPRO1)  >= '"+dtos(MV_PAR04)+"'  AND SRF.D_E_L_E_T_ = ' '"
    cQuery += " WHERE "

    cQuery += " AA1_FILIAL = '"+xFilial("AA1")+"' AND"
    cQuery += " AA1_CODTEC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
    cQuery += " (ABB_CODTEC IS NULL) AND"
    cQuery += " (R8_MAT IS NULL) AND "
    cQuery += " (RF_MAT IS NULL)"
    cQuery := ChangeQuery(cQuery)
	
		//Verifica se a tabela ja está aberta.
			If Select("TEMP") <> 0
				DbSelectArea("TEMP")
				DbCloseArea()
			EndIf
			
		TCQUERY cQuery NEW ALIAS "TEMP"
			
			DbSelectArea("TEMP")
			TEMP->(dbGoTop())
			
			oReport:SetMeter(TEMP->(LastRec()))
			
		While !EOF()
			If oReport:Cancel()
				Exit
			EndIf

			
	/*Imprimindo primeira seção:
		oSection1:Cell("AA1_FILIAL"):SetValue(TEMP->AA1_FILIAL)
		oSection1:Cell("AA1_CODTEC"):SetValue(TEMP->AA1_CODTEC)	
        oSection1:Cell("AA1_NOMTEC"):SetValue(TEMP->AA1_NOMTEC)		
        oSection1:Cell("AA1_CDFUNC"):SetValue(TEMP->AA1_CDFUNC)		
        oSection1:Cell("AA1_FUNCAO"):SetValue(TEMP->AA1_FUNCAO)		
        oSection1:Cell("RJ_DESC"):SetValue(TEMP->RJ_DESC)		
        oSection1:Cell("RA_CC"):SetValue(TEMP->RA_CC)		
        oSection1:Cell("CTT_DESC01"):SetValue(TEMP->CTT_DESC01)	*/	

		oSection1:PrintLine()
        TEMP->(dbSkip())



			
		EndDo
    TEMP->(dbCloseArea())
	oSection1:Finish()
Return


Static Function RPTStruc(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
    Local cHelp := "Lista os atendentes que não possuem agenda projetada no período filtrado"
	
	oReport := TReport():New(cNome,"Atendentes desalocados",cNome,{|oRperot| RPTPRINT(oReport)},cHelp)
	
	oReport:SetPortrait() //Definindo a orientação como retrato
	
	oSection1 := TRSection():New(oReport, "Atendentes",{"AA1"}, NIL,.F.,.T.)
    //oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
	oCell	:= TRCell():New(oSection1,"AA1_FILIAL"		,"TEMP","Filial",,TamSX3("AA1_FILIAL")[1]+2)
	oCell	:= TRCell():New(oSection1,"AA1_CODTEC"	,"TEMP","Cod. Atendente",,TamSX3("AA1_CODTEC")[1]+4)
	oCell	:= TRCell():New(oSection1,"AA1_NOMTEC"	,"TEMP","Nome",,TamSX3("AA1_NOMTEC")[1]+7)
	oCell	:= TRCell():New(oSection1,"AA1_CDFUNC"	,"TEMP","Matrícula",,TamSX3("AA1_CDFUNC")[1]+2)
	oCell	:= TRCell():New(oSection1,"AA1_FUNCAO"	,"TEMP"	  ,"Função",,TamSX3("AA1_FUNCAO")[1]+4)
	oCell	:= TRCell():New(oSection1,"RJ_DESC"	,"TEMP","Desc. Func.",,TamSX3("RJ_DESC")[1]+3)
	oCell	:= TRCell():New(oSection1,"RA_CC"	,"TEMP","CC",,TamSX3("RA_CC")[1]+1)
	oCell	:= TRCell():New(oSection1,"CTT_DESC01"	,"TEMP","Desc. CC",,TamSX3("CTT_DESC01")[1]+2)

	
	oSection1:SetPageBreak(.F.) //Quebra de seção

    TRFunction():New(oSection1:Cell("AA1_FILIAL"),"TOTAL" ,"COUNT",,,"@E 999999",,.F.,.T.)	
	

Return (oReport)
