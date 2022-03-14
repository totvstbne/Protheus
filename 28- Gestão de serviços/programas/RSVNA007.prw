#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
                       
#DEFINE MANUT_TIPO_FALTA		'01'	//Falta
#DEFINE MANUT_TIPO_ATRASO		'02'	//Atraso
#DEFINE MANUT_TIPO_SAIDAANT		'03'	//Saída Antecipada
#DEFINE MANUT_TIPO_HORAEXTRA	'04'	//Hora Extra
#DEFINE MANUT_TIPO_CANCEL		'05'	//Cancelamento
#DEFINE MANUT_TIPO_TRANSF		'06'	//Transferência
#DEFINE MANUT_TIPO_AUSENT		'07'	//Ausência

Static cAliasTmp 	:= ''	//Alias temporário com os dados da Agenda do atendente selecinado para manutenção
Static aCarga		:= {}	//Array com dados para a tela de substituição
Static cConfCtr 	:= ''	//Configuração da OS selecionada na transferência
Static nTempoIni	:= 0	//Tempo de hora extra antes do horário
Static nTempoFim	:= 0	//Tempo de hora extra após o horário
//Static cTipoAloc	:= ""  //Define o tipo da movimentação da alocação 
Static lGeraMemo := .F.         //Variavel que controla se Deseja realmente gerar o memorando?   

//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RSVNA007 
Cadastro de manutenções da agenda.
A função deve ser acionada apenas para alteração ou exclusão de uma agenda que teve manutenção.
Para inclusão utilize a função xATSVExecView()

@sample 	RSVNA007( cAgenda )

@param		cAgenda	Código da agenda (ABB_CODIGO) que está sendo 
						alterada. Informado quando a tela for ser usada
						para alterar ou excluir uma manutenção.
						
@author 	Danilo Dias
@since		21/11/2012
@version	P11.8
/*/
//------------------------------------------------------------------------------------------------------
User Function RSVNA007( cAgenda, cAlias )

Local oBrowse	:= nil
Local cFilxFi   := IIF(IsInCallStack('TECA540'),' .AND. ABR_FILIAL = "' + xFilial('ABR') + '"','')

Default cAgenda	:= ''
Default cAlias	:= ''

Private aRotina 	:= MenuDef()	// 'Monta menu da Browse'
Private cCadastro	:= 'Manutenção da Agenda'

cAliasTmp := cAlias

oBrowse := FWMBrowse():New()

oBrowse:SetAlias( "ABR" )
oBrowse:SetDescription( cCadastro )
oBrowse:SetFilterDefault( "ABR_AGENDA = '" + cAgenda + "'" + cFilxFi )	//Filtra manutenções da agenda informada
oBrowse:DisableDetails()
oBrowse:Activate()	//Ativa tela principal (Browse)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVExecView
Função para executar a View, quando é necessário acioná-la através
de outra rotina.
Use essa função para incluir uma nova manutenção.

@sample 	xATSVExecView( cAlias, nOpc )

@param		cAlias		Alias temporário com os dados da ABB.
						Exemplo: AT540ABBQry (TECA540)
			nOpc		Opção indicando a operação realizada.
			aAgendas	Agendas que estão sofrendo manutenção, selecionadas no TECA540.
			
@return	nConf		Indica se o usuário confirmou ou não a operação.
@return						0-Confirmou, 1-Cancelou

@author	Danilo Dias
@since		21/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function xATSVExecView( cAlias, nOpc, aAgendas )

Local aArea	:= GetArea()
Local nConf 	:= 1		//Indica se o usuário confirmou ou não a manutenção
Local aBts 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,'Confirmar'},{.T.,'Fechar'},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}  // "Confirmar" ### "Fechar"

Default cAlias	:= ''
Default nOpc		:= 0
Default aAgendas 	:= {}

Private cCadastro	:= 'Manutenção da Agenda'

If ( cAlias == '' )
	Help( ' ', 1, 'xATSVExecView', , "Falha no carregamento da rotina. Alias inválido.", 1, 0 )	//"Falha no carregamento da rotina. Alias inválido."
Else
	cAliasTmp	:= cAlias
	aCarga 		:= aAgendas
	cConfCtr 	:= ''
	nConf 		:= FwExecView( '', "VIEWDEF.RSVNA007", nOpc, /*oOwner*/, {||.T.}, /*bOk*/, 30, aBts )
EndIf

RestArea( aArea )

Return ( nConf )


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para montar o menu principal da rotina.

@sample 	MenuDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title "Alterar" Action "VIEWDEF.RSVNA007" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0	//"Alterar"
ADD OPTION aRotina Title "Excluir" Action "VIEWDEF.RSVNA007" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	//"Excluir"
ADD OPTION aRotina Title "Visualizar" Action "VIEWDEF.RSVNA007" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	//"Visualizar"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para definir o model da rotina.

@sample 	ModelDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.80
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruABR	:= nil
Local aTrigger	:= {}
Local bCommit		:= { |oModel| xATSVCommit( oModel ) }
Local bValid		:= { |oModel| xATSVVldModel( oModel ) }
Local bInic		:= { |oModel| xATSVInicia( oModel ) }
Local cValid 	:= ""
Local cVldUser 	:= ""
Local bVldMotivo 	:= Nil

oModel 	:= MPFormModel():New( 'YSVNA007',, bValid, bCommit )
oStruABR	:= FWFormStruct( 1, 'ABR' )

aTrigger := FwStruTrigger ( 'ABR_DTINI', 'ABR_TEMPO', 'xATSVTempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
aTrigger := FwStruTrigger ( 'ABR_HRINI', 'ABR_TEMPO', 'xATSVTempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
aTrigger := FwStruTrigger ( 'ABR_DTFIM', 'ABR_TEMPO', 'xATSVTempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
aTrigger := FwStruTrigger ( 'ABR_HRFIM', 'ABR_TEMPO', 'xATSVTempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )


//Altera propriedades dos campos
oStruABR:SetProperty( 'ABR_DTMAN'	, MODEL_FIELD_WHEN, 	{ || .F. } )
oStruABR:SetProperty( 'ABR_MOTIVO'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_MOTIVO' ) } )
oStruABR:SetProperty( 'ABR_DTINI'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_DTINI'  ) } )
oStruABR:SetProperty( 'ABR_HRINI'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_HRINI'  ) } )
oStruABR:SetProperty( 'ABR_DTFIM'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_DTFIM'  ) } )
oStruABR:SetProperty( 'ABR_HRFIM'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_HRFIM'  ) } )
oStruABR:SetProperty( 'ABR_CODSUB'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_CODSUB' ) } )
oStruABR:SetProperty( 'ABR_ITEMOS'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_ITEMOS' ) } )
oStruABR:SetProperty( 'ABR_TEMPO'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_TEMPO'  ) } )
oStruABR:SetProperty( 'ABR_USASER'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_USASER' ) } )
oStruABR:SetProperty( 'ABR_TIPDIA'	, MODEL_FIELD_WHEN, 	{ || u_xATSVWhen( oModel, 'ABR_TIPDIA' ) } )  // campo criado no projeto piloto da FT

cValid := RTrim(GetSX3Cache( "ABR_MOTIVO", "X3_VALID" )) + " .And. u_xATSVValid( a, b, c, d ) "
If !Empty( cVldUser := RTrim(GetSX3Cache( "ABR_MOTIVO", "X3_VLDUSER" ) ) )
	cValid += ".And. " + cVldUser
EndIf
bVldMotivo := FwBuildFeature( STRUCT_FEATURE_VALID, cValid )
// oStruABR:SetProperty( 'ABR_MOTIVO'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | xATSVValid( oModel, cCampo, xValIns, xValAnt ) } )
oStruABR:SetProperty( 'ABR_MOTIVO'	, MODEL_FIELD_VALID,	bVldMotivo )

oStruABR:SetProperty( 'ABR_ITEMOS'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | u_xATSVValid( oModel, cCampo, xValIns, xValAnt ) } )

// validar a edição dos horários, permitindo somente a redução e/ou aumento conforme o tipo inserido 
oStruABR:SetProperty( 'ABR_DTINI'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | u_xalidDtHr( oMdlVld, cCampo, xValIns, xValAnt ) } )
oStruABR:SetProperty( 'ABR_HRINI'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | u_xalidDtHr( oMdlVld, cCampo, xValIns, xValAnt ) } )
oStruABR:SetProperty( 'ABR_DTFIM'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | u_xalidDtHr( oMdlVld, cCampo, xValIns, xValAnt ) } )
oStruABR:SetProperty( 'ABR_HRFIM'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | u_xalidDtHr( oMdlVld, cCampo, xValIns, xValAnt ) } )

oStruABR:SetProperty( 'ABR_AGENDA'	, MODEL_FIELD_OBRIGAT, .F. )	//Remove obrigatoriedade pois preenchimento é feito em tempo de execução

//Adiciona um controle do tipo formulário
oModel:AddFields( 'XBRMASTER', , oStruABR )
oModel:GetModel( 'XBRMASTER' ):SetDescription("Substituição")

oModel:SetActivate( bInic )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criar a visualização da rotina.

@sample 	ViewDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	 	:= nil
Local oStruABR	:= nil
Local oView		:= nil
Local cCodAtdSub 	:= ''
Local bButtonSub	:= { |oView| xATSVCmdSub(oView) }

oModel		:= FWLoadModel( "RSVNA007" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
oStruABR	:= FWFormStruct( 2, "ABR" )	//Cria as estruturas a serem usadas na View
oView 		:= FWFormView():New()		//Cria o objeto de View

oStruABR:RemoveField( 'ABR_AGENDA' )
oStruABR:SetProperty( 'ABR_TEMPO', MVC_VIEW_CANCHANGE, .F.)

If (At680Perm( Nil , __cUserID, "036"))
	oStruABR:SetProperty( 'ABR_CODSUB', MVC_VIEW_CANCHANGE, .T.)
EndIf
	
	

oView:SetModel( oModel )										//Define qual Modelo de dados será utilizado
oView:AddField( "VIEW_ABR", oStruABR, "XBRMASTER" )		//Adiciona um controle do tipo formulário
oView:CreateHorizontalBox( "MASTER", 100 )				//Cria um box superior para exibir a Master
oView:SetOwnerView( "VIEW_ABR", "MASTER" )				//Relaciona o identificador (ID) da View com o "box" para exibição

oView:AddUserButton( 'Sel. Substituto'  /*<cTitle >*/,;	//'Sel. Substituto'
                     '' /*<cResource >*/,;
                     bButtonSub /*<bBloco>*/,;
                     /*[cToolTip]*/,;
                     /*[nShortCut]*/,;
                     {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} /*[aOptions]*/ )
oView:AddUserButton( 'Limpa Substituto' /*<cTitle >*/,;	//'Limpa Substituto'
                     '' /*<cResource >*/,;
                     {|oView| oModel:SetValue('XBRMASTER', 'ABR_CODSUB', ''),;
                              oModel:SetValue('XBRMASTER', 'ABR_NOMSUB', '')} /*<bBloco>*/,;
                     /*[cToolTip]*/,;
                     /*[nShortCut]*/,;
                     {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} /*[aOptions]*/ )

Return oView


//----------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVInicia
Função para inicializar campos da View.

@sample 	xATSVInicia( oModel )
@param		oModel		Objeto com modelo de dados.

@author	Danilo Dias
@since		22/01/2013
@version	P11.8
/*/
//----------------------------------------------------------------------------------
Static Function xATSVInicia( oModel )

Local aArea	:= GetArea()

If ( oModel:GetOperation() == MODEL_OPERATION_INSERT )

	oModel:LoadValue( 'XBRMASTER', 'ABR_DTINI', SToD( (cAliasTmp)->ABB_DTINI ) )
	oModel:LoadValue( 'XBRMASTER', 'ABR_HRINI', (cAliasTmp)->ABB_HRINI )
	oModel:LoadValue( 'XBRMASTER', 'ABR_DTFIM', SToD( (cAliasTmp)->ABB_DTFIM ) )
	oModel:LoadValue( 'XBRMASTER', 'ABR_HRFIM', (cAliasTmp)->ABB_HRFIM )
	oModel:LoadValue( 'XBRMASTER', 'ABR_TEMPO', '00:00' )
	oModel:LoadValue( 'XBRMASTER', 'ABR_CODSUB', '' )
	oModel:LoadValue( 'XBRMASTER', 'ABR_ITEMOS', '' )
	oModel:LoadValue( 'XBRMASTER', 'ABR_USASER', '2' )
	
EndIf

RestArea( aArea )

Return


//----------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVSelSub
Valida se o tipo selecionado permite a substiuição. Se permitir aciona a tela
de seleção de atendente substituto (TECA560).

@sample 	xATSVSelSub( cCodAtdSub )
@param		cCodAtdSub		Código do atendente a ser substituído. (Referência)

@author	Danilo Dias
@since		22/01/2013
@version	P11.8
/*/
//----------------------------------------------------------------------------------
Static Function xATSVSelSub( cCodAtdSub, oModel )

Local aArea	:= GetArea()
Local cTipo 	:= xATSVTipo()	//Verifica o tipo do motivo da manutenção
Local cCodABB := ""
Local cOrigem := ""
Local aAreaABB := ABB->(GetArea())
Local aAreaABQ := ABQ->(GetArea())
Local aReserva := {}//Data e horario a ser considerado para reserva tecnica
Local nI := 1
Local lCarrCarg := .F. //Carrega o array de carga


If ( cTipo $( '01|02|03|05|06|07' ) )

	If Len(aCarga) = 0 .AND. !Empty(cAliasTmp)
		AAdd( aCarga, { (cAliasTmp)->ABB_CODTEC 										 	,;
						SubStr( (cAliasTmp)->ABB_IDCFAL, 1, TAMSX3( 'AAH_CONTRT' )[1] )	,;
			            (cAliasTmp)->ABB_CODIGO  					   						,;
			            (cAliasTmp)->ABB_DTINI												,;
			            (cAliasTmp)->ABB_HRINI	   											,;
			            (cAliasTmp)->ABB_DTFIM	   											,;
			            (cAliasTmp)->ABB_HRFIM		} )
	   lCarrCarg := .T.
	EndIf

	//Verifica origem do contrato
	If Len(aCarga) > 0
		If Len(aCarga[1]) > 0
			cCodABB := aCarga[1][3]
		EndIf
	EndIf

	If !Empty(cCodABB)
		DbSelectArea("ABB")
		DbSelectArea("ABQ")
		ABB->(DbSetOrder(8))//ABB_FILIAL+ABB_CODIGO
		ABQ->(DbSetOrder(1))//ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM

		If ABB->(DbSeek(xFilial("ABB")+cCodABB))
			If ABQ->(DbSeek(xFilial("ABQ")+ABB->ABB_IDCFAL))
				cOrigem := ABQ->ABQ_ORIGEM
			EndIf

			//Realiza tratamento de horários para a substituição na reserva
			//copia do horario da agenda (aCarga)
			aReserva := aClone(aCarga)

			For nI:= 1 To Len(aReserva)
				If cTipo == '02'//Atraso
					aReserva[nI][4] := ABB->ABB_DTINI
					aReserva[nI][5]	:= ABB->ABB_HRINI
					aReserva[nI][6]	:= oModel:GetValue("XBRMASTER", "ABR_DTINI")
					aReserva[nI][7]	:= oModel:GetValue("XBRMASTER", "ABR_HRINI")
				ElseIf cTipo == '03'//Saida Antecipada
					aReserva[nI][4] := oModel:GetValue("XBRMASTER", "ABR_DTFIM")//dDtFim
					aReserva[nI][5]	:= oModel:GetValue("XBRMASTER", "ABR_HRFIM")//cHrFim
					aReserva[nI][6]	:= ABB->ABB_DTFIM
					aReserva[nI][7]	:= ABB->ABB_HRFIM
				ElseIf cTipo $ '01/05/06' // Falta / Cancelamento / Transferência
					aReserva[nI][4] := ABB->ABB_DTINI
					aReserva[nI][5]	:= ABB->ABB_HRINI
					aReserva[nI][6]	:= ABB->ABB_DTFIM
					aReserva[nI][7]	:= ABB->ABB_HRFIM
				EndIf
			Next nI

		EndIf

	EndIf

	TECA560( aCarga, @cCodAtdSub, cOrigem, aReserva )
	If lCarrCarg
		aCarga := {}
	EndIf
Else
	Help( " ", 1, "xATSVSelSub", , 'Tipo do motivo selecionado não permite substituição.', 1, 0 )	//'Tipo do motivo selecionado não permite substituição.'
EndIf

RestArea(aAreaABB)
RestArea(aAreaABQ)
RestArea( aArea )

Return


//----------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVTempo()
Função para calcular o tempo decorrido entre a data e hora da
agenda (ABB) e a data e hora informada na tela de manutenção (ABR).

@sample 	xATSVTempo()
@return	xHoras		Total de horas extras no formato 'HH:MM'

@author	Danilo Dias
@since		22/01/2013
@version	P11.8
/*/
//----------------------------------------------------------------------------------
Static Function xATSVTempo()

Local aArea		:= GetArea()
Local aAreaABN	:= ABN->(GetArea())
Local oModel		:= FwModelActive()
Local xHoras		:= 0
Local cTipo		:= ''
Local cMotivo		:= oModel:GetValue( 'XBRMASTER', 'ABR_MOTIVO' )
Local dDtIniABB 	:= SToD( (cAliasTmp)->ABB_DTINI )
Local dDtIniABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_DTINI' )
Local cHrIniABB 	:= (cAliasTmp)->ABB_HRINI
Local cHrIniABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_HRINI' )
Local dDtFimABB 	:= SToD( (cAliasTmp)->ABB_DTFIM )
Local dDtFimABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_DTFIM' )
Local cHrFimABB 	:= (cAliasTmp)->ABB_HRFIM
Local cHrFimABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_HRFIM' )

DbSelectArea('ABN')		//Cadastro de motivos de manutenção da agenda
ABN->( DbSetOrder(1) )	//ABN_FILIAL + ABN_MOTIVO

If ( ABN->( DbSeek( xFilial('ABN') + cMotivo ) ) )
	cTipo := ABN->ABN_TIPO
EndIf

Do Case
	Case cTipo == '02'	//Atraso
		xHoras := SubtHoras( dDtIniABB, cHrIniABB, dDtIniABR, cHrIniABR )
		
	Case cTipo == '03'	//Saída antecipada
		xHoras := SubtHoras( dDtFimABR, cHrFimABR, dDtFimABB, cHrFimABB )
		
	Case cTipo == '04'	//Hora Extra
		xHoras := SubtHoras( dDtIniABR, cHrIniABR, dDtIniABB, cHrIniABB )
		xHoras += SubtHoras( dDtFimABB, cHrFimABB, dDtFimABR, cHrFimABR )
	Case cTipo == '07'	//Ausência
		xHoras := SubtHoras(dDtIniABR, cHrIniABR, dDtFimABR, cHrFimABR )
End Case

If ( ValType( xHoras ) == 'N' )
	xHoras	:= IIf( xHoras > 0, IntToHora( xHoras ), '00:00' )
EndIf

RestArea( aAreaABN )
RestArea( aArea )

Return xHoras


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVValid
Função para validação de campos.

@sample 	xATSVValid( oModel, cCampo )

@param		oModel		Objeto com o Model para efetuar a validação.
			cCampo		Nome do campo que acionou o Valid.
@return	lRet		Indica se é válido.

@author	Danilo Dias
@since		11/01/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
User Function xATSVValid( oModelVld, cCampo, xValInserido, xValAnterior )

Local aArea 	:= GetArea()
Local lRet		:= .T.
Local cTpMovHora 	:= MANUT_TIPO_ATRASO+','+MANUT_TIPO_SAIDAANT+','+MANUT_TIPO_HORAEXTRA+','+MANUT_TIPO_AUSENT'
Local lDifHoras 	:= At540DifHr()
Local lMonitChk   := IsInCallStack( 'AT920Falta' )
Local oModel 		:= oModelVld:GetModel()
Do Case
	Case cCampo == 'ABR_MOTIVO'
	
		If xATSVTipo() $ cTpMovHora .And. lDifHoras
			lRet := .F.
			Help( " ", 1, "xATSVValid", , "Não é permitida alteração em massa para agendas com horários de entrada e saída diferentes", 1, 0 ) // "Não é permitida alteração em massa para agendas com horários de entrada e saída diferentes"
		
		ElseIf lMonitChk .And. !( xATSVTipo() == MANUT_TIPO_FALTA ) 
			lRet := .F.
			Help( " ", 1, "xATSVMONIT", , "Somente é permite atribuição de faltas", 1, 0 ) // "Somente é permite atribuição de faltas"
		Else
			xATSVInicia( oModel )
			lRet := .T.
		EndIf
	
	Case cCampo == 'ABR_ITEMOS'
		lRet := xATSVSelCt( oModel:GetValue( 'XBRMASTER', 'ABR_ITEMOS' ), oModel:GetValue( 'XBRMASTER', 'ABR_MOTIVO' ) )	//Abre TWBrowse para seleção da config. do contrato
		If ( !lRet )
			Help( " ", 1, "xATSVValid", , "Item selecionado não possui configuração de Ordem de Serviço.", 1, 0 )	//"Item selecionado não possui configuração de Ordem de Serviço."
		EndIf
		
End Case

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVWhen
Função para avaliar a condição de When do campo.

@sample 	xATSVWhen( oModel, cCampo )

@param		oModel		Objeto com o Model para efetuar a validação.
			cCampo		Nome do campo que acionou o When.
@return	lRet		Indica a condição de When.

@author	Danilo Dias
@since		11/01/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
User Function xATSVWhen( oModel, cCampo )

Local aArea		:= GetArea()
Local lRet			:= .T.
Local cTipo		:= ''
Local nOperation := oModel:GetOperation()
Local lInclui		:= (nOperation == MODEL_OPERATION_INSERT)
Local lAltera		:= (nOperation == MODEL_OPERATION_UPDATE)
If ( lAltera ) .Or. ( lInclui )
	cTipo := xATSVTipo()	//Busca tipo do motivo da manutenção
EndIf

Do Case
	Case cCampo == 'ABR_MOTIVO'
		If ( lInclui )
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	Case cCampo == 'ABR_DTINI' .Or. cCampo == 'ABR_HRINI'
		If ( cTipo $( '02|04' ) ) .Or. ( cTipo $( '07' ) .And. cCampo == 'ABR_HRINI')
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	
	Case cCampo == 'ABR_DTFIM' .Or. cCampo == 'ABR_HRFIM'
		If ( cTipo $( '03|04' ) ) .Or. ( cTipo $( '07' ) .And. cCampo == 'ABR_HRFIM')
			lRet := .T.
		Else
			lRet := .F.
		EndIf
		
	Case cCampo == 'ABR_CODSUB'
		If( ( cTipo == '04' ) .Or. ( Empty( cTipo ) )) 
			lRet := .F.
		Else
			lRet := .T.
		EndIf

	Case cCampo == 'ABR_ITEMOS'
		If ( cTipo == '06' )
			lRet := .T.
		Else
			lRet := .F.
		EndIf
		
	Case cCampo == 'ABR_TEMPO'
		If ( cTipo $( '02|03|04|07' ) )
			lRet := .T.
		Else
			lRet := .F.
		EndIf
		
	Case cCampo == 'ABR_USASER'
		If ( cTipo == '04' )
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Case cCampo == 'ABR_TIPDIA'
		If ( cTipo $ '01|02|03|05' ) .And. AliasInDic('TDV')
			If xATSVVldTDV( (cAliasTmp)->ABB_CODIGO )  // verifica se a agenda tem víncula com a alocação por escala
				lRet := .T.
			EndIf
		Else
			lRet := .F.
		EndIf
End Case

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVCommit
Função para gravar os dados do formulário no banco de dados.

@sample 	xATSVCommit( oModel )

@param		oModel		Objeto com o Model para efetuar o commit.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function xATSVCommit( oModel )

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local aAreaTMP	:= IIf( oModel:nOperation != 5, (cAliasTmp)->(GetArea()), {} )
Local lRet 		:= .T.
Local nOpc			:= 0
Local lIncluiABB	:= .T.		//Indica se é uma inclusão ou alteração para gravação da ABB
Local cAgenda		:= ''		//Código da agenda
Local cCodSub		:= ''		//Código do atendente substituo
Local cChave		:= ''		//Chave da agenda
Local cNumOS		:= ''		//Número da OS da agenda
Local cItemOS		:= ''		//Item da OS da agenda ABB_ITEMOS
Local cConfig		:= ''		//Código da configuração da agenda	ABB_IDCFAL	
Local cMotivo		:= ''		//Motivo informado para a manutenção
Local cTipo		:= ''		//Tipo do motivo selecionado para manutenção
Local cHrIni		:= ''		//Hora inicial da agenda original
Local dDtIni		:= ''		//Data inicial da agenda original
Local cHrFim		:= ''		//Hora final da agenda original
Local dDtFim		:= ''		//Data final da agenda original
Local cHrIniABR	:= ''		//Hora inicial informada para a manutenção
Local dDtIniABR	:= ''		//Data inicial informada para a manutenção
Local cHrFimABR	:= ''		//Hora final informada para a manutenção
Local dDtFimABR	:= ''		//Data final informada para a manutenção
Local cHrIniSub	:= ''		//Hora inicial para a agenda do substituto
Local dDtIniSub	:= ''		//Data inicial para a agenda do substituto
Local cHrFimSub	:= ''		//Hora final para a agenda do substituto
Local dDtFimSub	:= ''		//Data final para a agenda do substituto
Local cTempo		:= ''		//Tempo calculado de acordo com o início e fim informados para a manutenção
Local cAtivo		:= '1'		//Informa o conteúdo do campo ABB_ATIVO
Local cManut		:= '1'		//Informa o conteúdo do campo ABB_MANUT
Local aManut		:= {}		//Array com manutenções realizadas na agenda
Local nTamOSAB6	:= TAMSX3('AB6_NUMOS')[1]		//Tamanho do campo AB6_NUMOS
Local cNumManut	:= ''		//Número da manutenção
Local nI			:= 1
Local lAltDtHrIni 	:= .F.
Local lAltDtHrFim 	:= .F.
Local cMvHorario 	:= MANUT_TIPO_ATRASO+','+MANUT_TIPO_SAIDAANT+','+MANUT_TIPO_HORAEXTRA
Local cLocal := ""//Local de Atendimento (Posto)
Local cTipDia 	:= ''
Local aAtend		:= {}
Local lCustoTWZ	:= ExistBlock("TecXNcusto")
Local cFilAbb	:= ''
Local bFilAbb 	:= Nil
Local lUpCusto 		:= .F.
Local cCodTWZ 		:= ""
Local cDescErro 	:= ""
Local cHrTot		:= ""
Local cCodTec		:= ""
Local lAltAus		:= .F.
Local cHrFim		:= ""
Local dDtIni	
Local dDtFim
Local cHrTotAnt	:= ""
//Local cTipoAloc	:= ""
	
If ( ValType( oModel ) <> 'O' )
	Return .F.
EndIf

If !IsInCallStack('AT570Subst')
	cTipoAloc	:= ""
EndIf
	
DbSelectArea('ABB')	//Agenda de Alocação
ABB->(DbSetOrder(8))	//ABB_FILIAL + ABB_CODIGO
					
DbSelectArea('ABN')	//Motivos de Manutenção da Agenda
ABN->(DbSetOrder(1))	//ABN_FILIAL + ABN_CODIGO

DbSelectArea('ABQ')	//Configurações do contrato
ABQ->(DbSetOrder(1))	//ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM

cCodSub	:= oModel:GetValue( 'XBRMASTER', 'ABR_CODSUB' )
cMotivo	:= oModel:GetValue( 'XBRMASTER', 'ABR_MOTIVO' )
cTempo		:= oModel:GetValue( 'XBRMASTER', 'ABR_TEMPO' )
cItemOS	:= oModel:GetValue( 'XBRMASTER', 'ABR_ITEMOS' )
nOpc		:= oModel:GetOperation()

If ( ABN->( DbSeek( xFilial('ABN') + cMotivo ) ) )
	cTipo := ABN->ABN_TIPO
EndIf

Begin Transaction

	Do Case
	
		//----------------------------------------------------------------------------
		// Exclusão
		//----------------------------------------------------------------------------
		Case ( nOpc == MODEL_OPERATION_DELETE )
	
			cAgenda	:= oModel:GetValue( 'XBRMASTER', 'ABR_AGENDA' )	
			aManut		:= xATSVQryMan( cAgenda )
			
			// Verifica se existe mais de uma manutenção para a agenda
			// atualizando o status da agenda após a exclusão
			If ( Len( aManut ) > 1 )
				cManut := '1'		//Sim
				cAtivo := '1'		//Sim
				For nI := 1 To Len(aManut)				
					If ( aManut[nI][1] != oModel:GetValue( 'XBRMASTER', 'ABR_MOTIVO' ) )
						If ( aManut[nI][2] $('01|05|06') )	//Motivos que desativam a agenda
							cAtivo := '2'	//Não
							Exit
						EndIf
					EndIf
				Next nI
			Else
				cManut := '2'	//Não
				cAtivo	:= '1'	//Sim
			EndIf
			
			cHrFim := ABR->ABR_HRFIMA
			dDtIni := ABR->ABR_DTINIA
			dDtFim := ABR->ABR_DTFIMA
			
			//Atualiza status da agenda
			DbSelectArea('ABB')		//Agenda de Atendentes
			ABB->(DbSetOrder(8))		//ABB_FILIAL + ABB_CODIGO
			
			AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC

			If ( ABB->( DbSeek( xFilial('ABB') + cAgenda ) ) )
				// posiciona no atendente
				AA1->( DbSeek(xFilial("AA1")+ ABB->ABB_CODTEC))
				cCodTec := ABB->ABB_CODTEC
				

				lUpCusto := ( cAtivo == '1' ) // Agenda ativa?
				cConfig := ABB->ABB_IDCFAL
				cCodTWZ := ABB->ABB_CODTWZ

				If lUpCusto
					//Busca o custo do atendente pelo PE ou pelo campo do atendente
					If lCustoTWZ
						// posicina ABQ
						DbSelectArea("ABQ")
						ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
						ABQ->( DbSeek( cConfig ) )
						
						// posicina TFF
						DbSelectArea("TFF")
						TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
						TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
						nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
											{ 2, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
												TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
					Else
						nCusto := AA1->AA1_CUSTO
					EndIf
				EndIf

				RecLock('ABB',.F.)
					Replace ABB_MANUT With cManut
					Replace ABB_ATIVO With cAtivo
					Replace ABB_DTINI With ABR->ABR_DTINIA
					Replace ABB_DTFIM With ABR->ABR_DTFIMA
										
					If cTipo == MANUT_TIPO_AUSENT .AND. ABR->ABR_HRFIM != ABB->ABB_HRFIM .AND. ABR->ABR_HRINI != ABB->ABB_HRINI
						lAltAus := .T.
						Replace ABB_HRFIM With ABR->ABR_HRFIM
					Else
						Replace ABB_HRINI With ABR->ABR_HRINIA
						Replace ABB_HRFIM With ABR->ABR_HRFIMA
					EndIf 
					
					If lUpCusto
						Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
					Else
						Replace ABB->ABB_CUSTO With 0
						Replace ABB->ABB_CODTWZ With ""
					EndIf
				ABB->(MsUnlock())
				
				If lAltAus
					AUpdABBAus(cConfig,cCodTec,ABR->ABR_DTINIA,ABR->ABR_DTFIMA,ABR->ABR_HRFIMA)				
				EndIf
				
			

				//Exclui a agenda de substituição
				If ( !Empty( cCodSub ) )
	
					//Pega dados da agenda original
					cHrIni 	:= ABB->ABB_HRINI
					dDtIni 	:= ABB->ABB_DTINI
					cHrFim 	:= ABB->ABB_HRFIM
					dDtFim 	:= ABB->ABB_DTFIM
				
					//Atraso
					If ( cTipo == MANUT_TIPO_ATRASO )
						//Pega data e hora da substituição
						cHrIni 	:= ABB->ABB_HRINI
						dDtIni 	:= ABB->ABB_DTINI
						cHrFim 	:= ABR->ABR_HRINI
						dDtFim 	:= ABR->ABR_DTINI
					//Saída antecipada
					ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )
						//Pega data e hora da substituição
						cHrIni 	:= ABR->ABR_HRFIM
						dDtIni 	:= ABR->ABR_DTFIM
						cHrFim 	:= ABB->ABB_HRFIM
						dDtFim 	:= ABB->ABB_DTFIM
					ElseIf ( cTipo == MANUT_TIPO_AUSENT )
						//Pega data e hora da ausência
						cHrIni 	:= ABR->ABR_HRINI
						dDtIni 	:= ABR->ABR_DTFIM
						cHrFim 	:= ABR->ABR_HRFIM
						dDtFim 	:= ABR->ABR_DTFIM
					EndIf
					
					cFilAbb	:= ABB->(DbFilter())
					bFilAbb	:= &("{||" + cFilAbb + "}")

					ABB->( DBClearFilter())
					ABB->( DbSetOrder(1) )	//ABB_FILIAL + ABB_CODTEC + DTOS(ABB_DTINI) + ABB_HRINI + DTOS(ABB_DTFIM) + ABB_HRFIM

					//Apaga agenda do substituto e alocação por escala quando existir
					If ( ABB->( DbSeek( xFilial('ABB') + ABR->ABR_CODSUB + DToS( dDtIni ) + cHrIni + DToS( dDtFim ) + cHrFim ) ) )
						// remove vínculo com a tabela de agenda por escala
						If xATSVVldTDV( ABB->ABB_CODIGO )
							xATSVUpdTdv(.T.,ABB->ABB_CODIGO)
						EndIf

						Reclock('ABB',.F.)
							If Empty( cCodTWZ )
								cCodTWZ := ABB->ABB_CODTWZ
							EndIf
							ABB->( DbDelete() )
						ABB->(MsUnlock())
					EndIf

					If !Empty(cFilAbb)
						ABB->( DBSetFilter( bFilAbb, cFilAbb ) )
					EndIf
				EndIf

				// Atualiza as informações do aglutinador de custo do item, recalculando conforme o IDCFAL informado
				At330HasTWZ( cConfig, @cCodTWZ  )
				lRet := At330GrvCus( cConfig, cCodTWZ )
				If !lRet .And. Empty( cDescErro )
					cDescErro := "Não foi possível associar o custo da alocação." // "Não foi possível associar o custo da alocação."
				EndIf
			EndIf
			
			lRet := lRet .And. FwFormCommit( oModel )
			If !lRet .And. Empty( cDescErro )
				cDescErro := "Problemas na gravação nativa do MVC." // "Problemas na gravação nativa do MVC."
			EndIf
		
		//----------------------------------------------------------------------------
		// Inclusão
		//----------------------------------------------------------------------------
		Case ( nOpc == MODEL_OPERATION_INSERT )
		
			cNumManut := GetSXENum( 'ABR', 'ABR_MANUT' )
			
			(cAliasTmp)->(DbGoTop())
			
			While lRet .And. (cAliasTmp)->(!Eof())
			
				//Grava apenas para as agendas selecionadas
				If ( (cAliasTmp)->ABB_OK == 1 )
				
					cAgenda 	:= (cAliasTmp)->ABB_CODIGO
					cHrIni  	:= (cAliasTmp)->ABB_HRINI
					dDtIni  	:= SToD( (cAliasTmp)->ABB_DTINI )
					cHrFim  	:= (cAliasTmp)->ABB_HRFIM
					dDtFim  	:= SToD( (cAliasTmp)->ABB_DTFIM )
					cHrIniABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_HRINI' )
					dDtIniABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_DTINI' )
					cHrFimABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_HRFIM' )
					dDtFimABR 	:= oModel:GetValue( 'XBRMASTER', 'ABR_DTFIM' )
					cLocal		:= (cAliasTmp)->ABB_LOCAL
					cTipDia     := oModel:GetValue( 'XBRMASTER', 'ABR_TIPDIA' )
										
					If ( cTipo == '02' )	
						//Atualiza data e hora inicial em caso de atraso, conforme o tempo de atraso.
						SomaDiaHor( @dDtIni, @cHrIni, HoraToInt( cTempo, 2 ) )
						//Calcula o total de horas a partir da manutenção
						cHrTotAnt := ATTotHora(dDtIni, cHrIniABR, dDtFim, cHrFimABR )	//Calcula o tempo total da agenda
						
					ElseIf ( cTipo $ '03' )
						//Atualiza data e hora final em caso de saída antecipada, conforme o tempo de saída.
						SubtDiaHor( @dDtFim, @cHrFim, HoraToInt( cTempo, 2 ) )
						//Calcula o total de horas a partir da manutenção
						cHrTotAnt := ATTotHora(dDtIni, cHrIniABR, dDtFim, cHrFimABR )	//Calcula o tempo total da agenda
						
					ElseIf ( cTipo == '04' )
						//Atualiza a data e hora de início e fim do atendimento, conforme o tempo de hora extra.
						SubtDiaHor( @dDtIni, @cHrIni, nTempoIni )
						SomaDiaHor( @dDtFim, @cHrFim, nTempoFim )
						//Calcula o total de horas a partir da manutenção
						cHrTotAnt := ATTotHora(dDtIni, cHrIniABR, dDtFim, cHrFimABR )	//Calcula o tempo total da agenda
						
					ElseIf ( cTipo == '07' )
						//Para ausência a hora inicio e fim será do periodo ausente						
						cHrIni := cHrIniABR
						cHrFim := cHrFimABR
					EndIf

					//Grava dados da manutenção
					RecLock( 'ABR', .T. )
							ABR->ABR_FILIAL	:= xFilial('ABR')
							ABR->ABR_AGENDA	:= cAgenda
							ABR->ABR_DTMAN	:= Date()
							ABR->ABR_MOTIVO	:= cMotivo
							ABR->ABR_DTINI	:= dDtIni
							ABR->ABR_HRINI	:= IntToHora(HoraToInt(cHrIni)+0.01)
							ABR->ABR_DTFIM	:= dDtFim
							ABR->ABR_HRFIM	:= cHrFim
							ABR->ABR_TEMPO	:= cTempo
							ABR->ABR_CODSUB	:= cCodSub
							ABR->ABR_ITEMOS	:= cItemOS
							ABR->ABR_USASER	:= oModel:GetValue( 'XBRMASTER', 'ABR_USASER' )
							ABR->ABR_OBSERV	:= oModel:GetValue( 'XBRMASTER', 'ABR_OBSERV' )
							ABR->ABR_MANUT	:= cNumManut
							ABR->ABR_USER 	:= __cUserId
							ABR->ABR_DTINIA := STOD( (cAliasTmp)->ABB_DTINI )
							ABR->ABR_HRINIA := (cAliasTmp)->ABB_HRINI
							ABR->ABR_DTFIMA := STOD( (cAliasTmp)->ABB_DTFIM )
							ABR->ABR_HRFIMA := (cAliasTmp)->ABB_HRFIM
							ABR->ABR_TIPDIA	:= cTipDia
					ABR->(MsUnlock())
					
					If ExistBlock("xATSVGrv")
						ExecBlock("xATSVGrv",.F.,.F.,{oModel,nOpc} )
					EndIf 

					AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC
					AA1->( MsSeek(xFilial("AA1")+ ABB->ABB_CODTEC))
					// Caso seja Falta, Cancelamento ou Transferência, desativa a agenda
					cAtivo := If( cTipo $ "01/05/06", "2", "1" )
					lUpCusto := ( cAtivo == '1' ) // Agenda ativa?
					cConfig := ABB->ABB_IDCFAL
					cCodTWZ := ABB->ABB_CODTWZ
					
					If lUpCusto
						//Busca o custo do atendente pelo PE ou pelo campo do atendente
						If lCustoTWZ
							// posicina ABQ
							DbSelectArea("ABQ")
							ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
							ABQ->( DbSeek( cConfig ) )
							
							// posicina TFF
							DbSelectArea("TFF")
							TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
							TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
							nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
												{ 2, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
													TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
						Else
							nCusto := AA1->AA1_CUSTO
						EndIf
					EndIf

					If ( ABB->( DbSeek( xFilial('ABB') + cAgenda ) ) )
					
						cChave 	:= ABB->ABB_CHAVE
						cNumOS 	:= ABB->ABB_NUMOS
						cConfig	:= ABB->ABB_IDCFAL
						
						If cTipo == '07'
						
							//Quando a hora Inicio e final continuam iguais
							If (cHrIni == ABB->ABB_HRINI)  .AND.  (ABR->ABR_HRFIM == ABB->ABB_HRFIM)
																
								// Atualiza agenda com a hora fim igual a hora fim da ABR
								RecLock( 'ABB', .F. )									
									ABB->ABB_HRINI	:= cHrIni
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'	
								ABB->(MsUnlock())
								
							//Quando a hora inicial continua igual							
							ElseIf cHrIni == ABB->ABB_HRINI								
								
								//Calcula o total de horas a partir da manutenção															
								cHrTotAnt := ATTotHora(dDtIni, cHrFim, dDtFim, ABB->ABB_HRFIM)
								
								// Atualiza agenda com a hora fim igual a hora fim da ABR
								RecLock( 'ABB', .F. )									
									ABB->ABB_HRINI	:= cHrFim
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_HRTOT	:= cHrTotAnt	
								ABB->(MsUnlock())
															
							//Quando a hora final continua igual
							ElseIf ABR->ABR_HRFIM == ABB->ABB_HRFIM
																
								//Calcula o total de horas a partir da manutenção	
								cHrTotAnt := ATTotHora(dDtIni, ABB->ABB_HRINI, dDtFim, cHrIni )
								
								// Atualiza agenda com a hora fim igual a hora inicio da ABR
								RecLock( 'ABB', .F. )									
									ABB->ABB_HRFIM	:= cHrIni
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_HRTOT	:= cHrTotAnt	
								ABB->(MsUnlock())							
							
							//Quando a hora está no meio do periodo 
							Else
							
								//Calcula o total de horas a partir da manutenção															
								cHrTotAnt := ATTotHora(dDtIni, ABB->ABB_HRINI, dDtFim, cHrIni )							
							
								// Atualiza agenda com a hora fim igual a hora inicio da ABR
								RecLock( 'ABB', .F. )									
									ABB->ABB_HRFIM	:= cHrIni
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'					
									ABB->ABB_HRTOT	:= cHrTotAnt									
								ABB->(MsUnlock())
								
								If ( ValType( cHrTot ) == 'N' )
									cHrTot	:= IIf( cHrTot > 0, IntToHora( cHrTot ), '00:00' )
								EndIf								
								
								cHrTot := ATTotHora(dDtIni, ABR->ABR_HRFIM, dDtFim, (cAliasTmp)->ABB_HRFIM )	//Tempo total da agenda
								//Cria uma nova ABB com os dados do segundo periodo 
								RecLock( 'ABB', .T. )
									ABB->ABB_FILIAL	:= xFilial( 'ABB' )
									ABB->ABB_CODIGO	:= GetSXENum( 'ABB', 'ABB_CODIGO' )
									ABB->ABB_CODTEC	:= (cAliasTmp)->ABB_CODTEC
									
									If !Empty(cNumOS)
										ABB->ABB_ENTIDA	:= 'AB7'
										ABB->ABB_NUMOS	:= cNumOS
									EndIf
									
									ABB->ABB_CHAVE	:= cChave
									ABB->ABB_DTINI	:= dDtIni
									ABB->ABB_HRINI	:= IntToHora(HoraToInt(ABR->ABR_HRFIM)+0.01)
									ABB->ABB_DTFIM	:= dDtFim
									ABB->ABB_HRFIM	:= (cAliasTmp)->ABB_HRFIM
									ABB->ABB_HRTOT	:= cHrTot								
									ABB->ABB_SACRA 	:= 'S'
									ABB->ABB_CHEGOU	:= 'N'
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_IDCFAL	:= (cAliasTmp)->ABB_IDCFAL
									ABB->ABB_LOCAL	:= cLocal
									ABB->ABB_TIPOMV := '001'
									
									//Grava o custo da alocação
									Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
								ABB->(MsUnlock())
								
								//Atualizar a TDV com o novo registro
								If xATSVVldTDV(cAgenda)
									xATSVUpdTdv(.F.,cAgenda, ABB->ABB_CODIGO, cTipDia )
								EndIf
								
							EndIf
						Else
							//---------------------------------------------------
							// Atualiza status da agenda
							//---------------------------------------------------
							RecLock( 'ABB', .F. )
								Replace ABB->ABB_MANUT With '1'
								Replace ABB->ABB_ATIVO With cAtivo
							
								ABB->ABB_DTINI	:= dDtIni
								ABB->ABB_HRINI	:= cHrIni
								ABB->ABB_DTFIM	:= dDtFim
								ABB->ABB_HRFIM	:= cHrFim
							
								If !(cTipo $ "01/05/06") //Falta, Cancelamento ou Transferência
									ABB->ABB_HRTOT	:= cHrTotAnt
								EndIf

								If lUpCusto
									Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
								Else
									Replace ABB->ABB_CUSTO With 0
									Replace ABB->ABB_CODTWZ With ""
								EndIf
							ABB->(MsUnlock())
						
							//---------------------------------------------------
							// Grava agenda nova, em caso de transferência
							//---------------------------------------------------
							If ( !Empty( cItemOS ) )	
								//Grava agenda nova						
								xATSVGrvABB( (cAliasTmp)->ABB_CODTEC, cItemOS, SubStr( cItemOS, 1, nTamOSAB6 ),;
											 cConfCtr, dDtIni,	cHrIni, dDtFim, cHrFim, /*lInclui*/,;
											 cLocal, cTipoAloc, cAgenda, cTipDia, lCustoTWZ )
							EndIf
						EndIf
												
						//---------------------------------------------------
						// Grava agenda do substituto
						//---------------------------------------------------
						If ( !Empty( cCodSub ) )
						
							// Define o tipo da movimentação da alocação
							If Empty(cTipoAloc)
								cTipoAloc := At330TipAlo(.F.)
							EndIf
							
							//Monta horários para a genda do substituto
							If ( cTipo $( '01|05|06|07' ) )	//Substituição por falta, cancelamento ou transferência
								dDtIniSub 	:= dDtIni
								cHrIniSub	:= cHrIni
								dDtFimSub	:= dDtFim
								cHrFimSub	:= cHrFim
							ElseIf ( cTipo == '02' ) 		//Substituição do atraso
								dDtIniSub 	:= STOD((cAliasTmp)->ABB_DTINI)
								cHrIniSub	:= (cAliasTmp)->ABB_HRINI
								dDtFimSub	:= dDtIni
								cHrFimSub	:= cHrIni
							ElseIf ( cTipo == '03' )			//Substituição da saída antecipada
								dDtIniSub 	:= dDtFim
								cHrIniSub	:= cHrFim
								dDtFimSub	:= STOD((cAliasTmp)->ABB_DTFIM)
								cHrFimSub	:= (cAliasTmp)->ABB_HRFIM
							EndIf
							
							// Caso substituicao armazena os dados para o memorando
							IF aScan(aAtend,{|x| x[1] == cCodSub}) = 0
								Aadd(aAtend,{cCodSub,cConfig,dDtIniSub,cHrIniSub,dDtFimSub,cHrFimSub,cLocal,cTipoAloc,cAgenda})
							ELSE
								// Grava a ultima data/hora do atendente
								aAtend[aScan(aAtend,{|x| x[1] == cCodSub})][5] := dDtFimSub
								aAtend[aScan(aAtend,{|x| x[1] == cCodSub})][6] := cHrFimSub
							ENDIF

							xATSVGrvABB( cCodSub, cChave, cNumOS, cConfig, dDtIniSub,;
							             cHrIniSub, dDtFimSub, cHrFimSub,/*lInclui*/ ,;
							             cLocal, cTipoAloc, cAgenda, cTipDia, lCustoTWZ )
						EndIf
						
						// Atualiza as informações do aglutinador de custo do item, recalculando conforme o IDCFAL informado
						lRet := At330GrvCus( cConfig, cCodTWZ )
						If !lRet .And. Empty( cDescErro )
							cDescErro := "Não foi possível associar o custo da alocação."
						EndIf
					Else
						lRet := .F.
						cDescErro := "Agenda para manutenção não encontrada."
						Exit
					EndIf
				EndIf
			
				(cAliasTmp)->(DbSkip())				
			EndDo    
		
		//----------------------------------------------------------------------------			
		// Alteração
		//----------------------------------------------------------------------------
		Case ( nOpc == MODEL_OPERATION_UPDATE )
		
			cAgenda := oModel:GetValue( 'XBRMASTER', 'ABR_AGENDA' )
			cHrIni  := oModel:GetValue( 'XBRMASTER', 'ABR_HRINI' )
			dDtIni  := oModel:GetValue( 'XBRMASTER', 'ABR_DTINI' )
			cHrFim  := oModel:GetValue( 'XBRMASTER', 'ABR_HRFIM' )
			dDtFim  := oModel:GetValue( 'XBRMASTER', 'ABR_DTFIM' )
			cTipDia := oModel:GetValue( 'XBRMASTER', 'ABR_TIPDIA' )
			
			lAltDtHrIni := ( cHrIni <> ABR->ABR_HRINI .Or. dDtIni <> ABR->ABR_DTINI )
			lAltDtHrFim := ( cHrFim <> ABR->ABR_HRFIM .Or. dDtFim <> ABR->ABR_DTFIM )

			//Busca agenda original
			ABB->(DbSetOrder(8))	//ABB_FILIAL + ABB_CODIGO
	
			If ( ABB->( DbSeek( xFilial('ABB') + cAgenda ) ) )
				
				AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC
				AA1->( MsSeek(xFilial("AA1")+ ABB->ABB_CODTEC))
				// Não tem como ser Falta, Cancelamento ou Transferência, pois só atualiza quando há alteração de data e horário
				cAtivo := ABB->ABB_ATIVO
				lUpCusto := ( cAtivo == '1' ) // Agenda ativa?
				cConfig := ABB->ABB_IDCFAL
				cCodTWZ := ABB->ABB_CODTWZ
					
				If cTipo $ cMvHorario
					
					If ( cTipo == MANUT_TIPO_ATRASO .And. lAltDtHrIni )	
						//Atualiza data e hora inicial em caso de atraso, conforme o tempo de atraso.
						SomaDiaHor( @dDtIni, @cHrIni, HoraToInt( cTempo, 2 ) )
					
					ElseIf ( cTipo == MANUT_TIPO_SAIDAANT .And. lAltDtHrFim )
						//Atualiza data e hora final em caso de saída antecipada, conforme o tempo de saída.
						SubtDiaHor( @dDtFim, @cHrFim, HoraToInt( cTempo, 2 ) )
					
					ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA .And. ( lAltDtHrIni .Or. lAltDtHrFim ) )
						//Atualiza a data e hora de início e fim do atendimento, conforme o tempo de hora extra.
						SubtDiaHor( @dDtIni, @cHrIni, nTempoIni )
						SomaDiaHor( @dDtFim, @cHrFim, nTempoFim )
					EndIf
					
					If lUpCusto
						//Busca o custo do atendente pelo PE ou pelo campo do atendente
						If lCustoTWZ
							// posicina ABQ
							DbSelectArea("ABQ")
							ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
							ABQ->( DbSeek( cConfig ) )
							
							// posicina TFF
							DbSelectArea("TFF")
							TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
							TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
							nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
												{ 2, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
													TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
						Else
							nCusto := AA1->AA1_CUSTO
						EndIf
					EndIf

					Reclock( 'ABB', .F. )
						ABB->ABB_DTINI	:= dDtIni
						ABB->ABB_HRINI	:= cHrIni
						ABB->ABB_DTFIM	:= dDtFim
						ABB->ABB_HRFIM	:= cHrFim
						If lUpCusto
							ABB->ABB_CUSTO := (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
						Else
							ABB->ABB_CUSTO := 0
							ABB->ABB_CODTWZ := ""
						EndIf
					ABB->( MsUnlock() )
				EndIf
				
				//Pega dados da agenda original
				cHrIni 	:= ABB->ABB_HRINI
				dDtIni 	:= ABB->ABB_DTINI
				cHrFim 	:= ABB->ABB_HRFIM
				dDtFim 	:= ABB->ABB_DTFIM
				cChave 	:= ABB->ABB_CHAVE
				cNumOS 	:= ABB->ABB_NUMOS
				cConfig := ABB->ABB_IDCFAL
				cLocal	:= ABB->ABB_LOCAL
				
				//Atraso
				If ( cTipo == MANUT_TIPO_ATRASO )
					//Pega data e hora da substituição antiga
					cHrIni 	:= ABR->ABR_HRINIA  // pega o valor antes da manutenção de atraso
					dDtIni 	:= ABR->ABR_DTINIA  // pega o valor antes da manutenção de atraso
					cHrFim 	:= ABR->ABR_HRINI
					dDtFim 	:= ABR->ABR_DTINI
				EndIf
				
				//Saída antecipada
				If ( cTipo == MANUT_TIPO_SAIDAANT )
					//Pega data e hora da substituição antiga
					cHrIni 	:= ABR->ABR_HRFIM
					dDtIni 	:= ABR->ABR_DTFIM
					cHrFim 	:= ABR->ABR_HRFIMA  // pega o valor antes da manutenção de saída antecipada
					dDtFim 	:= ABR->ABR_DTFIMA  // pega o valor antes da manutenção de saída antecipada
				EndIf
				
				ABB->( DbSetOrder(1) )	//ABB_FILIAL + ABB_CODTEC + DTOS(ABB_DTINI) + ABB_HRINI + DTOS(ABB_DTFIM) + ABB_HRFIM
						
				If ( ABB->( DbSeek( xFilial('ABB') + ABR->ABR_CODSUB + DToS( dDtIni ) + cHrIni + DToS( dDtFim ) + cHrFim ) ) )
					//Alteração do substituto
					If ( ABR->ABR_CODSUB != cCodSub )
						// remove vínculo com a tabela de agenda por escala
						If xATSVVldTDV(ABB->ABB_CODIGO)
							xATSVUpdTdv(.T., ABB->ABB_CODIGO)
						EndIf
						
						//Apaga agenda do substituto anterior
						Reclock( 'ABB', .F. )
							ABB->( DbDelete() )
						ABB->(MsUnlock())
					Else
						lIncluiABB := .F.
					EndIf
				EndIf
				
				If ( !Empty( cCodSub ) )
				
					//Atraso
					If ( cTipo == MANUT_TIPO_ATRASO )
						//Pega data e hora para a nova substituição
						cHrIni 	:= ABB->ABB_HRINI
						dDtIni 	:= ABB->ABB_DTINI
						cHrFim 	:= oModel:GetValue( 'XBRMASTER', 'ABR_HRINI' )
						dDtFim 	:= oModel:GetValue( 'XBRMASTER', 'ABR_DTINI' )
					EndIf
					
					//Atraso
					If ( cTipo == MANUT_TIPO_SAIDAANT )
						//Pega data e hora para a nova substituição
						cHrIni 	:= oModel:GetValue( 'XBRMASTER', 'ABR_HRFIM' )
						dDtIni 	:= oModel:GetValue( 'XBRMASTER', 'ABR_DTFIM' )
						cHrFim 	:= ABB->ABB_HRFIM
						dDtFim 	:= ABB->ABB_DTFIM
					EndIf
					
					// Define o tipo da movimentação da alocação
					If Empty(cTipoAloc)
						cTipoAloc := At330TipAlo(.F.)
					EndIf
					
					//Grava agenda do substituto atual
					xATSVGrvABB( cCodSub, cChave, cNumOS, cConfig, dDtIni,;
							      cHrIni, dDtFim, cHrFim, lIncluiABB, cLocal, ;
							       cTipoAloc, cAgenda, cTipDia, lCustoTWZ )
				EndIf
				
				// Atualiza as informações do aglutinador de custo do item, recalculando conforme o IDCFAL informado
				lRet := At330GrvCus( cConfig, cCodTWZ )
				If !lRet .And. Empty( cDescErro )
					cDescErro := "Não foi possível associar o custo da alocação."
				EndIf
				lRet := lRet .And. FwFormCommit( oModel )
				If !lRet .And. Empty( cDescErro )
					cDescErro := "Problemas na gravação nativa do MVC."
				EndIf
			Else
				lRet := .F.
				cDescErro := "Agenda para manutenção não encontrada."
			EndIf
			
	End Case

If ( !lRet )

	If Empty(cDescErro)
		cDescErro := "Manutenção da agenda não pode acontecer."
	EndIf

	oModel:GetModel():SetErrorMessage( oModel:GetId() ,"TFL_DTFIM" ,"XBRMASTER", "ABR_CODSUB" ,'',; 
			cDescErro, "Corrija as informações e tente novamente")
	
	RollbackSX8()
	DisarmTransaction()
	Break
Else
	ConfirmSX8()

	// Apos gravacao chama rotina de geracao do memorando caso houver substituicao do atendente
	If Len( aAtend ) > 0
		xATSVFilCt(aAtend)
	EndIf
EndIf

End Transaction

IIf( oModel:nOperation != 5, RestArea( aAreaTMP ), Nil )
RestArea( aAreaABB)
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVVldModel
Valida os dados do model.

@sample 	xATSVVldModel( oModel )

@param		oModel		Objeto com o Model para efetuar a validação.
@return	lRet		Indica se os dados são válidos.

@author	Danilo Dias
@since		21/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function xATSVVldModel( oModel )

Local aArea		:= GetArea()
Local aAreaABR	:= ABR->(GetArea())
Local lRet			:= .T.
Local cAgenda		:= oModel:GetValue( 'XBRMASTER', 'ABR_AGENDA' )
Local cMotivo		:= oModel:GetValue( 'XBRMASTER', 'ABR_MOTIVO' )
Local dDtIni		:= oModel:GetValue( 'XBRMASTER', 'ABR_DTINI' )
Local cHrIni		:= oModel:GetValue( 'XBRMASTER', 'ABR_HRINI' )
Local dDtFim		:= oModel:GetValue( 'XBRMASTER', 'ABR_DTFIM' )
Local cHrFim		:= oModel:GetValue( 'XBRMASTER', 'ABR_HRFIM' )
Local cItemOS		:= oModel:GetValue( 'XBRMASTER', 'ABR_ITEMOS' )
Local cTempo		:= oModel:GetValue( 'XBRMASTER', 'ABR_TEMPO' )
Local cTipo  		:= xATSVTipo()
Local nOpc			:= 0
Local aManut		:= {}
Local lAtraso		:= .F.
Local lSaidaAnt 	:= .F.
Local lHrExtraIni	:= .F.
Local lHrExtraFim	:= .F.
Local nExtra		:= 0
Local lPodeRepl 	:= cTipo $ MANUT_TIPO_FALTA + "," + MANUT_TIPO_CANCEL + "," + MANUT_TIPO_TRANSF
Local aRecnosMk 	:= At540GetMk()
Local nX 			:= 0
Local aSaveTmp 		:= {}
Local nValorMark 	:= 0

nOpc := oModel:GetOperation()

DbSelectArea('ABR')	//Manutenções da Agenda
ABR->(DbSetOrder(1))	//ABR_FILIAL + ABR_AGENDA + ABR_MOTIVO

nTempoIni	:= SubtHoras( dDtIni, cHrIni, SToD( (cAliasTmp)->ABB_DTINI ), (cAliasTmp)->ABB_HRINI )
nTempoFim	:= SubtHoras( SToD( (cAliasTmp)->ABB_DTFIM ), (cAliasTmp)->ABB_HRFIM, dDtFim, cHrFim )

//-------------------------------------------------
//  Passa no array os registros selecionados
// validando se houve a seleção de fato
// e se pode realizar a replicação da manutenção
If nOpc == MODEL_OPERATION_INSERT .And. lPodeRepl .And. Len( aRecnosMk ) > 0
	
	For nX := 1 To Len( aRecnosMk )
		//-------------------------------------------------------
		//  Identifica se há necessidade de indicação para a replicação
		If ( aScan( aRecnosMk, { |pos| !aRecnosMk[nX,2] ; // item não marcado no browse anterior
									.And. aRecnosMk[nX,1] <> pos[1] ; // Recnos diferentes (ou seja item diferente)
									.And. aRecnosMk[nX,4] == pos[4] ; // mesma data de referência
									.And. aRecnosMk[nX,5] ;  // agenda ativa
									.And. pos[2]  } ) > 0 ) // item da mesma data de referência está marcado 

			aRecnosMk[nX,3] := .T.
		EndIf
	
	Next nX
	
	lPodeRepl := aScan( aRecnosMk, {|x| x[3] } ) > 0
	
	lPodeRepl := ( lPodeRepl .And. ;
		AVISO( "Atenção", "As manutenções podem ser replicadas para outros período no mesmo dia." + CHR(13)+CHR(10) + ; // "Atenção" ### "As manutenções podem ser replicadas para outros período no mesmo dia."
						  "" , {"Sim", "Não"} ) == 1 )// "Deseja replicar?" ### "Sim" ### "Não" 
		
	aSaveTmp := (cAliasTmp)->( GetArea() )
	
	nValorMark := If ( lPodeRepl, 1, 0)
	
	//-------------------------------------------------------------------
	// Atualiza a tabela temporária com a indicação de marcação ou não
	For nX := 1 To Len( aRecnosMk )
	
		If aRecnosMk[nX, 3]
			
			(cAliasTmp)->( DbGoTo( aRecnosMk[nX, 1] ) )
			Reclock( (cAliasTmp), .F. )
				REPLACE	ABB_OK 	WITH 	nValorMark
			(cAliasTmp)->( MsUnlock() )
			
		EndIf
	Next
	
	RestArea( aSaveTmp )
	RestArea( aArea )
	
Else
	lPodeRepl := .F.
EndIf

//----------------------------------------------------------------------
// Valida preenchimento dos campos
//----------------------------------------------------------------------
If ( lRet ) .And. ( ( nOpc == MODEL_OPERATION_INSERT ) .Or. ( nOpc == MODEL_OPERATION_UPDATE ) )
	Do Case
		//Falta
		Case cTipo == MANUT_TIPO_FALTA
			lRet := .T.
		//Atraso
		Case cTipo == MANUT_TIPO_ATRASO
			If ( ( Empty( cHrIni ) ) .Or. ( Empty( dDtIni ) ) ) .And. ( Empty( cTempo ) ) 
				Help( " ", 1, "xATSVVldModel", , 'Informe a data e hora de início do atendimento ou o tempo de atraso.', 1, 0 )	//'Informe a data e hora de início do atendimento ou o tempo de atraso.'
				lRet := .F.
			EndIf
		//Saída Antecipada
		Case cTipo == MANUT_TIPO_SAIDAANT
			If ( ( Empty( cHrFim ) ) .Or. ( Empty( dDtFim ) ) ) .And. ( Empty( cTempo ) )
				Help( " ", 1, "xATSVVldModel", , 'Informe a data e hora de fim do atendimento ou o tempo da saída antecipada.', 1, 0 )	//'Informe a data e hora de fim do atendimento ou o tempo da saída antecipada.'
				lRet := .F.
			EndIf
		//Hora Extra
		Case cTipo == MANUT_TIPO_HORAEXTRA
			If ( Empty( cHrIni ) .And. Empty( dDtIni ) ) .And. ( Empty( cHrFim ) .And. Empty( dDtFim ) )
				Help( " ", 1, "xATSVVldModel", , 'Informe a data e hora de início ou a data e hora de fim do atendimento para registrar a hora extra.', 1, 0 )	//'Informe a data e hora de início ou a data e hora de fim do atendimento para registrar a hora extra.'
				lRet := .F.
			EndIf
		//Cancelamento
		Case cTipo == MANUT_TIPO_CANCEL
			lRet := .T.
		//Transferência
		Case cTipo == MANUT_TIPO_TRANSF
			If ( Empty( cItemOS ) )
				Help( " ", 1, "xATSVVldModel", , 'Informe o item da OS para onde o atendente será transferido.', 1, 0 )	//'Informe o item da OS para onde o atendente será transferido.'
				lRet := .F.
			EndIf
			
			If ( Empty( cConfCtr ) )
				Help( " ", 1, "xATSVVldModel", , "Nenhuma configuração de contrato foi selecionada. Acione a consulta do Item da OS, selecione um item e confirme para mostrar as configurações do contrato e selecionar uma para a transferência.", 1, 0 )	//"Nenhuma configuração de contrato foi selecionada. Acione a consulta do Item da OS, selecione um item e confirme para mostrar as configurações do contrato e selecionar uma para a transferência."
				lRet := .F.
			EndIf
		OtherWise			
			lRet := .T.
	EndCase
Else
	If lRet
		// nOpc == MODEL_OPERATION_DELETE
		If ABR->( DbSeek( xFilial('ABR')+cAgenda+cMotivo ) )
			If !( lRet := IsLastManut( cAgenda, ABR->ABR_MANUT ) )
				Help( " ", 1, "xATSVVldModel", , "Para excluir esta manutenção exclua a última manutenção antes.", 1, 0 ) // "Para excluir esta manutenção exclua a última manutenção antes."
			EndIf
		Else
			 lRet := .F.
			 Help( " ", 1, "xATSVVldModel", , "Registro não encontrado para exclusão.", 1, 0 ) // "Registro não encontrado para exclusão."
		EndIf
	EndIf
EndIf

//----------------------------------------------------------------------
// Valida regras de negócio para cada agenda que sofrerá alterações
//----------------------------------------------------------------------
If ( lRet ) .And. ( nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE )
	//--------------------------------------------------
	//  Reposiciona no início da tabela para a validação 
	// ocorrer sem problemas, só na inclusão ocorre manutenção em massa
	If nOpc == MODEL_OPERATION_INSERT
		(cAliasTmp)->( DbGoTop() )
	EndIf

	While lRet .And. (cAliasTmp)->(!Eof())

		dDtIni	:= SToD( (cAliasTmp)->ABB_DTINI )
		cHrIni	:= (cAliasTmp)->ABB_HRINI
		dDtFim	:= SToD( (cAliasTmp)->ABB_DTFIM )
		cHrFim	:= (cAliasTmp)->ABB_HRFIM

		If ( (cAliasTmp)->ABB_OK == 1 )	//Verifica apenas se a linha estivar marcada
			
			If ( cTipo == MANUT_TIPO_ATRASO )
				//Atualiza data e hora inicial em caso de atraso, conforme o tempo de atraso.
				SomaDiaHor( @dDtIni, @cHrIni, HoraToInt( cTempo, 2 ) )
			ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )	
				//Atualiza data e hora final em caso de saída antecipada, conforme o tempo de saída.
				SubtDiaHor( @dDtFim, @cHrFim, HoraToInt( cTempo, 2 ) )
			ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA )	
				//Atualiza a data e hora de início e fim do atendimento, conforme o tempo de hora extra.
				SubtDiaHor( @dDtIni, @cHrIni, nTempoIni )
				SomaDiaHor( @dDtFim, @cHrFim, nTempoFim )
			EndIf

			If nOpc == MODEL_OPERATION_INSERT
				//Monta array com manutenções realizadas anteriormente na agenda
				aManut := xATSVQryMan( (cAliasTmp)->ABB_CODIGO )
				
				//Não permite mais de uma manutenção do mesmo tipo
				If ( AScan( aManut, { |x| x[2] == cTipo } ) > 0 )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , 'A agenda do dia ' + DToC(SToD((cAliasTmp)->ABB_DTINI)) + " já possui manutenção por motivo do mesmo tipo. Utilize a opção Detalhes para alterar essa manutenção.", 1, 0 )	//'A agenda do dia ' | " já possui manutenção por motivo do mesmo tipo. Utilize a opção Detalhes para alterar essa manutenção."
					Exit
				EndIf
	
				//Verifica se tem atraso registrado
				If ( AScan( aManut, { |x| x[2] == MANUT_TIPO_ATRASO } ) > 0 )
					lAtraso := .T.
				EndIf
				
				//Verifica se tem saída antecipada registrada
				If ( AScan( aManut, { |x| x[2] == MANUT_TIPO_SAIDAANT } ) > 0 )
					lSaidaAnt := .T.
				EndIf
				
				//Verifica se tem hora extra registrada
				nExtra := AScan( aManut, { |x| x[2] == MANUT_TIPO_HORAEXTRA } )
				If ( nExtra > 0 )
					//Hora extra antes do horário
					If ( SubtHoras( SToD( aManut[nExtra][3] ), aManut[nExtra][4], SToD( (cAliasTmp)->ABB_DTINI ), (cAliasTmp)->ABB_HRINI ) > 0 )
						lHrExtraIni := .T.
					EndIf  
					//Hora extra depois do horário
					If ( SubtHoras( SToD( (cAliasTmp)->ABB_DTFIM ), (cAliasTmp)->ABB_HRFIM, SToD( aManut[nExtra][5] ), aManut[nExtra][6] ) > 0 )
						lHrExtraFim := .T.
					EndIf  
				EndIf
				
				//Verifica se agenda está ativa
				If ( (cAliasTmp)->ABB_ATIVO = '2' )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , 'A agenda do dia '  + DToC(SToD((cAliasTmp)->ABB_DTINI)) + " foi desativada e não pode sofer manutenção." , 1, 0 )	//"A Agenda do dia " | " foi desativada e não pode sofer manutenção."
					Exit
				EndIf
				
				//Verifica se agenda foi atendida
				If ( (cAliasTmp)->ABB_ATENDE = '1' .And. (cAliasTmp)->ABB_CHEGOU = 'S' )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , "A Agenda do dia " + DToC(SToD((cAliasTmp)->ABB_DTINI)) + " já foi atendida e não pode sofer manutenção.", 1, 0 )	//"A Agenda do dia " | " já foi atendida e não pode sofer manutenção."
					Exit
				EndIf
			
			EndIf
			
			//--------------------------------------------------------------
			//  Valida por tipo do motivo de manutenção
			//--------------------------------------------------------------
			//Atraso
			If ( cTipo == MANUT_TIPO_ATRASO )
				
				//Tempo de atraso anterior ao início do atendimento
				If ( Empty( cTempo ) ) .Or. ( cTempo == '00:00' )
					If 	Empty( StrTran( StrTran( cTempo, ':', '' ), '0', '' ) ) .Or. ( ( dDtIni < SToD( (cAliasTmp)->ABB_DTINI ) ) .Or.; 
						( ( dDtIni == SToD( (cAliasTmp)->ABB_DTINI ) ) .And. ( cHrIni <= StrTran( (cAliasTmp)->ABB_HRINI, ':', '' ) ) ) )
						lRet := .F.
						Help( " ", 1, "xATSVVldModel", , 'A data e hora inicial deve ser superior à original.', 1, 0 )	//'A data e hora inicial deve ser superior à original.'
						Exit
					EndIf
				EndIf
				
				//Tempo de atraso superior ao final do atendimento
				If ( Empty( cTempo ) ) .Or. ( cTempo == '00:00' )
					If 	( dDtIni > SToD( (cAliasTmp)->ABB_DTFIM ) ) .Or.;
						( ( dDtIni == SToD( (cAliasTmp)->ABB_DTFIM ) ) .And. ( cHrIni >= StrTran( (cAliasTmp)->ABB_HRFIM, ':', '' ) ) )
						lRet := .F.
						Help( " ", 1, "xATSVVldModel", , 'A data e hora inicial deve ser inferior à hora final da agenda.', 1, 0 )	//'A data e hora inicial deve ser inferior à hora final da agenda.'
						Exit
					EndIf
				Else
					If ( HoraToInt( cTempo ) > SubtHoras( SToD((cAliasTmp)->ABB_DTINI), (cAliasTmp)->ABB_HRINI, SToD((cAliasTmp)->ABB_DTFIM), (cAliasTmp)->ABB_HRFIM ) )
						lRet := .F.
						Help( " ", 1, "xATSVVldModel", , 'O tempo de atraso não pode ser maior que o tempo de atendimento.', 1, 0 )	//'O tempo de atraso não pode ser maior que o tempo de atendimento.'
						Exit
					EndIf
				EndIf
				
				If ( lHrExtraIni )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , 'A Agenda do dia ' + ' possui hora extra antes do horário inicial.' + DToC(SToD((cAliasTmp)->ABB_DTINI)) + '' , 1, 0 )	//'Não é possível registrar o atraso. ' | "A agenda do dia " | ' possui hora extra antes do horário inicial.'
					Exit	
				EndIf
				
			//Saída Antecipada
			ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )
				
				//Saída antecipada fora do horário de atendimento
				If ( Empty( StrTran( StrTran( cTempo, ':', '' ), '0', '' ) ) ) .Or. ;
						( dDtFim == STOD( (cAliasTmp)->ABB_DTFIM ) .And. ; 
				 		( cHrFim >= (cAliasTmp)->ABB_HRFIM ) .Or. ( cHrFim <= (cAliasTmp)->ABB_HRINI ) )
					//Verifica se a data de saida é maior e o horario, para casos de virada de dia
					If (STOD( (cAliasTmp)->ABB_DTFIM ) > dDtIni .And. cHrFim >= (cAliasTmp)->ABB_HRFIM)
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , 'A hora final deve ser inferior à hora final da agenda e superior à hora inicial.' , 1, 0 )	//'A hora final deve ser inferior à hora final da agenda e superior à hora inicial.'
					Exit
				EndIf
				EndIf
				
				//Já possui hora extra após o horário
				If ( lHrExtraFim )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , 'Não é possível registrar a saída antecipada. ' + "A agenda do dia " + DToC(SToD((cAliasTmp)->ABB_DTINI)) + ' possui hora extra antes do horário inicial.' , 1, 0 )	//'Não é possível registrar a saída antecipada. ' | "A agenda do dia " | ' possui hora extra antes do horário inicial.'
					Exit	
				EndIf
				
			//Hora extra
			ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA )
			
				//Tempo de hora extra maior que zero
				If ( ( nTempoIni + nTempoFim ) <= 0 )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , 'O tempo total de hora extra deve ser maior que Zero', 1, 0 )	//'O tempo total de hora extra deve ser maior que Zero'
					Exit
				EndIf
				
				//Já possui atraso e saída antecipada registrada
				If ( lAtraso .And. lSaidaAnt )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , "A agenda do dia " + DToC(SToD((cAliasTmp)->ABB_DTINI)) + " possui atraso e saída antecipada registrada."  + "Para incluir a hora extra exclua o atraso ou a saída antecipada.", 1, 0 )	//"A agenda do dia " | " possui atraso e saída antecipada registrada." | "Para incluir a hora extra exclua o atraso ou a saída antecipada."
					Exit	
				EndIf
				
				//Já possui atraso e a hora extra é anterior ao início da agenda
				If ( lAtraso .And. nTempoIni > 0 )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , "A agenda do dia " + DToC(SToD((cAliasTmp)->ABB_DTINI)) + "Não é possível incluir hora extra anterior ao horário inicial e atraso ao mesmo tempo." , 1, 0 )	//"A agenda do dia " | " possui atraso registrado." | "Não é possível incluir hora extra anterior ao horário inicial e atraso ao mesmo tempo."
					Exit
				EndIf
				
				//Já possui saída antecipada e a hora extra é superior ao final da agenda
				If ( lSaidaAnt .And. nTempoFim > 0 )
					lRet := .F.
					Help( " ", 1, "xATSVVldModel", , "A agenda do dia " + DToC(SToD((cAliasTmp)->ABB_DTINI)) + " possui saída antecipada registrada." + "Não é possível incluir hora extra superior ao horário final e saída antecipada ao mesmo tempo." , 1, 0 )	//"A agenda do dia " | " possui saída antecipada registrada." | "Não é possível incluir hora extra superior ao horário final e saída antecipada ao mesmo tempo."
					Exit
				EndIf
				
			EndIf
				
		EndIf
		
		// -------------------------------------------------------------------
		//  Somente a inserção permite manutenção em mais de um registro
		// por isso quando for inclusão usa Skip e alteração o Exit
		If nOpc == MODEL_OPERATION_INSERT
			(cAliasTmp)->( DbSkip() )
		Else
			Exit
		EndIf	
	EndDo	
EndIf

RestArea( aAreaABR )
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVTipo
Retorna o tipo de manutenção do motivo selecionado.

@sample 	xATSVTipo()
@return	cTipo		Tipo de manutenção do motivo selecionado.

@author	Danilo Dias
@since		14/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function xATSVTipo()

Local aArea 	:= GetArea()
Local oModel	:= FwModelActive()
Local cTipo	:= ''

DbSelectArea('ABN')
ABN->(DbSetOrder(1))

If ( oModel:GetId() == "RSVNA007" .And. ABN->( DbSeek( xFilial('ABN') + oModel:GetValue( 'XBRMASTER', 'ABR_MOTIVO' ) ) ) )
	cTipo := ABN->ABN_TIPO
EndIf

RestArea( aArea )

Return cTipo


//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVQryMan
Monta array com motivos de manutenções realizadas na agenda informada.

@sample 	xATSVQryMan( cAgenda )

@param		cAgenda	Código da agenda para consultar manutenções.
@return	aDados		Array com motivos das manutenções realizadas 
@return						na agenda.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function xATSVQryMan( cAgenda )

Local aDados	:= {}
Local cAlias	:= GetNextAlias()

Default cAgenda := ''

BeginSQL Alias cAlias
	SELECT ABR.ABR_MOTIVO, ABN.ABN_TIPO, ABR.ABR_DTINI, ABR.ABR_HRINI, ABR.ABR_DTFIM, ABR.ABR_HRFIM
	  FROM %Table:ABR% ABR
	       JOIN %Table:ABN% ABN ON ABN.ABN_FILIAL = %xFilial:ABN%
	                           AND ABN.%NotDel%
	                           AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
	 WHERE ABR.ABR_FILIAL = %xFilial:ABR%
	   AND ABR.%NotDel%
	   AND ABR.ABR_AGENDA = %Exp:cAgenda%
EndSQL

While (cAlias)->(!Eof())

	AAdd( aDados, { 	(cAlias)->ABR_MOTIVO,;
						(cAlias)->ABN_TIPO,;
						(cAlias)->ABR_DTINI,;
						(cAlias)->ABR_HRINI,;
						(cAlias)->ABR_DTFIM,;
						(cAlias)->ABR_HRFIM } )
	
	(cAlias)->(DbSkip())
	
EndDo

Return aDados


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVGrvABB
Grava a agenda para o atendente informado.

@sample 	xATSVGrvABB( cCodTec, cChave, cNumOS, cIdcFal, dDtIni, cHrIni, dDtFim, cHrFim )

@param		cCodTec	Código do técnico.
@param		cChave		Chave da agenda.
@param		cNumOS		Número da OS.
@param		cIdcFal		Chave da configuração da OS.
@param		dDtIni		Data de início da agenda.
@param		cHrIni		Hora de início da agenda.
@param		dDtFim		Data de fim da agenda.
@param		cHrFim		Hora de fim da agenda.
@param		lInclui		Indica se é uma inclusão ou alteração.
@param		cLocal		Local de atendimento da agenda
@param 		cTipo 		Tipo da Agenda
@param		cAgendAnt	Código da agenda que recebeu a manutenção
@param		cTipDia		Tipo do dia da agenda, dia de trabalho (S) ou dia não trabalhado (N)

@author	Danilo Dias
@since		16/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function xATSVGrvABB( cCodTec, cChave, cNumOS, cIdcFal, dDtIni,;
                      cHrIni, dDtFim, cHrFim, lInclui, cLocal,;
                      cTipo, cAgendAnt, cTipDia, lCustoTWZ )

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local cHrTot		:= ATTotHora(	dDtIni, cHrIni, dDtFim, cHrFim )	//Tempo total da agenda

Default lInclui := .T.
Default cLocal := ""
Default cTipo  := ""
Default cTipDia := ""
Default lCustoTWZ	:= ExistBlock("TecXNcusto")

AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC
AA1->( MsSeek( xFilial("AA1") + cCodTec ) )

//Busca o custo do atendente pelo PE ou pelo campo do atendente
If lCustoTWZ
	// posicina ABQ
	DbSelectArea("ABQ")
	ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
	ABQ->( DbSeek( cConfig ) )
	
	// posicina TFF
	DbSelectArea("TFF")
	TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
	TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
	nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
						{ 3, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
							TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
Else
	nCusto := AA1->AA1_CUSTO
EndIf

If ABN->ABN_TIPO == "07" .AND. ABR->ABR_HRINI != ABB->ABB_HRINI .AND. ABR->ABR_HRFIM != ABB->ABB_HRFIM
	cHrIni := IntToHora(HoraToInt(cHrIni)+0.01)
EndIf 

RecLock('ABB',lInclui)

	If ( lInclui )
		ABB->ABB_FILIAL	:= xFilial( 'ABB' )
		ABB->ABB_CODIGO	:= GetSXENum( 'ABB', 'ABB_CODIGO' )
	EndIf
	ABB->ABB_CODTEC	:= cCodTec
	If !Empty(cNumOS)
		ABB->ABB_ENTIDA	:= 'AB7'
		ABB->ABB_NUMOS	:= cNumOS
	EndIf
	ABB->ABB_CHAVE	:= cChave
	ABB->ABB_DTINI	:= dDtIni
	ABB->ABB_HRINI	:= cHrIni
	ABB->ABB_DTFIM	:= dDtFim
	ABB->ABB_HRFIM	:= cHrFim
	ABB->ABB_HRTOT	:= cHrTot
	ABB->ABB_SACRA 	:= 'S'
	ABB->ABB_CHEGOU	:= 'N'
	ABB->ABB_ATENDE	:= '2'
	ABB->ABB_MANUT	:= '2'
	ABB->ABB_ATIVO	:= '1'
	ABB->ABB_IDCFAL	:= cIdcFal
	ABB->ABB_LOCAL	:= cLocal
	
	If !Empty(cTipo)
		ABB->ABB_TIPOMV := cTipo
	EndIf
	
	//Grava o custo da alocação
	Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)

	ABB->(MsUnLock())

If ( lInclui )
	ConfirmSX8()
	
	If xATSVVldTDV(cAgendAnt)
		xATSVUpdTdv(.F.,cAgendAnt, ABB->ABB_CODIGO, cTipDia )
	EndIf
EndIf

RestArea( aAreaABB )
RestArea( aArea )

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVSelCt
Tela para seleção da configuração do contrato para atendimento da OS.

@sample 	xATSVSelCt( cItemOS )

@param		cItemOS	Item da OS para busca do contrato.

@author	Danilo Dias
@since		20/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function xATSVSelCt( cItemOS, cMotManut )

Local aArea		:= GetArea()
Local aAreaAB6	:= AB6->(GetArea())
Local aAreaABQ	:= ABQ->(GetArea())
Local aAreaABN 	:= ABN->(GetArea())
Local oDlg			:= Nil
Local oBrowse		:= Nil
Local lRet			:= .T.
Local aHeader		:= {}		//Cabeçalho com a descrição dos campos da grid
Local aItens		:= {}		//Conteúdo dos campos da grid
Local cContrato	:= ''		//Contrato da OS
Local lTecXRh		:= SuperGetMV( 'MV_TECXRH',, .F. )	//Indica se há integração com o RH
Local nPosCont	:= 0

Default cItemOS := ''

DbSelectArea('AB6')	//Ordens de Serviço
AB6->(DbSetOrder(1))	//AB6_FILIAL+AB6_NUMOS

DbSelectArea('AB7')	//Ordens de Serviço Item
AB7->(DbSetOrder(1))	//AB7_FILIAL+AB7_NUMOS+AB7_ITEM

DbSelectArea('ABQ')	//Configuração de Alocação de Recursos
ABQ->(DbSetOrder(1))	//ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM

DbSelectArea('ABN')	// Motivos de Manutenção
ABN->(DbSetOrder(1))	//ABN_FILIAL+ABN_CODIGO

// ---------------------------------------------
// Verifica se a manutenção é uma transferência 
// e se está ocorrendo para a mesma OS
If !( cItemOs == ABB->ABB_CHAVE .And. ABN->( DbSeek( xFilial('ABN')+cMotManut ) ) .And. ABN->ABN_TIPO=='06' )
	If ( AB7->( DbSeek( xFilial("AB7")+cItemOS ) ) )
		If AB6->(DbSeek(AB7->AB7_FILIAL+AB7->AB7_NUMOS))
			If ( ABQ->( DbSeek( xFilial('ABQ') + AB6->AB6_CONTRT ) ) )
				cContrato := ABQ->ABQ_CONTRT
			Else 
				lRet := .F.		
			EndIf
		EndIf	
	EndIf
Else
	lRet := .F.
	Help(,,'xATSVITOS',, "A transferência não pode ocorrer para a mesma Ordem de Serviço e Item",1,0) // "A transferência não pode ocorrer para a mesma Ordem de Serviço e Item"
EndIf
                  
If ( lRet )

	xATSVGtABQ( cContrato, @aHeader, @aItens )
	
	DEFINE DIALOG oDlg TITLE "Configuração do Contrato" FROM 180,180 TO 400,800 PIXEL	//"Configuração do Contrato"	    
	
	oBrowse := TWBrowse():New( 0, 0, 313, 111,, aHeader,, oDlg,,,,,{||},,,,,,,.F.,,.F.,,.F.,,, )    
	oBrowse:SetArray( aItens )
	 
	If ( lTecXRh )   
		oBrowse:bLine := { || { 	aItens[oBrowse:nAt, 01], aItens[oBrowse:nAt, 02], aItens[oBrowse:nAt, 03],;
									aItens[oBrowse:nAt, 04], aItens[oBrowse:nAt, 05], aItens[oBrowse:nAt, 06],;
									aItens[oBrowse:nAt, 07], aItens[oBrowse:nAt, 08], aItens[oBrowse:nAt, 09],;
									aItens[oBrowse:nAt, 10], aItens[oBrowse:nAt, 11], aItens[oBrowse:nAt, 12],;
									aItens[oBrowse:nAt, 13], aItens[oBrowse:nAt, 14] } }
	nPosCont := 15
	Else
		oBrowse:bLine := { || { 	aItens[oBrowse:nAt, 01], aItens[oBrowse:nAt, 02], aItens[oBrowse:nAt, 03],;
									aItens[oBrowse:nAt, 04], aItens[oBrowse:nAt, 05], aItens[oBrowse:nAt, 06],;
									aItens[oBrowse:nAt, 07], aItens[oBrowse:nAt, 08], aItens[oBrowse:nAt, 09],;
									aItens[oBrowse:nAt, 10], aItens[oBrowse:nAt, 11], aItens[oBrowse:nAt, 12] } }
	nPosCont := 13
	EndIf
	   
	oBrowse:bLDblClick := { || cConfCtr := aItens[oBrowse:nAt,nPosCont], oDlg:End() } 
	oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT
	oBrowse:DrawSelect()
	oBrowse:Refresh()
	
	ACTIVATE DIALOG oDlg CENTERED

EndIf

RestArea( aAreaABN )
RestArea( aAreaAB6 )
RestArea( aAreaABQ )
RestArea( aArea )

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVGtABQ
Monta dados da tabela ABQ para exibir na tela de seleção da configuração do contrato.

@sample 	xATSVGtABQ( cContrato, aHeader, aItens )

@param		cContrato	Número do contrato para buscar configurações.
			aHeader	Array com dados do cabeçalho. (Referência)
			aItens		Array com dados dos registros da tabela. (Referência)

@author	Danilo Dias
@since		20/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function xATSVGtABQ( cContrato, aHeader, aItens )

Local aArea    	:= GetArea()
Local aAreaABQ 	:= ABQ->(GetArea())
Local lTecXRh		:= SuperGetMV( 'MV_TECXRH',, .F. )	//Indica se há integração com o RH
Local nI			:= 0
Local nJ			:= 0

//Monta o cabeçalho com os campos da tabela ABQ
AAdd( aHeader, TxSX3Campo('ABQ_PRODUT')[1] )		// "Produto"
AAdd( aHeader, TxSX3Campo('B1_DESC')[1] )			// "Descrição"
AAdd( aHeader, TxSX3Campo('ABQ_TPPROD')[1] )		// "Tipo de Produto"
If lTecXRh
	AAdd( aHeader, TxSX3Campo('ABQ_CARGO')[1] )	// "Cargo"
	AAdd( aHeader, TxSX3Campo('Q3_DESCSUM')[1] )	// "Descrição"
EndIf
AAdd( aHeader, TxSX3Campo('ABQ_FUNCAO')[1] )		// "Função"
AAdd( aHeader, TxSX3Campo('RJ_DESC')[1] )     	// "Descrição"
AAdd( aHeader, TxSX3Campo('ABQ_PERINI')[1] )   	// "Periodo Inicial"
AAdd( aHeader, TxSX3Campo('ABQ_PERFIM')[1] )    	// "Periodo Final"
AAdd( aHeader, TxSX3Campo('ABQ_TURNO')[1] )		// "Turno"
AAdd( aHeader, TxSX3Campo('R6_DESC')[1] )      	// "Descrição"
AAdd( aHeader, "Horas Contratadas")   							// "Horas Contratadas"
AAdd( aHeader, "Horas Alocadas")      						// "Horas Alocadas"
AAdd( aHeader, "Saldo de Horas")								// "Saldo de Horas"                                

DbSelectArea("ABQ")
ABQ->(DbSetOrder(1))

aItens := {}
nI		:= 1

//Monta os itens com os dados da ABQ		
If ABQ->( DbSeek( xFilial("ABQ") + cContrato ) )

	While ( ABQ->(!Eof()) .AND. ABQ->ABQ_FILIAL + ABQ_CONTRT == xFilial("ABQ") + cContrato )
		
		AAdd( aItens, {} )
		
		Aadd( aItens[nI], Alltrim( ABQ->ABQ_PRODUT ) )
		Aadd( aItens[nI], Alltrim( Posicione( "SB1", 1, xFilial("SB1") + ABQ->ABQ_PRODUT, "B1_DESC" ) ) )
		Aadd( aItens[nI], X3Combo( "ABQ_TPPROD", ABQ->ABQ_TPPROD ) )
		If ( lTecXRh )
			Aadd( aItens[nI], Alltrim(ABQ->ABQ_CARGO))
			Aadd( aItens[nI], Alltrim(FDESC("SQ3",ABQ->ABQ_CARGO,"Q3_DESCSUM",,ABQ->ABQ_FILIAL)))
		EndIf
		Aadd( aItens[nI], Alltrim(ABQ->ABQ_FUNCAO))
		Aadd( aItens[nI], Alltrim(FDESC("SRJ",ABQ->ABQ_FUNCAO,"RJ_DESC",,ABQ->ABQ_FILIAL)))
		Aadd( aItens[nI], ABQ->ABQ_PERINI)
		Aadd( aItens[nI], ABQ->ABQ_PERFIM)
		Aadd( aItens[nI], ABQ->ABQ_TURNO)
		Aadd( aItens[nI], Alltrim(FDESC("SR6",ABQ->ABQ_TURNO,"R6_DESC")))
		Aadd( aItens[nI], Transform(ABQ->ABQ_TOTAL,PesqPict("ABQ","ABQ_TOTAL")))
		Aadd( aItens[nI], Transform((ABQ->ABQ_TOTAL-ABQ->ABQ_SALDO),PesqPict("ABQ","ABQ_TOTAL")))
		Aadd( aItens[nI], Transform(ABQ->ABQ_SALDO,PesqPict("ABQ","ABQ_SALDO")))
		Aadd( aItens[nI], Alltrim( ABQ->ABQ_CONTRT + ABQ->ABQ_ITEM ) )
		
		nI++
		ABQ->(DbSkip())
	EndDo
EndIf

If ( Len(aItens) == 0 )
	If ( lTecXRh )
		nJ := 15
	Else
		nJ := 13
	EndIf
	AAdd( aItens, {} )
	
	For nI := 1 To nJ		
		AAdd( aItens[1], '' )
	Next nI
EndIf

RestArea( aAreaABQ )
RestArea( aArea )

Return Nil


//------------------------------------------------------------------------------------------
/* /{Protheus.doc} IsLastManut
	Valida se o código de manutenção informado é da última manutenção realizada na agenda

@sample 	IsLastManut( cCodAgenda, cCodManut )

@param 	cCodAgenda	Código da Agenda para referência à agenda
@param 	cCodManut	Código Sequencial de Manutenção na tabela ABR

@author 	Josimar Junior
@since 	07/05/2013
@version 	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function IsLastManut( cCodAgenda, cCodManut )

Local lRet 	:= .T.
Local cAreaTmp 	:= GetNextAlias()
Local aSave 	:= GetArea()
Local aSaveABB 	:= ABB->( GetArea() )
Local aSaveABR 	:= ABR->( GetArea() )

BeginSql Alias cAreaTmp

	SELECT ABR.ABR_AGENDA, ABR.ABR_MANUT
	  FROM %table:ABR% ABR
	 WHERE ABR.%NotDel% 
	   AND ABR.ABR_FILIAL = %xFilial:ABR% 
	   AND ABR_AGENDA = %exp:cCodAgenda%

EndSql

While lRet .And. (cAreaTmp)->( !EOF() )
	If cCodManut < (cAreaTmp)->ABR_MANUT
		lRet := .F.
	EndIf

	(cAreaTmp)->( DbSkip() )
End

RestArea( aSaveABR )
RestArea( aSaveABB )
RestArea( aSave )

Return lRet

//------------------------------------------------------------------------------------------
/* /{Protheus.doc} xalidDtHr
	Valida Data e Hora conforme o tipo do motivo de manutenção selecionado, chamado na
validação dos campos de Data e Hora Inicial e Final

@sample 	xalidDtHr( oModel, cCampo, xValAnt, xValIns )

@param 	oModel	objeto com o modelo de dados
@param 	cCampo	campo em validação
@param 	xValAnt	valor anterior do campo
@param 	xValIns	valor inserido pelo usuário no campo

@author 	Josimar Junior
@since 	07/05/2013
@version 	P11.8
/*/
//-------------------------------------------------------------------------------------------
User Function xalidDtHr( oModel, cCampo, xValIns, xValAnt )

Local lRet 		:= .T.
Local cTipo 	:= xATSVTipo()
Local lHora 	:= cCampo $ "ABR_HRINI*ABR_HRFIM"
Local lBloqDt  := .F.

//------------------------------------------------------------------------------------
//  Sobrescreve o conteúdo do valor anterior para validar conforme o primeiro
// registro selecionado na tabela de agenda temporária
xValAnt := (cAliasTmp)->&(StrTran(cCampo, "ABR", "ABB") )

If ValType(xValIns)=='D' .And. ValType(xValAnt) <> 'D'
	xValAnt := STOD( xValAnt )
	
	If cTipo == MANUT_TIPO_ATRASO
		lBloqDt := ( xValIns > oModel:GetValue("ABR_DTFIM") )
	ElseIf cTipo == MANUT_TIPO_SAIDAANT
		lBloqDt := ( xValIns < oModel:GetValue("ABR_DTINI") )
	EndIf
	
EndIf

If cTipo == MANUT_TIPO_ATRASO .And. Alltrim(cCampo) $ "ABR_DTINI*ABR_HRINI"

	lRet := ( xValAnt <= xValIns .And. !lBloqDt ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )

ElseIf cTipo == MANUT_TIPO_SAIDAANT .And. Alltrim(cCampo) $ "ABR_DTFIM*ABR_HRFIM"

	lRet := ( xValAnt >= xValIns .And. !lBloqDt ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )
	
	//Valida se a hora incluida na saida antecipada é maior que a hora inicial
	If lRet
		lRet := oModel:GetValue("ABR_HRINI") <= xValIns
	EndIf
	
ElseIf cTipo == MANUT_TIPO_HORAEXTRA

	If Alltrim(cCampo) $ "ABR_DTINI*ABR_HRINI"	
		lRet := ( xValAnt >= xValIns ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )
	Else
		lRet := ( xValAnt <= xValIns ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )	
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVGtAls
Retorna Alias utilizado pelo Model

@sample 	xATSVGtAls( )

@return	cAliasTmp	Alias Temporario utilizado pelo Model

@author	Rogério Francisco de Souza
@since		23/05/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function xATSVGtAls()

Return cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVStAls
RetSeta Alias a ser utiulizado pelo Model

@sample 	xATSVStAls(cAlias)

@param		cAlias	Alias a ser utilizado

@author	Rogério Francisco de Souza
@since		23/05/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
User Function xATSVStAls(cAlias)
cAliasTmp := cAlias
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVVldTDV
	Verifica se há víncula da agenda com a geração de escalas

@sample 	xATSVVldTDV('0000001')

@param		cAgdAbb, Char, código da agenda na tabela ABB

@since		14/07/2014
@version	P11.9
/*/
//-------------------------------------------------------------------
Static Function xATSVVldTDV( cAgdAbb )

Local aSave     := GetArea()
Local aSaveTDV  := TDV->(GetArea())
Local lRet      := .F.
DEFAULT cAgdAbb := ''

DbSelectArea('TDV')
TDV->(DbSetOrder(1))  //TDV_FILIAL+TDV_CODABB

If !Empty(cAgdAbb) .And. TDV->(DbSeek(xFilial('TDV')+cAgdAbb))
	lRet := .T.
EndIf

RestArea(aSaveTDV)
RestArea(aSave)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xATSVUpdTdv
	Copia as informações da escala de uma agenda para outra agenda

@sample 	xATSVUpdTdv('0000001')

@param		cAgCopia, Char, código da agenda a ter o conteúdo da escala copiado
@param		cAgNova, Char, código da nova agenda que terá a escala criada

@since		14/07/2014
@version	P11.9
/*/
//-------------------------------------------------------------------
Static Function xATSVUpdTdv(lDeleta,cAgCopia,cAgNova,cTipGrav)

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

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} xATSVFilCt
Filtra as informações.

@sample 	xATSVFilCt(_aAtend)

@param		_aAtend	Vetor: cCodSub,cConfig,dDtIniSub,cHrIniSub,dDtFimSub,cHrFimSub,cLocal,cTipoAloc,cAgenda

@author	Elcio
@since		10/02/2015
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Static Function xATSVFilCt(_aAtend)
	
Local aAreaABB  := GetArea()
Local cAliasABB := ''
Local _cConfig  := ''
Local cNumContr := ''
Local cRevContr := ''
Local nX        := 0

//If IsInCallStack('AT570Subst')
//	If ValType(lGeraMemo)=="U"
//		lGeraMemo := !(isBlind()) .AND. ( PerguntMemo() .AND. MSGYESNO( "Deseja realmente gerar o memorando?", "Memorando") ) //"Deseja realmente gerar o memorando?" # "Memorando"
//	EndIf
//Else
//	lGeraMemo := !(isBlind()) .AND. ( PerguntMemo() .AND. MSGYESNO( "Deseja realmente gerar o memorando?", "Memorando" ) ) //"Deseja realmente gerar o memorando?" # "Memorando"
//EndIf

IF lGeraMemo

	FOR nX := 1 TO Len(_aAtend)

		cAliasABB := GetNextAlias()

		_cConfig  := _aAtend[nX][2]
		cNumContr := Substr(_aAtend[nX][2],1,TAMSX3("TFF_CONTRT")[1])

		BeginSql Alias cAliasABB

			SELECT DISTINCT TFF_CONTRT, TFF_CONREV
			  FROM %table:ABB% ABB
			       JOIN %table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
			                           AND ABQ.%notDel%
			                           AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = ABB_IDCFAL
			       JOIN %table:TFF% TFF ON TFF_FILIAL = %xFilial:TFF%
			                           AND TFF_COD = ABQ_CODTFF
			                           AND TFF.%notDel%
			 WHERE ABB_FILIAL = %xFilial:ABB%
			   AND ABB_IDCFAL = %Exp:_cConfig%
			   AND ABB.%notDel%

		EndSql

		DbSelectArea(cAliasABB)

		DO WHILE (cAliasABB)->(!Eof())
			cRevContr := (cAliasABB)->TFF_CONREV
			(cAliasABB)->(DbSkip())
		END

		DbSelectArea(cAliasABB)
		(cAliasABB)->(DbCloseArea())

		// Chama rotina de geracao do memorando
		At330GerMem(cNumContr, cRevContr, _aAtend[nX] )

	NEXT nX
ENDIF

RestArea(aAreaABB)

Return

/*
{Protheus.doc} xATSVReset

@simple xATSVReset()
@since  20/08/2015
@return Null
*/
Static Function xATSVReset()

cTipoAloc	:= ""
lGeraMemo	:= Nil
Return

/*/{Protheus.doc} xATSVCmdSub
@description 		função criada para facilitar o debug 
@author				josimar.assuncao
@since				03.03.2017
@version			P12
@param 				oView, objeto FwFormView, objeto da interface do mvc (view)
/*/
Static Function xATSVCmdSub( oView ) 
Local lRet := .F.
Local cCodAtdSub := ""
Local oModel := oView:GetModel()
xATSVSelSub( @cCodAtdSub, oModel )

If !Empty(cCodAtdSub)
	lRet := oModel:SetValue( 'XBRMASTER', 'ABR_CODSUB', ALLTRIM(cCodAtdSub))
EndIf

Return lRet

/*/{Protheus.doc} xATSVVlMt
@description 		validação do motivo sendo escolhido para a manutenção da agenda
@author				josimar.assuncao
@since				06.03.2017
@version			P12
/*/
Static Function xATSVVlMt()
Local lRet := .T.
Local cTipo := xATSVTipo()

If cTipo == '06' .And. ; // tipo igual a transferência
	 Right( (cAliasTmp)->ABB_IDCFAL, 3) == "CN9"  // origem do contrato como CN9

	 lRet := .F.
	 Help(,,'xATSVNOTRCN9',, "Não pode ser realizada transferência em contratos integrados com o GCT.",1,0) // "Não pode ser realizada transferência em contratos integrados com o GCT."
EndIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AUpdABBAus
Atualiza a ABB criada pela ausência

@author	Matheus Lando Raimundo
@since		07/03/2018
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Static Function AUpdABBAus(cConfig,cCodTec,dDtIni,dDtFim,cHrFim)
Local cAliasTemp := GetNextAlias()
Local lRet := .F.

BeginSQL Alias cAliasTemp
	SELECT R_E_C_N_O_ IDRECNO FROM %Table:ABB% ABB
		WHERE ABB_FILIAL = %xFilial:ABB%
		AND ABB_IDCFAL = %Exp:cConfig%
		AND ABB_CODTEC = %Exp:cCodTec%
		AND ABB_DTINI  = %Exp:dDtIni%
		AND ABB_DTFIM  = %Exp:dDtFim%
		AND ABB_HRFIM  = %Exp:cHrFim%
		AND ABB.%NotDel%
EndSQL

If (cAliasTemp)->(!Eof())
	lRet := .T.
	ABB->(dbGoto((cAliasTemp)->IDRECNO))
	RecLock('ABB',.F.)
	ABB->ABB_MANUT = '2'
	ABB->(MsUnlock())
EndIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AUpdABBAus
Valid para o campo ABR_CODSUB

@author	Diego de Andrade Bezerra
@since		22/05/2018
@version	P12
/*/
//-------------------------------------------------------------------------------------------
User Function xATSVVaSub()

Local oMdlVld := FwModelActive()
Local cDateIn	:=	oMdlVld:GetModel("XBRMASTER"):GetValue('ABR_DTINI')
Local cDateFim	:= 	oMdlVld:GetModel("XBRMASTER"):GetValue('ABR_DTFIM')
Local cCodSub	:= 	oMdlVld:GetModel("XBRMASTER"):GetValue('ABR_CODSUB')
Local aRet	:= 	{}
Local lRet	:= .T.
Local cRet	:= 0
Local nI	:= 0
Local lAchou	:= .F.
Local cAliasTmp := GetNextAlias()
Local cCodTFF	:= TFF->TFF_COD

// Verifica se o usuário logado tem permissão para inserir substituto manualmente 
If (At680Perm( Nil , __cUserID, "036"))
	// Carrega array com o código do atendente e código da função, caso seja funcionário, se o mesmo estiver disponível para o período escolhido
	aRet	:= ListarApoio(cDateIn, cDateFim)
	lRet := ASCAN(aRet ,{|x| x[1] == cCodSub}) > 0
	
	// Se o atendente não for encontrado, ele não está disponível para a substituição no período selecionado
	If !lRet
		Help(,,"xATSVVaSub",,"Atendente não disponível para substituição",1,0) // Atendente não disponível para substituição
	EndIf
	
EndIf
Return lRet