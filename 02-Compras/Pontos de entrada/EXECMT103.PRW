#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

User Function EXEC103(_xFilial, _xPedido, _xNum, _xSerie, _xEspecie)
    Local aArea := getArea()
	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	Local aItensRat := {}
	Local aCodRet := {}
	Local aParamAux := {}
	Local nOpc := 3
	Local nX := 0

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	SC7->(DBSETORDER(1))
	If SC7->(DBSEEK(_xFilial+_xPedido))

        //Cabeçalho
		aadd(aCab,{"F1_TIPO"    ,"N"             ,NIL})
		aadd(aCab,{"F1_FORMUL"  ,"N"             ,NIL})
		aadd(aCab,{"F1_DOC"     ,_xNum           ,NIL})
		aadd(aCab,{"F1_SERIE"   ,_xSerie         ,NIL})
		aadd(aCab,{"F1_EMISSAO" ,DDATABASE       ,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,DDATABASE       ,NIL})
		aadd(aCab,{"F1_FORNECE" ,SC7->C7_FORNECE ,NIL})
		aadd(aCab,{"F1_LOJA"    ,SC7->C7_LOJA    ,NIL})
		aadd(aCab,{"F1_ESPECIE" ,_xEspecie       ,NIL})
		aadd(aCab,{"F1_COND"    ,SC7->C7_COND    ,NIL})
		aadd(aCab,{"F1_DESPESA" ,0               ,NIL})
		aadd(aCab,{"F1_DESCONT" ,0               ,Nil})
		aadd(aCab,{"F1_SEGURO"  ,0               ,Nil})
		aadd(aCab,{"F1_FRETE"   ,0               ,Nil})
		aadd(aCab,{"F1_MOEDA"   ,1               ,Nil})
		aadd(aCab,{"F1_TXMOEDA" ,1               ,Nil})
		aadd(aCab,{"F1_STATUS"  ,"A"             ,Nil})
		IF !EMPTY(SC7->C7_YNATUR)
			AADD(aCab,{"E2_NATUREZ" ,SC7->C7_YNATUR                ,NIL})
		ENDIF
        //Itens 
		nX := 1
		While !SC7->(eof()) .AND. SC7->C7_NUM == _xPedido
			aItem := {}
			aadd(aItem,{"D1_ITEM"   ,StrZero(nX,4)                             ,NIL})
			aadd(aItem,{"D1_COD"    ,PadR(SC7->C7_PRODUTO,TamSx3("D1_COD")[1]) ,NIL})
			aadd(aItem,{"D1_UM"     ,SC7->C7_UM                                ,NIL})
			aadd(aItem,{"D1_LOCAL"  ,SC7->C7_LOCAL                             ,NIL})
			aadd(aItem,{"D1_QUANT"  ,SC7->C7_QUANT                             ,NIL})
			aadd(aItem,{"D1_VUNIT"  ,SC7->C7_PRECO                             ,NIL})
			aadd(aItem,{"D1_TOTAL"  ,SC7->C7_TOTAL                             ,NIL})
			aadd(aItem,{"D1_TES"    ,SC7->C7_TES                               ,NIL})
			aadd(aItem,{'D1_PEDIDO ',SC7->C7_NUM                               ,NIL}) // Número do Pedido de Compras
			aadd(aItem,{'D1_ITEMPC ',SC7->C7_ITEM                              ,NIL}) // Item do Pedido de Compras
			aAdd(aItem,{"LINPOS"    ,"D1_ITEM",  StrZero(nX,4)                 ,NIL}) //ou SD1->D1_ITEM  se estiver posicionado.

			aadd(aItens,aItem)

			SC7->(dbskip())
		EndDo

		//3-Inclusão / 4-Classificação / 5-Exclusão
		MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aCab,aItens,nOpc,aParamAux,aItensRat,aCodRet)

		If lMsErroAuto
			MostraErro()
		EndIf

	EndIf

    restArea(aArea)

Return
