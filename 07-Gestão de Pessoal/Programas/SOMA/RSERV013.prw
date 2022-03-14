#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"
#include "topconn.ch"
#include 'parmtype.ch'
#Define CRLF CHR(13)+CHR(10)

user function RSERV013()

	Local aPergs	:= {}
	Local aRetOpc	:= {}
	Local cFilde    := space(6)
	Local cFilate   := space(6)
	Local cPeriod   := space(6)
	Local cDiret    := space(240)
	Local aOpc      := {"","Cadastro","Deposito"}
	Local cMat      := space(6)
	Local cCTT		:= space(TamSx3("RA_CC")[1])
	//Local cRoteiro  := space(3)
	Local aRot      := {"","FOL","FER","RES","131","132"}
	Local cMeioTr   := space(2)
	Local dDep	    := space(8)
	Local cSemana   := space(2)

	Local cClide  := space(6)
	Local cCliaT  := space(6)
	Local cCliin  := space(600)
	Local cCliex  := space(600)	
	Local cLojDcn := space(2)
	Local cLojAcn := space(2)
	Local cLojIcn := space(600)
	Local cLojEcn := space(600)
	Local cMatde  := space(6)
	Local cMataT  := space(6)
	Local cMatin  := space(600)
	Local cMatex  := space(600)	
	Local cContd  := space(15)
	Local cConta  := space(15)
	Local cConti  := space(1500)
	Local cConte  := space(1500)

	Local cMenComp  := "" 

	//aAdd( aPergs ,{1,"Filial de",	cFilde	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Filial ",	cFilate	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Período",	    cPeriod	,GetSx3Cache("RG2_ANOMES","X3_PICTURE") ,'.T.',"" ,'.T.',6,.T.})
	aAdd( aPergs ,{1,"Semana",	    cSemana	,GetSx3Cache("RC_SEMANA","X3_PICTURE") ,'.T.',"" ,'.T.',20,.T.})
	aAdd( aPergs ,{1,"Diretório",	cDiret	,GetSx3Cache("RA_NOME","X3_PICTURE") ,'.T.',"" ,'.T.',100,.T.})
	//aAdd( aPergs ,{1,"Roteiro",	    cRoteiro,GetSx3Cache("RR_ROTEIR","X3_PICTURE") ,'.T.',"" ,'.T.',3,.T.})
	aAdd( aPergs ,{2,"Roteiro", ,aRot,100  ,'.T.',.T.})
	aAdd( aPergs ,{2,"Cadastro / Deposito", ,aOpc,100  ,'.T.',.T.})
	//aAdd( aPergs ,{1,"Matricula de",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	//aAdd( aPergs ,{1,"Matricula ate",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Deposito",dDep	, ,'.T.',"" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Centro Custo de",cCTT	,"@ 999999999999" ,'.T.',"CTT" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Centro Custo ate",cCTT,"@ 999999999999" ,'.T.',"CTT" ,'.T.',50,.F.})

	// novos filtros 

	aAdd( aPergs ,{1,"Cliente De"          , cClide  ,GetSx3Cache("A1_COD","X3_PICTURE")    ,'.T.',"SA1" ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Cliente Ate"         , cCliaT  ,GetSx3Cache("A1_COD","X3_PICTURE")    ,'.T.',"SA1" ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Cliente Incl (+) "   , cCliin  ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'U_FMULSA1S()',"" ,'.T.',200,.F.})
	aAdd( aPergs ,{1,"Cliente Excl (-) "   , cCliex  ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'U_FMULSA1S()',"" ,'.T.',200,.F.})

	aAdd( aPergs ,{1,"Loja De"             , cLojDcn ,"@! 99"    ,'.T.',"" ,'.T.',10,.F.})
	aAdd( aPergs ,{1,"Loja Ate"            , cLojAcn ,"@! 99"    ,'.T.',"" ,'.T.',10,.F.})
	aAdd( aPergs ,{1,"Loja Incl (+) "      , cLojIcn ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'.T.',"" ,'.T.',200,.F.})
	aAdd( aPergs ,{1,"Loja Excl (-) "      , cLojEcn ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'.T.',"" ,'.T.',200,.F.})

	aAdd( aPergs ,{1,"Contrato De"         , cContd  ,"@! 999999999999999" ,'.T.',"CN9" ,'.T.', 50,.F.})
	aAdd( aPergs ,{1,"Contrato Ate"        , cConta  ,"@! 999999999999999" ,'.T.',"CN9" ,'.T.', 50,.F.})
	aAdd( aPergs ,{1,"Contrato Incl (+) "  , cConti  ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'U_FMULCN9S()',"" ,'.T.',200,.F.})
	aAdd( aPergs ,{1,"Contrato Excl (-) "  , cConte  ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'U_FMULCN9S()',"" ,'.T.',200,.F.})

	aAdd( aPergs ,{1,"Matricula De"        , cMatde  ,"@! 999999"    ,'.T.','SRA' ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Matricula Ate"       , cMataT  ,"@! 999999"    ,'.T.','SRA' ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Matricula Incl (+) " , cMatin  ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'U_FMULSRAS()',"" ,'.T.',200,.F.})
	aAdd( aPergs ,{1,"Matricula Excl (-) " , cMatex  ,GetSx3Cache("RJ_MEMOREQ","X3_PICTURE"),'U_FMULSRAS()',"" ,'.T.',200,.F.})



	If ParamBox(aPergs,"Informe",aRetOpc,,,,,,,"",.F.,.F.)
		ProcessBnf(aRetOpc)
	ENDIF
	//TNewProcess():New("BENEFARQ", STR0001, {|oSelf| ProcessBnf(oSelf)}, STR0002, "ARQBENEF", NIL, NIL, NIL, NIL, .T., .F.) 
return


Static Function ProcessBnf(aRetOpc)
	Local nCount, nCount2
	Local nOldSet   := SetVarNameLen(255)
	Local aArea     := GetArea()
	Local aItems    := {}
	Local lCancel   := .F.

	Private nTotal  := 0
	Private nVlr    := 0
	Private nHdl    := 0
	Private nLin    := 0

	// log 
	Private nHdlLog := 0
	Private nLinLog := 0

	Private cFil1 := alltrim(aRetOpc[1])
	//Private cFil2 := alltrim(aRetOpc[2])
	Private cPeri1:= alltrim(aRetOpc[2])
	Private cPerSem:= alltrim(aRetOpc[3])
	Private cRote := alltrim(aRetOpc[5])
	Private cTipo := alltrim(aRetOpc[6])
	Private dDep  := alltrim(aRetOpc[7])
	Private cCC1  := alltrim(aRetOpc[8])
	Private cCC2  := alltrim(aRetOpc[9])

	// CARREGANDO NOVOS FILTROS
	// Cliente 
	Private cCliDe := alltrim(aRetOpc[10])
	Private cCliAt := alltrim(aRetOpc[11])
	Private cCliin := SUBSTR(strtran(aRetOpc[12],"*",""),1,LEN(ALLTRIM(strtran(aRetOpc[12],"*",""))) - 1) //alltrim(aRetOpc[11]) 
	Private cCliex := SUBSTR(strtran(aRetOpc[13],"*",""),1,LEN(ALLTRIM(strtran(aRetOpc[13],"*",""))) - 1) //alltrim(aRetOpc[12]) 
	// Loja
	Private cLojaDe := alltrim(aRetOpc[14])
	Private cLojaAt := alltrim(aRetOpc[15])
	Private cLojain := ALLTRIM(aRetOpc[16]) 
	Private cLojaex := ALLTRIM(aRetOpc[17])    
	// Contrato
	Private cContDe := alltrim(aRetOpc[18])
	Private cContAt := alltrim(aRetOpc[19])
	Private cConti  := SUBSTR(strtran(aRetOpc[20],"*",""),1,LEN(ALLTRIM(strtran(aRetOpc[20],"*",""))) - 1)//alltrim(aRetOpc[19]) 
	Private cConte  := SUBSTR(strtran(aRetOpc[21],"*",""),1,LEN(ALLTRIM(strtran(aRetOpc[21],"*",""))) - 1)//alltrim(aRetOpc[20])   
	// Matricula 
	Private cMat1  := alltrim(aRetOpc[22]) 
	Private cMat2  := alltrim(aRetOpc[23])
	Private cMatin := SUBSTR(strtran(aRetOpc[24],"*",""),1,LEN(ALLTRIM(strtran(aRetOpc[24],"*",""))) - 1) //alltrim(aRetOpc[23])
	Private cMatex := SUBSTR(strtran(aRetOpc[25],"*",""),1,LEN(ALLTRIM(strtran(aRetOpc[25],"*",""))) - 1) //alltrim(aRetOpc[24])

	Private cArqOut   := alltrim(aRetOpc[4])+"\"
	Private lErrorImp := .F.

	MsAguarde({|aRetOpc| ProcINI(aRetOpc)},"Processamento","Aguarde a finalização do processamento...",.F.)
	//ProcINI(aRetOpc)


	RestArea(aArea)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcIni

@since 06/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcINI(oProcess)

	Local cTipPer := ""

	//1* verificar se o período informado ´é fechado (RG2) ou aberto (SR0)  RCH_PERSEL = '1' 
	cQuery1 := " SELECT *
	cQuery1 += " FROM "+RetSqlName("RCH")+" RCH  "	
	cQuery1 += " WHERE RCH_ROTEIR = '"+cRote+"'  "
	cQuery1 += " AND RCH_FILIAL = '"+ xfilial("RCH",cFil1) +"' 
	cQuery1 += " AND RCH_MES = '"+ SUBSTR(cPeri1,1,2) +"' 
	cQuery1 += " AND RCH_ANO = '"+ SUBSTR(cPeri1,3,4) +"'
	cQuery1 += " AND RCH_NUMPAG = '"+ cPerSem +"' 
	cQuery1 += " AND RCH_PERSEL = '1' 
	cQuery1 += " AND D_E_L_E_T_='' 
	IF SELECT("TCOMP") > 0
		TCOMP->(DBCLOSEAREA())
	ENDIF 
	TcQuery cQuery1 New Alias TCOMP	


	nLinha := 1
	nRCard := 0
	nREnd  := 0
	nRTel  := 0
	nRFil  := 0
	nRDep  := 0
	nValDep := 0
	cFilt := ''
	WHILE !TCOMP->(EOF())
		IF cTipo == "Cadastro"

			if  alltrim(cFil1) == '' .or. alltrim(cMat1 + cMat2) == '' .or. alltrim(cCC1 + cCC2) == ''  

				Alert("Preencher os parametros de Filial / Matricula / Centro de Custo")

				return
			endif

			cQuery := " SELECT  *
			cQuery += " FROM "+RetSqlName("SRA")+ " SRA " 
			cQuery += " INNER JOIN (
			cQuery += " SELECT RA_FILIAL , RA_MAT 
			cQuery += " FROM SRA010 SRA
			cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
			cQuery += " LEFT JOIN (
			cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
			cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
			cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
			cQuery += " AND TFJ_STATUS = '1' 
			cQuery += " AND  TFJ_ENTIDA = '1'
			cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
			cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
			cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
			cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
			cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
			cQuery += " GROUP BY RA_FILIAL , RA_MAT 
			cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
			cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
			cQuery += " AND SRA.D_E_L_E_T_ = '' 
			cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +")) 

			cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
			cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
			cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
			cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

			IF SELECT("TSRA") > 0
				TSRA->(DBCLOSEAREA())
			ENDIF 
			TcQuery cQuery New Alias TSRA

			cFilt := ''
			cTexto := ""
			cTexto2 := "" 
			WHILE !TSRA->(EOF())
				MsProcTxt("Funcionário: " + TSRA->RA_NOME)
				IF cFilt  <> TSRA->RA_FILIAL
					// CRIAR AQUIVO 
					cFilt := TSRA->RA_FILIAL
					nHdl := fCreate(cArqOut+"APT_ARQ_CAD"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

					If nHdl == -1
						MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
						Return
					Endif

					/*
					Header do Arquivo
					*/				
					// Tipo de Registro				
					cTexto += PADr("11",2,"")
					//Versão do arquivo
					cTexto += PADr("001",3,"")
					//Código da empresa 
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 					
					//Data da geração
					cTexto += SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4)
					//Hora de geração
					cTexto += STRTRAN(TIME(), ":", "")
					//Código da remessa
					cTexto += PADr("",7,"")
					//Código do Arquivo
					cTexto += PADr("",10,"")
					//Número da linha
					cTexto += PADr("00001",5,"")
					//Retorno do processamento
					cTexto += PADr("",2,"")


					cTexto += CRLF
					nLinha ++  // linha 2
					fWrite( nHdl, cTexto )	


					/*
					Header da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Tipo de Registro
					cTexto += PADr("21",2,"")
					//Código da empresa

					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial
					//cTexto += PADL("3333",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo pessoa
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
					//CPF/CNPJ
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Produto
					cTexto += PADr("00001",5,"")
					//Número da linha
					cTexto += PADr(nLinha,5,"0")
					//Retorno do processamento
					cTexto += PADr("",2,"")

					cTexto += CRLF
					nLinha ++ // linha 3
					nRFil  ++ // numero de filial no arquivo
					fWrite( nHdl, cTexto )	

				ENDIF	

				/*
				Detalhe do Cartão
				*/

				cTexto := ""
				cTexto2 := ""
				//nLinha ++ // linha 4

				//Tipo de Registro
				cTexto += PADr("31",2,"")
				//Tipo pessoa
				cTexto += PADr("F",1,"")
				//CPF/CNPJ
				cTexto += PADL(TSRA->RA_CIC,14,"0")
				//Matrícula
				//cTexto += PADR(alltrim(StrTran( TSRA->RA_MAT, "0", " " )),14,"")
				cTexto += PADR(CVALTOCHAR(VAL(TSRA->RA_MAT)),14,"")
				//Nome/Razão Social
				cTexto += PADR(TSRA->RA_NOMECMP,50,"")
				//RG/Inscrição Estadual
				cTexto += PADL(TSRA->RA_RG,15,"0")
				//Data de Nascimento/Registro
				cTexto += PADR(TSRA->RA_NASC,8,"")
				//Nome da mãe
				cTexto += PADR(TSRA->RA_MAE,50,"")
				//Sexo
				cTexto += PADR(TSRA->RA_SEXO,1,"")
				//Email
				cTexto += PADR("",50,"")	
				//Naturalidade
				cTexto += PADR(TSRA->RA_MUNNASC,50,"")	
				//UF da Naturalidade
				cTexto += PADR(TSRA->RA_NATURAL,2,"")	
				//Nacionalidade
				cTexto += PADR(POSICIONE("CCH",1,XFILIAL("CCH",TSRA->RA_FILIAL)+TSRA->RA_NACIONC,"CCH_PAIS"),20,"")
				//Estado Civil
				IF TSRA->RA_ESTCIVI == "S"
					cTexto += PADR("1",1,"")
				ELSEIF TSRA->RA_ESTCIVI == "C"
					cTexto += PADR("2",1,"")
				ELSEIF TSRA->RA_ESTCIVI == "V"
					cTexto += PADR("3",1,"")
				ELSEIF TSRA->RA_ESTCIVI == "D"
					cTexto += PADR("4",1,"")
				ELSE 
					cTexto += PADR("5",1,"")
				ENDIF 
				//Data Emissão do RG
				cTexto += PADR(TSRA->RA_DTRGEXP,8,"")
				//Orgão Emissor do RG
				cTexto += PADR(TSRA->RA_RGORG,20,"")
				//UF do Orgão Emissor
				cTexto += PADR(TSRA->RA_RGUF,2,"")
				//Data de Admissão do Funcionário
				cTexto += PADR(TSRA->RA_ADMISSA,8,"")
				//Código do cartão
				cTexto += PADR("",16,"")
				//Número da linha
				cTexto += PADL(nLinha,5,"0")
				//Retorno do processamento
				cTexto += PADR("",2,"")

				nRCard ++
				cTexto += CRLF
				nLinha ++ // linha 4
				fWrite( nHdl, cTexto )


				/*
				Detalhe do Endereço
				*/

				cTexto := ""
				cTexto2 := ""
				//Tipo de Registro
				cTexto += PADR("32",2,"")
				//Tipo pessoa
				cTexto += PADR("F",1,"")
				//CPF/CNPJ
				cTexto += PADL(TSRA->RA_CIC,14,"0")
				//Matrícula
				cTexto += PADR(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
				//Tipo do endereço
				IF TSRA->RA_CIC == "1" // COMERCIAL
					cTexto += PADR("3",1,"0")
				ELSEIF TSRA->RA_CIC == "2" // RESIDENCIAL 
					cTexto += PADR("1",2,"")
				ELSE 
					cTexto += PADR("3",2,"")
				ENDIF
				//CEP
				cTexto += PADR(TSRA->RA_CEP,8,"")
				//Logradouro
				cTexto += PADR(TSRA->RA_LOGRDSC,50,"")
				//Número do Endereço
				cTexto += PADR(TSRA->RA_LOGRNUM,5,"")
				//Complemento
				cTexto += PADR(TSRA->RA_COMPLEM,30,"")
				//Bairro
				cTexto += PADR(TSRA->RA_BAIRRO,40,"")
				//Localidade
				cTexto += PADR("",40,"")
				//Unidade Federativa
				cTexto += PADR(TSRA->RA_ESTADO,2,"")
				//Número da linha
				cTexto += PADL(nLinha,5,"0")
				//Retorno do processamento
				cTexto += PADR("",2,"")

				nREnd ++
				cTexto += CRLF
				nLinha ++ // linha 5
				fWrite( nHdl, cTexto )

				/*
				Detalhe do Contato
				*/
				cTexto := ""
				cTexto2 := ""
				//Tipo de Registro
				cTexto += PADR("33",2,"")
				//Tipo pessoa
				cTexto += PADR("F",1,"")
				//CPF/CNPJ
				cTexto += PADL(TSRA->RA_CIC,14,"0")
				//Matrícula
				cTexto += PADR(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
				//Tipo do telefone
				cTexto += PADR("01",2,"")
				//DDD telefone
				cTexto += PADL(ALLTRIM(TSRA->RA_DDDFONE),2,"0")
				//Número Telefone
				cTexto += PADL(TSRA->RA_TELEFON,8,"0")
				//Número da linha
				cTexto += PADL(nLinha,5,"0")
				//Retorno do processamento
				cTexto += PADR("",2,"")

				nRTel ++
				cTexto += CRLF
				nLinha ++ // linha 6
				fWrite( nHdl, cTexto )

				TSRA->(DBSKIP())
			ENDDO
			TSRA->(DBGOTOP())

			//finalizando o arquivo 

			/*
			f. Trailler da Filial
			*/

			cTexto := ""
			cTexto2 := ""
			//Tipo de Registro
			cTexto += PADR("29",2,"")
			//Código da empresa
			//cTexto += PADL("CODE",5,"0")
			IF TSRA->RA_FILIAL == '040101'
				cTexto += PADL("394",5,"0")
			ELSEIF TSRA->RA_FILIAL == '010101'
				cTexto += PADL("395",5,"0")
			ELSEIF TSRA->RA_FILIAL == '020101'
				cTexto += PADL("393",5,"0")
			ELSEIF TSRA->RA_FILIAL == '030101'
				cTexto += PADL("392",5,"0")
			ELSEIF TSRA->RA_FILIAL == '050101'
				cTexto += PADL("396",5,"0")
			ENDIF 	
			//Código da filial
			//cTexto += PADL("CODF",5,"0")
			IF TSRA->RA_FILIAL == '040101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '010101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '020101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '030101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '050101'
				cTexto += PADL("1",5,"0")
			ENDIF 	
			//Tipo pessoa
			cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
			//CPF/CNPJ
			cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
			//Produto
			cTexto += PADL("00001",5,"")
			//Quantidade registros cartão
			cTexto += PADL(nRCard,5,"0")
			//Quantidade registros endereço
			cTexto += PADL(nREnd,5,"0")
			//Quantidade registros telefone
			cTexto += PADL(nRTel,5,"0")
			//Número da linha
			cTexto += PADL(nLinha,5,"0")
			//Retorno do processamento
			cTexto += PADr("",2,"")

			cTexto += CRLF
			nLinha ++ // soma linha 
			fWrite( nHdl, cTexto )

			/*
			g. Trailler do Arquivo
			*/
			cTexto := ""
			cTexto2 := ""
			//Tipo de Registro
			cTexto += PADr("19",2,"")
			//Código da empresa
			//cTexto += PADl("0",5,"0")
			IF TSRA->RA_FILIAL == '040101'
				cTexto += PADL("394",5,"0")
			ELSEIF TSRA->RA_FILIAL == '010101'
				cTexto += PADL("395",5,"0")
			ELSEIF TSRA->RA_FILIAL == '020101'
				cTexto += PADL("393",5,"0")
			ELSEIF TSRA->RA_FILIAL == '030101'
				cTexto += PADL("392",5,"0")
			ELSEIF TSRA->RA_FILIAL == '050101'
				cTexto += PADL("396",5,"0")
			ENDIF 					
			//Quantidade registros filial
			//cTexto += PADl(nRFil,5,"0")
			IF TSRA->RA_FILIAL == '040101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '010101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '020101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '030101'
				cTexto += PADL("1",5,"0")
			ELSEIF TSRA->RA_FILIAL == '050101'
				cTexto += PADL("1",5,"0")
			ENDIF 			
			//Número da linha
			cTexto += PADl(nLinha,5,"0")	
			//Retorno do processamento
			cTexto += PADr("",2,"")

			cTexto += CRLF
			fWrite( nHdl, cTexto )

		ELSEIF alltrim(cTipo) == "Deposito"
			IF cRote == "FOL"
				if TCOMP->RCH_PERSEL == "1" // periodo em aberto

					// FAZER SELECT NA SRA 

					cQuery := " SELECT  *
					cQuery += " FROM "+RetSqlName("SRC")+" SRC  , "+RetSqlName("SRA")+ " SRA " 
					cQuery += " INNER JOIN (
					cQuery += " SELECT RA_FILIAL , RA_MAT 
					cQuery += " FROM SRA010 SRA
					cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
					cQuery += " LEFT JOIN (
					cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
					cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
					cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
					cQuery += " AND TFJ_STATUS = '1' 
					cQuery += " AND  TFJ_ENTIDA = '1'
					cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
					cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
					cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
					cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
					cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
					cQuery += " GROUP BY RA_FILIAL , RA_MAT 
					cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
					cQuery += " AND SRA.D_E_L_E_T_ = '' 
					cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))

					cQuery += " AND    SRC.D_E_L_E_T_ = '' "
					cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
					cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
					cQuery += " AND    SRA.RA_FILIAL = RC_FILIAL
					cQuery += " AND    SRA.RA_MAT = RC_MAT
					cQuery += " AND    RC_ROTEIR = '"+ cRote +"'
					cQuery += " AND    RC_PD = '910'
					cQuery += " AND    RC_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
					cQuery += " AND    RC_PERIODO = '"+ TCOMP->RCH_PER +"'
					cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
					cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

					IF SELECT("TSRA") > 0
						TSRA->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TSRA

					cFilt := ''
					cTexto := "" 
					cTexto2 := "" 
					WHILE !TSRA->(EOF())
						MsProcTxt("Funcionário: " + TSRA->RA_NOME)
						IF cFilt  <> TSRA->RA_FILIAL
							// CRIAR AQUIVO 
							cFilt := TSRA->RA_FILIAL
							nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							If nHdl == -1
								MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
								Return
							Endif

							// CRIAR ARQUIVO LOG
							cFilt := TSRA->RA_FILIAL
							nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							/*
							a. Header do Arquivo
							*/

							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("11",2,"")
							//Versão do layout do
							//arquivo Numérico 03 05 03
							cTexto += PADr("001",3,"")
							//Código da empresa Numérico 06 10 05
							//cTexto += PADl("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Produto Numérico 11 12 02
							cTexto += PADr("01",2,"")
							//Data de geração do
							//arquivo Data 13 20 08
							cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
							//Hora de geração do
							//arquivo Hora 21 26 06
							cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
							//Código de remessa Numérico 27 36 10
							cTexto += PADr("",10,"0")
							//Código do arquivo
							//(retorno) Numérico 37 46 10
							cTexto += PADr("",10,"0")
							//Número da linha Numérico 47 54 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno do processamento Numérico 55 56 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA

							/*
							b. Header da Filial
							*/
							cTexto := ""
							cTexto2 := ""
							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("21",02,"")
							//Código da Empresa Numérico 03 07 05
							//cTexto += PADL("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Código da filial Numérico 08 12 05
							//cTexto += PADL("FIL",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("1",5,"0")
							ENDIF 	
							//Tipo de pessoa Alfanumérico 13 13 01
							cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
							//CPF/CNPJ Numérico 14 27 14
							cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
							//Data de prevista do
							//depósito Data 28 35 08
							cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
							//Competencia Numérico 36 41 06
							cTexto += PADr(substr(TSRA->RC_PERIODO,5,2)+substr(TSRA->RC_PERIODO,1,4),6,"")
							//Tipo de Depósito Numérico 42 43 02
							// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
							IF cRote == "FOL"
								cTexto += PADr("01",2,"")
							ELSEIF cRote == "FER"
								cTexto += PADr("03",2,"")
							ELSEIF cRote == "RES"
								cTexto += PADr("05",2,"")
							ELSEIF cRote == "131" .OR. cRote == "132"
								cTexto += PADr("02",2,"")
							ENDIF
							//Número da linha Numérico 44 51 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno processamento Numérico 52 53 02
							cTexto += PADr("",2," ")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA
							nRFil  ++

						ENDIF	


						/*
						c. Detalhe da Filial - FUNCIONÁRIOS
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("31",2,"0")
						//Tipo de depósito Numérico 03 04 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF
						//Matrícula Alfanumérico 05 18 14
						cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
						//Valor Numérico 19 28 10
						//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RC_VALOR, "@E 999999999") ),10,"0")     
						cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RC_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RC_VALOR),",",""),".","")),10,"0")         
						cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   " 
						cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   " 
						cTexto2 += TRANSFORM(TSRA->RC_VALOR,"@E 999,999,999.99") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RC_VALOR),",",""),".","")),10,"0")
						//Número da linha Numérico 29 36 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 37 38 02
						cTexto += PADR("",2,"")

						cTexto += CRLF // ENTER
						cTexto2 += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						fWrite( nHdlLog, cTexto2 ) // IMPRIME log
						nLinha ++ //SOMAR A LINHA
						nRDep ++
						nValDep += TSRA->RC_VALOR

						TSRA->(DBSKIP())
					ENDDO
					TSRA->(dbgotop())
					IF nHdl == 0
						Alert("Não existe dados!")
						return
					ENDIF
					/*
					d. Trailler da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("29",2,"")
					//Código da Empresa Numérico 03 07 05
					//cTexto += PADl("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial Numérico 08 12 05
					//cTexto += PADl("fil",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo de pessoa Alfanumérico 13 13 01
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')   // ****
					//CPF/CNPJ Numérico 14 27 14
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Qtde de registros
					//enviados para deposito Numérico 28 35 08
					cTexto += PADL(nRDep,8,"0")
					//Valor dos registros
					//enviados para deposito Numérico 36 45 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")   
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")//PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
					cTexto2 += CRLF
					cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")
					//Qtde de registros
					//depositados Numérico 46 53 08
					cTexto += PADR("",8,"")
					//Valor dos registros
					//depositados Numérico 54 63 10
					cTexto += PADR("",10,"")
					//Número da linha Numérico 64 71 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 72 73 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME Log
					fWrite( nHdlLog, cTexto2 ) // IMPRIME
					nLinha ++ //SOMAR A LINHA

					/*
					e. Trailler do Arquivo
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("19",2,"")
					//Código da empresa Numérico 03 07 05
					//cTexto += PADL("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Produto Numérico 08 09 02
					cTexto += PADR("01",2,"")
					//Quantidade de filiais Numérico 10 17 08
					cTexto += PADL(nRFil,8,"0")
					//Qtde total de registros
					//enviados para deposito Numérico 18 25 08
					cTexto += PADL(nRDep,8,"0")
					//Valor total de registros
					//enviados para deposito Numérico 26 35 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")  //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0") 
					//Qtde total de registros
					//depositados Numérico 36 43 08
					cTexto += PADR("",8,"0")
					//Valor total de registros
					//depositados Numérico 44 53 10
					cTexto += PADR("",10,"0")
					//Número da linha Numérico 54 61 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno do
					//processamento Numérico 62 63 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					nLinha ++ //SOMAR A LINHA

				else // Periodo fechado

					// FAZER SELECT NA SRA 

					cQuery := " SELECT  *
					cQuery += " FROM "+RetSqlName("SRD")+" SRD  , "+RetSqlName("SRA")+ " SRA " 
					cQuery += " INNER JOIN (
					cQuery += " SELECT RA_FILIAL , RA_MAT 
					cQuery += " FROM SRA010 SRA
					cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
					cQuery += " LEFT JOIN (
					cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
					cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
					cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
					cQuery += " AND TFJ_STATUS = '1' 
					cQuery += " AND  TFJ_ENTIDA = '1'
					cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
					cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
					cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
					cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
					cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
					cQuery += " GROUP BY RA_FILIAL , RA_MAT 
					cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
					cQuery += " AND SRA.D_E_L_E_T_ = '' 
					cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))

					cQuery += " AND    SRD.D_E_L_E_T_ = '' "
					cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
					cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
					cQuery += " AND    SRA.RA_FILIAL = RD_FILIAL
					cQuery += " AND    SRA.RA_MAT = RD_MAT
					cQuery += " AND    RD_ROTEIR = '"+ cRote +"'
					cQuery += " AND    RD_PD = '910'
					cQuery += " AND    RD_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
					cQuery += " AND    RD_PERIODO = '"+ TCOMP->RCH_PER +"'
					cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
					cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

					IF SELECT("TSRA") > 0
						TSRA->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TSRA

					cFilt := ''
					cTexto := ""
					cTexto2 := "" 
					WHILE !TSRA->(EOF())
						MsProcTxt("Funcionário: " + TSRA->RA_NOME)
						IF cFilt  <> TSRA->RA_FILIAL
							// CRIAR AQUIVO 
							cFilt := TSRA->RA_FILIAL
							nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							If nHdl == -1
								MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
								Return
							Endif

							// CRIAR ARQUIVO LOG
							cFilt := TSRA->RA_FILIAL
							nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')


							/*
							a. Header do Arquivo
							*/

							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("11",2,"")
							//Versão do layout do
							//arquivo Numérico 03 05 03
							cTexto += PADr("001",3,"")
							//Código da empresa Numérico 06 10 05
							//cTexto += PADl("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Produto Numérico 11 12 02
							cTexto += PADr("01",2,"")
							//Data de geração do
							//arquivo Data 13 20 08
							cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
							//Hora de geração do
							//arquivo Hora 21 26 06
							cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
							//Código de remessa Numérico 27 36 10
							cTexto += PADr("",2,"10")
							//Código do arquivo
							//(retorno) Numérico 37 46 10
							cTexto += PADr("",10,"")
							//Número da linha Numérico 47 54 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno do processamento Numérico 55 56 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA

							/*
							b. Header da Filial
							*/
							cTexto := ""
							cTexto2 := ""
							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("21",02,"")
							//Código da Empresa Numérico 03 07 05
							//cTexto += PADL("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Código da filial Numérico 08 12 05
							//cTexto += PADL("FIL",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("1",5,"0")
							ENDIF 	
							//Tipo de pessoa Alfanumérico 13 13 01
							cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
							//CPF/CNPJ Numérico 14 27 14
							cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
							//Data de prevista do
							//depósito Data 28 35 08
							cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
							//Competencia Numérico 36 41 06
							cTexto += PADr(substr(TSRA->RD_PERIODO,5,2)+substr(TSRA->RD_PERIODO,1,4),6,"")
							//Tipo de Depósito Numérico 42 43 02
							// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
							IF cRote == "FOL"
								cTexto += PADr("01",2,"")
							ELSEIF cRote == "FER"
								cTexto += PADr("03",2,"")
							ELSEIF cRote == "RES"
								cTexto += PADr("05",2,"")
							ELSEIF cRote == "131" .OR. cRote == "132"
								cTexto += PADr("02",2,"")
							ENDIF


							//Número da linha Numérico 44 51 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno processamento Numérico 52 53 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA
							nRFil  ++

						ENDIF	


						/*
						c. Detalhe da Filial - FUNCIONÁRIOS
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("31",2,"0")
						//Tipo de depósito Numérico 03 04 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF


						//Matrícula Alfanumérico 05 18 14
						cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
						//Valor Numérico 19 28 10
						//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RD_VALOR, "@E 999999999") ),10,"0")  
						cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RD_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0")// PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RD_VALOR),",",""),".","")),10,"0")           
						cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   "
						cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   "
						cTexto2 += TRANSFORM(TSRA->RD_VALOR,"@E 999,999,999.99")// PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RD_VALOR),",",""),".","")),10,"0")
						//Número da linha Numérico 29 36 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 37 38 02
						cTexto += PADR("",2,"")

						cTexto += CRLF // ENTER
						cTexto2 += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
						nLinha ++ //SOMAR A LINHA
						nRDep ++
						nValDep += TSRA->RD_VALOR

						TSRA->(DBSKIP())
					ENDDO
					TSRA->(dbgotop())

					IF nHdl == 0
						Alert("Não existe dados!")
						return
					ENDIF

					/*
					d. Trailler da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("29",2,"")
					//Código da Empresa Numérico 03 07 05
					//cTexto += PADl("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial Numérico 08 12 05
					//cTexto += PADl("fil",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo de pessoa Alfanumérico 13 13 01
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
					//CPF/CNPJ Numérico 14 27 14
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Qtde de registros
					//enviados para deposito Numérico 28 35 08
					cTexto += PADL(nRDep,8,"0")
					//Valor dos registros
					//enviados para deposito Numérico 36 45 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")   //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")   
					cTexto2 += CRLF
					cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")
					//Qtde de registros
					//depositados Numérico 46 53 08
					cTexto += PADR("",8,"")
					//Valor dos registros
					//depositados Numérico 54 63 10
					cTexto += PADR("",10,"")
					//Número da linha Numérico 64 71 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 72 73 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
					nLinha ++ //SOMAR A LINHA

					/*
					e. Trailler do Arquivo
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("19",2,"")
					//Código da empresa Numérico 03 07 05
					//cTexto += PADL("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Produto Numérico 08 09 02
					cTexto += PADR("01",2,"")
					//Quantidade de filiais Numérico 10 17 08
					cTexto += PADL(nRFil,8,"0")
					//Qtde total de registros
					//enviados para deposito Numérico 18 25 08
					cTexto += PADL(nRDep,8,"0")
					//Valor total de registros
					//enviados para deposito Numérico 26 35 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999")),10,"0") 
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
					//Qtde total de registros
					//depositados Numérico 36 43 08
					cTexto += PADR("",8,"0")
					//Valor total de registros
					//depositados Numérico 44 53 10
					cTexto += PADR("",10,"0")
					//Número da linha Numérico 54 61 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno do
					//processamento Numérico 62 63 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					nLinha ++ //SOMAR A LINHA
				endif

				//131
			ELSEIF cRote == "131"
				if TCOMP->RCH_PERSEL == "1" // periodo em aberto

					// FAZER SELECT NA SRA 

					cQuery := " SELECT  *
					cQuery += " FROM "+RetSqlName("SRC")+" SRC  , "+RetSqlName("SRA")+ " SRA " 
					cQuery += " INNER JOIN (
					cQuery += " SELECT RA_FILIAL , RA_MAT 
					cQuery += " FROM SRA010 SRA
					cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
					cQuery += " LEFT JOIN (
					cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
					cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
					cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
					cQuery += " AND TFJ_STATUS = '1' 
					cQuery += " AND  TFJ_ENTIDA = '1'
					cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
					cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
					cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
					cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
					cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
					cQuery += " GROUP BY RA_FILIAL , RA_MAT 
					cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
					cQuery += " AND SRA.D_E_L_E_T_ = '' 
					cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))

					cQuery += " AND    SRC.D_E_L_E_T_ = '' "
					cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
					cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
					cQuery += " AND    SRA.RA_FILIAL = RC_FILIAL
					cQuery += " AND    SRA.RA_MAT = RC_MAT
					cQuery += " AND    RC_ROTEIR = '"+ cRote +"'
					cQuery += " AND    RC_PD = '068'
					cQuery += " AND    RC_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
					cQuery += " AND    RC_PERIODO = '"+ TCOMP->RCH_PER +"'
					cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
					cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

					IF SELECT("TSRA") > 0
						TSRA->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TSRA

					cFilt := ''
					cTexto := "" 
					cTexto2 := "" 
					WHILE !TSRA->(EOF())
						MsProcTxt("Funcionário: " + TSRA->RA_NOME)
						IF cFilt  <> TSRA->RA_FILIAL
							// CRIAR AQUIVO 
							cFilt := TSRA->RA_FILIAL
							nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							If nHdl == -1
								MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
								Return
							Endif

							// CRIAR ARQUIVO LOG
							cFilt := TSRA->RA_FILIAL
							nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							/*
							a. Header do Arquivo
							*/

							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("11",2,"")
							//Versão do layout do
							//arquivo Numérico 03 05 03
							cTexto += PADr("001",3,"")
							//Código da empresa Numérico 06 10 05
							//cTexto += PADl("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Produto Numérico 11 12 02
							cTexto += PADr("01",2,"")
							//Data de geração do
							//arquivo Data 13 20 08
							cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
							//Hora de geração do
							//arquivo Hora 21 26 06
							cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
							//Código de remessa Numérico 27 36 10
							cTexto += PADr("",10,"0")
							//Código do arquivo
							//(retorno) Numérico 37 46 10
							cTexto += PADr("",10,"0")
							//Número da linha Numérico 47 54 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno do processamento Numérico 55 56 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA

							/*
							b. Header da Filial
							*/
							cTexto := ""
							cTexto2 := ""
							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("21",02,"")
							//Código da Empresa Numérico 03 07 05
							//cTexto += PADL("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Código da filial Numérico 08 12 05
							//cTexto += PADL("FIL",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("1",5,"0")
							ENDIF 	
							//Tipo de pessoa Alfanumérico 13 13 01
							cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
							//CPF/CNPJ Numérico 14 27 14
							cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
							//Data de prevista do
							//depósito Data 28 35 08
							cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
							//Competencia Numérico 36 41 06
							cTexto += PADr(substr(TSRA->RC_PERIODO,5,2)+substr(TSRA->RC_PERIODO,1,4),6,"")
							//Tipo de Depósito Numérico 42 43 02
							// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
							IF cRote == "FOL"
								cTexto += PADr("01",2,"")
							ELSEIF cRote == "FER"
								cTexto += PADr("03",2,"")
							ELSEIF cRote == "RES"
								cTexto += PADr("05",2,"")
							ELSEIF cRote == "131" .OR. cRote == "132"
								cTexto += PADr("02",2,"")
							ENDIF
							//Número da linha Numérico 44 51 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno processamento Numérico 52 53 02
							cTexto += PADr("",2," ")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA
							nRFil  ++

						ENDIF	


						/*
						c. Detalhe da Filial - FUNCIONÁRIOS
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("31",2,"0")
						//Tipo de depósito Numérico 03 04 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF
						//Matrícula Alfanumérico 05 18 14
						cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
						//Valor Numérico 19 28 10
						//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RC_VALOR, "@E 999999999") ),10,"0")     
						cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RC_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RC_VALOR),",",""),".","")),10,"0")         
						cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   " 
						cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   " 
						cTexto2 += TRANSFORM(TSRA->RC_VALOR,"@E 999,999,999.99") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RC_VALOR),",",""),".","")),10,"0")
						//Número da linha Numérico 29 36 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 37 38 02
						cTexto += PADR("",2,"")

						cTexto += CRLF // ENTER
						cTexto2 += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						fWrite( nHdlLog, cTexto2 ) // IMPRIME log
						nLinha ++ //SOMAR A LINHA
						nRDep ++
						nValDep += TSRA->RC_VALOR

						TSRA->(DBSKIP())
					ENDDO
					TSRA->(dbgotop())
					IF nHdl == 0
						Alert("Não existe dados!")
						return
					ENDIF
					/*
					d. Trailler da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("29",2,"")
					//Código da Empresa Numérico 03 07 05
					//cTexto += PADl("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial Numérico 08 12 05
					//cTexto += PADl("fil",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo de pessoa Alfanumérico 13 13 01
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')   // ****
					//CPF/CNPJ Numérico 14 27 14
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Qtde de registros
					//enviados para deposito Numérico 28 35 08
					cTexto += PADL(nRDep,8,"0")
					//Valor dos registros
					//enviados para deposito Numérico 36 45 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")   
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")//PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
					cTexto2 += CRLF
					cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")
					//Qtde de registros
					//depositados Numérico 46 53 08
					cTexto += PADR("",8,"")
					//Valor dos registros
					//depositados Numérico 54 63 10
					cTexto += PADR("",10,"")
					//Número da linha Numérico 64 71 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 72 73 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME Log
					fWrite( nHdlLog, cTexto2 ) // IMPRIME
					nLinha ++ //SOMAR A LINHA

					/*
					e. Trailler do Arquivo
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("19",2,"")
					//Código da empresa Numérico 03 07 05
					//cTexto += PADL("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Produto Numérico 08 09 02
					cTexto += PADR("01",2,"")
					//Quantidade de filiais Numérico 10 17 08
					cTexto += PADL(nRFil,8,"0")
					//Qtde total de registros
					//enviados para deposito Numérico 18 25 08
					cTexto += PADL(nRDep,8,"0")
					//Valor total de registros
					//enviados para deposito Numérico 26 35 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")  //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0") 
					//Qtde total de registros
					//depositados Numérico 36 43 08
					cTexto += PADR("",8,"0")
					//Valor total de registros
					//depositados Numérico 44 53 10
					cTexto += PADR("",10,"0")
					//Número da linha Numérico 54 61 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno do
					//processamento Numérico 62 63 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					nLinha ++ //SOMAR A LINHA

				else // Periodo fechado

					// FAZER SELECT NA SRA 

					cQuery := " SELECT  *
					cQuery += " FROM "+RetSqlName("SRD")+" SRD  , "+RetSqlName("SRA")+ " SRA " 
					cQuery += " INNER JOIN (
					cQuery += " SELECT RA_FILIAL , RA_MAT 
					cQuery += " FROM SRA010 SRA
					cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
					cQuery += " LEFT JOIN (
					cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
					cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
					cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
					cQuery += " AND TFJ_STATUS = '1' 
					cQuery += " AND  TFJ_ENTIDA = '1'
					cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
					cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
					cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
					cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
					cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
					cQuery += " GROUP BY RA_FILIAL , RA_MAT 
					cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
					cQuery += " AND SRA.D_E_L_E_T_ = '' 
					cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))

					cQuery += " AND    SRD.D_E_L_E_T_ = '' "
					cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
					cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
					cQuery += " AND    SRA.RA_FILIAL = RD_FILIAL
					cQuery += " AND    SRA.RA_MAT = RD_MAT
					cQuery += " AND    RD_ROTEIR = '"+ cRote +"'
					cQuery += " AND    RD_PD = '068'
					cQuery += " AND    RD_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
					cQuery += " AND    RD_PERIODO = '"+ TCOMP->RCH_PER +"'
					cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
					cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

					IF SELECT("TSRA") > 0
						TSRA->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TSRA

					cFilt := ''
					cTexto := ""
					cTexto2 := "" 
					WHILE !TSRA->(EOF())
						MsProcTxt("Funcionário: " + TSRA->RA_NOME)
						IF cFilt  <> TSRA->RA_FILIAL
							// CRIAR AQUIVO 
							cFilt := TSRA->RA_FILIAL
							nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							If nHdl == -1
								MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
								Return
							Endif

							// CRIAR ARQUIVO LOG
							cFilt := TSRA->RA_FILIAL
							nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')


							/*
							a. Header do Arquivo
							*/

							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("11",2,"")
							//Versão do layout do
							//arquivo Numérico 03 05 03
							cTexto += PADr("001",3,"")
							//Código da empresa Numérico 06 10 05
							//cTexto += PADl("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Produto Numérico 11 12 02
							cTexto += PADr("01",2,"")
							//Data de geração do
							//arquivo Data 13 20 08
							cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
							//Hora de geração do
							//arquivo Hora 21 26 06
							cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
							//Código de remessa Numérico 27 36 10
							cTexto += PADr("",2,"10")
							//Código do arquivo
							//(retorno) Numérico 37 46 10
							cTexto += PADr("",10,"")
							//Número da linha Numérico 47 54 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno do processamento Numérico 55 56 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA

							/*
							b. Header da Filial
							*/
							cTexto := ""
							cTexto2 := ""
							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("21",02,"")
							//Código da Empresa Numérico 03 07 05
							//cTexto += PADL("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Código da filial Numérico 08 12 05
							//cTexto += PADL("FIL",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("1",5,"0")
							ENDIF 	
							//Tipo de pessoa Alfanumérico 13 13 01
							cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
							//CPF/CNPJ Numérico 14 27 14
							cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
							//Data de prevista do
							//depósito Data 28 35 08
							cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
							//Competencia Numérico 36 41 06
							cTexto += PADr(substr(TSRA->RD_PERIODO,5,2)+substr(TSRA->RD_PERIODO,1,4),6,"")
							//Tipo de Depósito Numérico 42 43 02
							// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
							IF cRote == "FOL"
								cTexto += PADr("01",2,"")
							ELSEIF cRote == "FER"
								cTexto += PADr("03",2,"")
							ELSEIF cRote == "RES"
								cTexto += PADr("05",2,"")
							ELSEIF cRote == "131" .OR. cRote == "132"
								cTexto += PADr("02",2,"")
							ENDIF


							//Número da linha Numérico 44 51 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno processamento Numérico 52 53 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA
							nRFil  ++

						ENDIF	


						/*
						c. Detalhe da Filial - FUNCIONÁRIOS
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("31",2,"0")
						//Tipo de depósito Numérico 03 04 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF


						//Matrícula Alfanumérico 05 18 14
						cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
						//Valor Numérico 19 28 10
						//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RD_VALOR, "@E 999999999") ),10,"0")  
						cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RD_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0")// PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RD_VALOR),",",""),".","")),10,"0")           
						cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   "
						cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   "
						cTexto2 += TRANSFORM(TSRA->RD_VALOR,"@E 999,999,999.99")// PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RD_VALOR),",",""),".","")),10,"0")
						//Número da linha Numérico 29 36 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 37 38 02
						cTexto += PADR("",2,"")

						cTexto += CRLF // ENTER
						cTexto2 += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
						nLinha ++ //SOMAR A LINHA
						nRDep ++
						nValDep += TSRA->RD_VALOR

						TSRA->(DBSKIP())
					ENDDO
					TSRA->(dbgotop())

					IF nHdl == 0
						Alert("Não existe dados!")
						return
					ENDIF

					/*
					d. Trailler da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("29",2,"")
					//Código da Empresa Numérico 03 07 05
					//cTexto += PADl("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial Numérico 08 12 05
					//cTexto += PADl("fil",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo de pessoa Alfanumérico 13 13 01
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
					//CPF/CNPJ Numérico 14 27 14
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Qtde de registros
					//enviados para deposito Numérico 28 35 08
					cTexto += PADL(nRDep,8,"0")
					//Valor dos registros
					//enviados para deposito Numérico 36 45 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")   //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")   
					cTexto2 += CRLF
					cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")
					//Qtde de registros
					//depositados Numérico 46 53 08
					cTexto += PADR("",8,"")
					//Valor dos registros
					//depositados Numérico 54 63 10
					cTexto += PADR("",10,"")
					//Número da linha Numérico 64 71 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 72 73 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
					nLinha ++ //SOMAR A LINHA

					/*
					e. Trailler do Arquivo
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("19",2,"")
					//Código da empresa Numérico 03 07 05
					//cTexto += PADL("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Produto Numérico 08 09 02
					cTexto += PADR("01",2,"")
					//Quantidade de filiais Numérico 10 17 08
					cTexto += PADL(nRFil,8,"0")
					//Qtde total de registros
					//enviados para deposito Numérico 18 25 08
					cTexto += PADL(nRDep,8,"0")
					//Valor total de registros
					//enviados para deposito Numérico 26 35 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999")),10,"0") 
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
					//Qtde total de registros
					//depositados Numérico 36 43 08
					cTexto += PADR("",8,"0")
					//Valor total de registros
					//depositados Numérico 44 53 10
					cTexto += PADR("",10,"0")
					//Número da linha Numérico 54 61 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno do
					//processamento Numérico 62 63 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					nLinha ++ //SOMAR A LINHA
				endif

				//132
			ELSEIF cRote == "FOL"
				if TCOMP->RCH_PERSEL == "1" // periodo em aberto

					// FAZER SELECT NA SRA 

					cQuery := " SELECT  *
					cQuery += " FROM "+RetSqlName("SRC")+" SRC  , "+RetSqlName("SRA")+ " SRA " 
					cQuery += " INNER JOIN (
					cQuery += " SELECT RA_FILIAL , RA_MAT 
					cQuery += " FROM SRA010 SRA
					cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
					cQuery += " LEFT JOIN (
					cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
					cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
					cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
					cQuery += " AND TFJ_STATUS = '1' 
					cQuery += " AND  TFJ_ENTIDA = '1'
					cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
					cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
					cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
					cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
					cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
					cQuery += " GROUP BY RA_FILIAL , RA_MAT 
					cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
					cQuery += " AND SRA.D_E_L_E_T_ = '' 
					cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))

					cQuery += " AND    SRC.D_E_L_E_T_ = '' "
					cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
					cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
					cQuery += " AND    SRA.RA_FILIAL = RC_FILIAL
					cQuery += " AND    SRA.RA_MAT = RC_MAT
					cQuery += " AND    RC_ROTEIR = '"+ cRote +"'
					cQuery += " AND    RC_PD = '730'
					cQuery += " AND    RC_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
					cQuery += " AND    RC_PERIODO = '"+ TCOMP->RCH_PER +"'
					cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
					cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

					IF SELECT("TSRA") > 0
						TSRA->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TSRA

					cFilt := ''
					cTexto := "" 
					cTexto2 := "" 
					WHILE !TSRA->(EOF())
						MsProcTxt("Funcionário: " + TSRA->RA_NOME)
						IF cFilt  <> TSRA->RA_FILIAL
							// CRIAR AQUIVO 
							cFilt := TSRA->RA_FILIAL
							nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							If nHdl == -1
								MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
								Return
							Endif

							// CRIAR ARQUIVO LOG
							cFilt := TSRA->RA_FILIAL
							nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							/*
							a. Header do Arquivo
							*/

							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("11",2,"")
							//Versão do layout do
							//arquivo Numérico 03 05 03
							cTexto += PADr("001",3,"")
							//Código da empresa Numérico 06 10 05
							//cTexto += PADl("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Produto Numérico 11 12 02
							cTexto += PADr("01",2,"")
							//Data de geração do
							//arquivo Data 13 20 08
							cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
							//Hora de geração do
							//arquivo Hora 21 26 06
							cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
							//Código de remessa Numérico 27 36 10
							cTexto += PADr("",10,"0")
							//Código do arquivo
							//(retorno) Numérico 37 46 10
							cTexto += PADr("",10,"0")
							//Número da linha Numérico 47 54 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno do processamento Numérico 55 56 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA

							/*
							b. Header da Filial
							*/
							cTexto := ""
							cTexto2 := ""
							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("21",02,"")
							//Código da Empresa Numérico 03 07 05
							//cTexto += PADL("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Código da filial Numérico 08 12 05
							//cTexto += PADL("FIL",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("1",5,"0")
							ENDIF 	
							//Tipo de pessoa Alfanumérico 13 13 01
							cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
							//CPF/CNPJ Numérico 14 27 14
							cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
							//Data de prevista do
							//depósito Data 28 35 08
							cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
							//Competencia Numérico 36 41 06
							cTexto += PADr(substr(TSRA->RC_PERIODO,5,2)+substr(TSRA->RC_PERIODO,1,4),6,"")
							//Tipo de Depósito Numérico 42 43 02
							// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
							IF cRote == "FOL"
								cTexto += PADr("01",2,"")
							ELSEIF cRote == "FER"
								cTexto += PADr("03",2,"")
							ELSEIF cRote == "RES"
								cTexto += PADr("05",2,"")
							ELSEIF cRote == "131" .OR. cRote == "132"
								cTexto += PADr("02",2,"")
							ENDIF
							//Número da linha Numérico 44 51 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno processamento Numérico 52 53 02
							cTexto += PADr("",2," ")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA
							nRFil  ++

						ENDIF	


						/*
						c. Detalhe da Filial - FUNCIONÁRIOS
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("31",2,"0")
						//Tipo de depósito Numérico 03 04 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF
						//Matrícula Alfanumérico 05 18 14
						cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
						//Valor Numérico 19 28 10
						//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RC_VALOR, "@E 999999999") ),10,"0")     
						cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RC_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RC_VALOR),",",""),".","")),10,"0")         
						cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   " 
						cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   " 
						cTexto2 += TRANSFORM(TSRA->RC_VALOR,"@E 999,999,999.99") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RC_VALOR),",",""),".","")),10,"0")
						//Número da linha Numérico 29 36 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 37 38 02
						cTexto += PADR("",2,"")

						cTexto += CRLF // ENTER
						cTexto2 += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						fWrite( nHdlLog, cTexto2 ) // IMPRIME log
						nLinha ++ //SOMAR A LINHA
						nRDep ++
						nValDep += TSRA->RC_VALOR

						TSRA->(DBSKIP())
					ENDDO
					TSRA->(dbgotop())
					IF nHdl == 0
						Alert("Não existe dados!")
						return
					ENDIF
					/*
					d. Trailler da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("29",2,"")
					//Código da Empresa Numérico 03 07 05
					//cTexto += PADl("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial Numérico 08 12 05
					//cTexto += PADl("fil",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo de pessoa Alfanumérico 13 13 01
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')   // ****
					//CPF/CNPJ Numérico 14 27 14
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Qtde de registros
					//enviados para deposito Numérico 28 35 08
					cTexto += PADL(nRDep,8,"0")
					//Valor dos registros
					//enviados para deposito Numérico 36 45 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")   
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")//PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
					cTexto2 += CRLF
					cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")
					//Qtde de registros
					//depositados Numérico 46 53 08
					cTexto += PADR("",8,"")
					//Valor dos registros
					//depositados Numérico 54 63 10
					cTexto += PADR("",10,"")
					//Número da linha Numérico 64 71 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 72 73 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME Log
					fWrite( nHdlLog, cTexto2 ) // IMPRIME
					nLinha ++ //SOMAR A LINHA

					/*
					e. Trailler do Arquivo
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("19",2,"")
					//Código da empresa Numérico 03 07 05
					//cTexto += PADL("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Produto Numérico 08 09 02
					cTexto += PADR("01",2,"")
					//Quantidade de filiais Numérico 10 17 08
					cTexto += PADL(nRFil,8,"0")
					//Qtde total de registros
					//enviados para deposito Numérico 18 25 08
					cTexto += PADL(nRDep,8,"0")
					//Valor total de registros
					//enviados para deposito Numérico 26 35 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")  //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0") 
					//Qtde total de registros
					//depositados Numérico 36 43 08
					cTexto += PADR("",8,"0")
					//Valor total de registros
					//depositados Numérico 44 53 10
					cTexto += PADR("",10,"0")
					//Número da linha Numérico 54 61 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno do
					//processamento Numérico 62 63 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					nLinha ++ //SOMAR A LINHA

				else // Periodo fechado

					// FAZER SELECT NA SRA 

					cQuery := " SELECT  *
					cQuery += " FROM "+RetSqlName("SRD")+" SRD  , "+RetSqlName("SRA")+ " SRA " 
					cQuery += " INNER JOIN (
					cQuery += " SELECT RA_FILIAL , RA_MAT 
					cQuery += " FROM SRA010 SRA
					cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
					cQuery += " LEFT JOIN (
					cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
					cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
					cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
					cQuery += " AND TFJ_STATUS = '1' 
					cQuery += " AND  TFJ_ENTIDA = '1'
					cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
					cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
					cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
					cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
					cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
					cQuery += " GROUP BY RA_FILIAL , RA_MAT 
					cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
					cQuery += " WHERE SRA.RA_SITFOLH <> 'D'
					cQuery += " AND SRA.D_E_L_E_T_ = '' 
					cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))

					cQuery += " AND    SRD.D_E_L_E_T_ = '' "
					cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
					cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
					cQuery += " AND    SRA.RA_FILIAL = RD_FILIAL
					cQuery += " AND    SRA.RA_MAT = RD_MAT
					cQuery += " AND    RD_ROTEIR = '"+ cRote +"'
					cQuery += " AND    RD_PD = '730'
					cQuery += " AND    RD_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
					cQuery += " AND    RD_PERIODO = '"+ TCOMP->RCH_PER +"'
					cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
					cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

					IF SELECT("TSRA") > 0
						TSRA->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TSRA

					cFilt := ''
					cTexto := ""
					cTexto2 := "" 
					WHILE !TSRA->(EOF())
						MsProcTxt("Funcionário: " + TSRA->RA_NOME)
						IF cFilt  <> TSRA->RA_FILIAL
							// CRIAR AQUIVO 
							cFilt := TSRA->RA_FILIAL
							nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

							If nHdl == -1
								MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
								Return
							Endif

							// CRIAR ARQUIVO LOG
							cFilt := TSRA->RA_FILIAL
							nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')


							/*
							a. Header do Arquivo
							*/

							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("11",2,"")
							//Versão do layout do
							//arquivo Numérico 03 05 03
							cTexto += PADr("001",3,"")
							//Código da empresa Numérico 06 10 05
							//cTexto += PADl("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Produto Numérico 11 12 02
							cTexto += PADr("01",2,"")
							//Data de geração do
							//arquivo Data 13 20 08
							cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
							//Hora de geração do
							//arquivo Hora 21 26 06
							cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
							//Código de remessa Numérico 27 36 10
							cTexto += PADr("",2,"10")
							//Código do arquivo
							//(retorno) Numérico 37 46 10
							cTexto += PADr("",10,"")
							//Número da linha Numérico 47 54 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno do processamento Numérico 55 56 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA

							/*
							b. Header da Filial
							*/
							cTexto := ""
							cTexto2 := ""
							//Identificador do registro
							//Header Numérico 01 02 02
							cTexto += PADr("21",02,"")
							//Código da Empresa Numérico 03 07 05
							//cTexto += PADL("EMP",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("394",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("395",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("393",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("392",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("396",5,"0")
							ENDIF 	
							//Código da filial Numérico 08 12 05
							//cTexto += PADL("FIL",5,"0")
							IF TSRA->RA_FILIAL == '040101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '010101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '020101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '030101'
								cTexto += PADL("1",5,"0")
							ELSEIF TSRA->RA_FILIAL == '050101'
								cTexto += PADL("1",5,"0")
							ENDIF 	
							//Tipo de pessoa Alfanumérico 13 13 01
							cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
							//CPF/CNPJ Numérico 14 27 14
							cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
							//Data de prevista do
							//depósito Data 28 35 08
							cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
							//Competencia Numérico 36 41 06
							cTexto += PADr(substr(TSRA->RD_PERIODO,5,2)+substr(TSRA->RD_PERIODO,1,4),6,"")
							//Tipo de Depósito Numérico 42 43 02
							// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
							IF cRote == "FOL"
								cTexto += PADr("01",2,"")
							ELSEIF cRote == "FER"
								cTexto += PADr("03",2,"")
							ELSEIF cRote == "RES"
								cTexto += PADr("05",2,"")
							ELSEIF cRote == "131" .OR. cRote == "132"
								cTexto += PADr("02",2,"")
							ENDIF


							//Número da linha Numérico 44 51 08
							cTexto += PADL(nLinha,8,"0")
							//Retorno processamento Numérico 52 53 02
							cTexto += PADr("",2,"")

							cTexto += CRLF // ENTER
							fWrite( nHdl, cTexto ) // IMPRIME
							nLinha ++ //SOMAR A LINHA
							nRFil  ++

						ENDIF	


						/*
						c. Detalhe da Filial - FUNCIONÁRIOS
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("31",2,"0")
						//Tipo de depósito Numérico 03 04 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF


						//Matrícula Alfanumérico 05 18 14
						cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
						//Valor Numérico 19 28 10
						//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RD_VALOR, "@E 999999999") ),10,"0")  
						cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RD_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0")// PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RD_VALOR),",",""),".","")),10,"0")           
						cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   "
						cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   "
						cTexto2 += TRANSFORM(TSRA->RD_VALOR,"@E 999,999,999.99")// PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RD_VALOR),",",""),".","")),10,"0")
						//Número da linha Numérico 29 36 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 37 38 02
						cTexto += PADR("",2,"")

						cTexto += CRLF // ENTER
						cTexto2 += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
						nLinha ++ //SOMAR A LINHA
						nRDep ++
						nValDep += TSRA->RD_VALOR

						TSRA->(DBSKIP())
					ENDDO
					TSRA->(dbgotop())

					IF nHdl == 0
						Alert("Não existe dados!")
						return
					ENDIF

					/*
					d. Trailler da Filial
					*/

					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("29",2,"")
					//Código da Empresa Numérico 03 07 05
					//cTexto += PADl("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Código da filial Numérico 08 12 05
					//cTexto += PADl("fil",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("1",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("1",5,"0")
					ENDIF 	
					//Tipo de pessoa Alfanumérico 13 13 01
					cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
					//CPF/CNPJ Numérico 14 27 14
					cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
					//Qtde de registros
					//enviados para deposito Numérico 28 35 08
					cTexto += PADL(nRDep,8,"0")
					//Valor dos registros
					//enviados para deposito Numérico 36 45 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0")
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0")   //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")   
					cTexto2 += CRLF
					cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")
					//Qtde de registros
					//depositados Numérico 46 53 08
					cTexto += PADR("",8,"")
					//Valor dos registros
					//depositados Numérico 54 63 10
					cTexto += PADR("",10,"")
					//Número da linha Numérico 64 71 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 72 73 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
					nLinha ++ //SOMAR A LINHA

					/*
					e. Trailler do Arquivo
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADR("19",2,"")
					//Código da empresa Numérico 03 07 05
					//cTexto += PADL("EMP",5,"0")
					IF TSRA->RA_FILIAL == '040101'
						cTexto += PADL("394",5,"0")
					ELSEIF TSRA->RA_FILIAL == '010101'
						cTexto += PADL("395",5,"0")
					ELSEIF TSRA->RA_FILIAL == '020101'
						cTexto += PADL("393",5,"0")
					ELSEIF TSRA->RA_FILIAL == '030101'
						cTexto += PADL("392",5,"0")
					ELSEIF TSRA->RA_FILIAL == '050101'
						cTexto += PADL("396",5,"0")
					ENDIF 	
					//Produto Numérico 08 09 02
					cTexto += PADR("01",2,"")
					//Quantidade de filiais Numérico 10 17 08
					cTexto += PADL(nRFil,8,"0")
					//Qtde total de registros
					//enviados para deposito Numérico 18 25 08
					cTexto += PADL(nRDep,8,"0")
					//Valor total de registros
					//enviados para deposito Numérico 26 35 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999")),10,"0") 
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
					//Qtde total de registros
					//depositados Numérico 36 43 08
					cTexto += PADR("",8,"0")
					//Valor total de registros
					//depositados Numérico 44 53 10
					cTexto += PADR("",10,"0")
					//Número da linha Numérico 54 61 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno do
					//processamento Numérico 62 63 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					nLinha ++ //SOMAR A LINHA
				endif

			ELSEIF cRote == "RES" .OR. cRote == "FER"
				// FAZER SELECT NA SRA 


				cQuery := " SELECT  *
				cQuery += " FROM "+RetSqlName("SRR")+" SRR  , "+RetSqlName("SRA")+ " SRA " 
				cQuery += " INNER JOIN (
				cQuery += " SELECT RA_FILIAL , RA_MAT 
				cQuery += " FROM SRA010 SRA
				cQuery += " LEFT JOIN "+RetSqlName("TFL")+ " TFL  ON TFL_FILIAL = SRA.RA_FILIAL AND SRA.RA_CC = TFL_YCC AND SRA.D_E_L_E_T_ = ''
				cQuery += " LEFT JOIN (
				cQuery += " SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , MAX(TFJ_CONREV) [TFJ_CONREV]
				cQuery += " FROM "+RetSqlName("TFJ")+ " TFJ  
				cQuery += " WHERE TFJ.D_E_L_E_T_ ='' 
				cQuery += " AND TFJ_STATUS = '1' 
				cQuery += " AND  TFJ_ENTIDA = '1'
				cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ cCliDe +"' AND '"+ cCliAt +"' OR  TFJ_CODENT IN ("+ if(alltrim(cCliin) == "","''",alltrim(cCliin)) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(cCliex) == "","''",alltrim(cCliex)) +") ) 
				cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(cLojaDe) +"' AND '"+ ALLTRIM(cLojaAt) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(cLojain) == "","''",ALLTRIM(cLojain)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(cLojaex) == '',"''",ALLTRIM(cLojaex)) +")) 
				cQuery += " AND  ( (TFJ_CONTRT BETWEEN '"+ ALLTRIM(cContDe) +"' AND '"+ ALLTRIM(cContAt) +"' OR  TFJ_CONTRT IN ("+ if(ALLTRIM(cConti) == "","''",ALLTRIM(cConti)) +") ) AND  TFJ_CONTRT NOT IN ("+ if(ALLTRIM(cConte) == "","''",ALLTRIM(cConte)) +")) 
				cQuery += " GROUP BY TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT
				cQuery += " ) AS TTFJ ON TFL_FILIAL = TFJ_FILIAL  AND TFL_CODPAI = TFJ_CODIGO 
				cQuery += " GROUP BY RA_FILIAL , RA_MAT 
				cQuery += " ) AS TSRA ON TSRA.RA_FILIAL = SRA.RA_FILIAL AND TSRA.RA_MAT = SRA.RA_MAT
				cQuery += " WHERE 
				cQuery += " SRA.D_E_L_E_T_ = '' 
				cQuery += " AND  ( (SRA.RA_MAT BETWEEN '"+ ALLTRIM(cMat1) +"' AND '"+ ALLTRIM(cMat2) +"' OR  SRA.RA_MAT IN ("+ if(ALLTRIM(cMatin) == "","''",ALLTRIM(cMatin)) +") ) AND  SRA.RA_MAT NOT IN ("+ if(ALLTRIM(cMatex) == "","''",ALLTRIM(cMatex)) +"))


				cQuery += " AND    SRR.D_E_L_E_T_ = '' "
				cQuery += " AND    SRA.RA_FILIAL = '"+ cFil1 +"' "
				cQuery += " AND    SRA.RA_CC BETWEEN '"+ cCC1 +"' and '"+ cCC2 +"'
				cQuery += " AND    SRA.RA_FILIAL = RR_FILIAL
				cQuery += " AND    SRA.RA_MAT = RR_MAT
				cQuery += " AND    SUBSTRING(SRA.RA_BCDEPSA,1,3) = '031'
				cQuery += " AND    RR_ROTEIR = '"+ cRote +"'
				IF cRote == "RES" 
					cQuery += " AND    RR_PD = '912'
				ELSEIF cRote == "FER"
					cQuery += " AND    RR_PD = '497'
				ENDIF
				cQuery += " AND    RR_SEMANA = '"+ TCOMP->RCH_NUMPAG +"'
				cQuery += " AND    RR_PERIODO = '"+ TCOMP->RCH_PER +"'
				cQuery += " ORDER BY SRA.RA_FILIAL , SRA.RA_MAT "

				IF SELECT("TSRA") > 0
					TSRA->(DBCLOSEAREA())
				ENDIF 
				TcQuery cQuery New Alias TSRA

				cFilt := ''
				cTexto := ""
				cTexto2 := "" 
				if TSRA->(EOF())
					Alert("Consulta não encontrou nenhum registro!")
					TSRA->(DBCLOSEAREA())
					Return
				endif 
				WHILE !TSRA->(EOF())
					MsProcTxt("Funcionário: " + TSRA->RA_NOME)
					IF cFilt  <> TSRA->RA_FILIAL
						// CRIAR AQUIVO 
						cFilt := TSRA->RA_FILIAL
						nHdl := fCreate(cArqOut+"APT_ARQ_DEP"+ "00000" + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')

						If nHdl == -1
							MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
							Return
						Endif

						// CRIAR ARQUIVO LOG
						cFilt := TSRA->RA_FILIAL
						nHdlLog := fCreate(cArqOut+"RELATORIO_DEP"+ cFilt + DTOS(DDATABASE) + STRTRAN(TIME(), ":", "") + '.txt')


						/*
						a. Header do Arquivo
						*/

						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("11",2,"")
						//Versão do layout do
						//arquivo Numérico 03 05 03
						cTexto += PADr("001",3,"")
						//Código da empresa Numérico 06 10 05
						//cTexto += PADl("EMP",5,"0")
						IF TSRA->RA_FILIAL == '040101'
							cTexto += PADL("394",5,"0")
						ELSEIF TSRA->RA_FILIAL == '010101'
							cTexto += PADL("395",5,"0")
						ELSEIF TSRA->RA_FILIAL == '020101'
							cTexto += PADL("393",5,"0")
						ELSEIF TSRA->RA_FILIAL == '030101'
							cTexto += PADL("392",5,"0")
						ELSEIF TSRA->RA_FILIAL == '050101'
							cTexto += PADL("396",5,"0")
						ENDIF 	
						//Produto Numérico 11 12 02
						cTexto += PADr("01",2,"")
						//Data de geração do
						//arquivo Data 13 20 08
						cTexto += PADr(SUBSTR(DTOS(DDATABASE),7,2) + SUBSTR(DTOS(DDATABASE),5,2) + SUBSTR(DTOS(DDATABASE),1,4),8,"")
						//Hora de geração do
						//arquivo Hora 21 26 06
						cTexto += PADr(STRTRAN(TIME(), ":", ""),6,"")
						//Código de remessa Numérico 27 36 10
						cTexto += PADr("",2,"10")
						//Código do arquivo
						//(retorno) Numérico 37 46 10
						cTexto += PADr("",10,"")
						//Número da linha Numérico 47 54 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno do processamento Numérico 55 56 02
						cTexto += PADr("",2,"")

						cTexto += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						nLinha ++ //SOMAR A LINHA

						/*
						b. Header da Filial
						*/
						cTexto := ""
						cTexto2 := ""
						//Identificador do registro
						//Header Numérico 01 02 02
						cTexto += PADr("21",02,"")
						//Código da Empresa Numérico 03 07 05
						//cTexto += PADL("EMP",5,"0")
						IF TSRA->RA_FILIAL == '040101'
							cTexto += PADL("394",5,"0")
						ELSEIF TSRA->RA_FILIAL == '010101'
							cTexto += PADL("395",5,"0")
						ELSEIF TSRA->RA_FILIAL == '020101'
							cTexto += PADL("393",5,"0")
						ELSEIF TSRA->RA_FILIAL == '030101'
							cTexto += PADL("392",5,"0")
						ELSEIF TSRA->RA_FILIAL == '050101'
							cTexto += PADL("396",5,"0")
						ENDIF 	
						//Código da filial Numérico 08 12 05
						//cTexto += PADL("FIL",5,"0")
						IF TSRA->RA_FILIAL == '040101'
							cTexto += PADL("1",5,"0")
						ELSEIF TSRA->RA_FILIAL == '010101'
							cTexto += PADL("1",5,"0")
						ELSEIF TSRA->RA_FILIAL == '020101'
							cTexto += PADL("1",5,"0")
						ELSEIF TSRA->RA_FILIAL == '030101'
							cTexto += PADL("1",5,"0")
						ELSEIF TSRA->RA_FILIAL == '050101'
							cTexto += PADL("1",5,"0")
						ENDIF 	
						//Tipo de pessoa Alfanumérico 13 13 01
						cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
						//CPF/CNPJ Numérico 14 27 14
						cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
						//Data de prevista do
						//depósito Data 28 35 08
						cTexto += PADr(SUBSTR(dDep,1,2) + SUBSTR(dDep,3,2) + SUBSTR(dDep,5,4),8,"")
						//Competencia Numérico 36 41 06
						cTexto += PADr(substr(TSRA->RR_PERIODO,5,2)+substr(TSRA->RR_PERIODO,1,4),6,"")
						//Tipo de Depósito Numérico 42 43 02
						// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
						IF cRote == "FOL"
							cTexto += PADr("01",2,"")
						ELSEIF cRote == "FER"
							cTexto += PADr("03",2,"")
						ELSEIF cRote == "RES"
							cTexto += PADr("05",2,"")
						ELSEIF cRote == "131" .OR. cRote == "132"
							cTexto += PADr("02",2,"")
						ENDIF


						//Número da linha Numérico 44 51 08
						cTexto += PADL(nLinha,8,"0")
						//Retorno processamento Numérico 52 53 02
						cTexto += PADr("",2,"")

						cTexto += CRLF // ENTER
						fWrite( nHdl, cTexto ) // IMPRIME
						nLinha ++ //SOMAR A LINHA
						nRFil  ++

					ENDIF	


					/*
					c. Detalhe da Filial - FUNCIONÁRIOS
					*/
					cTexto := ""
					cTexto2 := ""
					//Identificador do registro
					//Header Numérico 01 02 02
					cTexto += PADr("31",2,"0")
					//Tipo de depósito Numérico 03 04 02
					// UTILIZA SOMENTE 1-> SALARIO 3-> FERIAS 5->RESCISÃO 
					IF cRote == "FOL"
						cTexto += PADr("01",2,"")
					ELSEIF cRote == "FER"
						cTexto += PADr("03",2,"")
					ELSEIF cRote == "RES"
						cTexto += PADr("05",2,"")
					ELSEIF cRote == "131" .OR. cRote == "132"
						cTexto += PADr("02",2,"")
					ENDIF


					//Matrícula Alfanumérico 05 18 14
					cTexto += PADr(ALLTRIM(CVALTOCHAR(VAL(TSRA->RA_MAT))),14,"")
					//Valor Numérico 19 28 10
					//cTexto += PADL(ALLTRIM(TRANSFORM(TSRA->RR_VALOR, "@E 999999999") ),10,"0")    
					cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(TSRA->RR_VALOR,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RR_VALOR),",",""),".","")),10,"0")        
					cTexto2 += ALLTRIM(TSRA->RA_MAT) + "   "
					cTexto2 += SUBSTR(TSRA->RA_NOME,1,30) + "   "
					cTexto2 += TRANSFORM(TSRA->RR_VALOR,"@E 999,999,999.99") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(TSRA->RR_VALOR),",",""),".","")),10,"0")
					//Número da linha Numérico 29 36 08
					cTexto += PADL(nLinha,8,"0")
					//Retorno processamento Numérico 37 38 02
					cTexto += PADR("",2,"")

					cTexto += CRLF // ENTER
					cTexto2 += CRLF // ENTER
					fWrite( nHdl, cTexto ) // IMPRIME
					fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
					nLinha ++ //SOMAR A LINHA
					nRDep ++
					nValDep += TSRA->RR_VALOR

					TSRA->(DBSKIP())
				ENDDO
				TSRA->(dbgotop())

				IF nHdl == 0
					Alert("Não existe dados!")
					return
				ENDIF
				/*
				d. Trailler da Filial
				*/

				cTexto := ""
				cTexto2 := ""
				//Identificador do registro
				//Header Numérico 01 02 02
				cTexto += PADR("29",2,"")
				//Código da Empresa Numérico 03 07 05
				//cTexto += PADl("EMP",5,"0")
				IF TSRA->RA_FILIAL == '040101'
					cTexto += PADL("394",5,"0")
				ELSEIF TSRA->RA_FILIAL == '010101'
					cTexto += PADL("395",5,"0")
				ELSEIF TSRA->RA_FILIAL == '020101'
					cTexto += PADL("393",5,"0")
				ELSEIF TSRA->RA_FILIAL == '030101'
					cTexto += PADL("392",5,"0")
				ELSEIF TSRA->RA_FILIAL == '050101'
					cTexto += PADL("396",5,"0")
				ENDIF 	
				//Código da filial Numérico 08 12 05
				//cTexto += PADl("fil",5,"0")
				IF TSRA->RA_FILIAL == '040101'
					cTexto += PADL("1",5,"0")
				ELSEIF TSRA->RA_FILIAL == '010101'
					cTexto += PADL("1",5,"0")
				ELSEIF TSRA->RA_FILIAL == '020101'
					cTexto += PADL("1",5,"0")
				ELSEIF TSRA->RA_FILIAL == '030101'
					cTexto += PADL("1",5,"0")
				ELSEIF TSRA->RA_FILIAL == '050101'
					cTexto += PADL("1",5,"0")
				ENDIF 	
				//Tipo de pessoa Alfanumérico 13 13 01
				cTexto += IF(LEN(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC"))) == 14 ,'J','F')
				//CPF/CNPJ Numérico 14 27 14
				cTexto += PADL(ALLTRIM(POSICIONE("SM0",1,cEmpAnt+TSRA->RA_FILIAL,"M0_CGC")),14,"0")
				//Qtde de registros
				//enviados para deposito Numérico 28 35 08
				cTexto += PADL(nRDep,8,"0")
				//Valor dos registros
				//enviados para deposito Numérico 36 45 10
				//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0") 
				cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")  
				cTexto2 += CRLF
				cTexto2 += "TOTAL " + SPACE(24) + TRANSFORM(nValDep,"@E 999,999,999.99")

				//Qtde de registros
				//depositados Numérico 46 53 08
				cTexto += PADR("",8,"")
				//Valor dos registros
				//depositados Numérico 54 63 10
				cTexto += PADR("",10,"")
				//Número da linha Numérico 64 71 08
				cTexto += PADL(nLinha,8,"0")
				//Retorno processamento Numérico 72 73 02
				cTexto += PADR("",2,"")

				cTexto += CRLF // ENTER
				cTexto2 += CRLF // ENTER
				fWrite( nHdl, cTexto ) // IMPRIME
				fWrite( nHdlLog, cTexto2 ) // IMPRIME Log
				nLinha ++ //SOMAR A LINHA

				/*
				e. Trailler do Arquivo
				*/
				cTexto := ""
				cTexto2 := ""
				//Identificador do registro
				//Header Numérico 01 02 02
				cTexto += PADR("19",2,"")
				//Código da empresa Numérico 03 07 05
				//cTexto += PADL("EMP",5,"0")
				IF TSRA->RA_FILIAL == '040101'
					cTexto += PADL("394",5,"0")
				ELSEIF TSRA->RA_FILIAL == '010101'
					cTexto += PADL("395",5,"0")
				ELSEIF TSRA->RA_FILIAL == '020101'
					cTexto += PADL("393",5,"0")
				ELSEIF TSRA->RA_FILIAL == '030101'
					cTexto += PADL("392",5,"0")
				ELSEIF TSRA->RA_FILIAL == '050101'
					cTexto += PADL("396",5,"0")
				ENDIF 	
				//Produto Numérico 08 09 02
				cTexto += PADR("01",2,"")
				//Quantidade de filiais Numérico 10 17 08
				cTexto += PADL(nRFil,8,"0")
				//Qtde total de registros
				//enviados para deposito Numérico 18 25 08
				cTexto += PADL(nRDep,8,"0")
				//Valor total de registros
				//enviados para deposito Numérico 26 35 10
				//cTexto += PADL(ALLTRIM(TRANSFORM(nValDep, "@E 999999999") ),10,"0") 
				cTexto += PADL(ALLTRIM(STRTRAN(STRTRAN(TRANSFORM(nValDep,"@E 999,999,999.99"),",",""),".","")),10,"0") //PADL(ALLTRIM(STRTRAN(STRTRAN(cvaltochar(nValDep),",",""),".","")),10,"0")
				//Qtde total de registros
				//depositados Numérico 36 43 08
				cTexto += PADR("",8,"0")
				//Valor total de registros
				//depositados Numérico 44 53 10
				cTexto += PADR("",10,"0")
				//Número da linha Numérico 54 61 08
				cTexto += PADL(nLinha,8,"0")
				//Retorno do
				//processamento Numérico 62 63 02
				cTexto += PADR("",2,"")

				cTexto += CRLF // ENTER
				fWrite( nHdl, cTexto ) // IMPRIME
				nLinha ++ //SOMAR A LINHA

			ENDIF

			fClose(nHdlLog) /// libera arquivo de log

		endif

		TCOMP->(DBSKIP())
	enddo

	fClose(nHdl) /// libera aquivo de envio 

Return 



User Function FMULSA1S(cTitulo,lTipoRet)

	//Exemplo extraído da função GPEXFUNW, mas com pequenas modificações

	Local MvPar := ""
	Local MvParDef:=""	
	Private aCat:={}

	Default cTitulo:=""		//O titulo não é obrigatório pois pode ser pegar o titulo da tabela SX5
	Default lTipoRet := .T.

	l1Elem := If (l1Elem = Nil , .F. , .T.)

	cAlias := Alias() // Salva Alias Anterior


	cTitulo := Alltrim(Left("Tabela de Clientes",20))

	cQuery :="SELECT * FROM "+RetSqlName("SA1")+ " SA1 "
	cQuery +="WHERE D_E_L_E_T_ = ' ' "
	cQuery +="ORDER BY A1_COD "
	If select("TSA1") > 0
		TSA1->(dbCloseArea())
	Endif
	TcQuery cQuery new Alias TSA1


	If !TSA1->(EOF()) // DIFERENTE DE VAZIO
		CursorWait()
		aCat := {}
		While !TSA1->(EOF())
			Aadd(aCat,"'"+Left(TSA1->A1_COD,6)+"'," + " - " + Alltrim(TSA1->A1_NOME))
			MvParDef+="'"+Left(TSA1->A1_COD,6)+"',"
			TSA1->(dbSkip())
		Enddo
		CursorArrow()
	Else
		Help('',1,'FMULTIOP',,'As opções não foram inseridas!',1,0)
	Endif

	IF lTipoRet
		If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,9)
			&(__ReadVar) := mvpar
		EndIf
	EndIF

	dbSelectArea(cAlias) // Retorna Alias	
Return( IF( lTipoRet , .T. , MvParDef ) )

// CONTRATOS 
User Function FMULCN9S(cTitulo,lTipoRet)

	//Exemplo extraído da função GPEXFUNW, mas com pequenas modificações

	Local MvPar := ""
	Local MvParDef:=""	
	Private aCat:={}

	Default cTitulo:=""		//O titulo não é obrigatório pois pode ser pegar o titulo da tabela SX5
	Default lTipoRet := .T.

	l1Elem := If (l1Elem = Nil , .F. , .T.)

	cAlias := Alias() // Salva Alias Anterior


	cTitulo := Alltrim(Left("Tabela de Contratos",20))

	cQuery :=" SELECT TFJ_FILIAL ,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT , max(TFJ_CONREV) [TFJ_CONREV] 
	cQuery +=" FROM "+RetSqlName("TFJ")+ " TFJ "
	cQuery +=" WHERE D_E_L_E_T_ = ' ' "
	cQuery +=" AND TFJ_FILIAL = '"+ SRA->RA_FILIAL +"'
	cQuery +=" AND TFJ_STATUS = '1'
	cQuery +=" AND TFJ_ENTIDA = '1'
	cQuery +=" AND TFJ_CONTRT <> ''
	cQuery += " AND  ( (TFJ_CODENT BETWEEN '"+ ALLTRIM(mv_par09) +"' AND '"+ ALLTRIM(mv_par10) +"' OR  TFJ_CODENT IN ("+ if(alltrim(SUBSTR(strtran(mv_par11,"*",""),1,LEN(ALLTRIM(strtran(mv_par11,"*",""))) - 1)) == "","''",alltrim(SUBSTR(strtran(mv_par11,"*",""),1,LEN(ALLTRIM(strtran(mv_par11,"*",""))) - 1))) +") ) AND  TFJ_CODENT NOT IN ("+ if(alltrim(SUBSTR(strtran(mv_par12,"*",""),1,LEN(ALLTRIM(strtran(mv_par12,"*",""))) - 1)) == "","''",alltrim(SUBSTR(strtran(mv_par12,"*",""),1,LEN(ALLTRIM(strtran(mv_par12,"*",""))) - 1))) +") ) 
	cQuery += " AND  ( (TFJ_LOJA   BETWEEN '"+ ALLTRIM(mv_par13) +"' AND '"+ ALLTRIM(mv_par14) +"' OR  TFJ_LOJA IN ("+ if(ALLTRIM(mv_par15) == "","''",ALLTRIM(mv_par15)) +") ) AND  TFJ_LOJA NOT IN ("+ if(ALLTRIM(mv_par16) == "","''",ALLTRIM(mv_par16)) +"))
	cQuery +=" GROUP BY TFJ_FILIAL ,TFJ_CODENT , TFJ_LOJA , TFJ_CONTRT "
	cQuery +=" ORDER BY TFJ_CODENT,TFJ_LOJA "

	If select("TCN9") > 0
		TCN9->(dbCloseArea())
	Endif
	TcQuery cQuery new Alias TCN9


	If !TCN9->(EOF()) // DIFERENTE DE VAZIO
		CursorWait()
		aCat := {}
		While !TCN9->(EOF())
			Aadd(aCat,"'"+Left(TCN9->TFJ_CONTRT,18)+"'," + " -  Cliente:" +alltrim(TCN9->TFJ_CODENT) + " Loja:" + TCN9->TFJ_LOJA )
			MvParDef+="'"+Left(TCN9->TFJ_CONTRT,18)+"',"
			TCN9->(dbSkip())
		Enddo
		CursorArrow()
	Else
		Help('',1,'FMULTIOP',,'As opções não foram inseridas!',1,0)
	Endif

	IF lTipoRet
		If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,18)
			&(__ReadVar) := mvpar
		EndIf
	EndIF

	dbSelectArea(cAlias) // Retorna Alias	
Return( IF( lTipoRet , .T. , MvParDef ) )


User Function FMULSRAS(cTitulo,lTipoRet)


	//Exemplo extraído da função GPEXFUNW, mas com pequenas modificações

	Local MvPar := ""
	Local MvParDef:=""	
	Private aCat:={}

	Default cTitulo:=""		//O titulo não é obrigatório pois pode ser pegar o titulo da tabela SX5
	Default lTipoRet := .T.

	l1Elem := If (l1Elem = Nil , .F. , .T.)

	cAlias := Alias() // Salva Alias Anterior


	cTitulo := Alltrim(Left("Tabela de Funcionarios",20))

	cQuery :=" SELECT * FROM "+RetSqlName("SRA")+ " SRA "
	cQuery +=" WHERE D_E_L_E_T_ = ' ' "
	cQuery +=" AND RA_FILIAL = '"+ SRA->RA_FILIAL +"'
	cQuery +=" AND RA_SITFOLH NOT IN ('D','T')
	cQuery +=" ORDER BY RA_MAT "
	If select("TSRA") > 0
		TSRA->(dbCloseArea())
	Endif
	TcQuery cQuery new Alias TSRA


	If !TSRA->(EOF()) // DIFERENTE DE VAZIO
		CursorWait()
		aCat := {}
		While !TSRA->(EOF())
			Aadd(aCat,"'"+Left(TSRA->RA_MAT,6)+"'," + " - " + Alltrim(TSRA->RA_NOME))
			MvParDef+="'"+Left(TSRA->RA_MAT,6)+"',"
			TSRA->(dbSkip())
		Enddo
		CursorArrow()
	Else
		Help('',1,'FMULTIOP',,'As opções não foram inseridas!',1,0)
	Endif

	IF lTipoRet
		If f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,9)
			&(__ReadVar) := mvpar
		EndIf
	EndIF

	dbSelectArea(cAlias) // Retorna Alias	
Return( IF( lTipoRet , .T. , MvParDef ) )