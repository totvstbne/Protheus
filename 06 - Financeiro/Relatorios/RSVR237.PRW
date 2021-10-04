#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RSVR237
//TODO Impress�o Boleto Bradesco
@author Gerardo Ara�jo
@since 09/07/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function RSVR237(cNum, cSerie ,Banco , Agen ,Conta,cParcela, lImPDF )

	Local   aCampos      := {}
	Local   hEnter       := Chr( 13 )
	Local   cMarca       := IIf(alltrim(FunName())=="MATA410" .OR. ISINCALLSTACK("MATA460A"),"",GetMark())
	Local   lInverte     := .f.
	Local   aMarked      := {}
	Local   aDesc        := { "Este programa imprime os boletos de",;
	"cobranca bancaria de acordo com",;
	"os parametros informados"}

	Private nRegSel		:= 0
	Private Exec		:= .F.
	Private cIndexName	:= ''
	Private cIndexKey	:= ''
	Private cFilter		:= ''
	Private dvnn		:= 0
	Private dvcb		:= 0
	Private dv			:= 0
	Private _cBanco		:= "237"
	Private c_Banco		:= Banco
	Private c_Agen		:= Agen
	Private c_Conta		:= Conta
	Private oDlgTel		:= Nil
	Private lJOB		:= lImPDF

	oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	oFont08N:= TFont():New("Arial",8,8,,.T.,,,,.T.,.F.)
	oFont09 := TFont():New("Arial",9,9,,.F.,,,,.T.,.F.)
	oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont18n:= TFont():New("Arial",9,17,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)   
	oFont14n:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
	oFont12 := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont20 := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	Tamanho  := "M"
	titulo   := "Impress�o de Boleto"
	cDesc1   := "Este programa destina-se a impress�o de boletos do Banco Bradesco."
	cDesc2   := ""
	cDesc3   := ""
	cString  := "SE1"
	wnrel    := "RSVR237"
	lEnd     := .F.
	cPerg    := "RSVR0237"

	aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0

	dBSelectArea( "SE1" )

	AjustaSX1()

	If cNum == nil
		If !Pergunte( cPerg,.T., "Par�metros - Boletos BRADESCO" )
			Set Filter to
			Return
		Endif
	Else
		c_Banco		:= Banco
		c_Agen		:= Agen
		c_Conta		:= Conta

	EndIf

	cSql := " SELECT SE1.E1_OK,      " + hEnter
	cSql += "        SE1.E1_PREFIXO, " + hEnter
	cSql += "        SE1.E1_NUM,     " + hEnter
	cSql += "        SE1.E1_TIPO,    " + hEnter
	cSql += "        SE1.E1_PARCELA, " + hEnter
	cSql += "        SE1.E1_CLIENTE, " + hEnter
	cSql += "        SE1.E1_LOJA,    " + hEnter
	cSql += "        SE1.E1_VENCTO,  " + hEnter
	cSql += "        SE1.E1_EMISSAO, " + hEnter
	cSql += "        SE1.E1_PORTADO, " + hEnter
	cSql += "        SE1.E1_AGEDEP,  " + hEnter
	cSql += "        SE1.E1_CONTA,   " + hEnter
	cSql += "        SE1.E1_NUMBOR,  " + hEnter
	cSql += "        SE1.E1_NUMBCO,  " + hEnter
	cSql += "        SE1.E1_SALDO,   " + hEnter
	cSql += "        SE1.E1_DECRESC, " + hEnter
	cSql += "        SE1.E1_FILORIG, " + hEnter
	cSql += "        SE1.E1_FATURA,  " + hEnter
	cSql += "        SE1.E1_NFELETR, " + hEnter
	cSql += "        SE1.E1_FATURA,  " + hEnter
	cSql += "        SA1.A1_NOME	 " + hEnter


	cSql += "                        " + hEnter
	cSql += " FROM " + RetSqlName( "SE1" ) + " SE1            	" + hEnter
	/*
	cSql += " JOIN " + RetSqlName( "SEA" ) + " SEA            	" + hEnter
	cSql += " ON SEA.EA_FILIAL    = '" + xFilial("SEA") + "'" + hEnter
	cSql += " AND SEA.EA_PREFIXO   = SE1.E1_PREFIXO " + hEnter
	cSql += " AND SEA.EA_NUM   = SE1.E1_NUM " + hEnter
	cSql += " AND SEA.EA_PARCELA   = SE1.E1_PARCELA " + hEnter
	cSql += " AND SEA.EA_NUMBOR   = SE1.E1_NUMBOR " + hEnter
	*/	
	cSql += " JOIN " + RetSqlName( "SA1" ) + " SA1             	" + hEnter
	cSql += " ON E1_CLIENTE = A1_COD AND 						" + hEnter
	cSql += " E1_LOJA = A1_LOJA 								" + hEnter

	cSql += " WHERE SE1.E1_FILIAL    = '" + xFilial("SE1") + "'" + hEnter

	If cNum <> nil

		cSql += "   AND ( SE1.E1_PREFIXO >= '" + cSerie + "' AND SE1.E1_PREFIXO <= '" + cSerie + "')" + hEnter
		cSql += "   AND ( SE1.E1_NUM     >= '" + cNum + "' AND SE1.E1_NUM     <= '" + cNum + "')" + hEnter
		cSql += "   AND E1_PARCELA = '" + cParcela + "' "
		/*
		cSql += "   AND SEA.EA_PORTADO = '"+Banco+"' "  + hEnter
		cSql += "   AND SEA.EA_AGEDEP = '"+Agen+"' "  + hEnter
		cSql += "   AND SEA.EA_NUMCON = '"+Conta+"' "  + hEnter*/

	Else
		cSql += "   AND ( SE1.E1_PREFIXO >= '" + MV_PAR01 + "' AND SE1.E1_PREFIXO <= '" + MV_PAR02 + "')" + hEnter
		cSql += "   AND ( SE1.E1_NUM     >= '" + MV_PAR03 + "' AND SE1.E1_NUM     <= '" + MV_PAR04 + "')" + hEnter
		cSql += "   AND ( SE1.E1_PARCELA >= '" + MV_PAR05 + "' AND SE1.E1_PARCELA <= '" + MV_PAR06 + "')" + hEnter
		cSql += "   AND ( SE1.E1_NUMBOR  >= '" + MV_PAR07 + "' AND SE1.E1_NUMBOR  <= '" + MV_PAR08 + "')" + hEnter
		cSql += "   AND ( SE1.E1_CLIENTE >= '" + MV_PAR09 + "' AND SE1.E1_CLIENTE <= '" + MV_PAR10 + "')" + hEnter
		cSql += "   AND ( SE1.E1_LOJA    >= '" + MV_PAR11 + "' AND SE1.E1_LOJA    <= '" + MV_PAR12 + "')" + hEnter
		cSql += "   AND ( SE1.E1_VENCTO  >= '" + DTOS( MV_PAR13 ) +"' AND SE1.E1_VENCTO  <= '" + DTOS( MV_PAR14 ) + "')" + hEnter
		cSql += "   AND ( SE1.E1_EMISSAO >= '" + DTOS( MV_PAR15 ) +"' AND SE1.E1_EMISSAO <= '" + DTOS( MV_PAR16 ) + "')" + hEnter
		/*cSql += "   AND SEA.EA_PORTADO = '"+mv_par18+"' "  + hEnter
		cSql += "   AND SEA.EA_AGEDEP = '"+mv_par19+"' "  + hEnter
		cSql += "   AND SEA.EA_NUMCON = '"+mv_par20+"' "  + hEnter*/

	Endif

	cSql += "	AND SE1.E1_SALDO	 > 0" + hEnter
	cSql += "   AND SE1.D_E_L_E_T_  <> '*'" + hEnter
	cSql += "   AND SA1.D_E_L_E_T_  <> '*'" + hEnter
	cSql += "	ORDER BY SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_VENCTO,SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA " + hEnter

	MemoWrite( ProcName() + ".SQL", cSql )

	TCQUERY cSql NEW ALIAS "TMPBOL1"
	TCSETFIELD("TMPBOL1","E1_EMISSAO","D",8,0)
	TCSETFIELD("TMPBOL1","E1_VENCTO" ,"D",8,0)
	dbSelectArea("TMPBOL1")
	aStruc := dbStruct()
	cArqTemp := CriaTrab(aStruc)

	if Select("TMPBOL2") >0

		TMPBOL2->(DBCLOSEAREA())

	EndIf

	dbUseArea( .T. ,, cArqTemp , "TMPBOL2" )

	APPEND FROM TMPBOL1
	cIndTSAL := CriaTrab(NIL,.F.)

	dbselectarea("TMPBOL1")
	dbCloseArea("TMPBOL1")

	dbSelectArea("TMPBOL2")
	dbGoTop()

	aCampos := {}
	aAdd(aCampos, {"E1_OK"     ,"",""          ,""})
	aAdd(aCampos, {"E1_PREFIXO","","Prefixo"   ,""})
	aAdd(aCampos, {"E1_NUM"    ,"","Nr.T�tulo" ,""})
	aAdd(aCampos, {"E1_PARCELA","","Parcela"   ,""})
	aAdd(aCampos, {"E1_TIPO"   ,"","Tipo"      ,""})
	aAdd(aCampos, {"E1_PORTADO","","Portador"  ,""})
	aAdd(aCampos, {"E1_SALDO"  ,"","Valor"     ,"@E 9,999,999.99"})
	aAdd(aCampos, {"E1_NUMBOR ","","Bordero "  ,""})
	aAdd(aCampos, {"E1_NUMBCO ","","Nosso N�m" ,""})
	aAdd(aCampos, {"E1_EMISSAO","","Emiss�o"   ,""})
	aAdd(aCampos, {"E1_VENCTO" ,"","Vencimento",""})
	aAdd(aCampos, {"E1_CLIENTE","","Cliente"   ,""})
	aAdd(aCampos, {"E1_LOJA"   ,"","Loja"      ,""})
	aAdd(aCampos, {"A1_NOME"   ,"","Cliente"   ,""})

	dbSelectArea("TMPBOL2")
	dbGoTop()

	If lImPDF <> nil
		aMarked:= {}
		Do While TMPBOL2->(!Eof())
			AADD(aMarked,.T.)
			TMPBOL2->(dbSkip())
		EndDo
		dbGoTop()
		MontaRel( aMarked,cNum,cSerie,Banco,Agen,Conta,lImPDF, nil  )
	Else
		DEFINE MSDIALOG oDlgTel TITLE "Sele��o de T�tulos " From 1,1 To 400,950 OF oMainWnd PIXEL

		oMark := MsSelect():New("TMPBOL2","E1_OK",,aCampos,@lInverte,@cMarca,{1,1,170,475})
		@ 180,010 Get nRegSel When .F. Size 35,25 Object _oReg
		oBtnConf   	:= TButton():New( 180,415,"Imprimir"		,,{|| (Exec := .T.,LJOB:= .F.,Close(oDlgTel)) },48,16,,,,.T.,,"Imprimir",,,,.F. )
		oBtnCanc   	:= TButton():New( 180,380,"Cancelar"		,,{|| (Exec := .F.,Close(oDlgTel)) },48,16,,,,.T.,,"Cancelar",,,,.F. )

		ObjectMethod(oMark:oBrowse,"Refresh()")
		oMark:bMark := {|| fContSel()}
		oMark:oBrowse:lhasMark = .t.
		oMark:oBrowse:lCanAllmark := .t.
		oMark:oBrowse:bAllMark := {|| fMarkAll(cMarca,oDlgTel,_oReg)}
		//oDlgTel:lMaximized := .T.
		ACTIVATE MSDIALOG oDlgTel CENTERED

		dbSelectArea("TMPBOL2")
		TMPBOL2->(dbGoTop())
		Do While !Eof()
			If Marked("E1_OK")
				AADD(aMarked,.T.)
			Else
				AADD(aMarked,.F.)
			EndIf
			dbSkip()
		EndDo
		dbGoTop()

		If Exec
			Processa({||lEnd:= MontaRel( aMarked,cNum,cSerie,Banco,Agen,Conta,lJOB, oDlgTel  ) } )
		Endif

	Endif
	RetIndex("SE1")
	fErase(cIndexName+OrdBagExt())

	dbSelectArea("TMPBOL2")
	dbCloseArea("TMPBOL2")

Return


Static Function fContSel()

	If Marked("E1_OK")
		nRegSel++
	Else
		nRegSel--
	Endif
	_oReg:Refresh()
Return


Static Function fMarkAll(cMarca,oDlgTel)
	Local nRecno := Recno()
	dbSelectArea("TMPBOL2")
	dbGotop()
	Do While !Eof()
		RecLock("TMPBOL2",.F.)
		If !Marked("E1_OK")
			E1_OK := cMarca
			nRegSel++
		Else
			E1_OK := "  "
			nRegSel--
		Endif
		MsUnlock()
		dbSkip()
	EndDo
	dbGoto(nRecno)
	oDlgTel:Refresh()
	_oReg:Refresh()

Return(.T.)

/*/{Protheus.doc} MontaRel
//TODO Monta Relat�rio
@author Diogo
@since 17/03/2017
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaRel( aMarked,cNum,cSerie,Banco,Agen,Conta,lFJOB,oDlgTel  )
	Local oPrint
	Local n 	:= 0
	Local nCnpj	:= SM0->M0_CGC

	Local aDadosEmp    := {	ALLTRIM(SM0->M0_NOMECOM)                                                  ,; //[1]Nome da Empresa
	SM0->M0_ENDCOB                                                            ,; //[2]Endere�o
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
	"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
	"CNPJ.: "+ Transform(nCnpj,"@R 99.999.999/9999-99")          		      ,; //[6]CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        ,; //[7]I.E
	Substr(SM0->M0_CODFIL,1,2)                        						   } //[8]M0_FILIAL

	Local aDadosTit
	Local aDadosBanco
	Local aDatSacado
	Local aBolText     := { "Ap�s o vencimento cobrar multa de 2% - R$ "	,;
	"Mora Di�ria de 0,10% (3% a.m.) - R$ "          		    ,;
	"Protestar ap�s 10 dias."              ,;
	"" 	}

	Local i            := 1
	Local CB_RN_NN     := {}
	Local nRec         := 0
	Local _nVlrAbat    := 0
	Local aDevice	:= {}
	Local cSession	:= GetPrinterSession()
	Local cDevice	:= GetProfString( cSession, "PRINTTYPE", "SPOOL", .T. )
	Local nPrintType:= 0
	Local nLocal	:= 0
	Local nRec		:= 0
	Local _nVlrAbat	:= 0
	Local nFlags	:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEPREVIEW+PD_DISABLEPAPERSIZE
	Local cPath    := "c:\boletos\"
	Local cNomArq	:= "BOL237"
	Local cTexto	:= ""
	Local cSubject	:= ""
	Local cAttach 	:= ""
	Local cBody		:= ""
	Local cCopyMail	:= ""
	Local aDadMail	:= {}
	Local aArea		:= getArea()
	Private cTitulo	:= "Relatorio Boleto"
	Default lFJOB	:= .F.

	DbSelectArea ("TMPBOL2")
	dbGoTop()
	Do While !EOF()
		nRec := nRec + 1
		dbSkip()
	EndDo
	dbGoTop()
	ProcRegua(nRec)

	AADD(aDevice,"DISCO")
	AADD(aDevice,"SPOOL")
	AADD(aDevice,"EMAIL")
	AADD(aDevice,"EXCEL")
	AADD(aDevice,"HTML" )
	AADD(aDevice,"PDF"  )
	nPrintType := aScan(aDevice,{|x| x == cDevice })
	nPrintType := aScan(aDevice,{|x| x == cDevice })
	nLocal     := If(GetProfString(cSession,"Local","SERVER",.T.)=="SERVER",1,2 )
	If lfJOB
		MakeDir(cPath)
	Endif

	i := 1
	DbSelectArea("TMPBOL2")
	Do While  !EOF()

		If aMarked[i]
			dBSelectArea( "SE1" )
			SE1->( dBSetOrder( 1 ) )
			SE1->( dBGoTop( ) )
			If !SE1->( dBSeek( xFilial( "SE1" ) + TMPBOL2->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO),.T.) )
				MsgBox("Titulo n�o Localizado [ " + TMPBOL2->E1_PREFIXO + " ]/[" + TMPBOL2->E1_NUM + "]/[" + TMPBOL2->E1_PARCELA + "] , [SE1]. Favor verificar !" )
				Return()
			Endif

			//Posiciona o SA6 (Bancos)
			dBSelectArea("SA6")
			SA6->( dBSetOrder( 1 ) )
			SA6->( dBgotop() )
			If cNum <> nil
				lFound := SA6->( MsSeek(xFilial( "SA6" ) + c_Banco + c_Agen + c_Conta ) )
			Else
				lFound := SA6->( MsSeek( xFilial( "SA6" ) + MV_PAR18 + MV_PAR19 + MV_PAR20 ) )
			EndIf
			If !lFound
				If cNum <> nil
					MsgBox("Banco n�o Localizado, Bco [ " + c_Banco + " ]/Ag.: [" + c_Agen + "]/CC: [" + c_Conta + "] , [SA6]. Favor verificar !" )
				Else
					MsgBox("Banco n�o Localizado, Bco [ " + MV_PAR18 + " ]/Ag.: [" + MV_PAR19 + "]/CC: [" + MV_PAR20 + "] , [SA6]. Favor verificar !" )
				Endif
				Return()
			EndIf

			//Posiciona na Arq de Parametros CNAB
			DbSelectArea( "SEE" )
			SEE->( dBSetOrder( 1 ) )
			SEE->( dBgotop( ) )
			lFound := .T.
			If cNum <> nil
				lFound := SEE->( MsSeek( xFilial( "SEE" ) + c_Banco + c_Agen + c_Conta ) )
			Else
				lFound := SEE->( MsSeek( xFilial( "SEE" ) + MV_PAR18 + MV_PAR19 + MV_PAR20 ) )
			EndIf
			If !lFound
				If cNum <> nil
					MsgBox("Parametros do Banco n�o Localizados, Bco [ " + c_Banco + " ]/Ag.: [" + c_Agen + "]/CC: [" + c_Conta + "] , [SEE]. Favor verificar !" )
				Else
					MsgBox("Parametros do Banco n�o Localizados, Bco [ " + MV_PAR18 + " ]/Ag.: [" + MV_PAR19 + "]/CC: [" + MV_PAR20 + "] , [SEE]. Favor verificar !" )
				Endif
				Return()
			EndIf

			//Posiciona o SA1 (Cliente)
			DbSelectArea( "SA1" )
			SA1->( dBSetOrder( 1 ) )
			SA1->( dBGoTop( ) )
			If !SA1->( dBSeek( xFilial( "SA1" ) + TMPBOL2->E1_CLIENTE + TMPBOL2->E1_LOJA ) )
				MsgBox( "Cliente n�o Localizado, [" + TMPBOL2->E1_CLIENTE + "]/[" + TMPBOL2->E1_LOJA + "], [SA1]. Favor verificar !" )
				Return()
			Endif

			DbSelectArea("TMPBOL2")
			aDadosBanco  := { "237-2"                                     ,; // SA6->A6_COD [1]Numero do Banco
			SA6->A6_NOME      	            	                 	      ,; // [2]Nome do Banco
			AllTrim(SA6->A6_AGENCIA)		                          	  ,; // [3]Ag�ncia
			(AllTrim(SA6->A6_NUMCON))         						      ,; // [4]Conta Corrente
			AllTrim(SA6->A6_DVCTA)								  	      ,; // [5]D�gito da conta corrente
			SEE->EE_CODCART												  ,; // [6]Codigo da Carteira 009
			Trim(SEE->EE_CODEMP)       								       } // [7] Cod. Conv�nio 

			If Empty(SA1->A1_ENDCOB)
				aDatSacado   := { AllTrim(SA1->A1_NOME)           	        	        	  ,; // [1]Raz�o Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	       	  ,; // [2]C�digo
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO) 	      ,; // [3]Endere�o
				AllTrim(SA1->A1_MUN )                             	      ,; // [4]Cidade
				SA1->A1_EST                                       	      ,; // [5]Estado
				SA1->A1_CEP                                      	      ,; // [6]CEP
				SA1->A1_CGC										 	       } // [7]CGC
			Else
				aDatSacado   := { AllTrim( SA1->A1_NOME   )                                   ,; // [1]Raz�o Social
				AllTrim( SA1->A1_COD    ) + "-" + SA1->A1_LOJA              ,; // [2]C�digo
				AllTrim( SA1->A1_ENDCOB ) + "-" + AllTrim( SA1->A1_BAIRROC ),; // [3]Endere�o
				AllTrim( SA1->A1_MUNC   )	                                  ,; // [4]Cidade
				SA1->A1_ESTC	                                              ,; // [5]Estado
				SA1->A1_CEPC                                                ,; // [6]CEP
				SA1->A1_CGC									      	       } // [7]CGC
			Endif

			_nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)


			If Empty( SE1->E1_CODBAR )
				CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],SEE->EE_FAXATU,(E1_SALDO-_nVlrAbat),E1_VENCTO,E1_DECRESC)
			Else
				CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],Subs(SE1->E1_NUMBCO,1,12),(E1_SALDO-_nVlrAbat),E1_VENCTO,E1_DECRESC)
			Endif

			Aadd(aDadMail,{Strzero(VAL(E1_NUM),9) ,;
			Strzero(VAL(E1_PARCELA),3)  ,;
			cValTochar(SE1->E1_EMISSAO) ,;
			cValTochar(SE1->E1_VENCTO) 	,;
			AllTrim(Transform(SE1->E1_SALDO - _nVlrAbat,"@E 999,999,999.99")) ,;
			SE1->(E1_CLIENTE+E1_LOJA) 	,;
			''		 					,;
			date()						,;
			time()						,;
			SA1->A1_NOME				,;
			SE1->E1_NUMBOR				,;
			''							,;
			''							;
			} )

			aDadosTit   := { E1_NUM+E1_PARCELA	                ,;  // [1] N�mero do t�tulo
			E1_EMISSAO                              			,;  // [2] Data da emiss�o do t�tulo
			Date()                                  			,;  // [3] Data da emiss�o do boleto
			E1_VENCTO                               			,;  // [4] Data do vencimento
			(E1_SALDO - _nVlrAbat)                  			,;  // [5] Valor do t�tulo
			CB_RN_NN[3]                             			,;  // [6] Nosso n�mero (Ver f�rmula para calculo)
			AllTrim(E1_PREFIXO)                           		,;  // [7] Prefixo da NF
			"DM"	                               				,;  // [8] Tipo do Titulo   //E1_TIPO
			E1_TIPO											,;      // [9] Tipo do Titulo
			SE1->E1_YMSGBO			          					,;  // [10] Mensagem p/ Boleto
			SE1->E1_CODDIG                                   	,;  // [11] Linha Digit�vel do T�tulo
			SE1->E1_NUM                                     	,; 	// [12] Numero da fatura
			SE1->E1_DECRESC                                  	,; 	// 	[13] DESCONTO
			SE1->E1_FIlORIG									,; 	// [14] Filial Origem
			AllTrim(SE1->E1_FATURA) 				        	,;  // [15] Fatura
			AllTrim(SE1->E1_NFELETR) 				        	}  	// [16] E1_NFELETR

			If aMarked[i]
				cNumParc := IIF(EMPTY(SE1->E1_PARCELA), "", "-"+SE1->E1_PARCELA)
				cNomArq		:= UPPER(aDatSacado[1]) + "-" + SE1->(E1_NUM) + cNumParc
				//oPrint	:= FWMSPrinter():New( cNomArq, IMP_PDF , .T., cPath, .T., , , , , , .F., )
				oPrint	:= FWMSPrinter():New( cNomArq, IMP_PDF , .T., '\SPOOL\', .T., , , , , , .F., )
				oPrint:cPathPDF:= cPath
				oPrint:cPathPrint:= cPath
				oPrint:lInJob	:= .T.
				oPrint:lServer	:= .F.
				oPrint:lViewPDF	:= .F. 

				oPrint:nDevice := IMP_PDF
				oPrint:SetResolution(82)
				oPrint:SetPortrait()
				oPrint:SetPaperSize(DMPAPER_A4) //A4
				oPrint:SetMargin(12,12,12,12) // nEsquerda, nSuperior, nDireita, nInferior
				oPrint:Setup()
				Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
				n := n + 1
			EndIf
			If lFJob
				//oPrint:Preview()// Visualiza antes de imprimir
				Sleep(2000)
			Endif
		EndIf
		DbSelectArea("TMPBOL2")
		dbskip()
		IncProc()
		i := i + 1
	EndDo
	If !lFJob
		//oPrint:Preview()// Visualiza antes de imprimir
	Endif

	oPrint:EndPage()
	//oPrint:Preview()

	FreeObj(oPrint)
	oPrint := nil

	RestArea( aArea)
Return .T.

/*/{Protheus.doc} Impress
//TODO Impress�so do Boleto
@author Diogo
@since 17/03/2017
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)  //nParte 1 (Comprovante de Entrega,2 (Recibo do Sacado) ou 3 (Ficha de Compensa��o)
	Private oBrush
	Private n_Juros := SuperGetMv( "MV_TXPER",,0.03 ) / 100    	//percentual de juros por dia
	Private n_Multa := SuperGetMv( "SV_BMULTA",,2.00 ) /100  	//percentual da multa
	Private M->MsgLin1  := MV_PAR21
	Private M->MsgLin2  := MV_PAR22
	aTmpDados   := {}

	oBrush := TBrush():New("",4)

	oPrint:StartPage()   // Inicia uma nova p�gina
	ImpParte(1,oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN, aTmpDados)
	ImpParte(2,oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN, aTmpDados)
	ImpParte(3,oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN, aTmpDados)

	DbSelectArea("SE1")
	If Empty(SE1->E1_NUMBCO) .AND. SUBSTR(SE1->E1_TIPO,3,1) != "-"
		RecLock("SE1",.f.)
		SE1->E1_CODBAR  := CB_RN_NN[1]			 		 // Codigo de Barras
		SE1->E1_CODDIG  := CB_RN_NN[2]		               		// Linha Digitavel
		SE1->E1_NUMBCO  := CB_RN_NN[3]               			// Nosso n�mero
		SE1->E1_PORTADO := SUBSTR(aDadosBanco[1],1,3)			// Banco
		SE1->E1_AGEDEP	:= aDadosBanco[3]				// Agencia
		SE1->E1_CONTA	:= aDadosBanco[4]				// Conta


		If Empty( SE1->E1_NUMBOR )
			SE1->E1_SITUACA  := "0"
		EndIf

		MsUnlock()

		DbSelectArea("SEE")
		RecLock("SEE",.f.)
		SEE->EE_FAXATU := Strzero(VAL(SEE->EE_FAXATU)+1,11)
		MsUnlock()
	EndIf


	If SE1->E1_CODBAR != CB_RN_NN[1]
		RecLock("SE1",.f.)
		SE1->E1_CODBAR  := CB_RN_NN[1]
		MsUnlock()
	EndIf

	If SE1->E1_CODDIG != CB_RN_NN[2]
		RecLock("SE1",.f.)
		SE1->E1_CODDIG  := CB_RN_NN[2]
		MsUnlock()
	EndIf


	DbSelectArea("SE1")

	oPrint:EndPage() // Finaliza a p�gina
	//oPrint:Preview()

	If(LEN(aTmpDados)>=1)

		Contr := 1
		linha := 1

		For i := 1 to LEN(aTmpDados)
			IF(linha<=200)
				linha++
				If(Contr==1)
					Contr := 2
					oPrint:StartPage()
					ImpParte(1,oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN, aTmpDados)

					c := 0
					l := 30
					col := 1
					l1 := 650
					c1 := 110
					c2 := 170
					c3 := 200
					c4 := 430

					nLin := 600
					oPrint:Say  (570,2000,"Listagem dos CTRC's",oFont10)
					oPrint:Line (600, 100,600,2300 )

					oPrint:Say  (610,110,"Filial",oFont10)
					oPrint:Say  (610,200,"CTRC",oFont10)
					oPrint:Say  (610,450,"Valor",oFont10)

					oPrint:Say  (610,910,"Filial",oFont10)
					oPrint:Say  (610,1000,"CTRC",oFont10)
					oPrint:Say  (610,1250,"Valor",oFont10)

					oPrint:Say  (610,1710,"Filial",oFont10)
					oPrint:Say  (610,1800,"CTRC",oFont10)
					oPrint:Say  (610,2050,"Valor",oFont10)

					oPrint:Line (640, 100,640,2300 )

					oPrint:Line (600,100,3440,100 )
					oPrint:Line (600,2300,3440,2300 )

					oPrint:Line (3440, 100,3440,2300 )

				EndIf

				if col <= 3
					oPrint:Say  (l1+l,c1+c,cValToChar(aTmpDados[i,1]),oFont10)
					oPrint:Say  (l1+l,c2+c,cValToChar(aTmpDados[i,2]),oFont10)
					oPrint:Say  (l1+l,c3+c,cValToChar(aTmpDados[i,3]),oFont10)
					oPrint:Say  (l1+l,c4+c,cValToChar(aTmpDados[i,4]),oFont10)
					c := c + 800
					col := col + 1
				Else
					l := l + 40
					col := 1
					c := 0

					oPrint:Say  (l1+l,c1+c,cValToChar(aTmpDados[i,1]),oFont10)
					oPrint:Say  (l1+l,c2+c,cValToChar(aTmpDados[i,2]),oFont10)
					oPrint:Say  (l1+l,c3+c,cValToChar(aTmpDados[i,3]),oFont10)
					oPrint:Say  (l1+l,c4+c,cValToChar(aTmpDados[i,4]),oFont10)

					c := c + 800
					col := col + 1
				EndIf

			Else

				oPrint:Say  (3400,110,"Informa��o: A listagem dos CTRC's continuar� em uma nova p�gina.",oFont10)
				oPrint:EndPage()
				//oPrint:Preview()
				Contr := 1
				linha := 1
				i--
			EndIF
			oPrint:EndPage()
			//oPrint:Preview()
		Next i
		//oPrint:EndPage()
	EndIf
	oPrint:EndPage()
	oPrint:Preview()


Return()

Static Function ImpParte(nParte,oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN, aTmpDados)
	Local i := 0
	Local cLogoBco  := "\system\logobradesco.png"
	Local _VENCTO 	:= IIF( LEN( DTOC( aDadosTit[ 4 ] ) ) == 8, SUBSTR( DTOC( aDadosTit[ 4 ] ),1, 6 ) + "20" + SUBSTR( DTOC( aDadosTit[ 4 ]),7,2),aDadostit[ 4 ])
	Local _EMISS	:= IIF( LEN( DTOC( aDadosTit[ 2 ] ) ) == 8, SUBSTR( DTOC( aDadosTit[ 2 ] ),1, 6 ) + "20" + SUBSTR( DTOC( aDadosTit[ 2 ]),7,2),aDadostit[ 2 ])
	Local _DTBASE	:= IIF( LEN( DTOC( aDadosTit[ 3 ] ) ) == 8, SUBSTR( DTOC( aDadosTit[ 3 ] ),1, 6 ) + "20" + SUBSTR( DTOC( aDadosTit[ 3 ]),7,2),aDadostit[ 3 ])
	Local _CodBar	:= CB_RN_NN[1]
	Local _CodDig	:= CB_RN_NN[2]
	Local nDiffPDF	:= 23 //Impress�o via pdf

	If nParte == 1
		nLin := 00150
		nDiffPDF := 28 //Impress�o via pdf
		oPrint:Line (nLin,550,0050,0550)
		oPrint:Line (nLin,760,0050,0760)
		oPrint:SayBitmap(0045,100,cLogoBco,0445,0110 )     // Logo
		oPrint:Say  (0095+nDiffPDF,560,aDadosBanco[1],oFont24 )	  // [1]Numero do Banco
		oPrint:Say  (0084,1900,"Comprovante de Entrega",oFont10)
		oPrint:Line (0150,100,0150,2300)
		oPrint:Say  (0150+nDiffPDF,100 ,"Beneficiario"                                        	,oFont10)

		oPrint:Say  (0200+nDiffPDF,100, SM0->M0_NOMECOM, oFont10) //Nome + CNPJ

		oPrint:Say  (0150+nDiffPDF,1060,"Ag�ncia/C�d Beneficiario"                         	,oFont10)
		oPrint:Say  (18+0200+nDiffPDF,1080,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
		oPrint:Say  (0150+nDiffPDF,1510,"Nro.Documento"                                  	,oFont10)
		oPrint:Say  (18+0200+nDiffPDF,1530,aDadosTit[7]+aDadosTit[1]+aDadosTit[9]          	,oFont10) //Prefixo+Numero+Parcela+Tipo
		oPrint:Say  (0250+nDiffPDF,100 ,"Pagador"                                         	,oFont10)
		oPrint:Say  (0300+nDiffPDF,100 ,aDatSacado[1]                                    	,oFont09)	//Nome
		oPrint:Say  (0250+nDiffPDF,1060,"Vencimento"                                     	,oFont10)
		oPrint:Say  (20+0300+nDiffPDF,1080,DTOC(aDadosTit[4])                               	,oFont10)
		oPrint:Say  (0250+nDiffPDF,1510,"Valor do Documento"                          		,oFont10)
		oPrint:Say  (20+0300+nDiffPDF,1530,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10)
		oPrint:Say  (0400,0100,"Recebi(emos) o bloqueto/t�tulo"                 	,oFont10)
		oPrint:Say  (0450,0100,"com as caracter�sticas acima."             			,oFont10)
		oPrint:Say  (0350+nDiffPDF,1060,"Data"                                           	,oFont10)
		oPrint:Say  (0450+nDiffPDF,1060,"Assinatura(Nome por extenso)"                  		,oFont10)

		oPrint:Line (0250, 100,0250,1900 )
		oPrint:Line (0350, 100,0350,1900 )
		oPrint:Line (0450,1050,0450,1900 )
		oPrint:Line (0550, 100,0550,2300 )

		oPrint:Line (0550,1050,0150,1050 )
		oPrint:Line (0350,1500,0150,1500 )
		oPrint:Line (0550,1900,0150,1900 )

		oPrint:Say  (0160+nDiffPDF,1910,"(  )Mudou-se"                                	,oFont10)
		oPrint:Say  (0200+nDiffPDF,1910,"(  )Ausente"                                    ,oFont10)
		oPrint:Say  (0240+nDiffPDF,1910,"(  )N�o existe n� indicado"                  	,oFont10)
		oPrint:Say  (0280+nDiffPDF,1910,"(  )Recusado"                                	,oFont10)
		oPrint:Say  (0320+nDiffPDF,1910,"(  )N�o procurado"                              ,oFont10)
		oPrint:Say  (0360+nDiffPDF,1910,"(  )Endere�o insuficiente"                  	,oFont10)
		oPrint:Say  (0400+nDiffPDF,1910,"(  )Desconhecido"                            	,oFont10)
		oPrint:Say  (0440+nDiffPDF,1910,"(  )Falecido"                                   ,oFont10)
		oPrint:Say  (0480+nDiffPDF,1910,"(  )Outros(anotar no verso)"                  	,oFont10)

	ElseIf nParte == 2

		nLin := 600
		oPrint:Line (600, 100,600,2300 )
		oPrint:Say  (570+nDiffPDF,2000,"Recibo do Pagador",oFont10)

		//	oPrint:Line (600,100,2050,100)
		oPrint:Say  (610+nDiffPDF,110,"Beneficiario",oFont09)

		oPrint:Say  (640+nDiffPDF,110,SM0->M0_NOMECOM,oFont10)
		oPrint:Say  (670+nDiffPDF,110,"CNPJ: "+Alltrim(Transform( SM0->M0_CGC, "@R 99.999.999/9999-99")),oFont10)

		oPrint:Line (600,1300,995,1300)
		oPrint:Say  (610+nDiffPDF,1310,"Ag�ncia/C�d Beneficiario",oFont09)
		oPrint:Say  (33+640+nDiffPDF,1472,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5] ,oFont10)


		oPrint:Line (600,1800,995,1800)
		oPrint:Say  (610+nDiffPDF,1810,"Vencimento",oFont09)
		oPrint:Say  (33+640+nDiffPDF,2160-150+17,DTOC(aDadosTit[4]) ,oFont10)


		oPrint:Line (700, 100,700,2300 )
		oPrint:Say  (710+nDiffPDF, 110,"Pagador",oFont09)
		oPrint:Say  (740+nDiffPDF, 110,aDatSacado[1]+" (CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99")+")" ,oFont10)

		oPrint:Say  (710+nDiffPDF,1310,"N�mero do Documento",oFont09)
		oPrint:Say  (29+740+nDiffPDF,1472,aDadosTit[7]+aDadosTit[1]+aDadosTit[9]  ,oFont10)

		oPrint:Say  (710+nDiffPDF,1810,"Nosso N�mero",oFont09)
		nDifPDFCOL:= 150
		If Empty(SE1->E1_NUMBCO)
			oPrint:Say  (29+740+nDiffPDF,2160-nDifPDFCOL+17, SUBSTR( Alltrim( aDadosTit[6] ),1,3)+SUBSTR(Alltrim( aDadosTit[6] ),4,Len(Alltrim(aDadosTit[6]))),oFont10,,,,1)
		Else
			oPrint:Say  (29+740+nDiffPDF,2160-nDifPDFCOL+17, SUBSTR(SE1->E1_NUMBCO,1,3)+SUBSTR(Alltrim( SE1->E1_NUMBCO ),4,Len(Alltrim(SE1->E1_NUMBCO))),oFont10,,,,1)
		Endif

		oPrint:Line (800,100,800,2300 )
		oPrint:Say  (810+nDiffPDF,110,"Esp�cie",oFont09)
		oPrint:Say  (7+840+nDiffPDF,150,"R$" ,oFont10)

		oPrint:Line (800,330,895,330 )
		oPrint:Say  (810+nDiffPDF,340,"Quantidade",oFont09)


		oPrint:Line (800,630,895,630 )
		oPrint:Say  (810+nDiffPDF,640,"(x)Valor",oFont09)

		oPrint:Say  (810+nDiffPDF,1310,"(=)Valor do Documento",oFont09)
		oPrint:Say  (24+840+nDiffPDF,1472,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)


		oPrint:Line (800,630,895,630 )
		oPrint:Say  (810+nDiffPDF,1810,"(-)Desconto",oFont09)
		oPrint:Say  (24+840+nDiffPDF,2160-nDifPDFCOL+17,IIF(aDadosTit[13] != 0, AllTrim(Transform(aDadosTit[13],"@E 999,999,999.99")),""),oFont10)

		//	oPrint:Line (600, 2300,2050,2300 )
		//	oPrint:Line (2050, 100,2050,2300 )


		oPrint:Line (895,100,895,2300)

		oPrint:Say  (950+nDiffPDF,110,"Demonstrativo:",oFont09)

		oPrint:Say  (910+nDiffPDF,1310,"(+)Outros Acr�scimos",oFont09)

		oPrint:Line (895,100,895,2300)
		oPrint:Say  (910+nDiffPDF,1810,"(=)Valor Cobrado",oFont09)


		oPrint:Line (995,100,995,2300)
		nDiffPDF := 23 //Impress�o via pdf

	ElseIf nParte == 3

		nDiffPDF 	:= 25 //Impress�o via pdf
		nDifPDFCOL	:= 95
		nlin := 1150
		oPrint:Say  (nLin+1045+nDiffPDF,1580,"C�digo de Baixa"  ,oFont10)
		oPrint:Say  (nLin+1085+nDiffPDF,1930,"Ficha de Compensa��o"  ,oFont10)

		//MSBAR3("INT25"  ,19.8,1.0,_CodBar,oPrint,.F.,,,,1.2,,,,.F.)
		oPrint:FWMSBAR("INT25",53, 2,_CodBar,oPrint,.F.,,,,1.2,,,,.F.)      

		For i := 100 to 2300 step 50
			oPrint:Line( nLin, i, nLin, i+30)
		Next i

		oPrint:Line (nlin+150,100,nlin+150,2300)
		oPrint:Line (nlin+150,550,nlin+50, 550)
		oPrint:Line (nlin+150,760,nlin+50, 760)
		oPrint:SayBitmap(nlin+45,110,cLogoBco,0435,0100 ) 	// Logo
		oPrint:Say  (nlin+95+nDiffPDF,560,aDadosBanco[1],oFont24 )	// [1]Numero do Banco

		If Empty( SE1->E1_NUMBCO) .or. _CodDig != aDadosTit[11]
			oPrint:Say  (30+nLin+84+nDiffPDF,780+40,Transform(_CodDig,"@R 99999.99999  99999.999999  99999.999999  9  99999999999999"),oFont18n)
		Else
			oPrint:Say  (30+nLin+84+nDiffPDF,780+40,Transform(aDadosTit[11],"@R 99999.99999  99999.999999  99999.999999  9  99999999999999"),oFont18n)
		Endif

		oPrint:Line (nLin+250,100,nLin+250,2300 )
		oPrint:Line (nLin+350,100,nLin+350,2300 )
		oPrint:Line (nLin+420,100,nLin+420,2300 )
		oPrint:Line (nLin+490,100,nLin+490,2300 )

		oPrint:Line (nLin+350,0500,nLin+490,500)
		oPrint:Line (nLin+420,0750,nLin+490,750)
		oPrint:Line (nLin+350,1000,nLin+490,1000)
		oPrint:Line (nLin+350,1350,nLin+420,1350)
		oPrint:Line (nLin+350,1550,nLin+490,1550)

		oPrint:Say  (nLin+150+nDiffPDF,100 ,"Local de Pagamento"                             			,oFont10)
		oPrint:Say  (nLin+190+nDiffPDF,100 ,"PAG�VEL PREFERENCIALMENTE NA REDE BRADESCO OU BRADESCO EXPRESSO. "     			,oFont10)

		oPrint:Say  (nLin+150+nDiffPDF,1910,"Vencimento"                                     			,oFont10)
		oPrint:Say  (25+nLin+190+nDiffPDF+2,2212-nDifPDFCOL-64,DTOC(aDadosTit[4])                               			,oFont10,,,,1)

		oPrint:Say  (nLin+250+nDiffPDF,100 ,"Beneficiario" ,oFont10)

		oPrint:Say  (nLin+260+nDiffPDF,280 ,Alltrim(SM0->M0_NOMECOM)+" - CNPJ: "+Alltrim(Transform( SM0->M0_CGC, "@R 99.999.999/9999-99")) ,oFont10)     //Nome + CNPJ
		oPrint:Say  (nLin+310+nDiffPDF,280 ,Alltrim(SM0->M0_ENDCOB)+" - "+ Alltrim(SM0->M0_BAIRCOB)+", "+Alltrim(SM0->M0_CIDCOB)+","+SM0->M0_ESTCOB+" - CEP: "+ Alltrim(SM0->M0_CEPCOB),oFont10)

		oPrint:Say  (nLin+250+nDiffPDF,1910,"Ag�ncia/C�d Beneficiario"                         			,oFont10)
		oPrint:Say  (29+nLin+290+nDiffPDF,2212-nDifPDFCOL-64,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10,,,,1)

		oPrint:Say  (nLin+350+nDiffPDF,100 ,"Data do Documento"                              			,oFont10)
		oPrint:Say  (7+nLin+380+nDiffPDF,100 ,DTOC(aDadosTit[2])                               			,oFont10)

		oPrint:Say  (nLin+350+nDiffPDF,505 ,"Nro.Documento"                                  			,oFont10)
		oPrint:Say  (7+nLin+380+nDiffPDF,605 ,aDadosTit[7]+aDadosTit[1]+aDadosTit[9]   					,oFont10) //Prefixo +Numero+Parcela+Tipo

		oPrint:Say  (nLin+350+nDiffPDF,1005,"Esp�cie Doc."                                   			,oFont10)
		oPrint:Say  (7+nLin+380+nDiffPDF,1050,"DM"															,oFont10) //Tipo do Titulo


		oPrint:Say  (nLin+350+nDiffPDF,1355,"Aceite"                                         			,oFont10)
		oPrint:Say  (7+nLin+380+nDiffPDF,1370,"N"                                            			,oFont10)

		oPrint:Say  (nLin+350+nDiffPDF,1555,"Data do Processamento"                        				,oFont10)
		oPrint:Say  (7+nLin+380+nDiffPDF,1685,DTOC(aDadosTit[3])                               			,oFont10) // Data impressao

		oPrint:Say  (nLin+350+nDiffPDF,1910,"Nosso N�mero"                                 				,oFont10)

		If Empty( SE1->E1_NUMBCO )
			oPrint:Say  (7+nLin+380+nDiffPDF,2212-nDifPDFCOL-64, SUBSTR( Alltrim( aDadosTit[6] ),1,3)+SUBSTR(Alltrim( aDadosTit[6] ),4,Len(Alltrim(aDadosTit[6])))   	,oFont10,,,,1)

		Else
			oPrint:Say  (7+nLin+380+nDiffPDF,2212-nDifPDFCOL-64, SUBSTR(SE1->E1_NUMBCO,1,3)+SUBSTR(Alltrim( SE1->E1_NUMBCO ),4,Len(Alltrim(SE1->E1_NUMBCO)))   	,oFont10,,,,1)

		Endif

		oPrint:Say  (nLin+420+nDiffPDF,100 ,"Uso do Banco"                                   			,oFont10)

		oPrint:Say  (nLin+420+nDiffPDF,505 ,"Carteira"                                       			,oFont10)
		oPrint:Say  (7+nLin+450+nDiffPDF,555 ,aDadosBanco[6]                                  				,oFont10)

		oPrint:Say  (nLin+420+nDiffPDF,755 ,"Esp�cie"                                        			,oFont10)
		oPrint:Say  (7+nLin+450+nDiffPDF,805 ,"R$"                                             			,oFont10)


		oPrint:Say  (nLin+420+nDiffPDF,1005,"Quantidade"                                     			,oFont10)
		oPrint:Say  (nLin+420+nDiffPDF,1555,"Valor"                                          			,oFont10)

		oPrint:Say  (nLin+420+nDiffPDF,1910,"Valor do Documento"                          	   			,oFont10)
		oPrint:Say  (7+nLin+450+nDiffPDF,2212-nDifPDFCOL-64,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))			,oFont10,,,,1)

		oPrint:Say  (nLin+490+nDiffPDF,100 ,"Instru��es (Todas informa��es deste bloqueto s�o de exclusiva responsabilidade do Beneficiario)",oFont10)

		oPrint:Say  (nLin+540+nDiffPDF,100 ,aBolText[1] +" "+ AllTrim(Transform((aDadosTit[5]*n_Multa),"@E 99,999.99"))	,oFont10)
		oPrint:Say  (nLin+590+nDiffPDF,100 ,aBolText[2] +" "+ AllTrim(Transform((aDadosTit[5]*n_Juros),"@E 99,999.99")) 	,oFont10)
		oPrint:Say  (nLin+640+nDiffPDF,100 ,aBolText[3]                                                                 	,oFont10)
		oPrint:Say  (nLin+690+nDiffPDF,100 ,aBolText[4]                                                                 	,oFont10)

		If Empty( SE1->E1_YMSGBO )
			oPrint:Say  (nLin+740+nDiffPDF,100 ,M->MsgLin1                                                               	,oFont10)
			oPrint:Say  (nLin+790+nDiffPDF,100 ,M->MsgLin2                                                               	,oFont10)
		Else
			oPrint:Say  (nLin+690+nDiffPDF,100 ,aDadosTit[10]                                                               	,oFont10)
		EndIf

		oPrint:Say  (nLin+490+nDiffPDF,1910,"(-)Desconto/Abatimento"                         ,oFont10)
		oPrint:Say  (7+nLin+520+nDiffPDF,2212-nDifPDFCOL-64,IIF(aDadosTit[13] != 0, AllTrim(Transform(aDadosTit[13],"@E 999,999,999.99")),"")		,oFont10,,,,1)

		oPrint:Say  (nLin+560+nDiffPDF,1910,"(-)Outras Dedu��es"                             ,oFont10)
		oPrint:Say  (nLin+630+nDiffPDF,1910,"(+)Mora/Multa"                                  ,oFont10)
		oPrint:Say  (nLin+700+nDiffPDF,1910,"(+)Outros Acr�scimos"                           ,oFont10)
		oPrint:Say  (nLin+770+nDiffPDF,1910,"(=)Valor Cobrado"                               ,oFont10)

		oPrint:Say  (nLin+840+nDiffPDF,0100,"Pagador"                                         ,oFont10)
		oPrint:Say  (nLin+870+nDiffPDF,0100,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
		oPrint:Say  (nLin+923+nDiffPDF,0100,aDatSacado[3]                                    ,oFont10)
		oPrint:Say  (nLin+976+nDiffPDF,0104,"CEP: "+aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]+"   "+IIF(SA1->A1_PESSOA=="J","CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99")),oFont10) // CEP+Cidade+Estado+CNPJ/CPF
		//	    oPrint:Say  (nLin+976,1500,_CodBar)  //Impressao numerica do cod. Barras para conferencia
		oPrint:Say  (nLin+1045+nDiffPDF,0100,"Pagador/Avalista"                               ,oFont10)
		oPrint:Say  (nLin+1085+nDiffPDF,1580,"Autentica��o Mec�nica -"                        ,oFont10)

		oPrint:Line (nLin+150,1900,nLin+840,1900 )
		oPrint:Line (nLin+560,1900,nLin+560,2300 )
		oPrint:Line (nLin+630,1900,nLin+630,2300 )
		oPrint:Line (nLin+700,1900,nLin+700,2300 )
		oPrint:Line (nLin+770,1900,nLin+770,2300 )
		oPrint:Line (nLin+840,0100,nLin+840,2300 )
		oPrint:Line (nLin+1080,100,nLin+1080,2300)

	EndIf


Return

Static Function MontaNF(cNum, cFilOrig)

	Local  hEnter := Chr( 13 )
	Local  aRegs := {}
	Local  aDados := {}
	Local  aAreatmp := getArea()

	cSql := "SELECT D.D2_FILIAL," + hEnter
	cSql += "       D.D2_SERIE," + hEnter
	cSql += "       D.D2_DOC,  " + hEnter
	cSql += "       D.D2_TOTAL," + hEnter
	cSql += "       B.B1_DESC" + hEnter
	cSql += " FROM SD2010 AS D" + hEnter
	cSql += " LEFT JOIN SB1010 AS B  ON B.B1_COD = D.D2_COD " + hEnter
	cSql += " WHERE D.D2_DOC = '" + cNum + "'" + hEnter
	cSql += " AND D.D2_FILIAL = '" + cFilOrig + "'" + hEnter
	cSql += " AND D.D_E_L_E_T_  <> '*'" + hEnter


	TCQUERY cSql NEW ALIAS "TMPBOL4"
	dbSelectArea("TMPBOL4")
	dbGoTop()

	Do While !Eof()
		AADD(aRegs,{SubStr(TMPBOL4->D2_FILIAL,5,3),TMPBOL4->D2_SERIE,TMPBOL4->D2_DOC,Transform(TMPBOL4->D2_TOTAL,"@E 999,999,999.99"),TMPBOL4->B1_DESC})
		dbSkip()
	EndDo
	dbGoTop()

	dbCloseArea("TMPBOL4")
	restArea(aAreatmp)
Return (aRegs)


Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End

Return(D)

Static Function Modulo11(cData,lNossoNum_DV)
	Local L := Len(cdata)
	Local D := 0
	Local P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	If lNossoNum_DV
		D := mod(D,11)
		If D == 10
			D := 1
		ElseIf D == 0 .OR. D == 1
			D := 0
		Else
			D := 11 - D
		EndIf
	Else
		D := D * 10
		D := mod(D,11)
		If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
			D := 1
		EndIf
	EndIf
Return(D)

Static Function Modulo11NN(cData)
	LOCAL L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 7
			P := 1
		End
		L := L - 1
	End
	D := 11 - (mod(D,11))
	If (D == 11)
		D := "0"
	Elseif (D == 10)
		D := "P"
	End

Return(D)

//Retorna os strings para inpress�o do Boleto
//CB = String para o c�d.barras, RN = String com o n�mero digit�vel
//Cobran�a n�o identificada, n�mero do boleto = T�tulo + Parcela

//mj Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

//					    		   Codigo Banco            Agencia		  C.Corrente     Digito C/C
//					               1-cBancoc               2-Agencia      3-cConta       4-cDacCC       5-cNroDoc              6-nValor
//	CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],"175"+AllTrim(E1_NUM),(E1_VALOR-_nVlrAbat) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ RAIMUNDO PEREIRA      ³ Data ³ 01/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ�ÄÄÄÄÄÄÄ�ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ�ÄÄÄÄÄÄ�ÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄ�ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,nDesc)

	Local cNroDoc      := IIF(!Empty(SE1->E1_NUMBCO), SUBSTR(SE1->E1_NUMBCO,3,11), Strzero(VAL(SEE->EE_FAXATU),11))
	Local bldocnufinal := Strzero(val(cNroDoc),11)
	Local blvalorfinal := Strzero(((nValor - nDesc)*100),10)
	Local NN           := ''
	Local RN           := ''
	Local CB           := ''
	Local s            := ''
	Local _cfator      := Strzero(dVencto - ctod("07/10/97"),4)
	Local _cCart	   := SUBSTR(SEE->EE_CODCART,2,2)

	nValor := nValor - nDesc

	//-------- Definicao do NOSSO NUMERO
	//s    :=  cAgencia + cConta + _cCart + bldocnufinal
	s    := _cCart + bldocnufinal

	dvnn := modulo11NN(s,.T.) // digito verifacador Agencia + Conta + Carteira + Nosso Num
	//NN   := _cCart + bldocnufinal + '-' + AllTrim(Str(dvnn))

	NN   := s + '-' + AllTrim(cValtoChar(dvnn))

	_NNCB := bldocnufinal + AllTrim(cValtoChar(dvnn))

	//	-------- Definicao do CODIGO DE BARRAS
	//s    := cBanco + _cfator + blvalorfinal + _cCart + bldocnufinal + AllTrim(Str(dvnn)) + cAgencia + Strzero(VAL(cConta),5) + cDacCC + '0101'
	//cS   := cBanco + "9" + cFator +  cValorFinal + cCart + ) + "00000" + cNN + "0" + "201"

	//cCodigoCedente := SUBSTR(Trim(SEE->EE_CODEMP),2,LEN(TRIM(SEE->EE_CODEMP))
	cCodigoCedente := Trim(SEE->EE_CODEMP)

	s    := cBanco + '9' + _cfator + blvalorfinal +  STRZERO(VAL(cAgencia),4) + _cCart + bldocnufinal + STRZERO(VAL(cConta),7) + '0'

	dvcb := modulo11(s,.F.)

	CB   := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s,5)


	//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
	//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	//	AAABC.CCCDX		DEEEE.EEEEEY	EEFFF.FFFFGZ	H			UUUUVVVVVVVVVV

	// 	CAMPO 1:
	//	AAA	= Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	// CCCC = Codigo da Ag�ncia
	//	  D = Primeiro digito da Carteira
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	s    := cBanco + '9' + STRZERO(VAL(cAgencia),4) + SubStr(_cCart,1,1)
	dv   := modulo10(s)
	RN   := SubStr(s, 1, 5) + SubStr(s, 6, 4) + AllTrim(Str(dv))


	//	CAMPO 2 (DEEEE.EEEEEY) 
	//	       D =  Restante da Carteira 
	// EEEEEEEEE = Nosso N�mero (9 primeiras posi��es)  
	//	       Y =  DAC que amarra o campo 2 (Anexo 3)

	s    := SubStr(_cCart,2,1) + SubStr(bldocnufinal, 1, 9)
	dv   := modulo10(s)
	RN   := RN + SubStr(s, 1, 5) + SubStr(s, 6, 5) + AllTrim(Str(dv))


	// 	CAMPO 3:
	//	    EE = Restante do Nosso N�mero
	// FFFFFFF = Numero da Conta + DAC da mesma
	//	     G = Zeros (Nao utilizado)
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	s    := SubStr(bldocnufinal, 10, 2) + STRZERO(VAL(cConta),7) + '0'
	dv   := modulo10(s)
	RN   := RN + SubStr(s, 1, 5) + SubStr(s, 6, 5) + AllTrim(Str(dv))


	// 	CAMPO 4:
	//	     H = DAC do Codigo de Barras

	RN   := RN + AllTrim(Str(dvcb))


	// 	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo

	RN   := RN + _cfator + Strzero((nValor * 100),14-Len(_cfator))



Return({CB,RN,NN})


Static Function AjustaSX1()

	aRegs  	:= {}
	aHelp1  := {}
	aHelp2  := {}
	aHelp3  := {}
	aHelp4	:= {}
	aHelp5	:= {}
	aHelp6	:= {}
	aHelp7	:= {}
	aHelp8	:= {}
	aHelp9	:= {}
	aHelp10	:= {}
	aHelp11	:= {}
	aHelp12	:= {}
	aHelp13	:= {}
	aHelp14	:= {}
	aHelp15	:= {}
	aHelp16	:= {}
	aHelp17	:= {}
	aHelp18	:= {}
	aHelp19	:= {}
	aHelp20	:= {}
	aHelp21	:= {}
	aHelp22	:= {}
	aHelp23	:= {}

	aAdd(aRegs,{cPerg,"01","Prefixo de ?"      ,"Prefixo de ?"      ,"Prefixo de?"       ,"mv_ch1","C",TAMSX3("E1_PREFIXO")[1]  ,0,0,"G","			","mv_par01",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",	 "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"02","Prefixo at�?"      ,"Prefixo at�?"      ,"Prefixo at�?"      ,"mv_ch2","C",TAMSX3("E1_PREFIXO")[1]  ,0,0,"G","			","mv_par02",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",	 "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"03","Titulo de?"        ,"Titulo de?"        ,"Titulo de?"        ,"mv_ch3","C",TAMSX3("E1_NUM")	[1]     ,0,0,"G","			","mv_par03",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"04","Titulo at�?"       ,"Titulo at�?"       ,"Titulo at�?"       ,"mv_ch4","C",TAMSX3("E1_NUM")	[1]     ,0,0,"G","			","mv_par04",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","", 			     ""})
	aAdd(aRegs,{cPerg,"05","Parcela de?"       ,"Parcela de?"       ,"Parcela de?"       ,"mv_ch5","C",TAMSX3("E1_PARCELA")[1]  ,0,0,"G","			","mv_par05",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","", 			     ""})
	aAdd(aRegs,{cPerg,"06","Parcela at�?"      ,"Parcela at�?"      ,"Parcela at�?"      ,"mv_ch6","C",TAMSX3("E1_PARCELA")[1]  ,0,0,"G","			","mv_par06",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","", 			     ""})
	aAdd(aRegs,{cPerg,"07","Bordero de?"       ,"Bordero de?"       ,"Bordero de?"       ,"mv_ch7","C",TamSX3("E1_NUMBOR")	[1]	,0,0,"G","			","mv_par07",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","", 			     ""})
	aAdd(aRegs,{cPerg,"08","Bordero at�?"      ,"Bordero at�?"      ,"Bordero at�?"      ,"mv_ch8","C",TamSX3("E1_NUMBOR")	[1] ,0,0,"G","			","mv_par08",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",    			 ""})
	aAdd(aRegs,{cPerg,"09","Cliente de?"       ,"Cliente de?"       ,"Cliente de?"       ,"mv_ch9","C",TamSX3("E1_CLIENTE")[1]	,0,0,"G","			","mv_par09",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","","SA1" ,"","","",    			 ""})
	aAdd(aRegs,{cPerg,"10","Cliente at�?"      ,"Cliente at�?"      ,"Cliente at�?"      ,"mv_cha","C",TamSX3("E1_CLIENTE")[1]  ,0,0,"G","			","mv_par10",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","","SA1" ,"","","", 			     ""})
	aAdd(aRegs,{cPerg,"11","Loja de?"          ,"Loja de?"          ,"Loja de?"          ,"mv_chb","C",TamSX3("E1_LOJA")	[1]	,0,0,"G","			","mv_par11",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","", 			     ""})
	aAdd(aRegs,{cPerg,"12","Loja at�?"         ,"Loja at�?"         ,"Loja at�?"         ,"mv_chc","C",TamSX3("E1_LOJA")	[1]	,0,0,"G","			","mv_par12",			"",				"",				"","","",		"",		  "",		"","","",	  "",	  "",	  "","","","","","","","","","","","",   "" ,"","","",               ""})
	aAdd(aRegs,{cPerg,"13","Vencimento de?"    ,"Vencimento de?"    ,"Vencimento de?"    ,"mv_chd","D",08                       ,0,0,"G","			","mv_par13",         	"",        		"",         	"","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",	 "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"14","Vencimento at�?"   ,"Vencimento at�?"   ,"Vencimento at�?"   ,"mv_che","D",08						,0,0,"G","			","mv_par14",         	"", 	   	    "",    	     	"","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"15","Emiss�o de?"       ,"Emiss�o de?"       ,"Emiss�o de?"       ,"mv_chf","D",08                       ,0,0,"G","			","mv_par15",         	"",        		"",         	"","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",	 "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"16","Emiss�o at�?"      ,"Emiss�o at�?"      ,"Emiss�o at�?"      ,"mv_chg","D",08						,0,0,"G","			","mv_par16",         	"", 	   	    "",    	     	"","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"17","Reimprime Boletos?","Reimprime Boletos?","Reimprime Boletos?","mv_chh","N",01						,0,0,"C","naovazio()","mv_par17",		 "Sim",			 "Sim",			 "Sim","","",	 "Nao",	   "Nao",	 "Nao","","","Ambos","Ambos","Ambos","","","","","","","","","","","",   "" ,"","","",               ""})
	aAdd(aRegs,{cPerg,"18","Banco?"            ,"banco de?"         ,"banco de?"         ,"mv_chi","C",TAMSX3("E1_PORTADO")[1]  ,0,0,"G","			","mv_par18",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","","SEE" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"19","Agencia?"          ,"Agencia?"          ,"Agencia?"          ,"mv_chj","C",TAMSX3("E1_AGEDEP ")[1]  ,0,0,"G","			","mv_par19",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"20","Conta?"            ,"Conta?"            ,"Conta?"            ,"mv_chk","C",TAMSX3("E1_CONTA  ")[1]  ,0,0,"G","			","mv_par20",           "",             "",             "","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"21","Mensagem 1?"       ,"Mensagem 1?"       ,"Mensagem 1?"       ,"mv_chl","C",60                       ,0,0,"G","          ","mv_par21",         	"", 	   	    "",    	     	"","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"22","Mensagem 2?"       ,"Mensagem 2?"       ,"Mensagem 2?"       ,"mv_chm","C",60                       ,0,0,"G","          ","mv_par22",         	"", 	   	    "",    	     	"","","",       "",       "",       "","","",     "",     "",     "","","","","","","","","","","","",   "" ,"","","",				 ""})
	aAdd(aRegs,{cPerg,"23","Filial?"           ,"Filial de?"        ,"Filial de?"        ,"mv_chn","C",10						,0,0,"G","			","mv_par23",           "",             "",             "","","",       "",       "",   	"","","",     "",     "",     "","","","","","","","","","","","","SM0" ,"","","",				 ""})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do Help de cada item do Grupo de Perguntas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aHelp1 , "Informe o Prefixo inicial do t�tulo a" 		)
	Aadd( aHelp1 , "ser filtrado." 								)
	Aadd( aHelp2 , "Informe o Prefixo final do t�tulo a "		)
	Aadd( aHelp2 , "ser filtrado."								)
	Aadd( aHelp3 , "Informe o T�tulo inicial a ser filtrado." 	)
	Aadd( aHelp4 , "Informe o T�tulo final a ser filtrado."	  	)
	Aadd( aHelp5 , "Informe a parcela inicial a ser filtrada."	)
	Aadd( aHelp6 , "Informe a parcela final a ser filtrada."	)
	Aadd( aHelp7 , "Informe o Bordero inicial a ser filtrado." 	)
	Aadd( aHelp8 , "Informe o Bordero final a ser filtrado." 	)
	Aadd( aHelp9 , "Informe o Cliente inicial a ser filtrado." 	)
	Aadd( aHelp10, "Informe o Cliente final a ser filtrado." 	)
	Aadd( aHelp11, "Informe a loja do cliente inicial a "		)
	Aadd( aHelp11, "ser filtrada." 								)
	Aadd( aHelp12, "Informe a loja do cliente final a "			)
	Aadd( aHelp12, "ser filtrada." 								)
	Aadd( aHelp13, "Informe o vencto inicial ser filtrado." 	)
	Aadd( aHelp14, "Informe o vencto final ser filtrado."	 	)
	Aadd( aHelp15, "Informe a emiss�o inicial ser filtrado." 	)
	Aadd( aHelp16, "Informe a emiss�o final ser filtrado."	 	)
	Aadd( aHelp17, "Informe se deseja reimprimir boletos." 		)
	Aadd( aHelp17, "Sim= Ser�o apresentados na sele��o os "		)
	Aadd( aHelp17, "t�tulos com boletos j� impressos."	        )
	Aadd( aHelp17, "N�o= Ser�o apresentados na sele��o os"		)
	Aadd( aHelp17, " t�tulos sem boletos."   					)
	Aadd( aHelp17, "Ambos= Ser�o apresentados na sele��o "		)
	Aadd( aHelp17, "todos os t�tulos."							)
	Aadd( aHelp18, "Informe o Banco a ser amarrado como "		)
	Aadd( aHelp18, "Portador dos t�tulos.                "		)
	Aadd( aHelp19, "Agencia portador do T�tulo.		 	 "		)
	Aadd( aHelp20, "Conta portador do T�tulo.		 	 "		)
	Aadd( aHelp21, "Mensagem personalizada para boleto - "      )
	Aadd( aHelp21, "Linha 1                              "      )
	Aadd( aHelp22, "Mensagem personalizada para boleto - "      )
	Aadd( aHelp22, "Linha 2                              "      )
	Aadd( aHelp23, "Informe a Filial de cobran�a dos Boletos"   )

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
		If !dbSeek(PADR(cPerg,Len( SX1->X1_GRUPO )) + aRegs[i,2])
			RecLock("SX1", .T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o Help dos campos no arquivo de Help³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PutSX1Help("P." + cPerg + "01.", aHelp1, aHelp1, aHelp1)
	PutSX1Help("P." + cPerg + "02.", aHelp2, aHelp2, aHelp2)
	PutSX1Help("P." + cPerg + "03.", aHelp3, aHelp3, aHelp3)
	PutSX1Help("P." + cPerg + "04.", aHelp4, aHelp4, aHelp4)
	PutSX1Help("P." + cPerg + "05.", aHelp5, aHelp5, aHelp5)
	PutSX1Help("P." + cPerg + "06.", aHelp6, aHelp6, aHelp6)
	PutSX1Help("P." + cPerg + "07.", aHelp7, aHelp7, aHelp7)
	PutSX1Help("P." + cPerg + "08.", aHelp8, aHelp8, aHelp8)
	PutSX1Help("P." + cPerg + "09.", aHelp9, aHelp9, aHelp9)
	PutSX1Help("P." + cPerg + "10.",aHelp10,aHelp10,aHelp10)
	PutSX1Help("P." + cPerg + "11.",aHelp11,aHelp11,aHelp11)
	PutSX1Help("P." + cPerg + "12.",aHelp12,aHelp12,aHelp12)
	PutSX1Help("P." + cPerg + "13.",aHelp13,aHelp13,aHelp13)
	PutSX1Help("P." + cPerg + "14.",aHelp14,aHelp14,aHelp14)
	PutSX1Help("P." + cPerg + "15.",aHelp15,aHelp15,aHelp15)
	PutSX1Help("P." + cPerg + "16.",aHelp16,aHelp16,aHelp16)
	PutSX1Help("P." + cPerg + "17.",aHelp17,aHelp17,aHelp17)
	PutSX1Help("P." + cPerg + "18.",aHelp18,aHelp18,aHelp18)
	PutSX1Help("P." + cPerg + "19.",aHelp19,aHelp19,aHelp19)
	PutSX1Help("P." + cPerg + "20.",aHelp20,aHelp20,aHelp20)
	PutSX1Help("P." + cPerg + "21.",aHelp21,aHelp21,aHelp21)
	PutSX1Help("P." + cPerg + "22.",aHelp22,aHelp22,aHelp22)
	PutSX1Help("P." + cPerg + "23.",aHelp23,aHelp23,aHelp23)


Return