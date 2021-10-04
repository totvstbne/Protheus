#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FT300MNU
Menu da Proposta Comercial 
@author Diogo
@since 13/06/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function FT300MNU()
	aRotina:= paramixb[1]
	
	Aadd(aRotina, { "Reabrir Oportunidade"  ,"U_RSVNA002()"	,0,2,0 ,NIL,NIL,NIL})

return aRotina