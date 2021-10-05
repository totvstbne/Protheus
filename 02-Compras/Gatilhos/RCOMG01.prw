#INCLUDE "Protheus.CH"

Static cCodUsado	//Codigo reservado
/*/{Protheus.doc} RCOMG01
Gerar sequencial do código de produto
//teste 10

@type function
@obs
Máscara: TTGGGGSSSS
T = Tipo do Produto
G = Grupo de Produtos
S = Sequencial de código do Produto
/*/
User Function RCOMG01()
	Local aArea		:= GetArea()
	Local nTamSb1	:= GetSx3Cache("B1_COD","X3_TAMANHO")
	Local nTamTP	:= GetSx3Cache("B1_TIPO","X3_TAMANHO")
	Local nTamGrp	:= GetSx3Cache("B1_GRUPO","X3_TAMANHO")
	Local cCod		:= Space(nTamSb1)
	Local cAliasQry
	Local cQuery
	Local nVez		:= 0
	Local nTamSeq	:= 4
	If !Empty(M->B1_TIPO) .AND. !Empty(M->B1_GRUPO)
		//Busca o sequencia da tabela
		cQuery	:= "SELECT MAX(B1_COD) AS B1_COD FROM "+RetSqlName("SB1")+" SB1 WHERE B1_FILIAL='"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_=' ' AND B1_TIPO='"+M->B1_TIPO+"' AND B1_GRUPO='"+M->B1_GRUPO+"'"
		cAliasQry	:= MPSysOpenQuery(cQuery)
		IF (cAliasQry)->(!Eof())
			cCod	:= M->B1_TIPO+M->B1_GRUPO+SOMA1(SUBSTR((cAliasQry)->B1_COD,nTamTP+nTamGrp+1,nTamSeq))
		Else
			cCod	:= M->B1_TIPO+M->B1_GRUPO+StrZero(1,nTamSeq)
		Endif
		cCod	:= PADR(cCod,nTamSb1)
		(cAliasQry)->(DbCloseArea())
		If !Empty(cCodUsado)	//Se a sessão atual já tem um numero reservado
			UnLockByName(cCodUsado,.F.,.F.)
		EndIf
		SB1->(DbSetOrder(1))
		While SB1->(DbSeek("SB1"+xFilial("SB1")+cCod)) .OR. !LockByName("SB1"+xFilial("SB1")+cCod,.F.,.F.)	//Verifica numero reservado
			cCod	:= PADR(SubStr(cCod,1,nTamTP+nTamGrp)+SOMA1(SubStr(cCod,nTamTP+nTamGrp+1,nTamSeq)),nTamSb1)	//Soma1
			If nVez>50	//Tratar loop da rotina
				cCod:= Space(nTamSb1)
				Exit
			EndIf
			nVez++
		EndDo
		cCodUsado:= "SB1"+xFilial("SB1")+cCod
	EndIf

	RestArea(aArea)
Return cCod
