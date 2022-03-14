#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwcommand.ch'
#include 'topconn.ch'
#include "RPTDEF.CH"
#include "FWPRINTSETUP.CH"
#include 'FWMVCDEF.CH'


user function RSERVFER()

	Local nPrintType	:= 0
	Local nLocal		:= 0
	Local aDevice		:= {}
	Local cSession		:= GetPrinterSession()
	Local cDevice		:= GetProfString( cSession, "PRINTTYPE", "PDF", .T. )
	Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPREVIEW+PD_DISABLEPAPERSIZE
	Local oSetup		:= Nil

	Private cPerg		:= "RSERVFER"
	Private cTitulo		:= "Relatorio de Férias"
	Private oPrint		:= FWMSPrinter():New( cPerg, IMP_PDF , .F., , .T., , oSetup )
	AADD(aDevice,"DISCO")
	AADD(aDevice,"SPOOL")
	AADD(aDevice,"EMAIL")
	AADD(aDevice,"EXCEL")
	AADD(aDevice,"HTML" )
	AADD(aDevice,"PDF"  )
	nPrintType := aScan(aDevice,{|x| x == cDevice })
	nLocal     := If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )

	//Default lEnvMail	:= .F.
	/*
	if  ALLTRIM(SL1->L1_DOC) == ""
	ALERT("Orçamento em aberto, não gera recibo!  Finalize o Orçamento")
	RETURN
	endif
	*/

	oSetup := FWPrintSetup():New(nFlags, cTitulo)
	//If !lEnvMail
	cPerg:= procName()
	CarrPerg(cPerg)
	oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } )
	//EndIf
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 1)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)

	If oSetup:Activate() == PD_OK
		Pergunte( cPerg, .F. )

		MsgRun( "Gerando Relatorio...", "", {|| CursorWait(), RunReport(oSetup),CursorArrow()})
	Else
		MsgInfo("Relatório cancelado pelo usuário.")
		oPrint:Deactivate()
	EndIf

return

Static Function RunReport(oSetup)
	Private nLinha	:= 050
	Private nPag		:= 1
	Private cLogo		:= ""
	Private oFonte	:= TFont():New("Arial",,-11,,.F.,,,,,.f.)
	Private oFonPeq	:= TFont():New("Arial",,-9,,.F.,,,,,.f.)
	Private nSCOl		:= 50
	Private nCont
	Private oFont06n	:= TFont():New("Arial",9,06,.T.,.T.,5,.T.,5,.F.,.F.)
	Private oFont10		:= TFont():New("Arial",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont10n	:= TFont():New("Arial",9,09,.T.,.T.,5,.T.,5,.F.,.F.)
	Private oFont12n	:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.F.,.F.)
	Private oFont12		:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont13n	:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.F.,.F.)
	Private oFont14		:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont15 	:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont16 	:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont18n	:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont16n	:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont20 	:= TFont():New("Arial",9,20,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont20n	:= TFont():New("Arial",9,20,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont22 	:= TFont():New("Arial",9,22,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont22n	:= TFont():New("Arial",9,22,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont24 	:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	Private nCol1		:= 045,nCol2 := 250, nCol3 := 450


	If !File(cLogo)
		cLogo := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf
	oPrint:SetPortrait()
	// ----------------------------------------------
	// Define saida de impressão
	// ----------------------------------------------
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrint:nDevice := IMP_SPOOL
		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oPrint:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	Endif

	//oPrint:StartPage()

	fCabecRel()//Cabeçalho

	oPrint:EndPage()
	nLinha:= 1

	oPrint:Preview()
Return


Static Function fCabecRel
	// parambox
	Local aPergs	    := {}
	Local aRetOpc	    := {}
	Local cNomeCli      := space(200)
	Local nValCPE       := space(20)
	Local cObsCPE       := space(200)
	Local nTotGrl := 0
	Local nTotCc := -1    //Local nTotCc := 0    jf 04/03/2020
	Local nTotCtt := 0
	Local cCtts := ""
	Private nCol1	:= 045,nCol2 := 250, nCol3 := 450
	
	//São 335 dias (quantidade de dias do ano  - 01 mês) + X dias definido pelo sindicato.
	cQuery := " SELECT *
	cQuery += " FROM (
	cQuery += " SELECT *
	cQuery += " FROM (	
	cQuery += " SELECT RA_ADMISSA,RA_SINDICA , RA_MAT , RA_FILIAL , RA_NOME , RA_CC ,RA_SALARIO ,RA_CODFUNC, RF_PD , RF_MAT , RF_FILIAL , RF_STATUS , RF_DATABAS , RF_DATAFIM , RF_DIASDIR,
	cQuery += " CASE 

	cQuery += " WHEN RA_SINDICA = '01'  THEN convert(varchar(10), DATEADD(month, 8, RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '02'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '03'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '04'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '05'  THEN convert(varchar(10), DATEADD(month, 8 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '06'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '07'  THEN convert(varchar(10), DATEADD(month, 8 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '08'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '09'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '10'  THEN convert(varchar(10), DATEADD(month, 6 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '11'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '12'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '67'  THEN convert(varchar(10), DATEADD(month, 0 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '74'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '75'  THEN convert(varchar(10), DATEADD(month, 10 , RF_DATAFIM), 112) 
/*

	cQuery += " WHEN RA_SINDICA = '01'  THEN convert(varchar(10), DATEADD(month, 19 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '02'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '03'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '04'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '05'  THEN convert(varchar(10), DATEADD(month, 19 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '06'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '07'  THEN convert(varchar(10), DATEADD(month, 19 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '08'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '09'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '10'  THEN convert(varchar(10), DATEADD(month, 17 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '11'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '12'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '67'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '74'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '75'  THEN convert(varchar(10), DATEADD(month, 21 , RF_DATAFIM), 112) 
	*/
	cQuery += " END AS MES
	cQuery += " FROM "+RETSQLNAME("SRA")+"  SRA
	cQuery += " INNER JOIN "+RETSQLNAME("SRF")+" SRF ON RF_FILIAL = RA_FILIAL AND RF_MAT = RA_MAT AND RF_STATUS = '1' AND SRF.D_E_L_E_T_ = ''
	cQuery += " WHERE 
	cQuery += " SRA.RA_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+MV_PAR02+"'
	cQuery += " AND SRA.RA_MAT BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"'
	cQuery += " AND SRA.RA_SINDICA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery += " AND SRA.RA_CC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
	cQuery += " AND SRA.RA_SITFOLH NOT IN ('D','A','T','F')
	cQuery += " AND SRA.D_E_L_E_T_=''
	cQuery += " AND convert(varchar(10),EOMONTH ( RF_DATAFIM ),112) = RF_DATAFIM
	cQuery += " )  AS [TBA]
	cQuery += " WHERE SUBSTRING(MES,1,6) BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' 
		
	cQuery += " UNION ALL
	
	cQuery += " SELECT *
	cQuery += " FROM (	
	cQuery += " SELECT RA_ADMISSA,RA_SINDICA , RA_MAT , RA_FILIAL , RA_NOME , RA_CC ,RA_SALARIO ,RA_CODFUNC, RF_PD , RF_MAT , RF_FILIAL , RF_STATUS , RF_DATABAS , RF_DATAFIM , RF_DIASDIR,
	cQuery += " CASE 

	cQuery += " WHEN RA_SINDICA = '01'  THEN convert(varchar(10), DATEADD(month, 8-1, RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '02'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '03'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '04'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '05'  THEN convert(varchar(10), DATEADD(month, 8-1 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '06'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '07'  THEN convert(varchar(10), DATEADD(month, 8-1 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '08'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '09'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '10'  THEN convert(varchar(10), DATEADD(month, 6-1 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '11'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '12'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '67'  THEN convert(varchar(10), DATEADD(month, 0 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '74'  THEN convert(varchar(10), DATEADD(month, 11-1 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '75'  THEN convert(varchar(10), DATEADD(month, 10-1 , RF_DATAFIM), 112) 
/*

	cQuery += " WHEN RA_SINDICA = '01'  THEN convert(varchar(10), DATEADD(month, 19 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '02'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '03'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)  
	cQuery += " WHEN RA_SINDICA = '04'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '05'  THEN convert(varchar(10), DATEADD(month, 19 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '06'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '07'  THEN convert(varchar(10), DATEADD(month, 19 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '08'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '09'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '10'  THEN convert(varchar(10), DATEADD(month, 17 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '11'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112)
	cQuery += " WHEN RA_SINDICA = '12'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '67'  THEN convert(varchar(10), DATEADD(month, 11 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '74'  THEN convert(varchar(10), DATEADD(month, 22 , RF_DATAFIM), 112) 
	cQuery += " WHEN RA_SINDICA = '75'  THEN convert(varchar(10), DATEADD(month, 21 , RF_DATAFIM), 112) 
	*/
	cQuery += " END AS MES
	cQuery += " FROM "+RETSQLNAME("SRA")+"  SRA
	cQuery += " INNER JOIN "+RETSQLNAME("SRF")+" SRF ON RF_FILIAL = RA_FILIAL AND RF_MAT = RA_MAT AND RF_STATUS = '1' AND SRF.D_E_L_E_T_ = ''
	cQuery += " WHERE 
	cQuery += " SRA.RA_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+MV_PAR02+"'
	cQuery += " AND SRA.RA_MAT BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"'
	cQuery += " AND SRA.RA_SINDICA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery += " AND SRA.RA_CC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
	cQuery += " AND SRA.RA_SITFOLH NOT IN ('D','A','T' ,'F')
	cQuery += " AND SRA.D_E_L_E_T_=''
	cQuery += " AND convert(varchar(10),EOMONTH ( RF_DATAFIM ),112) > RF_DATAFIM
	cQuery += " )  AS [TBA]
	cQuery += " WHERE SUBSTRING(MES,1,6) BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' 
	cQuery += " ) TABB
	cQuery += " ORDER BY RA_CC , RA_NOME

	IF SELECT("TSRF") > 0
		TSRF->(DBCLOSEAREA())
	ENDIF

	TcQuery cQuery New Alias TSRF

	nLinha := 1
	lImpCab := .F.
	lTotLoc := .F.
	cLocal := ""
	NvALlOC := 0
	NvalTot := 0
	nColCab := 023
	
	WHILE !TSRF->(EOF())
		
		nTotGrl+= 1
		nTotCc += 1
		IF nLinha >= 760 .or. nLinha % 760
			lImpCab := .T.
			oPrint:EndPage()
			nLinha := 1
		ENDIF 
		
		if RTRIM(TSRF->RA_CC) <> cCtts 
			cCtts := RTRIM(TSRF->RA_CC)
			nTotCtt += 1
		endIf
		if nLinha == 1 .OR. lImpCab
			oPrint:StartPage() 
			lImpCab := .F.
			nLinha := 1

			oPrint:Box (010,020,800,570)	//Box principal
			//oPrint:Box (010,020,120,220)	//Box da logoadmi
			//oPrint:Box (010,220,120,570)	//Box dos itens
			//oPrint:Box (120,020,140,570)	//Box da Informação do Pedido
			//oPrint:Box (140,020,200,570)	//Box dos dados do cliente

			nLinha += 20

			nColCab := 023

			oPrint:Say(nLinha,nColCab ,"Empresa "+ Posicione("SM0",1,cEmpAnt + TSRF->RA_FILIAL,"M0_FILIAL") ,oFont10n)

			nLinha += 12

			oPrint:Say(nLinha,nColCab ,"Escala de férias por limite                     Movimentos de "+MesNo(val(substr(MV_PAR09,5,2))) + " " + substr(MV_PAR09,1,4) + " até  "+MesNo(val(substr(MV_PAR10,5,2))) + " " + substr(MV_PAR10,1,4) + "                    Emissão: " + dtoc(ddatabase) ,oFont10n)

			nLinha += 12
			oPrint:Say(nLinha,nColCab ,"----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" ,oFont10n)
			nLinha += 12
			oPrint:Say(nLinha,nColCab ,"MAT          FUNCAO       FUNCIONÁRIO                                                                       ADMISSA           PROX PERIODO AQUIS.        QTD       LIMITE               BASE                   DESC FUNCAO" ,oFont06n)
			nLinha += 12
			oPrint:Say(nLinha,nColCab ,"----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" ,oFont10n)

			nLinha += 12						
		endif

		if  cLocal == "" .or. cLocal <> ALLTRIM(TSRF->RA_CC)

			if lTotLoc
				oPrint:Say(nLinha,nColCab + 380 ,"-------------------------------------------------------------" ,oFont06n)
				nLinha += 12
				oPrint:Say(nLinha,nColCab + 380 ,"R$ "+ cvaltochar(NvALlOC) ,oFont06n)
				oPrint:Say(nLinha,nColCab + 450 ,"Func no CC: " + cValToChar(nTotCc),oFont06n)
				nTotCc := 0
				NvALlOC := 0 // jf 04/03/2020
			endif

			lTotLoc:= .T.
			cLocal := ALLTRIM(TSRF->RA_CC)

			oPrint:Say(nLinha,nColCab , "Locação : "+ ALLTRIM(TSRF->RA_CC) +" " + POSICIONE("CTT",1,XFILIAL("CTT",TSRF->RA_FILIAL)+TSRF->RA_CC,"CTT_DESC01") ,oFont10n)
			nLinha += 12

		endif

		// matricula 
		oPrint:Say(nLinha,nColCab , ALLTRIM(TSRF->RA_MAT) ,oFont06n)

		// COD FUNCAO
		oPrint:Say(nLinha,nColCab + 27 , ALLTRIM(TSRF->RA_CODFUNC) ,oFont06n)

		// NOME
		oPrint:Say(nLinha,nColCab + 60 , ALLTRIM(TSRF->RA_NOME) ,oFont06n)

		// ADMISSÃO
		oPrint:Say(nLinha,nColCab + 203 , ALLTRIM(DTOC(STOD(TSRF->RA_ADMISSA))) ,oFont06n)

		// INICIO PERIODO 
		oPrint:Say(nLinha,nColCab + 249 , ALLTRIM(DTOC(STOD(TSRF->RF_DATABAS))) ,oFont06n)

		// FIM PERIODO
		oPrint:Say(nLinha,nColCab + 280 , ALLTRIM(DTOC(STOD(TSRF->RF_DATAFIM))) ,oFont06n)

		//QUANTIDADE
		IF TSRF->RA_SINDICA == "01"
			oPrint:Say(nLinha,nColCab + 320 , "8" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "02"
			oPrint:Say(nLinha,nColCab + 320 , "11" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "03"
			oPrint:Say(nLinha,nColCab + 320 , "11" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "04"
			oPrint:Say(nLinha,nColCab + 320 , "11" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "05"
			oPrint:Say(nLinha,nColCab + 320 , "8" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "06"
			oPrint:Say(nLinha,nColCab + 320 , "11" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "10"
			oPrint:Say(nLinha,nColCab + 320 , "6" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "67"
			oPrint:Say(nLinha,nColCab + 320 , "0" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "74"
			oPrint:Say(nLinha,nColCab + 320 , "11" ,oFont06n)
		ELSEIF TSRF->RA_SINDICA == "75"
			oPrint:Say(nLinha,nColCab + 320 , "10" ,oFont06n)
		ENDIF

		//LIMITE
		oPrint:Say(nLinha,nColCab + 340 , ALLTRIM(DTOC(STOD(TSRF->MES))) ,oFont06n)

		// E  UM VALOR UTILIZADO PARA CALCULAR O INSS
		// BASE
		// PEGAR A BASE DE INSS E SOMA 1/3 
		cQuery := " SELECT  TOP 1 (RD_VALOR +  (RD_VALOR / 3)) RD_VALOR 
		cQuery += " FROM "+RETSQLNAME("SRD")+" SRD
		cQuery += " WHERE D_E_L_E_T_ = ''
		cQuery += " AND RD_FILIAL ='"+ TSRF->RA_FILIAL +"'
		cQuery += " AND RD_MAT ='"+ TSRF->RA_MAT +"'
		cQuery += " AND RD_PD = '917'	
		cQuery += " AND RD_ROTEIR = 'FOL'	
		cQuery += " ORDER BY RD_PERIODO DESC

		IF SELECT("TVAL") > 0
			TVAL->(DBCLOSEAREA())
		ENDIF

		TcQuery cQuery New Alias TVAL

		oPrint:Say(nLinha,nColCab + 380 , cValToChar(NOROUND(TVAL->RD_VALOR, 2)) ,oFont06n)
		//total local
		NvALlOC += NOROUND(TVAL->RD_VALOR, 2)
		//total geral
		NvalTot += NvALlOC
		NvalTot := NOROUND(NvalTot, 2)

		//Descrição da funcão
		oPrint:Say(nLinha,nColCab + 423 , POSICIONE("SRJ",1,XFILIAL("SRJ",TSRF->RA_FILIAL)+TSRF->RA_CODFUNC , "RJ_DESC") ,oFont06n)
		nLinha += 12

		oPrint:EndPage()

		TSRF->(dbskip())	

	ENDDO

	oPrint:Say(nLinha,nColCab + 380 ,"-------------------------------------------------------------" ,oFont06n)
	nLinha += 12
	oPrint:Say(nLinha,nColCab + 380 ,"R$ "+ cvaltochar(NvALlOC) ,oFont06n)
	oPrint:Say(nLinha,nColCab + 450 ,"Func no CC: " + cValToChar(nTotCc),oFont06n)
	nLinha += 10
//	oPrint:Say(nLinha,nColCab + 380 ,"-------------------------------------------------------------" ,oFont06n)
	oPrint:Say(nLinha,nColCab + 30 ,"Quantidade total de funcionários: " + cValToChar(nTotGrl),oFont06n)
	oPrint:Say(nLinha,nColCab + 200 ,"Total de CCs: " + cValToChar(nTotCtt),oFont06n)
	oPrint:Say(nLinha,nColCab + 300 ,"Total de R$: " + cValToChar(NvalTot),oFont06n)

Return

Static Function CarrPerg(cPerg)
	Local aHelpPor := {}
	Local aHelpEng := {}
	Local aHelpSpa := {}
	RCMHF001(cPerg,"01","Filial de","Filial de","Filial de","mv_ch1",;
	GetSx3Cache("F2_FILIAL","X3_TIPO"),GetSx3Cache("F2_FILIAL","X3_TAMANHO"),;
	GetSx3Cache("F2_FILIAL","X3_DECIMAL"),0,"G","","SM0","","","MV_PAR01",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"02","Filial ate","Filial ate","Filial ate","mv_ch2",;
	GetSx3Cache("F2_FILIAL","X3_TIPO"),GetSx3Cache("F2_FILIAL","X3_TAMANHO"),;
	GetSx3Cache("F2_FILIAL","X3_DECIMAL"),0,"G","","SM0","","","MV_PAR02",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"03","Funcionário de","Funcionário de","Funcionário de","mv_ch3",;
	GetSx3Cache("RA_MAT","X3_TIPO"),GetSx3Cache("RA_MAT","X3_TAMANHO"),;
	GetSx3Cache("RA_MAT","X3_DECIMAL"),0,"G","","SRA","","","MV_PAR03",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"04","Funcionário ate","Funcionário ate","Funcionário ate","mv_ch4",;
	GetSx3Cache("RA_MAT","X3_TIPO"),GetSx3Cache("RA_MAT","X3_TAMANHO"),;
	GetSx3Cache("RA_MAT","X3_DECIMAL"),0,"G","","SRA","","","MV_PAR04",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


	RCMHF001(cPerg,"05","Sindicato de","Sindicato de","Sindicato de","mv_ch5",;
	GetSx3Cache("RA_SINDICA","X3_TIPO"),GetSx3Cache("RA_SINDICA","X3_TAMANHO"),;
	GetSx3Cache("RA_SINDICA","X3_DECIMAL"),0,"G","","RCE","","","MV_PAR05",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"06","Sindicato ate","Sindicato ate","Sindicato ate","mv_ch6",;
	GetSx3Cache("RA_SINDICA","X3_TIPO"),GetSx3Cache("RA_SINDICA","X3_TAMANHO"),;
	GetSx3Cache("RA_SINDICA","X3_DECIMAL"),0,"G","","RCE","","","MV_PAR06",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"07","Locação de","Locação de","Locação de","mv_ch7",;
	GetSx3Cache("RA_CC","X3_TIPO"),GetSx3Cache("RA_CC","X3_TAMANHO"),;
	GetSx3Cache("RA_CC","X3_DECIMAL"),0,"G","","CTT","","","MV_PAR07",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"08","Locação ate","Locação ate","Locação ate","mv_ch8",;
	GetSx3Cache("RA_CC","X3_TIPO"),GetSx3Cache("RA_CC","X3_TAMANHO"),;
	GetSx3Cache("RA_CC","X3_DECIMAL"),0,"G","","CTT","","","MV_PAR08",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"09","Movimentação de","Movimentação de","Movimentação de","mv_ch9",;
	GetSx3Cache("RFQ_PERIOD","X3_TIPO"),GetSx3Cache("RFQ_PERIOD","X3_TAMANHO"),;
	GetSx3Cache("RFQ_PERIOD","X3_DECIMAL"),0,"G","","","","","MV_PAR09",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"10","Movimentação ate","Movimentação ate","Movimentação ate","mv_ch10",;
	GetSx3Cache("RFQ_PERIOD","X3_TIPO"),GetSx3Cache("RFQ_PERIOD","X3_TAMANHO"),;
	GetSx3Cache("RFQ_PERIOD","X3_DECIMAL"),0,"G","","","","","MV_PAR10",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return

Static Function MesNo(nNum)

	Local cRet := ""

	if nNum = 1
		cRet := "Janeiro"
	elseif nNum = 2
		cRet := "Fevereiro"	
	elseif nNum = 3
		cRet := "Março"	
	elseif nNum = 4
		cRet := "Abril"	
	elseif nNum = 5
		cRet := "Maio"	
	elseif nNum = 6
		cRet := "Junho"	
	elseif nNum = 7
		cRet := "Julho"	
	elseif nNum = 8
		cRet := "Agosto"	
	elseif nNum = 9
		cRet := "Setembro"	
	elseif nNum = 10
		cRet := "Outubro"
	elseif nNum = 11
		cRet := "Novembro"
	elseif nNum = 12
		cRet := "Dezembro"				
	endif
Return cRet



Static function RCMHF001(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
	cF3, cGrpSxg,cPyme,; 
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
	cDef02,cDefSpa2,cDefEng2,; 
	cDef03,cDefSpa3,cDefEng3,; 
	cDef04,cDefSpa4,cDefEng4,; 
	cDef05,cDefSpa5,cDefEng5,; 
	aHelpPor,aHelpEng,aHelpSpa,cHelp) 

	LOCAL aArea := GetArea() 
	Local cKey 
	Local lPort := .f. 
	Local lSpa := .f. 
	Local lIngl := .f. 

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

	cPyme	:= Iif( cPyme	== Nil, " ", cPyme	) 
	cF3		:= Iif( cF3		== NIl, " ", cF3	) 
	cGrpSxg	:= Iif( cGrpSxg	== Nil, " ", cGrpSxg) 
	cCnt01	:= Iif( cCnt01	== Nil, "" , cCnt01	) 
	cHelp	:= Iif( cHelp	== Nil, "" , cHelp	) 

	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

	If !( DbSeek( cGrupo + cOrdem )) 

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

		Reclock( "SX1" , .T. ) 

		Replace X1_GRUPO   With cGrupo 
		Replace X1_ORDEM   With cOrdem 
		Replace X1_PERGUNT With cPergunt 
		Replace X1_PERSPA With cPerSpa 
		Replace X1_PERENG With cPerEng 
		Replace X1_VARIAVL With cVar 
		Replace X1_TIPO    With cTipo 
		Replace X1_TAMANHO With nTamanho 
		Replace X1_DECIMAL With nDecimal 
		Replace X1_PRESEL With nPresel 
		Replace X1_GSC     With cGSC 
		Replace X1_VALID   With cValid 

		Replace X1_VAR01   With cVar01 

		Replace X1_F3      With cF3 
		Replace X1_GRPSXG With cGrpSxg 

		If Fieldpos("X1_PYME") > 0 
			If cPyme != Nil 
				Replace X1_PYME With cPyme 
			Endif 
		Endif 

		Replace X1_CNT01   With cCnt01 
		If cGSC == "C" 
			Replace X1_DEF01   With cDef01 
			Replace X1_DEFSPA1 With cDefSpa1 
			Replace X1_DEFENG1 With cDefEng1 

			Replace X1_DEF02   With cDef02 
			Replace X1_DEFSPA2 With cDefSpa2 
			Replace X1_DEFENG2 With cDefEng2 

			Replace X1_DEF03   With cDef03 
			Replace X1_DEFSPA3 With cDefSpa3 
			Replace X1_DEFENG3 With cDefEng3 

			Replace X1_DEF04   With cDef04 
			Replace X1_DEFSPA4 With cDefSpa4 
			Replace X1_DEFENG4 With cDefEng4 

			Replace X1_DEF05   With cDef05 
			Replace X1_DEFSPA5 With cDefSpa5 
			Replace X1_DEFENG5 With cDefEng5 
		Endif 

		Replace X1_HELP With cHelp 

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

		MsUnlock() 
	Else 

		lPort:= ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
		lSpa	:= ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
		lIngl:= ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

		If lPort .Or. lSpa .Or. lIngl 
			RecLock("SX1",.F.) 
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
			EndIf 
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
			EndIf 
			If lIngl 
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
			EndIf 
			SX1->(MsUnLock()) 
		EndIf 
	Endif 

	RestArea( aArea ) 

Return