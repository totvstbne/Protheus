#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwcommand.ch'
#include 'topconn.ch'
#include "RPTDEF.CH"
#include "FWPRINTSETUP.CH"
#include 'FWMVCDEF.CH'

/////////////////////////////////////////
// relatório de nf                     //
// joao filho                          //
// totvs - ce                          //
// =================================== //
// 06/02/19 -> VALIDADO COM O CLIENTE  //
/////////////////////////////////////////
 

user function RRECNFS()

	Local nPrintType	:= 0
	Local nLocal		:= 0
	Local aDevice		:= {}
	Local cSession		:= GetPrinterSession()
	Local cDevice		:= GetProfString( cSession, "PRINTTYPE", "PDF", .T. )
	Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPREVIEW+PD_DISABLEPAPERSIZE
	Local oSetup		:= Nil

	Private cPerg		:= "RRECNFS"
	Private cTitulo		:= "Relatorio do Recibo"
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

	Private nCol1	:= 045,nCol2 := 250, nCol3 := 450


	cQuery := " SELECT  *
	cQuery += " FROM  "+RETSQLNAME("SF2")+" SF2 , "+RETSQLNAME("SC5")+" SC5
	cQuery += " WHERE  "
	cQuery += "       F2_FILIAL BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "
	cQuery += " AND   F2_CLIENTE BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "
	cQuery += " AND   F2_DOC BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"' "
	cQuery += " AND   SF2.D_E_L_E_T_ = ''

	cQuery += " AND   C5_NOTA = F2_DOC 
	cQuery += " AND   C5_SERIE = F2_SERIE
	cQuery += " AND   C5_FILIAL = F2_FILIAL
	cQuery += " AND   C5_CLIENTE = F2_CLIENTE
	cQuery += " AND   C5_LOJACLI = F2_LOJA
	cQuery += " ORDER BY F2_DOC  "

	IF SELECT("TSF2") > 0
		TSF2->(DBCLOSEAREA())
	ENDIF

	TcQuery cQuery New Alias TSF2

	WHILE !TSF2->(EOF())  
	
	_RECISS:=POSICIONE("SA1",1,XFILIAL("SA1")+TSF2->F2_CLIENTE+TSF2->F2_LOJA,"A1_RECISS")//RECOLHE ISS

		oPrint:StartPage() 
		nLinha := 1

		oPrint:Box (010,020,800,570)	//Box principal
		//oPrint:Box (010,020,120,220)	//Box da logo	
		//oPrint:Box (010,220,120,570)	//Box dos itens
		//oPrint:Box (120,020,140,570)	//Box da Informação do Pedido
		//oPrint:Box (140,020,200,570)	//Box dos dados do cliente

		nLinha += 50

		nColCab := 023

		oPrint:Say(nLinha,nColCab + 200,Posicione("SM0",1,cEmpAnt + TSF2->F2_FILIAL,"M0_FILIAL") ,oFont12n)

		nLinha += 12

		oPrint:Say(nLinha,nColCab + 150,"-----------------------------------------------" ,oFont24)
		nLinha += 12
		oPrint:Say(nLinha,nColCab + 250,"R E C I B O" ,oFont20)
		nLinha += 12
		oPrint:Say(nLinha,nColCab + 150,"-----------------------------------------------" ,oFont24)
		nLinha += 12
		//oPrint:Say(nLinha,nColCab + 150,'NF: '+ ALLTRIM(TSF2->F2_DOC) + " de " + MesNo(Month(ddatabase)) + " de " + cValToChar(year(ddatabase)) ,oFont16)
		IF ALLTRIM(TSF2->C5_YCOMPET) <> ""
			oPrint:Say(nLinha,nColCab + 150,'RPS: '+ ALLTRIM(TSF2->F2_DOC) + " de " + MesNo(VAL(SUBSTR(TSF2->C5_YCOMPET,5,2))) + " de " + SUBSTR(TSF2->C5_YCOMPET,1,4) ,oFont16)
		ELSE
			oPrint:Say(nLinha,nColCab + 150,'RPS: '+ ALLTRIM(TSF2->F2_DOC) ,oFont16)
		ENDIF
		nLinha += 30
		oPrint:Say(nLinha,nColCab + 150,'NFE: '+ ALLTRIM(TSF2->F2_NFELETR)  ,oFont16)
		//C5_YCOMPET
		nLinha += 30
		nLiq := TSF2->F2_VALBRUT 
		IF _RECISS=='1' //Sim
			nLiq := nLiq - (TSF2->F2_VALIRRF + TSF2->F2_VALISS + TSF2->F2_VALCOFI + TSF2->F2_VALPIS + TSF2->F2_VALCSLL  + TSF2->F2_VALINSS)
		ELSE    
			nLiq := nLiq - (TSF2->F2_VALIRRF + TSF2->F2_VALCOFI + TSF2->F2_VALPIS + TSF2->F2_VALCSLL  + TSF2->F2_VALINSS)
		ENDIF
		
		oPrint:Say(nLinha,nColCab + 100," Total desta nota ............... R$ "+ cvaltochar(TSF2->F2_VALBRUT) ,oFont12n)
		nLinha += 15
		oPrint:Say(nLinha,nColCab + 100," IRRF .................................. R$ "+ cvaltochar(TSF2->F2_VALIRRF) ,oFont12n)
		IF _RECISS=='1' //Sim
			nLinha += 15
			oPrint:Say(nLinha,nColCab + 100," ISS .................................... R$ "+ cvaltochar(TSF2->F2_VALISS ) ,oFont12n) 
		ENDIF
		nLinha += 15
		oPrint:Say(nLinha,nColCab + 100," COFINS ............................. R$ "+ cvaltochar(TSF2->F2_VALCOFI ) ,oFont12n)
		nLinha += 15
		oPrint:Say(nLinha,nColCab + 100," PIS ..................................... R$ "+ cvaltochar(TSF2->F2_VALPIS ) ,oFont12n)
		nLinha += 15
		oPrint:Say(nLinha,nColCab + 100," CSLL .................................. R$ "+ cvaltochar(TSF2->F2_VALCSLL  ) ,oFont12n)
		nLinha += 15
		oPrint:Say(nLinha,nColCab + 100," INSS ................................... R$ "+ cvaltochar(TSF2->F2_VALINSS  ) ,oFont12n)
		nLinha += 15
		oPrint:Say(nLinha,nColCab + 100," Liquido a Receber ............ R$ "+ cvaltochar(nLiq) ,oFont12n)

		nLinha += 100
		oPrint:Say(nLinha,nColCab + 100," Recebemos de "+ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+TSF2->F2_CLIENTE+TSF2->F2_LOJA,"A1_NOME")) ,oFont14)
		nLinha += 15  

		if len(Extenso(nLiq)) > 45
			oPrint:Say(nLinha,nColCab + 100," Liquida de R$ "+ cvaltochar(nLiq) + '(' + substr(Extenso(nLiq),1,45),oFont14)
			nLinha += 15
			oPrint:Say(nLinha,nColCab + 100, substr(Extenso(nLiq),46,len(Extenso(nLiq)))+").",oFont14)
		else
			oPrint:Say(nLinha,nColCab + 100," Liquida de R$ "+ cvaltochar(nLiq) + " ( " + Extenso(nLiq) +").",oFont14)
		endif

		nLinha += 50

		oPrint:Say(nLinha,nColCab + 100,"Pelo que Passamos o Presente Recibo Dando Plena Quitação ",oFont14)
		nLinha += 15

		oPrint:Say(nLinha,nColCab + 200,"Fortaleza - CE  ____/____/_____",oFont14)


		oPrint:EndPage()

		TSF2->(dbskip())	

	ENDDO

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

	RCMHF001(cPerg,"03","Cliente de","Cliente de","Cliente de","mv_ch3",;
	GetSx3Cache("F2_CLIENTE","X3_TIPO"),GetSx3Cache("F2_CLIENTE","X3_TAMANHO"),;
	GetSx3Cache("F2_CLIENTE","X3_DECIMAL"),0,"G","","SA1","","","MV_PAR03",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"04","Cliente ate","Cliente ate","Cliente ate","mv_ch4",;
	GetSx3Cache("F2_CLIENTE","X3_TIPO"),GetSx3Cache("F2_CLIENTE","X3_TAMANHO"),;
	GetSx3Cache("F2_CLIENTE","X3_DECIMAL"),0,"G","","SA1","","","MV_PAR04",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


	RCMHF001(cPerg,"05","NF de","NF de","NF de","mv_ch5",;
	GetSx3Cache("F2_DOC","X3_TIPO"),GetSx3Cache("F2_DOC","X3_TAMANHO"),;
	GetSx3Cache("F2_DOC","X3_DECIMAL"),0,"G","","","","","MV_PAR05",;
	"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	RCMHF001(cPerg,"06","NF ate","NF ate","NF ate","mv_ch6",;
	GetSx3Cache("F2_DOC","X3_TIPO"),GetSx3Cache("F2_DOC","X3_TAMANHO"),;
	GetSx3Cache("F2_DOC","X3_DECIMAL"),0,"G","","","","","MV_PAR06",;
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