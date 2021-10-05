#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MTALCPER
Aprovação customizada para o Pedido Financeiro
@author Diogo
@since 06/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function MTALCPER()
	Local aAlc := {}
	aAdd(aAlc, { "PF"			,;
	 			'ZA7'			,;
	 			3				,;
	 			'ZA7->ZA7_NUM+ZA7->ZA7_PARCEL'	,;
	 			{||u_fVisuPF()}					,;
	 			{|| u_fEstorPF()}				,;
	 			{'ZA7->ZA7_STATUS',"P","A","R"}})
return aAlc

user Function fEstorPF
	MsgAlert("Utilizar a rotina Estonar Pedido Financeiro")
Return .F.