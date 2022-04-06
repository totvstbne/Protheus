#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwMvcdef.CH'
#include 'topconn.CH'
/*/{Protheus.doc} RSERV077
Relatório Atendentes sem Agenda
@author Diogo
@since 29/03/2022
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function RSERV077()
	Local cPerg	:= ""
	Private oReport := ReportDef( cPerg )
	If type("oReport") <> "U"
		oReport:PrintDialog()
	Endif
Return

Static Function ReportDef(cPerg)
	Local oReport
	Local oSection1
	Local cReport   := "RSERV077"
	Local aPergs	:= {}
	Local aRetP     := {}

	aAdd( aPergs ,{1,"Período",cTod(""),GetSx3Cache("E2_EMISSAO","X3_PICTURE") ,'.T.',"" ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Filial ",space(GetSx3Cache("E2_FILIAL","X3_TAMANHO")),GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',50,.T.})
	If !(ParamBox(aPergs,"Informe Parâmetros",aRetP,,,,,,,"",.T.,.T.))
        Return
    Endif
	oReport := TReport():New( cReport, "Atendentes sem Agenda", cPerg, { |oReport| RunReport(oReport,aRetP) }, "Relatório Atendentes sem Agenda" )
	oReport:SetLandscape()
	oSection1 := TRSection():New(oReport,"Itens",{"SRA"},, .F., .T.)
	oSection1:SetTotalInLine(.F.)
	oSection1:SetHeaderBreak(.T.)
    TRCell():New(oSection1,"RA_FILIAL"  ,"","Filial",,TamSX3("RA_FILIAL")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"M0_FILIAL"	,"","Nome Filial",,30,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"RA_MAT"	    ,"","Matrícula",,TamSX3("RA_MAT")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"TGY_ATEND"	,"","Atendimento",,TamSX3("TGY_ATEND")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"RA_NOME"	,"","Nome",,TamSX3("RA_NOME")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"RA_CIC"	    ,"","CPF",,TamSX3("RA_CIC")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"RA_CC"	    ,"","Centro Custo GPE",,TamSX3("RA_CC")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"TFL_YCC"	,"","Centro Custo GS",,TamSX3("TFL_YCC")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"RA_SITFOLH"	,"","Sit. Folha",,15,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"TFF_CONTRT"	,"","Contrato",,TamSX3("TFF_CONTRT")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"PROBLEMAS"	,"","Problemas Encontrados",,40,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"TGY_DTFIM"	,"","Dt. Fim Escala",,TamSX3("TGY_DTFIM")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1,"ULTALO"	    ,"","Ultima Agenda",,TamSX3("TGY_DTFIM")[1]+2,,,,.T.,,,,,,,.F.)
	Return oReport

/*/{Protheus.doc} RunReport
Impressão do relatório
@author Diogo
@since 07/02/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function RunReport(oReport,aret)
	Local oSection1	:= oReport:Section(1)
	Local cQuery    := ""
	Local cAlias    := nil
	Default aRet	:= {ctod(""),""}
	oSection1:Init()

    cQuery+=" SELECT  RA_FILIAL, "
    cQuery+="         SYS_COMPANY.M0_FILIAL AS 'FILIAL', "
    cQuery+="         RA_MAT, "
    cQuery+="         TGY_ATEND, "
    cQuery+="         RA_NOME, "
    cQuery+="         RA_CIC, "
    cQuery+="         RA_CC, "
    cQuery+="         TFL_YCC, "
    cQuery+="         CASE RA_SITFOLH "
    cQuery+="             WHEN '' THEN 'ATIVO' "
    cQuery+="             WHEN 'A' THEN 'AFASTADO' "
    cQuery+="             WHEN 'F' THEN 'FERIAS' "
    cQuery+="             WHEN 'T' THEN 'TRANSFERIDO' "
    cQuery+="         END AS 'SITFOLH', "
    cQuery+="         TFF_CONTRT, "
    cQuery+="         CASE "
    cQuery+="             WHEN TGY_ATEND IS NULL THEN 'ESCALA DO FUNCIONÁRIO NÃO ENCONTRADA' "
    cQuery+="             WHEN TFF_COD IS NULL THEN 'PROBLEMA NOS RECURSOS HUMANOS' "
    cQuery+="             WHEN TFL_YCC IS NULL THEN 'NÃO EXISTE CC PARA ESSE FUNCIONÁRIO NO GS' "
    cQuery+="             WHEN RTRIM(RA_CC) <> RTRIM(TFL_YCC) THEN 'CENTROS DE CUSTO DO GPE E GS SE DIFEREM' "
    cQuery+="             WHEN TGY_DTFIM <= '"+dtos(aRet[1])+"' THEN 'FIM DA ESCALA INFERIOR À DATA SELECIONADA' "
    cQuery+="             WHEN AGEND.ULTALO <= '"+dtos(aRet[1])+"' THEN 'ULTIMA AGENDA DO FUNCIONÁRIO INFERIOR À DATA SELECIONADA' "
    cQuery+="         END AS 'PROBLEMAS', "
    cQuery+="         TGY_DTFIM, "
    cQuery+="         AGEND.ULTALO "
    cQuery+=" FROM	"+RetSqlName("SRA")+" SRA " 
    cQuery+="         LEFT JOIN "+RetSqlName("TGY")+" TGY  ON TGY_FILIAL = RA_FILIAL AND TGY_ATEND =	RA_FILIAL + RA_MAT AND TGY_DTFIM = (SELECT MAX(TGY_DTFIM) FROM "+RetSqlName("TGY")+" ATENDMAX WHERE ATENDMAX.TGY_ATEND = RA_FILIAL + RA_MAT AND ATENDMAX.D_E_L_E_T_='') AND TGY.D_E_L_E_T_='' "
    cQuery+="         LEFT JOIN "+RetSqlName("TFF")+" TFF ON TFF_FILIAL = RA_FILIAL AND TFF_COD = TGY_CODTFF AND TFF.D_E_L_E_T_='' "
    cQuery+="         LEFT JOIN "+RetSqlName("TFL")+"  TFL ON TFL_FILIAL = RA_FILIAL AND TFL_CODIGO = TFF_CODPAI AND TFL.D_E_L_E_T_='' "
    cQuery+="         LEFT JOIN (SELECT ABB_FILIAL, ABB_CODTEC, MAX(ABB_DTINI) AS 'ULTALO' FROM "+RetSqlName("ABB")+" ABB WHERE ABB_MANUT = '2' AND ABB.D_E_L_E_T_='' GROUP BY ABB_FILIAL, ABB_CODTEC) AGEND ON AGEND.ABB_FILIAL = RA_FILIAL AND ABB_CODTEC = RA_FILIAL + RA_MAT "
    cQuery+="         INNER JOIN SYS_COMPANY ON M0_CODFIL = RA_FILIAL AND SYS_COMPANY.D_E_L_E_T_='' "
    cQuery+=" WHERE	SRA.D_E_L_E_T_='' "
    cQuery+="         AND RA_SITFOLH <> 'D' "
    cQuery+="         AND (	TGY_ATEND IS NULL "
    cQuery+="                 OR TFF_COD IS NULL "
    cQuery+="                 OR TFL_YCC IS NULL "
    cQuery+="                 OR RTRIM(RA_CC) <> RTRIM(TFL_YCC) "
    cQuery+="                 OR TGY_DTFIM <= '"+dtos(aRet[1])+"' "
    cQuery+="                 OR AGEND.ULTALO <= '"+dtos(aRet[1])+"' "
    cQuery+="         ) "
    cQuery+="         AND RA_FILIAL = '"+aret[2]+"' "
    cQuery+=" ORDER BY RA_FILIAL, RA_MAT "
    
    cAlias:= mpSysOpenQuery(cQuery)

	while (cAlias)->(!Eof())
  
		oSection1:Cell("RA_FILIAL"):SetValue((cAlias)->RA_FILIAL)
		oSection1:Cell("M0_FILIAL"):SetValue((cAlias)->FILIAL)
		oSection1:Cell("RA_MAT"):SetValue((cAlias)->RA_MAT)
		oSection1:Cell("TGY_ATEND"):SetValue((cAlias)->TGY_ATEND)
		oSection1:Cell("RA_NOME"):SetValue((cAlias)->RA_NOME)
		oSection1:Cell("RA_CIC"):SetValue((cAlias)->RA_CIC)
		oSection1:Cell("RA_CC"):SetValue((cAlias)->RA_CC)
		oSection1:Cell("TFL_YCC"):SetValue((cAlias)->TFL_YCC)
		oSection1:Cell("RA_SITFOLH"):SetValue((cAlias)->SITFOLH)
		oSection1:Cell("TFF_CONTRT"):SetValue((cAlias)->TFF_CONTRT)
		oSection1:Cell("PROBLEMAS"):SetValue((cAlias)->PROBLEMAS)
		oSection1:Cell("TGY_DTFIM"):SetValue(stod((cAlias)->TGY_DTFIM))
		oSection1:Cell("ULTALO"):SetValue(stod((cAlias)->ULTALO))
		oSection1:PrintLine()
	(cAlias)->(dbSkip())
	Enddo
	(cAlias)->(dbCloseArea())
	oSection1:Finish()
Return
