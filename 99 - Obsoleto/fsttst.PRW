#INCLUDE "RwMake.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "msobject.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSTTST    บAutor  ณCarlos A. Gomes Jr. บ Data ณ  11/08/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcoes genericas:                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RunAplica(cInternet)

	Local oBar
	Local cMenuBmp := GetMenuBmp()

	If Type("OMAINWND") != "O"

		//Variaveis para tela Principal
		Private oShortList, oMainWnd, oFont
		Private lLeft     := .F.
		Private cVersao   := GetVersao()
		Private dDataBase := MsDate()
		Private cUsuario  := "TOTVS"

		DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9

		DEFINE WINDOW oMainWnd FROM 0,0 TO 800, 600  TITLE  "Tela principal RunAplica."
		oMainWnd:oFont := oFont
		oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
		oMainWnd:Cargo := oShortList
		oMainWnd:oFont := oFont
		oMainWnd:nClrText := 0
		oMainWnd:lEscClose := .F.

		MainToolBar(@oBar)

		SET MESSAGE OF oMainWnd TO oEmToAnsi(cVersao)  NOINSET FONT oFont
		DEFINE MSGITEM oMsgItem0 OF oMainWnd:oMsgBar PROMPT '     '               SIZE 50
		DEFINE MSGITEM oMsgItem1 OF oMainWnd:oMsgBar PROMPT dDataBase             SIZE 100
		DEFINE MSGITEM oMsgItem2 OF oMainWnd:oMsgBar PROMPT Substr(cUsuario,1,6)  SIZE 100
		DEFINE MSGITEM oMsgItem3 OF oMainWnd:oMsgBar PROMPT 'Microsiga / Matriz'  SIZE 180
		DEFINE MSGITEM oMsgItem4 OF oMainWnd:oMsgBar PROMPT 'Ambiente'            SIZE 180

		oMainWnd:ReadClientCoors()

		ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( AuxRunAplica(.T.) , oMainWnd:End())

	Else
		AuxRunAplica()
	EndIf

Return

//DEFINICOES HTML
#Define HTMO ' <B><font size="4"> '
#Define HTMC ' </B></font> '

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunaplica บAutor  ณCarlos A. Gomes Jr. บ Data ณ  04/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para executar funcoes.                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxRunAplica(lRunEnv)

	Local bGet,oBkpDlg,oDlgRun,oResult,cResult
	Local cGet      := Space(255)
	Local cEmpRun   := "01"
	Local cFilRun   := "01"
	Local cUsuRun   := Space(20)
	Local cPasRun   := Space(20)
	Local lComAmb   := .F.
	Local lProtErro := .F.
	Local cMascFun  := Space(80)

	DEFAULT lRunEnv := .T.

	Private xRet := Space(255)

	oDlgRun := MSDialog():New(0,0,480,590,"Executa fun็ใo",,,,,,,,,.T.,,,)

	TSay():New(05,02, {|| "Empresa:" },oDlgRun,,,,,,.T.,,,30,10,,,,,,.T.)
	TGet():New(03,25, bSETGET(cEmpRun),oDlgRun,15,10,,,,,,,,.T.,,,{|| lRunEnv .And. !lComAmb },,,,,,)
	TSay():New(05,45, {|| "Filial:" },oDlgRun,,,,,,.T.,,,30,10,,,,,,.T.)
	TGet():New(03,65, bSETGET(cFilRun),oDlgRun,15,10,,,,,,,,.T.,,,{|| lRunEnv .And. !lComAmb },,,,,,)

	TSay():New(05,85, {|| "Usuario:" },oDlgRun,,,,,,.T.,,,30,10,,,,,,.T.)
	TGet():New(03,105, bSETGET(cUsuRun),oDlgRun,30,10,,,,,,,,.T.,,,{|| lRunEnv .And. !lComAmb },,,,,,)
	TSay():New(05,145, {|| "Senha:" },oDlgRun,,,,,,.T.,,,30,10,,,,,,.T.)
	TGet():New(03,165, bSETGET(cPasRun),oDlgRun,30,10,,,,,,,,.T.,,,{|| lRunEnv .And. !lComAmb },,,,,.T.,)

	TSay():New(20,02, {|| "Fun็ใo:" },oDlgRun,,,,,,.T.,,,30,10,,,,,,.T.)
	TGet():New(18,25, bSETGET(cGet),oDlgRun,200,10,,,,,,,,.T.,,,,,,,,,)
	TButton():New(02,200,"&Ambiente",oDlgRun,{|| AuxRunApl(cEmpRun,cFilRun,cUsuRun,cPasRun,,,,@lComAmb) },45,15,,,,.T.,,,,{|| lRunEnv .And. !lComAmb },,)
	TButton():New(02,250,"&Sem Ambiente",oDlgRun,{|| RpcClearEnv(),lComAmb := .F. },45,15,,,,.T.,,,,{|| lRunEnv .And. lComAmb },,)
	TButton():New(17,250,"&Executar",oDlgRun,{|| If(Empty(cGet),bGet:={|| .T. },bGet := &("{||xRet := "+cGet+" }")), MsgRun("Executando...","Aguarde.",{||TrataExec(bGet,lProtErro)}), cResult := VarInfo('xRet',xRet,,.F.), oResult:Refresh() },45,15,,,,.T.,,,,,,)
	TSay():New(33,02, {|| '<B><I><font size="4">Resultado:</font></B></I>' },oDlgRun,,,,,,.T.,,,50,10,,,,,,.T.)
	TCheckBox():New( 33, 240,'Protecao de erro:', bSETGET(lProtErro), oDlgRun, 50, 10,,,,,,,,.T.,,,)
	oResult := TMultiGet():New(48,02, bSETGET(cResult),oDlgRun,293,175,,,,,,.T.,,,,,,,,,,,)

	TSay():New(230,02, {|| "Mascara Fun็ใo:" },oDlgRun,,,,,,.T.,,,50,10,,,,,,.T.)
	TGet():New(228,50, bSETGET(cMascFun),oDlgRun,175,10,,,,,,,,.T.,,,,,,,,,)
	TButton():New(227,250,"&Buscar",oDlgRun,{|| cResult := VarInfo('Fun็ใo',LeFuncRPO(AllTrim(cMascFun)),,.F.), oResult:Refresh() },45,15,,,,.T.,,,,,,)

	oDlgRun:Activate(,,,.T.,,,)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAuxRunApl บAutor  ณCarlos A. Gomes Jr. บ Data ณ  21/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta ambiente.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxRunApl(cEmpRun,cFilRun,cUsrRun,cPasRun,cModRun,cFunRun,cTabRun,lComAmb)

	Local oBkpObj

	DEFAULT cEmpRun := "01"
	DEFAULT cFilRun := "01"

	If Empty(cUsrRun)
		cUsrRun := Nil
	Else
		cUsrRun := AllTrim(cUsrRun)
	EndIf

	If Empty(cPasRun)
		cPasRun := Nil
	Else
		cPasRun := AllTrim(cPasRun)
	EndIf

	lComAmb := .T.

	oBkpObj := oMainWnd
	oMainWnd := Nil

	RpcSetType(2)
	MsgRun("Aguarde...","Montando Ambiente. Empresa ["+cEmpRun+"] Filial ["+cFilRun+"].",{|| RpcSetEnv( cEmpRun,cFilRun,cUsrRun,cPasRun,"TMS",/*FunName*/,/*{Tables}*/) } )

	If ( !Empty(cUsrRun) .Or. !Empty(cPasRun) )
		PswOrder(2)
		If ( !PswSeek(cUsrRun) .Or. !PswName(cPasRun) )
			MsgStop("Usuario ou senha invalidos.["+cUsrRun+"]","RunAplica")
			RpcClearEnv()
			lComAmb := .F.
		EndIf
	EndIf

	oMainWnd := oBkpObj
	oBkpObj := Nil

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTrataExec บAutor  ณCarlos A. Gomes Jr. บ Data ณ  04/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa fun็ใo tratando erro.                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TrataExec(bBloco,lProtErro)

	Local bErrBlock

	DEFAULT lProtErro := .F.

	If lProtErro
		bErrBlock := ErrorBlock()
		ErrorBlock( {|e| ExecErro(e) } )
	EndIf

	Begin Sequence
		EVAL(bBloco)
	End Sequence

	If lProtErro
		ErrorBlock( bErrBlock )
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExecErro  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  22/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNovo tratamento de erro.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExecErro(e)
	MsgStop(HTMO+"Existe um erro na fun็ใo:"+HTMC+"<BR><BR>Verifique a ocorr๊ncia :<BR><BR>"+e:description, "ERRO!")
	xRet := CRLF+e:description+CRLF
	Break
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeFuncRPO บAutor  ณCarlos A. Gomes Jr. บ Data ณ  04/05/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe funcoes do RPO.                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeFuncRPO(cMascFun)
	Local aRet   := {}
	Local aFuns  := {}
	Local nCount := 0
	Local aType,aFile,aLine,aDate,aTime

	cMascFun := AllTrim(cMascFun)
	If !Empty(cMascFun)
		// Buscar informacoes de todas as funcoes contidas no APO
		aFuns := GetFuncArray(cMascFun, aType, aFile, aLine, aDate, aTime)

		For nCount := 1 To Len(aFuns)
			AAdd(aRet,{ aFuns[nCount], aType[nCount], aFile[nCount], aLine[nCount], aDate[nCount], aTime[nCount]})
		Next
	EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTESTAEMAILบAutor  ณCarlos A. Gomes Jr. บ Data ณ  06/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exmeplo de envio de email.                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TESTAEMAIL(cServidor,cConta,cMailPsw,cTo,cBody,lAut,cFrom,lHelp)

	Local lOk      := .T.
	Local lSendOk  := .F.
	Local cError   := ""
	Local cUserAut := ""

	DEFAULT cServidor := SuperGetMV("MV_RELSERV",,"smtp.meuservidor.com.br")
	DEFAULT cConta    := SuperGetMV("MV_RELACNT",,"usuario@meuservidor.com.br")
	DEFAULT cMailPsw  := SuperGetMV("MV_RELPSW" ,,"")
	DEFAULT lAut      := SuperGetMV("MV_RELAUTH",,.F.)
	DEFAULT cFrom     := cConta
	DEFAULT cTo       := cConta
	DEFAULT cBody     := "Enviado do email " + cConta
	DEFAULT lHelp     := .T.

	cUserAut  := cConta //Left(cConta,At("@",cConta)-1)

	CONNECT SMTP SERVER cServidor ACCOUNT cConta PASSWORD cMailPsw TIMEOUT 120 RESULT lOk

	If lOk .And. (!lAut .Or. (lOk := MailAuth(cUserAut,cMailPsw)) )
		SEND MAIL ;
			FROM cFrom ;
			TO cTo ;
			SUBJECT "E-Mail Protheus." ;
			BODY cBody ;
			RESULT lSendOk
	EndIf

	If lHelp
		If !lSendOk
			GET MAIL ERROR cError
			MsgAlert("Envio de Cartas."+CRLF+cError,"Erro no E-mail:")
		Else
			MsgInfo("Envio Ok.","E-mail.")
		EndIf
	EndIf

	If lOk
		DISCONNECT SMTP SERVER RESULT lOk
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTesteOle  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  06/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exemplo utilizacao objeto OLE.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "OleCont.ch"
User Function TesteOle

	Local oDlg, oScroll, oOle
	Local cArquivo := "c:\35120465681033000190550010000011751000011752.xml"
	Local cArq1 := "c:\35120465681033000190550010000011751000011752.doc"
	Local cArq2 := "c:\35120465681033000190550010000011751000011752.html"

	DEFINE MSDIALOG oDlg TITLE "Teste" FROM 0,0 TO 480,640 PIXEL

	@ 005,005 SCROLLBOX oScroll SIZE 220,310 OF oDlg VERTICAL HORIZONTAL BORDER
	@ 005,005 OLECONTAINER oOle SIZE 300,400 OF oScroll FILENAME cArquivo PIXEL
	@ 225,200 Button "&Abrir"  Size 030,012 PIXEL OF oDlg ACTION ShellExecute("open",cArquivo,"","",1)
	@ 225,100 Button "&Trocar" Size 030,012 PIXEL OF oDlg ACTION ( cArquivo := Iif(cArquivo == cArq1,cArq2,cArq1) , oOle:OpenFromFile(cArquivo,.F.), oOle:Refresh() )

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTesteXml  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  06/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria Janela de Tree do Xml.                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TesteXML

	Local oDlg, oXmlTree
	Local cArquivo := "c:\temp\29121142509257000113550030000072861301347230-nfe.xml"
	Local cXml     := MemoRead(cArquivo)

	DEFINE MSDIALOG oMainWnd TITLE "Teste" FROM 0,0 TO 480,640 PIXEL

	oXmlTree:= FWXmlInTree():New( 0, 0, 0 ,0, oMainWnd, cXml )
	oXmlTree:SetAlign( CONTROL_ALIGN_ALLCLIENT )
	oXmlTree:Activate()
	oXmlTree:ReNew()

	ACTIVATE MSDIALOG oMainWnd CENTERED ON INIT oXmlTree:Refresh()

	oXmlTree :Deactivate()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpBaseEx บAutor  ณCarlos A. Gomes Jr. บ Data ณ  10/22/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de importacao de base exemplo                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ImpBaseEx
	MsApp():New('SIGATST')
	oApp:CreateEnv()
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",{|| RpcSetEnv("01","01"), }),U_AuxImpBase(),Final("TERMINO NORMAL")}
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMenu:= .F.
	oApp:lShortCut:= .F.
	oApp:lMessageBar:= .F.
	oApp:cModDesc:= 'SIGATST'
	oApp:RunApp()
Return

//Funcao auxiliar chamada pela principal.
User Function AuxImpBase

	Local oWizard, oPanel, oGet1, oGet2, oMeter1, oMeter2
	Local cDir    := Space(100)
	Local cHist   := ""
	Local lNaoFoi := .T.
	Local cText :=	'Este programa irแ importar uma base de dados exemplo para a sua base atual'+;
		' da empresa 01 filial 01. Esta importa็ใo serแ por "APPEND" e portanto manterแ'+;
		'sua estrutura atual de arquivos, diferente da Fun็ใo Import do SDU'+;
		'.' + CRLF + CRLF + CRLF + ;
		'Para continuar clique em avan็ar.'

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializacao do Wizardณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE WIZARD oWizard TITLE 'Easy-Import de Base de Dados Exemplo.' ;
		HEADER 'APPEND de Base de dados Exemplo:' ;
		MESSAGE 'Fun็ใo criada internamente na Microsiga.' TEXT cText ;
		NEXT {|| lNaoFoi := .T. } FINISH {|| .T.} PANEL

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSegundo Panel - Arquivo Lay Outณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard HEADER 'Easy-Import de Base de Dados Exemplo.' ;
		MESSAGE 'APPEND de Base de dados Exemplo:' ;
		BACK {|| .T. } NEXT {|| lNaoFoi } FINISH {|| !lNaoFoi } PANEL
	oPanel := oWizard:GetPanel(2)

	TSay():New(01,02,{|| "Escolha o caminho do arquivo :"},oPanel,,,,,,.T.)
	oGet1 := TGet():New(11,02, bSETGET(cDir),oPanel,180,10,,,,,,,,.T.,,,,,,,.T.,,,)
	SButton():New(09,185,14,{|| cDir := cGetFile("Codebase|*.DBF|Todos Arquivos|*.*|","Escolha o caminho dos arquivos.",0,"SERVIDOR",.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY)},oPanel,)
	TButton():New(08,230,"&Processa", oPanel,{|| ProcImpEx(@oMeter1,@oMeter2,@cHist,cDir,@lNaoFoi,@oGet2) },45,15,,,,.T.,,,,{|| lNaoFoi },,)
	TSay():New(25,02,{|| "Hist๓rico de processamento :"},oPanel,,,,,,.T.)
	oGet2 := TMultiGet():New(35,02, bSETGET(cHist),oPanel,220,50,,,,,,.T.,,,,,,,,,,,)
	TSay():New(92,02,{|| "Andamento do Processamento (TOTAL) :"},oPanel,,,,,,.T.)
	oMeter1 := TMeter():New( 100,02, bSETGET(0),, oPanel, 270,10,,.T.,,,,,,,,)
	TSay():New(114,02,{||"Andamento do Processamento (Por arquivo) :"},oPanel,,,,,,.T.)
	oMeter2 := TMeter():New( 122,02, bSETGET(0),, oPanel, 270,10,,.T.,,,,,,,,)

	ACTIVATE WIZARD oWizard CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcImpEx บAutor  ณCarlos A. Gomes Jr. บ Data ณ  10/22/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa importacao de base de dados exemplo.              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcImpEx(oMeter1,oMeter2,cHist,cDir,lNaoFoi,oGet2)

	Local aDir    := aArqs := Directory(cDir+"*.DBF")
	Local aArqs   := {}
	Local aStru1  := {}
	Local aStru2  := {}
	Local nI      := 0
	Local nII     := 0
	Local lCont   := .T.
	Local nPosFil := 0
	Local uConteudo

	If Len(aDir) == 0
		MsgAlert("Nใo hแ arquivos no caminho selecionado.")
		cHist += "Nใo hแ arquivos no caminho selecionado." + CRLF + CRLF + "---------------------------"
		Return .F.
	Else
		cHist += "Iniciando Processamento..." + CRLF + "Filtrando arquivos..." + CRLF
		oGet2:Refresh()
		AEval(aDir,{|x,y| If(Len(AllTrim(x[1])) == 7 .And. Right(AllTrim(x[1]),4) == ".DBF", AAdd(aArqs, x[1] ) , .T. ) } )
	EndIf

	If Len(aArqs) == 0
		MsgAlert("Nใo hแ arquivos ap๓s aplica็ใo do filtro.")
		cHist += "Nใo hแ arquivos ap๓s aplica็ใo do filtro." + CRLF + CRLF + "---------------------------"
		Return .F.
	EndIf

	oMeter1:nTotal:=(Len(aArqs) * 10)

	For nI := 1 To Len(aArqs)
		oMeter1:Set(nI * 10)
		cHist += "Appendando arquivo " + aArqs[nI] + CRLF
		oGet2:Refresh()
		DbUseArea(.T.,,cDir+aArqs[nI],"BASEX",.F.,.F.)
		aStru1 := BASEX->(DbStruct())
		aStru2 := {}
		AEval(aStru1,{|x,y| Aadd(aStru2,{x[1],"BASEX->"+x[1]}) })
		nPosFil := AScan(aStru2,{|x| "_FILIAL" $ UPPER(x[1]) })
		If nPosFil > 0 .And. !BASEX->(Eof())
			If SX2->(MSSeek(Left(aArqs[nI],3)))
				RecLock('SX2',.F.)
				SX2->X2_MODO := Iif(Empty(&(aStru2[nPosFil][2])),"C","E")
				MsUnLock()
			EndIf
		EndIf
		oMeter2:nTotal:=BASEX->(RecCount())
		lCont := .T.
		DbSelectArea(Left(aArqs[nI],3))
		If RecCount() > 0
			If MsgYesNo(Alias() + ' nใo estแ vasio! Deseja apagแ-lo antes?')
				DbGoTop()
				Do While !Eof()
					RecLock(Left(aArqs[nI],3),.F.)
					(Left(aArqs[nI],3))->(DbDelete())
					MsUnLock()
					DbSkip()
				EndDo
			Else
				lCont := MsgYesNo('Procede "APPENND mesmo assim?"')
			EndIf
		EndIf
		BASEX->(DbGoTop())
		nII := 0
		Do While lCont .And. !BASEX->(Eof())
			nII++
			oMeter2:Set(nII)
			RecLock(Left(aArqs[nI],3),.T.)
			AEval(aStru2,{|x,y| uConteudo := &(x[2]), FieldPut( FieldPos(x[1]), uConteudo ) })
			MsUnLock()
			BASEX->(DbSkip())
		EndDo
		BASEX->(DbCloseArea())
	Next
	cHist += CRLF + "Processo finalizado com Sucesso!!!!" + CRLF + "-------------------------"

	lNaoFoi := .F.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFExplor   บAutor  ณTOTVS               บ Data ณ 07/Jul/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFile Explorer em ADVPL. Facilita manipulacao de arquivos no บฑฑ
ฑฑบ          ณprotheus.                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Modifica็๕es
//	SAULO GOMES MARTINS - 22/12/2014 - LAYOUT E INCLUSรO DE CONECTAR A SERVIDOR REMOTO
Static cMaskArq := "*"
User Function FExplor
	Local cModName 	:= "SIGACFG"
	Local oSrv
	Private oButRPC
	MsApp():New(cModName,.F.)
	oApp:cInternet := nil
	oApp:CreateEnv()
	//oApp:bAppStart	:= {|| TelaExplorer() }	//Antes de iniciar
	//oApp:bAppInit	:= {|| TelaExplorer(),FINAL() }		//Apos Logar
	oApp:bMainInit	:= {|| TelaExplorer(oSrv)/*,Final( "Final de programa!", "Finalizando!" ) */}			//Substitui tela de login
	oApp:Activate()
	If ValType(oSrv)<>"U"
		oSrv:Disconnect()
	EndIf
Return
Static Function TelaExplorer(oSrv)
	Local oDlgExpl,oGet1,oGet2
	Local oBmp01
	Local aSeek   := {}
	Local aCampos := {}
	Local oColumn

	Local cPatch01 := PadR("C:\",60)
	Local cPatch02 := PadR("\",60)

	Local cIP		:= Space(100)
	Local nPorta	:= 0
	Local cEnvi		:= Space(100)
	Local aGet			:= {}
	Local cQLineEdit	:= "QLineEdit {  border: 2px solid gray;     border-radius: 6px;     padding: 0 8px;     background: white;     selection-background-color: darkgray; }"
	Local cCSSGrid		:= ""//"QTableView { selection-background-color: qlineargradient(x1: 0, y1: 0, x2: 0.5, y2: 0.5,stop: 0 #CCCCCC, stop: 1 #888888); }"
	Local oList01
	Local oList02
	Local aList01:={}
	Local aList02:={}
	Static oFolder  := LoadBitmap( GetResources(), "f5_amar")
	Static oFile    := LoadBitmap( GetResources(), "lbno_mdi")

	Private oMainWnd
	Private oQtdArq,oQtdArq2

	Aadd( aSeek, { "Nome" , {{"","C",100,0,"Nome"}} } )
	//Aadd( aSeek, { "Tamanho(Bytes)" , {{"","N",9,0,"Tamanho"}} } )
	Aadd( aCampos, { "Nome","Nome","C",100,0,""} )
	Aadd( aCampos, { "Tamanho","Tamanho","N",9,0,""} )

	cCSSGrid += "QHeaderView::section { background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #616161, stop: 0.5 #505050, stop: 0.6 #434343,  stop:1 #656565); color: white; padding-left: 4px; border: 1px solid #6c6c6c; }"

	//DEFINE MSDIALOG oDlgExpl TITLE "Explorer" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL
	//oDlgExpl	:= oMainWnd

	//oApp:oMainWnd:SetCss("QDialog { background-image: url(rpo:login_background.png) stretch; background-repeat: none }")
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oApp:oMainWnd, .F., .T. )
	oFWLayer:addLine( 'LIN1', 6, .F. )
	oFWLayer:addLine( 'LIN2', 84, .F. )
	oFWLayer:addLine( 'LIN3', 10, .F. )
	oFWLayer:addCollumn( 'COL1', 45, .F.,'LIN1' )
	oFWLayer:addCollumn( 'COL2', 03, .F.,'LIN1' )
	oFWLayer:addCollumn( 'COL3', 52, .F.,'LIN1' )
	oFWLayer:addCollumn( 'COL1', 45, .F.,'LIN2' )
	oFWLayer:addCollumn( 'COL2', 04, .F.,'LIN2' )
	oFWLayer:addCollumn( 'COL3', 51, .F.,'LIN2' )
	oFWLayer:addCollumn( 'COL1', 45, .F.,'LIN3' )
	oFWLayer:addCollumn( 'COL2', 03, .F.,'LIN3' )
	oFWLayer:addCollumn( 'COL3', 52, .F.,'LIN3' )
	oPanel1_1 := oFWLayer:getColPanel( 'COL1','LIN1' )
	oPanel1_2 := oFWLayer:getColPanel( 'COL1','LIN2' )
	oPanel1_3 := oFWLayer:getColPanel( 'COL1','LIN3' )
	oPanel2_1 := oFWLayer:getColPanel( 'COL2','LIN1' )
	oPanel2_2 := oFWLayer:getColPanel( 'COL2','LIN2' )
	oPanel2_3 := oFWLayer:getColPanel( 'COL2','LIN3' )
	oPanel3_1 := oFWLayer:getColPanel( 'COL3','LIN1' )
	oPanel3_2 := oFWLayer:getColPanel( 'COL3','LIN2' )
	oPanel3_3 := oFWLayer:getColPanel( 'COL3','LIN3' )

	@ 003,001 BITMAP oBmp01 NAME "reload"      SIZE 015,015 OF oPanel1_1 PIXEL NOBORDER ON CLICK ( LeDirect(@oList01,@oGet1,@cPatch01) )
	@ 003,015 MSGET oGet1 VAR cPatch01 PICTURE "@!" PIXEL SIZE 150,009 WHEN .T. VALID LeDirect(@oList01,@oGet1,@cPatch01) OF oPanel1_1
	AADD(aGet,oGet1)
	@ 003,170 BITMAP oBmp01 NAME "OPEN"      SIZE 015,015 OF oPanel1_1 PIXEL NOBORDER ON CLICK ( cPatch01 := OpenBtn(cPatch01,"T") , LeDirect(@oList01,@oGet1,@cPatch01) )

	oBtn := TButton():New(002,001,"Excluir Arq.",oPanel1_3,,33,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| MsgRun("Apagando Arquivo...","Aguarde.",{|| FApaga(cPatch01,oList01) , LeDirect(@oList01,@oGet1,@cPatch01) }) }
    oBtn:SetCss(CssbtnImg("BMPDEL.png"))
	oBtn := TButton():New(002,034,"Excluir Tudo",oPanel1_3,,33,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| Processa({|| FApaga(cPatch01,oList01,.T.), LeDirect(@oList01,@oGet1,@cPatch01) },"Exclusใo de arquivos","Excluindo",.T.) }
    oBtn:SetCss(CssbtnImg("avg_idel.png"))
	oBtn := TButton():New(002,067,"Nova Pasta",oPanel1_3,,30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {||If(CriarPasta(@cPatch01,oSrv,.F.),LeDirect(@oList01,@oGet1,@cPatch01,.F.),nil)}
    oBtn:SetCss(CssbtnImg("avg_inew.png"))
	oBtn := TButton():New(002,097,"Abrir com...",oPanel1_3,,30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| shellExecute("Open", "rundll32.exe", "shell32.dll,OpenAs_RunDLL "+Alltrim(cPatch01)+AllTrim(oList01:oData:GetArray()[oList01:At()][1])+" ", cPatch01, 1 ) }
    oBtn:SetCss(CssbtnImg("avg_inew.png"))
	oBtn := TButton():New(002,127,"Abrir Pasta",oPanel1_3,,30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| shellExecute("Open","Explorer.exe", " /select,"+Alltrim(cPatch01)+AllTrim(oList01:oData:GetArray()[oList01:At()][1]), Alltrim(cPatch01), 1 ) }
    oBtn:SetCss(CssbtnImg("avg_import.png"))
	oBtn := TButton():New(002,157,"Notepad++",oPanel1_3,,30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| shellExecute("Open", "Notepad++.exe", " "+Alltrim(cPatch01)+AllTrim(oList01:oData:GetArray()[oList01:At()][1]), "C:\Program Files (x86)\Notepad++\", 1 ) }
    oBtn:SetCss(CssbtnImg("note.png"))

	@ 007,001 BITMAP oBmp01 NAME "ic_20_grayup"      SIZE 015,015 OF oPanel3_1 PIXEL NOBORDER ON CLICK ( VoltaDir(@cPatch02),LeDirect(@oList02,@oGet2,@cPatch02,.F.,oSrv) )
	@ 007,015 BITMAP oBmp01 NAME "reload"      SIZE 015,015 OF oPanel3_1 PIXEL NOBORDER ON CLICK ( LeDirect(@oList02,@oGet2,@cPatch02,.f.,oSrv) )
	@ 007,030 MSGET oGet2 VAR cPatch02 PICTURE "@!" PIXEL SIZE 130,009 WHEN .T. VALID LeDirect(@oList02,@oGet2,@cPatch02,.f.,oSrv) OF oPanel3_1
	AADD(aGet,oGet2)

	oGroup := TGroup():New(001,160,020,340,'Conexใo remota',oPanel3_1,,,.T.)
	@ 007,160 MSGET oIP VAR cIP PICTURE "@!" PIXEL SIZE 70,009 WHEN {|| ValType(oSrv)=="U" } OF oPanel3_1
	AADD(aGet,oIP)
	@ 007,230 MSGET oPorta VAR nPorta PICTURE "99999999" PIXEL SIZE 40,009 WHEN {|| ValType(oSrv)=="U" }  OF oPanel3_1
	AADD(aGet,oPorta)
	@ 007,270 MSGET oEnvi VAR cEnvi PICTURE "@!" PIXEL SIZE 45,009 WHEN {|| ValType(oSrv)=="U" } OF oPanel3_1
	AADD(aGet,oEnvi)
	If SubStr(GetBuild(),1,12)>"7.00.121227P"
		oIP:cPlaceHold	:= "IP ou hostname"
		oIP:cTooltip		:= "IP ou hostname"
		oPorta:cPlaceHold	:= "Porta"
		oPorta:cTooltip		:= "Porta"
		oEnvi:cPlaceHold	:= "Environment"
		oEnvi:cTooltip		:= "Environment"
	EndIf
	oButRPC := TButton():New(006,318,"",oPanel3_1,,15,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButRPC:bAction	:= {|| If( SrvConect(@oSrv,cEnvi,cIp,nPorta) , (cPatch02 := PadR("\",60),LeDirect(@oList02,@oGet2,@cPatch02,,oSrv)),nil) }
    oButRPC:SetCss(CssbtnImg("frtoffline.png"))

	//@ 007,320 BITMAP oBmp02 NAME "frtoffline"      SIZE 015,015 OF oPanel3_1 PIXEL NOBORDER ON CLICK ( If( SrvConect(@oSrv,cEnvi,cIp,nPorta,@oBmp02) , (cPatch02 := PadR("\",60),LeDirect(@oList02,@oGet2,@cPatch02,,oSrv)),nil) )

	oBtn := TButton():New(002,001,"Excluir Arq.",oPanel3_3,{|| MsgRun("Apagando Arquivo...","Aguarde.",{|| FApaga(cPatch02,oList02,,,,,oSrv) , LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) }) },33,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtn:SetCss(CssbtnImg("BMPDEL.png"))
	oBtn := TButton():New(002,034,"Excluir Tudo",oPanel3_3,{|| Processa({|| FApaga(cPatch02,oList02,.T.,,,,oSrv), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) },"Exclusใo de arquivos","Excluindo",.T.) },33,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtn:SetCss(CssbtnImg("avg_idel.png"))
	oBtn := TButton():New(002,067,"Nova Pasta",oPanel3_3,{|| Processa({|| If (CriarPasta(@cPatch02,oSrv,.T.),LeDirect(@oList02,@oGet2,@cPatch02,.F.,oSrv),nil) }) },30,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtn:SetCss(CssbtnImg("avg_inew.png"))

	//@ 025,002 BITMAP oBmp01 NAME "RIGHT"   SIZE 015,015 OF oPanel2_2 PIXEL NOBORDER ON CLICK MsgRun("Copiando Arquivo...","Aguarde.",{|| FCopia(cPatch01,cPatch02,oList01,.F.,,,oSrv,.T.) , LeDirect(@oList01,@oGet1,@cPatch01,,,oList01:oData:GetArray()[oList01:At()][1]),  LeDirect(@oList02,@oGet2,@cPatch02,,oSrv,oList01:oData:GetArray()[oList01:At()][1]) })
	oBtn := TButton():New(025,000,"Enviar",oPanel2_2,,25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| MsgRun("Copiando Arquivo...","Aguarde.",{|| FCopia(cPatch01,cPatch02,oList01,.F.,,,oSrv,.T.) , LeDirect(@oList01,@oGet1,@cPatch01,,,oList01:oData:GetArray()[oList01:At()][1]),  LeDirect(@oList02,@oGet2,@cPatch02,,oSrv,oList01:oData:GetArray()[oList01:At()][1]) }) }
    oBtn:SetCss(CssbtnImg("RIGHT.png"))
	oBtn := TButton():New(045,000,"Receber",oPanel2_2,,25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| MsgRun("Copiando Arquivo...","Aguarde.",{|| FCopia(cPatch02,cPatch01,oList02,.F.,,,oSrv,.F.) , LeDirect(@oList01,@oGet1,@cPatch01,,,oList02:oData:GetArray()[oList02:At()][1]),  LeDirect(@oList02,@oGet2,@cPatch02,,oSrv,oList02:oData:GetArray()[oList02:At()][1]) }) }
    oBtn:SetCss(CssbtnImg("LEFT.png"))
	oBtn := TButton():New(065,000,"Env.Tudo",oPanel2_2,,25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| Processa({|| FCopia(cPatch01,cPatch02,oList01,.T.,,,oSrv,.T.), LeDirect(@oList01,@oGet1,@cPatch01), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) },"Copia de arquivos","Copiando",.T.) }
    oBtn:SetCss(CssbtnImg("pgnext.png"))
	oBtn := TButton():New(085,000,"Rec.Tudo",oPanel2_2,,25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| Processa({|| FCopia(cPatch02,cPatch01,oList02,.T.,,,oSrv,.F.), LeDirect(@oList01,@oGet1,@cPatch01), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) },"Copia de arquivos","Copiando",.T.) }
    oBtn:SetCss(CssbtnImg("pgprev.png"))
	oBtn := TButton():New(105,000,"Filtrar",oPanel2_2,,25,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn:bAction	:= {|| ( MaskDir() , LeDirect(@oList01,@oGet1,@cPatch01), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) ) }
    oBtn:SetCss(CssbtnImg("FILTRO.png"))

	//@ 045,002 BITMAP oBmp01 NAME "LEFT"    SIZE 015,015 OF oPanel2_2 PIXEL NOBORDER ON CLICK MsgRun("Copiando Arquivo...","Aguarde.",{|| FCopia(cPatch02,cPatch01,oList02,.F.,,,oSrv,.F.) , LeDirect(@oList01,@oGet1,@cPatch01,,,oList02:oData:GetArray()[oList02:At()][1]),  LeDirect(@oList02,@oGet2,@cPatch02,,oSrv,oList02:oData:GetArray()[oList02:At()][1]) })
	//@ 065,002 BITMAP oBmp01 NAME "pgnext" SIZE 015,015 OF oPanel2_2 PIXEL NOBORDER ON CLICK Processa({|| FCopia(cPatch01,cPatch02,oList01,.T.,,,oSrv,.T.), LeDirect(@oList01,@oGet1,@cPatch01), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) },"Copia de arquivos","Copiando",.T.)
	//@ 085,002 BITMAP oBmp01 NAME "pgprev"   SIZE 015,015 OF oPanel2_2 PIXEL NOBORDER ON CLICK Processa({|| FCopia(cPatch02,cPatch01,oList02,.T.,,,oSrv,.F.), LeDirect(@oList01,@oGet1,@cPatch01), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) },"Copia de arquivos","Copiando",.T.)
	//@ 105,002 BITMAP oBmp01 NAME "FILTRO"  SIZE 015,015 OF oPanel2_2 PIXEL NOBORDER ON CLICK ( MaskDir() , LeDirect(@oList01,@oGet1,@cPatch01), LeDirect(@oList02,@oGet2,@cPatch02,,oSrv) )

	oList01 := FWBrowse():New(oPanel1_2)
	oList01:SetDataArray(.T.)
	oList01:SetLineHeight(13)
	oList01:SetArray(@aList01)
	oList01:SetOwner(oPanel1_2)
	oList01:DisableReport()
	oList01:SetSeek({|oFWSeek,oSelf| SeekDados(oFWSeek,oSelf) },aSeek)
	oList01:SetDoubleClick({|| LeDirect(@oList01,@oGet1,@cPatch01,.T.) })
	ADD COLUMN oColumn DATA { || Iif("D"$oSelf:oData:GetArray()[oSelf:At()][5],"f5_amar","rpmnew") }			TITLE " "			IMAGE SIZE 001 OF oList01
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][1] }										TYPE "C" TITLE "Nome"		SIZE 025 OF oList01
	ADD COLUMN oColumn DATA { || cTamBytes(oSelf:oData:GetArray()[oSelf:At()][2],2) }							TYPE "C" TITLE "Tamanho"		SIZE 008 OF oList01
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][3] }										TYPE "D" TITLE "Data"	SIZE 010 OF oList01
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][4] }										TYPE "C" TITLE "Hora"	SIZE 010 OF oList01
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][5] } 										TYPE "C" TITLE "Atri"	SIZE 001 OF oList01
	oList01:Activate()

	oList02 := FWBrowse():New(oPanel3_2)
	oList02:SetDataArray(.T.)
	oList02:SetLineHeight(13)
	oList02:SetArray(@aList02)
	oList02:SetOwner(oPanel3_2)
	oList02:DisableReport()
	oList02:SetSeek({|oFWSeek,oSelf| SeekDados(oFWSeek,oSelf) },aSeek)
	oList02:SetDoubleClick({|| LeDirect(@oList02,@oGet2,@cPatch02,.T.,oSrv) })
	ADD COLUMN oColumn DATA { || Iif("D"$oSelf:oData:GetArray()[oSelf:At()][5],"f5_amar","rpmnew") }			TITLE " "			IMAGE SIZE 001 OF oList02
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][1] }										TYPE "C" TITLE "Nome"		SIZE 025 OF oList02
	ADD COLUMN oColumn DATA { || cTamBytes(oSelf:oData:GetArray()[oSelf:At()][2],2) }							TYPE "C" TITLE "Tamanho"		SIZE 008 OF oList02
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][3] }										TYPE "D" TITLE "Data"	SIZE 010 OF oList02
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][4] }										TYPE "C" TITLE "Hora"	SIZE 010 OF oList02
	ADD COLUMN oColumn DATA { || oSelf:oData:GetArray()[oSelf:At()][5] } 										TYPE "C" TITLE "Atri"	SIZE 001 OF oList02
	oList02:Activate()
	oList02:oBrowse:SetCss(cCSSGrid)
	oList01:oBrowse:SetCss(cCSSGrid)

	LeDirect(@oList01,@oGet1,@cPatch01)
	LeDirect(@oList02,@oGet2,@cPatch02,,oSrv)
	oQtdArq		:= TSay():New(025,01,{||cValToChar(LenCond(oList01:oData:GetArray(),{|x| "D"$x[5].and.x[1]<>".".and.x[1]<>".."}))+' Pasta(s) e '+cValToChar(LenCond(oList01:oData:GetArray(),{|x| !("D"$x[5])}))+' Arquivo(s)'},oPanel1_3,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	oQtdArq2	:= TSay():New(025,01,{||cValToChar(LenCond(oList02:oData:GetArray(),{|x| "D"$x[5].and.x[1]<>".".and.x[1]<>".."}))+' Pasta(s) e '+cValToChar(LenCond(oList02:oData:GetArray(),{|x| !("D"$x[5])}))+' Arquivo(s)'},oPanel3_3,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	aEval(aGet,{|x| x:SetCss(cQLineEdit) })
	//oDlgExpl:Activate(,,,.T.,{|| oDlgExpl:FreeChildren() },, )


Return

Static Function SeekDados(oSeek,oBrowse)
Local oSelf    := oBrowse
Local cAscan   := ""
Local cSeek    := ""
Local cType    := ""
Local nAt      := 1
Local nI       := 0
Local nOrder   := 0
Local nPosCol  := 0
Local aColumns := {}

	If ValType(oSeek) != "O"
		Return nAt
	EndIf
	cSeek  := oSeek:GetSeek()
	If Empty(cSeek)
		Return nAt
	EndIf
	nOrder := oSeek:GetOrder()
	aColumns := StrTokArr(oSeek:aOrder[nOrder],"+")
	If Empty(aColumns)
		Return nAt
	EndIf
	cAscan := "{ || Ascan(oSelf:oData:GetArray(), { |x| "
	For nI := 1 To Len(aColumns)
		nPosCol := Ascan( oBrowse:aColumns, { |x| x:GetTitle() == aColumns[nI] } )
		If nPosCol > 1
			cType := oBrowse:aColumns[nPosCol]:GetType()
			If ValType(cType) == "U"
				cType := ValType(Eval(oBrowse:aColumns[nPosCol]:GetData()))
			EndIf
			If cType == "C"
				cAscan += "UPPER(SubStr(x["+LTrim(Str(nPosCol-1))+"],1,"+cValToChar(Len(Trim(cSeek)))+"))+"		//imagem ้ o 1o item
			Else
				cAscan += "x["+LTrim(Str(nPosCol-1))+"]+"
			EndIf
		Else
			cAscan := ""
			Exit
		EndIf
	Next nI
	If Empty(cAscan)
		Return nAt
	EndIf
	cAscan := SubStr(cAscan,1,Len(cAscan)-1) + " == "
	If cType == "C"
		cAscan += "UPPER('"+Trim(cSeek)+"')"
	Else
		cAscan += Trim(cSeek)
	EndIf
	cAscan += " } ) }"
	//-------------------------------------------------------------------
	// Realiza a pesquisa
	//-------------------------------------------------------------------
	nAt := Eval(&(cAscan))
	If nAt == 0
		nAt := 1
	EndIf

Return nAt

/*/{Protheus.doc} SrvConect
Realiza a conexใo remota ao servidor
@author Saulo Gomes Martins
@since 22/12/2014
@version 1.0
@param oSrv, objeto, Objeto RPC
@param cEnvi, character, Ambiente
@param cIp, character, IP
@param nPorta, num้rico, Porta
@return lConectado, Se conseguiu realizar a conexใo remota
/*/
Static Function SrvConect(oSrv,cEnvi,cIp,nPorta)
	If ValType(oSrv)<>"U"
		oSrv:Disconnect()
		oSrv	:= NIL
		oButRPC:SetCss(CssbtnImg("frtoffline.png"))
		oButRPC:Refresh()
		Return .T.
	EndIf
	oSrv:= yFstRpc():New( AllTrim(cEnvi) )
	If !oSrv:Connect( AllTrim(cIp), nPorta )
		Alert("Problema ao conectar no servidor remoto!")
		oSrv	:= nil
		Return .F.
	EndIF
	oButRPC:SetCss(CssbtnImg("frtonlin.png"))
	oButRPC:Refresh()
Return .T.

Static Function VoltaDir(cInfoPatch)
	If Alltrim(cInfoPatch)=="\"
		Return cInfoPatch
	EndIf
	cInfoPatch := Substr(cInfoPatch,1,RAT("\",Substr(cInfoPatch,1,Len(Rtrim(cInfoPatch))-1)))
	If !("\" $ cInfoPatch)
		cInfoPatch	:= "\"+space(200)
	EndIf
Return cInfoPatch

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeDirect  บAutor  ณTOTVS               บ Data ณ  07/Jul/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar leitura de diretorios no FExplorer.         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeDirect(oObjList,oGetInfo,cInfoPatch,lClick,oSrv,cArqPosic)

	Local aRetList := {{"0","..",0,""}}
	Local nPos	:= 0
	Local nPosPonto

	Local aDirectory	:= {}
	Local aList := {}
	DEFAULT lClick := .F.

	If Empty(cInfoPatch)
		cInfoPatch:= PadR("\",200)
	EndIf
	cInfoPatch := AllTrim(cInfoPatch)

	If lClick
		If oObjList:oData:GetArray()[oObjList:At()][1] == ".."
			VoltaDir(@cInfoPatch)
		ElseIf oObjList:oData:GetArray()[oObjList:At()][1] == "."
			Return
		ElseIf "D"$oObjList:oData:GetArray()[oObjList:At()][5]
			cInfoPatch := cInfoPatch+AllTrim(oObjList:oData:GetArray()[oObjList:At()][1])+"\"
		ElseIf ":" $ cInfoPatch
			shellExecute("Open", AllTrim(oObjList:oData:GetArray()[oObjList:At()][1]), " ", cInfoPatch, 1 )
			Return
		EndIf
	EndIf
	If ValType(oSrv)<>"U"
		aList := oSrv:CallProc("Directory",Rtrim(cInfoPatch)+cMaskArq,"HSD")
	Else
		aList := Directory(cInfoPatch+cMaskArq,"HSD",,.F.)
	EndIf
	If (nPosPonto	:= aScan(aList,{|x| x[1]=="." }))>0
		aDel(aList,nPosPonto)
		aSize(aList,Len(aList)-1)
	EndIf
	If Empty(aList)
		AADD(aList,{"..",0,CTOD(""),"","D"})
	Endif
	//aEval(aDirectory,{|x| AADD(aList,{x[5],x[1],x[2],x[3],x[4],x[5]})})

	ASort(aList,,,{|x,y| If("D"$x[5],"1","2")+UPPER(x[1]) < If("D"$y[5],"1","2")+UPPER(y[1]) })

	oObjList:SetArray(aClone(aList))
	//oObjList:bLine := { || {Iif("D"$aArqInfo[oObjList:At()][5],oFolder,oFile),aArqInfo[oObjList:At()][1],cTamBytes(aArqInfo[oObjList:At()][2]),DTOC(aArqInfo[oObjList:At()][3])+" "+aArqInfo[oObjList:At()][4],aArqInfo[oObjList:At()][5]}}
	//oObjList:SetArray(aRetList)
	//oObjList:bLine := { || {Iif(aRetList[oObjList:At()][1] == "2",oFile,oFolder),aRetList[oObjList:At()][2],cTamBytes(aRetList[oObjList:At()][3]),aRetList[oObjList:At()][4]}}
	oObjList:GoTop()
	oObjList:Refresh()
	oGetInfo:Refresh()
	//oQtdArq:Refresh()
	//oQtdArq2:Refresh()
	cInfoPatch	+= SPACE(60)
	If !Empty(cArqPosic)
		nPos	:= aScan(aList,{|x| Alltrim(Upper(x[1]))==AllTrim(Upper(cArqPosic))})
		If nPos>0
			oObjList:GoTo(nPos)
		EndIf
	EndIf
Return

Static Function cTamBytes(nBytes)
	If nBytes<1024
		Return cValToChar(nBytes)+" B"
	ElseIf nBytes<(1024^2)//1.048.576
		Return cValToChar(Round(nBytes/(1024^1),2))+" KB"
	ElseIf nBytes<(1024^3)//1.073.741.824
		Return cValToChar(Round(nBytes/(1024^2),2))+" MB"
	ElseIf nBytes<(1024^4)//1.099.511.627.776
		Return cValToChar(Round(nBytes/(1024^3),2))+" GB"
	ElseIf nBytes<(1024^5)
		Return cValToChar(Round(nBytes/(1024^4),2))+" TB"
	EndIf
Return cValToChar(nBytes)+" B"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOpenBtn   บAutor  ณTOTVS               บ Data ณ  07/Jul/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar botao de discos no FExplorer.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OpenBtn(cAtual,cOnde)
	Local cRetDir := ""
	If cOnde == "T"
		cRetDir := cGetFile("Todos Arquivos|*.*|","Escolha o caminho dos arquivos.",0,cAtual,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	ElseIf cOnde == "S"
		cRetDir := cGetFile("Todos Arquivos|*.*|","Escolha o caminho dos arquivos.",0,cAtual,,GETF_RETDIRECTORY+GETF_ONLYSERVER)
	EndIf
	cRetDir := Iif(Empty(cRetDir),cAtual,cRetDir)
Return cRetDir

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCopia    บAutor  ณTOTVS               บ Data ณ  07/Jul/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar de copia no FExplorer.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FCopia(cPatchOri,cPatchDes,oObjList,lMultCpy,cArquivo,cAtributo,oSrv,lEnviar)
	Local aMultCopy	:= {}
	Local aArquivos	:= {}
	Local aArqInfo	:= {}
	Private lAbortPrint := .F.

	DEFAULT lMultCpy := .F.
	Default cArquivo		:= oObjList:oData:GetArray()[oObjList:At()][1]
	Default cAtributo		:= oObjList:oData:GetArray()[oObjList:At()][5]
	cPatchOri	:= Rtrim(cPatchOri)
	cPatchDes	:= Rtrim(cPatchDes)

	If lMultCpy
		If ValType(oSrv)<>"U" .AND. lEnviar
			aArqInfo := oSrv:CallProc("Directory",cPatchOri+cMaskArq,"HSD")
		Else
			aArqInfo := Directory(cPatchOri+cMaskArq,"HSD",,.F.)
		EndIf
		AEval(aArqInfo,{|x,y| If(x[1]!=".".and.x[1]!="..",AAdd(aMultCopy,AllTrim(x[1])),nil) })
		If Len(aMultCopy)==0
			MsgAlert("Sem Arquivos para copiar!")
		ElseIf !MsgYesNo("Copiar "+cValToChar(Len(aMultCopy))+" arquivos/pastas?")
			Return
		EndIf
		ProcRegua(Len(aMultCopy))
		AEval(aMultCopy,{|x,y| If(!lAbortPrint, (FCopia(cPatchOri,cPatchDes,oObjList,.F.,x,"A",oSrv,lEnviar), IncProc("Copiando "+Transform(y*100/Len(aMultCopy),"@E 99")+"% - "+x) ),) })
	ElseIf !("D" $ cAtributo)
		If ValType(oSrv)<>"U"
			If lEnviar
				SendRPC(oSrv,Rtrim(cPatchOri)+cArquivo,Rtrim(cPatchDes))
			Else
				CopyRPC(oSrv,Rtrim(cPatchOri)+cArquivo,Rtrim(cPatchDes))
			EndIf
		ElseIf ":" $ cPatchOri
			If !CPYT2S(Rtrim(cPatchOri)+cArquivo,Rtrim(cPatchDes),)
				MsgAlert("Erro ao copiar arquivo."+cValtoChar(FError())+chr(13)+;
							"Origem: "+Rtrim(cPatchOri)+cArquivo+chr(13)+;
							"Destino: "+Rtrim(cPatchDes),"CPYT2S")
			EndIf
		Else
			If !CPYS2T(Rtrim(cPatchOri)+cArquivo,Rtrim(cPatchDes),)
				MsgAlert("Erro ao copiar arquivo."+cValtoChar(FError())+chr(13)+;
							"Origem: "+Rtrim(cPatchOri)+cArquivo+chr(13)+;
							"Destino: "+Rtrim(cPatchDes),"CPYS2T")
			EndIf
		EndIf
	Else
		//MsgAlert("Nใo copia pastas.")
		If ValType(oSrv)<>"U" .AND. lEnviar	//Se enviando para servidor remoto
			If !oSrv:CallProc("File",Rtrim(cPatchDes)+cArquivo)
				oSrv:CallProc("MakeDir",Rtrim(cPatchDes)+cArquivo)
			EndIf
		Else
			If !File(Rtrim(cPatchDes)+cArquivo)
				MakeDir(Rtrim(cPatchDes)+cArquivo)
			EndIf
		EndIf
		FCopia(Rtrim(cPatchOri)+cArquivo+"\",Rtrim(cPatchDes)+cArquivo+"\",oObjList,.T.,,,oSrv,lEnviar)	//Multi copiar
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFApaga    บAutor  ณTOTVS               บ Data ณ  07/Jul/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar de Mascara de Filtro no FExplorer.          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FApaga(cPatchOri,oObjList,lEraseMult,cEraseFile,cAtributo,lConfimar,oSrv)

	Local aMultErase		:= {}
	Local nErro
	Default cEraseFile 	:= AllTrim(oObjList:oData:GetArray()[oObjList:At()][1])
	Default cAtributo		:= oObjList:oData:GetArray()[oObjList:At()][5]
	Default lConfimar		:= .F.

	Private lAbortPrint := .F.

	DEFAULT lEraseMult := .F.

	If lEraseMult
		AEval(oObjList:oData:GetArray(),{|x,y| If(!("D"$x[5]),AAdd(aMultErase,AllTrim(x[1])),) })
		ProcRegua(Len(aMultErase))
		If MsgNoYes("Confirma a exclusao de "+AllTrim(Str(Len(aMultErase)))+" arquivos?")
			AEval(aMultErase,{|x,y| If(!lAbortPrint, (FApaga(cPatchOri,oObjList,.F.,x,"A",.T.,oSrv), IncProc("Apagando "+Transform(y*100/Len(aMultErase),"@E 99")+"% - "+x) ),) })
		EndIf
	ElseIf !("D"$cAtributo)
		If lConfimar .or. MsgNoYes("Apagar o arquivo ["+cEraseFile+"]?")
			If ValType(oSrv)<>"U"
				oSrv:CallProc("FErase",AllTrim(cPatchOri)+cEraseFile)
			Else
				FErase(AllTrim(cPatchOri)+cEraseFile)
			EndIf
		EndIf
	Else
		If !MsgNoYes("Apagar a Pasta ["+cEraseFile+"]?")
			Return
		EndIf
		//MsgAlert("Nใo apaga pastas.")
		/*If ValType(oSrv)<>"U" .AND. lEnviar
			aArqInfo := oSrv:CallProc("Directory",cPatchOri+cMaskArq,"HSD")
		Else
			aArqInfo := Directory(cPatchOri+cMaskArq,"HSD",,.F.)
		EndIf*/
		If ValType(oSrv)<>"U" //.AND. lEnviar
			If !oSrv:CallProc("DirRemove",AllTrim(cPatchOri)+cEraseFile)
				nErro	:= oSrv:CallProc("FError")
				If nErro==118
					//MsgStop('Falha ao remover a pasta '+AllTrim(cPatchOri)+cEraseFile+CHR(13)+"Pasta nใo esta vazia!")
					If MsgYesNo("A Pasta nใo estแ vazia excluir o conteudo todo?")
						If !oSrv:CallProc("FWDirRemove",AllTrim(cPatchOri)+cEraseFile,.F.,.T.)
							MsgStop('Falha ao remover a pasta ')
						EndIf
					EndIf
				Else
					MsgStop('Falha ao remover a pasta '+AllTrim(cPatchOri)+cEraseFile+CHR(13)+cValtoChar(nErro))
				EndIf
			EndIf
		Else
			If !DirRemove(AllTrim(cPatchOri)+cEraseFile)
				nErro	:= FError()
				If nErro==118
					//MsgStop('Falha ao remover a pasta '+AllTrim(cPatchOri)+cEraseFile+CHR(13)+"Pasta nใo esta vazia!")
					If MsgYesNo("A Pasta nใo estแ vazia excluir o conteudo todo?")
						If !FWDirRemove(AllTrim(cPatchOri)+cEraseFile,.F.,.T.)
							MsgStop('Falha ao remover a pasta ')
						EndIf
					EndIf
				Else
					MsgStop('Falha ao remover a pasta '+AllTrim(cPatchOri)+cEraseFile+CHR(13)+cValtoChar(nErro))
				EndIf
			EndIf
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMaskDir   บAutor  ณTOTVS               บ Data ณ  07/Jul/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar de delete no FExplorer.                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MaskDir

	Local oDlMask,oGetMask

	cMaskArq := Padr(cMaskArq,60)

	DEFINE MSDIALOG oDlMask TITLE "Informe a mascara de arquivos." FROM 0,0 TO 30,230 PIXEL
	@ 02,02 MSGET oGetMask VAR cMaskArq PICTURE "@!" PIXEL SIZE 70,009 VALID Len(AllTrim(cMaskArq)) >= 1 //.And. "." $ cMaskArq
	@ 02,75 BUTTON "Ok" SIZE 037,012 PIXEL OF oDlMask Action oDlMask:End()
	ACTIVATE MSDIALOG oDlMask CENTERED //VALID Len(AllTrim(cMaskArq)) >= 3 .And. "." $ cMaskArq

	cMaskArq := AllTrim(cMaskArq)

Return

Static Function CriarPasta(cDestino,oSrv,lEnviar)

	Local oDlg,oGet
	Local lOk	:= .F.

	Local cPasta	:= Space(100)

	DEFINE MSDIALOG oDlg TITLE "Informe Nome da pasta" FROM 0,0 TO 30,230 PIXEL
	@ 02,02 MSGET oGet VAR cPasta  PIXEL SIZE 70,009 VALID Len(AllTrim(cPasta)) >= 1 //.And. "." $ cMaskArq
	@ 02,75 BUTTON "Ok" SIZE 037,012 PIXEL OF oDlg Action (lOk:=.T.,oDlg:End())
	ACTIVATE MSDIALOG oDlg CENTERED //VALID Len(AllTrim(cMaskArq)) >= 3 .And. "." $ cMaskArq
	If !lOk
		Return .F.
	EndIf

	If ValType(oSrv)<>"U" .AND. lEnviar	//Se enviando para servidor remoto
		If !oSrv:CallProc("File",Rtrim(cDestino)+cPasta)
			oSrv:CallProc("MakeDir",Rtrim(cDestino)+cPasta)
			cDestino	:= Rtrim(cDestino)+Rtrim(cPasta)+"\"+space(200)
		Else
			MsgAlert("Pasta jแ existi!")
			Return .F.
		EndIf
	Else
		If !File(Rtrim(cDestino)+cPasta)
			MakeDir(Rtrim(cDestino)+cPasta)
			cDestino	:= Rtrim(cDestino)+Rtrim(cPasta)+"\"+space(200)
		Else
			MsgAlert("Pasta jแ existi!")
			Return .F.
		EndIf
	EndIf

Return .T.

Static Function CopyRPC(oSrv,cSource,cTarget)
	Local cNome		:= ""
	Local cExtensao	:= ""
	SplitPath(cSource,"","",@cNome,@cExtensao)
	Default cTarget	:= "\temp\"+cNome+cExtensao
	cTarget	+= cNome+cExtensao
	nHdlWrite	:= FCREATE(cTarget)

	If nHdlWrite<=0
		Alert("Problema ao ler arquivo de destino!")
		Return
	EndIf

	nHdlRead := oSrv:CallProc("FOpen",cSource,,)
	If nHdlRead<=0
		Alert("Problema ao ler arquivo de origem!")
		Return
	EndIf
	nSize := oSrv:CallProc("FSeek",nHdlRead,0,2)
	oSrv:CallProc("FSeek",nHdlRead,0,0)
	While oSrv:CallProc("FSeek",nHdlRead,0,1) < nSize
		cBuffer := oSrv:CallProc("FReadStr",nHdlRead,524288)
		FWrite(nHdlWrite,cBuffer)
	EndDo
	FClose(nHdlWrite)
	oSrv:CallProc("FClose",nHdlRead)
Return

Static Function SendRPC(oSrv,cSource,cTarget)
	Local cNome		:= ""
	Local cExtensao	:= ""
	SplitPath(cSource,"","",@cNome,@cExtensao)
	Default cTarget	:= "\temp\"+cNome+cExtensao
	cTarget	+= cNome+cExtensao
	nHdlWrite	:= oSrv:CallProc("FCREATE",cTarget)

	If nHdlWrite<=0
		Alert("Problema ao ler arquivo de destino!")
		Return
	EndIf

	nHdlRead := FOpen(cSource,,)
	If nHdlRead<=0
		Alert("Problema ao ler arquivo de origem!")
		Return
	EndIf
	nSize := FSeek(nHdlRead,0,2)
	FSeek(nHdlRead,0,0)
	While FSeek(nHdlRead,0,1) < nSize
		cBuffer := FReadStr(nHdlRead,1024)
		oSrv:CallProc("FWrite",nHdlWrite,cBuffer)
	EndDo
	oSrv:CallProc("FClose",nHdlWrite)
	FClose(nHdlRead)
Return

Static Function LenCond(aArray,bCond)
	Local nTam	:= 0
	aEval(aArray,{|z| If(Eval(bCond,z),nTam++,nil)})
Return nTam

Static Function CssbtnImg(cImg)
cRet	:= " QPushButton{ background-image: url(rpo:"+cImg+")"+;
    						" ;background-position: top center "+;
                            " ;background-repeat: none; margin: 0px "+;
                            " ;text-align: bottom center "+;
                            "}"
Return cRet

Class yFstRpc
	Data oRpc
	Method new()
	Method Connect()
	Method Disconnect()
	Method CallProc()
EndClass


Method New(cEnvi) Class yFstRpc
	::oRpc	:= TRPC():New( AllTrim(cEnvi) )
Return self

Method Connect(cServer,nPort) Class yFstRpc
Return ::oRpc:Connect(cServer,nPort)

Method Disconnect() Class yFstRpc
Return ::oRpc:Disconnect()

Method CallProc(cProcedure,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) Class yFstRpc
	Local xRetorno
	Local oErro := ErrorBlock({|e| MsgAlert("Problema no servidor remoto: " +chr(10)+ e:Description) })
	BEGIN SEQUENCE
	xRetorno	:= ::oRpc:CallProc(cProcedure,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
	RECOVER
	xRetorno	:= {}
	END SEQUENCE
	ErrorBlock(oErro)
Return xRetorno