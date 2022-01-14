#Include "Protheus.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120OK                                                                                               |
 | Autora: Alana Oliveira em 19.11.2021                                                                         |
 | Desc:  Ponto de Entrada para validar especificas, executado antes da gravação do pedido de compras           |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6085483                                         |
 *--------------------------------------------------------------------------------------------------------------*/


 User Function MT120OK()
 
 Local lRet := .T.
 
 If Empty(cXCartao) // cXCartao : variável pública criada no ponto de entrada MT120TEL
    
    Alert("Informe se pagamento é por cartão de crédito")
    lRet:= .F.

 Endif
 
 Return lRet
