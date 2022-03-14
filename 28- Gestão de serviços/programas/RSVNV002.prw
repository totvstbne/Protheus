#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RSVNV002
Validação 
@author diogo
@since 24/05/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSVNV002()
	Local lRet:= .T.
	Local aArea:= getArea()
	If posicione("SED",1,xFilial("SED")+M->ZA7_NATURE,"ED_MSBLQL") == "1"
		lRet:= .F.
		MsgStop("Natureza Bloqueada. Digite uma natureza válida.","Atenção")
	Endif
	RestArea(aArea)
return lRet