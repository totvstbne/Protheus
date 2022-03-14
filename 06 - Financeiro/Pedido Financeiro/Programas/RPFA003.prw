#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'FWMVCDEF.ch'

/*/{Protheus.doc} RPFA003
Rateio de Multinaturezas
@author Diogo
@since 17/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA003()
	Local oBrowse		:= Nil
	Private aRotina		:= MenuDef()
	Private cCadastro	:= "Rateio de Multinaturezas"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA8")

	oBrowse:SetDescription(cCadastro)
	oBrowse:DisableDetails()
	oBrowse:Activate()
return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"	ACTION "PesqBrw"			OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.RPFA003"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.RPFA003"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.RPFA003"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.RPFA003"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"		ACTION "VIEWDEF.RPFA003"	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"    	ACTION "VIEWDEF.RPFA003"	OPERATION 9 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruct		:= Nil
	Local oStructZA8	:= Nil
	Local oModel		:= Nil

	oStruct			:= FWFormStruct(1,"ZA8", {|cCampo|   (AllTrim(cCampo)+"|" $ "ZA8_PREFIX|ZA8_NUM|ZA8_PARCEL|ZA8_CLIFOR|ZA8_LOJA|ZA8_TIPO|ZA8_VALOR|")} )
	oStructZA8		:= FWFormStruct(1,"ZA8", {|cCampo|   !(AllTrim(cCampo)+"|" $ "ZA8_PREFIX|ZA8_NUM|ZA8_PARCEL|ZA8_CLIFOR|ZA8_LOJA|ZA8_TIPO|ZA8_VALOR|")} )

	oModel:= MPFormModel():New("YPFA002",/*Pre-Validacao*/,{|oModel| fValidarForm(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("CABECZA8", Nil/*cOwner*/, oStruct ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey({"ZA8_FILIAL","ZA8_PREFIX","ZA8_NUM","ZA8_PARCEL","ZA8_CLIFOR","ZA8_LOJA"})

	oModel:AddGrid("GRIDZA8", "CABECZA8"/*cOwner*/,oStructZA8,{ |oModel,nLine,cAcao,cCampo| fValiddAcao( oModel, nLine, cAcao, cCampo ) } ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)

	//	oModel:AddGrid("GRID_ZB2", "CMHA001_CAB"/*cOwner*/,oStructZB2,{ |oModelZB2,nLine,cAcao,cCampo| fValiddAcao( oModelZB2, nLine, cAcao, cCampo ) },;
	//													{|oModelZB2,nLine| vldLine(oModelZB2,nLine)}/*bLinePost*/,{|oModelZB2,nLinha,cOperacao,cCampo| FormLinPre(oModelZB2,nLinha,cOperacao,cCampo) }/*bPre*/,;
	//																		{|oModelZB2,nLinha,cOperacao,cCampo| FormLinPos(oModelZB2,nLinha,cOperacao,cCampo) }/*bPost*/,/*Carga*/)
	//

	oModel:SetRelation("GRIDZA8",{{"ZA8_FILIAL",'xFilial("ZA8")'},{"ZA8_PREFIX","ZA8_PREFIX"},;
	{"ZA8_NUM","ZA8_NUM"},{"ZA8_PARCEL","ZA8_PARCEL"},{"ZA8_CLIFOR","ZA8_CLIFOR"},;
	{"ZA8_LOJA","ZA8_LOJA"}},ZA8->(IndexKey(1)))
	oModel:GetModel( 'GRIDZA8' ):SetUniqueLine( { 'ZA8_NATURE' } )
	oModel:AddCalc( 'CALCPERC03', 'CABECZA8', 'GRIDZA8', 'ZA8_PERC'		, 'PERC', 'SUM',,,'Total Percentual',)
	oModel:AddCalc( 'CALCPERC03', 'CABECZA8', 'GRIDZA8', 'ZA8_VALNAT'	, 'NAT'	, 'SUM',,,'Total Valor',)

	oStructZA8:AddTrigger(	;
	"ZA8_PERC"			,;
	"ZA8_VALNAT"		,;
	{ |oModel,cId,xValue,nLinha| ReadVar() == "M->ZA8_PERC" }	,;
	{ |oModel|  fCalcVal(oModel) } )

	oStructZA8:AddTrigger(	;
	"ZA8_VALNAT"			,;
	"ZA8_PERC"				,;
	{ |oModel,cId,xValue,nLinha| ReadVar() == "M->ZA8_VALNAT" }	,;
	{ |oModel|  fCalcPer(oModel) } )

	oStructZA8:AddTrigger(	;
	"ZA8_RATEIC"			,;
	"ZA8_NMNAT"				,;
	{ |oModel,cId,xValue,nLinha| ReadVar() == "M->ZA8_RATEIC" },;
	{ |oModel|  fRatCCPF(oModel),oModel:GetValue("ZA8_NMNAT")})
	
	oModel:SetActivate({|oModel|fLoadZA8(oModel)})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStruct		:= FWFormStruct(2,"ZA8", {|cCampo|   (AllTrim(cCampo) + "|" $ "ZA8_PREFIX|ZA8_NUM|ZA8_PARCEL|ZA8_CLIFOR|ZA8_LOJA|ZA8_TIPO|ZA8_VALOR|")} )
	Local oStructZA8	:= FWFormStruct(2,"ZA8", {|cCampo|   !(AllTrim(cCampo) + "|" $ "ZA8_PREFIX|ZA8_NUM|ZA8_PARCEL|ZA8_CLIFOR|ZA8_LOJA|ZA8_TIPO|ZA8_VALOR|")} )
	Local oModel		:= FWLoadModel( 'RPFA003' )
	Local oCalc1		:= FWCalcStruct( oModel:GetModel( 'CALCPERC03') )
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "CABECZA8",oStruct)
	oView:AddGrid("GRIDZA8",oStructZA8)
	oView:AddField('CALC',oCalc1, 'CALCPERC03' )

	oView:CreateHorizontalBox("CABEC",25)
	oView:CreateHorizontalBox("GRID",65)
	oView:CreateHorizontalBox("CALC",10)
	oView:SetOwnerView( "CABECZA8","CABEC")
	oView:SetOwnerView( "GRIDZA8","GRID")
	oView:SetOwnerView( "CALC","CALC")
	oView:EnableControlBar(.T.)

	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)
Return oView

/*/{Protheus.doc} fCalcVal
Gatilho para o total do item
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcVal(oModel)
	Local oModel := FwModelActive()
	Local nRetC	 := oModel:getModel("CABECZA8"):getValue("ZA8_VALOR")

	If oModel:getModel("GRIDZA8"):getValue("ZA8_PERC") <> 100
		nRetC := Round((oModel:getModel("CABECZA8"):getValue("ZA8_VALOR")*;
		oModel:getModel("GRIDZA8"):getValue("ZA8_PERC"))/100,2)
	Endif
	oModel:GetModel("GRIDZA8"):loadValue("ZA8_RATEIC","2")
	fRatCCPF(oModel) //Apaga registro informado
Return nRetC

/*/{Protheus.doc} fCalcPer
Gatilho para o percetual do item
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fCalcPer(oModel)
	Local nRet	 := 100
	Local oModel := FwModelActive()
	
	If oModel:getModel("GRIDZA8"):getValue("ZA8_VALNAT") <> oModel:getModel("CABECZA8"):getValue("ZA8_VALOR")
		nRet := (Round((oModel:getModel("GRIDZA8"):getValue("ZA8_VALNAT")/ ;
		(oModel:getModel("CABECZA8"):getValue("ZA8_VALOR"))),getSx3Cache("EV_PERC","X3_DECIMAL"))) * 100
	Endif
	
	oModel:GetModel("GRIDZA8"):loadValue("ZA8_RATEIC","2")
	fRatCCPF(oModel) //Apaga registro informado
Return nRet

/*/{Protheus.doc} fValidarForm
Validação do formulário
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fValidarForm(oModel)
	Local lRet	:= .T.
	Local nTotI	:= 0
	
	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		For nx := 1 To oModel:getModel("GRIDZA8"):length()
			oModel:GetModel("GRIDZA8"):GoLine(nX)
			If oModel:GetModel("GRIDZA8"):IsDeleted()
				Loop
			EndIf
			nTotI += oModel:GetModel("GRIDZA8"):getValue("ZA8_VALNAT")
			If empty(oModel:GetModel("GRIDZA8"):getValue("ZA8_NATURE"))
				oModel:SetErrorMessage('GRIDZA8',,,,"ATENÇÃO",'Natureza não informada', 'Verifique o rateio',)
				Return .F.
			Endif
		Next
		If nTotI <> oModel:GetModel("CABECZA8"):getValue("ZA8_VALOR")
			oModel:SetErrorMessage('GRIDZA8',,,,"ATENÇÃO",'Totalizador não confere com o total do rateio', 'Verifique os valores informados',)
			lRet:= .F.
		Endif
	Endif
Return lRet

/*/{Protheus.doc} fRatCCPF
Rateio por Centro de Custo
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fRatCCPF(oModel)
	Local aArea	:= getArea()
	Local oModel:= fwModelActive()
	Local cRet	:= oModel:GetModel("GRIDZA8"):getValue("ZA8_RATEIC")
	
	If !empty(oModel:GetModel("GRIDZA8"):getValue("ZA8_NATURE"))
		If oModel:GetModel("GRIDZA8"):getValue("ZA8_RATEIC") == "1" //Tem rateio por CC
			//Verifica se existe lançamento para a natureza
			cQuery := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("ZA9") + " ZA9 "
			cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
			cQuery += "ZA9_FILIAL = '" + xFilial("ZA9") + "' AND "
			cQuery += "ZA9_PREFIX = '" + oModel:getModel("CABECZA8"):getValue("ZA8_PREFIX") + "' AND "
			cQuery += "ZA9_NUM= '" + oModel:getModel("CABECZA8"):getValue("ZA8_NUM") + "' AND "
			cQuery += "ZA9_PARCEL = '" + oModel:getModel("CABECZA8"):getValue("ZA8_PARCEL") + "' AND "
			cQuery += "ZA9_CLIFOR = '" + oModel:getModel("CABECZA8"):getValue("ZA8_CLIFOR") + "' AND "
			cQuery += "ZA9_LOJA = '" + oModel:getModel("CABECZA8"):getValue("ZA8_LOJA") + "'  AND "
			cQuery += "ZA9_NATURE = '" + oModel:getModel("GRIDZA8"):getValue("ZA8_NATURE") + "' "

			TcQuery cQuery new Alias QZA9

			If QZA9->(!Eof())
				dbSelectArea("ZA9")
				ZA9->(dbGoto(QZA9->RECNO))
			Else //Inclui novo registro
				Reclock("ZA9",.T.)
				ZA9->ZA9_FILIAL := xFilial("ZA9")
				ZA9->ZA9_PREFIX	:= oModel:getModel("CABECZA8"):getValue("ZA8_PREFIX")
				ZA9->ZA9_NUM   	:= oModel:getModel("CABECZA8"):getValue("ZA8_NUM")
				ZA9->ZA9_PARCEL	:= oModel:getModel("CABECZA8"):getValue("ZA8_PARCEL")
				ZA9->ZA9_CLIFOR	:= oModel:getModel("CABECZA8"):getValue("ZA8_CLIFOR")
				ZA9->ZA9_LOJA  	:= oModel:getModel("CABECZA8"):getValue("ZA8_LOJA")
				ZA9->ZA9_NATURE	:= oModel:getModel("GRIDZA8"):getValue("ZA8_NATURE")
				ZA9->ZA9_VALOR 	:= oModel:getModel("GRIDZA8"):getValue("ZA8_VALNAT")
				ZA9->ZA9_PERC	:= 100
				ZA9->ZA9_VALCC	:= oModel:getModel("GRIDZA8"):getValue("ZA8_VALNAT")
				MsUnlock()
			Endif
			dbSelectArea("ZA9")
			nRet := FWExecView("Rateio Centro de Custo", "RPFA004", MODEL_OPERATION_UPDATE,,{||.T.},,5,,)
			QZA9->(dbCloseArea())
			
			If cValtochar(nRet) == "1" //Cancelado
				oModel:GetModel("GRIDZA8"):LoadValue("ZA8_RATEIC","2")
				fRatCCPF(oModel)
			Endif
		Else //Não tem rateio
			//Verifica se existe lançamento para a natureza
			cQuery := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("ZA9") + " ZA9 "
			cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
			cQuery += "ZA9_FILIAL = '" + xFilial("ZA9") + "' AND "
			cQuery += "ZA9_PREFIX = '" + oModel:getModel("CABECZA8"):getValue("ZA8_PREFIX") + "' AND "
			cQuery += "ZA9_NUM= '" + oModel:getModel("CABECZA8"):getValue("ZA8_NUM") + "' AND "
			cQuery += "ZA9_PARCEL = '" + oModel:getModel("CABECZA8"):getValue("ZA8_PARCEL") + "' AND "
			cQuery += "ZA9_CLIFOR = '" + oModel:getModel("CABECZA8"):getValue("ZA8_CLIFOR") + "' AND "
			cQuery += "ZA9_LOJA = '" + oModel:getModel("CABECZA8"):getValue("ZA8_LOJA") + "'  AND "
			cQuery += "ZA9_NATURE = '" + oModel:getModel("GRIDZA8"):getValue("ZA8_NATURE") + "' "

			TcQuery cQuery new Alias QZA9

			while QZA9->(!Eof())
				dbSelectArea("ZA9")
				ZA9->(dbGoto(QZA9->RECNO))
				Reclock("ZA9",.F.)
				ZA9->(dbDelete())
				MsUnlock()

				QZA9->(dbSkip())
			Enddo
			QZA9->(dbCloseArea())
		Endif
	Endif
	RestArea(aArea)
Return cRet

Static Function fValiddAcao(oModelGrid, nLinha, cAcao, cCampo)
	Local lRet   	 := .T.
	Local oModel     := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()

	If alltrim(cAcao) $ "UNDELETE/DELETE" .and.;
	(nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT) //Apaga rateio do Centro de Custo
		cQuery := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("ZA9") + " ZA9 "
		cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
		cQuery += "ZA9_FILIAL = '" + xFilial("ZA9") + "' AND "
		cQuery += "ZA9_PREFIX = '" + oModel:getModel("CABECZA8"):getValue("ZA8_PREFIX") + "' AND "
		cQuery += "ZA9_NUM= '" + oModel:getModel("CABECZA8"):getValue("ZA8_NUM") + "' AND "
		cQuery += "ZA9_PARCEL = '" + oModel:getModel("CABECZA8"):getValue("ZA8_PARCEL") + "' AND "
		cQuery += "ZA9_CLIFOR = '" + oModel:getModel("CABECZA8"):getValue("ZA8_CLIFOR") + "' AND "
		cQuery += "ZA9_LOJA = '" + oModel:getModel("CABECZA8"):getValue("ZA8_LOJA") + "'  AND "
		cQuery += "ZA9_NATURE = '" + oModel:getModel("GRIDZA8"):getValue("ZA8_NATURE") + "' "

		TcQuery cQuery new Alias QZA9

		while QZA9->(!Eof())
			dbSelectArea("ZA9")
			ZA9->(dbGoto(QZA9->RECNO))
			Reclock("ZA9",.F.)
			ZA9->(dbDelete())
			MsUnlock()

			QZA9->(dbSkip())
		Enddo
		QZA9->(dbCloseArea())
	Endif

Return lRet

Static Function fLoadZA8(oModel)
	Local nValBkp	:= ""
	Local nLin		:= 0
	If oModel:getOperation() == MODEL_OPERATION_UPDATE
		For nLin:=1 to oModel:GetModel("GRIDZA8"):length()
			oModel:GetModel("GRIDZA8"):GoLine(nLin)
			If oModel:GetModel("GRIDZA8"):IsDeleted(nLin)
				Loop
			EndIf
			nValBkp:= oModel:GetModel("GRIDZA8"):getValue("ZA8_NATURE",nLin)
			oModel:GetModel("GRIDZA8"):setValue("ZA8_NATURE",nValBkp)
			exit
		Next	
	Endif
Return