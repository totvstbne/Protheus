#INCLUDE "PROTHEUS.CH"
#INCLUDE "pcoa310.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"

//	#########################################################################################
//	Projeto: SERVNAC
//	Modulo : PCO
//	Fonte  : PETPCO01.prw
//	---------+-------------------+-----------------------------------------------------------
//	Descricao Importa dados do Excel
//	---------+-------------------+-----------------------------------------------------------
//	#########################################################################################
Static lFWCodFil := FindFunction("FWCodFil")
Static lPLogIni  := FindFunction('PROCLOGINI')
Static lPLogAtu  := FindFunction('PROCLOGATU')
Static __lBlind  := IsBlind()
Static _lFKInUse
Static _lAuto    := .F.
Static _aRetPar1 := {}
Static _aRetPar2 := {}


Static __cTmpRec := NIL     //tabela temporaria contendo recnos ja processados
Static __cProcZero := NIL   //procedure strzero
Static __cProcSoma1 := NIL  //procedure soma1
Static __cProcFil   := nil  //procedure xfilial
Static __cProcDel := NIL    //procedure para exclusao dos movimentos or?mentarios no periodo
Static __cProcExec := NIL   //procedure pai quando processo/item  executado por procedure
Static __cProcID := NIL   //procedure para pegar proximo item do lan?mento
Static __cProcLote := NIL   //procedure para pegar proximo lote
Static __lProcAKDLOTE := NIL   //flag se criou a procedure para pegar proximo lote

User Function PETPCO01
	Local	_aArea		:= GetArea()
	Local	_cArquivo	:= Space(100)
	Local	_lOk		:= .t.
	Local	_cErro		:= ""
	Local	_cMascara	:= ""
	Local	_aNivCta	:= {}
	Local	__i			:= 0
	Private lEnd		:= .f.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴??
//쿣erifica a quantidade de caracteres em cada nivel da conta    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴??

	If Alltrim(GetMv("MV_PCOSINC"))$"1" //Usa plano de Contas Or?ament?rio
		_cMascara := Alltrim(GetMv("MV_PCOMASC"))
	Else
		_cMascara := Alltrim(GetMv("MV_MASCARA")) //Usa plano de Contas Cont?bil como Or?ament?rio
	EndIf


//============================================================
	If !Empty(AK1->AK1_VERREV)
		Alert("O Or?amento est? em revis?o portanto as altera寤es est?o bloqueadas. Para alterar utilize o controle de revis?o - op豫o revisar.  ")
		_cErro	+=	"O Or?amento est? em revis?o portanto as altera寤es est?o bloqueadas. Para alterar utilize o controle de revis?o - op豫o revisar.  "
		Return
	Endif


	_nCar	:=	0
	For __i := 1 to Len(_cMascara)
		_nCar	+=	Val(SubStr(_cMascara,__i,1))
		Aadd(_aNivCta,_nCar)
	Next __i
	Define Msdialog _oDlgNFe From 000,000 TO 100,500 Title OemToAnsi("Importar dados de Planilha do excel") of oMainWnd Pixel
	@ 003,005 Say OemToAnsi("Arquivo") 	Size 040,030 Pixel
	@ 003,060 Get _cArquivo  Picture "@!S100" Valid (_cArquivo:=cGetFile( "Arquivo NFe (*.csv) | *.csv", "Selecione a planilha de excel desejada"),.t.)  Size 150,010 Pixel
	@ 030,170 Button OemToAnsi("Ok")  Size 036,016 Action (_lOk:=.t.,_oDlgNFe:End()) Pixel
	Activate Dialog _oDlgNFe Centered
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//쿞e o usuario confirmar a importacao da planilha?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

	If _lOk
		//Teste()
		Processa({||FUPCRUN(@_cErro,_cArquivo,_cMascara,_aNivCta)},"Verificando estrutura e Importando...","Aguarde, por favor...",@lEnd)
		If !Empty(_cErro)
			//Alert(_cErro)
		Else
		//	Alert("IMPORTA플O REALIZADA COM SUCESSO")
			MSGINFO( "OK!!", "IMPORTA플O REALIZADA COM SUCESSO" )
		Endif
	Endif
	RestArea(_aArea)
Return nil
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇?袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑UPCRUN                                                     볍?
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽?
굇튒esc.     쿛rocessa a Importacao do Arquivo                            볍?
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽?
굇튧so       쿍FPC004D                                                    볍?
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
Static Function FUPCRUN(_cErro,_cArquivo,_cMascara,_aNivCta)
	Local nPPlan 	:= 0
	Local nPVersao 	:= 0
	Local nPRevisao	:= 0
	Local nPConta 	:= 0
	Local nPNivel 	:= 0
	Local nPCcusto 	:= 0
	Local nPCompl 	:= 0
	Local nPDtIni 	:= 0
	Local nPDtFim 	:= 0
	Local nPValor 	:= 0
	Local aLine		:= {}
	Local nLinha	:= 1
	If !File(_cArquivo)
		Alert("Arquivo n?o existe")
		_cErro	+=	"Arquivo n?o existe"
		Return nil
	Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//쿛osiciono na memoria o arquivo para leitura?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	_nHandle	:=	FOpen(_cArquivo)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//쿣erifico o Tamanho do arquivo?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	_nTam		:=	FSeek(_nHandle,0,2)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//쿛osiciono no Inicio do arquivo pois utilizei a Funcao FSeek?
//쿾ara saber a quantidade de linhas do arquivo               ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	FSeek(_nHandle,0,0)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//쿔ncremento a regua de processamento?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	ProcRegua((_nTam/271))
	FT_FUse(_cArquivo)
	FT_FGotop()


//Le cabe?alho
	_cLinha := Upper(Alltrim(FT_FREADLN()))

	aLine := Separa(_cLinha,';')
//TODO altera豫o 
	nPPlan 		:= aScan(aLine,'PLANILHA')
	nPVersao 	:= aScan(aLine,'VERSAO')
	nPRevisao	:= aScan(aLine,'REVISAO')
	nPConta		:= aScan(aLine,'CONTA')
	nPNivel		:= aScan(aLine,'NIVEL')
	nPCcusto	:= aScan(aLine,'CCLAS')
	nPCompl 	:= aScan(aLine,'COMPL')
	nPDtIni 	:= aScan(aLine,'DATAINI')
	nPDtFim 	:= aScan(aLine,'DATAFIM')
	nPValor 	:= aScan(aLine,'VALOR')


	IF 	nPPlan 		== 0 .Or. ;
			nPVersao 	== 0 .Or. ;
			nPRevisao	== 0 .Or. ;
			nPConta		== 0 .Or. ;
			nPNivel		== 0 .Or. ;
			nPCcusto	== 0 .Or. ;
			nPDtIni 	== 0 .Or. ;
			nPDtFim 	== 0 .Or. ;
			nPValor 	== 0
		Alert("Documento Invalido")
		_cErro	+=	"Documento Invalido"
		RETURN
	EndIf
	FT_FSkip()
	nLinha++

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//쿣erifica se o arquivo aberto e um arquivo de retorno de informacoes contabeis?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	_nLin		:=	0
	_lCabec	:=	.f.
	While (!FT_FEof())
		IncProc("Importando Estrutura do Or?amento...")
		_nLin++
		_cLinha := Upper(Alltrim(FT_FREADLN()))
		_lLinValid	:=	.t.
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿞e nao houver informacao nenhuma desconsidera o registro?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If Empty(Alltrim(_cLinha))
			FT_FSkip()
			nLinha++
			Loop
		Endif

		aLine := Separa(_cLinha,';')

		_cPlanil	:=	PADR(Alltrim(aLine[nPPlan]),TAMSX3('AK3_ORCAME')[1])

		_cVersao	:=	StrZero(Val(Alltrim(aLine[nPVersao])),TamSx3("AK2_VERSAO")[1],0)

		_cRevisao	:=	StrZero(Val(Alltrim(aLine[nPRevisao])),TamSx3("AK2_VERSAO")[1],0)

		_cConta	:=	PADR(Alltrim(aLine[nPConta]),TamSx3("AK5_CODIGO")[1])

		_nNivel	:=	Val(Alltrim(aLine[nPNivel]))

		_cCusto	:=	PADR(Alltrim(aLine[nPCcusto]),TamSx3("AK2_CC")[1])

		_cCompl	:=	PADR(Alltrim(aLine[nPCcusto]),TamSx3("AK2_DESCRI")[1])

		_dDataIni:=	Ctod(Alltrim(aLine[nPDtIni]))

		_dDataFim:=	Ctod(Alltrim(aLine[nPDtFim]))

		_nValor	:=	Alltrim(aLine[nPValor])

		While At(".",_nValor)>0
			_nValor	:=	StrTran(_nValor,".","")
		EndDo
		_nValor	:=	Val(StrTran(_nValor,",","."))

		CV0->(DbSetOrder(2))
		If CV0->(DbSeek(xFilial('CV0') + Alltrim(_cCusto)+Alltrim(_cConta)))
			_cOperac:=	CV0->CV0_XOPERA
		Else
			_cOperac := ''
		EndIf

//	If 	Alltrim(_cConta) == '55101001' .And. Alltrim(_cCusto) == 'DA007012'
//		Alert('OPA')
//	EndIf
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
		//쿣erifico se a planilha a ser importada ? igual a planilha posicionada?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
		If (Alltrim(_cPlanil)<>Alltrim(AK1->AK1_CODIGO) .Or. Alltrim(_cVersao)<>Alltrim(AK1->AK1_VERSAO)) .Or. Alltrim(aLine[nPRevisao])<>Alltrim(AK1->AK1_VERREV)
			Alert("Importa豫o n?o realizada pois o layout da planilha or?ament?ria (C?digo , Vers?o e Revis?o) n?o confere com o arquivo a ser importado.")
			_cErro	+=	"Importa豫o n?o realizada pois o layout da planilha or?ament?ria (C?digo , Vers?o e Revis?o) n?o confere com o arquivo a ser importado. "
			Return
			Exit
		Endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
		//쿣erifica se a conta contabil existe?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
		If Alltrim(_cConta)<>Alltrim(_cPlanil)
			DbSelectArea("AK5")
			ak5->(DbSetOrder(1))
			If !ak5->(DbSeek(xFilial("AK5")+_cConta))
				_cErro	+=	"Conta Orcamentaria "+_cConta+" na linha "+Alltrim(Str(_nLin))+" n?o esta cadastrada"+Chr(13)+Chr(10)
				_lLinValid	:=	.f.
			Else
			//TODO ALTEREI 
				_cNomeCta := AK5->AK5_DESCRI
				if  AK5->AK5_TIPO == '2'.AND. Len(_aNivCta) > 0
					_aNivCta[Len(_aNivCta)]:=Len(Alltrim(_cConta))
				ELSEIF Len(_aNivCta) > 0
					_aNivCta[Len(_aNivCta)]:= 0
				Endif


			Endif
		Endif
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿣erifica se a classe or?amentaria  existe?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		//TODO ALTEREI 
		If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
			DbSelectArea("AK6")
			AK6->(DbSetOrder(1))
			If !AK6->(DbSeek(xFilial("AK6")+PadR(_cCusto,TamSX3("AK6_CODIGO")[1])))
				_cErro	+=	"Classe or?amentaria  "+_cCusto+" na linha "+Alltrim(Str(_nLin))+" n?o esta cadastrado"+Chr(13)+Chr(10)
				_lLinValid	:=	.f.
			Endif
		Endif
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
		//쿣erifica se o nivel da conta esta correto?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
		If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. !(_nNivel>0)
			_cErro	+=	"Nivel da Conta na estrutura do or?amento "+Alltrim(Str(_nNivel))+" na linha "+Alltrim(Str(_nLin))+" ? inv?lido"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.
		Endif
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿣erifica o periodo inicial do orcamento ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If  Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Empty(_dDataIni)
			_cErro	+=	"Periodo Inicial na estrutura do or?amento na linha "+Alltrim(Str(_nLin))+" ? inv?lido"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.
		Endif
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿣erifica o periodo inicial do orcamento ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Empty(_dDataFim)
			_cErro	+=	"Periodo Final na estrutura do or?amento na linha "+Alltrim(Str(_nLin))+" ? inv?lido"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.
		Endif
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿞e alinha for valida faco a gravacao da estrutura do orcamento?
		//쿮 dos itens do orcamento                                      ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	//TODO parei na valida?o da tabela Ak3 pois n?o esta gravando a estrutura correta 
		If _lLinValid
			DbSelectArea("AK3")
			ak3->(DbSetOrder(2))
			_lExist	:= !(ak3->(DbSeek(xFilial("AK3")+_cPlanil+_cVersao + PADR(If(((Ascan(_aNivCta,Len(Alltrim(_cConta))))-1)>0,SubStr(_cConta,1,_aNivCta[((Ascan(_aNivCta,Len(Alltrim(_cConta))))-1)]),_cPlanil),TAMSX3('AK3_PAI')[1]) +_cConta)))
			//AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI+AK3_CO
			If RecLock("AK3",_lExist)
				If _lExist
					Replace	ak3->ak3_filial	With	xFilial("AK3")
					Replace	ak3->ak3_orcame	With	_cPlanil
					Replace	ak3->ak3_versao	With	_cVersao
					Replace	ak3->ak3_co		With	_cConta
					Replace	ak3->ak3_pai	With	If(((Ascan(_aNivCta,Len(Alltrim(_cConta))))-1)>0,SubStr(_cConta,1,_aNivCta[((Ascan(_aNivCta,Len(Alltrim(_cConta))))-1)]),_cPlanil)
				EndIf
				Replace	ak3->ak3_tipo	With	If(Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)],"2","1")
				Replace	ak3->ak3_nivel	With	StrZero(_nNivel,3)
				Replace	ak3->ak3_descri	With	_cNomeCta //buscar da Ak5
				MsUnLock("AK3")
			Endif
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//쿣erifica se a conta ? analitica?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
				_cId	:=	"0000"
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
				//쿛rocuro o proximo ID dos itens do orcamento?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
				DbSelectArea("AK2")
				ak2->(DbSetOrder(1))
				If ak2->(DbSeek(xFilial("AK2")+_cPlanil+_cVersao+_cConta))
					While ak2->(!Eof()) .And. ak2->ak2_filial==xFilial("AK2") .And.;
							ak2->ak2_orcame==_cPlanil			.And.;
							ak2->ak2_versao==_cVersao			.And.;
							ak2->ak2_co==_cConta
						If _cId<ak2->ak2_id .And. ((ak2->ak2_cc<>_cCusto))
							_cId	:=	ak2->ak2_id
						Endif
						ak2->(Dbskip())
					EndDo
				Endif
				_cId	:=	Soma1(_cId)

				DbSelectArea("AK2")
				AK2->(DbOrderNickName('PETCARE'))
				//TODO criar indice com o NOME  PETCARE
				_lExist	:= !(ak2->(DbSeek(xFilial("AK2")+_cPlanil+_cVersao+_cConta+ _cCusto+Dtos(_dDataIni))))
				//AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_CC
				If RecLock("AK2",_lExist)
					Replace	ak2->ak2_filial	With	xFilial("AK2")
					If _lExist
						Replace ak2->ak2_id		With	_cId
					EndIf
					Replace	ak2->ak2_orcame	With	_cPlanil
					Replace	ak2->ak2_versao	With	_cVersao
					Replace	ak2->ak2_co		With	_cConta
					Replace	ak2->ak2_period	With	_dDataIni
				//	Replace	ak2->ak2_cc		With	_cCusto
					Replace	ak2->ak2_classe	With	_cCusto
					//Replace	ak2->ak2_ent05	With	Alltrim(_cCusto)+Alltrim(_cConta)
					Replace	ak2->ak2_valor	With	_nValor
					//Replace	ak2->ak2_descri	With	_cCompl
					Replace	ak2->ak2_moeda	With	1
					Replace ak2->ak2_dataf	With	_dDataFim
					Replace ak2->ak2_datai	With	_dDataIni
				//	Replace ak2->ak2_oper	With	STRTRAN(_cOperac,';',' ' )
				//	Replace ak2->ak2_uniorc	With	SM0->M0_CODIGO
					MsUnLock("AK2")
				Endif
			Endif
		Endif
		FT_FSkip()
		nLinha++
	EndDo
	FT_FUse()
	FClose(_nHandle)

	IF !_lLinValid
		Return
	EndIF

	dbSelectArea("AKB")
	dbSetOrder(1)
	//TODO Johny wendel no cadastro do ponto de lan?amento 000252- 01 o campo AKB_PERMR tera que estar = 1
	// para que sej? lan?ado os lan?amentos na tabela AKD
	If dbSeek(xFilial("AKB")+'00025201') .AND. AKB->AKB_PERMR == "1"

		MV_PAR01 := .F.
		MV_PAR02 := ' '
		MV_PAR03 := 'zzz'
		MV_PAR04 := AK1->AK1_INIPER
		MV_PAR05 := AK1->AK1_FIMPER
		MV_PAR05 := AK1->AK1_FIMPER
		MV_PAR06 := "AK2_ORCAME = '" + AK1->AK1_CODIGO + "' "
		MV_PAR07 := .F.
		MV_PAR08 := .T.
		_lAuto := .T.
		nCallOpcx := 0
		A310DLG("AKB",AKB->(RecNo()),nCallOpcx)
	EndIf
Return






/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?310DLG   ?utor  ?dson Maricate      ?Data ? 08/07/05   ??
???????????????????????????????????????
??esc.     ?Dialog de reprocessamento                                  ??
???????????????????????????????????????
??so       ?AP8                                                        ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function A310Dlg(cAlias,nRecnoAKB,nCallOpcx)
	Local aRet	      := {}
	Local aParametros := {}

	Local aRetFil     := {}
	Local lRet        := .F.
	Local cFiltAKD    := ""
	Local aAreaOri

//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
	Local cAliasEnt	  := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
	Local nThreads 	  := SuperGetMv("MV_PCOTHRE",.T.,1)
	Local cTbField    := If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
	Local lEnd		  := .T.
	Local cFiltro	  := ""
//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
	Local cFilAtu	  := cFilAnt
	Local nRegSM0	  := SM0->(Recno())
	Local cProcess    := ""
	Local cItem       := ""
	Local lMultFil	  := .F.
	Local lPCO310Aux  := ExistBlock("PCO310AUX")
	Local cLoadParam  := cEmpAnt + "_" + cFilAnt + "_A310DLG"

	Local aFilLoc	  := {}
	Local lContinua	  := .T.
	Local cChave	  := ""
	Local nX
	Local nTotReg 	  := 0
	Local cMvExecProc := GetNewPar("MV_PCOPROC","")
	Local lCpExProc   :=  	Alltrim(TcGetDb()) $ "MSSQL7|ORACLE|DB2|INFORMIX"  .And. ; //bancos homologados
	ExistBlock("PCOA3105")                             .And. ; //se ponto de entrada esta compilado no RPO
	AKB->AKB_PROCES+AKB->AKB_ITEM $ cMvExecProc               //processo+item estar contido no parametro MV_PCOPROC

//*********************************
// Utilizado no vetor da parambox *
//*********************************

	Private DEF_DATINI := 2
	Private DEF_DATFIN := 3
	Private DEF_FILTRO := 4

	Private lDelPeriodo
	Private cFilialDe
	Private cFilialAte
	Private dPeriodoDe
	Private dPeriodoAte
	Private lVisualiza
	Private lAtuSld

	dbSelectArea("AL1")
	dbSetOrder(1)
	dbSelectArea("AL2")
	dbSetOrder(1)
	dbSelectArea("AK5")
	dbSetOrder(1)
	dbSelectArea("AKD")
	dbSetOrder(1)
	dbSelectArea("AKS")
	dbSetOrder(1)
	dbSelectArea("AKT")
	dbSetOrder(1)
	dbSelectArea("ALA")
	dbSetOrder(1)
	dbSelectArea("AKB")

	If AKB->AKB_PERMR == "1"

		If !lCpExProc
			If nThreads>1
				//***********************************************************
				// Avalia se tem Trhead rodando para o processo selecionado *
				// e apresenta tela com processamento Multi-Thread.         *
				//***********************************************************
				lEnd	:= MoniThread()
			EndIf
		EndIf

		If lEnd // So continua se n? tem Thread rodando

			MV_PAR06 := CHR(10) //Limpa Filtro
			If	FWModeAccess("AK8",3) == "C" .And.;	// Processos de Sistema
				FWModeAccess("AKB",3) == "C" .And.;	// Pontos de Lan?mento
				FWModeAccess("AKC",3) == "C" 		// Configuracao de Lancamento

				lMultFil := .T.

				cLoadParam += "_C" //Compartilhado

				aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //"Apagar lan?mantos do periodo ?"
				{ 1, STR0022,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"Empty() .or. ExistCpo('SM0',cEmpAnt+mv_par02)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial de"
				{ 1, STR0023,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"MV_PAR03>='ZZ' .or. ExistCpo('SM0',cEmpAnt+mv_par03)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial ate"
				{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
				{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
				{ 7, STR0007+GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),""},; //"Filtro "
				{ 5, STR0008,.F.,120,,.F.},;
					{ 5, STR0042,.F.,120,,.F.,nThreads>1}} //"Atualizar Saldos ?"

			Else

				aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //"Apagar lan?mantos do periodo ?"
				{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
				{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
				{ 7, STR0007+GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),""},; //"Filtro "
				{ 5, STR0008,.F.,120,,.F.},;
					{ 5, STR0042,.F.,120,,.F.,nThreads>1} } //"Atualizar Saldos ?"

			EndIf

			If _lAuto .OR. ParamBox(aParametros,STR0009,aRet,,,,,,,cLoadParam) //"Parametros"

				//Rodolfo
				aRet := {}
				aadd(aRet,.F.)
				aadd(aRet,' ')
				aadd(aRet,'zzz')
				aadd(aRet,AK1->AK1_INIPER)
				aadd(aRet,AK1->AK1_FIMPER)
				aadd(aRet,'AK2_ORCAME == "' + AK1->AK1_CODIGO + '" ')
				aadd(aRet,.F.)
				aadd(aRet,.T.)

				If lPCO310Aux
					ExecBlock("PCO310AUX",.F.,.F.)
				EndIf
				//*******************************
				// reprocessamento Multi-Filial *
				//*******************************
				If lMultFil
					lDelPeriodo			:= .F.
					cFilialDe			:= '   '
					cFilialAte			:= 'ZZZ'
					lAtuSld				:= .T.
					DEF_DATINI := 4
					DEF_DATFIN := 5
					DEF_FILTRO := 6
					DEF_VISUAL := 7
				Else
					lDelPeriodo			:= aRet[1]
					cFilialDe			:= cFilAnt
					cFilialAte			:= cFilAnt
					lAtuSld				:= aRet[6]
					DEF_DATINI 			:= 2
					DEF_DATFIN 			:= 3
					DEF_FILTRO 			:= 4
					DEF_VISUAL 			:= 5
				EndIf
				//???????????????????????????????
				//?Inicia o log de processamento  - nao tirar a linha abaixo  ?
				//?pois funcao ProcLogIni utiliza as variaveis mv_par private ?
				//???????????????????????????????
				AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )

				If	FWModeAccess("AL1",3) == "C"
					dbSelectArea("AL1")
					cChave := AllTrim(SM0->M0_CODIGO)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")
					If LockByName("PCOA300"+cChave,.F.,.F.)
						aAdd(aFilLoc,"PCOA300"+cChave)
					Else
						Help(" ",1,"PCOA301US",,STR0043,1,0) //"Outro usuario est?reprocessando saldos. Aguarde!"
						Return
					EndIf
				Else
					dbSelectArea("SM0")
					dbSeek(cEmpAnt+cFilialDe,.t.)
					While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and. SM0->M0_CODFIL <= cFilialAte
						cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
						dbSelectArea("AL1")
						cChave := AllTrim(SM0->M0_CODIGO)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")
						If LockByName("PCOA300"+cChave,.F.,.F.)
							aAdd(aFilLoc,"PCOA300"+cChave)
						Else
							lContinua := .F.
							Exit
						EndIf
						SM0->(DbSkip())
					EndDo
					DbSelectArea("SM0")
					DbGoTo(nRegSM0)

					If !lContinua
						For nX := 1 To Len(aFilLoc)
							UnLockByName(aFilLoc[nX],.F.,.F.)
						Next
						Help(" ",1,"PCOA301US",,STR0043,1,0) //"Outro usuario est?reprocessando saldos. Aguarde!"
						Return
					EndIf
				EndIf

				If _lAuto .And. lDelPeriodo
					If _lAuto
						aRetFil :=  aClone(_aRetPar2)
					EndIf

					If Len(aRetFil) > 0 .And. !Empty(aRetFil[1])
						cFiltAKD := aRetFil[1]
					EndIf
					//Qdo eh rotina automatica considera .T. sempre
					lRet := .T.

				ElseIf lDelPeriodo
					If Aviso(STR0010, STR0016, {STR0017, STR0018} )==1  //"Atencao"##"Filtrar os lancamentos existentes para exclusao do processo selecionado ?"##"Sim"##"Nao"

						If  ParamBox( { { 7 , STR0007+STR0019,"AKD",""} }, STR0009, aRetFil,,,,,,, "PCOA310_1", .F., .F.) //"Parametros"##"[ Excluir os Movimentos - AKD ]"
							If !Empty(aRetFil[1])
								cFiltAKD := aRetFil[1]
								lRet := .T.
							EndIf
						EndIf

						If !lRet
							Aviso(STR0010, STR0020, {"Ok"})  //"Atencao"##"Filtro nao informado. Operacao Cancelada!"
						EndIf

						AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )

					Else

						If Aviso(STR0010, STR0021,{STR0017, STR0018} ) == 1  //"Atencao"##"Confirma a exclusao de todos os lancamentos para o processo selecionado?"##"Sim"##"Nao"
							lRet := .T.
						EndIf

					EndIf

				Else

					lRet	:= .T.

				EndIf

				If lRet

					If lCpExProc

						//se existe campo e campo esta como 1-Sim Executa por procedure
						A310ExProc(aRet, lAtuSld, cAliasEnt, cFiltAKD)

					Else
						//*******************************
						// reprocessamento Multi-Thread *
						//*******************************

						nTotReg   := TotLanc(aRet) //Retorna a quantidade de registros  validando se o processamento ser?multi-thread

						cAliasEnt := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
						cTbField  := If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
						If nThreads>1 .And. nTotReg >= nThreads
							aAreaOri := GetArea()
							dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
							dbSetOrder(1)

							If lDelPeriodo
								cFiltro	:= aRet[DEF_FILTRO]
								dbSelectArea("SM0")
								DbSeek(cEmpAnt+cFilialDe,.t.)
								While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.;
										SM0->M0_CODFIL <= cFilialAte
									cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
									Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan?mentos" ### "Excluindo lancamentos..."
									SM0->(DbSkip())
								EndDo
								DbSelectArea("SM0")
								DbGoTo(nRegSM0)
							EndIf

							If  SubStr( cAliasEnt, 1, 1) == "S"
								//se a primeira letra do alias for "S" entao
								//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
								If !Empty(xFilial(cAliasEnt)) .And. Len(xFilial(cAliasEnt)) == 2
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL>='"+cFilialDe+"' .and. "
									aRet[DEF_FILTRO] += cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL<='"+cFilialAte+"'"
								Else
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+SubStr(cAliasEnt, 2, 2)+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
								EndIf
							Else
								If !Empty(xFilial(cAliasEnt)) .And. Len(xFilial(cAliasEnt)) == 2
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL>='"+cFilialDe+"' .and. "
									aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_FILIAL<='"+cFilialAte+"'"
								Else
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
								Endif
							EndIf
							RestArea(aAreaOri)

							If lRet
								cSql := A310Slq(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)
								If !Empty(aRet[DEF_FILTRO]) .and. !Empty(cSql)
									aRet[DEF_FILTRO] += " .AND. " + cSql + " "
								Elseif !Empty(cSql)
									aRet[DEF_FILTRO] += cSql + " "
								EndIf
								Processa({|| ThreadLanc(aRet)}, STR0013, STR0024 )		// "Processando lan?mentos" ### "Selecionando lan?mentos"
							EndIf

							//???????????????????
							//?Atualiza o log de processamento   ?
							//???????????????????
							ProcLogAtu("FIM")
						Else
							cFiltro	:= aRet[DEF_FILTRO]
							dbSelectArea("SM0")
							DbSeek(cEmpAnt+cFilialDe,.t.)
							While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.;
									SM0->M0_CODFIL <= cFilialAte
								cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

								ProcLogIni( {}/*aButtons*/, "PCOA310" )

								//???????????????????
								//?Atualiza o log de processamento   ?
								//???????????????????
								ProcLogAtu("INICIO")

								aAreaOri := GetArea()
								dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
								dbSetOrder(1)
								aRet[DEF_FILTRO] := cFiltro
								If  SubStr( cAliasEnt, 1, 1) == "S"
									//se a primeira letra do alias for "S" entao
									//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
								Else
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
								EndIf
								RestArea(aAreaOri)
								If lDelPeriodo

									Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan?mentos" ### "Excluindo lancamentos..."

								EndIf

								If lRet
									conout('INI = NO THREAD as ' + TIME())
									Processa({|| ProcLanc(aRet,,,lAtuSld)}, STR0013, STR0015 )		// "Processando lan?mentos" ### "Gerando lancamentos..."
									conout('FIM = EMP:' + cEmpAnt + ' FIL:' + cFilAnt  + ' NO THREAD as ' + TIME() )
								EndIf

								//???????????????????
								//?Atualiza o log de processamento   ?
								//???????????????????
								ProcLogAtu("FIM")

								SM0->(DbSkip())
							EndDo
							DbSelectArea("SM0")
							DbGoTo(nRegSM0)

							If _lAuto .And. !lAtuSld
								Conout( STR0033 +"--->"+STR0034+CRLF+STR0035 ) //"Aviso!" //"Reprocessamento dos lan?mentos finalizado." //" ?recomendada a atualiza?o dos saldos dos Cubos."
							ElseIf !lAtuSld
								Aviso( STR0033 , STR0034+CRLF+STR0035,{STR0012} ) //"Aviso!" //"Reprocessamento dos lan?mentos finalizado." //" ?recomendada a atualiza?o dos saldos dos Cubos."
							EndIf

						EndIf
					EndIf

				EndIf
				cFilAnt	:= cFilAtu

				For nX := 1 To Len(aFilLoc)
					UnLockByName(aFilLoc[nX],.F.,.F.)
				Next

			EndIf
		EndIf
	Else
		If _lAuto
			Conout(STR0010+"-->"+STR0011) //"Aten?o"###"Este ponto n? pode ser reprocessado"
		Else
			Aviso(STR0010,STR0011,{STR0012},2) //"Aten?o"###"Este ponto n? pode ser reprocessado"###"Fechar"
		EndIf
	EndIf

Return


Static Function GetEntFilt(cProcesso,cItem)
	Local aArea := GetArea()
	DbSelectArea('AKB')
	DbSetOrder(1)
	MsSeek(xFilial()+cProcesso+cItem)
	cRet	:=	AKB->AKB_ENTIDA
	If cProcesso == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
		cRet	:=	"SE2"
	ElseIf cProcesso == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
		cRet	:=	"SE1"
	ElseIf cProcesso == "000054" .And. AKB->AKB_ENTIDA == "SDE"
		cRet	:=	"SD1"
	Endif
	RestArea(aArea)
Return cRet




//-------------------------------------------------------------------
/*/{Protheus.doc}TotLanc()
Retorna quantidade de lan?mentos
@author Andr?Brito
@since  14/03/2018
@version 12
/*/
//-------------------------------------------------------------------

Static Function TotLanc(aRet)

	Local cAliasEnt	:= GetEntFilt(AKB->AKB_PROCESS,AKB->AKB_ITEM)
	Local cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
	Local cQuery	:= ""
	Local cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCESS,AKB->AKB_ITEM))
	Local nTotal    := 0

	Default aRet    := {}

	cQuery := "SELECT COUNT(*) AS TOT, MIN(R_E_C_N_O_) AS MIN, MAX(R_E_C_N_O_) AS MAX FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
	cQuery += "WHERE D_E_L_E_T_='' AND " + cTbField + "_FILIAL='" + xFilial(cAliasEnt) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")")
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTOT",.T.,.T.)

	nTotal	:= TRBTOT->TOT

	TRBTOT->(DbCLoseArea())

Return nTotal




Static Function ProcLanc(aRet,lThread,cTable,lAtuSld)
	Local	nIndex
	Local	cIndex   := ""
	Local cFiltro	:=	""
	Local	lCloseArea	:=	.F.
	Local bWhile
	Local cAlias
	Local cProcesso,cItem,cAliasEntid
	Local cTbField
	Local nLimTran	:= SuperGetMv("MV_PCOLIMI",.T.,9999)
	Local nLimCount	:= 0
	Local cCubIni	:= ""
	Local cCubFim   := ""
	Local lTemReg	:= .F.

//****************************************************
// Esta variavel so esta com .T. quando a fun?o ?  *
// solicitada por uma Thread de processamento. Neste *
// caso ser?utilizada uma tabela temporaria para    *
// posicionar os recnos a serem processados.         *
//****************************************************
	Default lThread := .F.
	Default lAtuSld := .F.

	cProcesso := AKB->AKB_PROCES
	cItem := AKB->AKB_ITEM
	cAliasEntid := GetEntFilt(cProcesso,cItem)

	PcoIniLan(AKB->AKB_PROCES)

	Begin Transaction
		dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		dbSetOrder(1)
		If !lThread
			ProcRegua(RecCount())
		Else
			(cTable)->(ProcRegua(RecCount()))
		EndIf

		//************************************************
		// Coni?o para Filtro SQL e quando n? ?Thread *
		//************************************************
		If !Empty(aRet[DEF_FILTRO]) .and. !lThread
			cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			If !Empty(cFiltro)
				cQuery 	:= " SELECT R_E_C_N_O_ RECTAB "
				cQuery 	+= "  FROM " + RetSQLName(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)) + " " +GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
				cQuery 	+= "  WHERE (" + cFiltro+") AND "// Adiciona expressao de filtro convertida para SQL
				cQuery 	+= " D_E_L_E_T_ <> '*' "
				If ExistBlock( "PCOA3103" )
					//P_E?????????????????????????????????????
					//P_E?Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ?
					//P_E?preparacao da query para reprocessamento dos Lancamentos               ?
					//P_E?Parametros : cProcesso, cItem, aClone(aRet), cAliasEntid, cQuery       ?
					//P_E?Retorno    : cQuery      expressao da query                            ?
					//P_E?????????????????????????????????????
					cQuery := ExecBlock( "PCOA3103", .F., .F.,{cProcesso,cItem,aClone(aRet),cAliasEntid,cQuery})
				EndIf

				cQuery 	+= " ORDER BY  " + SqlOrder((GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(IndexKey()))
				cQuery 	:= ChangeQuery(cQuery)


				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "PCOTRB", .T., .T. )
				DbSelectArea("PCOTRB")
				cAlias := Alias()
				lCloseArea	:=	.T.
			Else
				cIndex := CriaTrab(,.F.)
				IndRegua(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),cIndex,IndexKey(),,aRet[DEF_FILTRO])
				nIndex := RetIndex(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
				dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
				dbSetOrder(nIndex+1)
				cAlias := Alias()
			Endif
			DbGoTop()
			bWhile := { || ! (cAlias)->(Eof()) }
		Else

			//*****************************
			// Condi?o para Filtro ADVPL *
			//*****************************
			If !lThread
				dbSeek(xFilial())
				cAlias := Alias()

				If  SubStr( cAlias, 1, 1) == "S"
					//se a primeira letra do alias for "S" entao
					//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
					bWhile := {|| (cAlias)->(!Eof()) .And. &(SubStr( cAlias, 2, 2 ) + "_FILIAL") == xFilial() }
				Else
					bWhile := {|| (cAlias)->(!Eof()) .And. &(cAlias + "_FILIAL") == xFilial() }
				EndIf
			Else
				//***************************************
				// Condi?o para utiliza?o com Threads *
				//***************************************
				bWhile := {|| (cTable)->(!Eof()) }
			EndIf
		Endif

		While Eval(bWhile)

			lTemReg := .T.

			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			If lThread
				//*****************************************
				// Posiciona Recno da tabela temporaria   *
				// utilizada pela Thread de Processamento *
				//*****************************************
				(cAliasEntid)->(DbGoto((cTable)->(R_E_C_)))
			Endif
			If lCloseArea
				(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(MsGoTo(PCOTRB->RECTAB))
			Endif
			IncProc()
			If A310FilInt(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)

				If !DetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)    //processos normais

					If nLimCount >= nLimTran
						//*****************************************
						// O Comentario deste Bloco deve ser      *
						// retirado em caso de DeadLock no banco  *
						//*****************************************
					/*nXz := 1
					While nXz<4 .and. !LockByName("PCOA310_RUN_FINLAN",.T.,.T.,.T.)
						Sleep(1)
						nXz++
					EndDo
               	    If nXz<4*/
						EndTran()
						PcoFinLan(AKB->AKB_PROCES,.F.,.T.,,.F./*lAtuSld*/)
						//UnLockByName("PCOA310_RUN_FINLAN",.T.,.T.,.T.)
						PcoIniLan(AKB->AKB_PROCES)
						BeginTran()
						nLimCount := 0
					/*Else
						nLimCount++
					EndIf*/
				Else
					nLimCount++
				EndIf
				PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")			

			Else
                //processos de rateio que utilizam outra tabela alem da de origem
			    If  (AKB->AKB_PROCES == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") .OR. ;
					AKB->AKB_PROCES == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") )			    

					aDetProc	:=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
					DbSelectArea(aDetProc[1,1])
					DbSetOrder(aDetProc[1,2])
					DbSeek(Eval(aDetProc[1,3]))
					While !Eof() .And. Eval(aDetProc[1,4])
						//SEV
						If Len(aDetProc)==1
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Else
						//SEZ
							DbSelectArea(aDetProc[2,1])
							DbSetOrder(aDetProc[2,2])
							DbSeek(Eval(aDetProc[2,3]))
							While !Eof() .And. Eval(aDetProc[2,4])
								PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
								DbSelectArea(aDetProc[2,1])
								DbSkip()
							Enddo
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Endif
					Enddo					
					dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))

			    ElseIf AKB->AKB_PROCES == "000054" 
			    			    
			    	If	AKB->AKB_ITEM $ '09|10|11' .And. AKB->AKB_ENTIDA == "SDE"
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						If DbSeek(Eval(aDetProc[1,3])) 
							Posic_Tabelas( aDetProc[1,5] )
						EndIf	
						Do While !Eof() .And. Eval(aDetProc[1,4])
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						EndDo
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					ElseIf AKB->AKB_ITEM $ '01|05' .And. AKB->AKB_ENTIDA == "SD1"	
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						DbSeek(Eval(aDetProc[1,3])) 
   						If Eval(aDetProc[1,6])
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf
						DbSelectArea(aDetProc[1,1])
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					EndIf
					
				// Processos de movimentacao internas, producao e acerto de inventario devem gerar os 
				// lancamentos na tabela AKD de acordo com o campo D3_TM da tabela SD3.
				ElseIf AKB->AKB_PROCES $ "000151|000152|000153" .And.;
						AKB->AKB_ITEM $ "01|02" .And.;
						AKB->AKB_ENTIDA == "SD3"

					// Movimentos internos
					If AKB->AKB_PROCES == "000151"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf             
					// Producao
					ElseIf AKB->AKB_PROCES == "000152" .And. SubStr(SD3->D3_CF,1,2) $ "PR|ER"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf                                            
					// Inventario
					ElseIf AKB->AKB_PROCES == "000153" .And. SD3->D3_DOC == "INVENT"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf
					EndIf	
				ElseIf AKB->AKB_PROCES == "000358" .And. AKB->AKB_ITEM == '01' // Rotina de planejamento orcamentario
					DbSelectArea("ALX")
					DbSetOrder(2)
					If DbSeek(xFilial("ALX")+ALY->ALY_PLANEJ+ALY->ALY_VERSAO+ALY->ALY_SEQ) // Posiciona Tabela ALX
					
						PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
					
					EndIf
				EndIf            

			Endif			
		EndIf
		
		If lCloseArea
			dbSelectArea("PCOTRB")
		Else
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		Endif
		If !lThread
			(cAlias)->(dbSkip())		
		Else
			If (cTable)->(FieldPos("THREAD"))>0
				//***********************************
				// Retira flag para reprocessamento *
				// da na Thread.                    *
				//***********************************
				RecLock(cTable,.F.)
				(cTable)->(FieldPut(FieldPos("THREAD"),""))
				MsUnlock()
			EndIf		
			(cTable)->(dbSkip())
		EndIf
	EndDo                        
	If lCloseArea
		DbSelectArea("PCOTRB")
		DbCloseArea()
		DbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	Endif		
End Transaction		      

PcoFinLan(AKB->AKB_PROCES,.F.,.T.,,.F./*lAtuSld*/)

If lAtuSld .And. lTemReg
	//???????????????????
	//?Atualiza Saldos dos Cubos         ?
	//???????????????????
	dbSelectArea("AL1")
	AL1->(dbSetOrder(1))
	If AL1->(dbSeek(xFilial("AL1"))) //Verifica se existe Cubo cadastrado
		cCubIni := AL1->AL1_CONFIG
		AL1->(dbSeek(xFilial("AL1")+Replicate('z',TamSX3("AL1_CONFIG")[1]),.T.))
		AL1->(dbSkip(-1)) 
	 	cCubFim := AL1->AL1_CONFIG
	  	PCOA301EXE(,.T.,{cCubIni,cCubFim,aRet[DEF_DATINI],aRet[DEF_DATFIN],.T.,""}) //Atualizar Saldo dos Cubos
	EndIf	
EndIf

Return


//TODO analisar incluss?o na AKD
Static Function A310FilInt(cProcesso,cItem,aRet)
Local lRet := .F.

Do Case
	Case cProcesso+cItem == "00025201"  // Inclusao de itens da Planilha
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AK1->(dbSetOrder(1))
			lRet := ( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO == AK1->AK1_VERSAO ) 	
		Endif
	Case cProcesso+cItem == "00025202"  // Inclusao de itens da Planilha versoes revisadas
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AKR->(dbSetOrder(1))
			AK1->(dbSetOrder(1))
			lRet := !( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO))).And.( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO <> AK1->AK1_VERSAO ) 
		Endif
	Case cProcesso+cItem == "00025203"  // Inclusao de itens da Planilha versoes simuladas
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif
	Case cProcesso+cItem == "00035801"  // Inclusao de movimentos de planejamento
		lRet	:=	( ALY->ALY_DTINI >= aRet[DEF_DATINI] .And. ALY->ALY_DTFIM <= aRet[DEF_DATFIN] )
/*		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif */
	Case cProcesso+cItem == "00008201"  // Lan?mentos contabeis CT2
		lRet	:=	( CT2->CT2_DATA >= aRet[DEF_DATINI] .And. CT2->CT2_DATA <= aRet[DEF_DATFIN] )
		
OtherWise 
	lRet := .T.
EndCase

If lRet .And.  ExistBlock( "PCOA3102" )
	//P_E?????????????????????????????????????
	//P_E?Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ?
	//P_E?validacao do reprocessamento dos Lancamentos                           ?
	//P_E?Parametros : Nenhum                                                    ?
	//P_E?Retorno    : .T.ou .F.  //.T.validacao de usuario OK  .F.-Falhou       ?
	//P_E?              Ex. :  User Function PCOA3102                            ?
	//P_E?                     Return(If(U_FuncUsr(), .T., .F.))                 ?
	//P_E?????????????????????????????????????
	lRet := ExecBlock( "PCOA3102", .F., .F.,{cProcesso,cItem,aClone(aRet)})
EndIf

Return lRet


Static Function DetProc(cProcesso, cItem)
Local lRet	:=	.F.
If cProcesso == "000002" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	lRet	:=	.T.
ElseIf cProcesso $ "000151|000152|000153" .And. cItem $ '01|02'
	lRet	:=	.T.
ElseIf cProcesso $ "000358" .And. cItem $ '01' // Rotina de planejamento orcamentario
	lRet	:=	.T.
Endif	                                                                	
Return lRet              




Static Function GetDetProc(cProcesso, cItem)
Local lRet		:=	.F.
Local aDetProc	:=	{}
Local cChaveSEV	:= ""
Local cChaveSDE	:= ""
Local cChaveSD1	:= ""

If cProcesso == "000002"  .And. (cItem == '04' .Or. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE2")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE2",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'      
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE1",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	aDetProc	:=	Array(1,5)
	aDetProc[1,1]	:=	"SDE"
	aDetProc[1,2]	:=	1
	cChaveSDE 		:=  RetChaveSDE("SD1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSDE  + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SDE")+SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF) == "' + cChaveSDE +'" }')
	aDetProc[1,5]	:=	{}   //ARRAY PARA POSICIONAR TABELAS CONFORME ITEM 	
	aAdd(aDetProc[1,5], { "SF1", 1, &('{|| "' + RetChaveSDE("SD1",,"SF1") + '"}') })
	aAdd(aDetProc[1,5], { "SB1", 1, &('{|| xFilial("SB1")+'+GetEntFilt(cProcesso,cItem)+'->D1_COD }') })
	aAdd(aDetProc[1,5], { "SA2", 1, &('{||  xFilial("SA2")+'+GetEntFilt(cProcesso,cItem)+'->(D1_FORNECE+D1_LOJA) }') })
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	aDetProc	:=	Array(1,6)
	aDetProc[1,1]	:=	"SD1"
	aDetProc[1,2]	:=	1                   
	cChaveSD1		:=	SD1->(IndexKey(1))
	aDetProc[1,3]	:=	&("{|| "+cChaveSD1+"}")
	aDetProc[1,4]	:=	{}
	aDetProc[1,5]	:=	{}   
	If cItem == "01"
		aDetProc[1,6] := {|| SD1->D1_TIPO <> "D"}
	Else	
		aDetProc[1,6] := {|| SD1->D1_TIPO == "D"}
	EndIf	
Endif	                                                                	

Return aDetProc


Static Function Posic_Tabelas(aPosic)
Local nX
Local aArea := GetArea()
Local nOrdem := 0
Local nPosAlias

nPosAlias := ASCAN(aPosic, {|aVal| aVal[1] == aArea[1] })

For nX := 1 TO Len(aPosic)
	dbSelectArea(aPosic[nX,1])
	nOrdem := IndexOrd()
	dbSetOrder(aPosic[nX,2])
	dbSeek(Eval(aPosic[nX,3]))
	//depois que posicionou retorna para dbsetorder() de origem
	//atencao -> nao pode ser utilizado Getarea() / RestArea() - deve ficar posicionado
	dbSetOrder(nOrdem)
Next

If nPosAlias > 0   //se tiver que posicionar na tabela atual soh retorna para alias
	dbSelectArea(aArea[1])
Else  //senao restaura a area
	RestArea(aArea)
EndIf	

Return
