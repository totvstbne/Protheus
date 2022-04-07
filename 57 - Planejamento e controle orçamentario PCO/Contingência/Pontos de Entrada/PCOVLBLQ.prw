#include "PROTHEUS.CH"
#Include "AP5MAIL.CH"   
#INCLUDE "TOPCONN.CH" 
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
Local aDataIniFim   := ParamIXB[9]
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

CCADASTRO:="Contingencias"

If  cProcesso == "000055" // Liberação de pedido de compras

	If SCR->CR_NIVEL <> "01" // Só valida na primeira alçada
		Return lRet
	Endif

	cClasse:= IIF(POSICIONE("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_YPCO")=="1",CTT->CTT_YCLAOR,"")   

	/* Retorna o saldo do cubo da chave informada em uma determinada data */ 

	//Tipo de Saldo: 'RE' - Realizado
	aSldREIni:= PCORETSLD("01",cChaveR+"RE",dDtAnt)
	aSldREFim:= PCORETSLD("01",cChaveR+"RE",aDtFim)

	aSldREALA:= U_YSLDALA("01",cChaveR+"RE",dDtAnt,aDtFim) // Tabela ALA

	//Tipo de Saldo: 'EM' - Empenhado
	aSldEMIni:= PCORETSLD("01",cChaveR+"EM",dDtAnt)
	aSldEMFim:= PCORETSLD("01",cChaveR+"EM",aDtFim)

	aSldEMALA:= U_YSLDALA("01",cChaveR+"EM",dDtAnt,aDtFim) // Tabela ALA

	//Tipo de Saldo: 'OR' - Orçado
	aSldORIni:= PCORETSLD("01",cChaveR+"0R",dDtAnt)
	aSldORFim:= PCORETSLD("01",cChaveR+"0R",aDtFim)

	aSldORALA:= U_YSLDALA("01",cChaveR+"0R",dDtAnt,aDtFim) // Tabela ALA

	//Tipo de Saldo: '0I' - Orçado Inicial
	aSldOIIni:= PCORETSLD("01",cChaveR+"0I",dDtAnt)
	aSldOIFim:= PCORETSLD("01",cChaveR+"0I",aDtFim)

	//Tipo de Saldo: 'CT' - Contingência
	aSldCTIni:= PCORETSLD("01",cChaveR+"CT",dDtAnt)
	aSldCTFim:= PCORETSLD("01",cChaveR+"CT",aDtFim)

	aSldCTALA:= U_YSLDALA("01",cChaveR+"CT",dDtAnt,aDtFim) // Tabela ALA

	nValReal := ((aSldREFim[1,1]-aSldREFim[2,1])  -  (aSldREIni[1,1]-aSldREIni[2,1])) + ((aSldEMFim[1,1]-aSldEMFim[2,1])  -  (aSldEMIni[1,1]-aSldEMIni[2,1]))
	nValReal += (aSldREALA[1]-aSldREALA[2]) + (aSldEMALA[1]-aSldEMALA[2]) // Realizado + Empenhado tabela ALA 

	nValPrv  := ((aSldORFim[1,1]-aSldORFim[2,1])  -  (aSldORIni[1,1]-aSldORIni[2,1])) + ((aSldCTFim[1,1]-aSldCTFim[2,1])  -  (aSldCTIni[1,1]-aSldCTIni[2,1]))
	nValPrv  += (aSldORALA[1]-aSldORALA[2]) + (aSldCTALA[1]+aSldCTALA[2]) // Orçado + Contigência tabela ALA
	If nValPrv == 0
		nValPrv  += ((aSldOIFim[1,1]-aSldOIFim[2,1])  -  (aSldOIIni[1,1]-aSldOIIni[2,1]))
	Endif
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

	lRet	:= .F. // Retorna falso e Bloqueia processo '000055'
    
	//nRet := Aviso("Planejamento e Controle Orçamentário",cTxt,{"Sair", "Solicitar contingência"},3,"Saldo Insuficiente")

	//If nRet = 2

		_nOper     := 1 // Inclusão do documento
		_cCodBlq   := '01'
		_aDados    := {}
		_cProcesso := "000055"
		_nValReal  := nValReal
		_nValOrc   := nValPrv
		_nMoeda	   := 1
		_cChaveBlq := cChaveR
		_cLoteID   := ""
		_cObs	   := ""    
		_aDados    := {_cProcesso,;
						_nValReal,;
						_nValOrc,;
						_nMoeda,;
						_cChaveBlq,;
						_cLoteID,;
						_cObs}

	    _lRet := PCOA530({_nMoeda,nValReal,_nValOrc,_cChaveBlq,_cProcesso,'01','MATA097',"CO+CLASSE",aDataIniFim,aAuxFil,})
        //lRet := PCOA530({nMoedaCfg,nValReal,nValPrv,cChaveR,cProcesso,cItem,cPrograma,cChaveRD,aDataIniFim,aAuxFil} , @cMsgBlind )

EndIf

RestArea(aArea)

Return(_lRet)


/*
 Função para retornar movimentos pendentes de processamento na tabela ALA
 Autora Alana Oliveira em 21.01.2021
 Essa função irá retornar os valores pendentes de processamento no cubo que ainda estão na tabela ALA
 Utilizada quando o processamento do cubo é via JOB
*/

User Function YSLDALA(cCub,cChve,dDtIni,dDtFim)

Local nSldC:= 0
Local nSldD:= 0
Local aRetorno:= {}

cQry:= " SELECT SUM(ALA_VALOR1) AS VLR
cQry+= " FROM  " + RETSQLNAME("ALA") + " ALA
cQry+= " WHERE ALA_CHAVAK = '"+cChve+"'
cQry+= "   AND ALA_DATAMV BETWEEN '"+dtos(dDtIni)+"' AND '"+dtos(dDtFim)+"'
cQry+= "   AND D_E_L_E_T_ = ''
cQry+= "   AND ALA_CUBO = '"+cCub+"'
cQry+= "   AND ALA_TIPOMV = 'C'

IF SELECT("TRB2") >0
	TRB2->(DBCLOSEAREA())
ENDIF

TCQUERY cQry NEW ALIAS "TRB2"

If !TRB2->(EOF()) 
	nSldC:= TRB2->VLR
Endif

IF SELECT("TRB2") >0
	TRB2->(DBCLOSEAREA())
ENDIF

// Saldo a débito

cQry:= " SELECT SUM(ALA_VALOR1) AS VLR
cQry+= " FROM  " + RETSQLNAME("ALA") + " ALA
cQry+= " WHERE ALA_CHAVAK = '"+cChve+"'
cQry+= "   AND ALA_DATAMV BETWEEN '"+dtos(dDtIni)+"' AND '"+dtos(dDtFim)+"'
cQry+= "   AND D_E_L_E_T_ = ''
cQry+= "   AND ALA_CUBO = '"+cCub+"'
cQry+= "   AND ALA_TIPOMV = 'D'

IF SELECT("TRB3") >0
	TRB3->(DBCLOSEAREA())
ENDIF

TCQUERY cQry NEW ALIAS "TRB3"

If !TRB3->(EOF()) 
	nSldD:= TRB3->VLR
Endif

IF SELECT("TRB3") >0
	TRB3->(DBCLOSEAREA())
ENDIF

aRetorno:= {nSldC,nSldD}


Return aRetorno


