
#Include "RWMAKE.CH"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  PCOCONTG                                                                                             |
 | Autora: Alana Oliveira em 03.01.2022                                                                        |
 | Desc:  Ponto de Entrada chamado antes do controle de saldo de conting�ncia para validar a utiliza��o do     | 
 | controle de saldo de conting�ncia no bloqueio PCO.                                                          | 
 | Caso retorne Verdadeiro .T., � realizado normalmente o controle de saldo de conting�ncia.                   | 
 | Caso retorne Falso .F., n�o � realizado o controle de saldo de conting�ncia, somente o Bloqueio.            |                
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=83165322                                       |
 *--------------------------------------------------------------------------------------------------------------*/
 

User Function PCOCONTG()

Local aDadosBlq := paramixb[1]
Local lRet := .T.

Return lRet
