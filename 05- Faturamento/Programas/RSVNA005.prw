#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RSVNA005
Alteração da natureza financeira no faturamento
@author Diogo
@since 19/12/2018
@version undefined
@example
(examples)
@see (links_or_references
Modificado o parâmetro MV_1DUPNAT para &(U_RSVNA005())
/*/
user function RSVNA005()
	Local cRet:= "SA1->A1_NATUREZ"
	If funname() $ "MATA461/MATA460" //Faturamento considera a natureza da SC5
		cRet:= "SC5->C5_NATUREZ"
	Endif
return cRet