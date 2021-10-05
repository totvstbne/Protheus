#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDEF.ch'

/*/{Protheus.doc} RPFA005
Aprovação dos Pedidos Financeiros
@author Diogo
@since 18/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA005()
	Local aRetOpc	:= {}
	Local aPergs	:= {}
	Local cCCs		:= ""
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Private oDlg1		:= nil
	Private oMark1	:= nil
	Private cCadastro := "Aprovação dos Pedidos"
	oDlg1 := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],'Aprovação Pedido Financeiro',,,.F.,,,,,,.T.,,,.T. )
	aRotina := { {"Aprovar","u_fAprovPF()",0,3},;
	{"Rejeitar","u_fRejeiPF()",0,4},;
	{"Visualizar","u_fVisuPF()",0,2}}

	oMark1 := FWMarkBrowse():New()
	oMark1:SetAlias('ZA7')

	cQuery :="SELECT DISTINCT(ZA5_CC) ZA5_CC FROM "+RetSqlName("ZA5")+ " ZA5 "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="ZA5_FILIAL = '"+xFilial("ZA5")+"' AND "
	cQuery +="ZA5_CODAPV = '"+RetCodUsr()+"' "
	TcQuery cQuery new Alias QZA5

	while QZA5->(!Eof())
		cCCs += alltrim(QZA5->ZA5_CC)
		QZA5->(dbSkip())
		If QZA5->(!Eof())
			cCCs += "/"
		Endif
	Enddo
	QZA5->(dbCloseArea())

	cFiltro := "ZA7_STATUS = 'P' .AND. alltrim(ZA7_CUSTO) $ '"+cCCs+"' "
	oMark1:DisableDetails()
	oMark1:SetDescription('Aprovação dos Pedidos')
	oMark1:SetFilterDefault(cFiltro)
	///oMark1:SetUseFilter(.T.)
	oMark1:Activate(oDlg1)
	oDlg1:Activate(,,,.T.)
Return

/*/{Protheus.doc} fAprovPF
Rotina de Aprovação do Pedido Financeiro
@author Diogo
@since 18/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fAprovPF
	Local aCab		:= {}
	Local aRatEvEz	:= {}
	Local aRatEz	:= {}
	Local aAuxEz	:= {}
	Local aAuxEv	:= {}
	Local aDadosBco	:= {}
	Local lPABco	:= .F.
	Local aArea		:= getArea()
	aadd( aCab ,{"E2_FILIAL" 	, ZA7->ZA7_FILIAL	, Nil })
	aadd( aCab ,{"E2_PREFIXO" 	, ZA7->ZA7_PREFIX	, Nil })
	aadd( aCab ,{"E2_NUM" 		, ZA7->ZA7_NUM		, Nil })
	aadd( aCab ,{"E2_PARCELA" 	, ZA7->ZA7_PARCEL 	, Nil })

	If alltrim(ZA7->ZA7_TIPO) == "PA"
		Pergunte("FIN050",.F.)
		GravaPar("05",val(ZA7->ZA7_CHQADT),"FIN050")
		GravaPar("09",val(ZA7->ZA7_MOVCHQ),"FIN050")
		dDataBase	:= ZA7->ZA7_VENCTO
		_aArea	:= GetArea()
		cHistPA	:= "Pagamento Antecipado"
		mv_par05:= val(ZA7->ZA7_CHQADT)
		mv_par09:= val(ZA7->ZA7_MOVCHQ)
		//Pergunte("FIN050",.F.)
		RestArea(_aArea)

		If (mv_par05 = 2 .and. mv_par09 = 1 ) .or. ;
		(mv_par05 = 1 .and. mv_par09 = 1 ) //Não tem cheque e tem movimento bancario
			aadd( aCab ,{"E2_EMISSAO" 		, ZA7->ZA7_VENCTO		, Nil })
		Else
			aadd( aCab ,{"E2_EMISSAO" 		, ZA7->ZA7_EMISSA		, Nil })
		Endif

		If mv_par05 <> 2 .or. mv_par09 <> 2
			aadd( aCab ,{"AUTBANCO" 		, ZA7->ZA7_BANCO		, Nil })
			aadd( aCab ,{"AUTAGENCIA" 		, ZA7->ZA7_AGENCI		, Nil })
			aadd( aCab ,{"AUTCONTA" 		, ZA7->ZA7_CONTA		, Nil })
			aadd( aCab, {"AUTHIST"     		, ZA7->ZA7_HISTPA	    , Nil})
			aadd( aCab, {"AUTBENEF"     	, ZA7->ZA7_BENEF	    , Nil})
			//aadd( aCab ,{"E2_EMISSAO" 		, ZA7->ZA7_VENCTO		, Nil })
			If cvaltochar(mv_par05) == "1"
				aadd( aCab ,{"AUTCHEQUE" 	, ZA7->ZA7_NUMCHQ		, Nil })
			Else
				aadd( aCab ,{"AUTCHEQUE" 	, ""					, Nil })
			Endif
		Endif

		aDadosBco:= {	ZA7->ZA7_BANCO,; 	//1
		ZA7->ZA7_AGENCI,;	//2
		ZA7->ZA7_CONTA,; 	//3
		ZA7->ZA7_NUMCHQ,;	//4
		,;					//5
		,;					//6
		ZA7->ZA7_MOVCHQ == "1";	//7 Mov sem cheque
		}
		If mv_par05 = 2 .and. mv_par09 = 2 //PA sem movimentação
			aadd( aCab ,{"E2_TIPO" 		, "NF"						, Nil })
			lPABco		:= .T.
			aDadosBco	:= {}
		Else
			aadd( aCab ,{"E2_TIPO" 		, ZA7->ZA7_TIPO				, Nil })
		Endif

	Else
		aadd( aCab ,{"E2_EMISSAO" 	, ZA7->ZA7_EMISSA			, Nil })
		aadd( aCab ,{"E2_TIPO" 		, ZA7->ZA7_TIPO				, Nil })
	Endif

	aadd( aCab ,{"E2_FORNECE" 	, ZA7->ZA7_FORNEC			, Nil })
	aadd( aCab ,{"E2_LOJA" 		, ZA7->ZA7_LOJA				, Nil })
	aadd( aCab ,{"E2_NATUREZ" 	, ZA7->ZA7_NATURE			, Nil })
	aadd( aCab ,{"E2_VENCTO" 	, ZA7->ZA7_VENCTO			, Nil })
	aadd( aCab ,{"E2_VENCREA" 	, ZA7->ZA7_VENCRE			, Nil })
	aadd( aCab ,{"E2_VALOR" 	, ZA7->ZA7_VALOR			, Nil })
	aadd( aCab ,{"E2_HIST" 		, ZA7->ZA7_HIST				, Nil })

	aadd( aCab ,{"E2_CODBAR" 	, ZA7->ZA7_CODBAR	 		, Nil })
	aadd( aCab ,{"E2_FILORIG"	, cFilAnt	 				, Nil })
	aadd( aCab ,{"E2_MULTNAT" 	, IIF(ZA7->ZA7_MULTNA='S','1','2'), Nil })
	aadd( aCab ,{"E2_ORIGEM" 	, 'RPFA001'					, Nil })
	aadd( aCab ,{"E2_CCD"  		, ZA7->ZA7_CUSTO		 	, Nil })
	aadd( aCab ,{"E2_CCUSTO"	, ZA7->ZA7_CUSTO		 	, Nil })
	//aadd( aCab ,{"E2_CODAPRO"	, alltrim(SUPERGETMV("MV_FINAP01",.T.,"000001")), Nil })

	If ZA7->ZA7_MULTNA='S'
		dbSelectArea("SEV") // Cadastro de Multiplas Naturezas
		dbSelectArea("SEZ") // Cadastro de Rateio Por Centro de Custo
		dbselectArea("ZA8") // Cadatro de Multiplas Naturezas

		cQuery :="SELECT * FROM "+RetSqlName("ZA8")+ " ZA8 "
		cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
		cQuery +="ZA8_FILIAL = '"+xFilial("ZA8")+"' AND "
		cQuery +="ZA8_PREFIX = '"+ZA7->ZA7_PREFIX+"' AND "
		cQuery +="ZA8_NUM= '"+ZA7->ZA7_NUM+"' AND "
		cQuery +="ZA8_PARCEL = '"+ZA7->ZA7_PARCEL+"' AND "
		cQuery +="ZA8_CLIFOR = '"+ZA7->ZA7_FORNEC+"' AND "
		cQuery +="ZA8_LOJA = '"+ZA7->ZA7_LOJA+"'  "
		TcQuery cQuery new Alias QMULTNAT

		while QMULTNAT->(!Eof())
			aAuxEv:= {}
			aRatEz:= {}
			aadd( aAuxEv ,{"EV_FILIAL" ,  xFilial("SEV")						, Nil })
			aadd( aAuxEv ,{"EV_NATUREZ" , QMULTNAT->ZA8_NATURE					, Nil })
			aadd( aAuxEv ,{"EV_VALOR" 	, QMULTNAT->ZA8_VALNAT					, Nil })
			aadd( aAuxEv ,{"EV_PERC" 	, QMULTNAT->ZA8_PERC					, Nil })
			If QMULTNAT->ZA8_RATEIC = '1' //Tem rateio centro de custo
				aadd( aAuxEv ,{"EV_RATEICC" , "1"							    , Nil })
				//Busca rateio CC
				cQuery :="SELECT * FROM "+RetSqlName("ZA9")+ " ZA9 "
				cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
				cQuery +="ZA9_FILIAL = '"+QMULTNAT->ZA8_FILIAL+"' AND "
				cQuery +="ZA9_NATURE= '"+QMULTNAT->ZA8_NATURE+"' AND "
				cQuery +="ZA9_PREFIX = '"+ZA7->ZA7_PREFIX+"' AND "
				cQuery +="ZA9_NUM= '"+ZA7->ZA7_NUM+"' AND "
				cQuery +="ZA9_PARCEL = '"+ZA7->ZA7_PARCEL+"' AND "
				cQuery +="ZA9_CLIFOR = '"+ZA7->ZA7_FORNEC+"' AND "
				cQuery +="ZA9_LOJA = '"+ZA7->ZA7_LOJA+"'  "
				TcQuery cQuery new Alias QZA9
				while QZA9->(!Eof())
					aAuxEz:={}
					aadd( aAuxEz ,{"EZ_FILIAL"	, xFilial("SEZ")	, Nil })//centro de custo da natureza
					aadd( aAuxEz ,{"EZ_CCUSTO"	, QZA9->ZA9_CUSTO	, Nil })//centro de custo da natureza
					aadd( aAuxEz ,{"EZ_VALOR"	, QZA9->ZA9_VALCC	, Nil })//valor do rateio neste centro de custo
					aadd( aAuxEz ,{"EZ_ITEMCTA"	, QZA9->ZA9_ITEMCC	, Nil })//valor do rateio no item contabil
					aadd(aRatEz,aAuxEz)
					//aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
					QZA9->(dbSkip())
				Enddo
				QZA9->(dbCloseArea())
			Endif

			If len(aRatEz) > 0
				aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
			Endif
			aAdd(aRatEvEz,aAuxEv)//adicionando a natureza ao rateio de multiplas naturezas
			QMULTNAT->(dbSkip())
		Enddo
		QMULTNAT->(dbCloseArea())

		aAdd(aCab,{"AUTRATEEV",ARatEvEz,Nil})//adicionando ao vetor aCab o vetor do rateio
	Endif

	lMSErroAuto := .F.
	dbSelectArea("SE2")
	dbSetOrder(1)
	MSExecAuto({|x,y,z,a,b| Fina050(x,y,z,a,b)},aCab,,3,,aDadosBco)

	If lMSErroAuto
		MostraErro()
	Else
		If lPABco
			Reclock("SE2",.F.)
			SE2->E2_TIPO := "PA"
			MsUnlock()

			Reclock("FK7",.F.)
			FK7->FK7_CHAVE := strtran(FK7->FK7_CHAVE,'|NF |','|PA |')
			MsUnlock()

			cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SEV")+" SEV "
			cQuery+= "WHERE SEV.D_E_L_E_T_ = ' ' AND "
			cQuery+= "EV_NUM = '"+SE2->E2_NUM+"' AND "
			cQuery+= "EV_PARCELA= '"+SE2->E2_PARCELA+"' AND "
			cQuery+= "EV_FILIAL= '"+xFilial("SEV")+"' "
			tcQuery cQuery new Alias QRSEV
			while QRSEV->(!Eof())
				SEV->(dbGoto(QRSEV->RECNO))
				Reclock("SEV",.F.)
				SEV->EV_TIPO := "PA"
				MsUnlock()
				QRSEV->(dbSkip())
			Enddo
			QRSEV->(dbCloseArea())

			cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SEZ")+" SEZ "
			cQuery+= "WHERE SEZ.D_E_L_E_T_ = ' ' AND "
			cQuery+= "EZ_NUM = '"+SE2->E2_NUM+"' AND "
			cQuery+= "EZ_PARCELA= '"+SE2->E2_PARCELA+"' AND "
			cQuery+= "EZ_FILIAL= '"+xFilial("SEZ")+"' "
			tcQuery cQuery new Alias QRSEZ
			while QRSEZ->(!Eof())
				SEZ->(dbGoto(QRSEZ->RECNO))
				Reclock("SEZ",.F.)
				SEZ->EZ_TIPO := "PA"
				MsUnlock()
				QRSEZ->(dbSkip())
			Enddo
			QRSEZ->(dbCloseArea())
		Endif
		RecLock("ZA7",.F.)
		ZA7->ZA7_STATUS	:= "A"
		ZA7->ZA7_CODLIB	:= retCodUsr()
		ZA7->ZA7_USELIB	:= usrRetName(RETCODUSR())
		ZA7->ZA7_DTLIB	:= Date()
		ZA7->ZA7_HRLIB  := time()
		ZA7->ZA7_DESCRI	:= Alltrim(ZA7->ZA7_DESCRI) +chr(13)+chr(10)+ ' Aprovação: '+dToc(Date())+;
		' as '+time()+' por '+alltrim(UsrRetName(RetCodUsr()))+', motivo: '+Alltrim(cObsAp)
		ZA7->(MsUnLock())

		If alltrim(ZA7->ZA7_TIPO) == 'PA' //.and. cValtochar(ZA7->ZA7_CHQADT) == '2' .and. cValtochar(ZA7->ZA7_MOVCHQ) == '2'
			cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SE5")+" SE5 "
			cQuery+= "WHERE SE5.D_E_L_E_T_ = ' ' AND "
			cQuery+= "E5_FILIAL = '"+xFilial("SE5")+"' AND "
			cQuery+= "E5_NUMERO = '"+ZA7->ZA7_NUM+"' AND  "
			cQuery+= "E5_PARCELA= '"+ZA7->ZA7_PARCEL+"' AND  "
			cQuery+= "E5_TIPO = 'PA' "
			tcQuery cQuery new Alias QRSE5
			while QRSE5->(!Eof())
				SE5->(dbGoto(QRSE5->RECNO))
				Reclock("SE5",.F.)
				SE5->E5_BENEF := ZA7->ZA7_BENEF
				MsUnlock()
				QRSE5->(dbSkip())
			Enddo
			QRSE5->(dbCloseArea())
			//Atualiza SEF
			cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SEF")+" SEF "
			cQuery+= "WHERE SEF.D_E_L_E_T_ = ' ' AND "
			cQuery+= "EF_FILIAL = '"+xFilial("SEF")+"' AND "
			cQuery+= "EF_TITULO = '"+ZA7->ZA7_NUM+"' AND  "
			cQuery+= "EF_PARCELA= '"+ZA7->ZA7_PARCEL+"' AND  "
			cQuery+= "EF_TIPO = 'PA' "
			tcQuery cQuery new Alias QRSEF
			while QRSEF->(!Eof())
				SEF->(dbGoto(QRSEF->RECNO))
				Reclock("SEF",.F.)
				SEF->EF_BENEF := ZA7->ZA7_BENEF
				MsUnlock()
				QRSEF->(dbSkip())
			Enddo
			QRSEF->(dbCloseArea())
		Endif

		//Verifica se existe anexo, caso SIM, replica para a SE2
		cQuery :="SELECT AC9_CODOBJ FROM "+RetSqlName("AC9")+ " AC9 "
		cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
		cQuery +="AC9_FILIAL = '"+xFilial("AC9")+"' AND "
		cQuery +="AC9_ENTIDA = 'ZA7' AND "
		cQuery +="AC9_CODENT = '"+SE2->E2_NUM+"' "
		TcQuery cQuery new Alias QAC9

		while QAC9->(!Eof())
			Reclock("AC9",.T.)
			AC9->AC9_FILIAL	:=	xFilial("AC9")
			AC9->AC9_FILENT	:= 	xFilial("SE2")
			AC9->AC9_ENTIDA	:=	"SE2"
			AC9->AC9_CODENT	:=	SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			AC9->AC9_CODOBJ	:=	QAC9->AC9_CODOBJ
			MsUnlock()
			QAC9->(dbSkip())
		Enddo
		QAC9->(dbCloseArea())
		//msgInfo("Pedido Financeiro aprovado com sucesso")
	Endif
	RestArea(aArea)
Return

/*/{Protheus.doc} fRejeiPF
Rejeição do Pedido Financeiro
@author Diogo
@since 18/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fRejeiPF(lProcLote)
	Local lRet		:= .T.
	Local aRetOpc 	:= {}
	Local aPergs  	:= {}
	Local cDescMot	:= ""

	If SCR->CR_TIPO  = "06"
		Return
	Endif

	If SCR->CR_TIPO <> "PF"
		alert("Rejeição apenas para Pedidos Financeiros")
		Return
	Endif
	If SCR->CR_STATUS <> "02" //Pendente de aprovação
		lRet := A097LibVal("MATA094")
	Endif
	dbSelectArea("ZA7")
	ZA7->(dbSetOrder(3))
	If !(ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM))))
		alert("Pedido financeiro não localizado")
		Return
	Endif
	If !lRet
		Return
	Endif

	If lRet
		If !lProcLote
			If !(msgYesNo("Confirma a rejeição do Pedido Financeiro?"))
				Return
			Endif
			aAdd( aPergs ,{1,"Motivo Rejeição", space(100)	,"@!",'.T.','','.T.',100,.T.})
			If ParamBox(aPergs,"Motivo",aRetOpc,,,,,,,"_RFA01A",.F.,.F.)
				cDescMot:= aRetOpc[1]
			Endif
		Else
			cDescMot:= "Rejeição em lote"
		Endif

		RecLock("ZA7",.F.)
		ZA7->ZA7_STATUS := 'R'
		ZA7->ZA7_DESCRI	:= Alltrim(ZA7->ZA7_DESCRI) +chr(13)+chr(10)+ ' Pedido financeiro rejeitado em '+dToc(Date())+;
		' as '+TIME()+' por '+alltrim(USRRETNAME(RETCODUSR()))+', motivo: '+Alltrim(cDescMot)
		ZA7->ZA7_USEREJ	:= UsrRetName(RetCodUsr())
		ZA7->ZA7_DTREJ  := date()
		ZA7->ZA7_HRREJ  := time()
		MsUnlock()
		Reclock("SCR",.F.)
		SCR->CR_STATUS	:= "06"
		SCR->CR_DATALIB	:= date()
		SCR->CR_USERLIB	:= retcodusr()
		msUnlock()
		//Atualiza para os próximos níveis para rejeição
		cUpd:= "UPDATE "+RetSqlName("SCR")+" SET CR_STATUS = '06', " 
		cUpd+= "CR_DATALIB = '"+dTos(date())+"', "
		cUpd+= "CR_USERLIB = '"+retcodusr()+"' "
		cUpd+= "WHERE CR_NUM = '"+SCR->CR_NUM+"' AND CR_TIPO = 'PF' AND CR_FILIAL = '"+SCR->CR_FILIAL+"' "
		cUpd+= "AND CR_STATUS IN ('01','02') " //Bloqueado ou aguardando liberação
		tcSqlExec(cUpd)
		tcRefresh(RetSqlName("SCR"))
		
		If !lProcLote
			msgInfo("Pedido Financeiro rejeitado com sucesso")
		Endif
	Endif
Return

/*/{Protheus.doc} fVisuPF
Visualização do Pedido Financeiro
@author Diogo
@since 18/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fVisuPF()
	If funname() = "MATA094"
		dbSelectArea("ZA7")
		ZA7->(dbSetOrder(3))
		If !(ZA7->(dbSeek(xFilial("ZA7")+alltrim(SCR->CR_NUM))))
			alert("Pedido financeiro não localizado")
			Return
		Endif
	Endif
	FWExecView ("Visualizar", "RPFA001", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
Return

Static Function GravaPar(cOrdem,cDado,cGrupo)
	Local cGrupo := PADR(cGrupo,Len(SX1->X1_GRUPO))
	If SX1->(dbSeek(cGrupo+cOrdem))
		RecLock("SX1",.F.)
		If SX1->X1_GSC=="C"
			SX1->X1_PRESEL	:= cDado
		Else
			SX1->X1_CNT01	:= cDado
		EndIf
		MsUnlock()
	EndIf
	If select("profile")==0
		dbUseArea(.T.,__LOCALDRIVER,"\profile\profile.usr", "profile", .T., .T.)
	EndIf
	DbSelectArea("profile")
	DbSetOrder(1)	//P_NAME+P_PROG+P_TASK+P_TYPE
	If DbSeek(PADR(__cUserID,LEN(P_NAME))+PADR(cGrupo,LEN(P_PROG))+PADR("PERGUNTE",LEN(P_TASK))+PADR("MV_PAR",LEN(P_TYPE)))
		RecLock("profile",.f.)
		DbDelete()	//Obriga a usar o SX1
		MsUnlock()
	EndIf
	DbCloseArea()
Return

/*/{Protheus.doc} fAprovAlc
Aprovação da alçada
@author diogo
@since 27/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function fAprovAlc
	Local aArea:= getArea()
	If alltrim(SCR->CR_TIPO) = 'PF' //Sendo pedido financeiro, abre tela para visualização do PF
		u_fVisuPF()
	Elseif alltrim(SCR->CR_TIPO) = 'PC' //Sendo pedido de compras, abre tela para visualização
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7")+alltrim(SCR->CR_NUM)))
		Mata120(1,,,2)
	Endif
	RestArea(aArea)
	A94ExLiber()
Return