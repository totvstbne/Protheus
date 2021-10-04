#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} SIGATEC
Chamada da consulta dos cancelamentos e próximos da renovação
@author Diogo
@since 12/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function SIGATEC()
	Local aArea:= getArea()
	If type("cRotCust") = "U"
		aGrupos := UsrRetGrp(usrRetName(retCodUsr()) ,retCodUsr())
		If len(aGrupos) > 0
			For j := 1 To len(aGrupos)
				If alltrim(aGrupos[j]) $ alltrim(supergetMv("SV_GRPCON",,"000000"))
					If msgYesNo("Deseja visualizar contratos próximos do cancelamento e renovação?")
						u_RSVNA003()
					Endif
					public cRotCust:= "RSVNA003"
				EndIf
			Next
		EndIf
	Endif
	RestArea(aArea)
return