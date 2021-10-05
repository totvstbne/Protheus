#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"
#include "topconn.ch"
#Define CRLF CHR(13)+CHR(10)

user function RSERV015()

	Local aPergs	:= {}
	Local aRetOpc	:= {}
	Local cFilde    := space(6)
	Local cFilate   := space(6)
	Local cPeriod   := space(6)
	Local cDiret    := space(240)
	Local cRoteiro  := space(3)
	Local aOpc      := {"","FOL","132"}
	//	Local aOpc2     := {"","Vale Alimentação","Cesta Basica"}
	Local cMat      := space(6)
	Local cMeioTr   := space(2)

	Local cMenComp  := "" 

	aAdd( aPergs ,{1,"Filial de",	cFilde	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Filial de",	cFilate	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Período",	    cPeriod	,GetSx3Cache("RG2_ANOMES","X3_PICTURE") ,'.T.',"" ,'.T.',6,.T.})
	aAdd( aPergs ,{1,"Diretório",	cDiret	,GetSx3Cache("RA_NOME","X3_PICTURE") ,'.T.',"" ,'.T.',100,.T.})
	//aAdd( aPergs ,{1,"Roteiro",	    cRoteiro,GetSx3Cache("RR_ROTEIR","X3_PICTURE") ,'.T.',"" ,'.T.',3,.T.})
	aAdd( aPergs ,{2,"Roteiro", ,aOpc,100  ,'.T.',.T.})
	//	aAdd( aPergs ,{2,"VA / CB", ,aOpc2,100  ,'.T.',.T.})
	aAdd( aPergs ,{1,"Matricula de",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula ate",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	//	aAdd( aPergs ,{1,"Cod Beneficio",cMeioTr,GetSx3Cache("RN_COD","X3_PICTURE") ,'.T.',"SRN" ,'.T.',30,.T.})




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

	Private cFil1 := alltrim(aRetOpc[1])
	Private cFil2 := alltrim(aRetOpc[2])
	Private cPeri1:= alltrim(aRetOpc[3])
	Private cRote := alltrim(aRetOpc[5])
	Private cMat1 := alltrim(aRetOpc[6])
	Private cMat2 := alltrim(aRetOpc[7])


	Private cArqOut   := alltrim(aRetOpc[4])+"/FOLHA.TXT"
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
	Local nNumFunc := 0
	Local nProv := 0
	Local nDesc := 0
	Local nLiqPg := 0
	Local nValLiq := 0


	//1* verificar se o período informado ´é fechado (RG2) ou aberto (SR0)  RCH_PERSEL = '1' 
	cQuery1 := " SELECT *
	cQuery1 += " FROM "+RetSqlName("RCH")+" RCH  "	
	cQuery1 += " WHERE RCH_ROTEIR = '"+cRote+"'  "
	cQuery1 += " AND RCH_FILIAL BETWEEN '"+ xfilial("RCH",cFil1) +"' AND '"+ xfilial("RCH",cFil2) +"' 
	cQuery1 += " AND RCH_MES = '"+ SUBSTR(cPeri1,1,2) +"' 
	cQuery1 += " AND RCH_ANO = '"+ SUBSTR(cPeri1,3,4) +"' 
	cQuery1 += " AND D_E_L_E_T_='' 
	IF SELECT("TCOMP") > 0
		TCOMP->(DBCLOSEAREA())
	ENDIF 
	TcQuery cQuery1 New Alias TCOMP	


	HEADER := ""    
	WHILE !TCOMP->(EOF())


		IF TCOMP->RCH_PERSEL == '1' // ATIVO ---- VERIFICO NA SRC 

			// FAZER SELECT NA SRA
			cQuery := " SELECT *
			cQuery += " FROM   "+RetSqlName("SRA")+" SRA  "
			cQuery += " WHERE  D_E_L_E_T_ = ''  "
			cQuery += " AND    RA_FILIAL BETWEEN '"+XFILIAL("SRA",cFil1)+"' AND '"+ XFILIAL("SRA",cFil2) +"'
			cQuery += " AND    RA_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
			cQuery += " AND    RA_SITFOLH NOT IN ('D')
			cQuery += " ORDER BY RA_FILIAL ,RA_CC, RA_MAT "

			IF SELECT("TGPE") > 0
				TGPE->(DBCLOSEAREA())
			ENDIF 
			TcQuery cQuery New Alias TGPE

			//Cria Arquivo de saida
			nHdl := fCreate(cArqOut)

			If nHdl == -1
				MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
				Return
			Endif

			IF HEADER == ""
				// PEGAR OS DADOS DA EMPRESA "HEADER Da Empresa = 0"
				cTexto := ""

				dbSelectArea("SM0")
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+TGPE->RA_FILIAL))

				//Numero do Layout	
				cTexto += PADr("0", 1,"")	
				//Nome da Empresa		
				cTexto += PADr(SM0->M0_NOMECOM,40,"")
				//Numero do CNPJ / CGC		
				cTexto += PADr(SM0->M0_CGC,14,"")
				//Nome da Rua da Empresa	
				cNum1     := At(",",SM0->M0_ENDCOB)
				cTexto += PADr(ALLTRIM(SUBSTR(SM0->M0_ENDCOB,1 ,cNum1 - 1)),30,"")	
				//Numero da Empresa	
				cNum1     := At(",",SM0->M0_ENDCOB)
				cTexto += PADr(ALLTRIM(SUBSTR(SM0->M0_ENDCOB,cNum1 + 1 , 6)),4,"")		
				//Bairro da Empresa		
				cTexto += PADr(SM0->M0_BAIRCOB,30,"")
				//Cidade da Empresa
				cTexto += PADr(SM0->M0_CIDCOB,30,"")		
				//Estado da Empresa		
				cTexto += PADr(SM0->M0_ESTCOB,2,"")
				//Cep da Empresa		
				cTexto += PADr(SM0->M0_CEPCOB,8,"")
				//Telefone da Empresa		
				cTexto += PADr(SM0->M0_TEL,13,"")
				//Fax da Empresa		
				cTexto += PADr(SM0->M0_FAX,13,"")
				//Tipo de Folha		
				cTexto += PADr("",15,"")
				//Data da Geração do Arquivo	
				cTexto += PADr(DTOS(DATE()),08,"")	
				//Data do Credito		
				cTexto += PADr("",08,"")
				//Site da Empresa		
				cTexto += PADr("",15,"")
				//Linha de Assinatura		
				cTexto += PADr("",01,"")
				//Quantidade de Vias		
				cTexto += PADr("",01,"")
				//Mês e Ano		
				cTexto += PADr(cPeri1,06,"")
				//Versão do Sistemas		
				cTexto += PADr("1",01,"")

				cTexto += CRLF
				fWrite( nHdl, cTexto )	

				HEADER := "OK"
			ENDIF
			// verificar todos os funcionários 

			nCautP := 0
			while !TGPE->(eof())
				MsProcTxt("Funcionário: " + TGPE->RA_NOME)
				// FAZER SELECT NA SR0 
				cQuery := " SELECT *
				cQuery += " FROM   "+RetSqlName("SRC")+" SRC  "
				cQuery += " INNER JOIN   "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+ XFILIAL("SRV",TGPE->RA_FILIAL) +"' AND RV_COD = RC_PD AND SRV.D_E_L_E_T_ = '' " //AND RV_TIPOCOD  IN ('1','2') 
				cQuery += " WHERE    SRC.D_E_L_E_T_ = ''  "
				cQuery += " AND      RC_FILIAL = '"+ XFILIAL("SRC",TGPE->RA_FILIAL) +"'
				cQuery += " AND      RC_MAT = '"+ TGPE->RA_MAT +"'
				cQuery += " AND      RC_ROTEIR = '"+ cRote +"'
				cQuery += " AND      RC_PERIODO = '"+ SUBSTR(cPeri1,3,4)+SUBSTR(cPeri1,1,2) +"'
				cQuery += " ORDER BY RC_FILIAL , RC_PD "

				IF SELECT("TSRC") > 0
					TSRC->(DBCLOSEAREA())
				ENDIF 
				TcQuery cQuery New Alias TSRC

				// PERCORER TODOS OS LANÇAMENTOS 

				HEADER1 := ""
				HEADER2 := ""
				HEADER4 := ""
				nTotP   := 0
				nTotD   := 0

				// CASO NAO TENHA VALORES , PROXIMO REGISTRO
				IF TSRC->(EOF())
					TGPE->(DBSKIP())
					LOOP
				ENDIF

				nNumFunc += 1

				//carregando variaveis 
				nValLiq      := 0
				nValSalB	 := 0
				nValBasInss  := 0
				nValSacInss  := 0
				nValBasIr    := 0
				nValBasFgts  := 0

				WHILE  !TSRC->(EOF())
					cTexto := ""
					cTexPd := ""


					//BUSCA PELA ULTIMA LOCALIZAÇÃO ABB E ABS
					/*
					cQuery := " SELECT TOP 1 *
					cQuery += " FROM   "+RetSqlName("ABB")+" ABB , "+RetSqlName("ABS")+" ABS  "
					cQuery += " WHERE    ABB.D_E_L_E_T_ = '' AND ABS.D_E_L_E_T_ = ''  "
					cQuery += " AND      ABB_FILIAL = '"+ XFILIAL("ABB",TSRC->RC_FILIAL) +"'
					cQuery += " AND      ABB_CODTEC = '"+ ALLTRIM(XFILIAL("ABB",TSRC->RC_FILIAL)) + ALLTRIM(TSRC->RC_MAT) +"'
					cQuery += " AND      ABB_LOCAL = ABS_LOCAL 
					cQuery += " ORDER BY ABB_DTINI DESC 

					IF SELECT("TABS") > 0
					TABS->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TABS
					*/

					cQuery := " SELECT RA_FILIAL, RA_MAT, ABS_DESCRI , ABS_LOCAL
					cQuery += " FROM (
					cQuery += " SELECT RA_FILIAL,RA_MAT  , RA_NOME , RA_CC , TFL_LOCAL ,MAX(TFL_CONREV) TFL_CONREV
					cQuery += " FROM "+RetSqlName("SRA")+" SRA , "+RetSqlName("TFL")+" TFL 
					cQuery += " WHERE SRA.D_E_L_E_T_=''
					cQuery += " AND TFL.D_E_L_E_T_=''
					cQuery += " AND RA_FILIAL = TFL_FILIAL 
					cQuery += " AND RA_CC = TFL_YCC
					cQuery += " GROUP BY RA_FILIAL , RA_MAT , RA_NOME , RA_CC, TFL_LOCAL 
					cQuery += " ) TABA ,  "+RetSqlName("ABS")+" ABS 
					cQuery += " WHERE ABS.D_E_L_E_T_ = ''
					cQuery += " AND ABS_LOCAL  = TFL_LOCAL
					cQuery += " AND RA_FILIAL  = "+ TSRC->RC_FILIAL +" 
					cQuery += " AND RA_MAT  = "+ TSRC->RC_MAT +" 
					cQuery += " ORDER BY RA_FILIAL , RA_MAT

					IF SELECT("TABS") > 0
						TABS->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TABS

					//HEADER de Postagem = 1
					IF HEADER1 == ""
						cTexto := ""
						//Numero do Layout		
						cTexto += PADr("1",01,"")

						IF !TABS->(EOF())
							//Nome da Locação do Funcionario
							cTexto += PADr(TABS->ABS_DESCRI,40,"")		
							//Cod. Da Locaçao/Seção/Setor
							cTexto += PADr(TABS->ABS_LOCAL,15,"")
							cCodLoc :=	TABS->ABS_LOCAL
						ELSE

							// BUSCAR NA CTT
							cQuery := " SELECT RA_FILIAL , RA_MAT , RA_CC , CTT_CUSTO, CTT_DESC01
							cQuery += " FROM "+RetSqlName("SRA")+" SRA , "+RetSqlName("CTT")+" CTT
							cQuery += " WHERE 
							cQuery += " SRA.D_E_L_E_T_=''
							cQuery += " AND CTT.D_E_L_E_T_=''
							cQuery += " AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT_FILIAL
							cQuery += " AND SRA.RA_CC = CTT_CUSTO
							cQuery += " AND RA_FILIAL  = "+ TSRC->RC_FILIAL +" 
							cQuery += " AND RA_MAT  = "+ TSRC->RC_MAT +" 
							cQuery += " ORDER BY RA_FILIAL , RA_MAT

							IF SELECT("TAB2") > 0
								TAB2->(DBCLOSEAREA())
							ENDIF 
							TcQuery cQuery New Alias TAB2

							IF RAT(ALLTRIM(TAB2->CTT_DESC01),"-") > 0 
								//Nome da Locação do Funcionario
								cTexto += PADr( SUBSTR(RAT(ALLTRIM(TAB2->CTT_DESC01),"-"),RAT(ALLTRIM(TAB2->CTT_DESC01),"-")+1,LEN(ALLTRIM(TAB2->CTT_DESC01))),40,"")		
								//Cod. Da Locaçao/Seção/Setor
								cTexto += PADr(SUBSTR(TAB2->RA_CC,6,7),15,"")
								cCodLoc :=	""

							ELSE
								//Nome da Locação do Funcionario
								cTexto += PADr(ALLTRIM(TAB2->CTT_DESC01),40,"")		
								//Cod. Da Locaçao/Seção/Setor
								cTexto += PADr(SUBSTR(TAB2->RA_CC,6,7),15,"")
								cCodLoc :=	""
							ENDIF

						ENDIF
						//Matricula do Funcionario
						cTexto += PADr(TSRC->RC_MAT,06,"")		
						//Nome do Funcionario
						cTexto += PADr(if(alltrim(TGPE->RA_NOMECMP) == "",TGPE->RA_NOME,TGPE->RA_NOMECMP),40,"")		
						//Endereço do Funcionario
						cTexto += PADr(TGPE->RA_ENDEREC,50,"")		
						//Numero da Casa	
						cTexto += PADr(TGPE->RA_NUMENDE,04,"")	
						//Bairro do Funcionario
						cTexto += PADr(TGPE->RA_BAIRRO,20,"")		
						//Cidade do Funcionario
						cTexto += PADr(TGPE->RA_MUNNASC,20,"")		
						//Estado do Funcionario
						cTexto += PADr(TGPE->RA_NATURAL,02,"")		
						//Cep do Funcionario
						cTexto += PADr(TGPE->RA_CEP,08,"")		
						//Filler		
						cTexto += PADr("",34,"")

						cTexto += CRLF
						fWrite( nHdl, cTexto )	

						HEADER1 := "OK"
						TABS->(DBCLOSEAREA())
					ENDIF

					//HEADER de Postagem = 2
					IF HEADER2 == ""
						cTexto := ""
						//Numero do Layout		
						cTexto += PADr("2",1,"")
						//Cod. Da Locaçao/Seção/Setor
						cTexto += PADr(cCodLoc,15,"")		
						//Matricula do Funcionario
						cTexto += PADr(TSRC->RC_MAT,6,"")		
						//Nome do Funcionario
						cTexto += PADr(if(alltrim(TGPE->RA_NOMECMP) == "",TGPE->RA_NOME,TGPE->RA_NOMECMP),40,"")		
						//Admissão do Funcionario
						cTexto += PADr(TGPE->RA_ADMISSA,8,"")		
						//Cargo do Funcionario
						cTexto += PADr(POSICIONE("SQ3",1,XFILIAL("SQ3",TGPE->RA_FILIAL)+TGPE->RA_CARGO,"Q3_DESCSUM"),30,"")		
						//Carteira Proficional do Funcionario
						cTexto += PADr(TGPE->RA_NUMCP,08,"")		
						//Serie		
						cTexto += PADr(TGPE->RA_SERCP,05,"")
						//C.P.F do Funcionario		
						cTexto += PADr(TGPE->RA_CIC,11,"")
						//PIS do Funcionario
						cTexto += PADr(TGPE->RA_PIS,11,"")		
						//RG do Funcionario	
						cTexto += PADr(TGPE->RA_RG,20,"")	
						//Banco		
						cTexto += PADr(SUBSTR(TGPE->RA_BCDEPSA,1,3),3,"")
						//Numero da Agência
						cTexto += PADr(SUBSTR(TGPE->RA_BCDEPSA,5,5),6,"")		
						//Nome Agência		
						cTexto += PADr("",29,"")
						//Numero da Conta Corrente+DV
						cTexto += PADr(SUBSTR(TGPE->RA_CTDEPSA,5,5),8,"")		
						//Filler		
						cTexto += PADr("",39,"")


						cTexto += CRLF
						fWrite( nHdl, cTexto )	

						HEADER2 := "OK"
					ENDIF

					//HEADER das Verbas = 3
					IF TSRC->RV_TIPOCOD == '1' .OR. TSRC->RV_TIPOCOD == '2'
						cTexto := ""

						//Numero do Layout		
						cTexto += PADr("3",1,"")					
						//Verba		
						cTexto += PADr(TSRC->RC_PD,3,"")
						//Descrição		
						cTexto += PADr(TSRC->RV_DESC,40,"")
						//Referência		
						cTexto += PADr(TSRC->RC_HORAS,10,"")

						IF TSRC->RV_TIPOCOD == '1' //PROVENTO 

							//Vantagens	
							if   at(".",cValToChar(TSRC->RC_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')+"00"),12,"0")
							elseif (len(cValToChar(TSRC->RC_VALOR)) - at(".",cValToChar(TSRC->RC_VALOR))) == 1
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')+"0"),12,"0")
							elseif   (len(cValToChar(TSRC->RC_VALOR)) - at(".",cValToChar(TSRC->RC_VALOR))) == 2
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')),12,"0")
							elseif at(".",cValToChar(TSRC->RC_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')+"00"),12,"0")
							endif	
							//cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')),12,"0")
							//Descontos		
							cTexto += PADr("",12,"")

							nTotP += TSRC->RC_VALOR
							nProv += TSRC->RC_VALOR
						ELSEIF TSRC->RV_TIPOCOD == '2' // DESCONTO 

							//Vantagens		
							cTexto += PADr("",12,"")
							//Descontos		
							if   at(".",cValToChar(TSRC->RC_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')+"00"),12,"0")
							elseif (len(cValToChar(TSRC->RC_VALOR)) - at(".",cValToChar(TSRC->RC_VALOR))) == 1
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')+"0"),12,"0")
							elseif   (len(cValToChar(TSRC->RC_VALOR)) - at(".",cValToChar(TSRC->RC_VALOR))) == 2
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')),12,"0")
							elseif at(".",cValToChar(TSRC->RC_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')+"00"),12,"0")
							endif	
							//cTexto += PADL(alltrim(strTran(cValToChar(TSRC->RC_VALOR),'.','')),12,"0")

							nTotD += TSRC->RC_VALOR
							nDesc += TSRC->RC_VALOR
						ENDIF
						//Filler		
						cTexto += PADr("",162,"")


						cTexto += CRLF
						fWrite( nHdl, cTexto )	

					ENDIF 

					HEADER4 := "SRC"

					if TSRC->RC_ROTEIR == 'FOL'
						//verba de liquido 
						if TSRC->RC_PD == "910"
							nValLiq := TSRC->RC_VALOR	
							// SALARIO BASE				
						ELSEIF TSRC->RC_PD == "101"
							nValSalB := TSRC->RC_VALOR
							// BASE INSS				
						ELSEIF TSRC->RC_PD == "917"
							nValBasInss := TSRC->RC_VALOR
							// DESCONTO INSS		
							// SAQUE FGTS			
						ELSEIF TSRC->RC_PD == "235"
							nValSacInss := TSRC->RC_VALOR
							// BASE IRRF				
						ELSEIF TSRC->RC_PD == "919"
							nValBasIr := TSRC->RC_VALOR
							// BASE FGTS
						ELSEIF TSRC->RC_PD == "916"
							nValBasFgts := TSRC->RC_VALOR

						ENDIF
					ELSEif TSRC->RC_ROTEIR == '132'
						//verba de liquido 
						if TSRC->RC_PD == "730"
							nValLiq := TSRC->RC_VALOR	
							// SALARIO BASE				
						ELSEIF TSRC->RC_PD == "101"
							nValSalB := TSRC->RC_VALOR
							// BASE INSS				
						ELSEIF TSRC->RC_PD == "948"
							nValBasInss := TSRC->RC_VALOR
							// DESCONTO INSS		
							// SAQUE FGTS			
						ELSEIF TSRC->RC_PD == "402"
							nValSacInss := TSRC->RC_VALOR
							// BASE IRRF				
						ELSEIF TSRC->RC_PD == "726"
							nValBasIr := TSRC->RC_VALOR
							// BASE FGTS
						ELSEIF TSRC->RC_PD == "768"
							nValBasFgts := TSRC->RC_VALOR

						ENDIF
					ENDIF 

					TSRC->(DBSKIP())

				ENDDO

				//HEADER dos Valores = 4
				IF HEADER4 == "SRC"
					cTexto := ""
					//Numero do Layout	
					cTexto += PADr("4",1,"")
					//Total de Vencimentos
					if   at(".",cValToChar(nTotP)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nTotP)) - at(".",cValToChar(nTotP))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nTotP)) - at(".",cValToChar(nTotP))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')),12,"0")
					elseif at(".",cValToChar(nTotP)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')+"00"),12,"0")
					endif	
					//cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')),12,"0")

					//Total de Descontos	
					if  at(".",cValToChar(nTotD)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nTotD)) - at(".",cValToChar(nTotD))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nTotD)) - at(".",cValToChar(nTotD))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')),12,"0")
					elseif at(".",cValToChar(nTotD)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')+"00"),12,"0")
					endif
					//cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')),12,"0")

					//Liquido	
					if  at(".",cValToChar(nValLiq)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
					elseif at(".",cValToChar(nValLiq)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
					endif

					//cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
					nLiqPg += nValLiq

					//Salário Base
					if  at(".",cValToChar(nValSalB)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSalB)) - at(".",cValToChar(nValSalB))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSalB)) - at(".",cValToChar(nValSalB))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')),12,"0")
					elseif at(".",cValToChar(nValSalB)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')+"00"),12,"0")
					endif		
					//cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')),12,"0")

					//Base INSS		

					if  at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					elseif at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					endif	

					//cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")

					//INSS

					if  at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					elseif at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					endif			
					//cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")

					//Mês/Ano		
					cTexto += PADr("4",6,"")
					//Base IRRF		

					if  at(".",cValToChar(nValBasIr)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValBasIr)) - at(".",cValToChar(nValBasIr))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValBasIr)) - at(".",cValToChar(nValBasIr))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')),12,"0")
					elseif at(".",cValToChar(nValBasIr)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')+"00"),12,"0")
					endif	

					//cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')),12,"0")

					//BASE FGTS
					if  at(".",cValToChar(nValBasFgts)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValBasFgts)) - at(".",cValToChar(nValBasFgts))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValBasFgts)) - at(".",cValToChar(nValBasFgts))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')),12,"0")
					elseif at(".",cValToChar(nValBasFgts)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')+"00"),12,"0")
					endif		
					//cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')),12,"0")
					//Faixa INSS		
					cTexto += PADL("",12,"")

					//Saque FGTS
					if   at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					elseif at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					endif		
					//cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					//Mensagem 1		
					cTexto += PADr("",50,"")
					//Mensagem 2		
					cTexto += PADr("",50,"")
					//VFiller		
					cTexto += PADr("",13,"")

					cTexto += CRLF
					fWrite( nHdl, cTexto )	

				ENDIF

				HEADER4 := "OK"

				TGPE->(DBSKIP())
			enddo

			// JA PERCORREU TODOS OS FUNCIONÁRIOS 

			//Filler = 9										

			cTexto := ""
			//Numero do Layout	
			cTexto += PADr("9",1,"")
			//Total Geral de Registros		
			cTexto += PADL(alltrim(strTran(cValToChar(nNumFunc),'.','')),5,"0")			
			//Total Geral de Vencimentos	
			if  at(".",cValToChar(nProv)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')+"00"),12,"0")
			elseif (len(cValToChar(nProv)) - at(".",cValToChar(nProv))) == 1
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')+"0"),12,"0")
			elseif   (len(cValToChar(nProv)) - at(".",cValToChar(nProv))) == 2
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')),12,"0")
			elseif at(".",cValToChar(nProv)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')+"00"),12,"0")
			endif	
			//cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')),12,"0")			

			//Total Geral de Descontos
			if  at(".",cValToChar(nDesc)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')+"00"),12,"0")
			elseif (len(cValToChar(nDesc)) - at(".",cValToChar(nDesc))) == 1
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')+"0"),12,"0")
			elseif   (len(cValToChar(nDesc)) - at(".",cValToChar(nDesc))) == 2
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')),12,"0")
			elseif at(".",cValToChar(nDesc)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')+"00"),12,"0")
			endif		
			//cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')),12,"0")	

			//Total Geral Liquido a Pagar
			if  at(".",cValToChar(nValLiq)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
			elseif (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 1
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"0"),12,"0")
			elseif   (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 2
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
			elseif at(".",cValToChar(nValLiq)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
			endif			
			//cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
			//Filler		
			cTexto += PADr("",198,"")

			cTexto += CRLF
			fWrite( nHdl, cTexto )	
			
			//fClose(nHdl)

		ELSEIF TCOMP->RCH_PERSEL == '2' // FECHADO ---- VERIFICO NA SRD 

			// FAZER SELECT NA SRA
			cQuery := " SELECT *
			cQuery += " FROM   "+RetSqlName("SRA")+" SRA  "
			cQuery += " WHERE  D_E_L_E_T_ = ''  "
			cQuery += " AND    RA_FILIAL BETWEEN '"+XFILIAL("SRA",cFil1)+"' AND '"+ XFILIAL("SRA",cFil2) +"'
			cQuery += " AND    RA_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
			cQuery += " AND    RA_SITFOLH NOT IN ('D')
			cQuery += " ORDER BY RA_FILIAL ,RA_CC, RA_MAT "

			IF SELECT("TGPE") > 0
				TGPE->(DBCLOSEAREA())
			ENDIF 
			TcQuery cQuery New Alias TGPE

			//Cria Arquivo de saida
			nHdl := fCreate(cArqOut)

			If nHdl == -1
				MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!') 
				Return
			Endif

			IF HEADER == ""
				// PEGAR OS DADOS DA EMPRESA "HEADER Da Empresa = 0"
				cTexto := ""

				dbSelectArea("SM0")
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+TGPE->RA_FILIAL))

				//Numero do Layout	
				cTexto += PADr("0", 1,"")	
				//Nome da Empresa		
				cTexto += PADr(SM0->M0_NOMECOM,40,"")
				//Numero do CNPJ / CGC		
				cTexto += PADr(SM0->M0_CGC,14,"")
				//Nome da Rua da Empresa	
				cNum1     := At(",",SM0->M0_ENDCOB)
				cTexto += PADr(ALLTRIM(SUBSTR(SM0->M0_ENDCOB,1 ,cNum1 - 1)),30,"")	
				//Numero da Empresa	
				cNum1     := At(",",SM0->M0_ENDCOB)
				cTexto += PADr(ALLTRIM(SUBSTR(SM0->M0_ENDCOB,cNum1 + 1 , 6)),4,"")		
				//Bairro da Empresa		
				cTexto += PADr(SM0->M0_BAIRCOB,30,"")
				//Cidade da Empresa
				cTexto += PADr(SM0->M0_CIDCOB,30,"")		
				//Estado da Empresa		
				cTexto += PADr(SM0->M0_ESTCOB,2,"")
				//Cep da Empresa		
				cTexto += PADr(SM0->M0_CEPCOB,8,"")
				//Telefone da Empresa		
				cTexto += PADr(SM0->M0_TEL,13,"")
				//Fax da Empresa		
				cTexto += PADr(SM0->M0_FAX,13,"")
				//Tipo de Folha		
				cTexto += PADr("",15,"")
				//Data da Geração do Arquivo	
				cTexto += PADr(DTOS(DATE()),08,"")	
				//Data do Credito		
				cTexto += PADr("",08,"")
				//Site da Empresa		
				cTexto += PADr("",15,"")
				//Linha de Assinatura		
				cTexto += PADr("",01,"")
				//Quantidade de Vias		
				cTexto += PADr("",01,"")
				//Mês e Ano		
				cTexto += PADr(cPeri1,06,"")
				//Versão do Sistemas		
				cTexto += PADr("1",01,"")

				cTexto += CRLF
				fWrite( nHdl, cTexto )	

				HEADER := "OK"
			ENDIF
			// verificar todos os funcionários 

			nCautP := 0
			while !TGPE->(eof())
				MsProcTxt("Funcionário: " + TGPE->RA_NOME)
				// FAZER SELECT NA SR0 
				cQuery := " SELECT *
				cQuery += " FROM   "+RetSqlName("SRD")+" SRD  "
				cQuery += " INNER JOIN   "+RetSqlName("SRV")+" SRV ON RV_FILIAL = '"+ XFILIAL("SRV",TGPE->RA_FILIAL) +"' AND RV_COD = RD_PD AND SRV.D_E_L_E_T_ = '' " //AND RV_TIPOCOD  IN ('1','2') 
				cQuery += " WHERE    SRD.D_E_L_E_T_ = ''  "
				cQuery += " AND      RD_FILIAL = '"+ XFILIAL("SRD",TGPE->RA_FILIAL) +"'
				cQuery += " AND      RD_MAT = '"+ TGPE->RA_MAT +"'
				cQuery += " AND      RD_ROTEIR = '"+ cRote +"'
				cQuery += " AND      RD_PERIODO = '"+ SUBSTR(cPeri1,3,4)+SUBSTR(cPeri1,1,2) +"'
				cQuery += " ORDER BY RD_FILIAL , RD_PD "

				IF SELECT("TSRD") > 0
					TSRD->(DBCLOSEAREA())
				ENDIF 
				TcQuery cQuery New Alias TSRD

				// PERCORER TODOS OS LANÇAMENTOS 

				HEADER1 := ""
				HEADER2 := ""
				HEADER4 := ""
				nTotP   := 0
				nTotD   := 0

				// CASO NAO TENHA VALORES , PROXIMO REGISTRO
				IF TSRD->(EOF())
					TGPE->(DBSKIP())
					LOOP
				ENDIF

				nNumFunc += 1

				//carregando variaveis 
				nValLiq      := 0
				nValSalB	 := 0
				nValBasInss  := 0
				nValSacInss  := 0
				nValBasIr    := 0
				nValBasFgts  := 0

				WHILE  !TSRD->(EOF())
					cTexto := ""
					cTexPd := ""

					/*
					//BUSCA PELA ULTIMA LOCALIZAÇÃO ABB E ABS
					cQuery := " SELECT TOP 1 *
					cQuery += " FROM   "+RetSqlName("ABB")+" ABB , "+RetSqlName("ABS")+" ABS  "
					cQuery += " WHERE    ABB.D_E_L_E_T_ = '' AND ABS.D_E_L_E_T_ = ''  "
					cQuery += " AND      ABB_FILIAL = '"+ XFILIAL("ABB",TSRD->RD_FILIAL) +"'
					cQuery += " AND      ABB_CODTEC = '"+ ALLTRIM(XFILIAL("ABB",TSRD->RD_FILIAL)) + ALLTRIM(TSRD->RD_MAT) +"'
					cQuery += " AND      ABB_LOCAL = ABS_LOCAL 
					cQuery += " ORDER BY ABB_DTINI DESC 

					IF SELECT("TABS") > 0
					TABS->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TABS
					*/

					cQuery := " SELECT RA_FILIAL, RA_MAT, ABS_DESCRI , ABS_LOCAL
					cQuery += " FROM (
					cQuery += " SELECT RA_FILIAL,RA_MAT  , RA_NOME , RA_CC , TFL_LOCAL ,MAX(TFL_CONREV) TFL_CONREV
					cQuery += " FROM "+RetSqlName("SRA")+" SRA , "+RetSqlName("TFL")+" TFL 
					cQuery += " WHERE SRA.D_E_L_E_T_=''
					cQuery += " AND TFL.D_E_L_E_T_=''
					cQuery += " AND RA_FILIAL = TFL_FILIAL 
					cQuery += " AND RA_CC = TFL_YCC
					cQuery += " GROUP BY RA_FILIAL , RA_MAT , RA_NOME , RA_CC, TFL_LOCAL 
					cQuery += " ) TABA ,  "+RetSqlName("ABS")+" ABS 
					cQuery += " WHERE ABS.D_E_L_E_T_ = ''
					cQuery += " AND ABS_LOCAL  = TFL_LOCAL
					cQuery += " AND RA_FILIAL  = "+ TSRD->RD_FILIAL +" 
					cQuery += " AND RA_MAT  = "+ TSRD->RD_MAT +" 
					cQuery += " ORDER BY RA_FILIAL , RA_MAT

					IF SELECT("TABS") > 0
						TABS->(DBCLOSEAREA())
					ENDIF 
					TcQuery cQuery New Alias TABS

					//HEADER de Postagem = 1
					IF HEADER1 == ""
						cTexto := ""
						//Numero do Layout		
						cTexto += PADr("1",01,"")

						/*
						IF !TABS->(EOF())
						//Nome da Locação do Funcionario
						cTexto += PADr(TABS->ABS_DESCRI,40,"")		
						//Cod. Da Locaçao/Seção/Setor
						cTexto += PADr(TABS->ABS_LOCAL,15,"")
						cCodLoc :=	TABS->ABS_LOCAL
						ELSE
						//Nome da Locação do Funcionario
						cTexto += PADr("",40,"")		
						//Cod. Da Locaçao/Seção/Setor
						cTexto += PADr("",15,"")
						cCodLoc :=	""
						ENDIF
						*/

						IF !TABS->(EOF())
							//Nome da Locação do Funcionario
							cTexto += PADr(TABS->ABS_DESCRI,40,"")		
							//Cod. Da Locaçao/Seção/Setor
							cTexto += PADr(TABS->ABS_LOCAL,15,"")
							cCodLoc :=	TABS->ABS_LOCAL
						ELSE
							// BUSCAR NA CTT
							cQuery := " SELECT RA_FILIAL , RA_MAT , RA_CC , CTT_CUSTO, CTT_DESC01
							cQuery += " FROM "+RetSqlName("SRA")+" SRA , "+RetSqlName("CTT")+" CTT
							cQuery += " WHERE 
							cQuery += " SRA.D_E_L_E_T_=''
							cQuery += " AND CTT.D_E_L_E_T_=''
							cQuery += " AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT_FILIAL
							cQuery += " AND SRA.RA_CC = CTT_CUSTO
							cQuery += " AND RA_FILIAL  = "+ TSRD->RD_FILIAL +" 
							cQuery += " AND RA_MAT  = "+ TSRD->RD_MAT +" 
							cQuery += " ORDER BY RA_FILIAL , RA_MAT

							IF SELECT("TAB2") > 0
								TAB2->(DBCLOSEAREA())
							ENDIF 
							TcQuery cQuery New Alias TAB2

							IF RAT(ALLTRIM(TAB2->CTT_DESC01),"-") > 0 
								//Nome da Locação do Funcionario
								cTexto += PADr( SUBSTR(RAT(ALLTRIM(TAB2->CTT_DESC01),"-"),RAT(ALLTRIM(TAB2->CTT_DESC01),"-")+1,LEN(ALLTRIM(TAB2->CTT_DESC01))),40,"")		
								//Cod. Da Locaçao/Seção/Setor
								cTexto += PADr(SUBSTR(TAB2->RA_CC,6,7),15,"")
								cCodLoc :=	""

							ELSE
								//Nome da Locação do Funcionario
								cTexto += PADr(ALLTRIM(TAB2->CTT_DESC01),40,"")		
								//Cod. Da Locaçao/Seção/Setor
								cTexto += PADr(SUBSTR(TAB2->RA_CC,6,7),15,"")
								cCodLoc :=	""
							ENDIF

						ENDIF
						//Matricula do Funcionario
						cTexto += PADr(TSRD->RD_MAT,06,"")		
						//Nome do Funcionario
						cTexto += PADr(if(alltrim(TGPE->RA_NOMECMP) == "",TGPE->RA_NOME,TGPE->RA_NOMECMP),40,"")		
						//Endereço do Funcionario
						cTexto += PADr(TGPE->RA_ENDEREC,50,"")		
						//Numero da Casa	
						cTexto += PADr(TGPE->RA_NUMENDE,04,"")	
						//Bairro do Funcionario
						cTexto += PADr(TGPE->RA_BAIRRO,20,"")		
						//Cidade do Funcionario
						cTexto += PADr(TGPE->RA_MUNNASC,20,"")		
						//Estado do Funcionario
						cTexto += PADr(TGPE->RA_NATURAL,02,"")		
						//Cep do Funcionario
						cTexto += PADr(TGPE->RA_CEP,08,"")		
						//Filler		
						cTexto += PADr("",34,"")

						cTexto += CRLF
						fWrite( nHdl, cTexto )	

						HEADER1 := "OK"
						TABS->(DBCLOSEAREA())
					ENDIF

					//HEADER de Postagem = 2
					IF HEADER2 == ""
						cTexto := ""
						//Numero do Layout		
						cTexto += PADr("2",1,"")
						//Cod. Da Locaçao/Seção/Setor
						cTexto += PADr(cCodLoc,15,"")		
						//Matricula do Funcionario
						cTexto += PADr(TSRD->RD_MAT,6,"")		
						//Nome do Funcionario
						cTexto += PADr(if(alltrim(TGPE->RA_NOMECMP) == "",TGPE->RA_NOME,TGPE->RA_NOMECMP),40,"")		
						//Admissão do Funcionario
						cTexto += PADr(TGPE->RA_ADMISSA,8,"")		
						//Cargo do Funcionario
						cTexto += PADr(POSICIONE("SQ3",1,XFILIAL("SQ3",TGPE->RA_FILIAL)+TGPE->RA_CARGO,"Q3_DESCSUM"),30,"")		
						//Carteira Proficional do Funcionario
						cTexto += PADr(TGPE->RA_NUMCP,08,"")		
						//Serie		
						cTexto += PADr(TGPE->RA_SERCP,05,"")
						//C.P.F do Funcionario		
						cTexto += PADr(TGPE->RA_CIC,11,"")
						//PIS do Funcionario
						cTexto += PADr(TGPE->RA_PIS,11,"")		
						//RG do Funcionario	
						cTexto += PADr(TGPE->RA_RG,20,"")	
						//Banco		
						cTexto += PADr(SUBSTR(TGPE->RA_BCDEPSA,1,3),3,"")
						//Numero da Agência
						cTexto += PADr(SUBSTR(TGPE->RA_BCDEPSA,5,5),6,"")		
						//Nome Agência		
						cTexto += PADr("",29,"")
						//Numero da Conta Corrente+DV
						cTexto += PADr(SUBSTR(TGPE->RA_CTDEPSA,5,5),8,"")		
						//Filler		
						cTexto += PADr("",39,"")


						cTexto += CRLF
						fWrite( nHdl, cTexto )	

						HEADER2 := "OK"
					ENDIF

					//HEADER das Verbas = 3
					IF TSRD->RV_TIPOCOD == '1' .OR. TSRD->RV_TIPOCOD == '2'
						cTexto := ""

						//Numero do Layout		
						cTexto += PADr("3",1,"")					
						//Verba		
						cTexto += PADr(TSRD->RD_PD,3,"")
						//Descrição		
						cTexto += PADr(TSRD->RV_DESC,40,"")
						//Referência		
						cTexto += PADr(TSRD->RD_HORAS,10,"")

						IF TSRD->RV_TIPOCOD == '1' //PROVENTO 

							//Vantagens		

							if	at(".",cValToChar(TSRD->RD_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')+"00"),12,"0")
							elseif (len(cValToChar(TSRD->RD_VALOR)) - at(".",cValToChar(TSRD->RD_VALOR))) == 1
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')+"0"),12,"0")
							elseif   (len(cValToChar(TSRD->RD_VALOR)) - at(".",cValToChar(TSRD->RD_VALOR))) == 2
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')),12,"0")
							elseif at(".",cValToChar(TSRD->RD_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')+"00"),12,"0")
							endif

							//cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')),12,"0")

							//Descontos		
							cTexto += PADr("",12,"")

							nTotP += TSRD->RD_VALOR
							nProv += TSRD->RD_VALOR
						ELSEIF TSRD->RV_TIPOCOD == '2' // DESCONTO 

							//Vantagens		
							cTexto += PADr("",12,"")
							//Descontos		

							if at(".",cValToChar(TSRD->RD_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')+"00"),12,"0")
							elseif (len(cValToChar(TSRD->RD_VALOR)) - at(".",cValToChar(TSRD->RD_VALOR))) == 1
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')+"0"),12,"0")
							elseif   (len(cValToChar(TSRD->RD_VALOR)) - at(".",cValToChar(TSRD->RD_VALOR))) == 2
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')),12,"0")
							elseif at(".",cValToChar(TSRD->RD_VALOR)) == 0
								cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')+"00"),12,"0")
							endif

							//cTexto += PADL(alltrim(strTran(cValToChar(TSRD->RD_VALOR),'.','')),12,"0")

							nTotD += TSRD->RD_VALOR
							nDesc += TSRD->RD_VALOR
						ENDIF
						//Filler		
						cTexto += PADr("",162,"")


						cTexto += CRLF
						fWrite( nHdl, cTexto )	

					ENDIF 

					HEADER4 := "SRD"

					if TSRD->RD_ROTEIR == 'FOL'
						//verba de liquido 
						if TSRD->RD_PD == "910"
							nValLiq := TSRD->RD_VALOR	
							// SALARIO BASE				
						ELSEIF TSRD->RD_PD == "101"
							nValSalB := TSRD->RD_VALOR
							// BASE INSS				
						ELSEIF TSRD->RD_PD == "917"
							nValBasInss := TSRD->RD_VALOR
							// DESCONTO INSS		
							// SAQUE FGTS			
						ELSEIF TSRD->RD_PD == "235"
							nValSacInss := TSRD->RD_VALOR
							// BASE IRRF				
						ELSEIF TSRD->RD_PD == "919"
							nValBasIr := TSRD->RD_VALOR
							// BASE FGTS
						ELSEIF TSRD->RD_PD == "916"
							nValBasFgts := TSRD->RD_VALOR

						ENDIF
					ELSEif TSRD->RD_ROTEIR == '132'
						//verba de liquido 
						if TSRD->RD_PD == "730"
							nValLiq := TSRD->RD_VALOR	
							// SALARIO BASE				
						ELSEIF TSRD->RD_PD == "101"
							nValSalB := TSRD->RD_VALOR
							// BASE INSS				
						ELSEIF TSRD->RD_PD == "948"
							nValBasInss := TSRD->RD_VALOR
							// DESCONTO INSS		
							// SAQUE FGTS			
						ELSEIF TSRD->RD_PD == "402"
							nValSacInss := TSRD->RD_VALOR
							// BASE IRRF				
						ELSEIF TSRD->RD_PD == "726"
							nValBasIr := TSRD->RD_VALOR
							// BASE FGTS
						ELSEIF TSRD->RD_PD == "768"
							nValBasFgts := TSRD->RD_VALOR

						ENDIF
					ENDIF 

					TSRD->(DBSKIP())

				ENDDO

				//HEADER dos Valores = 4
				IF HEADER4 == "SRD"
					cTexto := ""
					//Numero do Layout	
					cTexto += PADr("4",1,"")
					//Total de Vencimentos		

					if	at(".",cValToChar(nTotP)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nTotP)) - at(".",cValToChar(nTotP))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nTotP)) - at(".",cValToChar(nTotP))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')),12,"0")
					elseif at(".",cValToChar(nTotP)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')+"00"),12,"0")
					endif	
					//cTexto += PADL(alltrim(strTran(cValToChar(nTotP),'.','')),12,"0")

					//Total de Descontos	

					if	at(".",cValToChar(nTotD)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nTotD)) - at(".",cValToChar(nTotD))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nTotD)) - at(".",cValToChar(nTotD))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')),12,"0")
					elseif at(".",cValToChar(nTotD)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')+"00"),12,"0")
					endif	

					//cTexto += PADL(alltrim(strTran(cValToChar(nTotD),'.','')),12,"0")

					//Liquido	

					if at(".",cValToChar(nValLiq)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
					elseif at(".",cValToChar(nValLiq)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
					endif	
					//cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
					nLiqPg += nValLiq

					//Salário Base		

					if  at(".",cValToChar(nValSalB)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSalB)) - at(".",cValToChar(nValSalB))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSalB)) - at(".",cValToChar(nValSalB))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')),12,"0")
					elseif at(".",cValToChar(nValSalB)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')+"00"),12,"0")
					endif	
					//cTexto += PADL(alltrim(strTran(cValToChar(nValSalB),'.','')),12,"0")

					//Base INSS
					if   at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					elseif at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					endif

					//cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")

					//INSS
					if	at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					elseif at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					endif
					//cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")

					//Mês/Ano		
					cTexto += PADr("4",6,"")

					//Base IRRF

					if  at(".",cValToChar(nValBasIr)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValBasIr)) - at(".",cValToChar(nValBasIr))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValBasIr)) - at(".",cValToChar(nValBasIr))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')),12,"0")
					elseif at(".",cValToChar(nValBasIr)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')+"00"),12,"0")
					endif		
					//cTexto += PADL(alltrim(strTran(cValToChar(nValBasIr),'.','')),12,"0")

					//BASE FGTS		

					if   at(".",cValToChar(nValBasFgts)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValBasFgts)) - at(".",cValToChar(nValBasFgts))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValBasFgts)) - at(".",cValToChar(nValBasFgts))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')),12,"0")
					elseif at(".",cValToChar(nValBasFgts)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')+"00"),12,"0")
					endif
					//cTexto += PADL(alltrim(strTran(cValToChar(nValBasFgts),'.','')),12,"0")

					//Faixa INSS		
					cTexto += PADL("",12,"")
					//Saque FGTS	

					if  at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					elseif (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 1
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"0"),12,"0")
					elseif   (len(cValToChar(nValSacInss)) - at(".",cValToChar(nValSacInss))) == 2
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					elseif at(".",cValToChar(nValSacInss)) == 0
						cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')+"00"),12,"0")
					endif	
					//cTexto += PADL(alltrim(strTran(cValToChar(nValSacInss),'.','')),12,"0")
					//Mensagem 1		
					cTexto += PADr("",50,"")
					//Mensagem 2		
					cTexto += PADr("",50,"")
					//VFiller		
					cTexto += PADr("",13,"")

					cTexto += CRLF
					fWrite( nHdl, cTexto )	

				ENDIF

				HEADER4 := "OK"

				TGPE->(DBSKIP())
			enddo

			// JA PERCORREU TODOS OS FUNCIONÁRIOS 

			//Filler = 9										

			cTexto := ""
			//Numero do Layout	
			cTexto += PADr("9",1,"")
			//Total Geral de Registros		
			cTexto += PADL(alltrim(strTran(cValToChar(nNumFunc),'.','')),5,"0")			
			//Total Geral de Vencimentos	
			if  at(".",cValToChar(nProv)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')+"00"),12,"0")
			elseif (len(cValToChar(nProv)) - at(".",cValToChar(nProv))) == 1
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')+"0"),12,"0")
			elseif   (len(cValToChar(nProv)) - at(".",cValToChar(nProv))) == 2
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')),12,"0")
			elseif at(".",cValToChar(nProv)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')+"00"),12,"0")
			endif
			//cTexto += PADL(alltrim(strTran(cValToChar(nProv),'.','')),12,"0")

			//Total Geral de Descontos	
			if  at(".",cValToChar(nDesc)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')+"00"),12,"0")
			elseif (len(cValToChar(nDesc)) - at(".",cValToChar(nDesc))) == 1
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')+"0"),12,"0")
			elseif   (len(cValToChar(nDesc)) - at(".",cValToChar(nDesc))) == 2
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')),12,"0")
			elseif at(".",cValToChar(nDesc)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')+"00"),12,"0")
			endif
			//cTexto += PADL(alltrim(strTran(cValToChar(nDesc),'.','')),12,"0")	

			//Total Geral Liquido a Pagar		

			if  at(".",cValToChar(nValLiq)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
			elseif (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 1
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"0"),12,"0")
			elseif   (len(cValToChar(nValLiq)) - at(".",cValToChar(nValLiq))) == 2
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")
			elseif at(".",cValToChar(nValLiq)) == 0
				cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')+"00"),12,"0")
			endif
			//cTexto += PADL(alltrim(strTran(cValToChar(nValLiq),'.','')),12,"0")

			//Filler		
			cTexto += PADr("",198,"")

			cTexto += CRLF
			fWrite( nHdl, cTexto )	
			
			//fClose(nHdl)

		ENDIF



		TCOMP->(DBSKIP())
		
	ENDDO

	 
	fClose(nHdl)

Return 