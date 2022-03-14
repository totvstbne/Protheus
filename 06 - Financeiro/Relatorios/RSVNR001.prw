#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"

#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

Static lFWCodFil := .T.
Static cFornLoja := ""
Static _oQry := Nil

/*/{Protheus.doc} RSVNR001
ImpressЦo do DARF
@author Diogo
@since 13/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function RSVNR001(cAlias,nReg,nOpc)
Local cPerg   := "FINSRF"  // Pergunta do Relatorio
Local aParamBox := {}  
Local cTitulo := "EmissЦo DARF"
Local bOk := {|| .T.}
Local aButtons := {}
Local lCentered := .T.
Local nPosx
Local nPosy
Local cLoad := "RSVNR01A"
Local lCanSave := .T.
Local lUserSave := .T.
Local dData	 := dDataBase  
Local nTamFilial:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local aOpcao    := {"1=EmissЦo","2=Vencimento"}

Static aPergRet := {}            
Default cAlias := "FI9"
Default nReg	:= 0
Default nOpc	:= 2 

AADD(aParamBox,{1, "Filial de"			,space(getSx3Cache("E1_FILIAL","X3_TAMANHO")) ,"@!"   ,""   ,"","",60 ,.F.})
AADD(aParamBox,{1, "Filial ate"			,space(getSx3Cache("E1_FILIAL","X3_TAMANHO")) ,"@!"   ,""   ,"","",60 ,.T.})
AADD(aParamBox,{1, "Cliente de"			,space(getSx3Cache("A1_COD","X3_TAMANHO"))	  ,"@!"   ,""   ,GetSx3Cache('C5_CLIENTE','X3_F3'),"",60 ,.F.})     
AADD(aParamBox,{1, "Cliente ate"		,space(getSx3Cache("A1_COD","X3_TAMANHO"))	  ,"@!"   ,""   ,GetSx3Cache('C5_CLIENTE','X3_F3'),"",60 ,.T.})
AADD(aParamBox,{1, "Loja de"			,space(getSx3Cache("A1_LOJA","X3_TAMANHO"))	  ,"@!"   ,""   ,""   ,""   ,60 ,.F.})
AADD(aParamBox,{1, "Loja atИ"			,space(getSx3Cache("A1_LOJA","X3_TAMANHO"))	  ,"@!"   ,""   ,""   ,""   ,60 ,.T.})     
AADD(aParamBox,{1, "Vencimento Inicial"	,dData		,"" 	 		 			      ,""   ,""   ,""   ,60 ,.T.}) //Vencimento Inicial ?     
AADD(aParamBox,{1, "Vencimento Final"	,dData		,"" 	 			 			  ,""   ,""	  ,""   ,60 ,.T.}) //Vencimento Final ?      			   
AADD(aParamBox,{1, "PerМodo de ApuraГЦo",dData		,"" 	 		 			      ,""   ,""   ,""   ,60 ,.T.}) //PerМodo de ApuraГЦo      			   
AADD(aParamBox,{1, "Documento de"		,space(getSx3Cache("E1_NUM","X3_TAMANHO")) ,"@!"   ,""   ,"","",60 ,.F.})
AADD(aParamBox,{1, "Documento atИ"		,space(getSx3Cache("E1_NUM","X3_TAMANHO")) ,"@!"   ,""   ,"","",60 ,.T.})
AADD(aParamBox,{2, "Data Considerar"	,"1",aOpcao ,65,"!Empty",.T.})

lRet := ParamBox(aParamBox, cTitulo, aPergRet, bOk, aButtons, lCentered, nPosx,nPosy, /*oMainDlg*/ , cLoad, lCanSave, lUserSave)

If lRet
	RptStatus({|lEnd| ImpDet(lEnd,cAlias,nReg,nOpc)},"Processando - DARF")
EndIf
Return(.T.)


Static Function ImpDet(lEnd,cAlias,nReg,nOpc)

Local aDarf     := {}
Local aInfo     := {}
Local lQuery    := .F.
Local cAliasSE1 := "SE1"
Local nX        := 0
Local nValorImp := 0
Local cAliasAux
Local nRegSE1
Local lExist	:= .F.
Local aStru     := {}
Local cNFs		:= ""
Local cQuery    := ""
Local cSepTxa		:= If("|"$MVTXA,"|",",")
Local cSepTx		:= If("|"$MVTAXA,"|",",")
Local aSelFil := {}
Local nC := 0
Local cFilialAtu := cFilAnt
Local cChaveOld := ""
Local cChave := ""
Local lOrigem := .F.
Local lTaxa := .F.
Local nY := 0
Local cTipod:= substr(cvaltochar(aPergRet[12]),1,1)

aSelFil := {cFilAnt}

aDarf     := {}
aInfo     := {}
nX        := 0
nValorImp := 0
SM0->(MsSeek(cEmpAnt+cFilAnt))

cQuery :="SELECT E1_FILIAL ,E1_NUM,E1_PARCELA,E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_NOMCLI " 
cQuery +="FROM "+RetSqlName("SE1")+ " SE1 "
cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
cQuery +="E1_FILIAL BETWEEN '"+aPergRet[1]+"' AND '"+aPergRet[2]+"' AND "
cQuery +="E1_CLIENTE BETWEEN '"+aPergRet[3]+"' AND '"+aPergRet[4]+"' AND "
cQuery +="E1_LOJA BETWEEN '"+aPergRet[5]+"' AND '"+aPergRet[6]+"' AND "
cQuery +="E1_VENCREA BETWEEN '"+dtos(aPergRet[7])+"' AND '"+dtos(aPergRet[8])+"' AND "
cQuery +="E1_NUM BETWEEN '"+aPergRet[10]+"' AND '"+aPergRet[11]+"' AND "
cQuery +="E1_TIPO IN ('CF-','PI-','CS-','IR-') "
cQuery +="GROUP BY E1_FILIAL, E1_NUM,E1_PARCELA,E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_NOMCLI "
TcQuery cQuery new Alias QTITULOS

while QTITULOS->(!Eof())

//PIS/COFINS/CSLL
aInfo:= {}
cQuery :="SELECT SUM(E1_VALOR) E1_VALOR,E1_FILIAL, E1_CLIENTE, E1_LOJA, MAX(E1_VENCREA) E1_VENCREA, MAX(E1_EMISSAO) E1_EMISSAO " 
cQuery +="FROM "+RetSqlName("SE1")+ " SE1 "
cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
cQuery +="E1_FILIAL BETWEEN '"+aPergRet[1]+"' AND '"+aPergRet[2]+"' AND "
cQuery +="E1_CLIENTE BETWEEN '"+aPergRet[3]+"' AND '"+aPergRet[4]+"' AND "
cQuery +="E1_LOJA BETWEEN '"+aPergRet[5]+"' AND '"+aPergRet[6]+"' AND "
cQuery +="E1_VENCREA BETWEEN '"+dtos(aPergRet[7])+"' AND '"+dtos(aPergRet[8])+"' AND "
cQuery +="E1_NUM BETWEEN '"+aPergRet[10]+"' AND '"+aPergRet[11]+"' AND "
cQuery +="E1_TIPO IN ('CF-','PI-','CS-') AND "
cQuery +="E1_FILIAL = '"+QTITULOS->E1_FILIAL+"' AND E1_NUM = '"+QTITULOS->E1_NUM+"' AND E1_PARCELA = '"+QTITULOS->E1_PARCELA+"' AND " 
cQuery +="E1_LOJA = '"+QTITULOS->E1_LOJA+"' AND E1_CLIENTE = '"+QTITULOS->E1_CLIENTE+"' "
cQuery +="GROUP BY E1_FILIAL, E1_CLIENTE, E1_LOJA "
TcQuery cQuery new Alias QSE1

while QSE1->(!Eof())
	//Busca Notas Fiscais
	cQuery :="SELECT E1_NUM, E1_NFELETR " 
	cQuery +="FROM "+RetSqlName("SE1")+ " SE1 "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="E1_FILIAL BETWEEN '"+aPergRet[1]+"' AND '"+aPergRet[2]+"' AND "
	cQuery +="E1_CLIENTE BETWEEN '"+aPergRet[3]+"' AND '"+aPergRet[4]+"' AND "
	cQuery +="E1_LOJA BETWEEN '"+aPergRet[5]+"' AND '"+aPergRet[6]+"' AND "
	cQuery +="E1_VENCREA BETWEEN '"+dtos(aPergRet[7])+"' AND '"+dtos(aPergRet[8])+"' AND "
	cQuery +="E1_NUM BETWEEN '"+aPergRet[10]+"' AND '"+aPergRet[11]+"' AND "
	cQuery +="E1_TIPO IN ('CF-','PI-','CS-') AND "
	cQuery +="E1_CLIENTE = '"+QSE1->E1_CLIENTE+"' AND "
	cQuery +="E1_LOJA = '"+QSE1->E1_LOJA+"' AND "
	cQuery +="E1_FILIAL = '"+QTITULOS->E1_FILIAL+"' AND E1_NUM = '"+QTITULOS->E1_NUM+"' AND E1_PARCELA = '"+QTITULOS->E1_PARCELA+"' AND " 
	cQuery +="E1_LOJA = '"+QTITULOS->E1_LOJA+"' AND E1_CLIENTE = '"+QTITULOS->E1_CLIENTE+"' "
	cQuery +="GROUP BY E1_NUM, E1_NFELETR "

	TcQuery cQuery new Alias QNFS
	cNFs:= ""
	cNEt:= ""
	while QNFS->(!eof())
		cNFs+= alltrim(QNFS->E1_NUM)
		cNEt:= alltrim(QNFS->E1_NFELETR)
		QNFS->(dbSkip())
		If QNFS->(!eof())
			cNFs+="/" 
		Endif
	enddo
	QNFS->(dbCloseArea())

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+QSE1->(E1_CLIENTE+E1_LOJA)))
	lExist	:= .T.
	If cTipod == "1" //Emissao
		dDatVenc:= stod(substr(QSE1->E1_EMISSAO,1,6)+"20")+30 //utiliza o mЙs subsequente - pela emissЦo
	Else //Vencimento
		dDatVenc:= stod(substr(QSE1->E1_VENCREA,1,6)+"20")+30 //utiliza o mЙs subsequente - pelo vencimento
	Endif
	dDatVenc:= substr(dTos(dDatVenc),1,6)+"20"
	aadd(aInfo,{{SA1->A1_NOME,SA1->A1_TEL},; //1
			aPergRet[9],;							//2 Periodo de apuraГЦo
			TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99"),; //3
			"5952",;								// 4 Codigo da Receita
			QSE1->E1_VALOR,;						// 5 Valor da Receita Bruta Acumulada
			0,;										// 6 Percentual
			QSE1->E1_VALOR,;						// 7 Valor do Principal
			0,;										// 8 Valor da multa
			0,;										// 9 Valor dos juros
			dDatVenc,;								// 10 Vencimento
			cNFs,;									// 11 Notas Fiscais
			alltrim(QTITULOS->E1_NUM)+"-"+alltrim(QTITULOS->E1_NOMCLI)+"_5952" , cNEt})// 12 nome do arquivo

		PrtDarf(aInfo,aPergRet)
		aInfo:= {}
	
QSE1->(dbSkip())
Enddo
QSE1->(dbCloseArea())

//IR
cQuery :="SELECT SUM(E1_VALOR) E1_VALOR, E1_FILIAL, E1_CLIENTE, E1_LOJA, MAX(E1_VENCREA) E1_VENCREA,MAX(E1_EMISSAO) E1_EMISSAO " 
cQuery +="FROM "+RetSqlName("SE1")+ " SE1 "
cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
cQuery +="E1_FILIAL BETWEEN '"+aPergRet[1]+"' AND '"+aPergRet[2]+"' AND "
cQuery +="E1_CLIENTE BETWEEN '"+aPergRet[3]+"' AND '"+aPergRet[4]+"' AND "
cQuery +="E1_LOJA BETWEEN '"+aPergRet[5]+"' AND '"+aPergRet[6]+"' AND "
cQuery +="E1_VENCREA BETWEEN '"+dtos(aPergRet[7])+"' AND '"+dtos(aPergRet[8])+"' AND "
cQuery +="E1_NUM BETWEEN '"+aPergRet[10]+"' AND '"+aPergRet[11]+"' AND "
cQuery +="E1_TIPO IN ('IR-') AND "
cQuery +="E1_FILIAL = '"+QTITULOS->E1_FILIAL+"' AND E1_NUM = '"+QTITULOS->E1_NUM+"' AND E1_PARCELA = '"+QTITULOS->E1_PARCELA+"' AND " 
cQuery +="E1_LOJA = '"+QTITULOS->E1_LOJA+"' AND E1_CLIENTE = '"+QTITULOS->E1_CLIENTE+"' "
cQuery +="GROUP BY E1_FILIAL, E1_CLIENTE, E1_LOJA "
TcQuery cQuery new Alias QSE1

while QSE1->(!Eof())
	//Busca Notas Fiscais
	cQuery :="SELECT E1_NUM, E1_NFELETR "
	cQuery +="FROM "+RetSqlName("SE1")+ " SE1 "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="E1_FILIAL BETWEEN '"+aPergRet[1]+"' AND '"+aPergRet[2]+"' AND "
	cQuery +="E1_CLIENTE BETWEEN '"+aPergRet[3]+"' AND '"+aPergRet[4]+"' AND "
	cQuery +="E1_LOJA BETWEEN '"+aPergRet[5]+"' AND '"+aPergRet[6]+"' AND "
	cQuery +="E1_VENCREA BETWEEN '"+dtos(aPergRet[7])+"' AND '"+dtos(aPergRet[8])+"' AND "
	cQuery +="E1_NUM BETWEEN '"+aPergRet[10]+"' AND '"+aPergRet[11]+"' AND "
	cQuery +="E1_TIPO IN ('IR-') AND "
	cQuery +="E1_CLIENTE = '"+QSE1->E1_CLIENTE+"' AND "
	cQuery +="E1_LOJA = '"+QSE1->E1_LOJA+"' AND "
	cQuery +="E1_FILIAL = '"+QTITULOS->E1_FILIAL+"' AND E1_NUM = '"+QTITULOS->E1_NUM+"' AND E1_PARCELA = '"+QTITULOS->E1_PARCELA+"' AND " 
	cQuery +="E1_LOJA = '"+QTITULOS->E1_LOJA+"' AND E1_CLIENTE = '"+QTITULOS->E1_CLIENTE+"' "
	cQuery +="GROUP BY E1_NUM, E1_NFELETR "
	
	TcQuery cQuery new Alias QNFS
	cNFs:= ""
	cNEt:= ""
	while QNFS->(!eof())
		cNFs+= alltrim(QNFS->E1_NUM)
		cNEt:= alltrim(QNFS->E1_NFELETR)
		QNFS->(dbSkip())
		If QNFS->(!eof())
			cNFs+="/" 
		Endif
	enddo
	QNFS->(dbCloseArea())

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+QSE1->(E1_CLIENTE+E1_LOJA)))
	lExist	:= .T.

	If cTipod == "1" //Emissao
		dDatVenc:= stod(substr(QSE1->E1_EMISSAO,1,6)+"20")+30 //utiliza o mЙs subsequente - pelo vencimento
	Else
		dDatVenc:= stod(substr(QSE1->E1_VENCREA,1,6)+"20")+30 //utiliza o mЙs subsequente - pelo vencimento
	Endif
	dDatVenc:= substr(dTos(dDatVenc),1,6)+"20"
	
	aadd(aInfo,{{SA1->A1_NOME,SA1->A1_TEL},; //1
			aPergRet[9],;							//2 Periodo de apuraГЦo
			TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99"),; //3
			"1708",;								// 4 Codigo da Receita
			QSE1->E1_VALOR,;						// 5 Valor da Receita Bruta Acumulada
			0,;										// 6 Percentual
			QSE1->E1_VALOR,;						// 7 Valor do Principal
			0,;										// 8 Valor da multa
			0,;										// 9 Valor dos juros
			dDatVenc,;						// 10 Vencimento
			cNFs,;									// 11 Notas Fiscais
			alltrim(QTITULOS->E1_NUM)+"-"+alltrim(upper(QTITULOS->E1_NOMCLI))+"_1708",cNEt})// 12 nome do arquivo
	
		PrtDarf(aInfo,aPergRet)
		aInfo:= {}

QSE1->(dbSkip())
Enddo
QSE1->(dbCloseArea())
	
QTITULOS->(dbSkip())
Enddo
QTITULOS->(dbCloseArea())

If lExist
	msgInfo('Arquivo(s) exportado(s) para o diretСrio C:\DARF\')
Else
	msgInfo('NЦo hА dados')
Endif	

cFilAnt := cFilialAtu
Return(.T.)

Static Function PrtDarf(aInfo,aPergRet)

Local cBmp 		 := ""
Local cStartPath := GetSrvProfString("StartPath","")
Local nX         := 030
Local nY         := 0
Local nW         := 0
Local oFont07    := TFont():New("Arial",07,10,,.F.,,,,.T.,.F.)
Local oFont09    := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  
Local oFont09n   := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Local oFont10    := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont11    := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Local oFont15    := TFont():New("Arial",15,15,,.F.,,,,.T.,.F.)
Local oFont21n   := TFont():New("Arial",21,21,,.T.,,,,.T.,.F.)

Local oFont07n   := TFont():New("Arial",07,10,,.T.,,,,.T.,.F.)
Local oFont18n   := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)          

Local oPrint
Local cSet  

Local cObs       := ""

cSet := Set(_SET_DATEFORMAT)
Set(_SET_DATEFORMAT,"dd/mm/yyyy")    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁInicializacao do objeto grafico                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
///oPrint 	:= TMSPrinter():New("DARF - Guia de Recolhimento DARF")
///oPrint:Setup()
///oPrint:SetPortrait()

cNomArq		:= alltrim(aInfo[1][12])
cPath		:= 'c:\darf\' //GetSrvProfString("ROOTPATH","") + "/darf/" //'C:\DARF\'
makedir(cPath)
oPrint	:= FWMSPrinter():New( cNomArq, IMP_PDF , .T., '\SPOOL\', .T., , , , , , .F., )
oPrint:cPathPDF:= cPath
oPrint:cPathPrint:= cPath
oPrint:lInJob	:= .T.
oPrint:lServer	:= .F.
oPrint:lViewPDF	:= .F. 

oPrint:nDevice := IMP_PDF
oPrint:SetResolution(82)
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_A4) //A4
oPrint:SetMargin(12,12,12,12)
oPrint:Setup()


cBmp := cStartPath + "Receita.BMP" //Logo da Receita Federal
For nW := 1 To Len(aInfo)
	oPrint:StartPage()
	nX := 040
	nFator:= 70
	For nY := 1 To 2
		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Box grafico                                                Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Box(nX,0030,nX+1100,2350)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁInclusao do logotipo do Ministerio da Fazenda                           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If File(cBmp)
				oPrint:SayBitmap(nX+10,040,cBmp,200,180)
			EndIf
			oPrint:Say(nX+020+nFator,250,"MINISTиRIO DA FAZENDA",oFont15)
			oPrint:Say(nX+070+nFator,250,"Secretaria da Receita Federal do Brasil")
			oPrint:Say(nX+120+nFator,250,"Documento de ArrecadaГЦo de Receitas Federais",oFont10)
			oPrint:Say(nX+170+nFator,250,"DARF",oFont21n)
			oPrint:Line(nX,1300,nX+1100,1300)
			oPrint:Line(nX,1800,nX+810,1800)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 01                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Say(nX+280+30,040,"01",oFont10)
			oPrint:Say(nX+290+30,110,"NOME / TELEFONE",oFont10)		    			
			oPrint:Say(nX+350+30,110,Left(aInfo[nW][1][1],40),oFont10) 
			oPrint:Say(nX+380+30,110,aInfo[nW][1][2],oFont10)

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁQuadro das Notas                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Say(nX+500+nFator-10,110,SM0->M0_FILIAL,oFont10)		    			
			oPrint:Say(nX+540+nFator-10,110,"REF. AO RPS "+alltrim(aInfo[nW][11])+" / NF "+alltrim(aInfo[nW][13]) ,oFont10)		    			

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 02                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+270,030,nX+270,1300) ///
			oPrint:Line(nX+490,030,nX+490,1300)
			oPrint:Line(nX+650,030,nX+650,1300)
			oPrint:Say(nX+020+20,1305,"02",oFont10)
			oPrint:Say(nX+030+20,1360,"PERIODO DE APURACAO",oFont09)
			If Len(Dtoc(aInfo[nW][2])) > 8
				oPrint:Say(nX+030+20,2150,Dtoc(aInfo[nW][2]),oFont10)
			Else
				oPrint:Say(nX+030+20,2190,Dtoc(aInfo[nW][2]),oFont10)
			EndIf	
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 03                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+090,1300,nX+90,2350)
			oPrint:Say(nX+120,1305,"03",oFont10)
			oPrint:Say(nX+130,1360,"NзMERO DO CPF OU CNPJ",oFont09)
			oPrint:Say(nX+130,2080,alltrim(aInfo[nW][3]),oFont10)  
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 04                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+180,1300,nX+180,2350)
			oPrint:Say(nX+200+15,1305,"04",oFont10)
			oPrint:Say(nX+210+15,1360,"CODIGO DA RECEITA",oFont09)
			oPrint:Say(nX+210+15,2260,aInfo[nW][4],oFont10)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 05                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+270,1300,nX+270,2350)
			oPrint:Say(nX+290+20,1305,"05",oFont10)
			oPrint:Say(nX+300+20,1360,"NзMERO DE REFERйNCIA",oFont09)
			///oPrint:Say(nX+300,2035,aInfo[nW][5],oFont10)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 06                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+360,1300,nX+360,2350)
			oPrint:Say(nX+380+20,1305,"06",oFont10)
			oPrint:Say(nX+390+20,1360,"DATA DE VENCIMENTO",oFont09)
			oPrint:Say(nX+390+20,2185,Dtoc(stod(aInfo[nW][10])),oFont10)  

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 07                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+450,1300,nX+450,2350)
			oPrint:Say(nX+470+20,1305,"07",oFont10)
			oPrint:Say(nX+480+20,1360,"VALOR DO PRINCIPAL",oFont09)
			oPrint:Say(nX+480+20,2160,Transform(aInfo[nW][7],"@E 9,999,999,999.99"),oFont10)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 08                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+ 540,1300,nX+540,2350)
			oPrint:Say(nX+560+20,1305,"08",oFont10)
			oPrint:Say(nX+570+20,1360,"VALOR DA MULTA",oFont09)
			oPrint:Say(nX+570+20,2160,Transform(aInfo[nW][8],"@E 9,999,999,999.99"),oFont10)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 09                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+630,1300,nX+630,2350)
			oPrint:Say(nX+650+30,1305,"09",oFont10)
			oPrint:Say(nX+640+30,1360,"VALOR DOS JUROS E / OU",oFont09)
			oPrint:Say(nX+670+30,1370,"ENCARGOS DL 1025/69",oFont09)
			oPrint:Say(nX+670+30,2160,Transform(aInfo[nW][9],"@E 9,999,999,999.99"),oFont10)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 10                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+720,1300,nX+720,2350)
			oPrint:Say(nX+740+20,1305,"10",oFont10)
			oPrint:Say(nX+750+20,1360,"VALOR TOTAL",oFont09)
			oPrint:Say(nX+750+20,2160,Transform(aInfo[nW][7]+aInfo[nW][8]+aInfo[nW][9],"@E 9,999,999,999.99"),oFont10)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro 11                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Line(nX+810,1300,nX+810,2350)
			oPrint:Say(nX+830+20,1305,"11",oFont10)
			oPrint:Say(nX+830+20,1370,"AUTENTICAгцO BANCаRIA (SOMENTE NAS 1 E 2 VIAS)",oFont09n)

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁDefinicao do Quadro de aviso                                            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			oPrint:Say(nX+0680,600,"ATENгцO",oFont10n)
			oPrint:Say(nX+0740,040,"и vedado o recolhimento de tributos e contribuiГУes administrados pela",oFont07)
			oPrint:Say(nX+0780,040,"Secretaria da Receita Federal cujo valor seja inferior a R$ 10,00. ",oFont07)
			oPrint:Say(nX+0820,040,"Ocorrendo tal situaГЦo, adicione esse valor ao tributo/contribuiГЦo de",oFont07)
			oPrint:Say(nX+0860,040,"mesmo cСdigo de perМodos subsequentes, atИ que o total seja igual ou",oFont07)
			oPrint:Say(nX+0900,040,"superior a R$10,00.",oFont07)
			
			If nY == 1
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁDefinicao do picote                                                     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				oPrint:Say(nX+1250,000,Replicate("-",132),oFont11)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//ЁSegunda via do Darf                                                     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
				nX := 1480
			EndIf
	
	Next nY
	oPrint:EndPage()
Next nW
oPrint:Preview()
Return(.T.)