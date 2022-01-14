#include "rwmake.ch"
#include "tcbrowse.ch"
#Include "colors.ch"
#include "vkey.ch"
#Include "Font.ch"
#include "Ap5Mail.ch"
#Include 'Protheus.ch'
  
 /*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120TEL                                                                                              |  
 | Autora: Alana Oliveira em 19.11.2021                                                                         |                 |
 | Desc:  Ponto de Entrada para adicionar campos no cabe�alho do pedido de compra                               |
 | Link:  http://tdn.totvs.com/display/public/mp/MT120TEL                                                       |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente ser� edit�vel, na Inclus�o, Altera��o e C�pia
    Local cOpera
    Local cCartao 
    Public cXOpera := ""
    Public cXCartao:= ""  
 
    //Define o conte�do para os campos
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXOpera := CriaVar("C7_YBANDEI",.F.)
        cXCartao:= CriaVar("C7_YCARTAO",.F.)
    Else
        cXOpera := SC7->C7_YBANDEI
        cXCartao:= SC7->C7_YCARTAO
    EndIf
 
    //Criando na janela o campo OBS
    @ 062, aPosGet[1,08] - 002 SAY Alltrim(RetTitle("C7_YCARTAO")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET cCartao VAR cXCartao SIZE 025, 006 OF oDlg COLORS 0, 16777215 PIXEL VALID (U_YVLDCART(cXCartao))
    @ 062, aPosGet[1,10] - 038 SAY Alltrim(RetTitle("C7_YBANDEI")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,11] - 045 MSGET cOpera VAR cXOpera SIZE 025, 006 OF oDlg F3 "ZF1" COLORS 0, 16777215  PIXEL VALID (U_YVLDOPER(cXCartao,cXOpera))
    cCartao:bHelp := {|| ShowHelpCpo( "C7_YBANDEI", {GetHlpSoluc("C7_YBANDEI")[1]}, 5  )}
    cOpera:bHelp  := {|| ShowHelpCpo( "C7_YCARTAO", {GetHlpSoluc("C7_YCARTAO")[1]}, 5  )}

    //Se n�o houver edi��o, desabilita os gets
    If !lEdit
        cOpera:lActive  := .F.
        cCartao:lActive := .F.
    EndIf
 
    RestArea(aArea)
Return

/* 
Fun��o para validar operadora de cart�o de cr�dito
Autora : Alana Oliveira em 19.11.2021
*/

User Function YVLDOPER(cCartao,cOpera)

Local lRet := .T.

If UPPER(cCartao) == "S" // Se cart�o for igual a SIM - Valida Operadora

    If Empty(cOpera)

	    Alert("Informar Bandeira do Cart�o!")
        lRet:= .F.

    Else 

	    lRet:= .F.
	    DbSelectArea("ZF1")
	    ZF1->(DbSetOrder(1))
	    If Dbseek(xFilial("ZF1")+cOpera)	
            lRet:= .T.
        Endif
	   // while SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "_1"
		//	cCod:= UPPER(ALLTRIM(SX5->X5_CHAVE))
		//	IF cCod == UPPER(AllTrim(cOpera)) 
	//			lRet:= .T.
	//		Endif
	//	    SX5->(DBSKIP())	
	 //   end

        IF !lRet
            Alert("Bandeira do Cart�o Inv�lida!")
        Endif
    ENDIF

Else

    IF !Empty(cOpera)
        Alert("Bandeira deve estar vazia quando pagamento n�o for por cart�o!")
        lRet:= .F.
    Endif

Endif

Return lRet 

/* 
Fun��o para validar campo cart�o
Autora : Alana Oliveira em 19.11.2021
*/

User Function YVLDCART(cCartao)

Local lRet:=.T.

If Empty(cCartao)
    Alert("Informar se o pagamento � por cart�o de cr�dito : S (Sim) ou N (N�o)!")
    lRet:=.F.
elseif  !("N" $ UPPER(cCartao)) .And. !("S" $ UPPER(cCartao))
    Alert("Conte�do permitido para o campo : S (Sim) ou N (N�o)!")
    lRet:=.F.
Endif

Return lRet
