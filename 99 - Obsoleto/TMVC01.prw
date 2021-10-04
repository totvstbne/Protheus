#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

user function TMVC01()
	local aArea := GetArea()

	DbSelectArea("SRA")
	SRA->(DbSetOrder(1)) //filia, cod,

	if SRA->(DbSeek(FWxFilial('SRA') + "000001"))
		FWExecView("Informacoes", "TMVC01", MODEL_OPERATION_VIEW)
	endIf
	
	SRA->(dbCloseArea())
	RestArea(aArea)

return

static function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruSRA := FWFormStruct( 1, 'SRA', {|cCampo| (AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_NASC|RA_SEXO|RA_CIC|RA_PIS|RA_RG|RA_RGUF|RA_RGORG|RA_HABILIT|RA_ESTCIVI|RA_TPDEFFI|RA_ADMISSA|RA_CODFUNC|RA_CC|RA_NUMCP|RA_LOGRDSC|") } ) 
	//Local oStruSRA := FWFormStruct( 1, 'SRA', {|cCampo| (AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_NASC|RA_SEXO|RA_CIC|RA_PIS|RA_RG|RA_RGUF|RA_RGORG|RA_HABILIT|RA_ESTCIVI|RA_DEFIFIS|RA_TPDEFFI|RA_ADMISSA|RA_CODFUNC|RA_CC|RA_NUMCP|RA_LOGRDSC|") } )
	Local oModel // Modelo de dados que será construído 

	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New('TESTE' ) 

	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields( 'SRAMASTER', /*cOwner*/, oStruSRA) 

	//oModel:SetPrimaryKey({"A1_COD"}) 
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription( 'Modelo de dados' ) 

	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'SRAMASTER' ):SetDescription( 'Dados' ) 

	//oModel:SetActivate({|oModel| T01(oModel)})

	// Retorna o Modelo de dados 
	Return oModel

return oModel

static function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'TMVC01' )

	// Cria a estrutura a ser usada na View 
	Local oStruSRA := FWFormStruct( 2, 'SRA', {|cCampo| (AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_NASC|RA_SEXO|RA_CIC|RA_PIS|RA_RG|RA_RGUF|RA_RGORG|RA_HABILIT|RA_ESTCIVI|RA_TPDEFFI|RA_ADMISSA|RA_CODFUNC|RA_CC|RA_NUMCP|RA_LOGRDSC|") } )
	//Local oStruSRA := FWFormStruct( 2, 'SRA', {|cCampo| (AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_NASC|RA_SEXO|RA_CIC|RA_PIS|RA_RG|RA_RGUF|RA_RGORG|RA_HABILIT|RA_ESTCIVI|RA_DEFIFIS|RA_TPDEFFI|RA_ADMISSA|RA_CODFUNC|RA_CC|RA_NUMCP|RA_LOGRDSC|") } ) 
	// Interface de visualização construída 
	Local oView  

	// Cria o objeto de View 
	oView := FWFormView():New() 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
	// Adiciona no nosso View um controle do tipo formulário(antiga Enchoice) 
	oView:AddField( 'VIEW_SRA', oStruSRA, 'SRAMASTER' ) 
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 

	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEW_SRA', 'TELA')

	//criando os grupos
	oStruSRA:addGroup("pessoal", "Informacoes pessoais", '', 1)
	oStruSRA:addGroup("funcional", "Informacoes trabalhistas", '', 2)

	oStruSRA:SetProperty( 'RA_MAT'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_NOME'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_NASC'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_SEXO'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_CIC'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_PIS'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_RG'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_RGUF'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_RGORG'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_HABILIT'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_ESTCIVI'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	//oStruSRA:SetProperty( 'RA_DEFIFIS'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_TPDEFFI'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	oStruSRA:SetProperty( 'RA_LOGRDSC'	, MVC_VIEW_GROUP_NUMBER, "pessoal" )
	
	oStruSRA:SetProperty( 'RA_ADMISSA'	, MVC_VIEW_GROUP_NUMBER, 'funcional' )
	oStruSRA:SetProperty( 'RA_CODFUNC'	, MVC_VIEW_GROUP_NUMBER, 'funcional' )
	oStruSRA:SetProperty( 'RA_CC'	, MVC_VIEW_GROUP_NUMBER, 'funcional' )
	oStruSRA:SetProperty( 'RA_NUMCP'	, MVC_VIEW_GROUP_NUMBER, 'funcional' )


	// Retorna o objeto de View criado 
Return oView

static function T01(oModel)
	Local oModelSA1 := oModel:GetModel("ZA0MASTER")
	oModelSA1:setValue( 'A1_NOME', 'MEUDEUS VDC PFC')
	oModelSA1:setValue( 'A1_COD', '000001') 
return .T.