#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"

user function RSERV001()


	Local oReport
	Private cPerg:= "U_RSERV001"

	oReport:=ReportDef()
	oReport:PrintDialog()	

return 

Static Function ReportDef()

	Local oReport
	Local oSection 
	Local oSection2
	Local aOrdem    := {}

	ValidPerg()
	Pergunte(cPerg,.F.)     

	oReport := TReport():New("RSERV001","Atestados",cPerg,{|oReport| ReportPrint(oReport,aOrdem)},"Atestados")
	oReport:SetLandscape() //Paisagem   

	oSection:= TRSection():New(oReport,OemToAnsi("Listagem"),,aOrdem) 
	TRCell():New(oSection,"TNY_FILIAL"    ,,"Empresa"               ,,4)
	TRCell():New(oSection,"SRA_NOME"      ,,"Funcionário"    		,,30)
	TRCell():New(oSection,"CC_CONTRA"     ,,"Contrato"	            ,,10)
	TRCell():New(oSection,"CC_LOCACAO"    ,,"Locação"		        ,,40)
	TRCell():New(oSection,"TNY_DTINIC"    ,,"Dia atestado"	        ,,10)
	TRCell():New(oSection,"TNY_TDIAS"     ,,"N* Dias"	    	    ,,3)
	TRCell():New(oSection,"TNY_DIASG"     ,,"N* Dias Gosados" 	    ,,3)
	TRCell():New(oSection,"TNY_CID"       ,,"CID"           		,,8)
	TRCell():New(oSection,"TNY_DESCID"    ,,"Desc CID"	            ,,30)
	TRCell():New(oSection,"TNY_INDMED"    ,,"Rede de Atendimento"   ,,10)
	TRCell():New(oSection,"TNY_LOCAL"     ,,"Local de Atendimento"  ,,20)
	TRCell():New(oSection,"TNP_NOME"      ,,"Nome Emitente"		    ,,TamSX3("CN9_VLADIT")[1])
	TRCell():New(oSection,"TNP_ENTCLA"    ,,"Entidade"		        ,,TamSX3("CN9_VLADIT")[1])
	TRCell():New(oSection,"TNP_NUMENT"    ,,"Num Entidade"		    ,,15)

	oSection2 := TRSection():New(oReport,OemToAnsi("Total"),{},aOrdem) 

	TRCell():New(oSection2,"TNY_FILIAL"    ,,"Filial"               ,,9  )
	TRCell():New(oSection2,"SRA_NOME"      ,,"Funcionário"          ,,30)
	TRCell():New(oSection2,"NTOTDIAS"      ,,"Total Dias"           ,,3)
	TRCell():New(oSection2,"NTOTDGO"       ,,"Total Dias Gosados"   ,,3)



return(oReport)



//------------------------------------------------//
//FUNÇÃO: IMPRESSAO								  //
//------------------------------------------------//
Static Function ReportPrint(oReport,aOrdem)

	Local oSection  := oReport:Section(1)   
	Local oSection2 := oReport:Section(2)   
	Local nOrdem    := oSection:GetOrder()   
	Local aTotal    := {}
	Local nBx                    
	Local nAx 

	If oReport:nDevice <> 4

		Alert("Esse relatório nao pode ser gerado de forma diferente de planilha")

		Return

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do titulo do relatorio                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetTitle(oReport:Title())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GERAÇÃO DOS REGISTROS			                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	cQuery:=" SELECT TNY_FILIAL,TM0_MAT,TM0_NOMFIC , ' -- CONTRA --' AS CONTRATO , '-- LOCACAO --' AS LOCACAO , TNY_DTINIC , TNY_DTFIM , TNY_CID , TMR_DOENCA,
	cQuery+=" TNY_INDMED , '-- LOC ATEND --' AS LOCATEN , TNP_NOME , TNP_ENTCLA , TNP_NUMENT
	cQuery+=" FROM "+RETSQLNAME("TNY")+"  TNY , "+RETSQLNAME("TM0")+"  TM0, "+RETSQLNAME("TNP")+"  TNP , "+RETSQLNAME("TMR")+"  TMR
	cQuery+=" WHERE TNY_DTINIC BETWEEN '"+ DTOS(MV_PAR03) +"' AND '"+ DTOS(MV_PAR04) +"'
	cQuery+=" AND TNY_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"'
	IF MV_PAR07 == 1
		cQuery+=" AND TNY_INDMED = '4'
	ELSEif MV_PAR07 == 2
		cQuery+=" AND TNY_INDMED = '5'
	ENDIF 
	cQuery+=" AND TNY_INDMED BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR09 +"'
	cQuery+=" AND TM0_MAT BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"'
	cQuery+=" AND TNY_CID BETWEEN '"+ MV_PAR11 +"' AND '"+ MV_PAR12 +"'
	cQuery+=" AND TNY_FILIAL = TNP_FILIAL AND TNY_EMITEN = TNP_EMITEN
	cQuery+=" AND TNY_FILIAL = TM0_FILIAL AND TNY_NUMFIC = TM0_NUMFIC
	//cQuery+=" AND TNY_FILIAL = TMR_FILIAL AND TNY_CID = TMR_CID
	cQuery+=" AND TNY_CID = TMR_CID
	cQuery+=" AND TNY.D_E_L_E_T_ = '' AND TM0.D_E_L_E_T_ = '' AND TNP.D_E_L_E_T_ = '' AND TMR.D_E_L_E_T_ = ''

	IF SELECT("T01") > 0 
		T01->(DBCLOSEAREA())
	ENDIF

	TCQUERY cQuery NEW ALIAS T01

	oSection:Init()
	WHILE  T01->(!EOF())

		oSection:Cell("TNY_FILIAL" ):SetValue(T01->TNY_FILIAL)
		oSection:Cell("SRA_NOME" ):SetValue(T01->TM0_NOMFIC)
		oSection:Cell("CC_CONTRA" ):SetValue(T01->CONTRATO)
		oSection:Cell("CC_LOCACAO" ):SetValue(T01->LOCACAO)
		oSection:Cell("TNY_DTINIC" ):SetValue(STOD(T01->TNY_DTINIC))
		oSection:Cell("TNY_TDIAS" ):SetValue((STOD(T01->TNY_DTFIM) - STOD(T01->TNY_DTINIC)) + 1)


		cQuery:=" select [1] AS S1 ,[2] AS S2 ,[3] AS S3,[4] AS S4 ,[5] AS S5,[6] AS S6,[7] AS S7
		cQuery+=" from  (SELECT PJ_TURNO,PJ_DIA,PJ_TPDIA 
		cQuery+=" FROM "+RETSQLNAME("SPJ")+" SPJ, "+RETSQLNAME("SRA")+"  SRA
		cQuery+=" WHERE RA_FILIAL = '"+T01->TNY_FILIAL+"' 
		cQuery+=" AND   RA_MAT    ='"+T01->TM0_MAT+"'
		cQuery+=" AND RA_TNOTRAB  =PJ_TURNO
		cQuery+=" AND SPJ.D_E_L_E_T_ = '' AND SRA.D_E_L_E_T_ = '' ) A
		cQuery+=" PIVOT ( MAX(PJ_TPDIA) FOR PJ_DIA  IN ([1],[2],[3],[4],[5],[6],[7])) AS A

		IF SELECT("T02") > 0 
			T02->(DBCLOSEAREA())
		ENDIF

		TCQUERY cQuery NEW ALIAS T02

		dVal := stod(T01->TNY_DTINIC)
		nCont := 0

		while	dVal <=  stod(T01->TNY_DTFIM)			
			IF &("T02->S"+CVALTOCHAR(DOW(dVal))) == "S"
				nCont ++
			ENDIF 
			dVal += 1
		enddo
		T02->(DBCLOSEAREA())

		oSection:Cell("TNY_DIASG" ):SetValue(alltrim(TRANSFORM(nCont ,"@E 999,999,999.99")))//cvaltochar(nCont))
		oSection:Cell("TNY_CID" ):SetValue(T01->TNY_CID)
		oSection:Cell("TNY_DESCID" ):SetValue(T01->TMR_DOENCA)
		oSection:Cell("TNY_INDMED" ):SetValue(IIF(T01->TNY_INDMED <> '4',"Privado","Publico"))
		oSection:Cell("TNY_LOCAL" ):SetValue(T01->LOCATEN)
		oSection:Cell("TNP_NOME" ):SetValue(T01->TNP_NOME)
		oSection:Cell("TNP_ENTCLA" ):SetValue(T01->TNP_ENTCLA)
		oSection:Cell("TNP_NUMENT" ):SetValue(T01->TNP_NUMENT)

		IF LEN(aTotal) == 0
			aadd(aTotal,{alltrim(T01->TNY_FILIAL),alltrim(T01->TM0_MAT),ALLTRIM(T01->TM0_NOMFIC),(STOD(T01->TNY_DTFIM) - STOD(T01->TNY_DTINIC)) + 1,nCont})
		ELSE

			FOR nAux := 1 to len(aTotal) 
				IF	aTotal[nAux][1] == alltrim(T01->TNY_FILIAL) .AND. aTotal[nAux][2] == alltrim(T01->TM0_MAT) .AND. aTotal[nAux][3] == ALLTRIM(T01->TM0_NOMFIC) 
					aTotal[nAux][4] += (STOD(T01->TNY_DTFIM) - STOD(T01->TNY_DTINIC)) + 1
					aTotal[nAux][5] += nCont
				ELSE
					aadd(aTotal,{alltrim(T01->TNY_FILIAL),alltrim(T01->TM0_MAT),ALLTRIM(T01->TM0_NOMFIC),(STOD(T01->TNY_DTFIM) - STOD(T01->TNY_DTINIC)) + 1,nCont})
				ENDIF
			NEXT 
		ENDIF

		oSection:PrintLine()  //Imprimir a Secção
		oReport:IncMeter(1)


		if oReport:Cancel()
			oSection:Finish()
			T01->(dbCloseArea())

			oSection2:Init()  
			FOR nAx := 1 to len(aTotal)
				oSection2:Cell("TNY_FILIAL" ):SetValue(aTotal[nAx][1])//+" "+ Posicione("SM0",1,cEmpant+aTotal[nAx][1],"M0_FILIAL"))
				oSection2:Cell("SRA_NOME" ):SetValue(alltrim(aTotal[nAx][3]))
				oSection2:Cell("NTOTDIAS" ):SetValue(alltrim(TRANSFORM(aTotal[nAx][4] ,"@E 999,999,999.99")))
				oSection2:Cell("NTOTDGO" ):SetValue(alltrim(TRANSFORM(aTotal[nAx][5] ,"@E 999,999,999.99")))

				oSection2:PrintLine()  //Imprimir a Secção
				oReport:IncMeter(1)

			Next 
			oSection2:Finish()


			return
		endif

		T01->(DBSKIP())

	ENDDO

	T01->(dbCloseArea())
	oSection:Finish()

	oSection2:Init()  
	FOR nAx := 1 to len(aTotal)
		oSection2:Cell("TNY_FILIAL" ):SetValue(aTotal[nAx][1])//+" "+ Posicione("SM0",1,cEmpant+aTotal[nAx][1],"M0_FILIAL"))
		oSection2:Cell("SRA_NOME" ):SetValue(alltrim(aTotal[nAx][3]))
		oSection2:Cell("NTOTDIAS" ):SetValue(alltrim(TRANSFORM(aTotal[nAx][4] ,"@E 999,999,999.99")))
		oSection2:Cell("NTOTDGO" ):SetValue(alltrim(TRANSFORM(aTotal[nAx][5] ,"@E 999,999,999.99")))


		oSection2:PrintLine()  //Imprimir a Secção
		oReport:IncMeter(1)

	Next 
	oSection2:Finish()


return



//========================================================================//
// MONTAGEM DAS PERGUNTAS 								                  //
//========================================================================//  

Static Function ValidPerg()
	// Objetivo: Criar as perguntas necessarias ao relatorios, caso nao existam
	//-----------------------------------------------------------------------------
	Local aRegs := {}, i, j, aAreaSX1 := SX1->(GetArea())


	// Numeracao dos campos:

	// 01 -> X1_GRUPO   02 -> X1_ORDEM    03 -> X1_PERGUNT  04 -> X1_PERSPA  05 -> X1_PERENG
	// 06 -> X1_VARIAVL 07 -> X1_TIPO     08 -> X1_TAMANHO  09 -> X1_DECIMAL 10 -> X1_PRESEL
	// 11 -> X1_GSC     12 -> X1_VALID    13 -> X1_VAR01    14 -> X1_DEF01   15 -> X1_DEFSPA1
	// 16 -> X1_DEFENG1 17 -> X1_CNT01    18 -> X1_VAR02    19 -> X1_DEF02   20 -> X1_DEFSPA2
	// 21 -> X1_DEFENG2 22 -> X1_CNT02    23 -> X1_VAR03    24 -> X1_DEF03   25 -> X1_DEFSPA3
	// 26 -> X1_DEFENG3 27 -> X1_CNT03    28 -> X1_VAR04    29 -> X1_DEF04   30 -> X1_DEFSPA4
	// 31 -> X1_DEFENG4 32 -> X1_CNT04    33 -> X1_VAR05    34 -> X1_DEF05   35 -> X1_DEFSPA5
	// 36 -> X1_DEFENG5 37 -> X1_CNT05    38 -> X1_F3       39 -> X1_GRPSXG

	// Campos:  01     02    03                      04  05  06        07   08 09 10  11  12  13          14      	  15  16  17  18  19     20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39
	If cPerg == "U_RSERV001"	

		aAdd(aRegs, {cPerg, "01", "Filial de? "            ,    "", "", "mv_ch1", "C", 6, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", ""})
		aAdd(aRegs, {cPerg, "02", "Filial ate? "           ,    "", "", "mv_ch2", "C", 6, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", ""})
		aAdd(aRegs, {cPerg, "03", "Periodo De"             ,    "", "", "mv_ch3", "D", 8, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
		aAdd(aRegs, {cPerg, "04", "Periodo Ate"            ,    "", "", "mv_ch4", "D", 8, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
		aAdd(aRegs, {cPerg, "05", "Matricula De"           ,    "", "", "mv_ch5", "C", 6, 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA", ""})
		aAdd(aRegs, {cPerg, "06", "Matricula Ate"          ,    "", "", "mv_ch6", "C", 6, 0, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA", ""})
		aAdd(aRegs, {cPerg, "07", "Rede Atendimento"       ,    "", "", "mv_ch7", "C", 1, 0, 0, "C", "", "mv_par07", "Publico", "", "", "", "", "Privado", "", "", "", "", "Todos", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
		aAdd(aRegs, {cPerg, "08", "Emitente De"            ,    "", "", "mv_ch8", "C",12, 0, 0, "G", "", "mv_par08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "TNP", ""})
		aAdd(aRegs, {cPerg, "09", "Emitente Ate"           ,    "", "", "mv_ch9", "C",12, 0, 0, "G", "", "mv_par09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "TNP", ""})
		aAdd(aRegs, {cPerg, "10", "Local de Atendimento"   ,    "", "", "mv_ch10","C", 20, 0, 0,"G", "", "mv_par10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
		aAdd(aRegs, {cPerg, "11", "Cid  De"                ,    "", "", "mv_ch11","C", 6, 0, 0, "G", "", "mv_par11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "TMR", ""})
		aAdd(aRegs, {cPerg, "12", "Cid  Até"               ,    "", "", "mv_ch12","C", 6, 0, 0, "G", "", "mv_par12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "TMR", ""})


	EndIf

	SX1->(dbSetOrder(1))   
	For i := 1 To Len(aRegs)

		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
			RecLock("SX1", .T.)

			For j :=1 to SX1->(FCount())

				If j <= Len(aRegs[i])
					SX1->(FieldPut(j,aRegs[i,j]))
				Endif
			Next

			SX1->(MsUnlock())
		Endif
	Next

	SX1->(RestArea(aAreaSX1))

Return

// DOCUMENTAÇAO DAS FUNÇÕES USADAS

/*
FUNÇAO DOW(ddata)

Segunda-feira  2
Terça-feira    3
Quarta-feira   4
Quinta-feira   5
Sexta-feira    6
Sábado         7
Domingo        1
*/