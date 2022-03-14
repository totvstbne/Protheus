#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwMvcdef.CH'
#include 'topconn.CH'
/*/{Protheus.doc} RPFR001
Relatório Listagem do Pedido Financeiro
@author Diogo
@since 07/02/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function RPFR001()
	Local cPerg	:= "RPFR001"
	Private oReport := ReportDef( cPerg )
	CriaSx1(cPerg)
	Pergunte(cPerg,.F.)
	oReport:PrintDialog()
Return

Static Function ReportDef(cPerg)
	Local nCont
	Local oReport
	Local oSection1,oSection2,oSection3,oSection4
	Local cReport		:= "RPFR001"
	Local aOrdem		:= {}
	Local nX
	Private cQuebr		:= ""
	oReport := TReport():New( cReport, "Pedido Financeiro", cPerg, { |oReport| RunReport( oReport) }, "Relatório Pedido Financeiro" )
	oReport:SetLandscape()
	oSection1 := TRSection():New(oReport,"iTENS",{"ZA7"},, .F., .T.)
	oSection1:SetTotalInLine(.F.)
	oSection1:SetHeaderBreak(.T.)
	Pergunte(cPerg,.T.)
	//oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
	oCell	:= TRCell():New(oSection1,"ZA7_NUM"		,"ZA7","Titulo",,TamSX3("ZA7_NUM")[1]+5,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_PARCEL"	,"ZA7","Parc.",,TamSX3("ZA7_PARCEL")[1]+3,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_TIPO"	,"ZA7","Tipo",,TamSX3("ZA7_TIPO")[1]+3,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_FORNEC"	,"ZA7","Forn.",,TamSX3("ZA7_FORNEC")[1]+5,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_NOMFOR"	,""	  ,"Nome For.",,TamSX3("ZA7_NOMFOR")[1]+2,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_NATURE"	,"ZA7","Natur.",,TamSX3("ZA7_NATURE")[1]+2,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_NOMNAT"	,"ZA7","Nome Natur.",,TamSX3("ZA7_NOMNAT")[1]+1,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_EMISSA"	,"ZA7","Emissão",,TamSX3("ZA7_EMISSA")[1]+2,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_VENCRE"	,"ZA7","Vencto",,TamSX3("ZA7_VENCRE")[1]+2,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_VALOR"	,"ZA7","Valor",,TamSX3("ZA7_VALOR")[1]+2,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_MULTNA"	,"ZA7","Mult. Nt",,TamSX3("ZA7_MULTNA")[1],,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_USECAD"	,"ZA7","Usuário",,TamSX3("ZA7_USECAD")[1]+10,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_NMGRPF"	,"ZA7","Grupo Apr.",,TamSX3("ZA7_NMGRPF")[1]+2,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_NMTIPO"	,"ZA7","Tipo PF",,TamSX3("ZA7_NMTIPO")[1]-5,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_YLOTE"	,"ZA7","Lote",,TamSX3("ZA7_YLOTE")[1]+4,,,,.T.,,,,,,,.F.)
	oCell	:= TRCell():New(oSection1,"ZA7_STATUS"	,"","ST.",,TamSX3("ZA7_STATUS")[1]+3,,,,.T.,,,,,,,.F.)

	If mv_par12 = 1 //Fornecedor
		oBreak := TRBreak():New( oSection1, oSection1:Cell("ZA7_FORNEC"),nil,.F.)
		oBreak:SetTitle({|| "TOTAL FORNECEDOR: "+cQuebr })
		//oBreak:SetTitle({|| "TOTAL "+cTPSEL + " - CC: "+cCTT })
	Else //Vencimento
		oBreak := TRBreak():New( oSection1, oSection1:Cell("ZA7_VENCRE"),nil,.F.)
		oBreak:SetTitle({|| "TOTAL VENCIMENTO: "+cQuebr })
	Endif
	TRFunction():New(oSection1:Cell("ZA7_VALOR"),NIL,"SUM",oBreak,"","@E 999,999,999.99",/*cFormula*/,.F.,.F.)

	oBrkEnd 	:= TRBreak():New(oSection1,"",nil,.F.)
	oBrkEnd:OnPrintTotal({|| oReport:SkipLine(),oReport:ThinLine(),oReport:SkipLine() })
	oBrkEnd:SetTitle({|| "T O T A L  G E R A L "}) 
	TRFunction():New(oSection1:Cell("ZA7_VALOR"),NIL,"SUM",oBrkEnd,"","@E 999,999,999.99",/*cFormula*/,.F.,.F.)

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
Static Function RunReport(oReport)
	Local oSection1	:= oReport:Section(1)
	Local aRet,cMvPar13
	Local cTexto,aTextos,cTpPed
	Local aTipos 	:= StrTokArr( alltrim(upper(mv_par14)), ";" )
	Private cQuebr	:= ""
	oSection1:Init()
	
	cQuery:= "SELECT ZA7.R_E_C_N_O_ RECNO FROM "+RetSqlName("ZA7")+" ZA7 "
	cQuery+= "WHERE ZA7.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZA7_FILIAL = '"+xFilial("ZA7")+"' AND "
	cQuery+= "ZA7_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
	//cQuery+= "ZA7_TIPO BETWEEN '"+mv_par14+"' AND '"+mv_par15+"' AND "
	If !empty(mv_par14)
		cQuery+= " ZA7_TIPO IN ( "
		For nX:=1 To len(aTipos)
			cQuery+= "'"+aTipos[nX]+"' "
			If nX+1 <= len(aTipos)
				cQuery+= ","
			Endif  
		Next
		cQuery+= " ) AND "
	Endif
	cQuery+= "ZA7_EMISSA BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"' AND "
	cQuery+= "ZA7_VENCRE BETWEEN '"+dtos(mv_par05)+"' AND '"+dtos(mv_par06)+"' AND "
	cQuery+= "ZA7_YLOTE BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' AND "
	cQuery+= "ZA7_FORNEC BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'  "
	If mv_par13 <> 4 //[1]Pendente,[2]aprovado,[3]rejeitado, [4]todos
		If mv_par13 == 1
			cMvPar13:= 'P' //Pendente
		Elseif mv_par13 == 2
			cMvPar13:= 'A' //Aprovado
		Elseif mv_par13 == 3
			cMvPar13:= 'R' //Rejeitado
		Endif
		cQuery+= " AND ZA7_STATUS = '"+cMvPar13+"' "
	Endif
	If mv_par12 = 1 //Fornecedor
		cQuery+= "ORDER BY ZA7_FORNEC,ZA7_LOJA,ZA7_NUM,ZA7_PARCEL "
	Else
		cQuery+= "ORDER BY ZA7_VENCRE,ZA7_NUM,ZA7_PARCEL "
	Endif
	tcQuery cQuery new Alias QRZA7
	
	If QRZA7->(!Eof())
	ZA7->(dbGoto(QRZA7->RECNO))
		cCampQbr:= ""
		cNomFor:= ""
		If mv_par11 = 1 //Razão social
		 	cNomFor:= ZA7->ZA7_NOMFOR
		Else //Nome reduzido
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+ZA7->(ZA7_FORNEC+ZA7_LOJA)))
			cNomFor:= SA2->A2_NREDUZ
		Endif
		If mv_par12 = 1 //Fornecedor
			cQuebr 	:= cNomFor
			cCampQbr:= ZA7->ZA7_FORNEC 
		Else
			cQuebr 	:= substr(dTos(ZA7->ZA7_VENCRE),7,2)+"/"+substr(dTos(ZA7->ZA7_VENCRE),5,2)+"/"+substr(dTos(ZA7->ZA7_VENCRE),1,4)
			cCampQbr:= dtos(ZA7->ZA7_VENCRE)
		Endif
	Endif
	
	while QRZA7->(!Eof())
		ZA7->(dbGoto(QRZA7->RECNO))
		cNomFor:= ""
		If mv_par11 = 1 //Razão social
		 	cNomFor:= ZA7->ZA7_NOMFOR
			oSection1:Cell("ZA7_NOMFOR"):SetValue(ZA7->ZA7_NOMFOR)
		Else //Nome reduzido
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+ZA7->(ZA7_FORNEC+ZA7_LOJA)))
			cNomFor:= SA2->A2_NREDUZ
			oSection1:Cell("ZA7_NOMFOR"):SetValue(SA2->A2_NREDUZ)
		Endif

		If ZA7->ZA7_STATUS == 'A'
			cTpPed:= 'Aprv.'
		Elseif ZA7->ZA7_STATUS == 'P'
			cTpPed:= 'Pend.'
		Elseif ZA7->ZA7_STATUS == 'R'
			cTpPed:= 'Rej.'
		Else
			cTpPed:= ZA7->ZA7_STATUS
		Endif
		oSection1:Cell("ZA7_STATUS"):SetValue(cTpPed)
		oSection1:PrintLine()

		If mv_par12 = 1 .and. cCampQbr <> ZA7->ZA7_FORNEC //Fornecedor
			cCampQbr:= ZA7->ZA7_FORNEC 
			cQuebr := cNomFor
		Elseif mv_par12 = 2 .and. cCampQbr <> dtos(ZA7->ZA7_VENCRE) //Vencimento
			cQuebr := substr(dTos(ZA7->ZA7_VENCRE),7,2)+"/"+substr(dTos(ZA7->ZA7_VENCRE),5,2)+"/"+substr(dTos(ZA7->ZA7_VENCRE),1,4)
			cCampQbr:= dTos(ZA7->ZA7_VENCRE)
		Endif

	QRZA7->(dbSkip())
	Enddo
	QRZA7->(dbCloseArea())
	oSection1:Finish()
Return

Static Function CriaSx1(cPerg)
  u_PutSx1(cPerg, "01","Titulo de"		,"Titulo de" 	,"Titulo de"	,"cpar01","C",GetSx3Cache("ZA7_NUM","X3_TAMANHO"),0,0,"G","","","","","mv_par01"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "02","Titulo ate"		,"Titulo ate" 	,"Titulo ate"	,"cpar02","C",GetSx3Cache("ZA7_NUM","X3_TAMANHO"),0,0,"G","","","","","mv_par02"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "03","Emissão de"		,"Emissão de" 	,"Emissão de"	,"cpar03","D",GetSx3Cache("ZA7_EMISSA","X3_TAMANHO"),0,0,"G","","","","","mv_par03"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "04","Emissão ate"	,"Emissão ate" 	,"Emissão ate"	,"cpar04","D",GetSx3Cache("ZA7_EMISSA","X3_TAMANHO"),0,0,"G","","","","","mv_par04"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "05","Vencto de"		,"Vencto de" 	,"Vencto de"	,"cpar05","D",GetSx3Cache("ZA7_EMISSA","X3_TAMANHO"),0,0,"G","","","","","mv_par05"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "06","Vencto ate"		,"Vencto ate" 	,"Vencto ate"	,"cpar06","D",GetSx3Cache("ZA7_EMISSA","X3_TAMANHO"),0,0,"G","","","","","mv_par06"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "07","Lote de"		,"Lote de" 		,"Lote de"		,"cpar07","C",GetSx3Cache("ZA7_YLOTE","X3_TAMANHO"),0,0,"G","","","","","mv_par07"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "08","Lote ate"		,"Lote ate" 	,"Lote ate"		,"cpar08","C",GetSx3Cache("ZA7_YLOTE","X3_TAMANHO"),0,0,"G","","","","","mv_par08"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "09","Fornecedor de"	,"Fornecedor de","Fornecedor de","cpar09","C",GetSx3Cache("A2_COD","X3_TAMANHO"),0,0,"G","","SA2","","","mv_par09"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "10","Fornecedor ate"	,"Fornecedor de","Fornecedor de","cpar10","C",GetSx3Cache("A2_COD","X3_TAMANHO"),0,0,"G","","SA2","","","mv_par10"," ","","","","","","","","","","","","","","","")
  u_PutSx1(cPerg, "11","Nome Forn."		,"Nome Forn."	,"Nome Forn."	,"cpar11","N",01,0,0,"C", "naovazio()","","","","mv_par11","Razão Social","Razão Social","Razão Social","","Reduzido","Reduzido","Reduzido","","", "", "", "", "", "", "", "",,,)
  u_PutSx1(cPerg, "12","Quebra"			,"Quebra"		,"Quebra"		,"cpar12","N",01,0,0,"C", "naovazio()","","","","mv_par12","Fornecedor","Fornecedor","Fornecedor","","Vencimento","Vencimento","Vencimento","","", "", "", "", "", "", "", "",,,)
  u_PutSx1(cPerg, "13","Status"			,"Status"		,"Status"		,"cpar13","N",01,0,0,"C", "naovazio()","","","","mv_par13","Pendente","Pendente","Pendente","","Aprovado","Aprovado","Aprovado","Rejeitado","Rejeitado", "Rejeitado", "Todos", "Todos", "Todos", "", "", "",,,)
  u_PutSx1(cPerg, "14","Tipos(NF;PA;)"	,"Tipos(NF;PA;)","Tipos(NF;PA;)","cpar14","C",99,0,0,"G","","","","","mv_par14"," ","","","","","","","","","","","","","","","")
Return