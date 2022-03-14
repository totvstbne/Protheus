#include 'protheus.ch'
#include 'rwmake.ch'
#include "totvs.ch"
#include "topconn.ch"
#Include 'FWMVCDEF.CH'

/*/{Protheus.doc} FT600BUT
Inclui opção em ações relacionadas na tela da Proposta Comercial
@author Totvs
@since 18/09/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/

User Function FT600BUT()

	Local aArea:= getArea()
	Local aBut 		:= {}
	Local oModel	:= FwModelActive()
				
	aAdd(aBut,{"Informe de Beneficios", "",{|| fVTVA()},"ViewAltera",, })
	
	RestArea(aArea) 
Return aBut

Static Function fVTVA()
	Local oModel	:= FwModelActive()
	Local aAreaAnt	:= getArea()
	Local cTpm		:= ""
	Local lExist	:= .F.
	Private aRotBkp	:= aRotina
	Private aRotina	:= {}
	aRotina:= {}

	//Verifica se já existe, caso não gera
	cQuery:= "SELECT ZA2_NROPOR FROM "+RetSqlName("ZA2")+" ZA2 "
	cQuery+= "WHERE ZA2.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZA2_FILIAL = '"+xFilial("ZA2")+"' AND "
	cQuery+= "ZA2_NROPOR = '"+M->ADY_OPORTU+"' "
	tcQuery cQuery new Alias QRZA21
	If QRZA21->(Eof())
		lExist:= fAddZA2()
	Endif
	QRZA21->(dbCloseArea())

	If !lExist
		alert("Necessário a vinculação da proposta ao gestão de serviços")
	Else
		u_RSERV011()
	Endif

	aRotina:= aRotBkp 
	RestArea(aAreaAnt)
Return

/*/{Protheus.doc} fAddZA2
Adiciona na ZA2
@author Diogo
@since 27/02/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fAddZA2()
	Local aArea		:= getArea()
	Local nOpc		:= MODEL_OPERATION_INSERT
	Local lRet		:= .F.
	cQuery :="SELECT ABS_DESCRI, ABS_LOCAL "
	cQuery +="FROM "+RetSqlName("ABS")+ " ABS "
	cQuery +="INNER JOIN " + RETSQLNAME("TFL") + " TFL ON TFL_LOCAL = ABS_LOCAL "
	cQuery +="INNER JOIN " + RETSQLNAME("TFJ") + " TFJ ON TFJ_FILIAL = TFL_FILIAL AND TFJ_CODIGO = TFL_CODPAI "
	cQuery +="WHERE ABS.D_E_L_E_T_ = ' ' AND "
	cQuery +="TFJ.D_E_L_E_T_ = ' ' AND "
	cQuery +="TFL.D_E_L_E_T_ = ' ' AND "
	cQuery +="TFJ_FILIAL = '"+xFilial("TFJ")+"' AND "
	cQuery +="TFL_FILIAL = '"+xFilial("TFL")+"' AND "
	cQuery +="ABS_FILIAL = '"+xFilial("ABS")+"' AND "
	cQuery +="TFJ_PROPOS = '"+M->ADY_PROPOS+"' "
	cQuery +="GROUP BY ABS_DESCRI, ABS_LOCAL "
	tcQuery cQuery new Alias TQFJ 
	
	while TQFJ->(!Eof())
		lRet		:= .T.
		oModelZA2	:= FWLoadModel('RSERV011')
		oModelZA2:SetOperation(nOpc)
		lRet	:= oModelZA2:Activate()
		oMdlZA2	:= oModelZA2:GetModel( "ZA2MAST" )
		oMdlZA2:SetValue("ZA2_COD",TQFJ->ABS_LOCAL)
		oMdlZA2:SetValue("ZA2_CONTRA","")
		
		If ( lRet := oModelZA2:VldData() )
			lRet := oModelZA2:CommitData()
		EndIf
		If !lRet
			aErro   := oModelZA2:GetErrorMessage()
			alert( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+;
			"Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+;
			"Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+;
			"Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+;
			"Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+;
			"Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+;
			"Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+;
			"Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+;
			"Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
			TQFJ->(dbCloseArea())
			RestArea(aArea)
			Return lRet
		EndIf
		oModelZA2:DeActivate()
	TQFJ->(dbSkip())
	Enddo
	TQFJ->(dbCloseArea())
	RestArea(aArea)
Return lRet