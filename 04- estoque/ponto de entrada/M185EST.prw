#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M185EST
Estorno da requisição
@author Diogo
@since 27/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function M185EST()
	If !Empty(SCP->CP_YORCSRV) .and. .F.	//Se tem orçamento de serviço preenchido INATIVADO
		At995ExcC(SCP->CP_YORCSRV,SCP->CP_YCODTWZ,.T.)	//Excluir movimento de custo
		If !Empty(SCP->CP_YITORC)
			//ATUALIZA O SALDO DO MATERIAL E EXCLUI APONTAMENTO DO MATERIAL
			If SCP->CP_YTPCOD=="3"		//Material de consumo
				TFH->(DbSetOrder(1))	//TFH_FILIAL+TFH_COD
				If TFH->(DbSeek(xFilial("TFH")+SCP->CP_YITORC))
					RecLock("TFH",.F.)
					TFH->TFH_SLD	:=	TFH->TFH_SLD + SCP->CP_QUANT	//Volta saldo
					MsUnlock()
				EndIf
				TFT->(DbSetOrder(1))	//TFT_FILIAL+TFT_CODIGO
				If TFT->(DbSeek(xFilial("TFT")+SCP->CP_YCODMAT))
					RecLock("TFT",.F.)
					TFT->(DbDelete())
					MsUnLock()
				EndIf
			ElseIf SCP->CP_YTPCOD=="2"	//Matériais operacionais
				TFG->(DbSetOrder(1))	//TFG_FILIAL+TFG_COD
				If TFG->(DbSeek(xFilial("TFG")+SCP->CP_YITORC))
					RecLock("TFG",.F.)
					TFG->TFG_SLD	:=	TFG->TFG_SLD + SCP->CP_QUANT	//Volta saldo
					MsUnlock()
				EndIf
				TFS->(DbSetOrder(1))	//TFS_FILIAL+TFS_CODIGO
				If TFS->(DbSeek(xFilial("TFS")+SCP->CP_YCODMAT))
					RecLock("TFS",.F.)
					TFS->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf
return