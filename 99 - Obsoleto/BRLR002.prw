#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "MSOLE.CH"



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport

@author  Matheus Lando Raimundo
@version P12
@since 	 16/02/2017
@return 
/*/
//-------------------------------------------------/------------------------------------
user function BRLR002()
	Private CMVPAR01 := TFJ->TFJ_CODIGO
	Private CMVPAR02 := ""
	Private CMVPAR03 := ""
	Private	oReport
	Private cPerg := ""
    
    At15GerExc()
        
	//If TRepInUse() 
		//Pergunte(cPerg,.F.)	
	//	oReport := RepInit() 
	//	oReport:SetLandScape()
	//	oReport:PrintDialog()	
	//EndIf
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RepInit
Função responsavel por elaborar o layout do relatorio a ser impresso

@version P12
/*/
//-------------------------------------------------------------------------------------
Static Function RepInit()
	//Local oReport
	Local oSection1
	Local oSection2		
	Local oBreak1	:= Nil	
	Local oBreak2	:= Nil
	
	STR0003 := "Demonstrativo de formação de preço"
	STR0004 := "Produto"
	STR0005 := "Local de atendimento"
	STR0006 := "Descrição"
	STR0007 := "Quantidade"
	STR0008 := "Per Início"
	STR0009 := "Per Fim"
	STR0010 := "Preço"
	STR0011 := "Campo"
	STR0012 := "Valor"
	STR0013 := "Formula"
	STR0014 := "Demonstrativo"
	STR0015 := "A"
	STR0016 := "Arquivo XML|*.xml"
	STR0018 := "Salvar Planilha"
	STR0019 := 'Verificando alocacao da equipe '
	STR0022 := "A"
	STR0023 := "A"
	STR0024 := "A"
	STR0025 := "A"
	STR0026 := "A"
	STR0027 := "A"
	STR0028 := "A"
	STR0029 := "A"
	STR0032 := "A"
	STR0033 := "A"
	STR0034 := "A"
	STR0035 := "A"
	STR0036 := "A"
	STR0037 := "A"
	STR0038 := "A"

	
	oReport := TReport():New("BRLR002",STR0003,cPerg,{|oReport| PrintReport(oReport)},STR0003)				 //"Demonstrativo de formação de preço"
	oSection1 := TRSection():New(oReport	,STR0004 ,{"TFF"},,,,,,,.T.) //"Produto"
	oSection2 := TRSection():New(oSection1	,STR0014,{"TFF"},,,,,,,.T.) //"Demonstrativo"	
		
	TRCell():New(oSection1,"TFF_PRODUT"		,"TFF"	,STR0004,,,,,,,,,,,,,.T.)	 //"Produto"
	TRCell():New(oSection1,"B1_DESC"		,"SB1"	,STR0006,,,,,,,,,,,,,.T.) //"Descrição"
	TRCell():New(oSection1,"TFL_LOCAL"		,"TFL"	,STR0005,,,,,,,,,,,,,.T.) //"Local de atendimento"
	TRCell():New(oSection1,"ABS_DESCRI"		,"ABS"	,STR0006,,,,,,,,,,,,,.T.) //"Descrição"
	TRCell():New(oSection1,"TFF_QTDVEN"		,"TFF"	,STR0007,,,,,,,,,,,,,.T.) //"Quantidade"
	TRCell():New(oSection1,"TFF_PERINI"		,"TFF"	,STR0008,,,,,,,,,,,,,.T.) //"Per Início"
	TRCell():New(oSection1,"TFF_PERFIM"		,"TFF"	,STR0009,,,,,,,,,,,,,.T.) //"Per Fim"
	TRCell():New(oSection1,"TFF_PRCVEN"		,"TFF"	,STR0010,,,,,,,,,,,,,.T.) //"Preço"
	
	
	
	TRCell():New(oSection2,"ZZZ_CAMPO","",STR0011,,,,,,,,,,.T.,,,) //"Campo"
	TRCell():New(oSection2,"ZZZ_DESC","",STR0006,,,,,,,,,,.T.,,,)	 //"Descrição"
	TRCell():New(oSection2,"ZZZ_VALOR","",STR0012,,,,,,,,,,.T.,,,) //"Valor"
	TRCell():New(oSection2,"ZZZ_FORM","",STR0013,,,,,,,,,,.T.,,,) //"Formula"
	
	oBreak1 := TRBreak():New( oSection1,{|| QRY_TFF->REC} )
	oBreak2 := TRBreak():New( oSection2,{|| QRY_TFF->REC} )
		
Return oReport


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport

@author  Matheus Lando Raimundo
@version P12
@since 	 16/02/2017
@return 
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)	
	Local oSection2 := oReport:Section(1):Section(1)										
	Local cCodOrc	:= CMVPAR01
	Local nI		:= 1
	Local cExpLoc	:= "% 0 = 0 %"
	Local cExpRH	:= "% 0 = 0 %"	
	
	If !Empty(CMVPAR02)
		cExpLoc := "% TFL.TFL_CODIGO = '" + CMVPAR02 + "'%"		
	EndIf

	If !Empty(CMVPAR03)
		cExpRH := "% TFF.TFF_COD = '" + CMVPAR03 + "'%"		
	EndIf  
	
	dbSelectArea("QRY_TFF")
	dbCloseArea()		
	//Busca os dados da Secao principal
	oSection1:BeginQuery()
	BeginSql alias "QRY_TFF"			 		 				
		SELECT TFF.R_E_C_N_O_ REC, TFL.TFL_LOCAL, ABS.ABS_DESCRI, TFF_PRODUT, SB1.B1_DESC, TFF_QTDVEN, TFF_PERINI, TFF_PERFIM, TFF_PRCVEN FROM %table:TFF% TFF			
			INNER JOIN %table:TFL% TFL ON TFL_FILIAL = %xfilial:TFL% AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
			INNER JOIN %table:ABS% ABS ON ABS_FILIAL = %xfilial:ABS% AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
			INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xfilial:SB1% AND SB1.B1_COD = TFF.TFF_PRODUT
			
			WHERE TFF.TFF_FILIAL = %xfilial:TFF% 			
			AND TFL.TFL_CODPAI = %Exp:cCodOrc%
			AND (TFF.TFF_TABXML <> '' OR TFF.TFF_TABXML IS NOT NULL) 
			AND %Exp:cExpLoc%
			AND %Exp:cExpRH%
			AND SB1.%notDel%
			AND ABS.%notDel%
			AND TFF.%notDel%
			AND TFL.%notDel%
			 					
	EndSql
	
	oSection1:EndQuery()
	oSection1:SetParentQuery(.F.)
		
	oSection1:Init()
	While QRY_TFF->(!Eof())
		oSection1:PrintLine()
		
		TFF->(DbGotO(QRY_TFF->(REC)))
		cXml := TFF->TFF_TABXML 	 	
		
		aDados := getDataXML(cXml)
		oSection2:Init()
		For nI := 1 To Len(aDados)			
			oSection2:Cell("ZZZ_CAMPO"):SetBlock( {||AllTrim(aDados[nI,1])})
			oSection2:Cell("ZZZ_DESC"):SetBlock( {||AllTrim(aDados[nI,2])})
			oSection2:Cell("ZZZ_VALOR"):SetBlock( {||AllTrim(aDados[nI,3])})				
			oSection2:Cell("ZZZ_FORM"):SetBlock( {||AllTrim(aDados[nI,4])})
	 		oSection2:PrintLine()
	 	Next nI	
	 	QRY_TFF->(DbSkip())
	EndDo
	dbSelectArea("QRY_TFF")
	dbCloseArea()	
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getDataXML

@author  Matheus Lando Raimundo
@version P12
@since 	 28/06/2018
@return 
/*/
//-------------------------------------------------------------------------------------
static Function getDataXML(cXML)
Local aRet 	  	:= {}
Local oXml 	    := ""
Local cError	:= ""
Local cWarning  := ""
Local nI		:= 1
Local aItens	:= {}

oXml := XmlParser( cXml, "_", @cError, @cWarning )
aItens := oXml:_FWMODELSHEET:_MODEL_SHEET:_MODEL_CELLS:_ITEMS:_ITEM

For nI := 1 To Len(aItens)
	If Mod(nI,2) <> 0 .And. Len(aItens) <> nI 
		Aadd(aRet, {aItens[nI + 1]:_NICKNAME:TEXT, aItens[nI]:_VALUE:TEXT, aItens[nI + 1]:_VALUE:TEXT, aItens[nI + 1]:_FORMULA:TEXT, aItens[nI + 1]:_PICTURE:TEXT})
	EndIf	
Next nI 

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At15GerExc

@author  Matheus Lando Raimundo
@version P12
@since 	 13/08/2018
@return 
/*/
//-------------------------------------------------------------------------------------
static Function At15GerExc()
Local cCodOrc	:= CMVPAR01	
Local cError	:= ""
Local cWarning	:= ""
Local cXml 		:= ""
Local oFWSheet	:= Nil
Local oExcel 	:= Nil 
Local cPlan		:= ""
Local aDados	:= {}
Local nY		:= 0
Local nW		:= 0
Local cFile		:= ""
Local xValor	:= ""
Local cExpRH	:= "% 0 = 0 %"
Local cExpLoc	:= "% 0 = 0 %"
Local lCriaObj 		:= .F.
	
If !Empty(CMVPAR02)
	cExpLoc := "% TFL.TFL_CODIGO = '" + CMVPAR02 + "'%"		
EndIf

If !Empty(CMVPAR03)
	cExpRH := "% TFF.TFF_COD = '" + CMVPAR03 + "'%"		
EndIf  
	
BeginSql alias "QRY_TFF"			 		 							
	SELECT TFF.R_E_C_N_O_ REC, TFF_COD FROM %table:TFF% TFF
		INNER JOIN %table:TFL% TFL ON TFL_FILIAL = %xfilial:TFL% AND TFF.TFF_CODPAI = TFL.TFL_CODIGO				
		
		WHERE TFF.TFF_FILIAL = %xfilial:TFF% 			
		AND TFL.TFL_CODPAI = %Exp:cCodOrc%
		AND (TFF.TFF_CALCMD <> '' OR TFF.TFF_CALCMD IS NOT NULL) 
		AND %Exp:cExpLoc%
		AND %Exp:cExpRH%		
		AND TFF.%notDel%
		AND TFL.%notDel%
		 					
EndSql
cPlan := "A"
While QRY_TFF->(!Eof())

	If !lCriaObj
		oExcel := FWMSExcel():New() // Define o objeto
		lCriaObj := .T.
	EndIf
	
	TFF->(DbGotO(QRY_TFF->(REC)))
	cPlan := TFF->TFF_ITEM + "-" + ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC"))
	cXml := TFF->TFF_CALCMD
	oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição
	oFWSheet:LoadXmlModel(cXml)
	
	oExcel:AddworkSheet(Alltrim(TFF->TFF_COD)) // Define o titulo da planilha 
	oExcel:AddTable(Alltrim(TFF->TFF_COD),cPlan)
	 
	For nY := 1 To Len(oFWSheet:aCells) //linha
		For nW := 2 To Len(oFWSheet:aCells[nY]) //Coluna
			xValor := oFWSheet:aCells[nY][nW]
			If nY == 1
				oExcel:AddColumn(Alltrim(TFF->TFF_COD),cPlan,Iif(ValType(xValor) == "U","",xValor),2,1)
			Else
				If alltrim(xValor) == "VL LIQUIDO"
					aAdd(aDados,"")
					nY := Len(oFWSheet:aCells)
				Else
					aAdd(aDados,Iif(ValType(xValor) == "U","",xValor))
				EndIf
			EndIf 
		Next nW
 		If nY != 1 	
			oExcel:AddRow(Alltrim(TFF->TFF_COD),cPlan,aDados)		
			aDados := {}
		EndIf
	Next nY
	
	oFWSheet := Nil  
	QRY_TFF->(DbSkip())
EndDo

If lCriaObj
	oExcel:Activate()
	
	//cFile := cGetFile('Arquivo XML|*.xml','Salvar Planilha',1,"C:\",.F.,nOR(GETF_LOCALHARD,GETF_LOCALFLOPPY),.T.,.T.) //'Arquivo XML|*.xml'#'Salvar Planilha'
	cFile := "C:\TOTVS\"+CMVPAR01
	If !Empty(cFile)
		If At('.xml',cFile) == 0
			cFile := cFile+'.xml'
		EndIf
		
		oExcel:GetXMLFile(cFile)
		
		If File(cFile)
//			If MsgYesNo("A")			
				MsgRun('Verificando geracao de arquivo '	, 'Verificando geracao de arquivo '	,{|| ShellExecute("open",cFile ,"","",2) } ) //'Verificando alocac'Verificando alocacao da equipe '	ao da equipe '						
//			EndIf		
		Else
			Help(,,"AT015NGER",,"A",1,0) 				
		EndIf
	EndIf	
Else
	Help(,,"AT015NREG",,"A",1,0)		
EndIf

dbSelectArea("QRY_TFF")
dbCloseArea()
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} at015Loc 
Filtra os locais do orçamento

@author  Matheus Lando Raimundo
@version P12
@since 	 13/08/2018
@return 
/*/
//-------------------------------------------------------------------------------------
static Function at015Loc()
Local lRet           := .F.
Local oBrowse        := Nil
Local cAls              := GetNextAlias()
Local nSuperior      := 0
Local nEsquerda      := 0
Local nInferior      := 0
Local nDireita       := 0
Local oDlgTela := Nil
Local cQry   := ""
//Definição do índice da Consulta Padrão
Local aIndex := {"ABS_LOCAL"}
//Definição da Descrição da Chave de Pesquisa da Consulta Padrão
Local aSeek := {{ "A", {{"A","C",TamSx3('TFL_CODIGO')[1],0,"",,}} }}
Local cCodOrc := CMVPAR01
Local cRet := ""
Local cPictTot := PesqPict("TFL","TFL_TOTMC")

cQry := " SELECT " 
cQry += " ABS_FILIAL, "
cQry += " TFL_CODIGO,"
cQry += " ABS_LOCAL, "  	
cQry += " ABS_DESCRI, "
cQry += " TFL_DTINI,"  
cQry += " TFL_DTFIM,"  
cQry += " TFL_TOTRH,"
cQry += " TFL_TOTMI,"
cQry += " TFL_TOTMC,"
cQry += " TFL_TOTLE"    
cQry += " FROM " + RetSqlName("ABS") + " ABS "  
cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQry += " ON TFL.TFL_FILIAL = '" +   xFilial('TFL') + "'"
cQry += " AND TFL.TFL_LOCAL = ABS.ABS_LOCAL "  
cQry += " AND TFL.D_E_L_E_T_ <> '*'"  
cQry += " AND TFL_CODPAI =  '" + cCodOrc  + "'"
cQry += " WHERE ABS_FILIAL = '" +  xFilial('ABS') + "'"
cQry += " AND ABS.D_E_L_E_T_ <> '*'"
  
nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE "A" FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL 
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription("A") 
oBrowse:SetAlias(cAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->TFL_CODIGO,  , lRet := .T., oDlgTela:End()})
oBrowse:AddButton( "A", {|| cRet := (oBrowse:Alias())->TFL_CODIGO,  lRet := .T., oDlgTela:End()},, 2 )
oBrowse:AddButton( "A",  {|| cRet := "", oDlgTela:End()} ,, 2 )
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)

ADD COLUMN oColumn DATA { ||  ABS_FILIAL } TITLE "A" SIZE TamSx3('ABS_FILIAL')[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  TFL_CODIGO } TITLE "A" SIZE TamSx3('TFL_CODIGO')[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  ABS_LOCAL} TITLE "A" SIZE TamSx3('ABS_LOCAL')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  ABS_DESCRI } TITLE "A" SIZE TamSx3('ABS_DESCRI')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  Transform(TFL_TOTRH,cPictTot) } TITLE "A" SIZE TamSx3('TFL_TOTRH')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  Transform(TFL_TOTMI,cPictTot) } TITLE "A" SIZE TamSx3('TFL_TOTMI')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  Transform(TFL_TOTMC,cPictTot) } TITLE "A" SIZE TamSx3('TFL_TOTMC')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  Transform(TFL_TOTLE,cPictTot) } TITLE "A" SIZE TamSx3('TFL_TOTLE')[1]  OF oBrowse



If !IsBlind()            
	oBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf	
 
If lRet
	cLocal := cRet 
EndIf
     
     
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} at015RetLc 
Filtra os locais do orçamento
Retorna o local selecionado
@author  Matheus Lando Raimundo
@version P12
@since 	 13/08/2018
@return 
/*/
//-------------------------------------------------------------------------------------
static Function at015RetLc()

Return cLocal


//-------------------------------------------------------------------
/*/{Protheus.doc} At015PrdRH()
Filtra os itens de rh do orçamento


@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
static Function At015PrdRH()

Local lRet           := .F.
Local oBrowse        := Nil
Local cAls              := GetNextAlias()
Local nSuperior      := 0	
Local nEsquerda      := 0
Local nInferior      := 0
Local nDireita       := 0
Local oDlgTela := Nil
Local cQry   := ""
//Definição do índice da Consulta Padrão
Local aIndex := {"TFF_PRODUT"}
//Definição da Descrição da Chave de Pesquisa da Consulta Padrão
Local aSeek := {{ "A", {{"A","C",TamSx3("TFF_PRODUT")[1],0,"",,}} }}
Local cCodOrc := CMVPAR01
Local cLocal := CMVPAR02
Local cPictQtd := PesqPict("TFF","TFF_QTDVEN")
Local cPictPrc := PesqPict("TFF","TFF_PRCVEN")
Local cRet := ""

cQry := " SELECT " 
cQry += " TFF_FILIAL,"
cQry += " TFF_COD, "
cQry += " TFF_PRODUT, "
cQry += " B1_DESC, "
cQry += " TFF_QTDVEN, "
cQry += " TFF_PRCVEN, "
cQry += " TFF_PERINI, "
cQry += " TFF_PERFIM "  
cQry += " FROM " + RetSqlName("TFF") + " TFF "
cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQry += " ON SB1.B1_FILIAL = '" +  xFilial('SB1') + "'"
cQry += " AND SB1.B1_COD = TFF.TFF_PRODUT"  
cQry += " AND SB1.D_E_L_E_T_ <> '*'"

cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQry += " ON TFL.TFL_FILIAL = '" +  xFilial('TFL') + "'"
cQry += " AND TFL.TFL_CODPAI = '"  + cCodOrc + "'"
cQry += " AND TFL.TFL_CODIGO = '"  + cLocal + "'"
cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI"
cQry += " AND TFL.D_E_L_E_T_ <> '*'"
  
cQry += " WHERE TFF_FILIAL = '" + xFilial('TFF') + "'"
cQry += " AND TFF.D_E_L_E_T_ <> '*'"
  
nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE "A" FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL 
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription("A") 
oBrowse:SetAlias(cAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->TFF_COD,  lRet := .T., oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi("A"), {|| cRet := (oBrowse:Alias())->TFF_COD, lRet := .T.,  oDlgTela:End()},, 2 )
oBrowse:AddButton( OemTOAnsi("A"),  {|| cRet := "", oDlgTela:End()} ,, 2 )
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)

ADD COLUMN oColumn DATA { ||  TFF_FILIAL } TITLE "A" SIZE TamSx3('TFF_FILIAL')[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  TFF_COD} TITLE "A" SIZE TamSx3('TFF_COD')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  TFF_PRODUT } TITLE "A" SIZE TamSx3('TFF_PRODUT')[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  B1_DESC } TITLE "A" SIZE TamSx3('B1_DESC')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  Transform(TFF_QTDVEN, cPictQtd)  } TITLE "A" SIZE TamSx3('TFF_QTDVEN')[1]  OF oBrowse
ADD COLUMN oColumn DATA { ||  Transform(TFF_PRCVEN, cPictPrc)  } TITLE "A" SIZE TamSx3('TFF_PRCVEN')[1]  OF oBrowse

If !IsBlind()             
	oBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf

If lRet
	cItemRH := cRet 
EndIf

     
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} at015RetRH()
Retorna o item de RH selecionado


@author Matheus Lando Raimundo      

/*/
//------------------------------------------------------------------
static Function at015RetRH()

Return cItemRH