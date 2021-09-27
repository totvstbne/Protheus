#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} MTA105OK
Valida a inclusão de NF, Este P.E. é chamado na função A103Tudok()
@author Diogo
@since 27/07/2018
@version 1.0
@return lRet, Se Verdadeiro (.T.), atualizara o movimento, de acordo com os dados digitados pelo usuario ; Se for falso (.F.) nao prosseguira com a implantacao
/*/
User Function MTA105OK()

	Local lRet	:= .T.
	Local nCont
	Local cOrcSrv,nPos,nCust
	Local aCodSld	:= {}	//Array com Codigo dos items e quantidade total
	If lRet
		For nCont:=1 to Len(aCols)
			If !aCols[nCont][Len(aCols[nCont])] .and. !empty(GDFieldGet("CP_YORCSRV",nCont)) //Linha não deletada
				oModel	:= FwLoadModel("TECA995")	//APONTAMENTO DE CUSTO
				TFJ->(DbSetOrder(1))	//TFJ_FILIAL+TFJ_CODIGO
				If TFJ->(DbSeek(xFilial("TFJ")+GDFieldGet("CP_YORCSRV",nCont)))
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
				Else
					oModel:SetOperation( MODEL_OPERATION_INSERT )
				EndIf
				lRet:= oModel:Activate()
					If lRet
						If !oModel:GetModel("TWZDETAIL"):IsEmpty()
							oModel:GetModel("TWZDETAIL"):AddLine()
						EndIf
						lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_LOCAL"	,GDFieldGet("CP_YLOCATE",nCont))
						If Empty(GDFieldGet("CP_YITORC",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_TPSERV"	,"5")
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_OBSERV"	,GDFieldGet("CP_NUM",nCont))
						Else
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_TPSERV"	,GDFieldGet("CP_YTPCOD",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_ITEM"		,GDFieldGet("CP_YITORC",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_PRODUT"	,GDFieldGet("CP_NUM",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_ROTINA"	,"MATA105")
						EndIf
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+GDFieldGet("CP_PRODUTO",nCont)))
						If SB1->B1_UPRC> 0
							nCust:= SB1->B1_UPRC
						Else
							nCust:= 1 
						Endif
						lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_VLCUST"	,GDFieldGet("CP_QUANT",nCont)*nCust)
						lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_DTINC"		,date())
					EndIf
					If lRet .AND. ( lRet := oModel:VldData() )
						//APENAS VALIDA, NÃO INCLUI
						//lRet := oModel:CommitData()
					EndIf
					If !lRet
						aErro   := oModel:GetErrorMessage()
						AutoGrLog( "ERRO AO INFORMAR CUSTO DO ORÇAMENTO" )
						AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
						AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
						AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
						AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
						AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
						AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
						AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
						AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
						AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
						AutoGrLog( "Linha:                     " + ' [' + AllToChar( nCont     ) + ']' )
						Mostraerro()
						oModel:DeActivate()
						Return .F.
					EndIf
					oModel:DeActivate()
				//EndIF
			EndIf
		Next
	EndIf
Return lRet
