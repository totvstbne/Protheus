#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} RSERA001
Valida�ao do or�amento, utilizado no campo D1_YORCSRV
@author Saulo Gomes Martins
@since 07/08/2018
@version 1.0
@return lRet, Se codigo � valido
@param cCodOrc, characters, Codigo do or�amento
@type function
/*/
user function RSERA001(cCodOrc)
	TFJ->(DbSetOrder(1))	//TFJ_FILIAL+TFJ_CODIGO
	If TFJ->(!DbSeek(xFilial("TFJ")+cCodOrc))
		Aviso("RSERA001","Or�amento informado n�o existe!",{"OK"})
		Return .F.
	EndIf
	If Empty(TFJ->TFJ_CONTRT)
		Aviso("RSERA001","Or�amento n�o possui contrato!",{"OK"})
		Return .F.
	EndIf
	//CN9 - Contratos
	//CN9_SITUAC: 01=Cancelado;02=Elabora��o;03=Emitido;04=Aprova��o;05=Vigente;06=Paralisa.;07=Sol. Finaliza��o;08=Finali.;09=Revis�o;10=Revisado
	If Posicione("CN9",1,xFilial("CN9")+TFJ->TFJ_CONTRT+TFJ->TFJ_CONREV,"CN9_SITUAC") != '05'
		Aviso("RSERA001","Contrato desse or�amento n�o est� vigente!",{"OK"})
		Return .F.
	EndIf
return .T.

/*/{Protheus.doc} RSERA01A
Valida��o do local de atendimento, utilizado no campo D1_YLOCATE
@author Saulo Gomes Martins
@since 07/08/2018
@version 1.0
@return lRet, Se o local � valido
@param cCodOrc, characters, Codigo do or�amento
@param cLocal, characters, Codigo do local
@type function
/*/
user function RSERA01A(cCodOrc,cLocal)
	Local cQry,cAliasQry
	TFJ->(DbSetOrder(1))	//TFJ_FILIAL+TFJ_CODIGO
	If TFJ->(!DbSeek(xFilial("TFJ")+cCodOrc))
		Aviso("RSERA01A","Or�amento informado n�o existe!",{"OK"})
		Return .F.
	EndIf
	cQry	:= " SELECT "
	cQry	+= " ABS_FILIAL, "
	cQry	+= " TFL_CODIGO,"
	cQry	+= " ABS_LOCAL, "
	cQry	+= " ABS_DESCRI, "
	cQry	+= " TFL_DTINI,"
	cQry	+= " TFL_DTFIM,"
	cQry	+= " TFL_TOTRH,"
	cQry	+= " TFL_TOTMI,"
	cQry	+= " TFL_TOTMC,"
	cQry	+= " TFL_TOTLE"
	cQry	+= " FROM " + RetSqlName("ABS") + " ABS "		//Locais de Atendimento
	cQry	+= " INNER JOIN " + RetSqlName("TFL") + " TFL "	//Orcamento Servicos x Proposta
	cQry	+= " ON TFL.TFL_FILIAL = '" +   xFilial('TFL') + "'"
	cQry	+= " AND TFL.TFL_LOCAL = ABS.ABS_LOCAL "
	cQry	+= " AND TFL.D_E_L_E_T_ = ' '"
	cQry	+= " AND TFL_CODPAI =  '" + cCodOrc  + "'"
	cQry	+= " WHERE ABS_FILIAL = '" +  xFilial('ABS') + "'"
	cQry	+= " AND TFL_CODIGO =  '" + cLocal  + "'"
	cQry	+= " AND ABS.D_E_L_E_T_ = ' '"
	cAliasQry	:= MPSysOpenQuery(cQry)
	If (cAliasQry)->(EOF())
		Aviso("RSERA01A","Local n�o existe ou n�o perternce a esse or�amento!",{"OK"})
		Return .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return .T.

Static cItem := ""

/*/{Protheus.doc} RSERA01B
Consulta especifica locais de atendimento
@author Saulo Gomes Martins
@since 06/08/2018
@version 1.0
@return lRet, Se confirmou a tela .T.
@param cCodOrc, characters, Codigo do or�amento
@type function
/*/
user function RSERA01B(cCodOrc)
	Local lRet			:= .F.
	Local oBrowse		:= Nil
	Local cAls			:= GetNextAlias()
	Local nSuperior		:= 0
	Local nEsquerda		:= 0
	Local nInferior		:= 0
	Local nDireita		:= 0
	Local oDlgTela		:= Nil
	Local cQry			:= ""
	Local aIndex		:= {"ABS_LOCAL"}	//Defini��o do �ndice da Consulta Padr�o
	Local aSeek			:= {{ "Local de atendimento", {{"Local","C",TamSx3('TFL_CODIGO')[1],0,"",,}} }}	//Defini��o da Descri��o da Chave de Pesquisa da Consulta Padr�o
	Local cRet			:= ""
	Local cCodTFL		:= ""

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
	cQry += " AND TFL.D_E_L_E_T_ = ' '"
	cQry += " AND TFL_CODPAI =  '" + cCodOrc  + "'"
	cQry += " WHERE ABS_FILIAL = '" +  xFilial('ABS') + "'"
	cQry += " AND ABS.D_E_L_E_T_ = ' '"

	nSuperior := 0
	nEsquerda := 0
	nInferior := 460
	nDireita  := 800

	DEFINE MSDIALOG oDlgTela TITLE "Locais de Atendimento" FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription("Locais de Atendimento")
	oBrowse:SetAlias(cAls)
	oBrowse:SetDataQuery()
	oBrowse:SetQuery(cQry)
	oBrowse:SetOwner(oDlgTela)
	oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->TFL_CODIGO,  , lRet := .T., oDlgTela:End()})
	oBrowse:AddButton( OemTOAnsi("Confirmar"), {|| cRet := (oBrowse:Alias())->TFL_CODIGO,  lRet := .T., oDlgTela:End()},, 2 )
	oBrowse:AddButton( OemTOAnsi("Cancelar"),  {|| cRet := "", oDlgTela:End()} ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(,aSeek)

	ADD COLUMN oColumn DATA { ||  ABS_FILIAL } TITLE "Filial" SIZE TamSx3('ABS_FILIAL')[1] OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_CODIGO } TITLE "C�digo" SIZE TamSx3('TFL_CODIGO')[1] OF oBrowse
	ADD COLUMN oColumn DATA { ||  ABS_LOCAL  } TITLE "Local" SIZE TamSx3('ABS_LOCAL')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  ABS_DESCRI } TITLE "Descri��o" SIZE TamSx3('ABS_DESCRI')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_DTINI } TITLE "Dt Ini" SIZE TamSx3('TFL_DTINI')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_DTFIM } TITLE "Dt Fim" SIZE TamSx3('TFL_DTFIM')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_TOTRH } TITLE "Total RH" SIZE TamSx3('TFL_TOTRH')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_TOTMI } TITLE "Total MI" SIZE TamSx3('TFL_TOTMI')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_TOTMC } TITLE "Total MC" SIZE TamSx3('TFL_TOTMC')[1]  OF oBrowse
	ADD COLUMN oColumn DATA { ||  TFL_TOTLE } TITLE "Total LE" SIZE TamSx3('TFL_TOTLE')[1]  OF oBrowse

	If !IsBlind()
		oBrowse:Activate()
		ACTIVATE MSDIALOG oDlgTela CENTERED
	EndIf
	If lRet
		cItem := cRet
	EndIf
Return lRet

/*/{Protheus.doc} At995RetIt
Retorno Consulta especifica
@author Saulo Gomes Martins
@since 06/08/2018
@version 1.0
@return cItem, Retorno

@type function
/*/
User Function RSERA01C()
Return cItem

/*/{Protheus.doc} RSERA01D
Consulta especifica dos produtos
@author Saulo Gomes Martins
@since 07/08/2018
@version 1.0
@return lRet, Confirmou tela
@param cCodOrc, characters, Codigo do or�amento
@param cLocal, characters, Codigo do local de atendimento
@param cTipo, characters, Tipo de produto 2=MI;3=MC
@type function
/*/
User Function RSERA01D(cCodOrc,cLocal,cTipo)
	Local lRet			:= .F.
	Local oBrowse		:= Nil
	Local cAls			:= GetNextAlias()
	Local nSuperior		:= 0
	Local nEsquerda		:= 0
	Local nInferior		:= 0
	Local nDireita		:= 0
	Local oDlgTela		:= Nil
	Local cQry			:= ""
	Local aIndex		:= {"TFG_PRODUT"}	//Defini��o do �ndice da Consulta Padr�o
	Local aSeek			:= {{ "Produtos", {{"Produto","C",TamSx3("TFG_PRODUT")[1],0,"",,}} }}	//Defini��o da Descri��o da Chave de Pesquisa da Consulta Padr�o
	Local cProd			:= ""
	Local cRet			:= ""

	If cTipo=="3"
		aIndex := {"TFH_PRODUT"}
		aSeek := {{ "Produtos", {{"Produto","C",TamSx3("TFH_PRODUT")[1],0,"",,}} }}
	EndIf
	cQry	:= QryProd(cCodOrc,cLocal,cTipo,)
	nSuperior := 0
	nEsquerda := 0
	nInferior := 460
	nDireita  := 800

	DEFINE MSDIALOG oDlgTela TITLE "Produto" FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription("Produtos")
	oBrowse:SetAlias(cAls)
	oBrowse:SetDataQuery()
	oBrowse:SetQuery(cQry)
	oBrowse:SetOwner(oDlgTela)
	oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->COD,  , lRet := .T., oDlgTela:End()})
	oBrowse:AddButton( OemTOAnsi("Confirmar"), {|| cRet := (oBrowse:Alias())->COD, lRet := .T., oDlgTela:End()},, 2 )
	oBrowse:AddButton( OemTOAnsi("Cancelar"),  {|| cRet := "", oDlgTela:End()} ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(,aSeek)

	ADD COLUMN oColumn DATA { ||  FILIAL }	TITLE "Filial"		SIZE TamSx3('TFG_FILIAL')[1]	OF oBrowse
	ADD COLUMN oColumn DATA { ||  COD }		TITLE "C�digo"		SIZE TamSx3('TFG_COD')[1]		OF oBrowse
	ADD COLUMN oColumn DATA { ||  PRODUT }	TITLE "Produto"		SIZE TamSx3('TFG_PRODUT')[1]	OF oBrowse
	ADD COLUMN oColumn DATA { ||  B1_DESC }	TITLE "Descri��o"	SIZE TamSx3('B1_DESC')[1]		OF oBrowse
	ADD COLUMN oColumn DATA { ||  QTDVEN }	TITLE "Quantidade"	SIZE TamSx3('TFG_QTDVEN')[1]	OF oBrowse
	ADD COLUMN oColumn DATA { ||  SLD }		TITLE "Saldo"		SIZE TamSx3('TFG_SLD')[1]		OF oBrowse
	ADD COLUMN oColumn DATA { ||  PERINI }	TITLE "Per ini"		SIZE TamSx3('TFG_PERINI')[1]	OF oBrowse
	ADD COLUMN oColumn DATA { ||  PERFIM }	TITLE "Per fim"		SIZE TamSx3('TFG_PERFIM')[1]	OF oBrowse

	If !IsBlind()
		oBrowse:Activate()
		ACTIVATE MSDIALOG oDlgTela CENTERED
	EndIf
	If lRet
		cItem := cRet
	EndIf

Return lRet

/*/{Protheus.doc} RSERA01E
Valida��o do produto no or�amento
@author Saulo Gomes Martins
@since 07/08/2018
@version 1.0
@return lRet, se o produto � valido
@param cCodOrc, characters, Codigo do or�amento
@param cLocal, characters, Codigo do local de atendimento
@param cTipo, characters, Tipo de produto 2=MI;3=MC
@param cCodigo, characters, Codigo do produto no or�amento
@type function
/*/
User Function RSERA01E(cCodOrc,cLocal,cTipo,cCodigo)
	Local cQry,cAliasQry
	If Empty(cCodOrc)
		Aviso("RSERA01E","Necessario preencher o campo C�digo do Or�amento!",{"OK"})
		Return .F.
	ElseIf Empty(cLocal)
		Aviso("RSERA01E","Necessario preencher o campo Local de Atendimento!",{"OK"})
		Return .F.
	ElseIf Empty(cTipo)
		Aviso("RSERA01E","Necessario preencher o campo tipo de c�digo!",{"OK"})
		Return .F.
	ElseIf Empty(cCodigo)
		Return .T.
	EndIf
	cQry		:= QryProd(cCodOrc,cLocal,cTipo,cCodigo)
	cAliasQry	:= MPSysOpenQuery(cQry)
	If (cAliasQry)->(EOF())
		Aviso("RSERA001","Item n�o existe ou n�o perternce a esse or�amento!",{"OK"})
		(cAliasQry)->(DbCloseArea())
		Return .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return .T.

/*/{Protheus.doc} RSERA01F
Retorna a descri��o do produto
@author Saulo Gomes Martins
@since 07/08/2018
@version 1.0
@return cRet, descri��o do produto
@param cCodOrc, characters, Codigo do or�amento
@param cLocal, characters, Codigo do local de atendimento
@param cTipo, characters, Tipo de produto 2=MI;3=MC
@param cCodigo, characters, Codigo do produto no or�amento
@type function
/*/
User Function RSERA01F(cCodOrc,cLocal,cTipo,cCodigo)
	Local cQry,cAliasQry
	Local cRet	:= ""
	cQry	:= QryProd(cCodOrc,cLocal,cTipo,cCodigo)
	cAliasQry	:= MPSysOpenQuery(cQry)
	If (cAliasQry)->(!EOF())
		cRet	:= (cAliasQry)->B1_DESC
	EndIf
	(cAliasQry)->(DbCloseArea())
Return cRet

/*/{Protheus.doc} QryProd
Monta query para os produtos do or�amento
@author Saulo Gomes Martins
@since 07/08/2018
@version 1.0
@return cQry, String com a query para consulta no banco
@param cCodOrc, characters, Codigo do or�amento
@param cLocal, characters, Codigo do local de atendimento
@param cTipo, characters, Tipo de produto 2=MI;3=MC
@param [cCodigo], characters, Codigo do produto no or�amento
@type function
/*/
Static Function QryProd(cCodOrc,cLocal,cTipo,cCodigo)
	Local cQry
	Local cCodTab		:= POSICIONE("TFJ",1,xFilial("TFJ")+cCodOrc,"TFJ_CODTAB")	//Orcamento de Servicos:Numero da tabela
	If cTipo=="2"	//Material de implanta��o
		cQry := " SELECT TFG_FILIAL FILIAL, TFG_COD COD, TFG_PRODUT PRODUT, B1_DESC ,TFG_QTDVEN QTDVEN, TFG_SLD SLD,TFG_PERINI PERINI,TFG_PERFIM PERFIM "+;
				" FROM " + RetSqlName("TFG") +  " TFG "+;			//MATERIAIS DE IMPLANTA��O
				" INNER JOIN "  + RetSqlName("TFL") + " TFL "  +;	//Or�amento Servi�os x Proposta
				" ON TFL.TFL_FILIAL = '" +  xFilial('TFL') + "'"+;
				" AND TFL.TFL_CODPAI = '" + cCodOrc + "'"+;
				" AND TFL.TFL_CODIGO = '" + cLocal + "'"+;
				" AND TFL.D_E_L_E_T_ = ' '"
		If !Empty(cCodTab)
			cQry += " AND TFG.TFG_CODPAI = TFL.TFL_CODIGO "
		Else
			cQry += "  INNER JOIN " + RetSqlName("TFF") + " TFF ON TFF.TFF_FILIAL = '" + xFilial('TFF') + "'" + " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO"	//RECURSOS HUMANOS
			cQry += "  AND TFG.TFG_CODPAI = TFF.TFF_COD"
			cQry += "  AND TFF.D_E_L_E_T_=' ' "
		EndIf
		cQry += "  INNER JOIN " +   RetSqlName("SB1") + " SB1 "+;
				" ON SB1.B1_FILIAL = '" +  xFilial('SB1') + "'"+;		//CADASTRO DE PRODUTO
				" AND SB1.B1_COD = TFG.TFG_PRODUT "+;
				" AND SB1.D_E_L_E_T_ = ' '"+;
				" WHERE TFG.TFG_FILIAL = '"  + xFilial('TFG') + "'"+;
				" AND TFG.D_E_L_E_T_ = ' '"
		If ValType(cCodigo)=="C"
			cQry += " AND TFG_COD='"+cCodigo+"' "
		EndIf
	Else			//Material de consumo
		cQry := " SELECT TFH_FILIAL FILIAL, TFH_COD COD, TFF_PRODUT PRODUT, B1_DESC ,TFH_QTDVEN QTDVEN, TFH_SLD SLD,TFH_PERINI PERINI,TFH_PERFIM PERFIM "+;
				" FROM " + RetSqlName("TFH") +  " TFH " +;				//MATERIAIS DE CONSUMO
				" INNER JOIN "  + RetSqlName("TFL") + " TFL "  +;		//Or�amento Servi�os x Proposta
				" ON TFL.TFL_FILIAL = '" +  xFilial('TFL') + "'" +;
				" AND TFL.TFL_CODPAI = '" + cCodOrc + "'" +;
				" AND TFL.TFL_CODIGO = '" + cLocal + "'" +;
				" AND TFL.D_E_L_E_T_ = ' '"
		If !Empty(cCodTab)
			cQry += " AND TFH.TFH_CODPAI = TFL.TFL_CODIGO "
		Else
			cQry += "  INNER JOIN " + RetSqlName("TFF") + " TFF ON TFF.TFF_FILIAL = '" + xFilial('TFF') + "'" + " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO"	//RECURSOS HUMANOS
			cQry += "  AND TFH.TFH_CODPAI = TFF.TFF_COD"
			cQry += "  AND TFF.D_E_L_E_T_=' ' "
		EndIf
		cQry += " INNER JOIN " +   RetSqlName("SB1") + " SB1 " +;		//CADASTRO DE PRODUTO
				" ON SB1.B1_FILIAL = '" +  xFilial('SB1') + "'" +;
				" AND SB1.B1_COD = TFF.TFF_PRODUT " +;
				" AND SB1.D_E_L_E_T_ = ' '" +;
				" WHERE TFH.TFH_FILIAL = '"  + xFilial('TFH') + "'" +;
				" AND TFF.TFF_FILIAL = '"  + xFilial('TFF') + "'" +;
				" AND TFH.D_E_L_E_T_ = ' '"
		If ValType(cCodigo)=="C"
			cQry += " AND TFH_COD='"+cCodigo+"' "
		EndIf
	EndIf
Return cQry