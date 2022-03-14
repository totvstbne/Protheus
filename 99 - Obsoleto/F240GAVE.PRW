#INCLUDE "PROTHEUS.CH"

/*

Programa:  Rotina    Autor:  Dilson Castro      Data:  11/07/2013 

Descrição: Ponto de entrada que substitue a tela de parâmetros da rotina de geração de borderô 
          
Uso: Geração do Borderô 

*/

User Function F240GAVE()

	Local aMDados 	:= PARAMIXB
	
	Local lPanelFin 	:= If (FindFunction("IsPanelFin"),IsPanelFin(),.F.) 
	
	Local cMNumBor   	
	Local dMVenIni	
	Local dMVenFim	
	Local nMLimite   	
	Local cMPort  	
	Local cMAgen  	
	Local cMConta 	
	Local cMContrat 	
	Local cMMoeda 	
	Local aMMoedas   	
	Local cMModPgt  	
	Local cMTipoPa  	
	
	cMNumBor	:= aMDados[01]   	
	dMVenIni	:= aMDados[02]	
	dMVenFim	:= aMDados[03]
	nMLimite	:= aMDados[04]	
	cMPort  	:= aMDados[05]
	cMAgen  	:= aMDados[06]
	cMConta 	:= aMDados[07]
	cMContrat 	:= aMDados[08]
	cMMoeda 	:= aMDados[09]
	aMMoedas	:= aMDados[10]
	cMModPgt  	:= aMDados[11]
	cMTipoPa  	:= aMDados[12]
	nOpc		:= aMDados[13]

	aSize := MSADVSIZE()

	If lPanelFin 			

		dbSelectArea("SE2")

		oPanelDados := FinWindow:GetVisPanel()

		oPanelDados:FreeChildren()

		aDim := DLGinPANEL(oPanelDados)

		DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )							

		nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 196) /2		 					

		nEspLin  := 0		
			
   Else   

	   	nEspLarg := 2 
	  	nEspLin  := 2
	
		DEFINE MSDIALOG oDlg FROM  15,6 TO 219,404 TITLE "Borderô de Pagamentos (USIBRAS)" PIXEL  

   Endif
	   
  	oDlg:lMaximized := .F.

	oPanel := TPanel():New(0,0,"",oDlg,,.T.,.T.,,,20,20)

	oPanel:Align := CONTROL_ALIGN_ALLCLIENT    		
	   
  	@ 00 + nEspLin, nEspLarg TO 29 + nEspLin, 196 + nEspLarg OF oPanel  PIXEL
	@ 34 + nEspLin, nEspLarg TO 63 + nEspLin, 196 + nEspLarg OF oPanel  PIXEL
	@ 68 + nEspLin, nEspLarg TO 97 + nEspLin, 196 + nEspLarg OF oPanel  PIXEL
	 	  
	nEspLarg := nEspLarg -1
	
	@ 06 + nEspLin, 009+nEspLarg SAY "Numero"			SIZE 23, 7 OF oPanel PIXEL  // Numero
	@ 06 + nEspLin, 045+nEspLarg SAY "Vencto de"		SIZE 32, 7 OF oPanel PIXEL  // Vencto de   
	@ 06 + nEspLin, 090+nEspLarg SAY "Ate"				SIZE 32, 7 OF oPanel PIXEL  // Ate
	@ 06 + nEspLin, 135+nEspLarg SAY "Limite Valor"	SIZE 53, 7 OF oPanel PIXEL  // Limite Valor
	@ 40 + nEspLin, 009+nEspLarg SAY "Banco"			SIZE 23, 7 OF oPanel PIXEL  // Banco    
	@ 40 + nEspLin, 045+nEspLarg SAY "Agencia"		SIZE 32, 7 OF oPanel PIXEL  // Agencia
	@ 40 + nEspLin, 085+nEspLarg SAY "Conta"			SIZE 32, 7 OF oPanel PIXEL  // Conta
	@ 40 + nEspLin, 151+nEspLarg SAY "Contrato"		SIZE 53, 7 OF oPanel PIXEL  // Contrato
	@ 73 + nEspLin, 009+nEspLarg SAY "Moeda"			SIZE 23, 7 OF oPanel PIXEL  // Moeda
	
	// @ 73 + nEspLin, 063+nEspLarg SAY "Modelo"			SIZE 22, 7 OF oPanel PIXEL  // Modelo
	// @ 73 + nEspLin, 097+nEspLarg SAY "Tipo Pagto"		SIZE 32, 7 OF oPanel PIXEL  // Tipo Pagto	
	
	// Linha 1

	@ 15 + nEspLin, 009 + nEspLarg MSGET cMNumBor		SIZE 32, 10 OF oPanel PIXEL Picture "@!" Valid If(nOpc <> 0 ,!Empty(cMNumBor) .And. FA240Num(cMNumBor),.T.)
	
	@ 15 + nEspLin, 045 + nEspLarg MSGET dMVenIni    SIZE 45, 10 OF oPanel PIXEL  HASBUTTON
	
	@ 15 + nEspLin, 090 + nEspLarg MSGET dMVenFim    SIZE 45, 10 OF oPanel PIXEL  HASBUTTON Valid If(nOpc <> 0 , FA240DATA(dMVenIni,dMVenFim),.T.)
	
	@ 15 + nEspLin, 135 + nEspLarg MSGET nMLimite    SIZE 60, 10 OF oPanel PIXEL  HASBUTTON Picture "@E 999,999,999,999.99" Valid If(nOpc <> 0 , nMLimite >= 0,.T.) 

	// Linha 2

	@ 49 + nEspLin, 009 + nEspLarg MSGET cMPort		SIZE 10, 10 OF oPanel PIXEL Picture "@!" F3 "SA6" 	Valid If(nOpc <> 0,CarregaSA6(@cMPort,,,.t.),.T.) HASBUTTON
	
	@ 49 + nEspLin, 045 + nEspLarg MSGET cMAgen  		SIZE 26, 10 OF oPanel PIXEL Picture "@!" Valid If(nOpc <> 0,CarregaSA6(@cMPort,@cMAgen,,.T.),.T.)
	
	@ 49 + nEspLin, 085 + nEspLarg MSGET cMConta 		SIZE 62, 10 OF oPanel PIXEL Picture "@!" Valid If(nOpc <> 0,CarregaSA6(@cMPort,@cMAgen,@cMConta,.T.,,.T.),.T.)
	
	@ 49 + nEspLin, 151 + nEspLarg MSGET cMContrat 	SIZE 42, 10 OF oPanel PIXEL Picture "@S3"
	
	// Linha 3

	@ 82 + nEspLin, 009 + nEspLarg MSCOMBOBOX oCbx VAR cMMoeda ITEMS aMMoedas SIZE 46, 50 OF oPanel PIXEL
		
	// @ 82 + nEspLin, 063 + nEspLarg MSGET cMModPgt		SIZE 25, 10 OF oPanel PIXEL Picture "@!"  Valid If(!Empty(cMModPgt),ExistCpo("SX5", + "58" + cMModPgt),.T.) F3 "58" HASBUTTON
	// @ 82 + nEspLin, 097 + nEspLarg MSGET cMTipoPa    SIZE 25, 10 OF oPanel PIXEL Picture "@!"  Valid If(!Empty(cMTipoPa),ExistCpo("SX5", + "59" + cMTipoPa),.T.) F3 "59" HASBUTTON
	   
	If lPanelFin 					

		oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])			

		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{||cVar := cMMoeda,nOpc:=1,Iif(F240TudoOk(oDlg),oDlg:End(),nOpc:=0)},{||oDlg:End()})
			
		cAlias := FinWindow:cAliasFile     

		dbSelectArea(cAlias)					
	
   Else	

		DEFINE SBUTTON FROM 83, 140 TYPE 1 ENABLE OF oPanel ACTION (cVar := cMMoeda,nOpc := 1,Iif(F240TudoOk(oDlg),oDlg:End(),nOpc := 0))
			
		DEFINE SBUTTON FROM 83, 170 TYPE 2 ENABLE OF oPanel ACTION oDlg:End() 
	
		ACTIVATE MSDIALOG oDlg CENTERED
			           
	Endif
	
	aMDados[01] := cMNumBor	   	
	aMDados[02] := dMVenIni		
	aMDados[03] := dMVenFim	
	aMDados[04] := nMLimite		
	aMDados[05] := cMPort  	
	aMDados[06] := cMAgen  	
	aMDados[07] := cMConta 	
	aMDados[08] := cMContrat 
	aMDados[09] := cMMoeda 	
	aMDados[10] := aMMoedas	
	aMDados[11] := cMModPgt  
	aMDados[12] := cMTipoPa  
	aMDados[13] := nOpc		
	
Return(aMDados)