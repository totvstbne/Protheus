#include "rwmake.ch" 
#include "Protheus.Ch"
#include "Topconn.Ch"
#include "MSOle.Ch"

#define oleWdFormatDocument "0"
#define oleWdFormatHTML "102"
#define oleWdFormatPDF "17"

/*/{Protheus.doc} BRLR001
Geração da Proposta em DOT
@author Diogo
@since 09/06/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/

User Function BRLR001(cPropCtr)

	Local aParam	:= {}
	Local aRet		:= {}
	Local cCam		:= Space(80)
	Local aPergs	:= {}
	Local cProps	:= Space(GetSx3Cache("ADY_PROPOS","X3_TAMANHO"))
	Local cRevs		:= Space(GetSx3Cache("ADY_PREVIS","X3_TAMANHO"))
	Private oWord 	:= Nil
	Private aExc	:= {}
	Default	cPropCtr:= ""	

	cDirDocs := MsDocPath()
	cArquivo := space(300)

	If empty(cPropCtr)
		aAdd(aPergs,{1,"Proposta:" 		,cProps		,"",'.T.',"ADY1",'.T.',80	,.T.})

		If !ParamBox(aPergs,"Caminho",@aRet,,,,,,,"_BRL7",.T.,.T.)
			Return
		Endif
		cAdyProp	:=	Alltrim(aRet[1])

	Else
		cAdyProp:=	Alltrim(cPropCtr)
	Endif

	Processa( {|| FProcess007() }, "", "Gerando proposta, aguarde...", .F. )


Return

Static Function FProcess007()

	//ADY_FILIAL+ADY_OPORTU
	ADY->(dbSetOrder(1))
	ADY->(dbSeek(xFilial("ADY")+cAdyProp))

	cFileOpen:= "C:\totvs\proposta.dotm"	
	
	If !File(cFileOpen)
		MsgAlert("Arquivo de modelo da proposta(proposta.dotm) não encontrado no diretorio!","Alerta")	
		Return
	EndIf

	// Criar o link do Protheus com o Word.
	oWord := OLE_CreateLink()

	// Cria um novo baseado no modelo.
	OLE_NewFile( oWord, cFileOpen )

	// Exibe ou oculta a janela da aplicacao Word no momento em que estiver descarregando os valores.
	OLE_SetProperty( oWord, oleWdVisible, .T. )	

	// Exibe ou oculta a aplicacao Word.
	OLE_SetProperty( oWord, oleWdWindowState, '1' )
	
	aExc:= {}
	aRet:= FDadosAR() //Busca os dados a serem considerados no DOT
	aRet2:= FDadostb() //Busca os dados a serem considerados no DOT
	

	// Atribui os valores as variaveis.
	OLE_SetDocumentVar( oWord, 'cDia'		, aRet[1]  )
	OLE_SetDocumentVar( oWord, 'cMes'		, aRet[2]  )
	OLE_SetDocumentVar( oWord, 'cAno'		, aRet[3]  )
	OLE_SetDocumentVar( oWord, 'cCliente'	, aRet[4]  )
	OLE_SetDocumentVar( oWord, 'cGlobal'	, "R$ " +TRANSFORM(aRet[5], "@E 999,999,999.99") )
	OLE_SetDocumentVar( oWord, 'cNome'	    , aRet[6]  )

	nAuxTot := len(aRet2)
	OLE_SetDocumentVar(oWord, 'prt_nroitens', str(nAuxTot))


	

	nI := 0
	nCount := 1
	Do While len(aRet2) >= nCount 
		nI++
		
		OLE_SetDocumentVar( oWord, 'prt_cod'+Alltrim(str(nI)), aRet2[nCount][1]  )		
		OLE_SetDocumentVar( oWord, 'prt_descr'+Alltrim(str(nI)), aRet2[nCount][2] )
		OLE_SetDocumentVar( oWord, 'prt_vtot'+Alltrim(str(nI)),  aRet2[nCount][3]  )
		OLE_SetDocumentVar( oWord, 'prt_vto1'+Alltrim(str(nI)),  aRet2[nCount][4]  )
		OLE_SetDocumentVar( oWord, 'prt_vto2'+Alltrim(str(nI)), aRet2[nCount][5]  )
		
		nCount += 1
	EndDo
	
	OLE_ExecuteMacro(oWord,"tabitens")
	
	// Atualiza todos os campos.
	OLE_UpDateFields( oWord )

	// Fecha o documento.
	OLE_CloseLink( oWord, .F. )

	dbSelectArea("TFJ")
	dbSetOrder(2)
	dbSeek(xFilial()+cAdyProp)
	u_BRLR002()

Return

//Retorna caminho do DOT

Static Function FDadosAR()

	Local aRetorno	:= {}
	Aadd(aRetorno, cValToChar(Day(ADY->ADY_DATA))) 
	Aadd(aRetorno, FMExtens(Month(ADY->ADY_DATA))) 
	Aadd(aRetorno, cValToChar(Year(ADY->ADY_DATA)))	
	Aadd(aRetorno, A600EntNm(IIF(ADY->ADY_ENTIDA =="1","SA1","SUS"),ADY->ADY_CODIGO,ADY->ADY_LOJA)) //cServiços
	Aadd(aRetorno, 0)
	Aadd(aRetorno, SM0->M0_NOME)

Return aRetorno


Static Function FDadosTB()

	Local aRetorno	:= {}	
	Local nTotal := 0
	Local nTotalLA := 0
	Local cCodRec := space(08)
	Local aRet21 := {}
	Local cPer := "M"
	Local aPergs := {}
	
	aAdd( aPergs ,{2,"Imprimir","1", {"Mensal", "Diario"}, 50,'.T.',.T.})   
	If ParamBox(aPergs ,"Parametros ",aRet21)
		If aRet21[1] == "Diario"
			cPer := "D"
		EndIf
	EndIf
	
	dbSelectArea("TFJ")
	dbSetOrder(2)
	dbSeek(xFilial()+cAdyProp)
	Do While xFilial("ADY")+cAdyProp+ADY->ADY_PREVIS == xFilial("TFJ")+TFJ->TFJ_PROPOS+TFJ->TFJ_PREVIS .and. !eof() // Laco para orcamento de serviço
		
		//Do While
			dbSelectArea("TFL")
			dbSetOrder(2)
			dbSeek(xFilial()+TFJ->TFJ_CODIGO)
			Do While xFilial("TFJ")+TFJ->TFJ_CODIGO==xFilial("TFL")+TFL->TFL_CODPAI // Laco para local de atendimento
				dbSelectArea("TFF")
				dbSetOrder(3)
				dbSeek(xFilial()+TFL->TFL_CODIGO)
				Do While xFilial("TFL")+TFL->TFL_CODIGO==xFilial("TFF")+TFF->TFF_CODPAI // Laco para serviços
					dbSelectArea("TFG")
					dbSetOrder(3)
					dbSeek(xFilial()+TFF->TFF_COD)
					_nTOTMI := 0
					Do While TFG->TFG_FILIAL+TFG->TFG_CODPAI == xFilial("TFF")+TFF->TFF_COD
						_nTOTMI += TFG->TFG_QTDVEN* TFG->TFG_PRCVEN
						dbskip()
					EndDo

					dbSelectArea("TFH")
					dbSetOrder(3)
					dbSeek(xFilial()+TFF->TFF_COD)
					_nTOTMC := 0
					Do While TFH->TFH_FILIAL+TFH->TFH_CODPAI == xFilial("TFF")+TFF->TFF_COD
						_nTOTMC += TFH->TFH_QTDVEN* TFH->TFH_PRCVEN
						dbskip()
					EndDo

					
					dbSelectArea("TFF")
					ciPosto := POSICIONE('ABS',1, XFILIAL('ABS')+TFL->TFL_LOCAL,'ABS_DESCRI')     
					ciDescri := ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")) + " DO DIA  " + DTOC(TFF->TFF_PERINI) + " ATE DIA " + DTOC(TFF->TFF_PERFIM)
					ciQuant := TFF->TFF_QTDVEN
					ciValMes := ROUND(((TFF->TFF_PRCVEN+_nTOTMI+_nTOTMC)/ IF(ROUND((TFF->TFF_PERFIM-TFF->TFF_PERINI)/30,0)==0,1,ROUND((TFF->TFF_PERFIM-TFF->TFF_PERINI)/30,0))),2)
					If cPer == "D"
						ciValMes := TFF->TFF_PRCVEN
						ciTotMes := (ciQuant*ciValMes)+_nTOTMI+_nTOTMC
					Else //Mensal
						ciTotMes := ROUND((( (TFF->TFF_PRCVEN*TFF->TFF_QTDVEN) +_nTOTMI+_nTOTMC) / ;
						 					IF(ROUND((TFF->TFF_PERFIM-TFF->TFF_PERINI)/30,0)==0,1,;
						 					ROUND((TFF->TFF_PERFIM-TFF->TFF_PERINI)/30,0))),2) 
					EndIf
					nTotal += ciTotMes
					nTotalLA += ciTotMes
					dbSkip()					
					Aadd(aRetorno, {	ciPosto,;
										ciDescri,;
										TRANSFORM(ciQuant, "@E 999"),;
										"R$ " +TRANSFORM((ciTotMes/ciQuant), "@E 999,999,999.99"),;  //ciValMes
										"R$ " +TRANSFORM(ciTotMes, "@E 999,999,999.99")}) 
				EndDo
				
				Aadd(aRetorno, {"","","","Total Posto","R$ " +TRANSFORM(nTotalLA, "@E 999,999,999.99")}) 
				//Aadd(aRetorno, {"","","","",""})
				dbSelectArea("TFL")
				dbSkip()
				nTotalLA := 0	
			EndDo
	
	
		dbSelectArea("TFJ")
		dbSkip()
	EndDo

aRet[5] := nTotal
Return aRetorno


Static Function FNAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
Return cString

Static Function FMExtens(nMesP)
Local cRet:= ''
	
	If nMesP <> 3
		cRet:= MesExtenso(nMesP)
	Else
		cRet:= 'Março'
	Endif	
Return cRet