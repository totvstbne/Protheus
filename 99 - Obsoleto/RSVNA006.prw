#INCLUDE "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOPCONN.CH'
#DEFINE MODEL 1
#DEFINE VIEW 2
#DEFINE MANUT_TIPO_CANCEL	'05'	//Tipo Cancelamento
#DEFINE PERMISSAO_CLIENTE 		1
#DEFINE PERMISSAO_CONTRATO 		2
#DEFINE PERMISSAO_BASEATEND 		3
#DEFINE PERMISSAO_CONTRATOSERV 	4
#DEFINE PERMISSAO_EQUIPE 		5

Static cAliasTmp := ""//Alias Temporario dos dados de conflito
Static aPerm		:= NIL //Controle de permissões. Esta variavel deverá ser recuperada através do método at570getPe()

/*
{Protheus.doc} TECA570


Apresenta conflitos de alocação relacionados a demissão, férias ou afastamentos no RH. 

@param aParam 	Array 		Array com informações para realização do filtro, caso não seja passado será apresentado pergunte para realização do filtro
								[1]Data Inicial de Alocação
								[2]Data Final de alocação
								[3]Atendente De
								[4]Atendente Ate
@param lPrevisao	Boolean 	Caso Verdadeiro será apresentada a previsão dos conflitos conforme datas do parametro, caso falso será apresentado conflitos existentes na alocação.
	
@owner  rogerio.souza
@author  rogerio.souza
@version P11.8
@since   04/06/2013 
@return Nil
@menu    
*/
User Function RSVNA006(aParam, lPrevisao)

Local oDialog	:= Nil

Local aSize	:= FWGetDialogSize( oMainWnd )
Local cPerg := "TEC570"
Local lExibe := .T.
Local cPermissao := ""
Local lContRefr := .T.//Controle para execução de refresh

Default lPrevisao 	:= .F.
Private cAtendDe 	:= ""
Private cAtendAte 	:= ""
Private dAlocDe 	:= STOD("")
Private dAlocAte 	:= STOD("")
Private cCadastro 	:= "" 
Private oBrowse 	:= Nil

If at570CPerm()//controla permissoes?
	cPermissao := AT570Perm()
	If Empty(cPermissao)
		alert("Usuário sem permissão de acesso para as informações de alocação!")
		lExibe := .F.
	EndIf
EndIf

If lExibe
	If (ValType(aParam)=="A" .AND. Len(aParam) > 0)
		dAlocDe 	:= aParam[1]
		dAlocAte 	:= aParam[2]
		cAtendDe 	:= aParam[3]
		cAtendAte 	:= aParam[4]
	Else
		lExibe 		:= Pergunte(cPerg, .T.)
		dAlocDe 	:= MV_PAR01
		dAlocAte 	:= MV_PAR02
		cAtendDe 	:= MV_PAR03
		cAtendAte 	:= MV_PAR04
	EndIf
EndIf

If lExibe
	cAliasTmp 	:= GetNextAlias()
	
	oBrowse := FWFormBrowse():New()
	
	oBrowse:SetDataQuery(.T.)
	If lPrevisao
		oBrowse:SetQuery( AT570QryPrev(dAlocDe, dAlocAte, cAtendDe, cAtendAte) )
	Else
		oBrowse:SetQuery( AT570Query(dAlocDe, dAlocAte, cAtendDe, cAtendAte) )			
	EndIf
	oBrowse:SetAlias( cAliasTmp )
	oBrowse:AddStatusColumns( { || AT570Status( cAliasTmp ) }, { || AT570Legen() } )						
	oBrowse:SetColumns( AT570Colum() )
	oBrowse:SetUseFilter( .T. )
	oBrowse:SetFilterDefault( "u_xt570Filter()") 	
 	
	oBrowse:AddButton( "Legenda", { || AT570Legen()},,2,, .F., 2 )	//'Legenda'		
	//oBrowse:AddButton( "Visualizara", { || If((oBrowse:Alias())->(!EOF()), FWExecView("Conflito de Alocação",'RSVNA006', MODEL_OPERATION_VIEW,, { || .T. } ),NIL) },,2,, .F., 2 )	//'Visualizar' - Conflito de Alocação
	If !IsInCallStack('u_xT570Detal')
		oBrowse:AddButton( "Substituir", { || MsgRun ( "Aguarde", "Realizando Substituição", {|| AT570Subst(oBrowse:Alias())} ), MsgRun ( "Substituir", "Realizando Substituição", {|| u_xT570Refresh(oBrowse)} ) },,4,, .F., 2 )	//'Substituir' - Realizando Substituição
		//oBrowse:AddButton( "Opções", { || If(Pergunte("TEC570"), MsgRun ( "Atualizar", "Atualizando", {|| u_xT570Refresh(oBrowse)} ),NIL) },,4,, .F., 2 )	//Opções - 'Atualizar' - Atualizando
	EndIf
	oBrowse:AddButton( "Sair", { ||oDialog:End() },,,, .F., 2 )	//'Sair'
					
	If (cAliasTmp)->(RecCount()) == 0
		msgInfo("Não há registros para serem exibidos!")			
	Else
		oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Conflito de Alocação", , , , , , , , /*oMainWnd*/, .T. )	
		oBrowse:SetOwner( oDialog )
		oBrowse:Activate()
		oDialog:Activate()					
	EndIf
EndIf
Return

//
/*
{Protheus.doc} AT570Colum

Recupera informações das colunas que serão exibidas no browse
	
@owner  rogerio.souza
@author  rogerio.souza
@version P11.8
@since   04/06/2013 
@return aColumns Array
*/
Static Function AT570Colum()
Local aCampos := AT570Field()
Local aColumns:= {}
Local nI 		:= 1
Local nJ 		:= 1
Local aArea	:= GetArea()
Local aAreaSX3:= SX3->(GetArea())	
	
DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO

For	nI:=1 To Len(aCampos)
	If ( SX3->( MsSeek( aCampos[nI] ) ) )
	
		AAdd( aColumns, FWBrwColumn():New() )
		
		If ( SX3->X3_TIPO == "D"  )
			aColumns[nJ]:SetData( &("{||SToD(" + aCampos[nI] + ")}") )
		Else
			aColumns[nJ]:SetData( &("{||" + aCampos[nI] + "}") )
		EndIf	
	
		aColumns[nJ]:SetTitle( X3Titulo() )
		aColumns[nJ]:SetSize( SX3->X3_TAMANHO )
		aColumns[nJ]:SetDecimal( SX3->X3_DECIMAL )
		aColumns[nJ]:SetPicture( SX3->X3_PICTURE )
		
		If aCampos[nI] == "RH_DATAINI"
			aColumns[nJ]:SetData( {|| x570IniF()} )
		ElseIf aCampos[nI] == "RH_DATAFIM"
			aColumns[nJ]:SetData( {|| x570FimF()} )			
		EndIf		
		
		nJ++
	EndIf	
Next nI

RestArea(aAreaSX3)
RestArea(aArea)
	
Return aColumns

//
/*
{Protheus.doc} ModelDef

Definição do Model da rotina TECA570
	
@owner  rogerio.souza
@author  rogerio.souza
@version P11.8
@since   04/06/2013 
@return oModel MPFormModel Modelo da rotina 
*/
Static Function ModelDef()
Local oModel:= MPFormModel():New('RSVNA006', /*bPreValidacao*/, /**/, {||.T.}, /*bCancel*/ )
Local oStru := AT570Struc(MODEL)

oModel:AddFields( 'MASTER', /*cOwner*/, oStru, /*bPreValidacao*/, /*bPosValidacao*/, {||} )

oModel:SetDescription( "Conflito de Alocação" )
oModel:GetModel( 'MASTER'):SetDescription( "Conflito de Alocação" )

oModel:SetActivate( {|oModel| AT570LoadM( oModel ) } )
oModel:setPrimaryKey({})

Return oModel

/*
{Protheus.doc} ViewDef

Definição da View

@param  
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return oView FWFormView
*/
Static Function ViewDef() 
Local oView := Nil
Local oStruct := AT570Struc(VIEW)
Local oModel   := FWLoadModel( 'RSVNA006' )
Local aCpos := AT570Field()
Local nI := 1

//Atribui propriedade somente visualização
For nI:=1 To Len(aCpos)
	oStruct:SetProperty( aCpos[nI] , MVC_VIEW_CANCHANGE, .F.)
Next nI


oView := FWFormView():New()
oView:SetModel( oModel )
 
oView:AddField( 'VIEW_RSVNA006', oStruct, 'MASTER' )//Add Controle

oView:CreateHorizontalBox( 'TELA' , 100 )// Criar um "box" horizontal para receber algum elemento da view

oView:SetOwnerView( 'VIEW_RSVNA006', 'TELA' )// Relaciona o ID da View com o "box" para exibicao

Return oView


/*Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TECA570' OPERATION 3 ACCESS 0
Return aRotina*/



/*
{Protheus.doc} AT570Field

Retorna campos que serão utilizados

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return aCampos Array array com campos utilizados 
*/
Static Function AT570Field()
Local aCampos := {}

aAdd(aCampos, "AA1_CODTEC")//Codigo do Atendente
aAdd(aCampos, "AA1_NOMTEC")//Nome do Atendnete
aAdd(aCampos, "ABB_DTINI")//Data Alocação Inicial
aAdd(aCampos, "ABB_HRINI")//Hora Alocação Inicial
aAdd(aCampos, "ABB_DTFIM")//Data Alocação Inicial
aAdd(aCampos, "ABB_HRFIM")//Hora Alocação Final
aAdd(aCampos, "RA_SITFOLH")//Situação no GPE
aAdd(aCampos, "RH_DATAINI")//Data Inicial Programação Férias
aAdd(aCampos, "RH_DATAFIM")//Data Final Programação Férias
aAdd(aCampos, "R8_DATAINI")//Data Inicial Afastamento
aAdd(aCampos, "R8_DATAFIM")//Data Final Afastamento
aAdd(aCampos, "RA_DEMISSA")//Data de Demissão

Return aCampos


//Retorna Estrutura para o Model
/*
{Protheus.doc} AT570Struc

Recupera estrutura de Model ou de View da rotina TECA570

@param  nType Integer - 1(MODEL), 2(VIEW)
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return oStruct - FWFormModelStruct ||  FWFormViewStruct
*/
Static Function AT570Struc(nType)
Local oStruct := Nil
Local aCampos := AT570Field()
Local nI := 1
Local aArea	:= GetArea()
Local aAreaSX3:= SX3->(GetArea())	
Local bBlockIni := Nil

If nType == MODEL
	oStruct := FWFormModelStruct():New()
Else
	oStruct := FWFormViewStruct():New()
EndIf
		
DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
	
For	nI:=1 To Len(aCampos)		
	
	If ( SX3->( MsSeek( aCampos[nI] ) ) )
			
		If nType == MODEL//Estrutura para Model
						
			If aCampos[nI] == "RH_DATAINI"
				bBlockIni := {|| x570IniF()}
			ElseIf aCampos[nI] == "RH_DATAFIM"
				bBlockIni := {|| x570FimF()}
			Else
				bBlockIni := Nil			
			EndIf	
			
			oStruct:AddField( ;
				X3Titulo()  		, ;             // [01] Titulo do campo
				X3Descric()	, ;             // [02] ToolTip do campo
				AllTrim(aCampos[nI])     	, ;             // [03] Id do Field
				SX3->X3_TIPO		, ;            	// [04] Tipo do campo
				SX3->X3_TAMANHO	, ;             // [05] Tamanho do campo
				SX3->X3_DECIMAL 	, ;               // [06] Decimal do campo
				/*NIL*/            , ;               // [07] Code-block de validação do campo
				/*{||.F.}*/   		, ;               // [08] Code-block de validação When do campo
				/*NIL*/ 			, ;         	  // [09] Lista de valores permitido do campo
				/*.F.*/     		, ;               // [10] Indica se o campo tem preenchimento obrigatório
				bBlockIni          , ;               // [11] Code-block de inicializacao do campo
				/*.F.*/            , ;               // [12] Indica se trata-se de um campo chave
				.T.					, ;               // [13] Indica se o campo pode receber valor em uma operação de update.
				.T.     )              				  // [14] Indica se o campo é virtual
		Else// Estrutura para View			
		    oStruct:AddField( ;
			    aCampos[nI]   			, ;             // [01] Campo
			    cValToChar(nI)        , ;             	// [02] Ordem
			    X3Titulo()	        	, ;             	// [03] Titulo
			    X3Descric()           , ;             	// [04] Descricao
			    /*{}*/                 , ;             	// [05] Help
			    'GET'					, ;             	// [06] Tipo do campo   COMBO, Get ou CHECK
			    SX3->X3_PICTURE		, ;             	// [07] Picture
			    /*''*/                 	, ;             	// [08] PictVar
			    /*NIL*/            	, ;            		// [09] F3
			    .T.						, ;             	// [10] Editavel
			    '01'                 	, ;        			// [11] Folder
			    /*''*/           		, ;            		// [12] Group
			    /*{}*/                 	, ;            		// [13] Lista Combo
			    /*10*/                 	, ;            		// [14] Tam Max CombO
			    /*''*/               	, ;            		// [15] Inic. Browse
			    .T.  )               						// [16] Virtual		  
		EndIf	
	EndIf		
Next nI	

RestArea(aAreaSX3)
RestArea(aArea)

Return oStruct


/*
{Protheus.doc} AT570Query

Recupera query para listagem dos cnflitos

@param dAlocDe 	Data Data inicial de alocação
@param	dAlocAte 	Data Data Final de Alocação
@param	cAtendDe 	String Atendente De
@param cAtendAte	String Atendente Ate
@param cPermissao String COndição para filtro devido a permissoes
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return cQuery String Query para recuperação de conflitos com o RH 
*/
Static Function AT570Query(dAlocDe, dAlocAte, cAtendDe,  cAtendAte)

Local cQuery := ""
Local cPermissao := ""
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada
		
cQuery += " SELECT DISTINCT " 
cQuery += 		"ABB.ABB_FILIAL,"
cQuery += 		"AA1.AA1_CODTEC,"
cQuery += 		"AA1.AA1_NOMTEC,"
cQuery += 		"ABB.ABB_DTINI,"
cQuery += 		"ABB.ABB_HRINI,"
cQuery += 		"ABB.ABB_DTFIM,"
cQuery += 		"ABB.ABB_HRFIM,"
cQuery += 		"COALESCE(SRA.RA_SITFOLH,' ') RA_SITFOLH,"
cQuery += 		"COALESCE(SRA.RA_DEMISSA,' ') RA_DEMISSA,"
cQuery += 		"COALESCE(SRF.RF_DATAINI,' ') RF_DATAINI,"
cQuery += 		"COALESCE(SRF.RF_DFEPRO1, 0 ) RF_DFEPRO1,"
cQuery += 		"COALESCE(SRF.RF_DATINI2,' ') RF_DATINI2,"
cQuery += 		"COALESCE(SRF.RF_DFEPRO2, 0 ) RF_DFEPRO2,"
cQuery += 		"COALESCE(SRF.RF_DATINI3,' ') RF_DATINI3,"
cQuery += 		"COALESCE(SRF.RF_DFEPRO3, 0 ) RF_DFEPRO3,"	

cQuery += 		"COALESCE(SR8.R8_DATAINI,' ') R8_DATAINI,"
cQuery += 		"COALESCE(SR8.R8_DATAFIM,' ') R8_DATAFIM "

cQuery += 		"FROM "+RetSqlName("ABB")+" ABB"	

cQuery += " LEFT JOIN "+RetSqlName("AA1")+" AA1"
cQuery += 		" ON AA1.AA1_FILIAL = '"+xFilial("AA1")+"'"
cQuery += 		" AND AA1.AA1_CODTEC = ABB.ABB_CODTEC"
cQuery += 		" AND AA1.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RetSqlName("SRA")+" SRA"
cQuery += 		" ON SRA.RA_FILIAL = AA1.AA1_FUNFIL"
cQuery += 		" AND SRA.RA_MAT = AA1.AA1_CDFUNC"
cQuery += 		" AND SRA.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RetSqlName("SR8")+" SR8"
cQuery += 		" ON SR8.R8_FILIAL = SRA.RA_FILIAL"
cQuery += 		" AND SR8.R8_MAT = SRA.RA_MAT"
cQuery += 		" AND ("
cQuery += 			"(ABB.ABB_DTINI >= SR8.R8_DATAINI AND ABB.ABB_DTINI <= SR8.R8_DATAFIM) OR"
cQuery += 			"(ABB.ABB_DTFIM >= SR8.R8_DATAINI AND ABB.ABB_DTFIM <= SR8.R8_DATAFIM) OR"
cQuery += 			"(ABB.ABB_DTINI >= SR8.R8_DATAINI AND SR8.R8_DATAFIM ='') OR"
cQuery += 			"(ABB.ABB_DTFIM >= SR8.R8_DATAINI AND SR8.R8_DATAFIM ='')"
cQuery += 			" )"	
cQuery += 		" AND SR8.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+RetSqlName("SRF")+" SRF"	
cQuery += 		" ON SRF.RF_FILIAL = SRA.RA_FILIAL"
cQuery += 		" AND SRF.RF_MAT = SRA.RA_MAT	"
cQuery += 		" AND SRF.D_E_L_E_T_ = ' '"
cQuery += 		" AND "

cQuery += "("
cQuery += 		"("			
cQuery += 			" ABB.ABB_DTINI >= SRF.RF_DATAINI OR"
cQuery += 			" ABB.ABB_DTFIM <= SRF.RF_DATAINI"		
cQuery += 		") OR ("
cQuery += 			" ABB.ABB_DTINI >= SRF.RF_DATINI2 OR"
cQuery += 			" ABB.ABB_DTFIM <= SRF.RF_DATINI2 "		
cQuery += 		") OR ("
cQuery += 			" ABB.ABB_DTINI >= SRF.RF_DATINI3 OR"
cQuery += 			" ABB.ABB_DTFIM <= SRF.RF_DATINI3 "		
cQuery += 		")"
cQuery += ")"
	
cQuery += " WHERE "
cQuery += 		" ABB.ABB_FILIAL = '"+xFilial("ABB")+"'"		
cQuery += 		" AND ABB.ABB_CODTEC BETWEEN '"+cAtendDe+"' AND '"+cAtendAte+"'"
cQuery += 		" AND ("
cQuery += 		" ABB.ABB_DTINI BETWEEN '"+DTOS(dAlocDe)+"' AND '"+DTOS(dAlocAte)+"' OR"
cQuery += 		" ABB.ABB_DTFIM BETWEEN '"+DTOS(dAlocDe)+"' AND '"+DTOS(dAlocAte)+"'"
cQuery += 		")"
cQuery += 		" AND ABB.ABB_ATIVO ='1'"
cQuery += 		" AND ABB.ABB_ATENDE ='2'"
	
cQuery += 		" AND ABB.D_E_L_E_T_ = ' '"
cQuery += 		" AND ("
cQuery += 			" (SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= ABB.ABB_DTINI) OR"
cQuery += 			" (SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= ABB.ABB_DTFIM)"

If lUsaEAIGS
	cQuery += 		" OR SRA.RA_SITFOLH = 'A'"
Else
	cQuery += 		" OR SR8.R8_DATAINI <> '"+Space(8)+"'"
EndIf

cQuery += 			" OR SRF.RF_DATAINI <> '"+Space(8)+"'"
cQuery += 			" OR SRF.RF_DATINI2 <> '"+Space(8)+"'"
cQuery += 			" OR SRF.RF_DATINI3 <> '"+Space(8)+"'"
cQuery += 		")"	

If At570CPerm()//controla permissoes?
	cPermissao := AT570Perm()
	If !Empty(cPermissao)		
		cQuery += cPermissao
	EndIf
EndIf

cQuery += " ORDER BY AA1_CODTEC, AA1_NOMTEC, ABB_DTINI, ABB_HRINI, ABB_DTFIM"

Return ChangeQuery(cQuery)

/*
{Protheus.doc} AT570QryPC
Encapsula a função AT570QryPrev que retorna uma string em forma de query de previsão de conflitos

@param dAlocDe 	Data Data inicial de alocação
@param	dAlocAte 	Data Data Final de Alocação
@param	cAtendDe 	String Atendente De
@param cAtendAte	String Atendente Ate
@param aLstAte	Array Contendo uma Lista simples com os códigos dos atendentes que se deseja consultar.

@version V12
@since   21/05/2015 
@return cQuery String Query para recuperação de conflitos com o RH em uma determinada data
*/
User Function AT570QryPC(dAlocDe, dAlocAte, cAtendDe, cAtendAte, aLstAte, lJoinABB)
Local cRet := ""
cRet := AT570QryPrev(dAlocDe, dAlocAte, cAtendDe, cAtendAte, aLstAte, lJoinABB)
Return cRet


/*
{Protheus.doc} AT570QryPrev

Recupera query para previsão de conflitos

@param dAlocDe 	Data Data inicial de alocação
@param	dAlocAte 	Data Data Final de Alocação
@param	cAtendDe 	String Atendente De
@param cAtendAte	String Atendente Ate
@param aLstAte	Array Contendo uma Lista simples com os códigos dos atendentes que se deseja consultar.
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return cQuery String Query para recuperação de conflitos com o RH em uma determinada data
*/
Static Function AT570QryPrev(dAlocDe, dAlocAte, cAtendDe, cAtendAte, aLstAte, lJoinABB)

Local cQuery := ""
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada
Local nI := 0
Local cLstAte := ""
	
Default aLstAte := {}	//{cCdAte1,cCdAte2,..,cCdAten} - Entre cada par de aspas simples deve constar um código de atendente
Default lJoinABB := .F.

cQuery := "SELECT DISTINCT"
cQuery += " AA1.AA1_FILIAL, "
cQuery += " AA1.AA1_CODTEC, "
cQuery += " AA1.AA1_NOMTEC,  "
cQuery += " '"+DTOS(dAlocDe)+"' AS ABB_DTINI, "
cQuery += " '  :  ' AS ABB_HRINI, "
cQuery += " '"+DTOS(dAlocAte)+"' AS ABB_DTFIM, "
cQuery += " '  :  ' AS ABB_HRFIM,  "
cQuery += " COALESCE(SRA.RA_SITFOLH,' ') RA_SITFOLH, " 
cQuery += " COALESCE(SRA.RA_DEMISSA,' ') RA_DEMISSA,  "
cQuery += " COALESCE(SRF.RF_DATAINI,' ') RF_DATAINI,"
cQuery += " COALESCE(SRF.RF_DFEPRO1, 0 ) RF_DFEPRO1,"
cQuery += " COALESCE(SRF.RF_DATINI2,' ') RF_DATINI2,"
cQuery += " COALESCE(SRF.RF_DFEPRO2, 0 ) RF_DFEPRO2,"
cQuery += " COALESCE(SRF.RF_DATINI3,' ') RF_DATINI3,"
cQuery += " COALESCE(SRF.RF_DFEPRO3, 0 ) RF_DFEPRO3,"	
cQuery += " COALESCE(SR8.R8_DATAINI,' ') R8_DATAINI,"
cQuery += " COALESCE(SR8.R8_DATAFIM,' ') R8_DATAFIM "
If lJoinABB
	cQuery += " ,ABB.ABB_DTINI AS DTINI, "
	cQuery += " ABB.ABB_DTFIM AS DTFIM, "
	cQuery += " ABB.ABB_HRINI AS HRINI, "
	cQuery += " ABB.ABB_HRFIM AS HRFIM "
EndIF
cQuery += " FROM "+RetSqlName("AA1")+" AA1 "

cQuery += "	LEFT JOIN "+RetSqlName("SRA")+"  SRA " 	
cQuery += 		" ON SRA.RA_FILIAL = AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_ = ' ' " 
	
cQuery += "	LEFT JOIN  "+RetSqlName("SR8")+" SR8 " 	
cQuery += 		"ON SR8.R8_FILIAL = SRA.RA_FILIAL 	AND SR8.R8_MAT = SRA.RA_MAT " 	
cQuery += 			" AND ( " 				
cQuery += 			"('"+DTOS(dAlocDe )+"' >= SR8.R8_DATAINI AND ('"+DTOS(dAlocDe)+"' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM ='')) OR "
cQuery += 			"('"+DTOS(dAlocDe )+"' <= SR8.R8_DATAINI AND '"+DTOS(dAlocAte)+"' <= SR8.R8_DATAFIM) OR "
cQuery += 			"('"+DTOS(dAlocDe )+"' <= SR8.R8_DATAINI AND '"+DTOS(dAlocAte)+"' >= SR8.R8_DATAFIM) OR "
cQuery += 			"('"+DTOS(dAlocAte)+"' >= SR8.R8_DATAINI AND SR8.R8_DATAFIM ='') "
cQuery += 			")"
cQuery += "	AND SR8.D_E_L_E_T_ = ' ' " 

cQuery += "	LEFT JOIN "+RetSqlName("SRF")+" SRF "
cQuery += 		" ON SRF.RF_FILIAL = SRA.RA_FILIAL AND SRF.RF_MAT = SRA.RA_MAT AND SRF.D_E_L_E_T_ = ' ' AND " 
cQuery += "("
cQuery += 		"("			
cQuery += 		" '"+DTOS(dAlocDe)+"' >= SRF.RF_DATAINI OR"
cQuery += 		" '"+DTOS(dAlocAte)+"' <= SRF.RF_DATAINI"		
cQuery += 		")OR("
cQuery += 		" '"+DTOS(dAlocDe)+"' >= SRF.RF_DATINI2 OR"
cQuery += 		" '"+DTOS(dAlocAte)+"' <= SRF.RF_DATINI2 "		
cQuery += 		")OR("
cQuery += 		" '"+DTOS(dAlocDe)+"' >= SRF.RF_DATINI3 OR"
cQuery += 		" '"+DTOS(dAlocAte)+"' <= SRF.RF_DATINI3 "		
cQuery += 		")"
cQuery += ")"

If lJoinABB
	cQuery += " LEFT JOIN " + RetSqlName("ABB") + " ABB ON ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cQuery += "AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += "AND ABB.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "	WHERE  "
 
cQuery += "	AA1.AA1_FILIAL = '"+xFilial('AA1')+"' "

If Empty(aLstAte)
	cQuery += "	AND AA1.AA1_CODTEC >= '"+cAtendDe+"' "
	cQuery += "	AND AA1.AA1_CODTEC <= '"+cAtendAte+"' " 
Else
	cLstAte := "("
	For nI := 1 to Len(aLstAte)
	 	cLstAte += "'" + aLstAte[nI] 
	 	cLstAte += If(Len(aLstAte) == nI, "'","';")
	Next nI
	cLstAte += ") "
	
	cQuery += "	AND AA1.AA1_CODTEC IN " + cLstAte
EndIf

cQuery += "	AND AA1.D_E_L_E_T_ = ' ' " 	
cQuery += "	AND ("
cQuery += "	(SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= '"+DTOS(dAlocDe)+"') OR "
cQuery += "	(SRA.RA_DEMISSA <> '' AND SRA.RA_DEMISSA <= '"+DTOS(dAlocAte)+"') OR "

If lUsaEAIGS
	cQuery += "	SRA.RA_SITFOLH = 'A' "
Else
	cQuery += "	SR8.R8_DATAINI <> '' "
EndIf

cQuery += "OR SRF.RF_DATAINI <> '' "
cQuery += "OR SRF.RF_DATINI2 <> '' OR SRF.RF_DATINI3 <> '' "
If lJoinABB
	cQuery += " OR (ABB.ABB_DTINI = '"+DTOS(dAlocDe)+"' AND ABB.ABB_DTFIM = '"+DTOS(dAlocAte)+"') "
EndIf
cQuery += ")"
cQuery += "	ORDER BY AA1_CODTEC,"
cQuery += "	AA1_NOMTEC,"
cQuery += "	ABB_DTINI,"
cQuery += "	ABB_HRINI,"
cQuery += "	ABB_DTFIM"

Return ChangeQuery(cQuery)

/*/{Protheus.doc} AT570LoadM
Realiza o Carregamento no Model
@param	oModel MPFormModel
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return 
/*/
Static Function AT570LoadM(oModel)
	Local aCpos := AT570Field()
	Local nI := 1	
	Local oStruct := oModel:GetModel("MASTER"):GetStruct()		
	
	For nI:=1 To Len(aCpos)
		If !aCpos[nI] $ "RH_DATAINI|RH_DATAFIM"
			If oStruct:GetProperty(aCpos[nI], MODEL_FIELD_TIPO) == "D"		
				oModel:LoadValue("MASTER",aCpos[nI], STOD((cAliasTmp)->&(aCpos[nI])))
			Else
				oModel:LoadValue("MASTER",aCpos[nI], (cAliasTmp)->&(aCpos[nI]))
			EndIf
		EndIf		
	Next nI
	
Return

/*
{Protheus.doc} AT570Status

Recupera Status de conflito para apresentação no Browse

@param  cAlias	String	Alias aberto para verificação do status
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return cStatus	String Status do registro do cAlias
*/
Static Function AT570Status(cAlias)

Local cStatus := ''	
Local cFeriasIni := DTOS(x570IniF())
Local cFeriasFim := DTOS(x570FimF())
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada

//Demissão
If !Empty((cAlias)->RA_DEMISSA) .AND. ((cAlias)->RA_DEMISSA <= (cAlias)->ABB_DTINI .OR. (cAlias)->RA_DEMISSA <= (cAlias)->ABB_DTFIM)
	cStatus := 'BR_VERMELHO'
	
//Férias
ElseIf ((cAlias)->ABB_DTINI >= cFeriasIni .AND. (cAlias)->ABB_DTINI <= cFeriasFim) .OR.;
		((cAlias)->ABB_DTFIM >= cFeriasIni .AND. (cAlias)->ABB_DTFIM <= cFeriasFim) .OR.;
		((cAlias)->ABB_DTINI <= cFeriasIni .AND. (cAlias)->ABB_DTFIM >= cFeriasFim)
	cStatus := "BR_AZUL"
	
//Afastamento
ElseIf	( ( lUsaEAIGS .And. (cAlias)->RA_SITFOLH = 'A' ) ;
		.OR. ( !lUsaEAIGS .And. ;
		((cAlias)->ABB_DTINI >= (cAlias)->R8_DATAINI .AND. (cAlias)->ABB_DTINI <= (cAlias)->R8_DATAFIM) .OR.;
		((cAlias)->ABB_DTFIM >= (cAlias)->R8_DATAINI .AND. (cAlias)->ABB_DTFIM <= (cAlias)->R8_DATAFIM) .OR.;
		((cAlias)->ABB_DTINI >= (cAlias)->R8_DATAINI .AND. Empty((cAlias)->R8_DATAFIM) ) .OR.;
		((cAlias)->ABB_DTFIM >= (cAlias)->R8_DATAINI .AND. Empty((cAlias)->R8_DATAFIM) ) ;
		))
	cStatus := "BR_AMARELO"	
									
EndIf

Return cStatus

/*
{Protheus.doc} AT570Legen

Aprensentação das Legendas disponiveis

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
*/
Static Function AT570Legen()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', 'BR_VERMELHO'	, 'Alocação com Demissão')	//'Alocação com Demissão'
	oLegenda:Add( '', 'BR_AMARELO'	, 'Alocação com Afastamento')	//'Alocação com Afastamento'
	oLegenda:Add( '', 'BR_AZUL'		, 'Alocação com Férias')	//'Alocação com Férias'

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

//Substituição da alocação
/*
{Protheus.doc} AT570Subst

Apresenta tela para escolha de substituto e gera registro na manunteção da alocação. 

@param  cAlias	String
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013  
*/

//User Function xT570Subst(cAlias)
Static Function AT570Subst(xAlias)
	Local aArea:=GetArea()
	Local aAreaABB := ABB->(GetArea())	
	Local aAreaABR := ABR->(GetArea())	
	Local cCodAtdSub := ""
	Local aErro 	:= {}
	Local cAliasBkp := ""
	Local cAliasABB	:=""	
	Local aQry540 	:= {}
	Local cQryABB 	:= ""
	Local cAlias	:= xAlias
	Private cMotivo :=  SuperGetMV("MV_ATMTCAN", , "") //Parametro para motivo de cancelamentol
	Private aPergs	:= {}
	Private aRetOpc	:= {}
	Private lRetR	:= .T.
	
	
	//Valida Motivo de cancelamento
	If ValType(cMotivo) != "C" .OR. !AT570VldMt(AllTrim(cMotivo))
		alert("Parametro MV_ATMTCAN deve ser um motivo do tipo de Cancelamento.")
		Return .F.
	EndIf                                                     

	cMotivo := AllTrim(cMotivo)
	cFunAA1:= posicione("AA1",1,xFilial("AA1")+(cAlias)->AA1_CODTEC,"AA1_FUNCAO")
	cTrnAA1:= posicione("AA1",1,xFilial("AA1")+(cAlias)->AA1_CODTEC,"AA1_TURNO")

	aAdd( aPergs ,{1,"Periodo de" 		,cTod(""),"@!",'.T.',"",'.T.',80,.T.})
	aAdd( aPergs ,{1,"Periodo até" 		,cTod(""),"@!",'.T.',"",'.T.',80,.T.})
	aAdd( aPergs ,{1,"Função" 			,cFunAA1,"@!",'.T.',"SRJ",'.T.',80,.F.})
	aAdd( aPergs ,{1,"Turno" 			,cTrnAA1,"@!",'.T.',"SR6",'.T.',80,.F.})

	If !(ParamBox(aPergs,"SUBSTITUIR :"+(cAlias)->AA1_NOMTEC,aRetOpc,,,,,,,"_CHMA01A",.T.,.T.))
		Return
	Endif

	dPerDE	:= aRetOpc[1] 
	dPerATE	:= aRetOpc[2] 
	cFunAA1	:= aRetOpc[3] 
	cTrnAA1	:= aRetOpc[4]
	
	aPergs := {}
	aRetOpc:={}

	aAdd( aPergs ,{1,"Substituto" ,space(getSx3Cache("ABB_CODTEC","X3_TAMANHO")),"@!",'.T.',"AA1TVT",'.T.',80 ,.T.})

	If !(ParamBox(aPergs,"SUBSTITUIR :"+(cAlias)->AA1_NOMTEC,aRetOpc,,,,,,,"_CHMA01B",.T.,.T.))
		Return
	Endif
	
	If !(msgYesNo("Confirma a substituição para o periodo selecionado:"+chr(13)+chr(10)+;
	 			  "De: "+Alltrim((cAlias)->AA1_NOMTEC)+chr(13)+chr(10)+;
	 			  "Para: "+alltrim(posicione("SRA",1,alltrim(aRetOpc[1]),"RA_NOME"))))
		Return
	Endif
	Private xCodTec := (cAlias)->AA1_CODTEC
	Private cNomTec := (cAlias)->AA1_NOMTEC

	Processa({||fProcess(cAlias)}, "Processando modificações")

	RestArea(aAreaABB)
	RestArea(aAreaABR)
	RestArea(aArea)

Return lRetR

Static Function fProcess(cAlias)
	Local aCarga := {}
	Local cCodAtdSub := ""
	Local aErro 	:= {}
	Local cErrs 	:= ""
	Local cAliasBkp := ""
	Local cAliasABB	:=""	
	Local aQry540 	:= {}
	Local cQryABB 	:= ""
	Private aImpress:= {}

	aRet:= fVldSub() //Validações da substituição
	If !(aRet[1])
		alert(aRet[2])
		Return
	Endif 		
	cTipoAloc := At330TipAlo(.F.) //Informa o tipo
	
	cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("ABB")+" ABB "
	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ABB_FILIAL = '"+(cAlias)->ABB_FILIAL+"' AND "
	cQuery+= "ABB_CODTEC = '"+(cAlias)->AA1_CODTEC+"' AND "
	cQuery+= "ABB_DTINI BETWEEN '"+dTos(dPerDE)+"' AND '"+dTos(dPerATE)+"' AND "
	cQuery+= "ABB_ATIVO <> '2' "
	If select("QRABB") > 0
		QRABB->(dbCloseArea()) 
	Endif 
	tcQuery cQuery new Alias QRABB

	while QRABB->(!Eof())
		dbSelectArea("ABB")
		ABB->(dbGoto(QRABB->RECNO))
		ABQ->(DbSetOrder(1))//ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM
		If ABQ->(DbSeek(xFilial("ABQ")+ABB->ABB_IDCFAL))
			AAdd(aCarga,  { ABB->ABB_CODTEC	,;
							SubStr( ABB->ABB_IDCFAL, 1, TAMSX3( 'AAH_CONTRT' )[1] ),;
				            ABB->ABB_CODIGO	,;
				            DTOS(ABB->ABB_DTINI),;
				            ABB->ABB_HRINI,;
				            DTOS(ABB->ABB_DTFIM),;
				            ABB->ABB_HRFIM} )//Origem		
					
			//Verifica Manutenções
			If	AT570CkMan(ABB->ABB_FILIAL, ABB->ABB_CODIGO) 
				cErrs+= "A agenda do dia "+cValtochar(ABB->ABB_DTINI)+" já possui manutenção por motivo de cancelamento "
				
			Else//Não existe manutenção do tipo Cancelamento '05'

				cCodAtdSub:= aRetOpc[1] //Codigo do substituto 
				cAliasABB := GetNextAlias()
				cAliasBkp := At550GtAls()		
				
				aQry540 := AT540ABBQry( ABB->ABB_CODTEC, ABB->ABB_CHAVE, ABB->ABB_DTINI, ABB->ABB_DTFIM, Nil , Nil, ABB->ABB_CODIGO, .T., ABB->ABB_ENTIDA )//Recupera cQuery para o model da TECA550
					
				If Len(aQry540) > 0 
					cQryABB := aQry540[1]
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryABB),cAliasABB)
					//At550StAls(cAliasABB)//Add Alias para o model
					u_xATSVStAls(cAliasABB)//Add Alias para o model
						
					//oModel	:= FWLoadModel( "TECA550" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
					oModel		:= FWLoadModel( "RSVNA007" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
					oModel:SetOperation(MODEL_OPERATION_INSERT)
					oModel:Activate()
						
					If !Empty(cCodAtdSub)
						x550UpdTdv(.T.,ABB->ABB_CODIGO) //Apaga a agenda
						oModel:SetValue( 'XBRMASTER', 'ABR_MOTIVO', cMotivo) //ABRMASTER
						oModel:LoadValue( 'XBRMASTER', 'ABR_CODSUB', cCodAtdSub) //ABRMASTER
						lRetR := oModel:VldData()
						If ( lRetR )											
							lRetR := oModel:CommitData()//Grava Model
							aadd(aImpress,{;
										   ABB->ABB_FILIAL	,;  //Filial
										   xCodTec 			,; 	//Anterior
										   alltrim(cNomTec)	,; 	//Nome Anterior
										   ABB->ABB_CODTEC	,;	//Novo
										   alltrim(posicione("SRA",1,alltrim(aRetOpc[1]),"RA_NOME")) ,; //Nome Novo
										   ABB->ABB_DTINI	,; //Inicio
										   ABB->ABB_DTFIM	,; //Final
										   SubStr( ABB->ABB_IDCFAL, 1, TAMSX3( 'AAH_CONTRT' )[1]),; //Contrato
										   ABB->ABB_LOCAL	,; //Local
										   Posicione("ABS",1,xFilial("ABS")+ABB->ABB_LOCAL,"ABS_DESCRI") ,; //Nome Local
										   ABB->ABB_HRINI	,; //Hora Inicial
										   ABB->ABB_HRFIM})
						Else
							aErro   := oModel:GetErrorMessage()						
							alert(aErro[MODEL_MSGERR_MESSAGE])
						EndIf
					EndIf
					//At550StAls(cAliasBkp)//Volta alias original para rotina
					u_xATSVStAls(cAliasBkp)//Volta alias original para rotina
				EndIf	
			EndIf
			
		EndIf
		QRABB->(dbSkip())
	Enddo
	QRABB->(dbCloseArea())
	If !empty(cErrs)
		alert(cErrs)
	Endif
	if msgyesNo("Deseja imprimir relatório com as informações processadas?")
		fImpress07A()
	Endif 
Return


//Atualiza Browse
/*
{Protheus.doc} AT570Refresh

Atualiza o Browse

@param  oBrw FWFormBrowse
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013  
*/
User Function xT570Refresh(oBrw)		
	oBrw:SetQuery( AT570Query(dAlocDe, dAlocAte, cAtendDe, cAtendAte) )		
	oBrw:Refresh( .T. )
Return


/*
{Protheus.doc} AT570VldMt

Realiza validação do motivo de manut
@param  cMotivo String Motivo que será validado
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean 
*/
Static Function AT570VldMt(cMotivo)
Local aArea 	:= GetArea()
Local aAreaABN := ABN->(GetArea())
Local cTipo	:= ''
Local lRet := .F.

If ValType(cMotivo) != "C"
	Return .F.
EndIf

DbSelectArea('ABN')
ABN->(DbSetOrder(1))//ABN_FILIAL+ABN_MOTIVO

If ( ABN->( DbSeek( xFilial('ABN') + cMotivo ) ) )
	cTipo := ABN->ABN_TIPO
EndIf

If cTipo == MANUT_TIPO_CANCEL
	lRet := .T.
EndIf

RestArea(aAreaABN)
RestArea( aArea )

Return lRet


/*
{Protheus.doc} At570VldRh

Valida Inconsistencias no RH para alocação em determinada data.
Retorn Verdadeiro caso não exista inconsistencias para o tecnico, Falso caso exista inconsistencias

@param	cCodTec	String Codigo do tecnico a ser validado
@param dDataIni	Data Data inicial de alocação a ser validada
@param dDataFim	Data Data Final de alocação a ser validada
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet	Boolean 
*/
User Function xt570VldRh(cCodTec, dDataIni, dDataFim,nTpRest)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaAA1:= AA1->(GetArea())
Local cFilFun := "" 
Local cMat := ""
Local lUsaEAIGS := ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada

Default nTpRest := 0

AA1->(DbSetOrder(1))//AA1_FILIAL+AA1_CODTEC
 
If AA1->(MsSeek(xFilial("AA1")+cCodTec))
	cFilFun := AA1->AA1_FUNFIL
	cMat := AA1->AA1_CDFUNC	
EndIf

If !Empty(cMat)
	
	//Verifica inconsistencias em determinada data
	If CheckDemis(cFilFun, cMat, dDataIni, dDataFim) .OR. CheckAfast(cFilFun, cMat, dDataIni, dDataFim)
		nTpRest := 1
		lRet 	:= .F.
	EndIf	
	
	If lRet .And. CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
		lRet 	:= .F.
		nTpRest := 2		
	EndIf	
		
	If lRet .And. lUsaEAIGS .And. Posicione("SRA",1,xFilial("SRA")+cMat,"RA_SITFOLH") $ "A/D"
		lRet := .F.
	EndIf
	
EndIf 
		 
RestArea(aAreaAA1)
RestArea(aArea)
Return lRet 


/*
{Protheus.doc} CheckDemis

Verifica se há inconsistencia de Demissao 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean	 
 */
Static Function CheckDemis(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := .F.
	Local aAreaSRA := SRA->(GetArea())
	
	SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT
	If SRA->(dbSeek(xFilial("SRA")+cMat))
		If !Empty(SRA->RA_DEMISSA) 
			If SRA->RA_DEMISSA <= dDataIni .OR. SRA->RA_DEMISSA <= dDataFim
				lRet := .T.
			EndIf
		EndIf 
	EndIf
	
	RestArea(aAreaSRA)
			
Return lRet


/*/{Protheus.doc} CheckAfast

Verifica se há inconsistencia de Afastamento

Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean	 
/*/ 
Static Function CheckAfast(cFilFun, cMat, dDataIni, dDataFim, lRetPeriod, aPeriodos)
	Local lRet := .F.
	Local aArea := GetArea()
	Local cAlias := GetNextAlias() 
	
	Default lRetPeriod := .F.
	Default aPeriodos := {}
	
	BeginSQL alias cAlias		
		SELECT 	COUNT(*) NUM, SR8.R8_DATAINI, SR8.R8_DATAFIM
 		FROM %table:SR8% SR8  
 		WHERE 		
			SR8.%notDel%
 			AND SR8.R8_FILIAL = %exp:cFilFun% 				
 			AND SR8.R8_MAT = %exp:cMat%
 			AND (( SR8.R8_DATAINI BETWEEN %exp:dDataIni% AND %exp:dDataFim%
      				OR SR8.R8_DATAFIM BETWEEN %exp:dDataIni% AND %exp:dDataFim%)
      				
      		OR ( %exp:dDataIni% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM 
      				OR %exp:dDataFim% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM))
      				
      				
      	GROUP BY
      		SR8.R8_DATAINI, SR8.R8_DATAFIM		
	EndSQL	

	If (cAlias)->(!Eof()) .AND. (cAlias)->NUM > 0
		lRet := .T.
	EndIf
	
	If lRetPeriod
		While (cAlias)->(!Eof())
			AADD(aPeriodos , {(cAlias)->R8_DATAINI ,(cAlias)->R8_DATAFIM})
			(cAlias)->(DbSkip())
		End
	EndIf
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
					
Return lRet

 
/*/{Protheus.doc} CheckAfast

Verifica se há inconsistencia de Férias

Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
@return lRet Boolean	 
/*/ 
Static Function CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
	Local lRet := .F.
	Local aArea := GetArea()
	Local cAliasSRF := GetNextAlias() 
		
	BeginSQL alias cAliasSRF			
		SELECT 	
			SRF.RF_DATAINI, 
			SRF.RF_DFEPRO1,
			SRF.RF_DATINI2,
			SRF.RF_DFEPRO2,
			SRF.RF_DATINI3,
			SRF.RF_DFEPRO3
			
 		FROM %table:SRF% SRF 
 		WHERE 
			SRF.%notDel%
 			AND SRF.RF_FILIAL = %exp:cFilFun% 				
 			AND SRF.RF_MAT = %exp:cMat%
 			AND ( 	
 					(
 						%exp:dDataIni% >= SRF.RF_DATAINI OR
						%exp:dDataFim% <= SRF.RF_DATAINI 				
					) OR (					
						%exp:dDataIni% >= SRF.RF_DATINI2 OR	
						%exp:dDataFim% <= SRF.RF_DATINI2  					
					) OR ( 	
						%exp:dDataIni% >= SRF.RF_DATINI3 OR
						%exp:dDataFim% <= SRF.RF_DATINI3 
 					)
 				) 	 			
	EndSQL	

	While (cAliasSRF)->(!Eof())
	
		If !Empty((cAliasSRF)->RF_DATAINI) .AND.;
			DTOS(dDataIni) >= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1))) .OR.;
			DTOS(dDataFim) >= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1))) .OR.;
			DTOS(dDataIni) <= (cAliasSRF)->RF_DATAINI .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATAINI) + ((cAliasSRF)->RF_DFEPRO1-1)))
				
			lRet := .T.
			Exit
								
		ElseIf  !Empty((cAliasSRF)->RF_DATINI2) .AND.;
			DTOS(dDataIni) >= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1))) .OR.;
			DTOS(dDataFim) >= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1))) .OR.;
			DTOS(dDataIni) <= (cAliasSRF)->RF_DATINI2 .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATINI2) + ((cAliasSRF)->RF_DFEPRO2-1)))
			
			lRet := .T.
			Exit
						
		ElseIf  !Empty((cAliasSRF)->RF_DATINI3) .AND.;
			DTOS(dDataIni) >= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataIni) <= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1))) .OR.;
			DTOS(dDataFim) >= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataFim) <= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1))) .OR.;
			DTOS(dDataIni) <= (cAliasSRF)->RF_DATINI3 .AND. DTOS(dDataFim) >= DTOS((STOD((cAliasSRF)->RF_DATINI3) + ((cAliasSRF)->RF_DFEPRO3-1)))
			
			lRet := .T.
			Exit
						
		EndIf

		(cAliasSRF)->(DbSkip())
	EndDo

	(cAliasSRF)->(DbCloseArea())
			
	RestArea(aArea)		
Return lRet

/*
{Protheus.doc} AT570Detal

Apresenta tela com detalhes de conflitos de alocação

@param	cAtend		String	Codigo do atendente
@param	aPeriodos	Array	Informações de periodos a serem considerados
@param	aConfAloc	Array	Configuração de alocação a ser considerada
@param	aPosPeriod	Array	Posição de data inicial e data Final dentro do aConfAloc [1]Data Inicial [2]Data Final
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   04/06/2013 
*/
User Function xT570Detal(cAtend, aPeriodos)
Local nI := 1
Local dAlocDe := STOD("")
Local dAlocAte := STOD("") 
Local cAliasBkp := cAliasTmp //realiza backup do alias atual da variavel estatica, para o caso de chamar a rotina dentro da TECA570


Default aPeriodos := {}

If ValType(aPeriodos) == "A" .AND. Len(aPeriodos) > 0
	dAlocDe 	:= aPeriodos[1][1]
	dAlocAte 	:= aPeriodos[1][3]
	
	//Encontra menor e mairo data de alocacao do periodo
	For nI:=1 To Len(aPeriodos)
		If aPeriodos[nI][1] < dAlocDe
			dAlocDe := aPeriodos[nI][1]
		EndIf
		If aPeriodos[nI][3] > dAlocAte
			dAlocAte := aPeriodos[nI][3]
		EndIf
	Next nI 
	
	RSVNA006({dAlocDe, dAlocAte, cAtend, cAtend}, .T.)
	cAliasTmp := cAliasBkp //Volta Alias
EndIf    
	
Return

/*
{Protheus.doc} AT570CkMan

Verifica se agenda possui manutenções do tipo de cancelamento

@param	cFil	String	Filial da agenda
@param	cAgenda	String	Codigo da Agenda

@return lRet	Boolean	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   05/06/2013 
*/
Static Function AT570CkMan(cFil, cAgenda)  
	Local lRet := .F.  
	Local aArea := ABR->(GetArea())
	
	ABR->(DbSelectArea(1))//ABR_FILIAL+ABR_AGENDA+ABR_MOTIVO
	ABR->( MsSeek(cFil+cAgenda ) )
	While ABR->(!EOF()) .AND. ABR->ABR_FILIAL == cFil .AND. ABR->ABR_AGENDA == cAgenda
		If AT570VldMt(ABR->ABR_MOTIVO) 
			lRet := .T.
			Exit
		EndIF
		ABR->(DbSkip())
	End
	
	RestArea(aArea)

Return lRet

/*
{Protheus.doc} AT570Perm

Recupera permissão de contratos e equipes no formato SQL para realização de filtros em query

@param  
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return cPermissao String Permissoes no formato SQL
 
*/
Static Function AT570Perm()
Local aPermissao	:= at570GetPe()//Recupera array de permissoes
Local aOs := {}
Local aAtend := {}
Local cOs:=""
Local cAtend := ""

Local nI := 1
Local cRet := ""

//Verifica permissoes de equipes
aAtend := at570PerAt()
If Len(aAtend) > 0
	For nI:=1 To Len(aAtend)
		cAtend += "'"+aAtend[nI]+"',"
	Next nI
	
	If !Empty(cAtend)
		cAtend:=SubStr(cAtend, 1, Len(cAtend)-1)
	EndIf
EndIf

If !Empty(cAtend)
 	cRet += " AND ABB.ABB_CODTEC IN ("+cAtend+")"
EndIf
 
Return cRet

/*
{Protheus.doc} at570PerAt

retorna codigo dos atendentes da equipe do usuario logado.

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return aRet Array Codigos de atendentes das equipes do usuario
*/
Static Function at570PerAt()
Local aPerEquipe := at570Equip(__cUserId)
Local aRet:={}
Local nI:=1

//Recupera codigo dos atendentes
For nI:=1 To Len(aPerEquipe)
	AAY->(DbSetOrder(1))//AAY_FILIAL+AAY_CODEQU+AAY_CODTEC
	If AAY->(MsSeek(xFilial("AAY")+aPerEquipe[nI]))
		
		While( AAY->(!EOF()) .AND. xFilial("AAY")==AAY->AAY_FILIAL .AND. aPerEquipe[nI]==AAY->AAY_CODEQU)
			If aScan(aRet, {|x| x == AAY->AAY_CODTEC}) == 0
				aAdd(aRet,AAY->AAY_CODTEC)
			EndIf				
			AAY->(DbSkip())			
		End	
		
	EndIf
Next nI


Return aRet

/*
{Protheus.doc} at570Equip

Retorna codigos das equipes do usuario definido pelo parametro cId

@param  cID String Id do usuario
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return aEquipe Array Codigos da equipe do usuario 
*/
Static Function at570Equip(cId)
Local aEquipe := {} 
Local cAlias := GetNextAlias()
Local cQuery := "" 

AA1->(DbSetorder(4)) //AA1_FILIAL+AA1_CODUSR

If !Empty(cId) .AND. AA1->(DbSeek(xFilial("AA1")+cId))
	cQuery := 	" SELECT AAY.*,R_E_C_N_O_ AAYRECNO FROM " + RetSqlName("AAY") + " AAY "
	cQuery += 	"WHERE"
	cQuery += 	" AAY_FILIAL='" + xFilial( "AAY" ) + "' AND "
	cQuery +=	"AAY_CODTEC = '"+AA1->AA1_CODTEC+"' AND "
	cQuery += 	"D_E_L_E_T_=' '"
	
	cQuery := ChangeQuery( cQuery ) 

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias, .T., .T. ) 

	While (cAlias)->( !Eof() )					
		AAdd(aEquipe, ( cAlias )->AAY_CODEQU)
		( cAlias )->(DbSkip())
	End		
EndIf
	
Return aEquipe


/*
{Protheus.doc} at570CPerm

Verifica se controla permissoes de acordo com parametro MV_TECPCON  e cadastro de permissoes
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return lCOntrola Boolean - Verdadeiro indica que controla permissoes, Falso indica que não controla permissoes 
*/
Static Function at570CPerm()
Local lPercTec		:= SuperGetMv('MV_TECPCON',,.F.)
Local aPermissao	:= at570GetPe()//Recupera permissoes
Local aAtend 		:= at570PerAt()//Permissoes de equipe
Local lControla := .F.

If lPercTec .OR. !Empty(aPermissao) .OR. !Empty(aAtend) 
	lControla := .T.
Else
	lControla := .F.
EndIf	
Return lControla

/*
{Protheus.doc} at570GetPe

Aplicação de padrão singleton para aPErm
 
Controle da variavel estática aPerm, caso não tenha sido realizada atribuição com seu conteudo, realiza a chamada da função At120Perm 
para carregar variavel aPerm somente uma vez no fonte.
	
@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   13/06/2013 
@return aPerm Array
*/
Static Function at570GetPe()
If ValType(aPerm) == "U"
	aPerm := At201Perm()
EndIf
Return aPerm

/*/{Protheus.doc} x570IniF
	
@author rogerio.souza
@since 23/12/2013
@version V11.9
@return dData, Data de inicio das férias
@description
Calcula e retorna data de inicio das férias

/*/
Static Function x570IniF()

Local dData := STOD("")

If !Empty(RF_DATAINI) .AND.;
	ABB_DTINI >= RF_DATAINI .AND. ABB_DTINI <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTFIM >= RF_DATAINI .AND. ABB_DTFIM <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTINI <= RF_DATAINI .AND. ABB_DTFIM >= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1)))
	
	dData := STOD(RF_DATAINI)
								
ElseIf  !Empty(RF_DATINI2) .AND.;
	ABB_DTINI >= RF_DATINI2 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTFIM >= RF_DATINI2 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTINI <= RF_DATINI2 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1)))
	
	dData := STOD(RF_DATINI2)
						
ElseIf  !Empty(RF_DATINI3) .AND.;
	ABB_DTINI >= RF_DATINI3 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTFIM >= RF_DATINI3 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTINI <= RF_DATINI3 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1)))
		
	dData := STOD(RF_DATINI3)	
								
EndIf

Return dData

/*/{Protheus.doc} x570FimF
	
@author rogerio.souza
@since 23/12/2013
@version V11.9	
@return dData, Data final das férias

@description
Calcula e retorna data final das férias do funcionário.

/*/
Static Function x570FimF()

Local dData := STOD("")

If !Empty(RF_DATAINI) .AND.;
	ABB_DTINI >= RF_DATAINI .AND. ABB_DTINI <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTFIM >= RF_DATAINI .AND. ABB_DTFIM <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR.;
	ABB_DTINI <= RF_DATAINI .AND. ABB_DTFIM >= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1)))
	
	dData := STOD(RF_DATAINI) + (RF_DFEPRO1-1)
								
ElseIf  !Empty(RF_DATINI2) .AND.;
	ABB_DTINI >= RF_DATINI2 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTFIM >= RF_DATINI2 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
	ABB_DTINI <= RF_DATINI2 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1)))
	
	dData := STOD(RF_DATINI2) + (RF_DFEPRO2-1)
						
ElseIf  !Empty(RF_DATINI3) .AND.;
	ABB_DTINI >= RF_DATINI3 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTFIM >= RF_DATINI3 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
	ABB_DTINI <= RF_DATINI3 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1)))
		
	dData := STOD(RF_DATINI3) + (RF_DFEPRO3-1)	
								
EndIf


Return dData

/*/{Protheus.doc} At570Filter
	
@since 08/12/2014
@version V12
@return lREt, avaliação do filtro
@description filtro para avaliação de férias, demissão e afastamento durante período de alocação 
/*/
User Function xt570Filter()

Local lAfasta 		:= .F.
Local lDemiss 		:= .F.
Local lFerias 		:= .F.
Local lUsaEAIGS 	:= ( !Empty(SuperGetMv( "MV_RHMUBCO",,"")) ) // verifica se está com integração via EAI habilitada

// Conflito de Afastamento
lAfasta := (AllTrim(R8_DATAINI) <> '')

//Conflito de Demissão
lDemiss := !lAfasta .And. ( ;
				( lUsaEAIGS .And. RA_SITFOLH = 'A' ) ;
				.Or. ;
				( !lUsaEAIGS .And. (( AllTrim(RA_DEMISSA) != '' .AND. RA_DEMISSA <= ABB_DTINI ) .OR. ; 				
				 (AllTrim(RA_DEMISSA) != '' .AND. RA_DEMISSA <= ABB_DTFIM ))) ;
			)

//Conflito de Férias
lFerias := !lAfasta .And. !lDemiss .And. ( ;
				AllTrim(RF_DATAINI) != '' .AND. ;
				( ;
					ABB_DTINI >= RF_DATAINI .AND. ABB_DTINI <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR. ;
					ABB_DTFIM >= RF_DATAINI .AND. ABB_DTFIM <= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) .OR. ;
					ABB_DTINI <= RF_DATAINI .AND. ABB_DTFIM >= DTOS((STOD(RF_DATAINI) + (RF_DFEPRO1-1))) ;
				) ;
			) .OR. ( ;
				AllTrim(RF_DATAINI2) != '' .AND. ;
				( ;
					ABB_DTINI >= RF_DATINI2 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
					ABB_DTFIM >= RF_DATINI2 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) .OR.;
					ABB_DTINI <= RF_DATINI2 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI2) + (RF_DFEPRO2-1))) ;
				) ;
			) .OR. ( ;
				AllTrim(RF_DATAINI3) != '' .AND. ;
				( ;
					ABB_DTINI >= RF_DATINI3 .AND. ABB_DTINI <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
					ABB_DTFIM >= RF_DATINI3 .AND. ABB_DTFIM <= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) .OR.;
					ABB_DTINI <= RF_DATINI3 .AND. ABB_DTFIM >= DTOS((STOD(RF_DATINI3) + (RF_DFEPRO3-1))) ;
				) ;
			)

Return ( lAfasta .Or. lDemiss .Or. lFerias )	

/*/{Protheus.doc} At570ChkDm

Encapsula a função CheckDemis 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação

@simple At570ChkDm(cFilFun, cMat, dDataIni, dDataFim)
@since  18/05/2015 
@return lRet Boolean	 
 /*/
User Function xt570ChkDm(cFilFun, cMat, dDataIni, dDataFim)
Local lRet := CheckDemis(cFilFun, cMat, dDataIni, dDataFim)
Return lRet

/*/{Protheus.doc} At570ChkAf

Encapsula a função CheckAfast 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação
	
@simple At570ChkAf(cFilFun, cMat, dDataIni, dDataFim)
@since  18/05/2015
@return lRet Boolean	 
/*/ 
User Function xt570ChkAf(cFilFun, cMat, dDataIni, dDataFim, lRetPeriod, aPeriodos)
Local lRet := CheckAfast(cFilFun, cMat, dDataIni, dDataFim, lRetPeriod, aPeriodos)
Return lRet

/*
{Protheus.doc} At570ChkFe

Encapsula a função CheckFeria 
Retorna Verdadeiro caso exista inconsitencia de alocação na data informada

@param  cFilFun	String	Filial do funcionário
@param  cMat		String	Matricula do Funcionario
@param  dDataIni	Data	Data inicial de alocação
@param  dDataFim	Data	Data Final de alocação

@simple At570ChkFe(cFilFun, cMat, dDataIni, dDataFim)
@since  18/05/2015 
@return lRet Boolean	 
 */ 
User Function xt570ChkFe(cFilFun, cMat, dDataIni, dDataFim)
Local lRet := CheckFeria(cFilFun, cMat, dDataIni, dDataFim)
Return lRet

/*/{Protheus.doc} fVldSub
Validações do funcionário substituto:
Se o funcionário está demitido/afastado/férias
Se o funcionário se encontra alocado em outro contrato para o periodo
@author diogo
@since 17/04/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fVldSub()
	Local aArea := getArea()
	Local lRet	:= .T.
	
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If !(SRA->(dbSeek(aRetOpc[1])))
		RestArea(aArea)
		Return {.F.,"Funcionário não localizado, verifique os parâmetros informados"}
	Elseif dPerDE <  dAlocDe .or. dPerATE > dAlocAte  
		RestArea(aArea)
		Return {.F.,"Periodo informado não corresponde ao intervalo selecionado: devendo respeitar o intervado de "+cValtochar(dAlocDe)+" até "+cValtochar(dAlocAte)}
	Elseif CheckAfast(xFilial("SRA"), SRA->RA_MAT, dPerDE, dPerATE)
		RestArea(aArea)
		Return {.F.,"Funcionário afastado na folha de pagamento"}
	Elseif CheckDemis(xFilial("SRA"), SRA->RA_MAT, dPerDE, dPerATE)
		RestArea(aArea)
		Return {.F.,"Funcionário demitido na folha de pagamento"}
	Endif
	If CheckFeria(xFilial("SRA"), SRA->RA_MAT, dPerDE, dPerATE)
		RestArea(aArea)
		Return {.F.,"Existe programação de férias para o funcionário no periodo informado"}
	Endif

	//Verifica se tem agendamento na ABB para o substituto no periodo informado
	cQuery:= "SELECT TOP 1 SUBSTRING(ABB_IDCFAL,1,15) CONTRATO  FROM "+RetSqlName("ABB")+" ABB "
	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ABB_FILIAL = '"+xFilial("ABB")+"' AND "
	cQuery+= "ABB_CODTEC = '"+SRA->(RA_FILIAL+RA_MAT)+"' AND  "
	cQuery+= "ABB_DTINI BETWEEN '"+dTos(dPerDE)+"' AND '"+dtos(dPerATE)+"' AND "
	cQuery+= "ABB_ATIVO <> '2' "
	tcQuery cQuery new Alias QRYABB
	If QRYABB->(!Eof())
		cMsgRet:= "Funcionário substituto agendado no periodo selecionado para o contrato "+QRYABB->CONTRATO
		QRYABB->(dbCloseArea())
		RestArea(aArea)
		Return {.F.,cMsgRet}
	Endif
	QRYABB->(dbCloseArea())

	//Verifica se tem agendamento na ABB para o funcionario selecionado
	cQuery:= "SELECT TOP 1 SUBSTRING(ABB_IDCFAL,1,15) CONTRATO  FROM "+RetSqlName("ABB")+" ABB "
	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ABB_FILIAL = '"+xFilial("ABB")+"' AND "
	cQuery+= "ABB_CODTEC = '"+xCodTec+"' AND  "
	cQuery+= "ABB_DTINI BETWEEN '"+dTos(dPerDE)+"' AND '"+dtos(dPerATE)+"' AND "
	cQuery+= "ABB_ATIVO <> '2' "
	tcQuery cQuery new Alias QRYABB
	If QRYABB->(Eof())
		cMsgRet:= "Funcionário "+Alltrim(cNomTec)+" não tem agendamento para o periodo selecionado"
		QRYABB->(dbCloseArea())
		RestArea(aArea)
		Return {.F.,cMsgRet}
	Endif
	QRYABB->(dbCloseArea())
	RestArea(aArea)
Return {.T.,""}

Static Function x550UpdTdv(lDeleta,cAgCopia,cAgNova,cTipGrav)

Local aCpos    := TDV->(DbStruct())
Local nMaxCpos := Len(aCpos)
Local aValores := Array(nMaxCpos)
Local nX       := 1
Local aSave    := GetArea()
Local aSaveTDV := TDV->(GetArea())

DEFAULT lDeleta := .F.

DbSelectArea('TDV')
TDV->(DbSetOrder(1)) //TDV_FILIAL+TDV_CODABB

If TDV->(DbSeek(xFilial('TDV')+cAgCopia))

	If !lDeleta
		// copia os dados da escala
		For nX := 1 To nMaxCpos
			aValores[nX] := TDV->&(aCpos[nX,1])
		Next nX
		
		// grava os dados da escala copiada
		Reclock('TDV', .T.)
		For nX := 1 To nMaxCpos
			TDV->&(aCpos[nX,1]) := aValores[nX]
		Next nX
		
		TDV->TDV_CODABB := cAgNova // substitui o código da agenda anterior do campo
		If !Empty(cTipGrav)  // grava o tipo informado pelo usuário
			TDV->TDV_TPDIA  := cTipGrav
		EndIf
		
		TDV->(MsUnlock())
	Else
		Reclock('TDV',.F.)
			TDV->(DbDelete())
		TDV->(MsUnlock())
	EndIf

EndIf
RestArea(aSaveTDV)
RestArea(aSave)
Return

/*/{Protheus.doc} fImpress07A
Impressão do relatório com o log do processamento
@author diogo
@since 22/04/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fImpress07A
	local oReport
	oReport := reportDef()
	oReport:printDialog()
Return

Static function reportDef()
	local oReport
	Local oSection1
	local cTitulo := 'Relatório Conflito de Alocações'

	oReport := TReport():New('RSVNA06', cTitulo,'', {|oReport| PrintReport(oReport)},"Relatório Conflito de Alocações")
	oReport:SetLandscape()

	oSection1 := TRSection():New(oReport)
	oSection1:SetTotalInLine(.T.)

	TRCell():New(oSection1, "ABB_FILIAL"	, "", 'Unidade'					,,25,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABB_CODTEC1"	, "", 'Funcionário'				,,TamSX3("ABB_CODTEC")[1]+3,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "RA_NOME1"		, "", 'Nome'					,,TamSX3("RA_NOME")[1]+5,,,,.T.,,,,,,,.F.)

	TRCell():New(oSection1, "ABB_CODTEC2"	, "", 'Substituto'				,,TamSX3("ABB_CODTEC")[1]+3,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "RA_NOME2"		, "", 'Nome'					,,TamSX3("RA_NOME")[1]+5,,,,.T.,,,,,,,.F.)

	TRCell():New(oSection1, "ABB_DTINI"		, "", 'Dt. Inicio'				,,TamSX3("ABB_DTINI")[1]+3,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABB_DTFIM"		, "", 'Dt. Final'				,,TamSX3("ABB_DTINI")[1]+3,,,,.T.,,,,,,,.F.)

	TRCell():New(oSection1, "ABB_HRINI"		, "", 'Hr Inicio'				,,TamSX3("ABB_HRINI")[1]+3,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABB_HRFIM"		, "", 'Hr Final'				,,TamSX3("ABB_HRINI")[1]+3,,,,.T.,,,,,,,.F.)

	TRCell():New(oSection1, "ABB_IDCFAL"		, "", 'Contrato'				,,TamSX3("AAH_CONTRT")[1]+6,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABS_LOCAL"		, "", 'Local'					,,TamSX3("ABS_LOCAL")[1]+2,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABS_DESCRI"	, "", 'Descrição Local'			,,TamSX3("ABS_DESCRI")[1]+10,,,,.T.,,,,,,,.F.)
	
Return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local i			:= 1

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)


	For i:=1 To len(aImpress)
		oSection1:Cell("ABB_FILIAL"):SetValue(substr(FWFilName(cEmpAnt,aImpress[i][1]),1,22))
		oSection1:Cell("ABB_CODTEC1"):SetValue(aImpress[i][2])
		oSection1:Cell("RA_NOME1"):SetValue(aImpress[i][3])
		oSection1:Cell("ABB_CODTEC2"):SetValue(aImpress[i][4])
		oSection1:Cell("RA_NOME2"):SetValue(aImpress[i][5])
		oSection1:Cell("ABB_DTINI"):SetValue(aImpress[i][6])
		oSection1:Cell("ABB_DTFIM"):SetValue(aImpress[i][7])
		oSection1:Cell("ABB_IDCFAL"):SetValue(aImpress[i][8])
		oSection1:Cell("ABS_LOCAL"):SetValue(aImpress[i][9])
		oSection1:Cell("ABS_DESCRI"):SetValue(aImpress[i][10])
		oSection1:Cell("ABB_HRINI"):SetValue(aImpress[i][11])
		oSection1:Cell("ABB_HRFIM"):SetValue(aImpress[i][12])
		oSection1:PrintLine()	
	Next
	oSection1:Finish()
Return