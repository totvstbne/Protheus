
#Include "RWMAKE.CH"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  PCOCONTG                                                                                             |
 | Autora: Alana Oliveira em 03.01.2022                                                                        |
 | Desc:  Ponto de Entrada chamado antes do controle de saldo de contingência para validar a utilização do     | 
 | controle de saldo de contingência no bloqueio PCO.                                                          | 
 | Caso retorne Verdadeiro .T., é realizado normalmente o controle de saldo de contingência.                   | 
 | Caso retorne Falso .F., não é realizado o controle de saldo de contingência, somente o Bloqueio.            |                
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=83165322                                       |
 *--------------------------------------------------------------------------------------------------------------*/
 

User Function PCOCONTG()

Local aDadosBlq := paramixb[1]
Local lRet := .T.

Return lRet
