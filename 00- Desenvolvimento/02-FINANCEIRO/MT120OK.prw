#Include "Protheus.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120OK                                                                                               |
 | Autora: Alana Oliveira em 19.11.2021                                                                         |
 | Desc:  Ponto de Entrada para validar especificas, executado antes da grava��o do pedido de compras           |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6085483                                         |
 *--------------------------------------------------------------------------------------------------------------*/


 User Function MT120OK()
 
	Local lRet := .T.
	Local i
	Local nC7_TES    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TES"})
	Local nC7_YNATUR    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_YNATUR"})

	IF Inclui .OR. ALTERA

		If Empty(cXCartao) // cXCartao : vari�vel p�blica criada no ponto de entrada MT120TEL		
			Alert("Informe se pagamento � por cart�o de cr�dito")
			lRet:= .F.
		Endif

		If lRet .and. Empty(cXCartao) // cXCartao : vari�vel p�blica criada no ponto de entrada MT120TEL
			Alert("Informe se pagamento � por cart�o de cr�dito")
			lRet:= .F.
		Endif

		IF lRet .and. empty(nCombPCPF)
			lRet := .F.
			Alert("Favor preencher o campo PC/PF. Campo Obrigat�rio!")
		ENDIF

		IF lRet .and. nCombPCPF == "PF"
			For i:=1 to len(aCols)
				If lRet .and. empty(alltrim(aCols[i, nC7_TES]))
					lRet := .f.
					Alert("TES obrigat�rio para o tipo 'PF' - Linha: "+cvaltochar(i))
					exit
				EndIf
				If lRet .and. empty(alltrim(aCols[i, nC7_YNATUR]))
					lRet := .f.
					Alert("Natureza obrigat�rio para o tipo 'PF' - Linha: "+cvaltochar(i))
					exit
				EndIf
			Next i
		EndIf
	ENDIF
 
 Return lRet
