#INCLUDE "rwmake.ch"

User Function F580LbA()

Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cCodApr  := GetMV("SV_FINAPRO")
Local lRet

If cCodUser $ cCodApr
	lRet	:= .T.
Else
	Alert("Usu�rio sem permiss�o para libera��o de t�tulos.")
	lRet	:= .F.
EndIf

Return lRet