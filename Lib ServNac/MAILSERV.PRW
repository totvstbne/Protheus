#Include "RWMAKE.CH"
#Include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#include "AP5MAIL.CH"

USER FUNCTION MAILSERV(CPARA,CASSUNTO,CMSG)

	private lResulConn := .T.
	private lResulSend := .T.
	private cError := ""

	private cServer  := AllTrim(GetMV("MV_RELSERV"))
	private cEmail   := AllTrim(GetMV("MV_RELACNT"))
	private cPass    := AllTrim(GetMV("MV_RELPSW"))
	private lRelauth := GetMv("MV_RELAUTH")

	private cDe      := cEmail
//private cPara    := "rodrigoti@concret.com.br;marconinho@concret.com.br"
	private cCc      := ""
//private cAssunto := "RELATO DE PROCURA POR PRODUTO"
	private cAnexo   := ""
//private cMsg     := Space(200)

	private _lJob 	:= .T.


	CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

	If !lResulConn
		GET MAIL ERROR cError
		If _lJob
			ConOut(Padc("Falha na conexao "+cError,80))
		Else
			MsgAlert("Falha na conexao "+cError)
		Endif
		Return(.F.)
	Endif

	// Sintaxe: SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	// Todos os e-mail terão: De, Para, Assunto e Mensagem, porém precisa analisar se tem: Com Cópia e/ou Anexo

	If lRelauth

		lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))

		// Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail.
		If !lResult
			nA := At("@",cEmail)
			cUser	:= If(nA>0,Subs(cEmail,1,nA-1),cEmail)
			lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
		Endif

	Endif

	If lResult
		If Empty(cCc) .And. Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
		ElseIf Empty(cCc) .And. !Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
		ElseIf !Empty(cCc) .And. !Empty(cAnexo)
			SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

		Endif
		If !lResulSend
			GET MAIL ERROR cError
			If _lJob
				ConOut(Padc("Falha no Envio do e-mail "+cError,80))
			Else
				MsgAlert("Falha no Envio do e-mail " + cError)
			Endif
		Endif

	Else

		If _lJob
			ConOut(Padc("Falha na autenticação do e-mail: "+cError,80))
		Else
			MsgAlert("Falha na autenticação do e-mail:" + cError)
		Endif

	Endif

	DISCONNECT SMTP SERVER

	IF lResulSend
		If _lJob
			ConOut(Padc("E-mail enviado com sucesso",80))
		Else
			MsgInfo("E-mail enviado com sucesso" + cError)
		Endif
	ENDIF



RETURN lResulSend
