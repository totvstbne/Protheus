#Include "TopConn.CH"
#Include "Protheus.CH"
#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#include 'parmtype.ch'

//------------------------------------------||
// AUTOR JOAO FILJO     -- DATA  26/02/2019 ||
//------------------------------------------||
// OBJETIVO: MONTAGEM DO CONTRACHEQUE DOS   ||
//           FUNCIONÁRIOS                   ||
//------------------------------------------||   


user function RCOTRA02()


	Local aPergs	:= {}
	Local aRetOpc	:= {}
	Local cMen      := space(400)
	Local cMenComp  := "" 
	Local cFilde   
	Local cFilate         
	Local nProv
	Local nDesc 
	Local nBasIr    := 0
	Local nBasFgts  := 0
	Local nFgtsRec  := 0     
	Local nSalBase  := 0 

	Private nLinha 
	//Objetos para tamanho e tipo das fontes
	Private oFont1 := TFont():New( "Times New Roman",,10,,.T.,,,,,.F.)
	Private oFont2 := TFont():New( "Tahoma",,16,,.T.,,,,,.F.)
	Private oFont3 := TFont():New( "Arial"       ,,6,,.F.,,,,,.F.) 
	Private oFont4 := TFont():New( "Times New Roman",,15,,.T.,,,,,.F.) 
	Private oFont5 := TFont():New( "Franklin Gothic Heavy",,15,,.T.,,,,,.F.)         
	Private oFont6 := TFont():New( "Arial"       ,,11,,.F.,,,,,.F.) 
	Private oFont7 := TFont():New( "Arial"       ,,9,,.F.,,,,,.F.) 
	Private oBrush1 := TBrush():New( , CLR_GRAY )

	//LOGO DA EMPRESA 
	Private cFigura
	//objeto RELATORIO 
	Private oPrn := TMSPrinter():New("Servnac - Contra Cheque")  
	// NOME DAS PERGUNTAS
	cPerg := "RCOTRA02"

	oPrn:SetUp()                // Abre opcoes para o usuario
	oPrn:SetPortrait()          // ou SetLandscape()   


	AjustaSX1(cPerg)            // cria as perguntas
	Pergunte(cPerg,.T.)         // abre na tela as perguntas

	cFilde   := MV_PAR01
	cFilate  := MV_PAR02
	IF MV_PAR06  ==  1
		aAdd( aPergs ,{1,"Mensagem",	cMen	,GetSx3Cache("RA_NOME","X3_PICTURE") ,'.T.',"" ,'.T.',400 ,.T.})


		If ParamBox(aPergs,"Informe a Mensagem",aRetOpc,,,,,,,"_RCH",.F.,.F.)
			cMenComp :=	alltrim(aRetOpc[1])
		ENDIF

	ENDIF   

	//situacao
	cSit := ""
	for nAux := 1 to len(MV_PAR11)
		if substring(MV_PAR11,nAux,1) <> "*" .and. cSit == ""
			cSit +=  "'"+substring(MV_PAR11,nAux,1)+"'"
		elseif substring(MV_PAR11,nAux,1) <> "*" .and. cSit <> ""
			cSit +=  ",'" + substring(MV_PAR11,nAux,1)+"'"
		endif 
	next


	//categoria
	cCat := ""
	for nAux := 1 to len(alltrim(MV_PAR12))
		if substring(MV_PAR12,nAux,1) <> "*" .and. cCat == ""
			cCat +=  "'"+substring(MV_PAR12,nAux,1)+"'"
		elseif substring(MV_PAR12,nAux,1) <> "*" .and. cCat <> ""
			cCat +=  ",'" + substring(MV_PAR12,nAux,1) + "'"
		endif
	next

	if MV_PAR08 == 1 // folha de pagamento

		IF MV_PAR07 == 1 //PERIODO ABERTO , CONSULTAS FEITAS NA SRC

			/*
			MONTAR CONSULTA DA SRC DOS FUNCIONÁRIOS 
			*/

			cQuery := " SELECT  RC_FILIAL , RC_MAT , RA_NOME , RC_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO ,RA_BCDEPSA,RA_CTDEPSA , RA_ADMISSA
			cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRC")+" SRC  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
			cQuery += " WHERE  "
			cQuery += "       RC_MAT BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
			cQuery += " AND   RC_DATA LIKE '%"+ SUBSTRING(DTOS(MV_PAR03),1,6) +"%' "
			cQuery += " AND   RC_FILIAL BETWEEN '"+ cFilde +"' AND '"+ cFilate +"' "
			cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRC.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
			cQuery += " AND   RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT "
			cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "
			cQuery += " AND   RA_CODFUNC = RJ_FUNCAO "   
			cQuery += " AND   RC_ROTEIR NOT IN ('131','132') " 	
			cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
			cQuery += " AND   RA_SITFOLH IN ("+cSit+")
			cQuery += " AND   RA_CATFUNC IN ("+cCat+")
			cQuery += " GROUP BY RC_FILIAL , RC_MAT , RA_NOME , RC_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO, RA_BCDEPSA, RA_CTDEPSA ,RA_ADMISSA "
			cQuery += " ORDER BY RC_FILIAL, RC_DATA , RC_MAT  "

			TcQuery cQuery New Alias TFOL

			if TFOL->(EOF())
				alert("Nenhum dado encontrado, favor verificar os parametros!")        
				TFOL->(DBCLOSEAREA()) 
				Return
			endif

			WHILE !TFOL->(EOF())

				MontaFol(TFOL->RC_FILIAL)

				//CABEÇALHO  
				nLinha := 370

				//matricula
				oPrn:Say(nLinha ,30, TFOL->RC_MAT ,oFont7,100)

				//NOME
				oPrn:Say(nLinha ,510, TFOL->RA_NOME ,oFont7,100)

				//ADMISSAO 
				oPrn:Say(nLinha ,2210, SUBSTR(TFOL->RA_ADMISSA,7,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,5,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,1,4),oFont7,100)

				nLinha := 470

				SM0->(DBSEEK(CEMPANT + TFOL->RC_FILIAL ))
				//empresa
				oPrn:Say(nLinha,30,ALLTRIM(SM0->M0_FILIAL),oFont7,100)   // chapado por pedido do cliente

				//CNPJ
				oPrn:Say(nLinha,1610, TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oFont7,100) //SM0->M0_CGC

				//MES/ANO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RC_DATA,5,2) +"/"+  SUBSTR(TFOL->RC_DATA,1,4) ,oFont7,100)


				nLinha := 670

				//FUNÇAO
				oPrn:Say(nLinha,30,ALLTRIM(TFOL->RJ_DESC),oFont7,100)

				//lotação
				//oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_CC),oFont7,100)
				oPrn:Say(nLinha,1010,ALLTRIM(POSICIONE("CTT",1,XFILIAL("CTT",TFOL->RC_FILIAL) + TFOL->RA_CC,"CTT_DESC01")),oFont7,100)
				

				//DEP.IR
				oPrn:Say(nLinha,2210,ALLTRIM(TFOL->RA_DEPIR),oFont7,100)

				//DEP.SF
				oPrn:Say(nLinha,2337,ALLTRIM(TFOL->RA_DEPSF),oFont7,100)

				nLinha := 770

				//CPF
				oPrn:Say(nLinha,30,TRANSFORM(TFOL->RA_CIC,"@R 999.999.999-99"),oFont7,100)

				//IDENTIDADE
				oPrn:Say(nLinha,510,ALLTRIM(TFOL->RA_RG),oFont7,100)

				//PIS
				oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_PIS),oFont7,100)

				// BUSCAR SALÁRIO DO PEDIO , DE ACORDO COM OS PARAMETROS 
				cQuery := " SELECT TOP 1 *
				cQuery += " FROM  "+RETSQLNAME("SR3")+" SR3 
				cQuery += " WHERE  "
				cQuery += "       R3_FILIAL = '"+TFOL->RC_FILIAL+"' 
				cQuery += " AND   R3_MAT = '"+TFOL->RC_MAT+"' "  
				cQuery += " AND   R3_DATA <= '"+TFOL->RC_DATA+"' "   
				cQuery += " AND   R3_PD = '000' "
				cQuery += " ORDER BY R3_DATA DESC "

				TcQuery cQuery New Alias TSAL

				//SALARIO BASE
				oPrn:Say(nLinha,2010,ALLTRIM(TRANSFORM(TSAL->R3_VALOR,"@E 999,999.99")),oFont7,100)

				TSAL->(DBCLOSEAREA())
				nLinha := 870

				//BANCO DE PAGAMENTO 
				oPrn:Say(nLinha ,30,SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4),oFont7,100)

				//AGENCIA 
				oPrn:Say(nLinha ,1010,SUBSTRING(TFOL->RA_BCDEPSA ,LEN(SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4)) + 1,4),oFont7,100)

				//CONTA CORRENTE 
				oPrn:Say(nLinha ,2010,ALLTRIM(TFOL->RA_CTDEPSA),oFont7,100)

				//ITENS

				cQuery := " SELECT  RC_FILIAL , RC_MAT , RA_NOME , RC_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
				cQuery += " RA_RG , RA_PIS , RA_SALARIO , 
				cQuery += " RC_PD , RV_DESC ,RV_TIPOCOD, RC_VALOR , RC_HORAS
				cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRC")+" SRC  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
				cQuery += " WHERE  "
				cQuery += "       RC_MAT = '"+ TFOL->RC_MAT +"' "
				cQuery += " AND   RC_DATA LIKE '%"+ SUBSTRING(DTOS(MV_PAR03),1,6) +"%'  "
				cQuery += " AND   RC_FILIAL = '"+ TFOL->RC_FILIAL +"' "
				cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRC.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
				cQuery += " AND   RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT "
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "
				cQuery += " AND   RA_CODFUNC = RJ_FUNCAO " 
				cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
				cQuery += " AND   RA_SITFOLH IN ("+cSit+")
				cQuery += " AND   RA_CATFUNC IN ("+cCat+")
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RV_FILIAL
				cQuery += " AND   RC_PD = RV_COD "
				cQuery += " AND   RC_ROTEIR NOT IN ('131','132') " 	
				cQuery += " ORDER BY  RC_PD, RC_DATA , RC_MAT   "

				TcQuery cQuery New Alias TVERB

				nLinha := 1000

				nProv := 0
				nDesc := 0

				WHILE !TVERB->(EOF())
					IF TVERB->RV_TIPOCOD == "1" .OR. TVERB->RV_TIPOCOD == "2"       

						nLinha += 35
						//CODIGO
						//oPrn:Say(nLinha + 5,30,TVERB->RC_PD,oFont7,100)
						oPrn:Say(nLinha + 5,110,TVERB->RC_PD,oFont7,100)

						//PROVENTOS/DESCONTOS
						//oPrn:Say(nLinha + 5,540,TVERB->RV_DESC,oFont7,100)
						oPrn:Say(nLinha + 5,300,TVERB->RV_DESC,oFont7,100)

						//REFER. 
						//oPrn:Say(nLinha + 5,1300,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RC_HORAS,2),"@E 999,999.99")),5,),oFont7,100)
						oPrn:Say(nLinha + 5,1500,ALLTRIM(TRANSFORM(ROUND(TVERB->RC_HORAS,2),"@E 999,999.99")),oFont7,200,,,1)

						IF TVERB->RV_TIPOCOD = "1"
							//PROVENTOS
							oPrn:Say(nLinha + 5,1897,ALLTRIM(TRANSFORM(ROUND(TVERB->RC_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)   


							nProv += ROUND(TVERB->RC_VALOR,2)    

						ELSEIF TVERB->RV_TIPOCOD == "2"
							//DESCONTOS
							//oPrn:Say(nLinha + 5,2100,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RC_VALOR,2),"@E 999,999.99")),15,),oFont7,100)
							oPrn:Say(nLinha + 5,2350,ALLTRIM(TRANSFORM(ROUND(TVERB->RC_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)  

							nDesc += ROUND(TVERB->RC_VALOR,2)

						ENDIF
					ENDIF

					IF TVERB->RC_PD == "919"   //BASE IR     
						nBasIr := TVERB->RC_VALOR
					ELSEIF TVERB->RC_PD == "916" .or. TVERB->RC_PD == "867"  // BASE FGTS         
						nBasFgts += TVERB->RC_VALOR
					ELSEIF TVERB->RC_PD == "920" .or. TVERB->RC_PD == "866"   // FGTS RECOLHIDO
						nFgtsRec += TVERB->RC_VALOR  
					ELSEIF TVERB->RC_PD == "915"    // SALARIO BASE
						nSalBase += TVERB->RC_VALOR 
					ENDIF


					TVERB->(DBSKIP())
				ENDDO                

				TVERB->(dbcloseare())

				// RODAPE
				nLinha := 2705
				//BASE DE CALCULO FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nBasFgts,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100,,,1)   
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100)   

				//BASE DE CALCULO IR
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nBasIr,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100)  

				//TOTAL PROVENTOS 
				//oPrn:Say(nLinha,1246,CVALTOCHAR(ROUND(nProv,2)),oFont7,100)
				//oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100)                

				//TOTAL DESCONTOS	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nDesc,2)),oFont7,100)   
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100)                

				nLinha := 2805

				//FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nFgtsRec,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100)  

				//SALARIO CONTRIBUIÇÃO
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nSalBase,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100) 

				//>>>>>>>>>
				oPrn:Say(nLinha,1446,">>>>>>>",oFont6,100)

				//VALOR LÍQUIDO	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nProv - nDesc,2)),oFont7,100)
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100)  


				//MENSAGEM

				nLinha := 2925
				//oPrn:Say(nLinha,30,cMenComp,oFont7,100)
				oPrn:Say(nLinha,30,substr(cMenComp,1,80),oFont7,100)
				oPrn:Say(nLinha + 30,30,substr(cMenComp,81,80),oFont7,100)
				oPrn:Say(nLinha + 60,30,substr(cMenComp,162,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,243,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,324,80),oFont7,100)

				nBasFgts := 0 
				nFgtsRec := 0 
				nSalBase := 0
				nBasIr := 0		
				//finaliza a pagina
				oPrn:EndPage()	

				TFOL->(DBSKIP())
			ENDDO

			TFOL->(DBCLOSEAREA())   

			oPrn:Preview() 	
			oPrn:End() 

		ELSEIF MV_PAR07 == 2   // PERIODO FECHADO , CONSULTAS FEITAS NAS SRD
			/*
			MONTAR CONSULTA DA SRD DOS FUNCIONÁRIOS 
			*/

			cQuery := " SELECT  RD_FILIAL , RD_MAT , RA_NOME , RD_DATARQ , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO ,RA_BCDEPSA,RA_CTDEPSA ,RA_ADMISSA
			cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRD")+" SRD  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
			cQuery += " WHERE  "
			cQuery += "       RD_MAT BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
			cQuery += " AND   RD_DATARQ = '"+ SUBSTRING(DTOS(MV_PAR03),1,6) +"' "
			cQuery += " AND   RD_FILIAL BETWEEN '"+ cFilde +"' AND '"+ cFilate +"' "
			cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRD.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
			cQuery += " AND   RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT "
			cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "     
			cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
			cQuery += " AND   RA_SITFOLH IN ("+cSit+")
			cQuery += " AND   RA_CATFUNC IN ("+cCat+")
			cQuery += " AND   RD_ROTEIR NOT IN ('131','132') " 	
			cQuery += " GROUP BY RD_FILIAL , RD_MAT , RA_NOME , RD_DATARQ , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO, RA_BCDEPSA, RA_CTDEPSA,RA_ADMISSA "
			cQuery += " ORDER BY RD_FILIAL, RD_DATARQ , RD_MAT  "

			TcQuery cQuery New Alias TFOL

			WHILE !TFOL->(EOF())

				MontaFol(TFOL->RD_FILIAL)

				//CABEÇALHO  
				nLinha := 370

				//matricula
				oPrn:Say(nLinha,30, TFOL->RD_MAT ,oFont7,100)

				//matricula
				oPrn:Say(nLinha,510, TFOL->RA_NOME ,oFont7,100)

				//ADMISSAO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RA_ADMISSA,7,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,5,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,1,4),oFont7,100)

				nLinha := 470

				SM0->(DBSEEK(CEMPANT + TFOL->RD_FILIAL ))
				//empresa
				oPrn:Say(nLinha,30,alltrim(SM0->M0_FILIAL),oFont7,100)   // chapado por pedido do cliente

				//CNPJ
				oPrn:Say(nLinha,1610, TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oFont7,100) //SM0->M0_CGC

				//MES/ANO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RD_DATARQ,5,2) +"/"+ SUBSTR(TFOL->RD_DATARQ,1,4)  ,oFont7,100)


				nLinha := 670

				//FUNÇAO
				oPrn:Say(nLinha,30,ALLTRIM(TFOL->RJ_DESC),oFont7,100)

				//lotação
				//oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_CC),oFont7,100)
				oPrn:Say(nLinha,1010,ALLTRIM(POSICIONE("CTT",1,XFILIAL("CTT",TFOL->RD_FILIAL) + TFOL->RA_CC,"CTT_DESC01")),oFont7,100)

				//DEP.IR
				oPrn:Say(nLinha,2210,ALLTRIM(TFOL->RA_DEPIR),oFont7,100)

				//DEP.SF
				oPrn:Say(nLinha,2337,ALLTRIM(TFOL->RA_DEPSF),oFont7,100)

				nLinha := 770

				//CPF
				oPrn:Say(nLinha,30,TRANSFORM(TFOL->RA_CIC,"@R 999.999.999-99"),oFont7,100)

				//IDENTIDADE
				oPrn:Say(nLinha,510,ALLTRIM(TFOL->RA_RG),oFont7,100)

				//PIS
				oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_PIS),oFont7,100)


				// BUSCAR SALÁRIO DO PEDIO , DE ACORDO COM OS PARAMETROS 
				cQuery := " SELECT TOP 1 *
				cQuery += " FROM  "+RETSQLNAME("SR3")+" SR3 
				cQuery += " WHERE  "
				cQuery += "       R3_FILIAL = '"+TFOL->RD_FILIAL+"' 
				cQuery += " AND   R3_MAT = '"+TFOL->RD_MAT+"' "  
				cQuery += " AND   R3_DATA <= '"+DTOS(MV_PAR03)+"' " 
				cQuery += " AND   R3_PD = '000' "
				cQuery += " ORDER BY R3_DATA DESC "

				TcQuery cQuery New Alias TSAL

				//SALARIO BASE
				oPrn:Say(nLinha,2010,ALLTRIM(TRANSFORM(TSAL->R3_VALOR,"@E 999,999.99")),oFont7,100)  
				TSAL->(DBCLOSEAREA())

				nLinha := 870

				//BANCO DE PAGAMENTO 
				oPrn:Say(nLinha ,30,SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4),oFont7,100)

				//AGENCIA 
				oPrn:Say(nLinha ,1010,SUBSTRING(TFOL->RA_BCDEPSA ,LEN(SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4)) + 1,4),oFont7,100)

				//CONTA CORRENTE 
				oPrn:Say(nLinha ,2010,ALLTRIM(TFOL->RA_CTDEPSA),oFont7,100)

				//ITENS

				cQuery := " SELECT  RD_FILIAL , RD_MAT , RA_NOME , RD_DATARQ , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
				cQuery += " RA_RG , RA_PIS , RA_SALARIO , 
				cQuery += " RD_PD , RV_DESC ,RV_TIPOCOD, RD_VALOR , RD_HORAS
				cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRD")+" SRD  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
				cQuery += " WHERE  "
				cQuery += "       RD_MAT = '"+ TFOL->RD_MAT +"' "
				cQuery += " AND   RD_DATARQ = '"+ TFOL->RD_DATARQ +"' "
				cQuery += " AND   RD_FILIAL = '"+ TFOL->RD_FILIAL +"' "
				cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRD.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
				cQuery += " AND   RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT "
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO " 
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RV_FILIAL
				cQuery += " AND   RD_PD = RV_COD "
				cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
				cQuery += " AND   RA_SITFOLH IN ("+cSit+")
				cQuery += " AND   RA_CATFUNC IN ("+cCat+")
				cQuery += " AND   RD_ROTEIR NOT IN ('131','132') " 	
				cQuery += " ORDER BY RD_DATARQ , RD_MAT , RD_PD "

				TcQuery cQuery New Alias TVERB

				nLinha := 1000

				nProv := 0
				nDesc := 0

				WHILE !TVERB->(EOF())
					IF TVERB->RV_TIPOCOD == "1" .OR. TVERB->RV_TIPOCOD == "2"       

						nLinha += 35
						//CODIGO
						//oPrn:Say(nLinha + 5,30,TVERB->RD_PD,oFont7,100)
						oPrn:Say(nLinha + 5,110,TVERB->RD_PD,oFont7,100)

						//PROVENTOS/DESCONTOS
						//oPrn:Say(nLinha + 5,540,TVERB->RV_DESC,oFont7,100)
						oPrn:Say(nLinha + 5,300,TVERB->RV_DESC,oFont7,100)

						//REFER. 
						//oPrn:Say(nLinha + 5,1300,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RD_HORAS,2),"@E 999,999.99")),5,),oFont7,100)
						oPrn:Say(nLinha + 5,1500,ALLTRIM(TRANSFORM(ROUND(TVERB->RD_HORAS,2),"@E 999,999.99")),oFont7,200,,,1)

						IF TVERB->RV_TIPOCOD = "1"
							//PROVENTOS
							//oPrn:Say(nLinha + 5,1645,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RD_VALOR,2),"@E 999,999.99")),15,) ,oFont7,100)
							oPrn:Say(nLinha + 5,1897,ALLTRIM(TRANSFORM(ROUND(TVERB->RD_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)   

							nProv += ROUND(TVERB->RD_VALOR,2)    

						ELSEIF TVERB->RV_TIPOCOD == "2"
							//DESCONTOS
							//oPrn:Say(nLinha + 5,2100,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RD_VALOR,2),"@E 999,999.99")),15,),oFont7,100)
							oPrn:Say(nLinha + 5,2350,ALLTRIM(TRANSFORM(ROUND(TVERB->RD_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)  

							nDesc += ROUND(TVERB->RD_VALOR,2)

						ENDIF
					ENDIF   


					IF TVERB->RD_PD == "919"   //BASE IR     
						nBasIr := TVERB->RD_VALOR
					ELSEIF TVERB->RD_PD == "916" .or. TVERB->RD_PD == "867"  // BASE FGTS         
						nBasFgts += TVERB->RD_VALOR
					ELSEIF TVERB->RD_PD == "920" .or. TVERB->RD_PD == "866"   // FGTS RECOLHIDO
						nFgtsRec += TVERB->RD_VALOR  
					ELSEIF TVERB->RD_PD == "915"    // SALARIO BASE
						nSalBase += TVERB->RD_VALOR 
					ENDIF

					TVERB->(DBSKIP())
				ENDDO                

				TVERB->(dbcloseare())

				// RODAPE
				nLinha := 2705


				//BASE DE CALCULO FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nBasFgts,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100,,,1)   
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100)   

				//BASE DE CALCULO IR
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nBasIr,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100)  

				//TOTAL PROVENTOS 
				//oPrn:Say(nLinha,1246,CVALTOCHAR(ROUND(nProv,2)),oFont7,100)
				//oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100)                

				//TOTAL DESCONTOS	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nDesc,2)),oFont7,100)   
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100)                

				nLinha := 2805

				//FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nFgtsRec,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100)  

				//SALARIO CONTRIBUIÇÃO
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nSalBase,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100) 

				//>>>>>>>>>
				oPrn:Say(nLinha,1446,">>>>>>>",oFont6,100)

				//VALOR LÍQUIDO	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nProv - nDesc,2)),oFont7,100)
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100)  


				//MENSAGEM

				nLinha := 2925
				//oPrn:Say(nLinha,30,cMenComp,oFont7,100)
				oPrn:Say(nLinha,30,substr(cMenComp,1,80),oFont7,100)
				oPrn:Say(nLinha + 30,30,substr(cMenComp,81,80),oFont7,100)
				oPrn:Say(nLinha + 60,30,substr(cMenComp,162,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,243,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,324,80),oFont7,100)

				nBasFgts := 0 
				nFgtsRec := 0 
				nSalBase := 0
				nBasIr := 0		
				//finaliza a pagina
				oPrn:EndPage()	

				TFOL->(DBSKIP())
			ENDDO

			TFOL->(DBCLOSEAREA())   

			oPrn:Preview() 	
			oPrn:End() 
		ENDIF
	ELSEIF MV_PAR08 == 2 //13* SALARIO

		IF MV_PAR07 == 1 //PERIODO ABERTO , CONSULTAS FEITAS NA SRC

			/*
			MONTAR CONSULTA DA SRC DOS FUNCIONÁRIOS 
			*/

			/*
			cQuery := " SELECT  RI_FILIAL , RI_MAT , RA_NOME , RI_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO ,RA_BCDEPSA,RA_CTDEPSA , RA_ADMISSA
			cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRI")+" SRI  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
			cQuery += " WHERE  "
			cQuery += "       RI_MAT BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
			cQuery += " AND   RI_DATA LIKE '%"+ DTOS(MV_PAR03) +"%' "
			cQuery += " AND   RI_FILIAL BETWEEN '"+ cFilde +"' AND '"+ cFilate +"' "
			cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRI.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
			cQuery += " AND   RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT "
			cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "
			cQuery += " AND   RA_CODFUNC = RJ_FUNCAO " 
			cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
			cQuery += " AND   RA_SITFOLH IN ("+cSit+")
			cQuery += " AND   RA_CATFUNC IN ("+cCat+")    
			cQuery += " GROUP BY RC_FILIAL , RI_MAT , RA_NOME , RI_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO, RA_BCDEPSA, RA_CTDEPSA ,RA_ADMISSA "
			cQuery += " ORDER BY RI_FILIAL, RI_DATA , RI_MAT  "
			*/

			cQuery := " SELECT  RC_FILIAL [RI_FILIAL], RC_MAT [RI_MAT], RA_NOME , RC_DATARQ [RI_DATA], RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO ,RA_BCDEPSA,RA_CTDEPSA ,RA_ADMISSA
			cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRC")+" SRC  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
			cQuery += " WHERE  "
			cQuery += "       RC_MAT BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
			cQuery += " AND   RC_DATARQ = '"+ SUBSTRING(DTOS(MV_PAR03),1,6) +"' " 
			cQuery += " AND   RC_ROTEIR = '132' " 			
			cQuery += " AND   RC_FILIAL BETWEEN '"+ cFilde +"' AND '"+ cFilate +"' "
			cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRC.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
			cQuery += " AND   RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT "
			cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "     
			cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
			cQuery += " AND   RA_SITFOLH IN ("+cSit+")
			cQuery += " AND   RA_CATFUNC IN ("+cCat+")
			cQuery += " GROUP BY RC_FILIAL , RC_MAT , RA_NOME , RC_DATARQ , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO, RA_BCDEPSA, RA_CTDEPSA,RA_ADMISSA "
			cQuery += " ORDER BY RC_FILIAL, RC_DATARQ , RC_MAT  "


			TcQuery cQuery New Alias TFOL

			if TFOL->(EOF())
				alert("Nenhum dado encontrado, favor verificar os parametros!")        
				TFOL->(DBCLOSEAREA()) 
				Return
			endif

			WHILE !TFOL->(EOF())

				MontaFol(TFOL->RI_FILIAL)

				//CABEÇALHO  
				nLinha := 370

				//matricula
				oPrn:Say(nLinha,30, TFOL->RI_MAT ,oFont7,100)

				//matricula
				oPrn:Say(nLinha,510, TFOL->RA_NOME ,oFont7,100)

				//ADMISSAO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RA_ADMISSA,7,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,5,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,1,4),oFont7,100)

				nLinha := 470

				SM0->(DBSEEK(CEMPANT + TFOL->RI_FILIAL ))
				//empresa
				oPrn:Say(nLinha,30,ALLTRIM(SM0->M0_FILIAL),oFont7,100)   // chapado por pedido do cliente

				//CNPJ
				oPrn:Say(nLinha,1610, TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oFont7,100) //SM0->M0_CGC

				//MES/ANO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RI_DATA,5,2) +"/"+ SUBSTR(TFOL->RI_DATA,1,4)  ,oFont7,100)


				nLinha := 670

				//FUNÇAO
				oPrn:Say(nLinha,30,ALLTRIM(TFOL->RJ_DESC),oFont7,100)

				//lotação
				//oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_CC),oFont7,100)
				oPrn:Say(nLinha,1010,ALLTRIM(POSICIONE("CTT",1,XFILIAL("CTT",TFOL->RC_FILIAL) + TFOL->RA_CC,"CTT_DESC01")),oFont7,100)

				//DEP.IR
				oPrn:Say(nLinha,2210,ALLTRIM(TFOL->RA_DEPIR),oFont7,100)

				//DEP.SF
				oPrn:Say(nLinha,2337,ALLTRIM(TFOL->RA_DEPSF),oFont7,100)

				nLinha := 770

				//CPF
				oPrn:Say(nLinha,30,TRANSFORM(TFOL->RA_CIC,"@R 999.999.999-99"),oFont7,100)

				//IDENTIDADE
				oPrn:Say(nLinha,510,ALLTRIM(TFOL->RA_RG),oFont7,100)

				//PIS
				oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_PIS),oFont7,100)


				// BUSCAR SALÁRIO DO PEDIO , DE ACORDO COM OS PARAMETROS 
				cQuery := " SELECT TOP 1 *
				cQuery += " FROM  "+RETSQLNAME("SR3")+" SR3 
				cQuery += " WHERE  "
				cQuery += "       R3_FILIAL = '"+TFOL->RI_FILIAL+"' 
				cQuery += " AND   R3_MAT = '"+TFOL->RI_MAT+"' "  
				cQuery += " AND   R3_DATA <= '"+DTOS(MV_PAR03)+"' "
				cQuery += " AND   R3_PD = '000' "
				cQuery += " ORDER BY R3_DATA DESC "

				TcQuery cQuery New Alias TSAL

				//SALARIO BASE
				oPrn:Say(nLinha,2010,ALLTRIM(TRANSFORM(TSAL->R3_VALOR,"@E 999,999.99")),oFont7,100)
				TSAL->(DBCLOSEAREA())

				nLinha := 870

				//BANCO DE PAGAMENTO 
				oPrn:Say(nLinha ,30,SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4),oFont7,100)

				//AGENCIA 
				oPrn:Say(nLinha ,1010,SUBSTRING(TFOL->RA_BCDEPSA ,LEN(SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4)) + 1,4),oFont7,100)

				//CONTA CORRENTE 
				oPrn:Say(nLinha ,2010,ALLTRIM(TFOL->RA_CTDEPSA),oFont7,100)

				//ITENS

				/*
				cQuery := " SELECT  RI_FILIAL , RI_MAT , RA_NOME , RI_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
				cQuery += " RA_RG , RA_PIS , RA_SALARIO , 
				cQuery += " RI_PD , RV_DESC ,RV_TIPOCOD, RI_VALOR , RI_HORAS
				cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRI")+" SRI  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
				cQuery += " WHERE  "
				cQuery += "       RI_MAT = '"+ TFOL->RI_MAT +"' "
				cQuery += " AND   RI_DATA LIKE '%"+ TFOL->RI_DATA +"%' "
				cQuery += " AND   RI_FILIAL = '"+ TFOL->RI_FILIAL +"' "
				cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRI.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
				cQuery += " AND   RA_FILIAL = RI_FILIAL AND RA_MAT = RC_MAT "
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "
				cQuery += " AND   RA_CODFUNC = RJ_FUNCAO " 
				cQuery += " AND   RI_PD = RV_COD "
				cQuery += " AND   RI_PD NOT IN ('170','051') "
				cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
				cQuery += " AND   RA_SITFOLH IN ("+cSit+")
				cQuery += " AND   RA_CATFUNC IN ("+cCat+")
				cQuery += " ORDER BY RI_DATA , RI_MAT , RI_PD "
				*/

				cQuery := " SELECT  RC_FILIAL [RI_FILIAL], RC_MAT [RI_MAT], RA_NOME , RC_DATARQ [RI_DATA] , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
				cQuery += " RA_RG , RA_PIS , RA_SALARIO , 
				cQuery += " RC_PD [RI_PD], RV_DESC ,RV_TIPOCOD, RC_VALOR [RI_VALOR], RC_HORAS [RI_HORAS]
				cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRC")+" SRC  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
				cQuery += " WHERE  "
				cQuery += "       RC_MAT = '"+ TFOL->RI_MAT +"' "
				cQuery += " AND   RC_ROTEIR = '132' " 	
				cQuery += " AND   RC_DATARQ = '"+ TFOL->RI_DATA +"' "
				cQuery += " AND   RC_FILIAL = '"+ TFOL->RI_FILIAL +"' "
				cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRC.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
				cQuery += " AND   RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT "
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO " 
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RV_FILIAL
				cQuery += " AND   RC_PD = RV_COD "
				cQuery += " AND   RC_PD NOT IN ('170','051') "
				cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
				cQuery += " AND   RA_SITFOLH IN ("+cSit+")
				cQuery += " AND   RA_CATFUNC IN ("+cCat+")
				cQuery += " ORDER BY RC_DATARQ , RC_MAT , RC_PD "

				TcQuery cQuery New Alias TVERB

				nLinha := 1000

				nProv := 0
				nDesc := 0

				WHILE !TVERB->(EOF())
					IF TVERB->RV_TIPOCOD == "1" .OR. TVERB->RV_TIPOCOD == "2"       

						nLinha += 35
						//CODIGO
						//oPrn:Say(nLinha + 5,30,TVERB->RI_PD,oFont7,100)
						oPrn:Say(nLinha + 5,110,TVERB->RI_PD,oFont7,100)

						//PROVENTOS/DESCONTOS
						//oPrn:Say(nLinha + 5,540,TVERB->RV_DESC,oFont7,100)
						oPrn:Say(nLinha + 5,300,TVERB->RV_DESC,oFont7,100)

						//REFER. 
						//oPrn:Say(nLinha + 5,1300,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RI_HORAS,2),"@E 999,999.99")),5,),oFont7,100)
						oPrn:Say(nLinha + 5,1500,ALLTRIM(TRANSFORM(ROUND(TVERB->RI_HORAS,2),"@E 999,999.99")),oFont7,200,,,1)

						IF TVERB->RV_TIPOCOD = "1"
							//PROVENTOS
							oPrn:Say(nLinha + 5,1897,ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)   


							nProv += ROUND(TVERB->RI_VALOR,2)    

						ELSEIF TVERB->RV_TIPOCOD == "2"
							//DESCONTOS
							//oPrn:Say(nLinha + 5,2100,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),15,),oFont7,100)
							oPrn:Say(nLinha + 5,2350,ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)  

							nDesc += ROUND(TVERB->RI_VALOR,2)

						ENDIF
					ENDIF   

					IF TVERB->RC_PD == "726"   //BASE IR     
						nBasIr := TVERB->RC_VALOR
					ELSEIF TVERB->RC_PD == "768"  // BASE FGTS         
						nBasFgts += TVERB->RC_VALOR
					ELSEIF TVERB->RC_PD == "920" .or. TVERB->RC_PD == "866"   // FGTS RECOLHIDO
						nFgtsRec += TVERB->RC_VALOR  
					ELSEIF TVERB->RC_PD == "915"    // SALARIO BASE
						nSalBase += TVERB->RC_VALOR 
					ENDIF


					TVERB->(DBSKIP())
				ENDDO                

				TVERB->(dbcloseare())

				// RODAPE
				nLinha := 2705


				//BASE DE CALCULO FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nBasFgts,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100,,,1)   
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100)   

				//BASE DE CALCULO IR
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nBasIr,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100)  

				//TOTAL PROVENTOS 
				//oPrn:Say(nLinha,1246,CVALTOCHAR(ROUND(nProv,2)),oFont7,100)
				//oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100)                

				//TOTAL DESCONTOS	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nDesc,2)),oFont7,100)   
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100)                

				nLinha := 2805

				//FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nFgtsRec,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100)  

				//SALARIO CONTRIBUIÇÃO
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nSalBase,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100) 

				//>>>>>>>>>
				oPrn:Say(nLinha,1446,">>>>>>>",oFont6,100)

				//VALOR LÍQUIDO	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nProv - nDesc,2)),oFont7,100)
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100)  


				//MENSAGEM

				nLinha := 2925
				//oPrn:Say(nLinha,30,cMenComp,oFont7,100)
				oPrn:Say(nLinha,30,substr(cMenComp,1,80),oFont7,100)
				oPrn:Say(nLinha + 30,30,substr(cMenComp,81,80),oFont7,100)
				oPrn:Say(nLinha + 60,30,substr(cMenComp,162,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,243,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,324,80),oFont7,100)

				nBasFgts := 0 
				nFgtsRec := 0 
				nSalBase := 0
				nBasIr := 0		
				//finaliza a pagina
				oPrn:EndPage()	

				TFOL->(DBSKIP())
			ENDDO

			TFOL->(DBCLOSEAREA())   

			oPrn:Preview() 	
			oPrn:End() 

		ELSEIF MV_PAR07 == 2   // PERIODO FECHADO , CONSULTAS FEITAS NAS SRD   
			/*
			MONTAR CONSULTA DA SRD DOS FUNCIONÁRIOS 
			*/

			/*
			cQuery := " SELECT  RI_FILIAL , RI_MAT , RA_NOME , RI_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO ,RA_BCDEPSA,RA_CTDEPSA ,RA_ADMISSA
			cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA , RI01"+SUBSTRING(DTOS(MV_PAR03),3,2)+"13 SRI  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
			cQuery += " WHERE  "
			cQuery += "       RI_MAT BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
			cQuery += " AND   RI_DATA LIKE '%"+ SUBSTRING(DTOS(MV_PAR03),1,6) +"%' "
			cQuery += " AND   RI_FILIAL BETWEEN '"+ cFilde +"' AND '"+ cFilate +"' "
			cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRI.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
			cQuery += " AND   RA_FILIAL = RI_FILIAL AND RA_MAT = RI_MAT "
			cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "     
			cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
			cQuery += " AND   RA_SITFOLH IN ("+cSit+")
			cQuery += " AND   RA_CATFUNC IN ("+cCat+")
			cQuery += " GROUP BY RI_FILIAL , RI_MAT , RA_NOME , RI_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO, RA_BCDEPSA, RA_CTDEPSA,RA_ADMISSA "
			cQuery += " ORDER BY RI_FILIAL, RI_DATA , RI_MAT  "
			*/


			cQuery := " SELECT  RD_FILIAL [RI_FILIAL], RD_MAT [RI_MAT], RA_NOME , RD_DATARQ [RI_DATA], RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO ,RA_BCDEPSA,RA_CTDEPSA ,RA_ADMISSA
			cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRD")+" SRD  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
			cQuery += " WHERE  "
			cQuery += "       RD_MAT BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"' "
			cQuery += " AND   RD_DATARQ = '"+ SUBSTRING(DTOS(MV_PAR03),1,6) +"' " 
			cQuery += " AND   RD_ROTEIR = '132' " 			
			cQuery += " AND   RD_FILIAL BETWEEN '"+ cFilde +"' AND '"+ cFilate +"' "
			cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRD.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
			cQuery += " AND   RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT "
			cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO "     
			cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
			cQuery += " AND   RA_SITFOLH IN ("+cSit+")
			cQuery += " AND   RA_CATFUNC IN ("+cCat+")
			cQuery += " GROUP BY RD_FILIAL , RD_MAT , RA_NOME , RD_DATARQ , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
			cQuery += " RA_RG , RA_PIS , RA_SALARIO, RA_BCDEPSA, RA_CTDEPSA,RA_ADMISSA "
			cQuery += " ORDER BY RD_FILIAL, RD_DATARQ , RD_MAT  "

			TcQuery cQuery New Alias TFOL

			WHILE !TFOL->(EOF())

				MontaFol(TFOL->RI_FILIAL)

				//CABEÇALHO  
				nLinha := 370

				//matricula
				oPrn:Say(nLinha,30, TFOL->RI_MAT ,oFont7,100)

				//matricula
				oPrn:Say(nLinha,510, TFOL->RA_NOME ,oFont7,100)

				//ADMISSAO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RA_ADMISSA,7,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,5,2) +"/"+ SUBSTR(TFOL->RA_ADMISSA,1,4),oFont7,100)

				nLinha := 470

				SM0->(DBSEEK(CEMPANT + TFOL->RI_FILIAL ))
				//empresa
				oPrn:Say(nLinha,30,ALLTRIM(SM0->M0_FILIAL),oFont7,100)   // chapado por pedido do cliente

				//CNPJ
				oPrn:Say(nLinha,1610, TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oFont7,100) //SM0->M0_CGC

				//MES/ANO 
				oPrn:Say(nLinha,2210, SUBSTR(TFOL->RI_DATA,5,2) +"/"+ SUBSTR(TFOL->RI_DATA,1,4)  ,oFont7,100)


				nLinha := 670

				//FUNÇAO
				oPrn:Say(nLinha,30,ALLTRIM(TFOL->RJ_DESC),oFont7,100)

				//lotação
				//oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_CC),oFont7,100)
				oPrn:Say(nLinha,1010,ALLTRIM(POSICIONE("CTT",1,XFILIAL("CTT",TFOL->RD_FILIAL) + TFOL->RA_CC,"CTT_DESC01")),oFont7,100)

				//DEP.IR
				oPrn:Say(nLinha,2210,ALLTRIM(TFOL->RA_DEPIR),oFont7,100)

				//DEP.SF
				oPrn:Say(nLinha,2337,ALLTRIM(TFOL->RA_DEPSF),oFont7,100)

				nLinha := 770

				//CPF
				oPrn:Say(nLinha,30,TRANSFORM(TFOL->RA_CIC,"@R 999.999.999-99"),oFont7,100)

				//IDENTIDADE
				oPrn:Say(nLinha,510,ALLTRIM(TFOL->RA_RG),oFont7,100)

				//PIS
				oPrn:Say(nLinha,1010,ALLTRIM(TFOL->RA_PIS),oFont7,100)


				// BUSCAR SALÁRIO DO PEDIO , DE ACORDO COM OS PARAMETROS 
				cQuery := " SELECT TOP 1 *
				cQuery += " FROM  "+RETSQLNAME("SR3")+" SR3 
				cQuery += " WHERE  "
				cQuery += "       R3_FILIAL = '"+TFOL->RI_FILIAL+"' 
				cQuery += " AND   R3_MAT = '"+TFOL->RI_MAT+"' "  
				cQuery += " AND   R3_DATA <= '"+DTOS(MV_PAR03)+"' "
				cQuery += " AND   R3_PD = '000' "
				cQuery += " ORDER BY R3_DATA DESC "

				TcQuery cQuery New Alias TSAL

				//SALARIO BASE
				oPrn:Say(nLinha,2010,ALLTRIM(TRANSFORM(TSAL->R3_VALOR,"@E 999,999.99")),oFont7,100)
				TSAL->(DBCLOSEAREA())

				nLinha := 870

				//BANCO DE PAGAMENTO 
				oPrn:Say(nLinha ,30,SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4),oFont7,100)

				//AGENCIA 
				oPrn:Say(nLinha ,1010,SUBSTRING(TFOL->RA_BCDEPSA ,LEN(SUBSTRING(TFOL->RA_BCDEPSA ,1,LEN(ALLTRIM(TFOL->RA_BCDEPSA))-4)) + 1,4),oFont7,100)

				//CONTA CORRENTE 
				oPrn:Say(nLinha ,2010,ALLTRIM(TFOL->RA_CTDEPSA),oFont7,100)

				//ITENS
				/*
				cQuery := " SELECT  RI_FILIAL , RI_MAT , RA_NOME , RI_DATA , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
				cQuery += " RA_RG , RA_PIS , RA_SALARIO , 
				cQuery += " RI_PD , RV_DESC ,RV_TIPOCOD, RI_VALOR , RI_HORAS
				cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA , RI01"+SUBSTRING(DTOS(MV_PAR03),3,2)+"13 SRI   , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
				cQuery += " WHERE  "
				cQuery += "       RI_MAT = '"+ TFOL->RI_MAT +"' "
				cQuery += " AND   RI_DATA LIKE '%"+ TFOL->RI_DATA +"%' "
				cQuery += " AND   RI_FILIAL = '"+ TFOL->RI_FILIAL +"' "
				cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRI.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
				cQuery += " AND   RA_FILIAL = RI_FILIAL AND RA_MAT = RI_MAT "
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO " 
				cQuery += " AND   RI_PD = RV_COD "
				cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
				cQuery += " AND   RA_SITFOLH IN ("+cSit+")
				cQuery += " AND   RA_CATFUNC IN ("+cCat+")
				cQuery += " ORDER BY RI_DATA , RI_MAT , RI_PD "
				*/

				cQuery := " SELECT  RD_FILIAL [RI_FILIAL], RD_MAT [RI_MAT], RA_NOME , RD_DATARQ [RI_DATA] , RA_CODFUNC , RJ_DESC, RA_DEPIR , RA_DEPSF ,RA_CC,RA_CIC,
				cQuery += " RA_RG , RA_PIS , RA_SALARIO , 
				cQuery += " RD_PD [RI_PD], RV_DESC ,RV_TIPOCOD, RD_VALOR [RI_VALOR], RD_HORAS [RI_HORAS]
				cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA ,"+RETSQLNAME("SRD")+" SRD  , "+RETSQLNAME("SRJ")+" SRJ , "+RETSQLNAME("SRV")+" SRV"
				cQuery += " WHERE  "
				cQuery += "       RD_MAT = '"+ TFOL->RI_MAT +"' "
				cQuery += " AND   RD_ROTEIR = '132' " 	
				cQuery += " AND   RD_DATARQ = '"+ TFOL->RI_DATA +"' "
				cQuery += " AND   RD_FILIAL = '"+ TFOL->RI_FILIAL +"' "
				cQuery += " AND   SRA.D_E_L_E_T_ = '' AND   SRD.D_E_L_E_T_ = '' AND   SRJ.D_E_L_E_T_ = '' AND SRV.D_E_L_E_T_='' "
				cQuery += " AND   RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT "
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RJ_FILIAL AND RA_CODFUNC = RJ_FUNCAO " 
				cQuery += " AND   SUBSTRING(RA_FILIAL,1,2) = RV_FILIAL
				cQuery += " AND   RD_PD = RV_COD "
				cQuery += " AND   RD_PD NOT IN ('170','051') "
				cQuery += " AND   RA_CC BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR10 +"' "
				cQuery += " AND   RA_SITFOLH IN ("+cSit+")
				cQuery += " AND   RA_CATFUNC IN ("+cCat+")
				cQuery += " ORDER BY RD_DATARQ , RD_MAT , RD_PD "

				TcQuery cQuery New Alias TVERB

				nLinha := 1000

				nProv := 0
				nDesc := 0

				WHILE !TVERB->(EOF())
					IF TVERB->RV_TIPOCOD == "1" .OR. TVERB->RV_TIPOCOD == "2"       

						nLinha += 35
						//CODIGO
						//oPrn:Say(nLinha + 5,30,TVERB->RI_PD,oFont7,100)
						oPrn:Say(nLinha + 5,110,TVERB->RI_PD,oFont7,100)

						//PROVENTOS/DESCONTOS
						//oPrn:Say(nLinha + 5,540,TVERB->RV_DESC,oFont7,100)
						oPrn:Say(nLinha + 5,300,TVERB->RV_DESC,oFont7,100)

						//REFER. 
						//oPrn:Say(nLinha + 5,1300,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RI_HORAS,2),"@E 999,999.99")),5,),oFont7,100)
						oPrn:Say(nLinha + 5,1500,ALLTRIM(TRANSFORM(ROUND(TVERB->RI_HORAS,2),"@E 999,999.99")),oFont7,200,,,1)

						IF TVERB->RV_TIPOCOD = "1"
							//PROVENTOS
							//oPrn:Say(nLinha + 5,1645,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),15,) ,oFont7,100)
							oPrn:Say(nLinha + 5,1897,ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)   

							nProv += ROUND(TVERB->RI_VALOR,2)    

						ELSEIF TVERB->RV_TIPOCOD == "2"
							//DESCONTOS
							//oPrn:Say(nLinha + 5,2100,PADL(ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),15,),oFont7,100)
							oPrn:Say(nLinha + 5,2350,ALLTRIM(TRANSFORM(ROUND(TVERB->RI_VALOR,2),"@E 999,999.99")),oFont7,200,,,1)  

							nDesc += ROUND(TVERB->RI_VALOR,2)

						ENDIF
					ENDIF   

					IF TVERB->RD_PD == "726"   //BASE IR     
						nBasIr := TVERB->RD_VALOR
					ELSEIF TVERB->RD_PD == "768"  // BASE FGTS         
						nBasFgts += TVERB->RD_VALOR
					ELSEIF TVERB->RD_PD == "920" .or. TVERB->RD_PD == "866"   // FGTS RECOLHIDO
						nFgtsRec += TVERB->RD_VALOR  
					ELSEIF TVERB->RD_PD == "915"    // SALARIO BASE
						nSalBase += TVERB->RD_VALOR 
					ENDIF


					TVERB->(DBSKIP())
				ENDDO                

				TVERB->(dbcloseare())

				// RODAPE
				nLinha := 2705


				//BASE DE CALCULO FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nBasFgts,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100,,,1)   
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nBasFgts,2),"@E 999,999.99")),oFont7,100)   

				//BASE DE CALCULO IR
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nBasIr,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nBasIr,2),"@E 999,999.99")),oFont7,100)  

				//TOTAL PROVENTOS 
				//oPrn:Say(nLinha,1246,CVALTOCHAR(ROUND(nProv,2)),oFont7,100)
				//oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1246,ALLTRIM(TRANSFORM(ROUND(nProv,2),"@E 999,999.99")),oFont7,100)                

				//TOTAL DESCONTOS	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nDesc,2)),oFont7,100)   
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100,,,1)  
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nDesc,2),"@E 999,999.99")),oFont7,100)                

				nLinha := 2805

				//FGTS
				//oPrn:Say(nLinha,30,CVALTOCHAR(ROUND(nFgtsRec,2)),oFont7,100)
				//oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,30,ALLTRIM(TRANSFORM(ROUND(nFgtsRec,2),"@E 999,999.99")),oFont7,100)  

				//SALARIO CONTRIBUIÇÃO
				//oPrn:Say(nLinha,638,CVALTOCHAR(ROUND(nSalBase,2)),oFont7,100)
				//oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100,,,1) 
				oPrn:Say(nLinha,638,ALLTRIM(TRANSFORM(ROUND(nSalBase,2),"@E 999,999.99")),oFont7,100) 

				//>>>>>>>>>
				oPrn:Say(nLinha,1446,">>>>>>>",oFont6,100)

				//VALOR LÍQUIDO	
				//oPrn:Say(nLinha,1854,CVALTOCHAR(ROUND(nProv - nDesc,2)),oFont7,100)
				//oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100,,,1)     
				oPrn:Say(nLinha,1854,ALLTRIM(TRANSFORM(ROUND(nProv - nDesc,2),"@E 999,999.99")),oFont7,100)  

				//MENSAGEM

				nLinha := 2925
				//oPrn:Say(nLinha,30,cMenComp,oFont7,100)
				oPrn:Say(nLinha,30,substr(cMenComp,1,80),oFont7,100)
				oPrn:Say(nLinha + 30,30,substr(cMenComp,81,80),oFont7,100)
				oPrn:Say(nLinha + 60,30,substr(cMenComp,162,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,243,80),oFont7,100)
				oPrn:Say(nLinha + 90,30,substr(cMenComp,324,80),oFont7,100)

				nBasFgts := 0 
				nFgtsRec := 0 
				nSalBase := 0
				nBasIr := 0		
				//finaliza a pagina
				oPrn:EndPage()	

				TFOL->(DBSKIP())
			ENDDO

			TFOL->(DBCLOSEAREA())   

			oPrn:Preview() 	
			oPrn:End() 
		ENDIF

	ENDIF
return

Static Function AjustaSX1(cPerg)

	RCMHF001(cPerg, "01","Filial de?",                            "","","mv_ch01","C",06,0,0,"G","","SM0","","","MV_PAR01","","","","","","","","","","","")  
	RCMHF001(cPerg, "02","Filial ate?",                           "","","mv_ch02","C",06,0,0,"G","","SM0","","","MV_PAR02","","","","","","","","","","","")
	RCMHF001(cPerg, "03","Periodo de?",                           "","","mv_ch03","D",08,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","")
	RCMHF001(cPerg, "04","De Matricula?",                         "","","mv_ch04","C",06,0,0,"G","","SRA","","","MV_PAR04","","","","","","",,,,"","")
	RCMHF001(cPerg, "05","Ate Matricula?",                        "","","mv_ch05","C",06,0,0,"G","","SRA","","","MV_PAR05","","","","","","",,,,"","")
	RCMHF001(cPerg, "06","Mensagem",                              "","","mv_ch06","C",03,0,0,"C","","","","","MV_PAR06","SIM","SIM","SIM","NÃO","NÃO","NÃO",,,,"","")
	RCMHF001(cPerg, "07","Tipo Periodo",                          "","","mv_ch07","C",10,0,0,"C","","","","","MV_PAR07","Aberto","Aberto","Aberto","Fechado","Fechado","Fechado",,,,"","")
	RCMHF001(cPerg, "08","Folha/ 13* ?",                          "","","mv_ch08","C",10,0,0,"C","","","","","MV_PAR08","Folha","Folha","Folha","13* Salario","13* Salario","13* Salario",,,,"","")
	RCMHF001(cPerg, "09","CC de?",                                "","","mv_ch09","C",12,0,0,"G","","CTT","","","MV_PAR09","","","","","","","","","","","")  
	RCMHF001(cPerg, "10","CC ate?",                               "","","mv_ch10","C",12,0,0,"G","","CTT","","","MV_PAR10","","","","","","","","","","","")
	RCMHF001(cPerg, "11","Situações a Imp. ?",                    "","","mv_ch11","C",05,0,0,"G","fSituacao","","","","MV_PAR11","","","","","","","","","","","")  
	RCMHF001(cPerg, "12","Categorias a Imp. ?",                   "","","mv_ch12","C",15,0,0,"G","fCategoria","","","","MV_PAR12","","","","","","","","","","","")

Return

Static Function MontaFol(cConfil)

	//Inicia uma nova página
	oPrn:StartPage()          // Inicia uma nova página
	//Monta a caixa (moldura)
	//oPrn:Box (20,20,3485,2455)
	oPrn:Box (30,10,3395,2465)
	oPrn:Box (40,20,2655,2455)

	//LOGO DA EMPRESA
	//oPrn:SayBitmap(100,70,"C:\servnac\servnac.png",360,142)

	if alltrim(cConfil) == "050101"
		//oPrn:SayBitmap(100,70,"/system/logoserv/tok.png",360,142)
		oPrn:SayBitmap(100,70,"C:\servnac\tok.png",360,142)
	else
		//oPrn:SayBitmap(100,70,"/system/logoserv/servnac.png",360,142)
		oPrn:SayBitmap(100,70,"C:\servnac\servnac.png",360,142)
	endif

	//DESCRIÇÃO DO DOCUMENTO
	oPrn:Say(150,1580,"COMPROVANTE DE PAGAMENTO",oFont5,100)

	oPrn:Line(330,20,330,2455) //-----

	nLinha := 330 	

	//matricula
	oPrn:Say(nLinha + 10 ,30,"MATRÍCULA",oFont3,100)

	//matricula
	oPrn:Say(nLinha + 10 ,510,"NOME",oFont3,100)

	//ADMISSAO 
	oPrn:Say(nLinha + 10 ,2210,"ADMISSÃO",oFont3,100)

	oPrn:Box (nLinha ,500,nLinha + 100 ,2200)

	nLinha += 100 //(430)
	oPrn:Line(nLinha,20,nLinha,2455) // ------

	//empresa
	oPrn:Say(nLinha + 10,30,"EMPRESA",oFont3,100)

	//CNPJ
	oPrn:Say(nLinha + 10,1610,"CNPJ",oFont3,100)

	//MES/ANO 
	oPrn:Say(nLinha + 10,2210,"MES / ANO",oFont3,100)

	oPrn:Box (nLinha ,1600,nLinha + 100 ,2200)

	nLinha += 100 //(530)

	oPrn:Line(nLinha,20,nLinha,2455) //---

	oPrn:FillRect( {nLinha, 20, nLinha + 100, 2455}, oBrush1 )

	nLinha += 100  //630

	oPrn:Line(nLinha,20,nLinha,2455) //--- 

	oPrn:Box (nLinha,1000,nLinha + 100,2200) //box CENTRO DE CUSTO
	oPrn:Box (nLinha,2200,nLinha + 100,2327) //box dep.sf

	//cargo
	oPrn:Say(nLinha + 10 ,30,"FUNÇÃO",oFont3,100)

	//lotação
	oPrn:Say(nLinha + 10 ,1010,"CENTRO DE CUSTO",oFont3,100)

	//DEP.IR
	oPrn:Say(nLinha + 10 ,2210,"DEP.IR",oFont3,100)

	//DEP.SF
	oPrn:Say(nLinha + 10 ,2337,"DEP.SF",oFont3,100)

	nLinha += 100 //(730)

	oPrn:Line(nLinha,20,nLinha,2455) //----

	oPrn:Box (nLinha,500,nLinha + 100,1000) //box identidade
	oPrn:Box (nLinha,2000,nLinha + 100,2455) //box salario base

	//CPF
	oPrn:Say(nLinha + 10,30,"CPF",oFont3,100)

	//IDENTIDADE
	oPrn:Say(nLinha + 10,510,"IDENTIDADE",oFont3,100)

	//PIS
	oPrn:Say(nLinha + 10,1010,"PIS",oFont3,100)

	//SALARIO BASE
	oPrn:Say(nLinha + 10,2010,"SALÁRIO BASE",oFont3,100)


	nLinha += 100 //(830)

	oPrn:Line(nLinha,20,nLinha,2455) //-------

	oPrn:Box (nLinha,1000,nLinha + 100,2000) //box agnecia

	//BANCO DE PAGAMENTO 
	oPrn:Say(nLinha + 10 ,30,"BANCO DE PAGAMENTO",oFont3,100)

	//AGENCIA 
	oPrn:Say(nLinha + 10 ,1010,"AGÊNCIA",oFont3,100)

	//CONTA CORRENTE 
	oPrn:Say(nLinha + 10 ,2010,"CONTA CORRENTE",oFont3,100)


	nLinha += 100 //(930)

	oPrn:Line(nLinha,20,nLinha,2455) //-------


	//oPrn:Box (nLinha,260,nLinha + 10,1200) //box PROVENTOS DESCONTOS
	oPrn:Box (nLinha,260,nLinha + 1725,1200) //box PROVENTOS DESCONTOS
	//oPrn:Box (nLinha,1545,nLinha + 10,2000) //box PROVENTOS PROVENTOS
	oPrn:Box (nLinha,1545,nLinha + 1725,2000) //box PROVENTOS PROVENTOS

	//CODIGO
	oPrn:Say(nLinha + 5,50,"CÓDIGO",oFont6,100)

	//PROVENTOS/DESCONTOS
	oPrn:Say(nLinha + 5,540,"DESCRIÇÃO",oFont6,100)

	//REFER. 
	oPrn:Say(nLinha + 5,1248,"REFERÊNCIA",oFont6,100)

	//PROVENTOS
	oPrn:Say(nLinha + 5,1645,"PROVENTOS",oFont6,100)

	//DESCONTOS
	oPrn:Say(nLinha + 5,2100,"DESCONTOS",oFont6,100)

	nLinha += 70 //(1000)

	oPrn:Line(nLinha,20,nLinha,2455) //------------------

	//box de bases
	nLinha := nLinha + 1665 //(2665)

	oPrn:Box (nLinha ,20,nLinha + 200,2455)

	oPrn:Box (nLinha,628,nLinha + 200 ,1236) //box base de calculo e ir  / salario contribuição
	oPrn:Box (nLinha,1236,nLinha + 200 ,1844) //box total de proventos


	//BASE DE CALCULO FGTS
	oPrn:Say(nLinha + 10 ,30,"BASE DE CÁLCULO FGTS",oFont3,100)

	//BASE DE CALCULO IR
	oPrn:Say(nLinha + 10 ,638,"BASE DE CÁLCULO IR",oFont3,100)

	//TOTAL PROVENTOS 
	oPrn:Say(nLinha + 10 ,1246,"TOTAL PROVENTOS",oFont3,100)

	//TOTAL DESCONTOS	
	oPrn:Say(nLinha + 10 ,1854,"TOTAL DESCONTOS",oFont3,100)

	nLinha  += 100 //(2765)

	oPrn:Line(nLinha,20,nLinha,2455)

	//FGTS
	oPrn:Say(nLinha + 10,30,"FGTS",oFont3,100)

	//SALARIO CONTRIBUIÇÃO
	oPrn:Say(nLinha + 10,638,"SALÁRIO CONTRIBUIÇÃO",oFont3,100)

	//>>>>>>>>>
	oPrn:Say(nLinha + 20,1446,">>>>>>>",oFont6,100)

	//VALOR LÍQUIDO	
	oPrn:Say(nLinha + 10,1854,"VALOR LÍQUIDO",oFont3,100)

	nLinha  += 100 //(2865)

	//box de mensagem
	oPrn:Box (nLinha + 20,20,nLinha + 520,2455)

	//MENSAGEM	
	oPrn:Say(nLinha + 30,30,"MENSAGEM",oFont3,100)

	/*
	oPrn:EndPage()	
	oPrn:Preview() 	
	oPrn:End() 
	*/

Return 


Static function RCMHF001(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
	cF3, cGrpSxg,cPyme,; 
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
	cDef02,cDefSpa2,cDefEng2,; 
	cDef03,cDefSpa3,cDefEng3,; 
	cDef04,cDefSpa4,cDefEng4,; 
	cDef05,cDefSpa5,cDefEng5,; 
	aHelpPor,aHelpEng,aHelpSpa,cHelp) 

	LOCAL aArea := GetArea() 
	Local cKey 
	Local lPort := .f. 
	Local lSpa := .f. 
	Local lIngl := .f. 

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

	cPyme	:= Iif( cPyme	== Nil, " ", cPyme	) 
	cF3		:= Iif( cF3		== NIl, " ", cF3	) 
	cGrpSxg	:= Iif( cGrpSxg	== Nil, " ", cGrpSxg) 
	cCnt01	:= Iif( cCnt01	== Nil, "" , cCnt01	) 
	cHelp	:= Iif( cHelp	== Nil, "" , cHelp	) 

	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

	If !( DbSeek( cGrupo + cOrdem )) 

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

		Reclock( "SX1" , .T. ) 

		Replace X1_GRUPO   With cGrupo 
		Replace X1_ORDEM   With cOrdem 
		Replace X1_PERGUNT With cPergunt 
		Replace X1_PERSPA With cPerSpa 
		Replace X1_PERENG With cPerEng 
		Replace X1_VARIAVL With cVar 
		Replace X1_TIPO    With cTipo 
		Replace X1_TAMANHO With nTamanho 
		Replace X1_DECIMAL With nDecimal 
		Replace X1_PRESEL With nPresel 
		Replace X1_GSC     With cGSC 
		Replace X1_VALID   With cValid 

		Replace X1_VAR01   With cVar01 

		Replace X1_F3      With cF3 
		Replace X1_GRPSXG With cGrpSxg 

		If Fieldpos("X1_PYME") > 0 
			If cPyme != Nil 
				Replace X1_PYME With cPyme 
			Endif 
		Endif 

		Replace X1_CNT01   With cCnt01 
		If cGSC == "C" 
			Replace X1_DEF01   With cDef01 
			Replace X1_DEFSPA1 With cDefSpa1 
			Replace X1_DEFENG1 With cDefEng1 

			Replace X1_DEF02   With cDef02 
			Replace X1_DEFSPA2 With cDefSpa2 
			Replace X1_DEFENG2 With cDefEng2 

			Replace X1_DEF03   With cDef03 
			Replace X1_DEFSPA3 With cDefSpa3 
			Replace X1_DEFENG3 With cDefEng3 

			Replace X1_DEF04   With cDef04 
			Replace X1_DEFSPA4 With cDefSpa4 
			Replace X1_DEFENG4 With cDefEng4 

			Replace X1_DEF05   With cDef05 
			Replace X1_DEFSPA5 With cDefSpa5 
			Replace X1_DEFENG5 With cDefEng5 
		Endif 

		Replace X1_HELP With cHelp 

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

		MsUnlock() 
	Else 

		lPort:= ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
		lSpa	:= ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
		lIngl:= ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

		If lPort .Or. lSpa .Or. lIngl 
			RecLock("SX1",.F.) 
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
			EndIf 
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
			EndIf 
			If lIngl 
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
			EndIf 
			SX1->(MsUnLock()) 
		EndIf 
	Endif 

	RestArea( aArea ) 

Return