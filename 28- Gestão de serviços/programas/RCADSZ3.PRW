#INCLUDE "fwmvcdef.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} RCADSZ3
Campos Planilha
@type function
@version 1.0
@author Saulo Gomes Martins
@since 06/10/2021
//*/
User Function RCADSZ3
	Local oBrowse	:= BrowseDef()
	oBrowse:Activate()
return

Static Function BrowseDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Tabela rentabilidade#")
	oBrowse:SetAlias('SZ3')
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( 'RCADSZ3' )
	//Gr�fico
	oBrowse:SetAttach(.T.)
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"		ACTION "PesqBrw"				OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RCADSZ3"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RCADSZ3"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RCADSZ3"		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RCADSZ3"		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "C�pia"			ACTION "VIEWDEF.RCADSZ3"		OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RCADSZ3"		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir em Lote"	ACTION "u_RCADSZ3E()"	OPERATION 8 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel as object
	Local oStruSZ3 as object
	oStruSZ3	:= FWFormStruct( 1, 'SZ3',/*bAvalCampo*/,/*lViewUsado*/)

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('YCADSZ3')
	oModel:AddFields( 'SZ3MASTER', /*cOwner*/, oStruSZ3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"Z3_FILIAL","Z3_CONTRAT","Z3_REVISAO","Z3_LOCAL","Z3_CODRH"})
	oModel:SetDescription( 'Campos Planilha' )
	//oModel:GetModel( '{2:ALIAS}MASTER' ):SetDescription( '' )


	oModel:SetSource("RCADSZ3")
Return oModel

Static Function ViewDef()
	Local oModel as object
	Local oStruSZ3 as object
	Local oView as object

	oModel		:= FwLoadModel( 'RCADSZ3' )
	oStruSZ3	:= FWFormStruct( 2, 'SZ3', /*bAvalCampo*/)

	//oStruSZ2:RemoveField("Z2_COD")

	//Cria o objeto de View
	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("SZ3MASTER", oStruSZ3 )

	oView:CreateHorizontalBox("CABEC",100)
	oView:SetOwnerView( "SZ3MASTER", "CABEC" )

Return oView


User Function RCADSZ3E

	Local aParam			:= {}
	Local aRet				:= {}
	Local bOk				:= {|| .T. }
	Local cFilIni
	Local cFilFim

	cFilIni		:= Space(FWSizeFilia())
	cFilFim		:= Space(FWSizeFilia())
	cContraIni	:= Space(GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cContraFim	:= Replicate("Z",GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cRevIni		:= Space(GetSx3Cache("CN9_REVISA","X3_TAMANHO"))
	cRevFim		:= Replicate("Z",GetSx3Cache("CN9_REVISA","X3_TAMANHO"))
	aAdd(aParam,{1,"Empresa De"		,cFilIni	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Empresa Até"	,cFilFim	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato De"	,cContraIni	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato Até"	,cContraFim	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Revisão De"	,cRevIni	,"@!","","",".T.",110,.F.})
	aAdd(aParam,{1,"Revisão Até"	,cRevFim	,"@!","","",".T.",110,.F.})
	//aAdd(aParam,{2,"Extra"		    ,cExtra     ,	{"1=Não", "2=Sim"},80,".T.",.F.})
	//aAdd(aParam,{4,"Elaboração"		,l02	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Vigente"		,l05	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Em revisão"		,l09	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Revisado"		,l10	,""	,80,".T.",.F.})
	If !ParamBox(aParam,"Filtro",@aRet,bOk,,,,,,"RGSER001",.T.,.T.)
		Return
	EndIf
	cFilIni	:= aRet[1]
	cFilFim	:= aRet[2]
	cContraIni	:= aRet[3]
	cContraFim	:= aRet[4]
	cRevIni		:= aRet[5]
	cRevFim		:= aRet[6]
	
	_CUPD  := " UPDATE "+RETSQLNAME("SZ3")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE "
	_CUPD  += " Z3_FILIAL  BETWEEN '"+cFilIni+"'    AND '"+cFilFim+"' AND  "
	_CUPD  += " Z3_CONTRAT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"' AND  "
	_CUPD  += " Z3_REVISAO BETWEEN '"+cRevIni+"'    AND '"+cRevFim+"' AND "
	_CUPD  += " D_E_L_E_T_ = ' ' "


	If tcSqlExec(_CUPD) < 0
		Alert(tcSqlError())
	Endif

	alert("Exclus�o conclu�da!")
Return
