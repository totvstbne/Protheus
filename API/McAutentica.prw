#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.CH"


WSRESTFUL McAutentica DESCRIPTION "Serviço REST - Mconsult para autenticação"

	WSDATA login AS STRING
	WSDATA senha AS String

//WSMETHOD GET DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/scr || /scr/{id}"
	WSMETHOD GET DESCRIPTION "McAutentica" WSSYNTAX "/McAutentica/{login}/{senha}"

END WSRESTFUL



WSMETHOD GET WSRECEIVE login, senha WSSERVICE McAutentica
	Local cCodUsr
	Local cPass
	Local lAchou	:= .F.
	// define o tipo de retorno do método
	::SetContentType("application/json")

	// verifica se recebeu parametro pela UR
	If Len(::aURLParms) > 0
		cCodUsr     := ::aURLParms[1]
		cPass       := ::aURLParms[2]
		/*
		PswOrder(1)
		IF PswSeek(cCodUsr)
			aUser := PswRet()
			lAchou := .T.
		Else
		*/
			PswOrder(2)
			IF PswSeek(cCodUsr, .T. )
				//PswID()
				aUser := PswRet()
				lAchou := .T.
			EndIF
			//EndIF

			IF lAchou
				PswSeek(cCodUsr, .T. )
				IF PswName(AllTrim(cPass)) .and. !(aUser[1,17])
					::SetResponse('{"autenticado":true,"codigo":"'+AllTrim(aUser[1,1])+'","login":"'+alltrim(aUser[1,2])+'","nome":"'+AllTrim(aUser[1,4])+'","email":"'+AllTrim(aUser[1,14])+'"}')
				Else
					::SetResponse('{"autenticado":false,"codigo":"'+AllTrim(aUser[1,1])+'","login":"'+alltrim(aUser[1,2])+'","nome":"'+AllTrim(aUser[1,4])+'","email":"'+AllTrim(aUser[1,14])+'"}')
				EndIF
			Else
				::SetResponse('{"autenticado":false}')
			EndIF
			//EndIF
		EndIf

		//::SetResponse("{autenticado:0}")
		Return .T.
