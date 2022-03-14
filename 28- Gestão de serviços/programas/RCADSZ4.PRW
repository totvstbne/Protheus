#INCLUDE "fwmvcdef.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} RCADSZ4
Campos Planilha
@type function
@version 1.0
@author Saulo Gomes Martins
@since 06/10/2021
//*/
User Function RCADSZ4
	Local oBrowse	:= BrowseDef()
	oBrowse:Activate()
return

Static Function BrowseDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Tabela Realizado#")
	oBrowse:SetAlias('SZ4')
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( 'RCADSZ4' )
	//Gr·fico
	oBrowse:SetAttach(.T.)
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"		ACTION "PesqBrw"				OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RCADSZ4"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RCADSZ4"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RCADSZ4"		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RCADSZ4"		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "CÛpia"			ACTION "VIEWDEF.RCADSZ4"		OPERATION 7 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RCADSZ4"		OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir em Lote"	ACTION "u_RCADSZ4E()"	OPERATION 8 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel as object
	Local oStruSZ4 as object
	oStruSZ4	:= FWFormStruct( 1, 'SZ4',/*bAvalCampo*/,/*lViewUsado*/)

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('YCADSZ4')
	oModel:AddFields( 'SZ4MASTER', /*cOwner*/, oStruSZ4, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"Z4_FILIAL","Z4_CONTRAT","Z4_CC","Z4_COMPET"})
	oModel:SetDescription( 'Campos Planilha' )
	//oModel:GetModel( '{2:ALIAS}MASTER' ):SetDescription( '' )


	oModel:SetSource("RCADSZ4")
Return oModel

Static Function ViewDef()
	Local oModel as object
	Local oStruSZ4 as object
	Local oView as object

	oModel		:= FwLoadModel( 'RCADSZ4' )
	oStruSZ4	:= FWFormStruct( 2, 'SZ4', /*bAvalCampo*/)

	//oStruSZ2:RemoveField("Z2_COD")

	//Cria o objeto de View
	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("SZ4MASTER", oStruSZ4 )

	oView:CreateHorizontalBox("CABEC",100)
	oView:SetOwnerView( "SZ4MASTER", "CABEC" )

Return oView


User Function RCADSZ4E

	Local aParam			:= {}
	Local aRet				:= {}
	Local bOk				:= {|| .T. }
	Local cFilIni
	Local cFilFim
	Local cPERI
	cFilIni		:= Space(FWSizeFilia())
	cFilFim		:= Space(FWSizeFilia())
	cContraIni	:= Space(GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cContraFim	:= Replicate("Z",GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cCCIni		:= Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO"))
	cCCFim		:= Replicate("Z",GetSx3Cache("CTT_CUSTO","X3_TAMANHO"))
	cPERI := SPACE(6)
	aAdd(aParam,{1,"Empresa De"		,cFilIni	,"@!","","SM0",".T.",110,.F.})
	//aAdd(aParam,{1,"Empresa At√©"	,cFilFim	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato De"	,cContraIni	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Contrato At√©"	,cContraFim	,"@!","","CN9",".T.",110,.F.})
	aAdd(aParam,{1,"Periodo AAAAMM"	,cPERI	    ,"@!","","",".T.",110,.F.})
	//aAdd(aParam,{2,"Extra"		    ,cExtra     ,	{"1=N√£o", "2=Sim"},80,".T.",.F.})
	//aAdd(aParam,{4,"Elabora√ß√£o"		,l02	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Vigente"		,l05	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Em revis√£o"		,l09	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Revisado"		,l10	,""	,80,".T.",.F.})
	If !ParamBox(aParam,"Filtro",@aRet,bOk,,,,,,"RTECR05",.T.,.T.)
		Return
	EndIf
	cFilIni	:= aRet[1]
//	cFilFim	:= aRet[2]
	cContraIni	:= aRet[2]
	cContraFim	:= aRet[3]
	cPERI		:= aRet[4]
	
	_CUPD  := " UPDATE "+RETSQLNAME("SZ4")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE "
	_CUPD  += " Z4_FILIAL  = '"+cFilIni+"'   AND  "
	_CUPD  += " Z4_CONTRAT BETWEEN '"+cContraIni+"' AND '"+cContraFim+"' AND  "
//	_CUPD  += " Z4_CC      BETWEEN '"+cCCIni+"'     AND '"+cCCFim+"' AND "
	_CUPD  += " Z4_COMPET = '"+cPERI+"' AND "
	_CUPD  += " D_E_L_E_T_ = ' ' "


	If tcSqlExec(_CUPD) < 0
		Alert(tcSqlError())
	Endif

	alert("Exclus„o concluÌda!")
Return
