#include "PROTHEUS.CH"
#Include "AP5MAIL.CH"   

/*------------------------------------------------------------------------------------------------------------*
| P.E.:  PCOVLBLQ                                                                                             |
| Autora: Alana Oliveira em 20.12.2021                                                                        |
| Desc:  Este ponto de entrada permite que a regra de validação seja efetuada pelo usuario para os pontos de  |
| bloqueio no controle orçamentário                                                                           |
| Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6073546                                        |
*-------------------------------------------------------------------------------------------------------------*/                   

User Function PCOVLBLQ()  

Local nMoedaCfg 	:= ParamIXB[1] // Moeda
Local nValReal 		:= ParamIXB[2] // Valor "Realizado"
Local nValPrv 		:= ParamIXB[3] // Valor "Previsto"                  
Local cChaveR 		:= ParamIXB[4] // Chave da Pesquisa              
Local cProcesso 	:= ParamIXB[5] // Código do Processo
Local cItem 		:= ParamIXB[6] // Item do Processo
Local cPrograma 	:= ParamIXB[7] // Nome do Programa                            
Local cChaveRD 		:= ParamIXB[8] // Descricao da Chave
Local aDtIni 	    := ParamIXB[9,1] // 1-Data Inicio
Local aDtFim        := ParamIXB[9,2] // Data Fim
Local aAuxFil 		:= ParamIXB[10] // 1-Param Cfg Prv;2-Cfg Real
Local lUsaLote 		:= ParamIXB[11] // Indicador se utiliza lote
Local aPcoBkpBlq 	:= ParamIXB[12] // Array contendo Recnos AKD para caso de restaurar

Local _dData		:= dDataBase  
Local cConta 		:= ALLTRIM(SUBSTR(cChaveR,1,12)) 
Local cCentro 		:= ALLTRIM(SUBSTR(cChaveR,13,20)) 
Local cDescCC 	    := ""
Local cDescCta		:= ""
Local cDisp		    := ""
Local cDIf		    := ""
Local cValor		:= ""
Local lRet 		    := .T. // Retorno -> .T. Nao Bloqueia .F. Bloqueia Lancamento
Local dDtAnt	    := FirstYDate(aDtIni)-1
Local aArea         := GetArea()

/* Retorna o saldo do cubo da chave informada em uma determinada data */ 

//Tipo de Saldo: 'RE' - Realizado
aSldREIni:= PCORETSLD("01",cChaveR+"RE",dDtAnt)
aSldREFim:= PCORETSLD("01",cChaveR+"RE",aDtFim)

//Tipo de Saldo: 'EM' - Empenhado
aSldEMIni:= PCORETSLD("01",cChaveR+"EM",dDtAnt)
aSldEMFim:= PCORETSLD("01",cChaveR+"EM",aDtFim)

//Tipo de Saldo: 'OR' - Orçado
aSldORIni:= PCORETSLD("01",cChaveR+"OR",dDtAnt)
aSldORFim:= PCORETSLD("01",cChaveR+"OR",aDtFim)

//Tipo de Saldo: 'CT' - Contingência
aSldCTIni:= PCORETSLD("01",cChaveR+"CT",dDtAnt)
aSldCTFim:= PCORETSLD("01",cChaveR+"CT",aDtFim)

nValReal := ((aSldREFim[1,1]-aSldREFim[2,1])  -  (aSldREIni[1,1]-aSldREIni[2,1])) + ((aSldEMFim[1,1]-aSldEMFim[2,1])  -  (aSldEMIni[1,1]-aSldEMIni[2,1]))
nValPrv  := ((aSldORFim[1,1]-aSldORFim[2,1])  -  (aSldORIni[1,1]-aSldORIni[2,1])) + ((aSldCTFim[1,1]-aSldCTFim[2,1])  -  (aSldCTIni[1,1]-aSldCTIni[2,1]))

If  cProcesso = "000055" // Liberação de pedido de compras
	cDisp  := Alltrim(STR(nValPrv - (nValReal - SC7->C7_TOTAL),17,2))
	cDIf   := Alltrim(STR(abs(SC7->C7_TOTAL - (nValPrv - (nValReal - SC7->C7_TOTAL))),17,2))
	cValor := Alltrim(STR(SC7->C7_TOTAL,17,2))
EndIf

If VAL(cDisp) >= VAL(cValor) // Se houver saldo
	Return(lRet)
EndIf

CTT->(DBSETORDER(1))
CTT->(DbSeek(xFilial("CTT")+cCentro))
cDescCC := CTT->CTT_DESC01

AK5->(DbSeek(xFilial("AK5")+cConta))
cDescCta := ALLTRIM(AK5->AK5_DESCRI)

If cProcesso = "000055"
	
	cPed	:= SC7->C7_NUM
	cFornece:= SC7->C7_FORNECE
	cLoja	:= SC7->C7_LOJA
	cNomFor	:= Posicione("SA2",1,xfilial("SA2")+cFornece+cLoja,"A2_NOME")
	nValor	:= SC7->C7_TOTAL
	cValor	:= Alltrim(STR(nValor,17,2))
    _dData  := SC7->C7_EMISSAO
	cMen	:= "Pedido: "+cPed+" - "+"Forn.: "+cFornece+"-"+cLoja+" - "+cNomFor
	cMenMail:= "Pedido: "+cPed

	cMsg	:=	"Os saldos atuais do Planejamento e Controle Orçamentário são insuficientes para "+CHR(13)+CHR(10)+;
                "completar esta operação no período "+ DTOC(aDtIni) + " - "+DTOC(aDtFim)+"."+CHR(13)+CHR(10)+;
				"Solicitante: "+Alltrim(UsrFullName(__cUserId))+CHR(13)+CHR(10)+; 
				"Documento: "+cMen+CHR(13)+CHR(10)+;
                "Conta: "+Alltrim(cConta)+" - "+AllTrim(cDescCta)+CHR(13)+CHR(10)+;
				"Centro de Custo: "+Alltrim(cCentro)+" - "+AllTrim(cDescCC)+CHR(13)+CHR(10)+;
				"Valor Solicitado : " +cDIf+"  -   Saldo Disponível: "+cDisp  +CHR(13)+CHR(10)+;
				" - Venc.: "+dtoc(_dData) + " - Valor do Documento: "+ cValor +CHR(13)+CHR(10)

	lRet	:= .F. // Retorna falso e Bloqueia processo '000055'
    
	nRet := Aviso("Planejamento e Controle Orçamentário",cMsg,{"Sair", "Solicitar contingência"},3,"Saldo Insuficiente")

	If nRet = 2
		Alert("Ponto de Entrada")
	EndIf 

EndIf

RestArea(aArea)

Return(lRet)



