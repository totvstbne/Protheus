#INCLUDE "rwmake.ch"

User Function F580CAN()

Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cCodApr  := GetMV("SV_FINAPRO")
Local lGrvMov

If cCodUser $ cCodApr
	lGrvMov	:= .T.
Else
	Alert("Usuário sem permissão para cancelamento de liberação.")
	lGrvMov	:= .F.
EndIf

Return lGrvMov