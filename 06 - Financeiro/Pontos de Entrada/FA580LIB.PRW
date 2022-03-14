#INCLUDE "rwmake.ch"

User Function FA580LIB()

Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cCodApr  := GetMV("SV_FINAPRO")
Local lRet

If cCodUser $ cCodApr
	lRet	:= .T.
Else
	Alert("Usuário sem permissão para liberação de títulos.")
	lRet	:= .F.
EndIf

Return lRet