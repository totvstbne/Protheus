#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} MT100TOK
Valida a inclusão de NF, Este P.E. é chamado na função A103Tudok()
@author Saulo Gomes Martins
@since 27/07/2018
@version 1.0
@return lRet, Se Verdadeiro (.T.), atualizara o movimento, de acordo com os dados digitados pelo usuario ; Se for falso (.F.) nao prosseguira com a implantacao

@type function
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6085400
/*/
User Function MT100TOK()
	Local lRet	:= PARAMIXB[1]	//Retorno do PE
	Local nCont
	Local cCC,cTes,cMovEst,cTPLOT
	Local cOrcSrv,nPos
	Local aCodSld	:= {}	//Array com Codigo dos items e quantidade total
	If lRet
		For nCont:=1 to Len(aCols)
			If !aCols[nCont][Len(aCols[nCont])]	//Linha não deletada
				cTes	:= GDFieldGet("D1_TES",nCont)
				cCC		:= GDFieldGet("D1_CC",nCont)
				cMovEst	:= POSICIONE("SF4",1,xFilial("SF4")+cTes,"F4_ESTOQUE")	//Se movimenta estoque
				cTPLOT	:= POSICIONE("CTT",1,xFilial("CTT")+cCC,"CTT_TPLOT")	//Tipo Lotação
				If cMovEst=="N" .AND. cTPLOT=="04"	//Não movimenta estoque e tipo lotação 04 (Pessoa Juridica Tomadora De Servicos Prestados Mediante Cessao De Mao De Obra, Exceto Contratante De Cooperativa, Nos Termos Da Lei 8.212/1991.)
					//VERIFICA SE CAMPOS OBRIGATORIOS FORAM PREENCHIDOS
					If Empty(GDFieldGet("D1_YORCSRV",nCont)) .OR. Empty(GDFieldGet("D1_YLOCATE",nCont))
						Aviso("MT100TOK","Campos obrigatorio não preenchidos!"+CRLF+;
						"Os campos '"+GetSx3Cache("D1_YORCSRV","X3_TITULO")+"'"+;
						",'"+GetSx3Cache("D1_YLOCATE","X3_TITULO")+"'"+;
						" são obrigatorios para esse centro de custo e TES. Linha "+cValToChar(nCont);
						,{"OK"})
						lRet	:= .F.
						Return .F.
					EndIf
					//VALIDAÇÃO DA QUANTIDADE
					If !Empty(GDFieldGet("D1_YITORC",nCont))	//Preenchido material do contrato
						If Empty(GDFieldGet("D1_YTPCOD",nCont))
							Aviso("MT100TOK","Tipo de codigo não preenchido, necessario preenchimento quando item do orçamento estiver preenchido! Linha "+cValToChar(nCont);
								,{"OK"})
								lRet	:= .F.
							Return .F.
						EndIf
						nPos	:= aScan(aCodSld,{|x| x[1]==GDFieldGet("D1_YITORC",nCont) })
						If nPos==0
							AADD(aCodSld,{GDFieldGet("D1_YITORC",nCont),0})
							nPos	:= Len(aCodSld)
						EndIf
						aCodSld[nPos][2]	+= GDFieldGet("D1_QUANT",nCont)
						If GDFieldGet("D1_YTPCOD",nCont)=="3"		//Material de consumo
							TFH->(DbSetOrder(1))	//TFH_FILIAL+TFH_COD
							If TFH->(!DbSeek(xFilial("TFH")+GDFieldGet("D1_YITORC",nCont)))
								Aviso("MT100TOK","Material não encontrado no contrato, verifique o código digitado ou não preencha o campo item do orçamento quando não disponível no contrato! Linha "+cValToChar(nCont);
								,{"OK"})
								lRet	:= .F.
								Return .F.
							ElseIf aCodSld[nPos][2]>TFH->TFH_SLD
								Aviso("MT100TOK","Saldo do contrato é menor que a quantidade digitada do material "+GDFieldGet("D1_YITORC",nCont)+CRLF+;
												"Saldo:"+cValToChar(TFH->TFH_SLD)+CRLF+;
												"Quantidade digitada:"+cValToChar(aCodSld[nPos][2])+CRLF;
								,{"OK"})
								lRet	:= .F.
								Return .F.
							EndIf
						ElseIf GDFieldGet("D1_YTPCOD",nCont)=="2"		//Matériais operacionais
							TFG->(DbSetOrder(1))	//TFG_FILIAL+TFG_COD
							If TFG->(!DbSeek(xFilial("TFG")+GDFieldGet("D1_YITORC",nCont)))
								Aviso("MT100TOK","Material não encontrado no contrato, verifique o código digitado ou não preencha o campo item do orçamento quando não disponível no contrato! Linha "+cValToChar(nCont);
								,{"OK"})
								lRet	:= .F.
								Return .F.
							ElseIf aCodSld[nPos][2]>TFG->TFG_SLD	//Matériais operacionais
								Aviso("MT100TOK","Saldo do contrato é menor que a quantidade digitada do material "+GDFieldGet("D1_YITORC",nCont)+CRLF+;
												"Saldo:"+cValToChar(TFG->TFG_SLD)+CRLF+;
												"Quantidade digitada:"+cValToChar(aCodSld[nPos][2])+CRLF;
								,{"OK"})
								lRet	:= .F.
								Return .F.
							EndIf
						EndIf
					EndIf
					//VALIDA APONTAMENTO DE CUSTO
					oModel	:= FwLoadModel("TECA995")	//APONTAMENTO DE CUSTO
					TFJ->(DbSetOrder(1))	//TFJ_FILIAL+TFJ_CODIGO
					If TFJ->(DbSeek(xFilial("TFJ")+GDFieldGet("D1_YORCSRV",nCont)))
						oModel:SetOperation( MODEL_OPERATION_UPDATE )
					Else
						oModel:SetOperation( MODEL_OPERATION_INSERT )
					EndIf
					lRet		:= oModel:Activate()
					If lRet
						If !oModel:GetModel("TWZDETAIL"):IsEmpty()
							oModel:GetModel("TWZDETAIL"):AddLine()
						EndIf
						lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_LOCAL"	,GDFieldGet("D1_YLOCATE",nCont))
						If Empty(GDFieldGet("D1_YITORC",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_TPSERV"	,"5")
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_OBSERV"	,GDFieldGet("D1_COD",nCont))
						Else
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_TPSERV"	,GDFieldGet("D1_YTPCOD",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_ITEM"		,GDFieldGet("D1_YITORC",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_PRODUT"	,GDFieldGet("D1_COD",nCont))
							lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_ROTINA"	,"MATA103")
						EndIf
						lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_VLCUST"	,GDFieldGet("D1_TOTAL",nCont))
						lRet	:= lRet .AND. oModel:GetModel("TWZDETAIL"):SetValue("TWZ_DTINC"		,dDEmissao)
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
				EndIF
			EndIf
		Next
	EndIf
Return lRet