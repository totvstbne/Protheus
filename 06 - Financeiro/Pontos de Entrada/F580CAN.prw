#INCLUDE "rwmake.ch"

User Function F580CAN()

Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cCodApr  := GetMV("SV_FINAPRO")
Local lGrvMov

If cCodUser $ cCodApr
	lGrvMov	:= .T.
Else
	Alert("Usu�rio sem permiss�o para cancelamento de libera��o.")
	lGrvMov	:= .F.
EndIf

Return lGrvMov