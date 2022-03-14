#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE OP_LIB	"001" // Liberado
#DEFINE OP_EST	"002" // Estornar
#DEFINE OP_SUP	"003" // Superior
#DEFINE OP_TRA	"004" // Transferir Superior
#DEFINE OP_REJ	"005" // Rejeitado
#DEFINE OP_BLQ	"006" // Bloqueio
#DEFINE OP_VIW	"007" // Visualizacao


WSRESTFUL MconsultApi DESCRIPTION "Serviço REST - Mconsult"

	WSDATA query 	AS STRING
	WSDATA token 	AS String

	WSDATA login 	AS STRING
	WSDATA senha 	AS String

	WSDATA aprovacoes AS string
	/*
	WSDATA filial	AS STRING
	WSDATA num 		AS String
	WSDATA tipo		AS String
	WSDATA status	AS String
	WSDATA obs		AS String
	WSDATA aprovador AS String
	WSDATA dData 	AS Date
	*/

//WSMETHOD GET DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/scr || /scr/{id}"
	WSMETHOD GET DESCRIPTION "MconsultApi" WSSYNTAX "/MconsultApi/{query}/{token}"
	//WSMETHOD PUT DESCRIPTION "McAprovacao" WSSYNTAX "/MconsultApi/{filial}/{tipo}/{num}/{status}/{obs}/{aprovador}/{dData}"
	WSMETHOD POST DESCRIPTION "McAprovacao" WSSYNTAX "/MconsultApi"

END WSRESTFUL



WSMETHOD GET WSRECEIVE query, token WSSERVICE MconsultApi
	Local cQuery
	Local cToken
	Local nCont
	//Local aResult := {}
	// define o tipo de retorno do método
	::SetContentType("application/json")
	// verifica se recebeu parametro pela UR
	If Len(::aURLParms) > 0
		cQuery := Replace(Decode64(::aURLParms[1],,.F.),"?",">")
		cToken := ::aURLParms[2]

		//if (cToken == Upper(Md5(DtoS(Date())+"Am@ur!"+cQuery)))
		TcQuery cQuery New Alias T01

		::SetResponse('[')

		aStruct := T01->(DBSTRUCT())

		While !T01->(EOF())
			::SetResponse('{')

			For nCont := 1 To Len(aStruct)

				IF aStruct[nCont,2] == "N"
					//IF Type("aStruct[nCont,2]") == "N"
					::SetResponse('"'+aStruct[nCont,1]+'":'	+ cValToChar(T01->&(aStruct[nCont,1])))
				Else
					cValor := OEMTOANSI(Replace(NoAcento(AllTrim(T01->&(aStruct[nCont,1]))),"´"," "))
					cValor := Replace(cValor,'"','\"')
					cValor := Replace(cValor,'/','\/')
					::SetResponse('"'+aStruct[nCont,1]+'":"'+cValor+'"')
				EndIF
				if nCont < Len(aStruct)
					::SetResponse(",")
				EndIF

			Next
			::SetResponse('}')
			T01->(DbSkip())

			IF !T01->(Eof())
				::SetResponse(",")
			EndIF
		EndDo
		::SetResponse(']')

		T01->(DbCloseArea())
		//EndIF
	EndIf
Return .T.


WSMETHOD POST WSRECEIVE aprovacoes WSSERVICE MconsultApi
	Local cJsonObj      := "JsonObject():New()"
	Local cAprovacoes	:= ::GetContent()//::aprovacoes
	Local nCont
	Local cStatus
	Private oAprov    	:= &cJsonObj

	::SetContentType("application/json")

	oAprov:FromJson(cAprovacoes)
	ConOut('iniciando APROVAÇÃO')
	if ValType(oAprov) == "C"
		::SetResponse("Falha ao transformar texto em objeto json. Erro: " + oAprov)
		::SetResponse(cAprovacoes)
	EndIF

	//BeginTran()
	cRet := "["
	For nCont := 1 To Len(oAprov)
		// verifica se recebeu parametro pela UR
		cFilAnt		:= oAprov[nCont]:GetJsonText("Filial")
		dDataBase	:= StoD(oAprov[nCont]:GetJsonText("Data"))
		cStatus		:= oAprov[nCont]:GetJsonText("Status")
		lOK			:= .T.
		IF AllTrim(oAprov[nCont]:GetJsonText("Tipo")) == "CP"
			ConOut('iniciando APROVAÇÃO CP')
			DbSelectArea("SE2")
			DbSetOrder(1)
			IF DbSeek(AllTrim(oAprov[nCont]:GetJsonText("Chave")))
				RecLock("SE2",.F.)
				SE2->E2_DATALIB	:= dDataBase
				MsUnLock()
				//cRet := '{"processado":true}'
				ConOut('APROVAÇÃO CP '+AllTrim(oAprov[nCont]:GetJsonText("Chave")))
				oAprov[nCont]["Ok"] := .T.
			Else
				oAprov[nCont]["Ok"] := .F.
				oAprov[nCont]["Erro"] := "Título não encontrado"
				lOK	:= .F.
				//cRet := '{"processado":false, "erro":"Título não encontrado"}'
			EndIF
		Else
			cCR_NUM		:= oAprov[nCont]:GetJsonText("Chave")
			cCR_TIPO	:= oAprov[nCont]:GetJsonText("Tipo")
			cCR_OBS		:= oAprov[nCont]:GetJsonText("Obs")
			cCR_APROV	:= oAprov[nCont]:GetJsonText("CodAprovador")
			//cCR_GRUPO	:= SCR->CR_GRUPO//oModel:GetValue("FieldSCR","CR_GRUPO")
			_CAPROV := ""
			DbSelectArea("SAK")
			DbSetOrder(2)
			IF DbSeek(xFilial("SAK")+ALLTRIM(cCR_APROV))
				_CAPROV := SAK->AK_COD
			ELSE
				oAprov[nCont]["Ok"] := .F.
				oAprov[nCont]["Erro"] := "APROVADOR INVÁLIDO!"
				lOK := .F.
				ConOut('APROVADOR INVÁLIDO!')
			ENDIF

		endif
		if cCR_TIPO == "PF"
			ConOut('iniciando APROVAÇÃO PF! Aprovador - '+_CAPROV)
		ELSEIF  cCR_TIPO == "PC"
			ConOut('iniciando APROVAÇÃO PC! Aprovador - '+_CAPROV)
		ENDIF
		if cCR_TIPO == "PF"
			DbSelectArea("ZA7")
			DbSetOrder(1)
			DbSeek(xFilial("ZA7")+cCR_NUM)

			DbSelectArea("SED")
			DbSetOrder(1)
			IF !DbSeek(xFilial("SED")+ZA7->ZA7_NATURE)
				oAprov[nCont]["Ok"] := .F.
				oAprov[nCont]["Erro"] := "Natureza inválida!"
				lOK := .F.
				ConOut('Natureza inválida!')
			EndIF
		EndIF
		PswOrder(1)
		IF PswSeek(cCR_APROV, .T. )
			aUser := PswRet()
			__cUserID := cCR_APROV
			cUserName := aUser[1,2]
		Else
			oAprov[nCont]["Ok"] := .F.
			oAprov[nCont]["Erro"] := "Usuário não encontrado!"
			lOK	:= .F.
			ConOut('Usuário não encontrado!')
		EndIF
		DbSelectArea("SCR")
		DbSetOrder(2)
		IF !DbSeek(xFilial("SCR")+cCR_TIPO+PadR(cCR_NUM,Len(SCR->CR_NUM))+cCR_APROV)
			oAprov[nCont]["Ok"] := .F.
			oAprov[nCont]["Erro"] := "Registro não encontrado"
			lOK := .F.
			ConOut('Registro não encontrado')
		Else
			IF lOk
				SetFunName("MATA094")
				oModel094  := FwLoadModel("MATA094")
				oModel094:SetOperation(MODEL_OPERATION_UPDATE)

				IF cStatus == "L"
					A094SetOp(OP_LIB)
				ElseIF cStatus == "R"
					A094SetOp(OP_REJ)
				EndIF
				//oView := FWLoadView("MATA094")
				oModel094:Activate()
				oModelSCR := oModel094:GetModel("FieldSCR")
				oModelSCR:LoadValue("CR_NUM"        ,cCR_NUM)
				oModelSCR:LoadValue("CR_TIPO"       ,cCR_TIPO)
				oModelSCR:LoadValue("CR_OBS"        ,cCR_OBS)
				oModelSCR:LoadValue("CR_APROV"      ,_CAPROV)
				//oModel094:SetValue("FieldSCR","CR_GRUPO"      ,cCR_GRUPO)
				oModelSCR:LoadValue("CR_DATALIB"    ,dDataBase)

				If oModel094:VldData()
					oModel094:CommitData()
					//cRet := '{"processado":true}'
					oAprov[nCont]["Ok"] := .T.
					ConOut('APROVAÇÃO PEDIDO OK'+cCR_NUM)
				Else
					aErro := oModel094:GetErrorMessage()
					oAprov[nCont]["Ok"] := .F.
					oAprov[nCont]["Erro"] := aErro[6]
					lOk := .F.
					//cRet := '{"processado":false, erro:"'+aErro[6]+'"}'
					//MsgInfo(aErro[6])
					//VarInfo("",aErro)
					ConOut('APROVAÇÃO PEDIDO ERRO'+cCR_NUM+"-"+aErro[6])
				EndIf
				oModel094:DeActivate()
				oModel094:Destroy()
			EndIF
		EndIF

		cRet += FWJsonSerialize(oAprov[nCont], .F., .F., .T.)
		IF nCont < Len(oAprov)
			cRet += ","
		EndIF
	Next
//EndTran()
	cRet += "]"
	::SetResponse(cRet)

	FreeObj(oAprov)
Return .T.
