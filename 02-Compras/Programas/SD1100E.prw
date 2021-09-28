#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} SD1100E
Antes de deletar o registro no SD1 na exclusao da Nota de Entrada
@author Saulo Gomes Martins
@since 06/08/2018
@version 1.0

@type function
/*/
user function SD1100E()
	Local lConFrete	:= PARAMIXB[1]	//Conhecimento de Frete
	Local lConImp	:= PARAMIXB[2]	//Conhecimento de Importacao.
	If !Empty(SD1->D1_YORCSRV)	//Se tem orçamento de serviço preenchido
		At995ExcC(SD1->D1_YORCSRV,SD1->D1_YCODTWZ,.T.)	//Excluir movimento de custo
		If !Empty(SD1->D1_YITORC)
			//ATUALIZA O SALDO DO MATERIAL E EXCLUI APONTAMENTO DO MATERIAL
			If SD1->D1_YTPCOD=="3"		//Material de consumo
				TFH->(DbSetOrder(1))	//TFH_FILIAL+TFH_COD
				If TFH->(DbSeek(xFilial("TFH")+SD1->D1_YITORC))
					RecLock("TFH",.F.)
					TFH->TFH_SLD	:=	TFH->TFH_SLD + SD1->D1_QUANT	//Volta saldo
					MsUnlock()
				EndIf
				TFT->(DbSetOrder(1))	//TFT_FILIAL+TFT_CODIGO
				If TFT->(DbSeek(xFilial("TFT")+SD1->D1_YCODMAT))
					RecLock("TFT",.F.)
					TFT->(DbDelete())
					MsUnLock()
				EndIf
			ElseIf SD1->D1_YTPCOD=="2"	//Matériais operacionais
				TFG->(DbSetOrder(1))	//TFG_FILIAL+TFG_COD
				If TFG->(DbSeek(xFilial("TFG")+SD1->D1_YITORC))
					RecLock("TFG",.F.)
					TFG->TFG_SLD	:=	TFG->TFG_SLD + SD1->D1_QUANT	//Volta saldo
					MsUnlock()
				EndIf
				TFS->(DbSetOrder(1))	//TFS_FILIAL+TFS_CODIGO
				If TFS->(DbSeek(xFilial("TFS")+SD1->D1_YCODMAT))
					RecLock("TFS",.F.)
					TFS->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf
return