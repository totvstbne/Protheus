#include "protheus.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  PCOA5301                                                                                             |
 | Autora: Alana Oliveira em 14.01.2022                                                                        |
 | O ponto de entrada PCOA5301 serve para manipular o texto padrão do bloqueio orçamentário quando o controle  |
 |  de saldos de contingência estiver ativo. Esse texto será enviado ao usuário com alçada para liberação por  |
 |  e-mail (ou workflow).                                                                                      |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6073549                                        |
 *--------------------------------------------------------------------------------------------------------------*/
 

User Function PCOA5301()

Local cTxt := ParamIXB[1]
Local aDadosBlq := ParamIXB[2]

/*

1) nMoedaCfg => Moeda da Configuração
2)nValReal => Valor Realizado
3)nValPrv => Valor Previsto
4)cChaveR => Chave do cubo
5)cProcesso => Código Processo Lançamento
6)cItem => Item Processo de Lançamento
7)cPrograma => Nome do Programa
8)cChaveRD => Moeda da Configuração
9)aDataIniFim => array contendo período 1-inicial 2-Final
10)aAuxFil => Parâmetros das configurações executadas na função PcoRunCube()

*/

Local nMoedaCfg 	:= aDadosBlq[1] // Moeda
Local nValReal 		:= aDadosBlq[2] // Valor "Realizado"
Local nValPrv 		:= aDadosBlq[3] // Valor "Previsto"                  
Local cChaveR 		:= aDadosBlq[4] // Chave da Pesquisa              
Local cProcesso 	:= aDadosBlq[5] // Código do Processo
Local cItem 		:= aDadosBlq[6] // Item do Processo
Local cPrograma 	:= aDadosBlq[7] // Nome do Programa                            
Local cChaveRD 		:= aDadosBlq[8] // Descricao da Chave
Local aDtIni 	    := aDadosBlq[9,1] // 1-Data Inicio
Local aDtFim        := aDadosBlq[9,2] // Data Fim
Local aAuxFil 		:= aDadosBlq[10] // 1-Param Cfg Prv;2-Cfg Real

Local _dData		:= dDataBase  
Local cConta 		:= ALLTRIM(SUBSTR(cChaveR,1,12)) 
Local cCentro 		:= SC7->C7_CC //ALLTRIM(SUBSTR(cChaveR,13,20)) 
Local cDescCC 	    := ""
Local cDescCta		:= ""
Local cDisp		    := ""
Local cDIf		    := ""
Local cValor		:= ""
Local lRet 		    := .T. // Retorno -> .T. Nao Bloqueia .F. Bloqueia Lancamento
Local dDtAnt	    := FirstYDate(aDtIni)-1
Local aArea         := GetArea()

If  cProcesso == "000055" // Liberação de pedido de compras

	cClasse:= IIF(POSICIONE("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")   

	cDisp  := Alltrim(STR(nValPrv - (nValReal - SC7->C7_TOTAL),17,2))
	cDIf   := Alltrim(STR(abs(SC7->C7_TOTAL - (nValPrv - (nValReal - SC7->C7_TOTAL))),17,2))
	cValor := Alltrim(STR(SC7->C7_TOTAL,17,2))

	CTT->(DBSETORDER(1))
	CTT->(DbSeek(xFilial("CTT")+cCentro))
	cDescCC := CTT->CTT_DESC01

	AK5->(DbSeek(xFilial("AK5")+cConta))
	cDescCta := ALLTRIM(AK5->AK5_DESCRI)

	AK6->(DbSeek(xFilial("AK6")+cClasse))
	cDescCla := ALLTRIM(AK6->AK6_DESCRI)

	If VAL(cDisp) >= VAL(cValor) // Se houver saldo
		Return(lRet)
	EndIf

	cPed	:= SC7->C7_NUM
	cFornece:= SC7->C7_FORNECE
	cLoja	:= SC7->C7_LOJA
	cNomFor	:= Posicione("SA2",1,xfilial("SA2")+cFornece+cLoja,"A2_NOME")
	nValor	:= SC7->C7_TOTAL
	cValor	:= Alltrim(STR(nValor,17,2))
	_dData  := SC7->C7_EMISSAO
	cMen	:= "Pedido: "+cPed+" - "+"Forn.: "+cFornece+"-"+cLoja+" - "+cNomFor
	cMenMail:= "Pedido: "+cPed

	cTxt:="Os saldos atuais do Planejamento e Controle Orçamentário são insuficientes para "+CHR(13)+CHR(10)+;
      "completar esta operação no período "+ DTOC(aDtIni) + " - "+DTOC(aDtFim)+"."+CHR(13)+CHR(10)+;
	  "Solicitante: "+Alltrim(UsrFullName(__cUserId))+CHR(13)+CHR(10)+; 
	  "Documento: "+cMen+CHR(13)+CHR(10)+;
      "Conta: "+Alltrim(cConta)+" - "+AllTrim(cDescCta)+CHR(13)+CHR(10)+;
	  "Classe: "+Alltrim(cClasse)+" - "+Alltrim(cDescCla)+CHR(13)+CHR(10)+;
	  "Valor Solicitado : " +cDIf+"  -   Saldo Disponível: "+cDisp  +CHR(13)+CHR(10)+;
	  " - Venc.: "+dtoc(_dData) + " - Valor do Documento: "+ cValor +CHR(13)+CHR(10)

Endif

RestArea(aArea)

Return(cTxt)
