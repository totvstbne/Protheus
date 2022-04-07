#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MTA094RO
Inclusão de rejeição do Pedido Financeiro
@author Diogo
@since 06/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function MTA094RO()
	Local aRotina	:= PARAMIXB[1]
	Local nPos		:= Ascan(aRotina,{|x| upper(Alltrim(x[1]))="APROVAR"})
	
	aRotina[nPos][2] := 'u_fAprovAlc()' 
	
	aadd(aRotina, { "Rejeitar Pedido Financeiro","u_fRejeiPF(.F.)",0,4,0,NIL})
	aadd(aRotina, { "Visualizar Pedido Financeiro","u_fVisuPF()",0,4,0,NIL})
	aadd(aRotina, { "Aprov. Desp. Fixas","u_RPFA010(1)",0,4,0,NIL})
	aadd(aRotina, { "Aprovação em Lote PF","u_RPFA010(2)",0,4,0,NIL})
	aadd(aRotina, { "Estornar Pedido Financeiro","u_fEst01A()",0,4,0,NIL})
	aadd(aRotina, { "Consulta Aprovação","u_fConsApv()",0,4,0,NIL})
	aadd(aRotina, { "Aprovação em Lote PC","U_RSVNA010()",0,4,0,NIL})
	aadd(aRotina, { "Aprovação de Contingência","U_RAPRCTG1()",0,3,0,NIL})
return aRotina
