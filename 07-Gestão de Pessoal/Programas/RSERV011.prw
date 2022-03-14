#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'
/*/{Protheus.doc} RSERV011
Beneficios por Local de Atendimento - Vale Transporte / Vale Alimentação
@author Diogo/João Filho
@since 20/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function RSERV011()
	Local oBrowse
	Private aRotina:= {}

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'ZA2' )
	oBrowse:AddLegend( "ZA2_COD<>'' "	, "BR_VERDE", "Cadastrado"  )
	oBrowse:SetDescription( 'Beneficios por Local de Atendimento' )
	oBrowse:SetMenuDef("RSERV011")
	If funname() == "FATA300"
		cFiltro:= "ZA2_NROPOR = '"+M->ADY_OPORTU+"'"
		oBrowse:SetFilterDefault(cFiltro)
	Endif	
	oBrowse:Activate()

Return NIL


Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.RSERV011' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.RSERV011' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.RSERV011' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.RSERV011' OPERATION 5 ACCESS 0
	If funname() <> "FATA300"
		ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.RSERV011' OPERATION 8 ACCESS 0
		ADD OPTION aRotina Title 'Processamento Folha'   Action 'u_RSERV012()' OPERATION 10 ACCESS 0
		ADD OPTION aRotina Title 'Carrega Contratos x Locais'   Action 'u_fCarreg011()' OPERATION 10 ACCESS 0
	Endif
Return aRotina

Static Function ModelDef()
	Local oStruZMast:= FWFormStruct( 1, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_COD|ZA2_DESCRI|ZA2_CONTRA|ZA2_NROPOR|") } )
	Local oStruVT   := FWFormStruct( 1, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_VTTIPO|ZA2_DESCVT|ZA2_QTDDIA|ZA2_TPVALE|") } )
	Local oStruVA   := FWFormStruct( 1, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_VATIPO|ZA2_DESCVA|ZA2_TPVALE|") } )
	//Local oStruVR   := FWFormStruct( 1, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_VRTIPO|ZA2_DESCVR|") } )
	Local oModel

	oModel:= MPFormModel():New("RLMA3N",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields( 'ZA2MAST', /*cOwner*/, oStruZMast )

	oModel:SetPrimaryKey({"ZA2_FILIAL","ZA2_COD","ZA2_CONTRA"})

	// Vale Transporte
	oModel:AddGrid( 'ZA2VT', 'ZA2MAST', oStruVT,;
	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, {|oModel| fTpVT(oModel) }/*bPosVal*/,/*BLoad*/ )

	oModel:SetRelation( 'ZA2VT',{{"ZA2_FILIAL",'xFilial("ZA2")'},{"ZA2_COD","ZA2_COD"},;
								{"ZA2_CONTRA","ZA2_CONTRA"},;
								{"ZA2_NROPOR","ZA2_NROPOR"},;
								{"ZA2_TPVALE","'0'"};
								 } , ZA2->( IndexKey( 1 ) )  )
	oModel:GetModel( 'ZA2VT' ):SetUniqueLine( { 'ZA2_VTTIPO' } )
	//oModel:GetModel( "ZA2VT" ):SetMaxLine(1) 
	
	//Vale Alimentação
	oModel:AddGrid( 'ZA2VA', 'ZA2MAST', oStruVA,;
	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, {|oModel| fTpVA(oModel) } /*bPosVal*/,/*BLoad*/ )

	oModel:SetRelation( 'ZA2VA',{{"ZA2_FILIAL",'xFilial("ZA2")'},{"ZA2_COD","ZA2_COD"},;
								{"ZA2_CONTRA","ZA2_CONTRA"},;
								{"ZA2_NROPOR","ZA2_NROPOR"},;
								{"ZA2_TPVALE","'2'"};
								 } , ZA2->( IndexKey( 1 ) )  )
	oModel:GetModel( 'ZA2VA' ):SetUniqueLine( { 'ZA2_VATIPO' } )
	oModel:GetModel( "ZA2VA" ):SetMaxLine(1) //Somente um 

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZA2MAST' ):SetDescription( 'Local Atendimento' )
	oModel:GetModel( 'ZA2VT' ):SetDescription( 'Vale Transporte'  )
	oModel:GetModel( 'ZA2VA' ):SetDescription( 'Vale Alimentação'  )
	
	oModel:GetModel( "ZA2VT" ):SetOptional(.T.)
	oModel:GetModel( "ZA2VA" ):SetOptional(.T.)
	If funname() == "FATA300"
		oModel:SetActivate({|oModel| fCargaZA2(oModel)})
	Endif

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruZMast:= FWFormStruct( 2, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_COD|ZA2_DESCRI|ZA2_CONTRA|ZA2_NROPOR|") } )
	Local oStruVT   := FWFormStruct( 2, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_VTTIPO|ZA2_DESCVT|ZA2_QTDDIA|") } )
	Local oStruVA	:= FWFormStruct( 2, 'ZA2', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA2_VATIPO|ZA2_DESCVA|") } )
	Local oModel	:= FWLoadModel( 'RSERV011' )
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField('VIEW_ZA2M', oStruZMast, 'ZA2MAST')
	oView:AddGrid('VIEW_ZAVT', oStruVT, 'ZA2VT' )
	oView:AddGrid('VIEW_ZAVA', oStruVA, 'ZA2VA' )
	//oView:AddGrid('VIEW_ZAVR', oStruVR, 'ZA2VR' )

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TOP' , 30 )
	oView:CreateHorizontalBox( 'GRID', 60 )
	oView:CreateHorizontalBox( 'RODAPE'	, 10)

	//Criação das abas 
	oView:CreateFolder( 'PASTAS', 'GRID' )

	oView:AddSheet( 'PASTAS', 'ABA01', "Vale Transporte")
	oView:AddSheet( 'PASTAS', 'ABA02', "Vale Alimentação")

	oView:CreateHorizontalBox( 'ABAS1',100,,,'PASTAS','ABA01' )	//VT
	oView:CreateHorizontalBox( 'ABAS2',100,,,'PASTAS','ABA02' )	//VA

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZA2M', 'TOP'   )
	oView:SetOwnerView( 'VIEW_ZAVT', 'ABAS1' )
	oView:SetOwnerView( 'VIEW_ZAVA', 'ABAS2' )

	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_ZA2M' )
	oView:EnableTitleView( 'VIEW_ZAVT', "Vale Transporte", RGB( 255, 255, 255)  )
	oView:EnableTitleView( 'VIEW_ZAVA', "Vale Alimentação", RGB( 255, 255, 255)  )

Return oView

User Function fCarreg011
	Local aArea:= getArea()
	Local oModelZA2,oMdlZA2
	Local nOpc:= MODEL_OPERATION_INSERT
	Local lRet
	Local aErro
	
	If msgYesNo("Confirma carregamento Contrato x Estabelecimentos? ")	
		ZA2->(dbSetOrder(1))
		cQuery:= " SELECT SUBSTRING(ABB_IDCFAL,1,15) CONTRATO , RTRIM(ABB_LOCAL) LOCAL" 
		cQuery+= " FROM "+RetSqlName("ABB")+" ABB "
		cQuery+= " JOIN "+RetSqlName("CN9")+" CN9 "
		cQuery+= " ON CN9_NUMERO = SUBSTRING(ABB_IDCFAL,1,15) AND CN9_FILIAL = ABB_FILIAL " 
		cQuery+= " WHERE ABB.D_E_L_E_T_ = ' '  "
		cQuery+= " AND CN9.D_E_L_E_T_ = ' '  "
		cQuery+= " AND CN9_FILIAL = '"+xFilial("CN9")+"' "
		cQuery+= " AND CN9_REVATU = ' ' AND CN9_SITUAC IN ('05') " //Somente vigentes 
		cQuery+= " GROUP BY SUBSTRING(ABB_IDCFAL,1,15) , RTRIM(ABB_LOCAL) "
		If select("TQ01") > 0
			TQ01->(dbClosearea())
		Endif
		TCQuery cQuery new Alias TQ01
		
		while TQ01->(!Eof())
			If !(ZA2->(dbSeek(xFilial("ZA2")+ TQ01->LOCAL + TQ01->CONTRATO)))

				//Insere Registro
				oModelZA2	:= FWLoadModel('RSERV011')
				oModelZA2:SetOperation(nOpc)
				lRet	:= oModelZA2:Activate()
				oMdlZA2	:= oModelZA2:GetModel( "ZA2MAST" )
				oMdlZA2:SetValue("ZA2_COD",TQ01->LOCAL)
				oMdlZA2:SetValue("ZA2_CONTRA",TQ01->CONTRATO)
				
				If ( lRet := oModelZA2:VldData() )
					lRet := oModelZA2:CommitData()
				EndIf
				If !lRet
					aErro   := oModelZA2:GetErrorMessage()
					alert( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+;
					"Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+;
					"Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+;
					"Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+;
					"Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+;
					"Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+;
					"Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+;
					"Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+;
					"Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
					TQ01->(dbCloseArea())
					Return .F.
				EndIf
			oModelZA2:DeActivate()					
			Endif
		TQ01->(dbSkip())
		Enddo
		TQ01->(dbCloseArea()) 
		msgInfo("Processo finalizado")
	Endif 
	
	RestArea(aArea)
Return

Static Function fCargaZA2(oModel)
	If oModel:GetOperation()==MODEL_OPERATION_INSERT .OR. oModel:GetOperation()==MODEL_OPERATION_UPDATE
		oModel:LoadValue("ZA2MAST","ZA2_NROPOR",M->ADY_OPORTU)
	Endif
Return

Static Function fTpVT(oModel)
	Local nLin:= 0
	
	For nLin:=1 to oModel:GetQtdLine()
		oModel:GoLine(nLin)
		If oModel:IsDeleted(nLin)
			Loop
		EndIf
		oModel:setValue("ZA2_TPVALE","0")
	Next
Return .T.

Static Function fTpVA(oModel)
	Local nLin:= 0
	
	For nLin:=1 to oModel:GetQtdLine()
		oModel:GoLine(nLin)
		If oModel:IsDeleted(nLin)
			Loop
		EndIf
		oModel:setValue("ZA2_TPVALE","2")
	Next
Return .T.