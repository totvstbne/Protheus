#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} FTMSREL
Inclusão de referencia no banco de conhecimento
@author Diogo
@since 25/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function FTMSREL
	Local aEntidade := {}

	Aadd( aEntidade, { "ZA7", { "ZA7_NUM" }, { || ZA7->ZA7_NUM } } )

Return aEntidade