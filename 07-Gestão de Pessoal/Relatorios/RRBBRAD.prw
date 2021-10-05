#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

#include 'fwcommand.ch'
#include "RPTDEF.CH"
#include "FWPRINTSETUP.CH"
#include 'FWMVCDEF.CH'



// FONTE PARA LER ARQUIVO DE RETORNO DO BANCO BRADESCO 
// E GERA UM RELATÓRIO, PARA SER USADO COMO COMPROVANTE DE PAGAMENTO 


User Function RRBBRAD()

	Local cExt      := "Arquivo RET | *.RET"
	Local cPath     := "Selecione diretório"

	Local cArq      

	Private cRetBrad	
	Private cError   := ""
	Private aLinhas  := {}


	cArq     := cGetFile(cExt,cExt)
	cRetBrad := cArq 

	IF Empty(cRetBrad)		
		Aviso("Aviso","Arquivo vazio",{"ok"})
		Return(.F.)
	ENDIF


	// ler todas as linhas do arquivo 
	MsAguarde({|| fImpDados()},"Leitura do Arquivo","Aguarde a finalização do processamento...",.F.)
	//fImpDados()
	// VERIFICO SE O ARQUIVO É DE RETORNO 
	IF SUBSTR(aLinhas[1],143,1) <> '2'
		Aviso("Aviso","Arquivo não é de retorno",{"ok"})
		Return(.F.)
	ENDIF 
	// fazer o tratamento para relatório 
	Processa({|| RelPro()})

return

Static Function fImpDados()

	Local nVinfo := 0 
	aLinh2 := {}
	

	FT_FUse(cRetBrad)   // ler arquivo 
	FT_FGoTop()         // vai para o topo
	i := 1
	while ( !FT_FEof() )
		IncProc()
		if i == 1
			AADD(aLinhas,{"               0000000000000AAAAAAAAAAAAAAAAAAA",FT_FREADLN()})
		ELSEif i == 2
			AADD(aLinhas,{"               0000000000000AAAAAAAAAAAAAAABB",FT_FREADLN()})
		ELSE
			if alltrim(SUBSTR(FT_FREADLN(),14,1)) == "A"
				if alltrim(SUBSTR(FT_FREADLN(),44,30)) = ""
					AADD(aLinhas,{"ZZZZZZZZZZZZZZZZZZZZZZZ",FT_FREADLN()})
				else
					AADD(aLinhas,{alltrim(SUBSTR(FT_FREADLN(),44,30)),FT_FREADLN()})
					
					nVinfo += VAL(SUBSTR(FT_FREADLN(),120,15))/100
					MsProcTxt("Total >> R$"+ cvaltochar(nVinfo)+" !")	
					
				endif
			endif
		endif
		i++
		FT_FSkip()
	enddo

	aLinh2 := ASORT(aLinhas, , , { | x,y | x[1] < y[1] } )

	aLinhas := {}

	for nAux := 1 to Len(aLinh2)
		AADD(aLinhas,aLinh2[nAux][2])
	next

Return 

// impressao do relatório 

Static Function RelPro()

	Local nPrintType	:= 0
	Local nLocal		:= 0
	Local aDevice		:= {}
	Local cSession		:= GetPrinterSession()
	Local cDevice		:= GetProfString( cSession, "PRINTTYPE", "PDF", .T. )
	Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPREVIEW+PD_DISABLEPAPERSIZE
	Local oSetup		:= Nil

	Private cPerg		:= "RRBBRAD"
	Private cTitulo		:= "Relatorio do retorno Bradesco"
	Private oPrint		:= FWMSPrinter():New( cPerg, IMP_PDF , .F., , .T., , oSetup )
	AADD(aDevice,"DISCO")
	AADD(aDevice,"SPOOL")
	AADD(aDevice,"EMAIL")
	AADD(aDevice,"EXCEL")
	AADD(aDevice,"HTML" )
	AADD(aDevice,"PDF"  )
	nPrintType := aScan(aDevice,{|x| x == cDevice })
	nLocal     := If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )

	oSetup := FWPrintSetup():New(nFlags, cTitulo)
	//If !lEnvMail
	//cPerg:= procName()
	//CarrPerg(cPerg)
	//oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } )
	//EndIf
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , 1)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)

	If oSetup:Activate() == PD_OK
		//Pergunte( cPerg, .F. )
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

	cLogo := "carmehil.bmp" 
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

	oPrint:StartPage()

	fCabecRel()//Cabeçalho

	oPrint:EndPage()
	nLinha:= 1

	oPrint:Preview()
Return


Static Function fCabecRel()
	// parambox
	Local aPergs	    := {}
	Local aRetOpc	    := {}
	Local cNomeCli      := space(200)
	Local nValCPE       := space(20)
	Local cObsCPE       := space(200)
	Local cEmpr			:= ""
	Local cFil			:= ""
	Local nTotal		:= 0
	Local nTotal1		:= 0
	Local nTotal2		:= 0
	Local lRejei		:= .F.

	Private nCol1	:= 045,nCol2 := 250, nCol3 := 450

	If MsgYesNo("Imprimir somente não processados ?","Atenção")
		lRejei := .T.
	endif

	nLinha := 1

	// descobrir a empresa 
	DbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DbGoTop())

	while !SM0->(EOF())
		if SM0->M0_CGC == SUBSTR(aLinhas[1],19,14)
			cEmpr := SM0->M0_NOME
			cFil  := SM0->M0_CODFIL
		endif 
		SM0->(dbskip())
	enddo


	// criando a primeila folha

	lCab := .T.

	for nAux := 1 to len(aLinhas)

		IF nLinha >= 780 .or. nLinha % 780
			lCab := .T.
			oPrint:EndPage()
			oPrint:StartPage()
			nLinha := 1
		ENDIF 
		//oPrint:StartPage() 
		IF nAux == 1 .OR. lCab
			oPrint:Box (010,020,800,570)	//Box principal
			nLinha  += 30
			nColCab := 023
			oPrint:Say(nLinha,300, "Empresa "+ cEmpr ,oFont12n)

			nLinha  += 30
			// titulo 
			oPrint:Say(nLinha,100, "Retorno de arquivo de credito BRADESCO ",oFont16n)
			// DATA 
			oPrint:Say(nLinha,400, DTOC(DDATABASE) + "  " + SUBSTR(TIME(),1,5) ,oFont12n)
			nLinha  += 20
			// LINHA DIVISÃO 

			oPrint:Line( nLinha, 30, nLinha, 550)

			nLinha  += 20
			lCab := .F.

			//loop


		ENDIF 

		if SUBSTR(aLinhas[nAux],14,1) == "A"

			if lRejei .and. SUBSTR(aLinhas[nAux],231,2) == "BD"
				loop
			endif

			// NOME DO FUNCIONÁIO			
			oPrint:Say(nLinha,023, ALLTRIM(SUBSTR(aLinhas[nAux],44,30)) ,oFont10n)

			// NUMERO DO DOCUMENTO 			
			oPrint:Say(nLinha,250, cvaltochar(val(ALLTRIM(SUBSTR(aLinhas[nAux],74,20)))) ,oFont10n)

			// DATA			
			oPrint:Say(nLinha,275, ALLTRIM(SUBSTR(aLinhas[nAux],94,2))+"/"+ALLTRIM(SUBSTR(aLinhas[nAux],96,2))+"/"+ALLTRIM(SUBSTR(aLinhas[nAux],98,4)) ,oFont10n)

			//VALOR 
			oPrint:Say(nLinha,350, cvaltochar(VAL(SUBSTR(aLinhas[nAux],120,15))/100) + " > " ,oFont10n)

			// COD RETORNO 
			IF SUBSTR(aLinhas[nAux],231,2) == "BD"// INCLUSOA COM SUCESSO
				oPrint:Say(nLinha,400, "BD INCLUSÃO COM SUCESSO" ,oFont10n) 
				nTotal1 += VAL(SUBSTR(aLinhas[nAux],120,15))/100
			ELSE 
				oPrint:Say(nLinha,400, SUBSTR(aLinhas[nAux],231,2)+" - PAGAMENTO NÃO EFETUADO" ,oFont10n)
				nTotal2 += VAL(SUBSTR(aLinhas[nAux],120,15))/100
			ENDIF 


			nLinha  += 20

			nTotal += VAL(SUBSTR(aLinhas[nAux],120,15))/100
		else
			loop
		endif 

		//oPrint:EndPage()
	next

	// LINHA DIVISÃO 

	oPrint:Line( nLinha, 30, nLinha, 550)
	nLinha  += 20
	oPrint:Say(nLinha,50, "Total dos pagamentos realizados " ,oFont10n)
	oPrint:Say(nLinha,200, CVALTOCHAR(nTotal1) ,oFont10n)
	nLinha  += 15
	oPrint:Say(nLinha,50, "Total dos pagamentos não realizados " ,oFont10n)
	oPrint:Say(nLinha,200, CVALTOCHAR(nTotal2) ,oFont10n)
	nLinha  += 15
	oPrint:Say(nLinha,50, "Total dos pagamentos " ,oFont10n)
	oPrint:Say(nLinha,200, CVALTOCHAR(nTotal) ,oFont10n)

Return
