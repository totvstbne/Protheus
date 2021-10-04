#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'

/*/{Protheus.doc} RSVNA003
Consulta dos cancelamentos
@author Diogo
@since 05/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User function RSVNA003()
	public cRotCust:= "RSVNA003" 
	cAliasCAN := GetNextAlias()
	oTmpCan	:= FWTemporaryTable():New(cAliasCAN)

	cAliasRen := GetNextAlias()
	oTmpRen	:= FWTemporaryTable():New(cAliasRen)
	
	fBrowsRegs()
	
	oTmpCan:delete()
	oTmpRen:delete()
Return
	
Static Function fBrowsRegs

Local aCoors  := FWGetDialogSize( oMainWnd )
Local aStru:= {}
Local aSRen:= {}
Local aCpos:= {}
Local aCRen:= {}
Private oDlg


Define MsDialog oDlg Title 'Consulta dos Contratos' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )

	oFWLayer:addLine( '1', 50, .F. )
	oFWLayer:addLine( '2', 50, .F. )

	oPanel1 := oFWLayer:getLinePanel( '1' )
	oPanel2 := oFWLayer:getLinePanel( '2' )

//Estrutura da tabela temporaria
Aadd(aStru,{"FILIAL","C",40,0})
Aadd(aCpos,{"Filial",aStru[len(aStru)][1],,,1,40})

Aadd(aStru,{"CONTRATO","C",TamSx3("CN9_NUMERO")[1],0})
Aadd(aCpos,{"Contrato",aStru[len(aStru)][1],,,1,TamSx3("CN9_NUMERO")[1]})

Aadd(aStru,{"A1_NOME","C",TamSx3("A1_NOME")[1],0})
Aadd(aCpos,{"Cliente",aStru[len(aStru)][1],,,1,TamSx3("A1_NOME")[1]})

Aadd(aStru,{"DATAINI","C",TamSx3("CN9_DTINIC")[1]+4,0})
Aadd(aCpos,{"Data Inicial",aStru[len(aStru)][1],,,1,TamSx3("CN9_DTINIC")[1]+4})

Aadd(aStru,{"DATAFIM","C",TamSx3("CN9_DTFIM")[1]+4,0})
Aadd(aCpos,{"Data Final",aStru[len(aStru)][1],,,1,TamSx3("CN9_DTFIM")[1]+4})

Aadd(aStru,{"DATACAN","C",TamSx3("CN9_DTFIM")[1]+4,0})
Aadd(aCpos,{"Data Cancelamento",aStru[len(aStru)][1],,,1,TamSx3("CN9_DTFIM")[1]+4})

oTmpCan:SetFields(aStru)
oTmpCan:Create()

oMark	:= FWMarkBrowse():New()
oMark:SetAlias(cAliasCAN)
arotina:={}
oMark:SetDescription('Contratos Próximos do Cancelamento')
oMark:SetOwner(oDlg)
///oMark:DisableReport()
oMark:SetMenuDef("")
oMark:SetFields(aCpos)
oMark:SetProfileID('3')
oMark:Activate(oPanel1)

//Renovação
Aadd(aSRen,{"FILIAL","C",40,0})
Aadd(aCRen,{"Filial",aSRen[len(aSRen)][1],,,1,40})

Aadd(aSRen,{"CONTRATO","C",TamSx3("CN9_NUMERO")[1],0})
Aadd(aCRen,{"Contrato",aSRen[len(aSRen)][1],,,1,TamSx3("CN9_NUMERO")[1]})

Aadd(aSRen,{"A1_NOME","C",TamSx3("A1_NOME")[1],0})
Aadd(aCRen,{"Cliente",aSRen[len(aSRen)][1],,,1,TamSx3("A1_NOME")[1]})

Aadd(aSRen,{"DATAINI","C",TamSx3("CN9_DTINIC")[1]+4,0})
Aadd(aCRen,{"Data Inicial",aSRen[len(aSRen)][1],,,1,TamSx3("CN9_DTINIC")[1]+4})

Aadd(aSRen,{"DATAFIM","C",TamSx3("CN9_DTFIM")[1]+4,0})
Aadd(aCRen,{"Data Final",aSRen[len(aSRen)][1],,,1,TamSx3("CN9_DTFIM")[1]+4})

Aadd(aSRen,{"DATACAN","C",TamSx3("CN9_DTFIM")[1]+4,0})
Aadd(aCRen,{"Data Cancelamento",aSRen[len(aSRen)][1],,,1,TamSx3("CN9_DTFIM")[1]+4})

oTmpRen:SetFields(aSRen)
oTmpRen:Create()

oMarkRen:= FWMarkBrowse():New()
oMarkRen:SetAlias(cAliasRen)
arotina:={}
oMarkRen:SetDescription('Contratos Próximos da Renovação')
oMarkRen:SetOwner(oDlg)
oMarkRen:SetMenuDef("")
oMarkRen:SetFields(aCRen)
oMarkRen:SetProfileID('3')
oMarkRen:Activate(oPanel2)

fAddTmpCan() //Adiciona registros

Activate MsDialog oDlg Center
Return

/*/{Protheus.doc} fAddTmpCan
//Adicionar registros na tabela temporária
@author Diogo
@since 26/09/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fAddTmpCan
//01=Cancelado;02=Elaboracao;03=Emitido;04=Aprovacao;05=Vigente;06=Paralisa.;07=Sol. Finalizacao;08=Finalizado;09=Revisao;10=Revisado
cQuery :="SELECT CN9_FILIAL, CN9_NUMERO, CN9_DTINIC, CN9_YDTCAN, CN9_DTFIM FROM "+RetSqlName("CN9")+ " CN9 "
cQuery +="WHERE D_E_L_E_T_ = ' '  "
cQuery +="AND DATEDIFF(DD,'"+dtos(dDatabase)+"', CN9_DTFIM) <= '"+cValtochar(Supergetmv("SV_DIASCON",,30))+"' "
cQuery +="AND CN9_YRENOV <> 'S' AND CN9_YDTCAN = ' ' "
cQuery +="AND CN9_SITUAC IN ('05','06') AND CN9_REVATU = ' ' "
cQuery +="UNION ALL "
cQuery +="SELECT CN9_FILIAL, CN9_NUMERO, CN9_DTINIC, CN9_YDTCAN, CN9_DTFIM FROM "+RetSqlName("CN9")+ " CN9 "
cQuery +="WHERE D_E_L_E_T_ = ' '  "
cQuery +="AND DATEDIFF(DD,'"+dtos(dDatabase)+"', CN9_YDTCAN) <= '"+cValtochar(Supergetmv("SV_DIASCON",,30))+"' "
cQuery +="AND CN9_YRENOV <> 'S' AND CN9_YDTCAN <> ' ' "
cQuery +="AND CN9_SITUAC IN ('05','06') AND CN9_REVATU = ' ' "
cQuery +="ORDER BY CN9_FILIAL, CN9_NUMERO "
TcQuery cQuery new Alias QCAN
dbSelectArea("CNC")
CNC->(dbSetOrder(1))

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

while QCAN->(!Eof())
	
	CNC->(dbSeek(QCAN->CN9_FILIAL+QCAN->CN9_NUMERO))
	SA1->(dbSeek(xFilial("SA1")+CNC->(CNC_CLIENT+CNC_LOJACL)))

	Reclock(cAliasCAN,.t.)
		(cAliasCAN)->FILIAL		:= alltrim(QCAN->CN9_FILIAL)+"-"+alltrim(FWFilName(cEmpAnt,QCAN->CN9_FILIAL))
		(cAliasCAN)->CONTRATO	:= QCAN->CN9_NUMERO
		(cAliasCAN)->A1_NOME	:= SA1->A1_NOME
		(cAliasCAN)->DATAINI	:= dtoc(stod(QCAN->CN9_DTINIC))
		(cAliasCAN)->DATAFIM	:= dtoc(stod(QCAN->CN9_DTFIM))
		(cAliasCAN)->DATACAN	:= dtoc(stod(QCAN->CN9_YDTCAN))
	MsUnlock()
QCAN->(dbSkip())
Enddo
QCAN->(dbCloseArea())
(cAliasCAN)->(dbGotop())	
oMark:oBrowse:Refresh()
oMark:Refresh(.T.)


//Renovação dos contratos
cQuery :="SELECT CN9_FILIAL, CN9_NUMERO, CN9_DTINIC, CN9_DTFIM FROM "+RetSqlName("CN9")+ " CN9 "
cQuery +="WHERE D_E_L_E_T_ = ' '  "
cQuery +="AND DATEDIFF(DD,'"+dtos(dDatabase)+"', CN9_DTFIM) <= '"+cValtochar(Supergetmv("SV_DIASCON",,30))+"' "
cQuery +="AND CN9_YRENOV = 'S' "
cQuery +="AND CN9_SITUAC IN ('05','06') AND CN9_REVATU = ' ' "
cQuery +="ORDER BY CN9_FILIAL, CN9_NUMERO "

TcQuery cQuery new Alias QREN
dbSelectArea("CNC")
CNC->(dbSetOrder(1))

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

while QREN->(!Eof())
	
	CNC->(dbSeek(QREN->CN9_FILIAL+QREN->CN9_NUMERO))
	SA1->(dbSeek(xFilial("SA1")+CNC->(CNC_CLIENT+CNC_LOJACL)))
	
	Reclock(cAliasRen,.t.)
		(cAliasRen)->FILIAL		:= alltrim(QREN->CN9_FILIAL)+"-"+alltrim(FWFilName(cEmpAnt,QREN->CN9_FILIAL))
		(cAliasRen)->CONTRATO	:= QREN->CN9_NUMERO
		(cAliasRen)->A1_NOME	:= SA1->A1_NOME
		(cAliasRen)->DATAINI	:= dtoc(stod(QREN->CN9_DTINIC))
		(cAliasRen)->DATAFIM	:= dtoc(stod(QREN->CN9_DTFIM))
	MsUnlock()
QREN->(dbSkip())
Enddo
QREN->(dbCloseArea())
(cAliasRen)->(dbGotop())	
oMarkRen:oBrowse:Refresh()
oMarkRen:Refresh(.T.)
Return