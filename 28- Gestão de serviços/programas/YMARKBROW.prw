#Include 'Protheus.ch'
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "DBINFO.CH"


User Function yTSTYMARKBROW
	Local nCont
	Local oMarkBrow
	RPCSETENV("01","0101")
	__cInterNet	:= nil
	oMarkBrow	:= YMARKBROW():new()
	//VIA QUERY
	oMarkBrow:cTitulo	:= "MarkBrowse via Query"
	oMarkBrow:Query("SELECT TOP 10 B1_COD AS COD,B1_DESC,B1_LOCPAD,B1_UREV FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.D_E_L_E_T_=' '",{{"B1_UREV","D",8,0}})
	oMarkBrow:Browse()
	oMarkBrow:oBrowse:AddButton('Atualizar Dados',{|| self:UpdateDados()}, , 9, 0)
	aDados	:= {}
	For nCont:=1 to 10
		AADD(aDados,"Teste "+cValToChar(nCont))
	Next
	oMarkBrow:oBrowse:AddButton('Teste',{|| Processa({|| ProcRegua(Len(aDados)),IncProc("Processando..."),aEval(aDados,{|x| IncProc(x),ProcessMessage(),Sleep(1500) }) },"Aguarde...")  }, , 9, 0)

	oMarkBrow:Activate()
	If oMarkBrow:lOk	//Apertou o botão de confirmar
		For nCont:=1 to Len(oMarkBrow:aDados)
			If oMarkBrow:GetCampo("#",nCont)	//Campo Foi Marcado
				Alert("Produto Marcado: "+oMarkBrow:GetCampo("B1_DESC",nCont))
			EndIf
		Next
	EndIf
	//VIA ARRAY
	oMarkBrow	:= YMARKBROW():new()
	oMarkBrow:cTitulo	:= "MarkBrowse via Array"
	AADD(oMarkBrow:aCampos,{"#","L",1,0})	//Flag, sempre deve ser a primeira opção
	AADD(oMarkBrow:aCampos,{"Cod","C",10,0})
	AADD(oMarkBrow:aCampos,{"B1_DESC"})
	AADD(oMarkBrow:aCampos,{"B1_LOCPAD"})
	AADD(oMarkBrow:aCampos,{"B1_UREV"})
	AADD(oMarkBrow:aDados,{.F.,"0001","Produto Teste","01",CTOD("09/04/2014")})
	AADD(oMarkBrow:aDados,{.F.,"0002","Produto Teste 2","01",CTOD("")})
	oMarkBrow:Browse()
	oMarkBrow:Activate()
	If oMarkBrow:lOk
		For nCont:=1 to Len(oMarkBrow:aDados)
			If oMarkBrow:GetCampo("#",nCont)	//Campo Foi Marcado
				Alert("Produto Marcado: "+oMarkBrow:GetCampo("B1_DESC",nCont))
			EndIf
		Next
	EndIf
Return

Static oObjeto

Class YMARKBROW
	DATA aCampos
	DATA aDados
	DATA cQuery
	DATA oBrowse
	DATA aTipos
	DATA oDlg
	DATA cTitulo
	DATA lOk
	Method New() CONSTRUCTOR
	Method Query()
	Method GetCampo()
	Method Browse()
	Method InvertaDados()
	Method UpdateDados()
	Method Activate()
EndClass

Method New() Class YMARKBROW
	If TYPE("__CUSERID ")=="U"
		Public __CUSERID := ""
	EndIf
	::cTitulo	:= "Selecionar"
	::oBrowse	:= FWFormBrowse():New()
	::aCampos	:= {}
	::aDados	:= {}
	::aTipos	:= {}
	::cQuery	:= ""
	::lOk		:= .F.
Return self

Method Query(cQuery,aTipos) Class YMARKBROW
	Local nCont,nTam,nQuanCol
	Local cAliasQry
	If !Empty(cQuery)
		::cQuery	:= cQuery
	EndIf
	If !Empty(aTipos)
		::aTipos	:= aTipos
	EndIf

	cAliasQry	:= MPSysOpenQuery(::cQuery,,::aTipos)
	nTam	:= 0
	nQuanCol	:= (cAliasQry)->(DBInfo(DBI_FCOUNT))
	AADD(::aCampos,{"#","L",1,0})
	For nCont:=1 to (cAliasQry)->(DBInfo(DBI_FCOUNT))
		AADD(::aCampos,{;
						(cAliasQry)->(DBFIELDINFO(DBS_NAME,nCont));
						,(cAliasQry)->(DBFIELDINFO(DBS_TYPE,nCont));
						,(cAliasQry)->(DBFIELDINFO(DBS_LEN,nCont));
						,(cAliasQry)->(DBFIELDINFO(DBS_DEC,nCont));
						})
	Next
	While (cAliasQry)->(!EOF())
		AADD(::aDados,Array(nQuanCol+1))
		nTam++
		::aDados[nTam][1]	:= .F.
		For nCont:=1 to (cAliasQry)->(DBInfo(DBI_FCOUNT))
			::aDados[nTam][nCont+1]	:= (cAliasQry)->(&(DBFIELDINFO(DBS_NAME,nCont)))
		Next
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return

Method UpdateDados() Class YMARKBROW
	Local nQuanCol
	Local nCont
	Local cAliasQry
	::aDados	:= {}
	cAliasQry	:= MPSysOpenQuery(::cQuery,,::aTipos)
	nTam	:= 0
	nQuanCol	:= (cAliasQry)->(DBInfo(DBI_FCOUNT))
	While (cAliasQry)->(!EOF())
		AADD(::aDados,Array(nQuanCol+1))
		nTam++
		::aDados[nTam][1]	:= .F.
		For nCont:=1 to (cAliasQry)->(DBInfo(DBI_FCOUNT))
			::aDados[nTam][nCont+1]	:= (cAliasQry)->(&(DBFIELDINFO(DBS_NAME,nCont)))
		Next
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	::oBrowse:Refresh()
	::oBrowse:GoTop()
Return

Method GetCampo(cCampo,nCont) Class YMARKBROW
	Local xRet
	Local nPos	:= aScan(::aCampos,{|x| UPPER(x[1])==UPPER(cCampo)})
	If nPos>0
		xRet	:= ::aDados[nCont][nPos]
	EndIf
Return xRet

//Static Function Desativar(oObj)
//Alert(VarInfo("oObj",oObj))
//Return

Method Browse()	Class YMARKBROW
	Local nCont
	Local aCoors
	Local bBlockClique
	Local bBloco	:= {|| lOk:=.T.,self:oDlg:End() }
	aCoors			:= FwGetDialogSize( GetWndDefault() )
	If aCoors[3]-aCoors[1]<600 .OR. aCoors[4]-aCoors[2]<800
		aCoors	:= {0,0,600,800}
	EndIf
	::oDlg			:= MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],::cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	::oBrowse:ForceQuitButton(.T.)
	::oBrowse:AddButton('Confirmar'		,bBloco, , 9, 0)
	::oBrowse:AddButton('Inverter Seleção'		,{||::InvertaDados()}, , 9, 0)
	::oBrowse:SetDataArray()
	::oBrowse:SetArray(::aDados)
	bBlockClique	:= {|| ::aDados[::oBrowse:At()][1]:= !(::aDados[::oBrowse:At()][1]) }
	::oBrowse:SetDoubleClick(bBlockClique)
	::oBrowse:AddMarkColumns(;
		{||If(::aDados[::oBrowse:At()][1],"LBTICK","LBNO")};
		,bBlockClique;
		,{||::InvertaDados()};
		)
	For nCont:=2 to Len(::aCampos)

		oColumn := FWBrwColumn():New()
		If Len(::aCampos[nCont])>5 .AND. ValType(::aCampos[nCont][6])=="C"
			oColumn:SetData(&("{|o| Eval({|x,y|"+::aCampos[nCont][6]+"},o:oData:aArray[o:At()],"+cValToChar(nCont)+")}") )
		Else
			oColumn:SetData(&("{|o| o:oData:aArray[o:At()]["+cValToChar(nCont)+"]}") )
		EndIf
		oColumn:SetTitle(GetCampo(::aCampos[nCont],"X3_TITULO"))
		oColumn:SetComment(GetCampo(::aCampos[nCont],"X3_DESCRIC"))
		oColumn:SetSize(GetCampo(::aCampos[nCont],"X3_TAMANHO"))
		oColumn:SetDecimal(GetCampo(::aCampos[nCont],"X3_DECIMAL"))
		oColumn:SetType(GetCampo(::aCampos[nCont],"X3_TIPO"))
		oColumn:SetPicture(GetCampo(::aCampos[nCont],"X3_PICTURE"))
		oColumn:SetDoubleClick(bBlockClique)

		::oBrowse:SetColumns({oColumn})
		oColumn := nil
	Next
	::oBrowse:SetOwner(::oDlg)
Return

Method Activate() Class YMARKBROW
	Private lOk	:= .F.
	::oBrowse:lUpdVisibRw	:= .F.
	::oBrowse:Activate()
	::oDlg:Activate(,,,.T.,{|| ::aDados:=aClone(::oBrowse:oData:aArray),::oDlg:FreeChildren() },, )
	::lOk	:= lOk
	::oBrowse:DeActivate(.F.)
	::oBrowse := nil
Return

Method InvertaDados() Class YMARKBROW
	Local nCont
	For nCont:=1 to Len(::oBrowse:oData:aArray)
		::oBrowse:oData:aArray[nCont][1]:= !::oBrowse:oData:aArray[nCont][1]
	Next
	::oBrowse:Refresh()
	::oBrowse:GoTop()
Return

Static Function GetCampo(aCampo,cSX3)
	Local xRet	:=	GetSx3Cache(aCampo[1],cSX3)
	If ValType(xRet)=="U" .AND. Len(aCampo)<4
		UserException("Campo "+aCampo[1]+" não encontrado no SX3, necessario informar o Array com dados. ")
	ElseIf ValType(xRet)=="U"
		If cSX3=="X3_TITULO"
			xRet	:= aCampo[1]
		ElseIf cSX3=="X3_DESCRIC"
			xRet	:= aCampo[1]
		ElseIf cSX3=="X3_TIPO"
			xRet	:= aCampo[2]
		ElseIf cSX3=="X3_PICTURE"
			If Len(aCampo)>=5
				xRet	:= aCampo[5]
			Else
				xRet	:= ""
			EndIF
		ElseIf cSX3=="X3_TAMANHO"
			xRet	:= aCampo[3]
		ElseIf cSX3=="X3_DECIMAL"
			xRet	:= aCampo[4]
		EndIf
	EndIf
Return xRet
