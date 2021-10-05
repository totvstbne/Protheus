#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.Ch"
#Include "Totvs.Ch"
#Include "Rwmake.Ch"
#Include "TbiConn.Ch"
#Include "TbiCode.Ch"
#INCLUDE "FWPrintSetup.ch"


user function RSERV034()

	Local oReport

	Local aParam		 := {}
	Local cPd            := "                                               "
	Local cPeriod		 := "      "
	Local cSindic		 := "                                               "
	Local aTipo	         := {'EMP','CC','FUNC'}
	private aRet  		 := {}


	aAdd(aParam,{1,"Verba"          ,cPd       	,"@! ",".T.","SRV",".T.",90,.F.})
	aAdd(aParam,{1,"Periodo"	    ,cPeriod	,"@! 999999",".T.","",".T.",20,.F.})
	aAdd(aParam,{1,"Sindicato"	    ,cSindic	,"@! ",".T.","",".T.",90,.F.})
	aAdd(aParam,{2,"Tipo Relatorio" ,,aTipo	    ,80,,.F.,})



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


	if aRet[4] == "EMP"

		oReport := TReport():New("RSERV034","Conferencia Verba",,{|oReport| ReportPrint(oReport,aOrdem)},"Conferencia Verba")
		//oReport:SetLandscape() //Paisagem   
		oReport:SetPortrait() // retrato

		oSection:= TRSection():New(oReport,OemToAnsi("Valores"),,aOrdem) 
		TRCell():New(oSection,"RA_FILIAL"     ,,"Filial"                ,,6)
		TRCell():New(oSection,"RA_SINDICA"    ,,"Cod. Sindicato"        ,,10)
		TRCell():New(oSection,"RCE_DESCRI"    ,,"Sindicato"             ,,40)
		TRCell():New(oSection,"RC_PD"         ,,"Verba"             	,,10)
		TRCell():New(oSection,"RC_ROTEIR"     ,,"Roteiro"	            ,,10)
		TRCell():New(oSection,"RC_VALOR"      ,,"Cod. Funcao"	        ,,20)
		TRCell():New(oSection,"NFNC"          ,,"Total Func"	        ,,20)

	ELSEIF aRet[4] == "CC"

		oReport := TReport():New("RSERV034","Conferencia Verba",,{|oReport| ReportPrint(oReport,aOrdem)},"Conferencia Verba")
		//oReport:SetLandscape() //Paisagem   
		oReport:SetPortrait() // retrato

		oSection:= TRSection():New(oReport,OemToAnsi("Valores"),,aOrdem) 
		TRCell():New(oSection,"RA_FILIAL"    ,,"Filial"                ,,6)
		TRCell():New(oSection,"RA_SINDICA"    ,,"Cod. Sindicato"        ,,10)
		TRCell():New(oSection,"RCE_DESCRI"    ,,"Sindicato"             ,,40)
		TRCell():New(oSection,"RA_CC"        ,,"Centro Custo"          ,,20)
		TRCell():New(oSection,"CTT_DESC"     ,,"Desc Cent. Custos"     ,,40)
		TRCell():New(oSection,"CTT_CEI"      ,,"CNPJ"                  ,,40)
		TRCell():New(oSection,"RC_PD"        ,,"Verba"                 ,,10)
		TRCell():New(oSection,"RC_ROTEIR"    ,,"Roteiro"               ,,10)
		TRCell():New(oSection,"RC_VALOR"     ,,"Valor"		    	   ,,20)
		TRCell():New(oSection,"NFNC"          ,,"Total Func"	        ,,20)

	ELSEIF aRet[4] == "FUNC"

		oReport := TReport():New("RSERV034","Conferencia Verba",,{|oReport| ReportPrint(oReport,aOrdem)},"Conferencia Verba")
		//oReport:SetLandscape() //Paisagem   
		oReport:SetPortrait() // retrato

		oSection:= TRSection():New(oReport,OemToAnsi("Valores"),,aOrdem) 
		TRCell():New(oSection,"RA_FILIAL"    ,,"Filial"                ,,6)
		TRCell():New(oSection,"RA_SINDICA"    ,,"Cod. Sindicato"        ,,10)
		TRCell():New(oSection,"RCE_DESCRI"    ,,"Sindicato"             ,,40)
		TRCell():New(oSection,"RA_CC"        ,,"Centro Custo"          ,,20)
		TRCell():New(oSection,"CTT_DESC"     ,,"Desc Cent. Custos"     ,,40)
		TRCell():New(oSection,"CTT_CEI"      ,,"CNPJ"                  ,,40)
		TRCell():New(oSection,"RC_PD"        ,,"Verba"                 ,,10)
		TRCell():New(oSection,"RC_ROTEIR"    ,,"Roteiro"               ,,10)
		TRCell():New(oSection,"RA_NOME"      ,,"Funcionário"           ,,30)		
		TRCell():New(oSection,"RC_VALOR"     ,,"Valor"		    	   ,,20)

	endif


return(oReport)


//------------------------------------------------//
//FUNÇÃO: IMPRESSAO								  //
//------------------------------------------------//
Static Function ReportPrint(oReport,aOrdem)

	Local oSection  := oReport:Section(1)   
	Local nOrdem    := oSection:GetOrder()   
	Local aVerba 	:= StrTokArr( aret[1] , "," )
	Local cVerba    := ""
	Local cPeriod   := aret[2]
	Local aSindic   := StrTokArr( aret[3] , "," )
	Local cSindic   := ""
	Local cTipo     := aret[4]


	for naux:= 1 to len(aVerba)
		if naux < len(aVerba)
			cVerba += "'"+ alltrim(aVerba[naux]) +"',"
		elseif naux== len(aVerba)
			cVerba += "'"+ alltrim(aVerba[naux]) +"'"	
		endif
	next



	for naux := 1 to len(aSindic)
		if naux < len(aSindic)
			cSindic += "'"+ alltrim(aSindic[naux]) +"',"
		elseif naux== len(aSindic)
			cSindic += "'"+ alltrim(aSindic[naux]) +"'"	
		endif
	next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do titulo do relatorio                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetTitle(oReport:Title())



	if cTipo == "EMP"


		cQuery:=" SELECT  RA_FILIAL ,RC_PD , RC_ROTEIR , RCE_CODIGO , RCE_DESCRI ,SUM(RC_VALOR) VALOR , COUNT(RA_MAT) NFUNC
		cQuery+=" FROM "+RETSQLNAME("SRA")+"  SRA , "+RETSQLNAME("SRC")+"  SRC , "+RETSQLNAME("CTT")+"  CTT ,  "+RETSQLNAME("RCE")+"  RCE 
		cQuery+=" WHERE SRA.D_E_L_E_T_='' AND SRC.D_E_L_E_T_ = '' AND CTT.D_E_L_E_T_='' AND RCE.D_E_L_E_T_=''
		cQuery+=" AND RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT
		cQuery+=" AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC
		cQuery+=" AND RC_PD IN ("+cVerba+")
		cQuery+=" AND RC_PERIODO = '"+cPeriod+"'
		cQuery+=" AND RC_FILIAL = '"+XFILIAL("SRC",cFilant)+"'
		cQuery+=" AND RCE_CODIGO = RA_SINDICA
		if alltrim(aret[3]) <> ""
			cQuery+=" AND RA_SINDICA IN ("+cSindic+")
		endif		
		cQuery+=" GROUP BY RA_FILIAL , RC_PD  , RC_ROTEIR , RCE_CODIGO , RCE_DESCRI
		cQuery+=" ORDER BY  RA_FILIAL


	ELSEif cTipo == "CC"


		cQuery:=" SELECT  RA_FILIAL ,RA_CC , CTT_DESC01 , RC_PD , RC_ROTEIR , CTT_CEI , RCE_CODIGO , RCE_DESCRI, SUM(RC_VALOR) VALOR ,COUNT(RA_MAT) NFUNC
		cQuery+=" FROM "+RETSQLNAME("SRA")+"  SRA , "+RETSQLNAME("SRC")+"  SRC , "+RETSQLNAME("CTT")+"  CTT ,  "+RETSQLNAME("RCE")+"  RCE 
		cQuery+=" WHERE SRA.D_E_L_E_T_='' AND SRC.D_E_L_E_T_ = '' AND CTT.D_E_L_E_T_='' AND RCE.D_E_L_E_T_=''
		cQuery+=" AND RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT
		cQuery+=" AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC
		cQuery+=" AND RC_PD IN ("+cVerba+")
		cQuery+=" AND RC_PERIODO = '"+cPeriod+"'
		cQuery+=" AND RC_FILIAL = '"+XFILIAL("SRC",cFilant)+"'
		cQuery+=" AND RCE_CODIGO = RA_SINDICA
		if alltrim(aret[3]) <> ""
			cQuery+=" AND RA_SINDICA IN ("+cSindic+")
		endif	
		cQuery+=" GROUP BY RA_FILIAL ,RA_CC , CTT_DESC01 , RC_PD ,RC_ROTEIR , CTT_CEI , RCE_CODIGO , RCE_DESCRI
		cQuery+=" ORDER BY  RA_CC

	ELSEif cTipo == "FUNC"

		cQuery:=" SELECT  RA_FILIAL ,RA_CC , CTT_DESC01 , RC_PD ,RC_ROTEIR , CTT_CEI ,RA_NOME , RCE_CODIGO , RCE_DESCRI , SUM(RC_VALOR) VALOR
		cQuery+=" FROM "+RETSQLNAME("SRA")+"  SRA , "+RETSQLNAME("SRC")+"  SRC , "+RETSQLNAME("CTT")+"  CTT ,  "+RETSQLNAME("RCE")+"  RCE
		cQuery+=" WHERE SRA.D_E_L_E_T_='' AND SRC.D_E_L_E_T_ = '' AND CTT.D_E_L_E_T_='' AND RCE.D_E_L_E_T_=''
		cQuery+=" AND RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT
		cQuery+=" AND CTT_FILIAL = SUBSTRING(RA_FILIAL,1,2) AND CTT_CUSTO = RA_CC
		cQuery+=" AND RC_PD IN ("+cVerba+")
		cQuery+=" AND RC_PERIODO = '"+cPeriod+"'
		cQuery+=" AND RC_FILIAL = '"+XFILIAL("SRC",cFilant)+"'
		cQuery+=" AND RCE_CODIGO = RA_SINDICA
		if alltrim(aret[3]) <> ""
			cQuery+=" AND RA_SINDICA IN ("+cSindic+")
		endif	
		cQuery+=" GROUP BY RA_FILIAL ,RA_CC , CTT_DESC01 , RC_PD ,RC_ROTEIR, CTT_CEI ,RA_NOME , RCE_CODIGO , RCE_DESCRI
		cQuery+=" ORDER BY  RA_CC , RA_NOME

	Endif

	IF SELECT("TCO") > 0 
		TCO->(DBCLOSEAREA())
	ENDIF

	TCQUERY cQuery NEW ALIAS TCO

	oSection:Init()



	if cTipo == "EMP"

		WHILE  TCO->(!EOF())

			oSection:Cell("RA_FILIAL"  ):SetValue(TCO->RA_FILIAL)
			oSection:Cell("RA_SINDICA"  ):SetValue(TCO->RCE_CODIGO)
			oSection:Cell("RCE_DESCRI"  ):SetValue(TCO->RCE_DESCRI)
			oSection:Cell("RC_PD"     ):SetValue(TCO->RC_PD)
			oSection:Cell("RC_ROTEIR"    ):SetValue(ALLTRIM(TCO->RC_ROTEIR))
			oSection:Cell("RC_VALOR" ):SetValue(TCO->VALOR )
			oSection:Cell("NFNC" ):SetValue(cvaltochar(TCO->NFUNC))


			oSection:PrintLine()  //Imprimir a Secção
			oReport:IncMeter(1)


			if oReport:Cancel()
				oSection:Finish()
				TCO->(dbCloseArea())

				return
			endif

			TCO->(DBSKIP())

		ENDDO

	elseif cTipo == "CC"

		WHILE  TCO->(!EOF())

			oSection:Cell("RA_FILIAL"):SetValue(TCO->RA_FILIAL)
			oSection:Cell("RA_SINDICA"  ):SetValue(TCO->RCE_CODIGO)
			oSection:Cell("RCE_DESCRI"  ):SetValue(TCO->RCE_DESCRI)
			oSection:Cell("RA_CC"    ):SetValue(TCO->RA_CC)
			oSection:Cell("CTT_DESC" ):SetValue(TCO->CTT_DESC01)
			oSection:Cell("CTT_CEI" ):SetValue(TRANSFORM(TCO->CTT_CEI,"@R 99.999.999/9999-99"))
			oSection:Cell("RC_PD"    ):SetValue(TCO->RC_PD)
			oSection:Cell("RC_ROTEIR"):SetValue(ALLTRIM(TCO->RC_ROTEIR))
			oSection:Cell("RC_VALOR" ):SetValue(TCO->VALOR) //SetValue(TRANSFORM( TCO->VALOR , "@E 99.999.999,99"))
			oSection:Cell("NFNC" ):SetValue(cvaltochar(TCO->NFUNC))

			oSection:PrintLine()  //Imprimir a Secção
			oReport:IncMeter(1)


			if oReport:Cancel()
				oSection:Finish()
				TCO->(dbCloseArea())

				return
			endif

			TCO->(DBSKIP())

		ENDDO


	elseif cTipo == "FUNC"
		cNfuncf := 0
		cValFun := 0
		WHILE  TCO->(!EOF())
			cNfuncf ++
			oSection:Cell("RA_FILIAL"  ):SetValue(TCO->RA_FILIAL)
			oSection:Cell("RA_SINDICA"  ):SetValue(TCO->RCE_CODIGO)
			oSection:Cell("RCE_DESCRI"  ):SetValue(TCO->RCE_DESCRI)
			oSection:Cell("RA_CC"     ):SetValue(TCO->RA_CC)
			oSection:Cell("CTT_DESC"     ):SetValue(TCO->CTT_DESC01)
			oSection:Cell("CTT_CEI" ):SetValue(TRANSFORM(TCO->CTT_CEI,"@R 99.999.999/9999-99"))
			oSection:Cell("RC_PD"     ):SetValue(TCO->RC_PD)
			oSection:Cell("RC_ROTEIR"    ):SetValue(ALLTRIM(TCO->RC_ROTEIR))
			oSection:Cell("RA_NOME"    ):SetValue(ALLTRIM(TCO->RA_NOME))
			oSection:Cell("RC_VALOR" ):SetValue(TCO->VALOR) //SetValue(TRANSFORM( TCO->VALOR , "@E 99.999.999,99"))


			oSection:PrintLine()  //Imprimir a Secção
			oReport:IncMeter(1)


			if oReport:Cancel()
				oSection:Finish()
				TCO->(dbCloseArea())

				return
			endif

			cValFun += TCO->VALOR

			TCO->(DBSKIP())

		ENDDO

		// TOTALIZADORES

		oSection:Cell("RA_FILIAL"  ):SetValue(" ")
		oSection:Cell("RA_SINDICA"  ):SetValue(" ")
		oSection:Cell("RCE_DESCRI"  ):SetValue(" ")
		oSection:Cell("RA_CC"     ):SetValue(" ")
		oSection:Cell("CTT_DESC"     ):SetValue(" ")
		oSection:Cell("CTT_CEI" ):SetValue(" ")
		oSection:Cell("RC_PD"     ):SetValue(" ")
		oSection:Cell("RC_ROTEIR"    ):SetValue(" ")
		oSection:Cell("RA_NOME"    ):SetValue("Total de Funcionário: ")
		oSection:Cell("RC_VALOR" ):SetValue(cNfuncf) //SetValue(TRANSFORM( TCO->VALOR , "@E 99.999.999,99"))

		
		oSection:PrintLine()  //Imprimir a Secção
		oReport:IncMeter(1)
		
		oSection:Cell("RA_FILIAL"  ):SetValue(" ")
		oSection:Cell("RA_SINDICA"  ):SetValue(" ")
		oSection:Cell("RCE_DESCRI"  ):SetValue(" ")
		oSection:Cell("RA_CC"     ):SetValue(" ")
		oSection:Cell("CTT_DESC"     ):SetValue(" ")
		oSection:Cell("CTT_CEI" ):SetValue(" ")
		oSection:Cell("RC_PD"     ):SetValue(" ")
		oSection:Cell("RC_ROTEIR"    ):SetValue(" ")
		oSection:Cell("RA_NOME"    ):SetValue("Total da Verba: R$")
		oSection:Cell("RC_VALOR" ):SetValue(cValFun) //SetValue(TRANSFORM( TCO->VALOR , "@E 99.999.999,99"))
		
		
		oSection:PrintLine()  //Imprimir a Secção
		oReport:IncMeter(1)


	endif


	TCO->(dbCloseArea())
	oSection:Finish()


return
