#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
Static cCodUsado	//Codigo reservado

/*/{Protheus.doc} RSVNG001
Gatilho da numeração do local de atendimento
CCCCCSSS - 5 caracteres do cliente + 3 sequencial
@author Diogo
@since 12/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSVGN001()
	Local aArea	:= getArea()
	Local cRet	:= ''
	Local cSeq	:= ''
	Local nVez	:= 0
	If M->ABS_ENTIDA = '1'//Cliente
		cQuery :="SELECT SUBSTRING(ABS_LOCAL,6,3) SEQ, R_E_C_N_O_ RECNO FROM "+RetSqlName("ABS")+ " ABS "
		cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
		cQuery +="ABS_FILIAL = '"+xFilial("ABS")+"' AND "
		cQuery +="ABS_CODIGO = '"+M->ABS_CODIGO+"' AND "
		cQuery +="SUBSTRING(ABS_LOCAL,1,1) <> 'P' "
		cQuery +="ORDER BY SUBSTRING(ABS_LOCAL,6,3) DESC "
		TcQuery cQuery new Alias QTABS
		cSeq:= "001"
		If !empty(QTABS->SEQ)
			cSeq:= soma1(QTABS->SEQ)
			cSeq:= padl(cSeq,3,"0")
		Endif
		QTABS->(dbCloseArea())
		cRet:= substr(M->ABS_CODIGO,2,5)+cSeq
	Else //Prospect
		cQuery :="SELECT MAX(ABS_LOCAL) ABS_LOCAL FROM "+RetSqlName("ABS")+ " ABS "
		cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
		cQuery +="ABS_FILIAL = '"+xFilial("ABS")+"' AND "
		cQuery +="SUBSTRING(ABS_LOCAL,1,1) = 'P' "
		TcQuery cQuery new Alias QTABS

		cSeq:= "0000001"
		If !empty(QTABS->ABS_LOCAL)
			cSeq:= val(substr(QTABS->ABS_LOCAL,2,8))+1
			cSeq:= strzero(cSeq,7)
		Endif
		QTABS->(dbCloseArea())
		cRet:= 'P'+ cSeq
	Endif
	If !Empty(cCodUsado)	//Se a sessão atual já tem um numero reservado
		UnLockByName(cCodUsado,.F.,.F.)
	EndIf

	ABS->(DbSetOrder(1))
	While ABS->(DbSeek("ABS"+xFilial("ABS")+cRet)) .OR. !LockByName("ABS"+xFilial("ABS")+cRet,.F.,.F.)	//Verifica numero reservado
		cRet:= substr(cRet,1,len(alltrim(cRet))-3)+Soma1(substr(cRet,len(alltrim(cRet))-3,3))
		If nVez>30	//Tratar loop da rotina
			Exit
		EndIf
		nVez++
	EndDo

	//Verifica se existe
	lexist:= .T.
	while .T.
		cQuery:="SELECT ABS_LOCAL FROM "+RetSqlName("ABS")+" "
		cQuery+="WHERE D_E_L_E_T_ = ' ' AND "
		cQuery+="ABS_LOCAL = '"+cRet+"' AND  "
		cQuery+="ABS_FILIAL = '"+xFilial("ABS")+"' "
		TcQuery cQuery new Alias QEXIST
		If empty(QEXIST->ABS_LOCAL)
			lexist:= .F.
		Else
			cRet:= substr(cRet,1,5)+soma1(substr(cRet,6,3))
		Endif
		QEXIST->(dbCloseArea())
		If !lexist
			exit	
		Endif
	enddo	
	cCodUsado:= "ABS"+xFilial("ABS")+cRet
	RestArea(aArea)
return cRet
