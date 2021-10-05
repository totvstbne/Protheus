#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "fwbrowse.ch"

/*/{Protheus.doc} SRVCSTCT
//TODO Descrição auto-gerada.
@author Levy
@since 29/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

user function SRVCSTCT()
	local oDlg
	local aCoord := FwGetDialogSize( oMainWnd ) ////Array de coordenadas { nTop, nLeft, nBottom, nRight }.
	local cQuery, oColumn
	local aParam := {}
	local bOk := {|| .T. }
	Local oLinha
	Local aRet := {}
	Local oBrowse
	Private dDataIni, cEmpIni, cEmpFim, cMatIni, cMatFim, cCtrIni, cCtrFim, cLocIni, cLocFim, cNome

	aAdd(aParam,{1,"Empresa de", "010101","@E","","SM0",".T.",70,.T.})
	aAdd(aParam,{1,"Empresa até", "010101","@E","","SM0",".T.",70,.T.})
	aAdd(aParam,{1,"Contrato de ", Space(TamSX3("CN9_NUMERO")[1]),"@C","","CN9",".T.",70,.F.})
	aAdd(aParam,{1,"Contrato até ", Space(TamSX3("CN9_NUMERO")[1]),"@C","","CN9",".T.",70,.F.})
	aAdd(aParam,{1,"Local de ", Space(TamSX3("ABS_LOCAL")[1]),"@C","","ABS",".T.",70,.F.})
	aAdd(aParam,{1,"Local até ", Space(TamSX3("ABS_LOCAL")[1]),"@C","","ABS",".T.",70,.F.})
	aAdd(aParam,{1,"Matricula de ", Space(TamSX3("RA_MAT")[1]),"@C","","SRA",".T.",70,.F.})
	aAdd(aParam,{1,"Matricula até ", Space(TamSX3("RA_MAT")[1]),"@C","","SRA",".T.",70,.F.})
	aAdd(aParam,{1,"Nome ", Space(TamSX3("RA_NOME")[1]),"@C","","",".T.",100,.F.})
	aAdd(aParam,{1,"Data ", dDataBase,"@D","","",".T.",70,.F.})
	
	If !ParamBox(aParam,"",@aRet,bOk,,,,,,"SRVCSTCT",.T.,.T.)
		Return
	Else
		cEmpIni := aRet[1]
		cEmpFim := aRet[2]
		cCtrIni := aRet[3]
		cCtrFim := aRet[4]
		cLocIni := aRet[5]
		cLocFim := aRet[6]
		cMatIni := aRet[7]
		cMatFim := aRet[8]
		cNome := aRet[9]
		dDataIni := aRet[10]
	EndIf
	
	oDlg := MSDialog():New(aCoord[1], aCoord[2], aCoord[3], aCoord[4], "Tabela de CCs",,,,,CLR_BLACK,RGB(0,0,0),,,.T.)
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )
	oFWLayer:addLine("LIN1", 100, .F.) //nome, porcent da tela e se a linha e fixa
	oLinha := oFWLayer:getLinePanel("LIN1")
	
	cQuery := RetQry()
	oBrowse := FWBrowse():New(oLinha)
	oBrowse:setDataQuery(.T.)
	oBrowse:setQuery(cQuery)
	oBrowse:setAlias("TMPA")
	oBrowse:setLocate()
	oBrowse:setDescription("Lista de CCs")
	oBrowse:setProfileID("TMPGS_A")
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->RA_FILIAL) } TITLE "Filial" SIZE 5 OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->TFL_CONTRT ) } TITLE "Contrato" SIZE 12 OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->TFL_LOCAL ) } TITLE "Local" SIZE 20 OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->ABS_DESCRI) } TITLE "Descricao" SIZE 60 OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->RA_MAT) } TITLE "Matricula" SIZE 10 OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->RA_NOME) } TITLE "Nome" SIZE 35 OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->TFL_YCC ) } TITLE "CC" SIZE tamSX3("CTT_CUSTO")[1] OF oBrowse
	ADD COLUMN oColumn DATA { || RTRIM(TMPA->CTT_DESC01 ) } TITLE "Descricao" SIZE 60 OF oBrowse
//	oBrowse:disableConfig()
//	oBrowse:disableReport()
	oBrowse:setDoubleClick({|oBrowse| cliqueCC(oBrowse) })
	oBrowse:setOwner(oLinha)
	oBrowse:setFocus()
	oBrowse:Activate()
	oDlg:Activate(,,,.T.,{||  },, )
return


static function cliqueCC(oBrowse)
	Local cEmpBw, cCtrBw, cLocBw, cDecBw, cMatBw, cNomeBw, cCCBw, cCTTBw
	Local aRet := {}
	local bOk := {|| .T. }
	Local aParam := {}
	
	aAdd(aParam,{1,"Filial", (oBrowse:oData:cAlias)->RA_FILIAL,"@C","","",".T.",130,})
	aAdd(aParam,{1,"Contrato", (oBrowse:oData:cAlias)->TFL_CONTRT,"@C","","",".T.",130,})
	aAdd(aParam,{1,"Local", (oBrowse:oData:cAlias)->TFL_LOCAL,"@C","","",".T.",130,})
	aAdd(aParam,{1,"Descrição ", (oBrowse:oData:cAlias)->ABS_DESCRI,"@C","","",".T.",130,})
	aAdd(aParam,{1,"Matricula", (oBrowse:oData:cAlias)->RA_MAT,"@C","","",".T.",130,})
	aAdd(aParam,{1,"Nome", (oBrowse:oData:cAlias)->RA_NOME,"@C","","",".T.",130,})
	aAdd(aParam,{1,"CC", (oBrowse:oData:cAlias)->TFL_YCC,"@C","","",".T.",130,})
	aAdd(aParam,{1,"Descrição", (oBrowse:oData:cAlias)->CTT_DESC01,"@C","","",".T.",130,})
	ParamBox(aParam,"",@aRet,bOk,,,,,,"CC",,)
return 

static function RetQry()
	Local cQuery := ""
	
	if !empty(cNome) .or. !empty(cMatIni) .or. !empty(cMatFim) 
		cQuery := "SELECT DISTINCT SRA.RA_FILIAL, TFL.TFL_CONTRT, SRA.RA_MAT, SRA.RA_NOME, TFL.TFL_LOCAL, ABS_DESCRI, TFL_YCC, CTT.CTT_DESC01 "
	else
		cQuery := "SELECT DISTINCT SRA.RA_FILIAL, TFL.TFL_CONTRT, '-' AS RA_MAT, '-' AS RA_NOME, TFL.TFL_LOCAL, ABS_DESCRI, TFL_YCC, CTT.CTT_DESC01 "
	endIf
	cQuery += "FROM "+RETSQLNAME('SRA')+ " SRA "
	cQuery += "JOIN "+RETSQLNAME('ABB')+" ABB ON "
	cQuery += "ABB.ABB_CODTEC = SRA.RA_FILIAL || SRA.RA_MAT AND ABB.D_E_L_E_T_ = ' ' AND ABB.ABB_FILIAL = SRA.RA_FILIAL "
	cQuery += "JOIN "+RETSQLNAME('TFL')+" TFL ON "
	cQuery += "TFL.TFL_CONTRT = SUBSTRING(ABB.ABB_IDCFAL, 1, 15) AND TFL.TFL_LOCAL = ABB.ABB_LOCAL AND TFL.D_E_L_E_T_ = ' ' AND TFL.TFL_FILIAL = SRA.RA_FILIAL "
	cQuery += "JOIN "+RETSQLNAME('ABS')+" ABS ON "
	cQuery += "ABS.ABS_LOCAL = TFL.TFL_LOCAL AND ABS.D_E_L_E_T_ = ' ' "
	cQuery += "JOIN "+RETSQLNAME('CTT')+" CTT ON "
	cQuery += "CTT.CTT_CUSTO = TFL.TFL_YCC AND CTT.CTT_FILIAL = SUBSTRING(SRA.RA_FILIAL, 1, 2) AND CTT.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SRA.RA_FILIAL BETWEEN '"+cEmpIni+"' AND '"+cEmpFim+"' AND SRA.D_E_L_E_T_ = ' ' " 
	
	if !Empty(cMatIni) .and. !Empty(cMatFim)
		cQuery += "AND SRA.RA_MAT BETWEEN '"+cMatIni+"' AND '"+cMatFim+"' "
	endIf
	if !Empty(cLocIni) .and. !Empty(cLocFim)
		cQuery += "AND TFL.TFL_LOCAL BETWEEN '"+cLocIni+"' AND '"+cLocFim+"' "
	endIf
	if !Empty(cCtrIni) .and. !Empty(cCtrFim)
		cQuery += "AND TFL.TFL_CONTRT BETWEEN '"+cCtrIni+"' AND '"+cCtrFim+"' "
	endIf
	
	if !Empty(cNome) 
		cQuery += "AND SRA.RA_NOME LIKE '%"+RTRIM(cNome)+"%' "
	endIf
	
	cQuery += "AND ABB_DTFIM = '"+DtoS(dDataIni)+" '
	cQuery += "ORDER BY RA_FILIAL"
	cQuery := ChangeQuery(cQuery)
return cQuery