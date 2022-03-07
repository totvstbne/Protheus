#include 'protheus.ch'
#include 'parmtype.ch'

/*
+-------------+----------+--------+---------------------------------+-------+-------------+
| Programa:   | CT030GRI | Autora: | Alana Oliveira	     	        | Data: | Fev/2022    |
+-------------+----------+--------+---------------------------------+-------+-------------+
| Descri��o:  | Ponto-de-Entrada: CT030GRI.O ponto de entrada CT030GRI tem como finalidade|
|             | gravar os campos de usu�rio, deixando compativeis as tabelas SI3 e CTT 	  |	
|             | (inclus�o).	                                                              |
+-------------+---------------------------------------------------------------------------+
| Uso:        | ServNac							                                          |
+-------------+------------------------------------+--------------------------------------+
*/

User Function CT030GRI()

Local aArea     := getArea()
Local _cClasse  := '1'+SubStr(CTT->CTT_CUSTO,6,5)
Local _cCli     := SubStr(CTT->CTT_CUSTO,5,6)
Local _cDesCli  := ""

If SubStr(CTT->CTT_CUSTO,1,1) == '1' // Se o centro de custo come�ar com 1

    DbSelectArea("AK6")
    AK6->(DbSetOrder(1))
    If !AK6->(DBSEEK(xFilial("AK6")+_cClasse))//Verifica se j� existe classe or�ament�ria no sistema
        
        DbSelectArea("SA1")  //Pesquisa Descri��o do cliente
        SA1->(DbSetOrder(1)) 
        SA1->(dbseek(xFilial("SA1")+_cCli))
        _cDesCli:= SA1->A1_NOME
        
        RECLOCK("AK6",.T.)  // Inclus�o da classe or�ament�ria
            AK6->AK6_FILIAL := xFilial("AK6")
            AK6->AK6_CODIGO := _cClasse
            AK6->AK6_DESCRI := _cDesCli //Descri��o do cliente � a mesma da classe
            AK6->AK6_INDICE := 0
            AK6->AK6_OBRIGA := '2'
            AK6->AK6_OPER   := '2'
            AK6->AK6_DECIMA := 2
            AK6->AK6_FORMAT := '1'
        MSUNLOCK()

    Endif

    RECLOCK("CTT",.F.) // Faz a amarra��o da classe com o centro de custo
        CTT->CTT_YCLAOR := _cClasse
        CTT->CTT_YPCO   := "1"
    MSUNLOCK()

Endif

RestArea(aArea)

Return
