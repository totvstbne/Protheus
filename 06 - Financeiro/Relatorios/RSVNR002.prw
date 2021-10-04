#Include "Protheus.Ch"
#Include "FWCommand.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE 'FWMVCDEF.CH'

#define GPS_COD		1
#define GPS_LOJA	2
#define GPS_VALOR	4
#define GPS_ACHOU	5
#define GPS_CNPJ	6

Static lFWCodFil := .t.
Static cFilUnEmp := ""

/*/{Protheus.doc} RSVNR002
Impressão do GPS
@author Diogo
@since 19/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function RSVNR002()

Local cDesc1 	:= "Guia de I.N.S.S. (G.P.S.)"
Local cDesc2 	:= "Ser  impresso de acordo com os parametros solicitados pelo usuario."
Local cDesc3 	:= ""
Local cString	:= "SE1"
Local aOrd   	:= {}
Local aGps		:= {}
Local aGpsIna	:= {}
Local aGpsIns	:= {}
Local Titulo 	:= "EMISSÃO GUIA DE RECOLHIMENTO DA PREVIDENCIA SOCIAL"
Private cPerg  := "XINGPS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial  De                               ³
//³ mv_par02        //  Filial  Ate                              ³
//³ mv_par03        //  Centralizado ( S/N )                     ³
//³ mv_par04        //  Mes e Ano da Competencia                 ³
//³ mv_par05        //  Codigo de Pagamento.                     ³
//³ mv_par06        //  ATM / MULTA / JUROS                      ³
//³ mv_par07        //  Fornecedor de                            ³
//³ mv_par08        //  Fornecedor ate                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

fCriaPerg(cPerg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAreaSM0 := SM0->(GetArea())
If pergunte(cPerg,.T.)
	RestArea(aAreaSM0)
	RptStatus({|lEnd| u_fGpsCR() }, Titulo ) //"EMISSO GUIA DE RECOLHIMENTO DA PREVIDENCIA SOCIAL"
Endif

/*/{Protheus.doc} fGpsCR
Impressão do GPS
@author Diogo
@since 19/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fGpsCR
Local nX
Local dDataIni
Local dDataFim
Local lQuery
Local aStru
Local cAliasSe1
Local aInfo
Local dVencto
Local oPrint
Local nSavSm0 := SM0->(Recno())
Local cFilOld := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local bWhile
Local nInc		:= 0
Local aSM0
Local aFil
Local aRecnos := {}
Local lAdto		:= .F.
Local lNota		:= .F.
Local aEmpCont	:=	{} //Dados da empresa contratante caso seja guia emitida por uma cooperativa.
Local lFWCodFil	:= .T.
Local cFilAtual	:=	cFilAnt
Local nRegSM0 		:= SM0->(Recno())
Local aProc		:= {}
Local aAreaSM0
Local lGestao   := ( FWSizeFilial() > 2 )
Local cFilialAtu	:=	cFilAnt
Local cGRP	:=	FWGRPCompany()
Local aSelFil := {}
Local nC := 0
Local cRngFilSE1 := ""
Local cTmpSE1Fil := ""
Local aTmpFil := {}
Local cFilSE1 := ""

dDataIni := Ctod("01/"+Left(mv_par04,2)+"/"+Right(mv_par04,4))
dDataFim := LastDay(dDataIni)

If !( ChkFile("SE1",.F.,"NEWSE1") )
	Return(Nil)
EndIf


aSM0 := AdmAbreSM0()

#IFDEF TOP
	aAreaSM0 := SM0->(GetArea())
	If mv_par10 == 1 
		aSelFil := AdmGetFil(.F.,.T.,"SE1")
	Else
		aSelFil := { cFilAnt }	
	Endif
	RestArea(aAreaSM0)
#ENDIF

If Empty(aSelFil)
	aSelFil := {cFilAnt}
	cFilSE1 := " SE1.E1_FILIAL = '"+ FWxFilial("SE1", cFilAnt) + "' AND "
Else
	aSort(aSelFil)
	cRngFilSE1 := GetRngFil( aSelFil, "SE1", .T., @cTmpSE1Fil )
	aAdd(aTmpFil, cTmpSE1Fil)
	cFilSE1 := " SE1.E1_FILIAL "+ cRngFilSE1 + " AND "
Endif

#IFNDEF TOP
	cFilAtual := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
#ELSE
mv_par01 := Alltrim(aSM0[1][SM0_CODFIL])
mv_par02 := Alltrim(aSM0[Len(aSM0)][SM0_CODFIL])
cFilAtual := cFilAnt
#ENDIF

aEmpCont	:={}

#IFNDEF TOP
SM0->(MsSeek(cEmpAnt))
While !Eof() .and. SM0->M0_CODIGO == cEmpAnt
	If	Alltrim(SM0->M0_CODFIL) == Alltrim(cFilAtual)
		Aadd(aEmpCont,{SM0->M0_CGC,; //CGC
							PadR(SM0->M0_NOMECOM,40),; //RAZAO
							PadR(SM0->M0_ENDCOB,30),; //ENDERECO COBRANCA
							PadR(SM0->M0_BAIRCOB,20),; //BAIRRO COBRANCA
							PadR(SM0->M0_CIDCOB,20),; //CIDADE COBRANCA
							PadR(SM0->M0_ESTCOB,2),; //ESTADO COBRANCA
							PadR(SM0->M0_CEPCOB,2),; //CEP COBRANCA
							PadR(ALLTRIM(SM0->M0_TEL),14)}) //TELEFONE COBRANCA
		Exit
	Endif
	SM0->(Dbskip())
Enddo
SM0->(DbGoto(nRegSM0))
#ELSE
For nInc := 1 To Len( aSM0 )
	If	AllTrim(aSM0[nInc][SM0_CODFIL]) == cFilAtual
		aAreaSM0 := SM0->(GetArea())
		SM0->(dBGoTo(aSM0[nInc][SM0_RECNO]))
		Aadd(aEmpCont,{SM0->M0_CGC,; //CGC
							PadR(SM0->M0_NOMECOM,40),; //RAZAO
							PadR(SM0->M0_ENDCOB,30),; //ENDERECO COBRANCA
							PadR(SM0->M0_BAIRCOB,20),; //BAIRRO COBRANCA
							PadR(SM0->M0_CIDCOB,20),; //CIDADE COBRANCA
							PadR(SM0->M0_ESTCOB,2),; //ESTADO COBRANCA
							PadR(SM0->M0_CEPCOB,2),; //CEP COBRANCA
							PadR(ALLTRIM(SM0->M0_TEL),14)}) //TELEFONE COBRANCA
		RestArea(aAreaSM0)
		Exit
	Endif
Next
#ENDIF

For nInc := Len(aSM0) To 1 Step -1
	If aScan(aSelFil,Alltrim(aSM0[nInc][SM0_CODFIL])) == 0 .Or. Alltrim(aSM0[nInc][SM0_GRPEMP]) != cGRP;
		.Or. Alltrim(aSM0[nInc][SM0_CODFIL]) == "99"
		aDel(aSM0,nInc)
		nC++
	EndIf
Next

aSize(aSM0,Len(aSM0) - nC)
aSort(aSM0,,,{|x,y| x[2] < y[2]})

#IFNDEF TOP
For nInc := 1 To Len( aSM0 )
	If Alltrim(aSM0[nInc][1]) == cEmpAnt .AND. Alltrim(aSM0[nInc][SM0_CODFIL]) >= mv_par01 .AND. Alltrim(aSM0[nInc][SM0_CODFIL]) <= mv_par02
		cFilAnt := Alltrim(aSM0[nInc][SM0_CODFIL])
#ENDIF

		#IFDEF TOP

			lQuery := .T.
			aStru  := SE1->(dbStruct())
			If !Empty(cAliasSE1)
				DbSelectArea(cAliasSE1)
				DbCloseArea()
			EndIf
			cAliasSE1 := GetNextAlias()

			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
			cQuery += "WHERE " + cFilSE1 // SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
			If mv_par09 == 2
				cQuery += "SE1.E1_EMIS1>='"+DTOS(dDataIni)+"' AND "
				cQuery += "SE1.E1_EMIS1<='"+DTOS(dDataFim)+"' AND "
			Else
				cQuery += "SE1.E1_EMISSAO>='"+DTOS(dDataIni)+"' AND "
				cQuery += "SE1.E1_EMISSAO<='"+DTOS(dDataFim)+"' AND "
			EndIf
			cQuery += "SE1.E1_CLIENTE>='"+MV_PAR07+"' AND "
			cQuery += "SE1.E1_CLIENTE<='"+MV_PAR08+"' AND "
			cQuery += "SE1.E1_NUM>='"+MV_PAR11+"' AND "
			cQuery += "SE1.E1_NUM<='"+MV_PAR12+"' AND "
			cQuery += "(SE1.E1_INSS > 0 OR "
			cQuery += "(SE1.E1_INSS = 0 AND SE1.E1_TIPO IN " + FormatIn(MVINSS+'INA',,3) + ")) AND "

			cQuery += "SE1.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SE1->(IndexKey()))

			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1)
			For nX := 1 To Len(aStru)
				If aStru[nX][2]<>"C"
					TcSetField(cAliasSE1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
		#ELSE
			If mv_par09 == 2
				SE1->(DbSetOrder(7))
				SE1->(MsSeek(xFilial("SE1")+DTOS(dDataIni),.T.))
			Else
				SE1->(DbSetOrder(5))
				SE1->(MsSeek(xFilial("SE1")+DTOS(dDataIni),.T.))
			EndIf
			cAliasSe1 := "SE1"
		#ENDIF

		If mv_par09 == 2
			SE1->(DbSetOrder(7))
			bWhile := {|| ((cAliasSE1)->(!Eof()) .And. (cAliasSE1)->(E1_FILIAL)==xFilial("SE1") .And. (cAliasSE1)->(E1_EMIS1) <= dDataFim ) }
		Else
			SE1->(DbSetOrder(5))
			bWhile := {|| ((cAliasSE1)->(!Eof()) .And. (cAliasSE1)->(E1_FILIAL)==xFilial("SE1") .And. (cAliasSE1)->(E1_EMISSAO) <= dDataFim ) }
		EndIf

		aRecnos := {}
		aInfo	:= {}
		aFil	:= {}
		#IFDEF TOP
			cFilAnt := (cAliasSE1)->(E1_FILORIG)
		#ENDIF
		// Se possuir filial centralizadora, posiciona nesta filial
		If !Empty(mv_par03)
			aFil := FWArrFilAtu(cEmpAnt, mv_par03 )
		Else
		    aFil := FWArrFilAtu(cEmpAnt, cFilAnt )
		Endif

		IF !Empty( aFil ) .AND. fInfo( @aInfo, aFil[2] )
			aGpsIns		:= {}
			aGpsIna		:= {}	
			While Eval(bWhile)
				
				lAchouPai	 := .T.
				
				If aScan(aRecnos,{|x| x == (cAliasSE1)->(R_E_C_N_O_) } ) > 0
					(cAliasSE1)->(DbSkip())
				#IFDEF TOP
					cFilAnt := (cAliasSE1)->(E1_FILIAL)
				#ENDIF
					Loop				
				Else
					aAdd(aRecnos, (cAliasSE1)->(R_E_C_N_O_) )
				Endif
				// Se nao for titulo de INSS
				If (cAliasSE1)->E1_TIPO $ MVINSS+"/"+"INA"
					// Se achou o titulo pai, significa que o INSS ja foi impresso ou ainda vai ser
					If FrGpsPai(cAliasSe1)
						(cAliasSE1)->(DbSkip())
						#IFDEF TOP
							cFilAnt := (cAliasSE1)->(E1_FILIAL)
						#ENDIF
						Loop
					Endif
					lAchouPai := .F.
				Else
					If (cAliasSE1)->E1_INSS	 = 0
						(cAliasSE1)->(DbSkip())
						#IFDEF TOP
							cFilAnt := (cAliasSE1)->(E1_FILIAL)
						#ENDIF
						Loop
					Endif
				Endif	
				
				dbSelectArea("SA1")
				cFilUnEmp := xFilial("SA1")
				MsSeek(xFilial("SA1")+(cAliasSe1)->(E1_CLIENTE+E1_LOJA))

				If .F.
				Else
					If (cAliasSe1)->E1_TIPO $ MVINSS+"/"+"INA" .Or.;
						((cAliasSe1)->E1_CLIENTE >= mv_par07 .And. (cAliasSe1)->E1_CLIENTE <= mv_par08)
						// Nao achou o fornecedor, adiciona novo item no array
						If !((cAliasSe1)->E1_TIPO $ MVPAGANT+"/INA")
							nX := Ascan( aGpsIns, { |e| e[1]+e[6] == SA1->A1_COD + SA1->A1_CGC } )
							If nX == 0
								aadd(aGpsIns,{	SA1->A1_COD,;
												SA1->A1_LOJA,;
												SA1->A1_NOME,;
												xMoeda(If( ! (cAliasSe1)->E1_TIPO $ MVINSS+"/"+"INA", (cAliasSe1)->E1_INSS, (cAliasSe1)->E1_VALOR),(cAliasSe1)->E1_MOEDA,1),;
												lAchouPai,;
												SA1->A1_CGC,;
												(cAliasSe1)->E1_NUM,;
												(cAliasSe1)->E1_NFELETR;
												})

							Else
								// Senao soma o valor do INSS do fornecedor
								aGpsIns[nX][GPS_VALOR] += xMoeda(If( ! (cAliasSe1)->E1_TIPO $ MVINSS+"/"+"INA", (cAliasSe1)->E1_INSS, (cAliasSe1)->E1_VALOR),(cAliasSe1)->E1_MOEDA,1)
							EndIf
						Else
							nX := Ascan( aGpsIna, { |e| e[1]+e[6] == SA1->A1_COD + SA1->A1_CGC } )
							If nX == 0
								aadd(aGpsIna,{	SA1->A1_COD,;
												SA1->A1_LOJA,;
												SA1->A1_NOME,;
												xMoeda(If( ! (cAliasSe1)->E1_TIPO $ MVINSS+"/"+"INA", (cAliasSe1)->E1_INSS, (cAliasSe1)->E1_VALOR),(cAliasSe1)->E1_MOEDA,1),;
												lAchouPai,;
												SA1->A1_CGC,;
												(cAliasSe1)->E1_NUM,;
												(cAliasSe1)->E1_NFELETR;
												})
							Else
								// Senao soma o valor do INSS do fornecedor
								aGpsIna[nX][GPS_VALOR] += xMoeda(If( ! (cAliasSe1)->E1_TIPO $ MVINSS+"/"+"INA", (cAliasSe1)->E1_INSS, (cAliasSe1)->E1_VALOR),(cAliasSe1)->E1_MOEDA,1)
							EndIf
						EndIf								
					Endif	
					
				EndIF	
				(cAliasSe1)->(DbSkip())
				#IFDEF TOP
					cFilAnt := (cAliasSe1)->(E1_FILIAL)
				#ENDIF
				
			End

			aGps		:= {}
			
			If Len(aGpsIna) > 0 .And. Len(aGpsIns) > 0
				MsgInfo("Os calculos foram efetuados considerando titulos INSS Adto e Normal para emissão da GPS","Atenção")
				For nX := 1 To Len(aGpsIns)
					nY := Ascan( aGpsIna, { |e| e[1]+e[6] == aGpsIns[nx][1] + aGpsIns[nx][6] } )
					If ny == 0
						aAdd(aGps,aGpsIns[nx])   //Carrega Agps pelo INS
					Else
						If aGpsIns[nx][GPS_VALOR] >= aGpsIna[ny][GPS_VALOR]
							aAdd(aGps,aGpsIns[nx])   //Carrega Agps pelo INS
						Else
							aAdd(aGps,aGpsIna[ny])   //Carrega Agps pelo INA
						EndIf
					EndIf
				Next
			ElseIf Len(aGpsIns) > 0
				aGps := aClone(aGpsIns) //			Carrefa Agps pelo INS
			ElseIf Len(aGpsIna) > 0
				aGps := aClone(aGpsIna) //			Carrega Agps pelo INA
			EndIf

			If ValType(oPrint) != "O"
//				oPrint 	:= TMSPrinter():New("GPS - Guia da Previdência Social")
//				oPrint:Setup()
//				oPrint:SetPortrait()
//				cNomArq		:= alltrim(SE1->E1_NUM)+alltrim(upper(SE1->E1_NOMCLI))+"_GPS"
//				cPath		:= 'C:\GPS\'
//				makedir(cPath)
//				oPrint	:= FWMSPrinter():New( cNomArq, IMP_PDF , .T., cPath, .T., , , , , , .F., )
//				oPrint:cPathPDF:= cPath
//				oPrint:cPathPrint:= cPath
//				oPrint:lInJob	:= .T.
//				oPrint:lServer	:= .T.
//				oPrint:lViewPDF	:= .F. 
//				
//				oPrint:nDevice := IMP_PDF
//				oPrint:SetResolution(82)
//				oPrint:SetPortrait()
//				oPrint:SetPaperSize(DMPAPER_A4)
//				oPrint:SetMargin(12,12,12,12)
//				oPrint:Setup()
			Endif

			For nX := 1 To Len(aGps)
				cNomArq		:= alltrim(aGps[nX][3])+"GPS"
				cPath		:= 'C:\GPS\'
				makedir(cPath)
				oPrint	:= FWMSPrinter():New( cNomArq, IMP_PDF , .T., '\SPOOL\', .T., , , , , , .F., )
				oPrint:cPathPDF:= cPath
				oPrint:cPathPrint:= cPath
				oPrint:lInJob	:=  .T.
				oPrint:lServer	:= .F.
				oPrint:lViewPDF	:= .F.
				
				oPrint:nDevice := IMP_PDF
				oPrint:SetResolution(82)
				oPrint:SetPortrait()
				oPrint:SetPaperSize(DMPAPER_A4)
				oPrint:SetMargin(12,12,12,12)
				oPrint:Setup()
			
				u_fPrtGps(aGps[nX],oPrint,aInfo,aEmpCont)
				oPrint:Preview()
			Next

		Endif
#IFNDEF TOP
	EndIf
#ENDIF
#IFNDEF TOP
Next
#ELSE
  	For nX := 1 TO Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
    Next
#ENDIF

If len(aGps) > 0
	msgInfo('Arquivo(s) exportado(s) para o diretório C:\GPS\')
Endif

NEWSE1->(DbCloseArea())
#IFNDEF TOP
cFilAnt := cFilOld
#ELSE
cFilAnt := cFilialAtu
#ENDIF

Return

User Function  fPrtGps(aGps,oPrint,aInfo,aEmpCont)

Local cBmp 		 := ""
Local cStartPath := GetSrvProfString("StartPath","")
Local nX         := 030
Local nY         := 0
Local oFont07    := TFont():New("Arial",07,10,,.F.,,,,.T.,.F.)
Local oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Local oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont11    := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Local oFont15    := TFont():New("Arial",15,15,,.F.,,,,.T.,.F.)
Local cCgc       := ""
Local cRazao     := ""
Local cEndereco  := ""
Local cFone		  := ""
Local cCep       := ""
Local cMunicipio := ""
Local cUf        := ""
Local cCodBarSdv
Local cCodBarCDv
Local cCampo1
Local cCampo2
Local cCampo3
Local cCampo4
Local dEmissao := DataValida(Ctod("01/"+Left(mv_par04,2)+"/"+Right(mv_par04,4)),.T.)
Local cTipo		:= ""
Local aRetGPS := {}
// Se nao encontrou o titulo pai, imprime os dados de recolhimento em nome da empresa

If ! aGps[GPS_ACHOU]
	cCgc      	:= aInfo[8]                      // CGC
	cRazao    	:= PadR(aInfo[3],40) // Razao Social
	cFone     	:= PadR(aInfo[10],14)
	cEndereco 	:= PadR(aInfo[4],30)
	cBairro   	:= PadR(aInfo[13],20)
	cCep      	:= PadR(aInfo[7],8)
	cMunicipio	:= alltrim(PadR(aInfo[5],20))
	cUf       	:= PadR(aInfo[6],2)
	cCGC 		:= PadR(If (aInfo[15] == 1 ,aInfo[8],Transform(cCgc,"@R ##.###.###/####-##")),18) // CGC
	cTipo		:= "J"
Else
	// Senao imprime os dados de recolhimento em nome do fornecedor
	If !SA1->(MsSeek(xFilial("SA1")+aGps[GPS_COD]+aGps[GPS_LOJA]))
		SA1->(MsSeek(cFilUnEmp+aGps[GPS_COD]+aGps[GPS_LOJA]))
	EndIf

	cCgc      	:= SA1->A1_CGC            // CGC
	cRazao    	:= PadR(SA1->A1_NOME,40) // Razao Social
	cFone     	:= PadR(ALLTRIM(SA1->A1_TEL),14)
	cEndereco 	:= alltrim(PadR(SA1->(ALLTRIM(A1_END)),30))
	cBairro   	:= PadR(SA1->A1_BAIRRO,20)
	cCep      	:= PadR(SA1->A1_CEP,8)
	cMunicipio	:= alltrim(PadR(SA1->A1_MUN,20))
	cUf       	:= alltrim(PadR(SA1->A1_EST,2))

	cCGC 		:= PadR(If (SA1->A1_TIPO!="J",aInfo[8],Transform(cCgc,"@R ##.###.###/####-##")),18) // CGC
	cTipo		:= IIf(!Empty(SA1->A1_TIPO),SA1->A1_TIPO,"J")

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBmp := cStartPath + "GPS.BMP" //Logo da Receita Federal
oPrint:StartPage()
nX := 030
cCodBarSDv := "858" + StrZero((aGps[GPS_VALOR]+mv_par06)*100,11)+"0270"+MV_PAR05+StrTran(StrTran(StrTran(cCgc,".",""),"/",""),"-","")+Right(mv_par04,4)+Left(mv_par04,2) + "7"
cCodBarCDv := Left(cCodBarSDv, 3) + Modulo11( cCodBarSDv,2,9 ) + SubStr(cCodBarSDv,4)

cCampo1 := Left(cCodBarCDv,11)
cCampo1 := cCampo1 + "-" +  Modulo11(cCampo1,2,9)

cCampo2 := SubStr(cCodBarCdv,12,11)
cCampo2 := cCampo2 + "-" +  Modulo11(cCampo2,2,9)

cCampo3 := SubStr(cCodBarCdv,23,11)
cCampo3 := cCampo3 + "-" + Modulo11(cCampo3,2,9)

cCampo4 := SubStr(cCodBarCdv,34,11)
cCampo4 := cCampo4 + "-" +  Modulo11(cCampo4,2,9)

For nY := 1 To 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Box grafico                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Box(nX,0030,nX+1100,2350)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao do logotipo do Ministerio da Fazenda                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File(cBmp)
		oPrint:SayBitmap(nX+10,040,cBmp,200,180)
	EndIf
	oPrint:Say(nX+020+20,270,"MINISTÉRIO DA PREVIDÊNCIA SOCIAL - MPS",oFont07)
	oPrint:Say(nX+070+20,270,"SECRETARIA DA RECEITA PREVIDENCIÁRIA - SRP",oFont07)
	oPrint:Say(nX+120+20,270,"INSTITUTO NACIONAL DO SEGURO SOCIAL - INSS",oFont07)
	oPrint:Say(nX+170+20,270,"GUIA DA PREVIDÊNCIA SOCIAL - GPS",oFont15)

	oPrint:Line(nX,1300,nX+1100,1300)
	oPrint:Line(nX,1800,nX+810,1800)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 01                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+270,030,nX+270,1300)
	oPrint:Say(nX+280+20,040,"1 - ",oFont10)
	oPrint:Say(nX+280+20,110,"NOME OU RAZÃO SOCIAL / ENDEREÇO / TELEFONE",oFont10)
	
	oPrint:Say(nX+310+20,110, FWFilName(cEmpAnt,sm0->m0_codfil),oFont10n)
	nX+= 10
	oPrint:Say(nX+345+20,110,"TOMADOR: "+cRazao,oFont10)
	oPrint:Say(nX+380+20,110,alltrim(cEndereco) + " - " + alltrim(cBairro),oFont10)
	oPrint:Say(nX+415+20,110,alltrim(cCep) + " - " + alltrim(cMunicipio) + " - " + alltrim(cUf),oFont10)
	nX-= 10
	
	oPrint:Say(nX+495+20,040,"2 - VENCIMENTO",oFont10)
	oPrint:Say(nX+530+20,040,"(Uso exclusivo do INSS)",oFont10)

	
	
	//Calculo do Vencto do INSS
	//dVencto := F050VIMP("INSS",dEmissao,dEmissao,dEmissao,,cTipo)

	dVencto:= stod(substr(dtos(dEmissao),1,6)+"20")+30 //utiliza o mês subsequente
	dVencto:= stod(substr(dTos(dVencto),1,6)+"20")



	oPrint:Say(nX+530+20,550,Transform(dVencto,""),oFont10)
	oPrint:Line(nX+490,450,nX+650,450)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 03                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+490,030,nX+490,1300)
	oPrint:Line(nX+650,030,nX+650,1300)
	oPrint:Say(nX+020+20,1305,"3 - CÓDIGO DE PAGAMENTO",oFont09)
	oPrint:Say(nX+030+20,2200,MV_PAR05,oFont10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 04                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+090,1300,nX+90,2350)
	oPrint:Say(nX+120+20,1305,"4 - COMPETÊNCIA",oFont09)
	oPrint:Say(nX+130+20,2170,Subs(mv_par04,1,2)+"/"+Subs(mv_par04,3,4),oFont10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 05                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+180,1300,nX+180,2350)
	oPrint:Say(nX+200+20,1305,"5 - IDENTIFICADOR",oFont09)
	oPrint:Say(nX+210+20,2075,cCgc,oFont10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 06                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+270,1300,nX+270,2350)
	oPrint:Say(nX+290+20,1305,"6 - VALOR DO INSS",oFont09)
	oPrint:Say(nX+300+20,2100,Transform(aGps[GPS_VALOR],"@E 9,999,999,999.99"),oFont10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 07                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+360,1300,nX+360,2350)
	oPrint:Say(nX+380+20,1305,"7 -",oFont09)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 08                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+450,1300,nX+450,2350)
	oPrint:Say(nX+470+20,1305,"8 - ",oFont09)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 09                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+ 540,1300,nX+540,2350)
	oPrint:Say(nX+552+20,1303,"9 - VALOR DE OUTRAS",oFont09)
	oPrint:Say(nX+582+20,1350,"ENTIDADES",oFont09)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 10                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+630,1300,nX+630,2350)
	oPrint:Say(nX+650+20,1305,"10 - ATM/MULTA E JUROS",oFont09)
	oPrint:Say(nX+670+20,2100,Transform(mv_par06,"@E 9,999,999,999.99"),oFont10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 11                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+720,1300,nX+720,2350)
	oPrint:Say(nX+740+20,1305,"11 - VALOR TOTAL",oFont10)
	oPrint:Say(nX+750+20,2100,Transform(aGps[GPS_VALOR]+mv_par06,"@E 9,999,999,999.99"),oFont10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro 12                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Line(nX+810,1300,nX+810,2350)
	oPrint:Say(nX+830+20,1305,"12",oFont10)
	oPrint:Say(nX+830+20,1370,"AUTENTICAÇÃO BANCÁRIA (SOMENTE NAS 1 E 2 VIAS)",oFont10n)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao do Quadro de aviso                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Say(nX+0680,600,"ATENÇÃO",oFont10n)
	oPrint:Say(nX+0740,040,"É vedada a utilização de GPS para recolhimento de receita de valor inferior",oFont07)
	oPrint:Say(nX+0780,040,"ao estipulado em Resolução publicada pelo INSS. A receita que resultar valor",oFont07)
	oPrint:Say(nX+0820,040,"inferior, deverá ser adicionada a contribuição ou importância correspondente",oFont07)
	oPrint:Say(nX+0860,040,"nos  meses subsequentes,  até que o total  seja  igual ou  superior ao valor",oFont07)
	oPrint:Say(nX+0900,040,"mínimo fixado",oFont07)

	//oPrint:Line(nX+980,1300,nX+980,2350)
	oPrint:Line(nX+980,030,nX+980,1300)
	oPrint:Say(nX+1020,040,"REF. AO RPS "+alltrim(aGps[7])+" / NF "+alltrim(aGps[8]),oFont10n)

	///oPrint:Say(nX+1110,290,cCampo1 + " " + cCampo2 + " " + cCampo3 + " " + cCampo4,oFont10n)
	///MSBAR("INT25",If(nY==1,10.7,23.8),1,AllTrim(StrTran(SubStr(cCampo1,1,len(cCampo1)-1)+SubStr(cCampo2,1,len(cCampo2)-1)+SubStr(cCampo3,1,len(cCampo3)-1)+SubStr(cCampo4,1,len(cCampo4)-1),"-","")),oPrint,.F.,Nil,Nil,0.025,1.5,Nil,Nil,"A",.F.)

	If nY == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definicao do picote                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Say(nX+1410,000,Replicate("-",132),oFont11)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Segunda via do Darf                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nX := 1580
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a pagina                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:EndPage()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ FrGpsPai ³ Autor ³ Claudio Donizete      ³ Data ³08.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posiciona no titulo pai do titulo de INSS                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet - .T. Encontrou titulo pai, .F. caso contrario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasSe1 - Alias do contas a pagar                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FrGpsPai(cAliasSe1)
LOCAL nRegSE1:= NEWSE1->(Recno())
LOCAL lAchou:= .F.
LOCAL cPrefixo := (cAliasSe1)->E1_PREFIXO
LOCAL cNum		:= (cAliasSe1)->E1_NUM
LOCAL cParcela := (cAliasSe1)->E1_PARCELA
LOCAL cTipoPai	:= (cAliasSe1)->E1_TIPO
LOCAL cParcPai
LOCAL cValorcPai
Local aArea := GetArea()
Local lPai := .F.

If (cAliasSe1)->E1_TIPO $ MVINSS+"/"+"INA"
	cValorPai := "NEWSE1->E1_INSS"
	cParcPai := "E1_PARCELA"
Else
	lPai := .T.
Endif

// Se nao estiver no titulo pai, procura o titulo Pai.
If !lPai
	dbSelectArea("NEWSE1")
	dbSetOrder(1)
	nRegSE1:= Recno()
	If MsSeek(xFilial("SE1")+cPrefixo+cNum)
		While !Eof() .and. NEWSE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+cPrefixo+cNum
			If &(cParcPai) == cParcela
				If &(cValorPai) != 0
					lAchou := .T.
					Exit
				EndIf
			EndIf
			DbSkip()
		Enddo
	EndIf
Endif

dbSelectArea("NEWSE1")
// Se nao encontrou o registro pai, restaura o ponteiro do alias alternativo
// Pois o registro pode ja estar posicionado no titulo principal.
If !lAchou .And. !lPai
	dbGoto(nRegSE1)
Elseif !lAchou
	NEWSE1->(MsSeek(xFilial("SE1")+(cAliasSe1)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
Endif

Return lAchou

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0

Static Function fCriaPerg(cPerg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial  De                               ³
//³ mv_par02        //  Filial  Ate                              ³
//³ mv_par03        //  Centralizado ( S/N )                     ³
//³ mv_par04        //  Mes e Ano da Competencia                 ³
//³ mv_par05        //  Codigo de Pagamento.                     ³
//³ mv_par06        //  ATM / MULTA / JUROS                      ³
//³ mv_par07        //  Fornecedor de                            ³
//³ mv_par08        //  Fornecedor ate                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	u_PutSx1( cPerg, "01", "Filial de?","Filial de?","Filial de?","mv_ch1","C",6,0,0,"G","","XM0","","",;
		"mv_par01","","","","","","","",;
		"","","","","","","","","",{},{},{})

	u_PutSx1( cPerg, "02", "Filial ate?","Filial ate?","Filial ate?","mv_ch2","C",6,0,0,"G","","XM0","","",;
		"mv_par02","","","","","","","",;
		"","","","","","","","","",{},{},{})
	
	u_PutSx1( cPerg, "03", "Filial centralizadora ?","Filial centralizadora ?","Filial centralizadora ?","mv_ch3","C",6,0,0,"G","","XM0","","",;
		"mv_par03","","","","","","","",;
		"","","","","","","","","",{},{},{})
		
	u_PutSx1( cPerg, "04", "Mês/Ano de competência ?","Mês/Ano de competência ?","Mês/Ano de competência ?","mv_ch4","C",6,0,0,"G","","","","",;
		"mv_par04","","","","","","","",;
		"","","","","","","","","",{},{},{})
		
	u_PutSx1( cPerg, "05", "Código de pagamento ?","Código de pagamento ?","Código de pagamento ?","mv_ch5","C",4,0,0,"G","","","","",;
		"mv_par05","","","","","","","",;
		"","","","","","","","","",{},{},{})

	u_PutSx1( cPerg, "06", "ATM / Multa / Juros ?","ATM / Multa / Juros ?","ATM / Multa / Juros ?","mv_ch6","N",12,2,0,"G","","","","",;
		"mv_par06","","","","","","","",;
		"","","","","","","","","",{},{},{})

	u_PutSx1( cPerg, "07", "Cliente de ?","Cliente de ?","Cliente de ?","mv_ch7","C",6,0,0,"G","","SA1","","",;
		"mv_par07","","","","","","","",;
		"","","","","","","","","",{},{},{}) 

	u_PutSx1( cPerg, "08", "Cliente até?","Cliente até?","Cliente até?","mv_ch8","C",6,0,0,"G","","SA1","","",;
		"mv_par08","","","","","","","",;
		"","","","","","","","","",{},{},{})

	u_PutSx1( cPerg, "09", "Considera Data ?","Considera Data ?","Considera Data ?","mv_ch9","N",1,0,0,"C","","","","",;
		"mv_par09","Emissão","","","","Data Base","","",;
		"","","","","","","","","",{},{},{})
			
	u_PutSx1( cPerg, "10", "Seleciona Filiais ?","Seleciona Filiais ?","Seleciona Filiais ?","mv_chA","N",1,0,0,"C","","","","",;
		"mv_par10","Sim","","","","Não","","",;
		"","","","","","","","","",{},{},{})

	u_PutSx1( cPerg, "11", "Título de ?","Título de ?","Título de ?","mv_chB","C",9,0,0,"G","","","","",;
		"mv_par11","","","","","","","",;
		"","","","","","","","","",{},{},{}) 

	u_PutSx1( cPerg, "12", "Título ate ?","Título ate ?","Título ate ?","mv_chC","C",9,0,0,"G","","","","",;
		"mv_par12","","","","","","","",;
		"","","","","","","","","",{},{},{}) 

Return