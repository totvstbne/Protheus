#Include "RWMAKE.CH"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  A097PCO                                                                                              |
 | Autora: Alana Oliveira em 17.12.2021                                                                        |
 | Desc:  Ponto de Entrada que permite lançar PCO na liberação de Pedidos de Compra                            |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6085825                                        |
 *--------------------------------------------------------------------------------------------------------------*/
 

User Function A097PCO()

Local lRet	  := .F.
Local cC7Num  := ParamIXB[1]	//-- Numero do Pedido de Compra
Local cUser	  := ParamIXB[2]	//-- Nome do Usuario
Local lLanPCO := ParamIXB[3]	//-- Valor Atual para geracao de lancamentos no PCO

//If SCR->CR_NIVEL == "01"
  //  lRet:= .T.
//ENDIF

Return lRet
