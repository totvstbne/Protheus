#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'

/*/{Protheus.doc} RSVNA001
//Geração do Plano de saúde x estabelecimentos
@author Diogo
@since 05/12/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
user function RSVNA001()
Local oBrowse
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA1' )
oBrowse:SetDescription( 'Plano de Saúde x Estabelecimentos' )
oBrowse:Activate()

Return NIL


Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.RSVNA001' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.RSVNA001' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.RSVNA001' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.RSVNA001' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.RSVNA001' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Processamento'  Action 'u_fProcessS01' OPERATION 8 ACCESS 0
Return aRotina

Static Function ModelDef()
Local oStruZMast:= FWFormStruct( 1, 'ZA1', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA1_CODEST|ZA1_DESTAB|") } )
Local oStruZITE := FWFormStruct( 1, 'ZA1', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA1_CODEST|ZA1_TPFORN|ZA1_CODFOR|ZA1_TPPLAN|ZA1_PLANO|ZA1_PD|ZA1_PDDAGR|ZA1_PERINI|ZA1_PERFIM|") } )
Local oStruZDep := FWFormStruct( 1, 'ZA3', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA3_CODEST|ZA3_TIPO|ZA3_TPLNDP|ZA3_PLNDP|ZA3_PRINDP|ZA3_PRFNDP|ZA3_CLASSF|") } )
Local oModel

	oStruZITE:AddTrigger(	;
	"ZA1_CODFOR"		,;											//[01] Id do campo de origem
	"ZA1_CODEST"		,;											//[02] Id do campo de destino
	{ |oModel,cId,xValue,nLinha| .T.  }	,;							//[03] Bloco de codigo de validação da execução do gatilho
	{ |oModel|  fCarregCod()  }  )		//[04] Bloco de codigo de execução do gatilho

	oStruZDep:AddTrigger(	;
	"ZA3_TIPO"			,;											//[01] Id do campo de origem
	"ZA3_CLASSF"			,;											//[02] Id do campo de destino
	{ |oModel,cId,xValue,nLinha| .T.  }	,;								//[03] Bloco de codigo de validação da execução do gatilho
	{ |oModel|  fCarregClas()  }  )		//[04] Bloco de codigo de execução do gatilho

	oModel := MPFormModel():New( 'RCHMH13', /*bPreValidacao*/, /*bPosValidacao*/,  , /*bCancel*/ )
	
	oModel:AddFields( 'ZA1MASTER', /*cOwner*/, oStruZMast )

	oModel:SetPrimaryKey({"ZA1_FILIAL","ZA1_CODEST"})

	oModel:AddGrid( 'ZA1DETAIL', 'ZA1MASTER', oStruZITE,;
	 				/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*BLoad*/ )
	
	oModel:SetRelation( 'ZA1DETAIL', { 	{ 'ZA1_FILIAL'	, 'xFilial( "ZA1" )' },;
	 									{ 'ZA1_CODEST' 	, 'ZA1_CODEST'	};
	 									} , ZA1->( IndexKey(1) )  )
	
	oModel:GetModel( 'ZA1DETAIL' ):SetUniqueLine( { 'ZA1_TPFORN' } )


	oModel:AddGrid( 'ZA1DEP', 'ZA1MASTER', oStruZDep,;
	 				/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*BLoad*/ )

	oModel:SetRelation( 'ZA1DEP', { 	{ 'ZA3_FILIAL'	, 'xFilial( "ZA1" )' },;
	 									{ 'ZA3_CODEST' 	, 'ZA1_CODEST'	};
	 									} , ZA3->( IndexKey(1) )  )

	 									//{ 'ZA3_CLASSF'  ,  'ZA1_TPFORN' };

	
	oModel:GetModel( 'ZA1DEP' ):SetUniqueLine( { 'ZA3_TIPO','ZA3_CLASSF' } )
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Planos Ativos do Titular' )
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('ZA1MASTER'):SetDescription('Plano de Saúde')
	oModel:GetModel('ZA1DETAIL'):SetDescription('Planos Ativos do Titular')
	oModel:GetModel('ZA1DEP'):SetDescription('Planos Ativos dos Dependetes')
	oModel:GetModel('ZA1DEP'):SetOptional(.T.)

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruZMast:= FWFormStruct( 2, 'ZA1', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA1_CODEST|ZA1_DESTAB|") } )
Local oStruZITE := FWFormStruct( 2, 'ZA1', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA1_CODEST|ZA1_TPFORN|ZA1_CODFOR|ZA1_TPPLAN|ZA1_PLANO|ZA1_PD|ZA1_PDDAGR|ZA1_PERINI|ZA1_PERFIM|") } )
Local oStruZDep := FWFormStruct( 2, 'ZA3', {|cCampo|  (AllTrim(cCampo)+"|" $ "ZA3_TIPO|ZA3_TPLNDP|ZA3_PLNDP|ZA3_PRINDP|ZA3_PRFNDP|ZA3_CLASSF|") } )
Local oModel   := FWLoadModel( 'RSVNA001' )
Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_ZA1M', oStruZMast, 'ZA1MASTER')
	
	oView:AddGrid(  'VIEW_ZA1', oStruZITE, 'ZA1DETAIL')

	oView:AddGrid(  'VIEW_DEP', oStruZDep, 'ZA1DEP')
	
//	oStruZITE:RemoveField('ZA1_CODEST')
//	oStruZDep:RemoveField('ZA1_CODEST')
		
	oView:CreateHorizontalBox( 'TOP', 20 )
	oView:CreateHorizontalBox( 'GRID', 40 )
	oView:CreateHorizontalBox( 'RODAPE',40)

	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZA1M', 'TOP'   )
	oView:SetOwnerView( 'VIEW_ZA1', 'GRID'   )
	oView:SetOwnerView( 'VIEW_DEP', 'RODAPE'   )
	
	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_ZA1M' )
	oView:EnableTitleView( 'VIEW_ZA1', "Planos Ativos", RGB( 030, 204, 153)  )
	oView:EnableTitleView( 'VIEW_DEP', "Dependentes/Agregados", RGB( 020, 255, 255)  )

Return oView

Static Function fCarregClas()
	Local oModel:= FwModelActive()
	Local cRet:= ""
	cRet:= oModel:getModel("ZA1DETAIL"):getValue("ZA1_TPFORN")
	oModel:getModel("ZA1DEP"):setValue("ZA3_CODEST",oModel:getModel("ZA1MASTER"):getValue("ZA1_CODEST"))
Return cRet


Static Function fCarregCod()
	Local oModel:= FwModelActive()
	Local cRet:= ""
	cRet:= oModel:getModel("ZA1MASTER"):getValue("ZA1_CODEST")
Return cRet

/*/{Protheus.doc} fProcessS01
Rotina de processamento para o cadastro padrão
@author Diogo
@since 06/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fProcessS01
Local oModel := nil
ProcRegua(2)
IncProc("Gerando informações referente ao contrato...")
ProcessMessage()

oModel 	:= FWLoadModel("GPEA001")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

oCabec := oModelCtr:getModel("GPEA001_MSRA") //Cabeçalho
oTitul := oModelCtr:getModel("GPEA001_MRHK") //Planos ativos do titular
oDepen := oModelCtr:getModel("GPEA001_MRHL") //Planos dos dependentes
oAgreg := oModelCtr:getModel("GPEA001_MRHM") //Planos dos agregados

//Informações do cabeçalho
dbSelectArea("SRA")
SRA->(dbSetOrder(1))
SRA->(dbSeek(xFilial("SRA")+"012195"))
oCabec:setValue("RA_MAT",SRA->RA_MAT)
oCabec:setValue("RA_NOME",SRA->RA_NOME)
oCabec:setValue("RA_ADMISSA",SRA->RA_ADMISSA)

//Informações dos planos ativos do titular
oTitul:setValue("RHK_TPFORN","1")
oTitul:setValue("RHK_CODFOR","002")
oTitul:setValue("RHK_TPPLAN","3")
oTitul:setValue("RHK_PLANO","08")
oTitul:setValue("RHK_PD","012")
oTitul:setValue("RHK_PDDAGR","013")
oTitul:setValue("RHK_PERINI","092019")
oTitul:setValue("RHK_PERFIM","")

//Informações dos dependentes
oDepen:setValue("RHL_CODIGO","01")
oDepen:setValue("RHL_TPPLAN","3")

IncProc("Gerando informações ...")
ProcessMessage()

//Validação e Gravação do Modelo
If oModelCtr:VldData()
    lRet:= oModelCtr:CommitData()
    aRet:= {.T.,cNum}
Else
		aErro   := oModelCtr:GetErrorMessage()
		alert( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' +;
		"Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' +;
		 "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' +;
		 "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' +;
		 "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' +;
		 "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' +;
		 "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' +;
		 "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' +;
		 "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
		aRet:= {.F.,""}
		Return aRet
	Endif
Return aRet
