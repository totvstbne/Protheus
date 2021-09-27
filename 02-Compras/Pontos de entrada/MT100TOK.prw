#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} MT100TOK
Valida a inclus�o de NF, Este P.E. � chamado na fun��o A103Tudok()
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
			If !aCols[nCont][Len(aCols[nCont])]	//Linha n�o deletada
				cTes	:= GDFieldGet("D1_TES",nCont)
				cCC		:= GDFieldGet("D1_CC",nCont)
				cMovEst	:= POSICIONE("SF4",1,xFilial("SF4")+cTes,"F4_ESTOQUE")	//Se movimenta estoque
				cTPLOT	:= POSICIONE("CTT",1,xFilial("CTT")+cCC,"CTT_TPLOT")	//Tipo Lota��o
				If cMovEst=="N" .AND. cTPLOT=="04"	//N�o movimenta estoque e tipo lota��o 04 (Pessoa Juridica Tomadora De Servicos Prestados Mediante Cessao De Mao De Obra, Exceto Contratante De Cooperativa, Nos Termos Da Lei 8.212/1991.)
					//VERIFICA SE CAMPOS OBRIGATORIOS FORAM PREENCHIDOS
					If Empty(GDFieldGet("D1_YORCSRV",nCont)) .OR. Empty(GDFieldGet("D1_YLOCATE",nCont))
						Aviso("MT100TOK","Campos obrigatorio n�o preenchidos!"+CRLF+;
						"Os campos '"+GetSx3Cache("D1_YORCSRV","X3_TITULO")+"'"+;
						",'"+GetSx3Cache("D1_YLOCATE","X3_TITULO")+"'"+;
						" s�o obrigatorios para esse centro de custo e TES. Linha "+cValToChar(nCont);
						,{"OK"})
						lRet	:= .F.
						Return .F.
					EndIf
					//VALIDA��O DA QUANTIDADE
					If !Empty(GDFieldGet("D1_YITORC",nCont))	//Preenchido material do contrato
						If Empty(GDFieldGet("D1_YTPCOD",nCont))
							Aviso("MT100TOK","Tipo de codigo n�o preenchido, necessario preenchimento quando item do or�amento estiver preenchido! Linha "+cValToChar(nCont);
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
								Aviso("MT100TOK","Material n�o encontrado no contrato, verifique o c�digo digitado ou n�o preencha o campo item do or�amento quando n�o dispon�vel no contrato! Linha "+cValToChar(nCont);
								,{"OK"})
								lRet	:= .F.
								Return .F.
							ElseIf aCodSld[nPos][2]>TFH->TFH_SLD
								Aviso("MT100TOK","Saldo do contrato � menor que a quantidade digitada do material "+GDFieldGet("D1_YITORC",nCont)+CRLF+;
												"Saldo:"+cValToChar(TFH->TFH_SLD)+CRLF+;
												"Quantidade digitada:"+cValToChar(aCodSld[nPos][2])+CRLF;
								,{"OK"})
								lRet	:= .F.
								Return .F.
							EndIf
						ElseIf GDFieldGet("D1_YTPCOD",nCont)=="2"		//Mat�riais operacionais
							TFG->(DbSetOrder(1))	//TFG_FILIAL+TFG_COD
							If TFG->(!DbSeek(xFilial("TFG")+GDFieldGet("D1_YITORC",nCont)))
								Aviso("MT100TOK","Material n�o encontrado no contrato, verifique o c�digo digitado ou n�o preencha o campo item do or�amento quando n�o dispon�vel no contrato! Linha "+cValToChar(nCont);
								,{"OK"})
								lRet	:= .F.
								Return .F.
							ElseIf aCodSld[nPos][2]>TFG->TFG_SLD	//Mat�riais operacionais
								Aviso("MT100TOK","Saldo do contrato � menor que a quantidade digitada do material "+GDFieldGet("D1_YITORC",nCont)+CRLF+;
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
						//APENAS VALIDA, N�O INCLUI
						//lRet := oModel:CommitData()
					EndIf
					If !lRet
						aErro   := oModel:GetErrorMessage()
						AutoGrLog( "ERRO AO INFORMAR CUSTO DO OR�AMENTO" )
						AutoGrLog( "Id do formul�rio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
						AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
						AutoGrLog( "Id do formul�rio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
						AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
						AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
						AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
						AutoGrLog( "Mensagem da solu��o:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
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