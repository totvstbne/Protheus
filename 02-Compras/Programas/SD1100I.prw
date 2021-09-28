#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} SD1100I
Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. O registro no SD1 já se encontra travado (Lock). Será executado uma vez para cada item do Documento de Entrada que está sendo incluída.
@author Saulo Gomes Martins
@since 27/07/2018
@version 1.0

@type function
@see http://tdn.totvs.com/display/public/PROT/SD1100I
/*/
user function SD1100I()
	Local lConFrete	:= PARAMIXB[1]	//Conhecimento de Frete
	Local lConImp	:= PARAMIXB[2]	//Conhecimento de Importacao.
	Local nOper		:= PARAMIXB[3]	//Operação
	Local oModel
	Local cCod		:= ""
	Local cCodMat	:= ""
	
	Reclock("SD1",.F.)	
		SD1->D1_YDTLAN	:= date()
		SD1->D1_YUSUARI	:= upper(cUserName)
		SD1->D1_YHORA	:= substr(time(),1,5) 
	msUnlock()
	
	If !Empty(SD1->D1_YORCSRV)	//Se tem orçamento de serviço preenchido
		//Incluir registro centro de custo
		cCod		:= GetSxeNum('TWZ','TWZ_CODIGO')
		ConfirmSx8()
		oModel		:= FwLoadModel("TECA995")
		TFJ->(DbSetOrder(1))	//TFJ_FILIAL+TFJ_CODIGO
		If TFJ->(DbSeek(xFilial("TFJ")+SD1->D1_YORCSRV))
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel:SetOperation( MODEL_OPERATION_INSERT )
		EndIf
		lRet		:= oModel:Activate()
		oModel:GetModel("TWZDETAIL"):AddLine()
		If lRet
			If oModel:GetModel("TWZDETAIL"):IsEmpty()
				oModel:GetModel("TWZDETAIL"):AddLine()
			EndIf
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_CODIGO"		,cCod)
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_LOCAL"			,SD1->D1_YLOCATE)
			If Empty(SD1->D1_YITORC)
				lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_TPSERV"	,"5")
				lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YPRD"		,SD1->D1_COD)
			Else
				lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_TPSERV"	,SD1->D1_YTPCOD) //2=MI;3=MC
				lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_ITEM"		,SD1->D1_YITORC)
				lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_PRODUT"	,SD1->D1_COD)
				lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_ROTINA"	,"MATA103")
			EndIf

			aRet:= u_fQryProd(SD1->D1_FILIAL,SD1->D1_YORCSRV,SD1->D1_YLOCATE,SD1->D1_YITORC,SD1->D1_YTPCOD)
			cItB:= iif(!empty(aRet[2]), alltrim(substr(aRet[2],3,len(aRet[2]))),"")
			If !empty(cItB)
				u_fSetCTD(cItB,aRet[2])
			Endif	

			Reclock("SD1",.F.)
				SD1->D1_CC		:= aRet[1]
				SD1->D1_ITEMCTA	:= cItB
				SD1->D1_YVLMI	:= iif(SD1->D1_YTPCOD == "2",Round(SD1->D1_TOTAL,2),0)  
				SD1->D1_YVLMC  	:= iif(SD1->D1_YTPCOD == "3",Round(SD1->D1_TOTAL,2),0)
			MsUnlock()
			
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YDTLAN"	, SD1->D1_YDTLAN)
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YUSUAR"	, SD1->D1_YUSUARI)
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YHORA"		, SD1->D1_YHORA)
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YCC"		, aRet[1])
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YCTB"		, iif(!empty(cItB),Posicione("SB1",1,xFilial("SB1")+aRet[2],"B1_CONTA"),""))
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_YITCTB"	, cItB)
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_OBSERV"	,"NF:"+SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + SD1->D1_COD)
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_VLCUST"	,Round(SD1->D1_TOTAL,2) )
			lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_DTINC"		,dDEmissao)
		EndIf
		If lRet .AND. ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
		If lRet
			If !Empty(SD1->D1_YITORC)
				//ATUALIZA O SALDO DO MATERIAL E INCLUI APONTAMENTO DO MATERIAL
				//2=MI;3=MC
				If SD1->D1_YTPCOD=="3"		//Material de consumo
					TFH->(DbSetOrder(1))	//TFH_FILIAL+TFH_COD
					If TFH->(DbSeek(xFilial("TFH")+SD1->D1_YITORC))
						RecLock("TFH",.F.)
						TFH->TFH_SLD	:=	TFH->TFH_SLD - SD1->D1_QUANT
						MsUnlock()
					EndIf
					
					//Verifica se a numeração está em uso
					cCodMat:= fNumTFT()
					
					RecLock("TFT",.T.)
					TFT->TFT_FILIAL	:= xFilial("TFT")
					//cCodMat			:= GetSxeNum("TFT","TFT_CODIGO")
					TFT->TFT_CODIGO	:= cCodMat
					TFT->TFT_CODTFH	:= SD1->D1_YITORC
					TFT->TFT_PRODUT	:= SD1->D1_COD
					TFT->TFT_QUANT	:= SD1->D1_QUANT
					TFT->TFT_CC		:= SD1->D1_CC
					TFT->TFT_LOCAL	:= SD1->D1_LOCAL
					TFT->TFT_LOCALI	:= ""
					TFT->TFT_LOTECT	:= ""
					TFT->TFT_NUMLOT	:= ""
					TFT->TFT_NUMSER	:= ""
					TFT->TFT_TM		:= ""
					TFT->TFT_NUMMOV	:= SD1->D1_NUMSEQ
					TFT->TFT_DTAPON	:= dDatabase
					TFT->TFT_ITAPUR	:= ""
					TFL->(DbSetOrder(2))	//TFL_FILIAL+TFL_CODPAI
					TFT->TFT_CODTFL	:= SD1->D1_YLOCATE
					TFT->TFT_CODTWZ	:= cCod
					MsUnLock()
					//ConfirmSX8()
				ElseIf SD1->D1_YTPCOD=="2"	//Matériais operacionais
					TFG->(DbSetOrder(1))	//TFG_FILIAL+TFG_COD
					If TFG->(DbSeek(xFilial("TFG")+SD1->D1_YITORC))
						RecLock("TFG",.F.)
						TFG->TFG_SLD	:=	TFG->TFG_SLD - SD1->D1_QUANT
						MsUnlock()
					EndIf
					RecLock("TFS",.T.)
					TFS->TFS_FILIAL	:= xFilial("TFS")
					//cCodMat		:= GetSxeNum("TFS","TFS_CODIGO")
					cCodMat			:= fNumTFS()
					TFS->TFS_CODIGO	:= cCodMat
					TFS->TFS_CODTFG	:= SD1->D1_YITORC
					TFS->TFS_PRODUT	:= SD1->D1_COD
					TFS->TFS_QUANT	:= SD1->D1_QUANT
					TFS->TFS_CC		:= SD1->D1_CC
					TFS->TFS_LOCAL	:= SD1->D1_LOCAL
					TFS->TFS_LOCALI	:= ""
					TFS->TFS_LOTECT	:= ""
					TFS->TFS_NUMLOT	:= ""
					TFS->TFS_NUMSER	:= ""
					TFS->TFS_TM		:= ""
					TFS->TFS_NUMMOV	:= SD1->D1_NUMSEQ
					TFS->TFS_DTAPON	:= dDatabase
					TFS->TFS_ITAPUR	:= ""
					TFL->(DbSetOrder(2))	//TFL_FILIAL+TFL_CODPAI
					TFS->TFS_CODTFL	:= SD1->D1_YLOCATE
					TFS->TFS_MOV	:= "1"
					TFS->TFS_CODTWZ	:= cCod
					MsUnLock()
					//ConfirmSX8()
				EndIf
			EndIf
		Else
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
			Mostraerro()
			oModel:DeActivate()
			Return .F.
		EndIf
		oModel:DeActivate()
		SD1->D1_YCODTWZ	:=	cCod	//CODIGO DO REGISTRO DE CUSTO
		SD1->D1_YCODMAT	:=	cCodMat	//CODIGO DO APONTAMENTO
	EndIf
return

Static Function fNumTFT
	cRet:= 	GetSxeNum("TFT","TFT_CODIGO")
	ConfirmSX8()

	cQuery:= "SELECT TFT_CODIGO FROM "+RetSqlName("TFT")+" TFT "
	cQuery+= "WHERE TFT.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFT_FILIAL = '"+xFilial("TFT")+"' AND "
	cQuery+= "TFT_CODIGO = '"+cRet+"' "
	If select("QRTFT") > 0
		QRTFT->(dbCloseArea())
	Endif
	tcQuery cQuery new Alias QRTFT
	If QRTFT->(!Eof())
		QRTFT->(dbCloseArea())
		fNumTFT()
	Endif
Return cRet

Static Function fNumTFS
	cRet:= 	GetSxeNum("TFS","TFS_CODIGO")
	ConfirmSX8()

	cQuery:= "SELECT TFS_CODIGO FROM "+RetSqlName("TFS")+" TFS "
	cQuery+= "WHERE TFS.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFS_FILIAL = '"+xFilial("TFS")+"' AND "
	cQuery+= "TFS_CODIGO = '"+cRet+"' "
	If select("QRTFS") > 0
		QRTFS->(dbCloseArea())
	Endif	
	tcQuery cQuery new Alias QRTFS
	If QRTFS->(!Eof())
		QRTFS->(dbCloseArea())
		fNumTFS()
	Endif
Return cRet