#Include "Protheus.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120OK                                                                                               |
 | Autora: Alana Oliveira em 19.11.2021                                                                         |
 | Desc:  Ponto de Entrada para validar especificas, executado antes da grava��o do pedido de compras           |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6085483                                         |
 *--------------------------------------------------------------------------------------------------------------*/


 User Function MT120OK()
 
 Local lRet := .T.
 
 If Empty(cXCartao) // cXCartao : vari�vel p�blica criada no ponto de entrada MT120TEL
    
    Alert("Informe se pagamento � por cart�o de cr�dito")
    lRet:= .F.

 Endif
 
 Return lRet
