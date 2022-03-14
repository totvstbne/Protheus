#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"
#include "topconn.ch"
#Define CRLF CHR(13)+CHR(10)

user function RSERV010()

	Local aPergs	:= {}
	Local aRetOpc	:= {}
	Local cFilde    := space(6)
	Local cFilate   := space(6)
	Local cPeriod   := space(6)
	Local cDiret    := space(240)
	Local cRoteiro  := space(3)
	Local aOpc      := {"Urbano","Metropolitano"}
	Local aTipos	:= {"T=Todos","D=Dissídio","N=Normal"}
	Local cMat      := space(6)
	Local cMeioTr   := space(2)
	Local cNumPd    := space(10)
	Local cNumPate  := space(10)

	Local cMenComp  := ""

	aAdd( aPergs ,{1,"Filial de",	cFilde	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Filial de",	cFilate	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Período",	    cPeriod	,GetSx3Cache("RG2_ANOMES","X3_PICTURE") ,'.T.',"" ,'.T.',6,.T.})
	aAdd( aPergs ,{1,"Diretório",	cDiret	,GetSx3Cache("RA_NOME","X3_PICTURE") ,'.T.',"" ,'.T.',100,.T.})
	aAdd( aPergs ,{1,"Roteiro",	    cRoteiro,GetSx3Cache("RR_ROTEIR","X3_PICTURE") ,'.T.',"" ,'.T.',3,.T.})
	aAdd( aPergs ,{2,"Urbano / Metrop", ,aOpc,100  ,'.T.',.T.})
	aAdd( aPergs ,{1,"Matricula de",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula ate",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Meio Transporte",cMeioTr	,GetSx3Cache("RN_COD","X3_PICTURE") ,'.T.',"SRN" ,'.T.',50,.T.})

	aAdd( aPergs ,{1,"Num Pedido De",	    cNumPd,"@! 9999999999",'.T.',"" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Num Pedido Ate",	  cNumPate,"@! 9999999999",'.T.',"" ,'.T.',50,.F.})

	aAdd( aPergs ,{2,"Tipo","T",aTipos,100  ,'.T.',.T.})

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
	Private cTipo := alltrim(aRetOpc[6])
	Private cMat1 := alltrim(aRetOpc[7])
	Private cMat2 := alltrim(aRetOpc[8])
	Private cMeioTra := alltrim(aRetOpc[9])


	Private cPedDe  := alltrim(aRetOpc[10])
	Private cPedAte := alltrim(aRetOpc[11])

	Private cTipoDis := alltrim(aRetOpc[12])


	Private cArqOut   := alltrim(aRetOpc[4])+"\"
	Private lErrorImp := .F.


	ProcINI(aRetOpc)


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
	cQuery1 += " AND RCH_FILIAL BETWEEN '"+ xfilial("RCH",cFil1) +"' AND '"+ xfilial("RCH",cFil2) +"'
	cQuery1 += " AND RCH_MES = '"+ SUBSTR(cPeri1,1,2) +"'
	cQuery1 += " AND RCH_ANO = '"+ SUBSTR(cPeri1,3,4) +"'
	cQuery1 += " AND D_E_L_E_T_=''
	IF SELECT("TCOMP") > 0
		TCOMP->(DBCLOSEAREA())
	ENDIF
	TcQuery cQuery1 New Alias TCOMP



	WHILE !TCOMP->(EOF())
		IF cTipo == "Metropolitano"

			IF TCOMP->RCH_PERSEL == '1' // ATIVO

				// FAZER SELECT NA SR0
				cQuery := " SELECT R0_FILIAL , R0_MAT ,R0_QDIAINF,RA_MAT ,RA_YMATANT, RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP,SUM(R0_DIASPRO) AS R0_DIASPRO,SUM(R0_VALCAL) AS R0_VALCAL "
				cQuery += " FROM "+RetSqlName("SR0")+" SR0, "+RetSqlName("SRA")+" SRA  "
				cQuery += " WHERE  SR0.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' '  "
				cQuery += " AND    R0_FILIAL = '"+ xfilial("SR0",ALLTRIM(TCOMP->RCH_FILIAL)+"0101" )+"'
				cQuery += " AND    R0_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
				cQuery += " AND    RA_FILIAL = R0_FILIAL
				cQuery += " AND    RA_MAT = R0_MAT
				cQuery += " AND    R0_CODIGO = '"+cMeioTra+"'
				cQuery += " AND    R0_PERIOD = '"+ALLTRIM(TCOMP->RCH_PER)+"'
				// TIPO VALE TRANSPORTE
				cQuery += " AND    R0_TPVALE = '0'
				// SO ATIVOS
				cQuery += " AND    RA_SITFOLH <> 'D'
				// pedido
				if alltrim(cPedDe) + alltrim(cPedAte) <> ""
					cQuery += " AND    R0_NROPED BETWEEN '"+ cPedDe +"' and '"+ cPedAte +"'
				endif
				If cTipoDis=="D"
					cQuery += " AND R0_YDISSID = 'S'"
				ElseIf cTipoDis=="N"
					cQuery += " AND R0_YDISSID <> 'S'"
				EndIf
				cQuery += " GROUP BY  R0_FILIAL , R0_MAT ,R0_QDIAINF,RA_MAT , RA_YMATANT , RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP
				cQuery += " ORDER BY R0_FILIAL , R0_MAT "

				IF SELECT("TGPE") > 0
					TGPE->(DBCLOSEAREA())
				ENDIF
				TcQuery cQuery New Alias TGPE

				//Cria Arquivo de saida
				nHdl := fCreate(cArqOut+"CadasMetropolitano_"+TGPE->R0_FILIAL+'.txt')

				// Criando arqui de pedido
				nHd2 := fCreate(cArqOut+"PedidoMetropolitano_"+TGPE->R0_FILIAL+'.txt')

				If nHdl == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif

				If nHd2 == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif


				// verificar todos os funcionários calculados

				nCautP := 0
				while !TGPE->(eof())
					nCautP ++
					cTexto := ""
					cTexPd := ""
					/*
					cadastro
					*/
					// codcliente
					if TGPE->R0_FILIAL == "010101"
						cTexto += PADr("30126",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexto += PADr("33159",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexto += PADr("64015",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexto += PADr("70043",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexto += PADr("94915",5,"")
						cTexto += " "
					ENDIF

					//matricula
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexto += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexto += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexto += " "
					//BRANCO
					cTexto += PADr("",5,"")
					cTexto += " "
					//NOME
					cTexto += PADr(TGPE->RA_NOME,50,"")
					cTexto += " "
					//APELIDO
					cTexto += PADr(TGPE->RA_NOME,20,"")
					cTexto += " "
					//DATA NASCIMENTO
					cTexto += PADr(DTOC(STOD(TGPE->RA_NASC)),10,"")
					cTexto += " "
					//TELEFONE
					cTexto += PADr(TGPE->RA_TELEFON,20,"")
					cTexto += " "
					//CPF
					cTexto += PADr(substr(TGPE->RA_CIC,1,3)+"."+substr(TGPE->RA_CIC,4,3)+"."+substr(TGPE->RA_CIC,7,3)+"-"+substr(TGPE->RA_CIC,10,2),14 ,"")
					cTexto += " "
					//RG
					cTexto += PADr(TGPE->RA_RG,20,"")
					cTexto += " "
					//EMISSOR RG
					cTexto += PADr(TGPE->RA_ORGEMRG,20,"")
					cTexto += " "
					//ENDEREÇO
					cTexto += PADr(TGPE->RA_ENDEREC,80,"")
					cTexto += " "
					//BAIRRO
					cTexto += PADr(TGPE->RA_BAIRRO,30,"")
					cTexto += " "
					//CEP
					cTexto += PADr(substr(TGPE->RA_CEP,1,5)+"-"+substr(TGPE->RA_CEP,6,3),9,"")
					cTexto += " "
					//CIDADE
					cTexto += PADr(TGPE->RA_MUNNASC,50,"")
					cTexto += " "
					//ESTADO
					cTexto += PADr(TGPE->RA_ESTADO,2,"")
					cTexto += " "
					//CARGO
					cTexto += PADr(POSICIONE("SRJ",1,XFILIAL("SRJ",TGPE->R0_FILIAL)+TGPE->RA_CODFUNC,"RJ_DESC"),20,"")
					cTexto += " "
					//NOME MAE
					cTexto += PADr(TGPE->RA_MAE,40,"")
					cTexto += " "
					//CTPS
					cTexto += PADr(TGPE->RA_NUMCP,13,"")
					cTexto += " "
					//CART ESTUDANTE
					cTexto += PADr("",10,"")
					cTexto += " "
					// DEPARTAMENTO
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3,"")
					cTexto += " "
					// DOMINGO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEGUNDA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// TERÇA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUARTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUINTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEXTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SABADO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					//QUANTIDADE DIARIO
					cTexto += PADL(CVALTOCHAR(TGPE->R0_QDIAINF),3,"0")
					cTexto += " "
					//QUANTIDADE MENSAIS
					cTexto += PADL(CVALTOCHAR(TGPE->R0_DIASPRO * TGPE->R0_QDIAINF),3 ,"0")
					cTexto += " "
					//TIPO PEDE
					cTexto += PADr('M',1 ,"")
					cTexto += " "
					//Quantidade Vale Letra C
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra D
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra E
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra F
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra G
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra H
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra I
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra J
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra M
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra S
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale METROFOR
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Nome departamento
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50,"")
					cTexto += " "
					//CC
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3 ,"")
					cTexto += " "
					//NOME CC
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50,"")
					cTexto += " "
					//SALARIO
					cTexto += PADr('',10 ,"")


					cTexto += CRLF
					fWrite( nHdl, cTexto )

					/*
					pedido
					*/

					// codcliente
					if TGPE->R0_FILIAL == "010101"
						cTexPd += PADr("30126",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexPd += PADr("33159",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexPd += PADr("64015",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexPd += PADr("70043",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexPd += PADr("94915",5,"")
						cTexPd += " "
					ENDIF

					// data pede
					cTexPd += PADr(DTOC(DDATABASE),10,"")
					cTexPd += " "
					// matricula
					//cTexPd += PADL(TGPE->RA_MAT,8,"0")
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexPd += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexPd += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexPd += " "
					// DIAS
					cTexPd += PADL(TGPE->R0_DIASPRO,3,"0")
					cTexPd += " "
					// NUMERO DE VALES DIA
					cTexPd += PADL(TGPE->R0_QDIAINF,3,"0")
					cTexPd += " "
					// TOTAL DE VALES
					cTexPd += PADL(alltrim(transform(TGPE->R0_VALCAL,"@e 999.99")),7,"0")
					cTexPd += " "
					// CATEGO PEDIDO
					cTexPd += PADR('2',1,"0")
					cTexPd += " "
					// sec
					cTexPd += PADL(CVALTOCHAR(nCautP),5,"0")

					cTexPd += CRLF

					fWrite( nHd2, cTexPd )

					TGPE->(DBSKIP())
				enddo
				//FINALISA CADASTRO METROPOLE
				fClose(nHdl)
				//FINALISA PEDIDO METROPOLE
				fClose(nHd2)

			ELSEIF  RCH_PERSEL == '2' // FECHADO

				// FAZER SELECT NA RG2
				cQuery := " SELECT RG2_FILIAL [R0_FILIAL] , RG2_MAT [R0_MAT], RG2_VTDUTE [R0_QDIAINF],RA_MAT,RA_YMATANT,RA_NOME,RA_NASC,RA_TELEFON,RA_CIC,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP,SUM(RG2_DIAPRO) AS R0_DIASPRO, SUM(RG2_VALCAL) AS R0_VALCAL "
				cQuery += " FROM "+RetSqlName("RG2")+" RG2, "+RetSqlName("SRA")+" SRA  "
				cQuery += " WHERE  RG2.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' "
				cQuery += " AND    SUBSTRING(RG2_FILIAL,1,2) = '"+ xfilial("RG2",TCOMP->RCH_FILIAL) +"'
				cQuery += " AND    RG2_ROTEIR = '"+TCOMP->RCH_ROTEIR+"'
				cQuery += " AND    RG2_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
				cQuery += " AND    RA_FILIAL = RG2_FILIAL
				cQuery += " AND    RA_MAT = RG2_MAT
				cQuery += " AND    RG2_CODIGO = '"+cMeioTra+"'
				cQuery += " AND    RG2_PERIOD = '"+ALLTRIM(TCOMP->RCH_PER)+"'
				// TIPO VALE TRANSPORTE
				cQuery += " AND    RG2_TPVALE = '0'
				// SO ATIVOS
				cQuery += " AND    RA_SITFOLH <> 'D'
				// pedido
				if alltrim(cPedDe) + alltrim(cPedAte) <> ""
					cQuery += " AND    RG2_NROPED BETWEEN '"+ cPedDe +"' and '"+ cPedAte +"'
				endif
				If cTipoDis=="D"
					cQuery += " AND RG2_YDISSI = 'S'"
				ElseIf cTipoDis=="N"
					cQuery += " AND RG2_YDISSI <> 'S'"
				EndIf
				cQuery += " GROUP BY  RG2_FILIAL , RG2_MAT ,RG2_VTDUTE,RA_MAT,RA_YMATANT,RA_NOME,RA_NASC,RA_TELEFON,RA_CIC,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP
				cQuery += " ORDER BY RG2_FILIAL , RG2_MAT "

				IF SELECT("TGPE") > 0
					TGPE->(DBCLOSEAREA())
				ENDIF
				TcQuery cQuery New Alias TGPE

				//Cria Arquivo de saida
				nHdl := fCreate(cArqOut+"CadasMetropolitano_"+TGPE->R0_FILIAL+'.txt')

				// Criando arqui de pedido
				nHd2 := fCreate(cArqOut+"PedidoMetropolitano_"+TGPE->R0_FILIAL+'.txt')

				If nHdl == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif

				If nHd2 == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif


				// verificar todos os funcionários calculados
				nCautP := 0
				while !TGPE->(eof())
					nCautP ++
					cTexto := ""
					cTexPd := ""

					// codcliente
					if TGPE->R0_FILIAL == "010101"
						cTexto += PADr("30126",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexto += PADr("33159",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexto += PADr("64015",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexto += PADr("70043",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexto += PADr("94915",5,"")
						cTexto += " "
					ENDIF

					//matricula
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexto += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexto += PADL(TGPE->RA_MAT,8,"0")
					endif
					//cTexto += PADL(TGPE->RA_MAT,8,"0")
					cTexto += " "
					//BRANCO
					cTexto += PADr("",5,"")
					cTexto += " "
					//NOME
					cTexto += PADr(TGPE->RA_NOME,50,"")
					cTexto += " "
					//APELIDO
					cTexto += PADr(TGPE->RA_NOME,20,"")
					cTexto += " "
					//DATA NASCIMENTO
					cTexto += PADr(DTOC(STOD(TGPE->RA_NASC)),10,"")
					cTexto += " "
					//TELEFONE
					cTexto += PADr(TGPE->RA_TELEFON,20,"")
					cTexto += " "
					//CPF
					cTexto += PADr(substr(TGPE->RA_CIC,1,3)+"."+substr(TGPE->RA_CIC,4,3)+"."+substr(TGPE->RA_CIC,7,3)+"-"+substr(TGPE->RA_CIC,10,2),14 ,"")
					cTexto += " "
					//RG
					cTexto += PADr(TGPE->RA_RG,20,"")
					cTexto += " "
					//EMISSOR RG
					cTexto += PADr(TGPE->RA_ORGEMRG,20,"")
					cTexto += " "
					//ENDEREÇO
					cTexto += PADr(TGPE->RA_ENDEREC,80,"")
					cTexto += " "
					//BAIRRO
					cTexto += PADr(TGPE->RA_BAIRRO,30,"")
					cTexto += " "
					//CEP
					cTexto += PADr(substr(TGPE->RA_CEP,1,5)+"-"+substr(TGPE->RA_CEP,6,3),9,"")
					cTexto += " "
					//CIDADE
					cTexto += PADr(TGPE->RA_MUNNASC,50,"")
					cTexto += " "
					//ESTADO
					cTexto += PADr(TGPE->RA_ESTADO,2,"")
					cTexto += " "
					//CARGO
					cTexto += PADr(POSICIONE("SRJ",1,XFILIAL("SRJ",TGPE->R0_FILIAL)+TGPE->RA_CODFUNC,"RJ_DESC"),20,"")
					cTexto += " "
					//NOME MAE
					cTexto += PADr(TGPE->RA_MAE,40,"")
					cTexto += " "
					//CTPS
					cTexto += PADr(TGPE->RA_NUMCP,13,"")
					cTexto += " "
					//CART ESTUDANTE
					cTexto += PADr("",10,"")
					cTexto += " "
					// DEPARTAMENTO
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3,"")
					cTexto += " "
					// DOMINGO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEGUNDA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// TERÇA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUARTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUINTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEXTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SABADO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					//QUANTIDADE DIARIO
					cTexto += PADL(CVALTOCHAR(TGPE->R0_QDIAINF),3,"0")
					cTexto += " "
					//QUANTIDADE MENSAIS
					cTexto += PADL(CVALTOCHAR(TGPE->R0_DIASPRO * TGPE->R0_QDIAINF),3 ,"0")
					cTexto += " "
					//TIPO PEDE
					cTexto += PADr('M',1 ,"")
					cTexto += " "
					//Quantidade Vale Letra C
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra D
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra E
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra F
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra G
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra H
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra I
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra J
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra M
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale Letra S
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Quantidade Vale METROFOR
					cTexto += PADr('000',3 ,"")
					cTexto += " "
					//Nome departamento
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50,"")
					cTexto += " "
					//CC
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3 ,"")
					cTexto += " "
					//NOME CC
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50,"")
					cTexto += " "
					//SALARIO
					cTexto += PADr('',10 ,"")

					cTexto += CRLF
					fWrite( nHdl, cTexto )

					/*
					pedido
					*/

					// codcliente
					if TGPE->R0_FILIAL == "010101"
						cTexPd += PADr("30126",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexPd += PADr("33159",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexPd += PADr("64015",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexPd += PADr("70043",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexPd += PADr("94915",5,"")
						cTexPd += " "
					ENDIF

					// data pede
					cTexPd += PADr(DTOC(DDATABASE),10,"")
					cTexPd += " "
					// matricula
					//cTexPd += PADL(TGPE->RA_MAT,8,"0")
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexPd += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexPd += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexPd += " "
					// DIAS
					cTexPd += PADL(TGPE->R0_DIASPRO,3,"0")
					cTexPd += " "
					// NUMERO DE VALES DIA
					cTexPd += PADL(TGPE->R0_QDIAINF,3,"0")
					cTexPd += " "
					// TOTAL DE VALES
					cTexPd += PADL(alltrim(transform(TGPE->R0_VALCAL,"@e 999.99")),7,"0")
					cTexPd += " "
					// CATEGO PEDIDO
					cTexPd += PADR('2',1,"0")
					cTexPd += " "
					// sec
					cTexPd += PADL(CVALTOCHAR(nCautP),5,"0")

					cTexPd += CRLF

					fWrite( nHd2, cTexPd )

					TGPE->(DBSKIP())
				enddo

				//FINALISA CADASTRO
				fClose(nHdl)
				//FINALISA PEDIDO
				fClose(nHd2)

			ENDIF

		ELSEIF cTipo == "Urbano"

			IF RCH_PERSEL == '1' // ATIVO

				// FAZER SELECT NA SR0
				cQuery := " SELECT R0_FILIAL , R0_MAT ,R0_QDIAINF,RA_MAT , RA_YMATANT , RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP,SUM(R0_DIASPRO) AS R0_DIASPRO,SUM(R0_VALCAL) AS R0_VALCAL "
				cQuery += " FROM "+RetSqlName("SR0")+" SR0, "+RetSqlName("SRA")+" SRA  "
				cQuery += " WHERE  SR0.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' "
				cQuery += " AND    R0_FILIAL = '"+ xfilial("SR0",ALLTRIM(TCOMP->RCH_FILIAL)+"0101" )+"'
				cQuery += " AND    R0_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
				cQuery += " AND    RA_FILIAL = R0_FILIAL
				cQuery += " AND    RA_MAT = R0_MAT
				cQuery += " AND    R0_CODIGO = '"+cMeioTra+"'
				cQuery += " AND    R0_PERIOD = '"+ALLTRIM(TCOMP->RCH_PER)+"'
				// TIPO VALE TRANSPORTE
				cQuery += " AND    R0_TPVALE = '0'
				// SO ATIVOS
				cQuery += " AND    RA_SITFOLH <> 'D'
				cQuery += " GROUP BY  R0_FILIAL , R0_MAT ,R0_QDIAINF,RA_MAT , RA_YMATANT , RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP
				cQuery += " ORDER BY R0_FILIAL , R0_MAT "

				IF SELECT("TGPE") > 0
					TGPE->(DBCLOSEAREA())
				ENDIF
				TcQuery cQuery New Alias TGPE

				//Cria Arquivo de saida
				nHdl := fCreate(cArqOut+"CadasUrbano_"+TGPE->R0_FILIAL+'.txt')

				// Criando arqui de pedido
				nHd2 := fCreate(cArqOut+"PedidoUrbano_"+TGPE->R0_FILIAL+'.txt')


				If nHdl == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif

				If nHd2 == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif


				// verificar todos os funcionários calculados
				nCautP := 0
				while !TGPE->(eof())
					cTexto := ""
					cTexPd := ""
					nCautP ++
					/*
					cadastro
					*/
					// codcliente

					if TGPE->R0_FILIAL == "010101"
						cTexto += PADr("30126",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexto += PADr("33159",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexto += PADr("64015",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexto += PADr("70043",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexto += PADr("94915",5,"")
						cTexto += " "
					ENDIF
					//matricula
					//cTexto += PADL(TGPE->RA_MAT,8,"0")
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexto += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexto += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexto += " "
					//BRANCO
					cTexto += PADr("",5 ,"")
					cTexto += " "
					//NOME
					cTexto += PADr(TGPE->RA_NOME,50 ,"")
					cTexto += " "
					//APELIDO
					cTexto += PADr(TGPE->RA_NOME,20 ,"")
					cTexto += " "
					//DATA NASCIMENTO
					cTexto += PADr(DTOC(STOD(TGPE->RA_NASC)),10,"")
					cTexto += " "
					//TELEFONE
					cTexto += PADr(TGPE->RA_TELEFON,20,"")
					cTexto += " "
					//CPF
					cTexto += PADr(substr(TGPE->RA_CIC,1,3)+"."+substr(TGPE->RA_CIC,4,3)+"."+substr(TGPE->RA_CIC,7,3)+"-"+substr(TGPE->RA_CIC,10,2),14 ,"")
					cTexto += " "
					//RG
					cTexto += PADr(TGPE->RA_RG,20 ,"")
					cTexto += " "
					//EMISSOR RG
					cTexto += PADr(TGPE->RA_ORGEMRG,20 ,"")
					cTexto += " "
					//ENDEREÇO
					cTexto += PADr(TGPE->RA_ENDEREC,80 ,"")
					cTexto += " "
					//BAIRRO
					cTexto += PADr(TGPE->RA_BAIRRO,30 ,"")
					cTexto += " "
					//CEP
					cTexto += PADr(substr(TGPE->RA_CEP,1,5)+"-"+substr(TGPE->RA_CEP,6,3),9,"")
					cTexto += " "
					//CIDADE
					cTexto += PADr(TGPE->RA_MUNNASC,50 ,"")
					cTexto += " "
					//ESTADO
					cTexto += PADr(TGPE->RA_ESTADO,2 ,"")
					cTexto += " "
					//CARGO
					cTexto += PADr(POSICIONE("SRJ",1,XFILIAL("SRJ",TGPE->R0_FILIAL)+TGPE->RA_CODFUNC,"RJ_DESC"),20,"")
					cTexto += " "
					//NOME MAE
					cTexto += PADr(TGPE->RA_MAE,40 ,"")
					cTexto += " "
					//CTPS
					cTexto += PADr(TGPE->RA_NUMCP,13 ,"")
					cTexto += " "
					//CART ESTUDANTE
					cTexto += PADr("",10,"")
					cTexto += " "
					// DEPARTAMENTO
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3,"")
					cTexto += " "
					// DOMINGO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEGUNDA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// TERÇA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUARTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUINTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEXTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SABADO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					//QUANTIDADE DIARIO
					cTexto += PADL(CVALTOCHAR(TGPE->R0_QDIAINF),3,"0")
					cTexto += " "
					//QUANTIDADE MENSAIS
					cTexto += PADL(CVALTOCHAR(TGPE->R0_DIASPRO * TGPE->R0_QDIAINF),3 ,"0")
					cTexto += " "
					//TIPO PEDE
					cTexto += PADr('M',1 ,"")
					cTexto += " "
					//NOME DEPARTAMETO
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50 ,"")
					cTexto += " "
					//CC
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3,"")
					cTexto += " "
					//NOME CC
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50,"")
					cTexto += " "
					//SALARIO
					cTexto += PADr('',10,"")

					cTexto += CRLF
					fWrite( nHdl, cTexto )

					/*
					pedido
					*/

					// codcliente
					if TGPE->R0_FILIAL == "010101"
						cTexPd += PADr("30126",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexPd += PADr("33159",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexPd += PADr("64015",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexPd += PADr("70043",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexPd += PADr("94915",5,"")
						cTexPd += " "
					ENDIF

					// data pede
					cTexPd += PADr(DTOC(DDATABASE),10,"")
					cTexPd += " "
					// matricula
					//cTexPd += PADL(TGPE->RA_MAT,8,"0")
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexPd += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexPd += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexPd += " "
					// DIAS
					cTexPd += PADL(TGPE->R0_DIASPRO,3,"0")
					cTexPd += " "
					// NUMERO DE VALES DIA
					cTexPd += PADL(TGPE->R0_QDIAINF,3,"0")
					cTexPd += " "
					// TOTAL DE VALES
					cTexPd += PADL(alltrim(transform(TGPE->R0_VALCAL,"@e 999.99")),7,"0")
					cTexPd += " "

					/*
					// CATEGO PEDIDO
					cTexPd += PADR('2',1 + 1,"0")
					*/
					// sec
					cTexPd += PADL(CVALTOCHAR(nCautP),5,"0")


					cTexPd += CRLF

					fWrite( nHd2, cTexPd )

					TGPE->(DBSKIP())
				enddo
				//FINALISA CADASTRO METROPOLE
				fClose(nHdl)
				//FINALISA PEDIDO METROPOLE
				fClose(nHd2)

			ELSEIF  RCH_PERSEL == '2' // FECHADO

				// FAZER SELECT NA RG2
				cQuery := " SELECT RG2_FILIAL [R0_FILIAL] , RG2_MAT [R0_MAT], RG2_VTDUTE [R0_QDIAINF],RA_MAT, RA_YMATANT ,RA_NOME,RA_RG,RA_NASC,RA_TELEFON,RA_CIC,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,RA_MAE,RA_NUMCP,SUM(RG2_DIAPRO) AS R0_DIASPRO, SUM(RG2_VALCAL) AS R0_VALCAL ""
				cQuery += " FROM "+RetSqlName("RG2")+" RG2, "+RetSqlName("SRA")+" SRA  "
				cQuery += " WHERE  RG2.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' "
				cQuery += " AND    SUBSTRING(RG2_FILIAL,1,2) = '"+ xfilial("RG2",TCOMP->RCH_FILIAL) +"'
				cQuery += " AND    RG2_ROTEIR = '"+TCOMP->RCH_ROTEIR+"'
				cQuery += " AND    RG2_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
				cQuery += " AND    RA_FILIAL = RG2_FILIAL
				cQuery += " AND    RA_MAT = RG2_MAT
				cQuery += " AND    RG2_CODIGO = '"+cMeioTra+"'
				cQuery += " AND    RG2_PERIOD = '"+ALLTRIM(TCOMP->RCH_PER)+"'
				// TIPO VALE TRANSPORTE
				cQuery += " AND    RG2_TPVALE = '0'
				// SO ATIVOS
				cQuery += " AND    RA_SITFOLH <> 'D'
				cQuery += " GROUP BY  RG2_FILIAL , RG2_MAT ,RG2_VTDUTE,RA_MAT,RA_YMATANT,RA_NOME,RA_RG,RA_NASC,RA_TELEFON,RA_CIC,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC , RA_MAE,RA_NUMCP
				cQuery += " ORDER BY RG2_FILIAL , RG2_MAT "

				IF SELECT("TGPE") > 0
					TGPE->(DBCLOSEAREA())
				ENDIF
				TcQuery cQuery New Alias TGPE

				//Cria Arquivo de saida
				nHdl := fCreate(cArqOut+"CadasUrbano_"+TGPE->R0_FILIAL+'.txt')

				// Criando arqui de pedido
				nHd2 := fCreate(cArqOut+"PedidoUrbano_"+TGPE->R0_FILIAL+'.txt')

				If nHdl == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif

				If nHd2 == -1
					MsgAlert('O arquivo não pode ser criado! Verifique os parametros.','Atenção!')
					Return
				Endif


				// verificar todos os funcionários calculados
				nCautP := 0
				while !TGPE->(eof())
					cTexto := ""
					cTexPd := ""
					nCautP ++
					/*
					cadastro
					*/

					// codcliente

					if TGPE->R0_FILIAL == "010101"
						cTexto += PADr("30126",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexto += PADr("33159",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexto += PADr("64015",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexto += PADr("70043",5,"")
						cTexto += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexto += PADr("94915",5,"")
						cTexto += " "
					ENDIF
					//matricula
					//cTexto += PADL(TGPE->RA_MAT,8,"0")
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexto += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexto += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexto += " "
					//BRANCO
					cTexto += PADr("",5 ,"")
					cTexto += " "
					//NOME
					cTexto += PADr(TGPE->RA_NOME,50 ,"")
					cTexto += " "
					//APELIDO
					cTexto += PADr(TGPE->RA_NOME,20 ,"")
					cTexto += " "
					//DATA NASCIMENTO
					cTexto += PADr(DTOC(STOD(TGPE->RA_NASC)),10,"")
					cTexto += " "
					//TELEFONE
					cTexto += PADr(TGPE->RA_TELEFON,20,"")
					cTexto += " "
					//CPF
					cTexto += PADr(substr(TGPE->RA_CIC,1,3)+"."+substr(TGPE->RA_CIC,4,3)+"."+substr(TGPE->RA_CIC,7,3)+"-"+substr(TGPE->RA_CIC,10,2),14 ,"")
					cTexto += " "
					//RG
					cTexto += PADr(TGPE->RA_RG,20 ,"")
					cTexto += " "
					//EMISSOR RG
					cTexto += PADr(TGPE->RA_ORGEMRG,20 ,"")
					cTexto += " "
					//ENDEREÇO
					cTexto += PADr(TGPE->RA_ENDEREC,80 ,"")
					cTexto += " "
					//BAIRRO
					cTexto += PADr(TGPE->RA_BAIRRO,30 ,"")
					cTexto += " "
					//CEP
					cTexto += PADr(substr(TGPE->RA_CEP,1,5)+"-"+substr(TGPE->RA_CEP,6,3),9,"")
					cTexto += " "
					//CIDADE
					cTexto += PADr(TGPE->RA_MUNNASC,50 ,"")
					cTexto += " "
					//ESTADO
					cTexto += PADr(TGPE->RA_ESTADO,2 ,"")
					cTexto += " "
					//CARGO
					cTexto += PADr(POSICIONE("SRJ",1,XFILIAL("SRJ",TGPE->R0_FILIAL)+TGPE->RA_CODFUNC,"RJ_DESC"),20,"")
					cTexto += " "
					//NOME MAE
					cTexto += PADr(TGPE->RA_MAE,40 ,"")
					cTexto += " "
					//CTPS
					cTexto += PADr(TGPE->RA_NUMCP,13 ,"")
					cTexto += " "
					//CART ESTUDANTE
					cTexto += PADr("",10,"")
					cTexto += " "
					// DEPARTAMENTO
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3,"")
					cTexto += " "
					// DOMINGO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEGUNDA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// TERÇA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUARTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// QUINTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SEXTA
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					// SABADO
					cTexto += PADr('S',1 ,"")
					cTexto += " "
					//QUANTIDADE DIARIO
					cTexto += PADL(CVALTOCHAR(TGPE->R0_QDIAINF),3,"0")
					cTexto += " "
					//QUANTIDADE MENSAIS
					cTexto += PADL(CVALTOCHAR(TGPE->R0_DIASPRO * TGPE->R0_QDIAINF),3 ,"0")
					cTexto += " "
					//TIPO PEDE
					cTexto += PADr('M',1 ,"")
					cTexto += " "
					//NOME DEPARTAMETO
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50 ,"")
					cTexto += " "
					//CC
					cTexto += PADr(SUBSTR(TGPE->RA_CC,1,3),3,"")
					cTexto += " "
					//NOME CC
					cTexto += PADr(POSICIONE("CTT",1,XFILIAL("CTT",TGPE->R0_FILIAL)+TGPE->RA_CC,"CTT_DESC01"),50,"")
					cTexto += " "
					//SALARIO
					cTexto += PADr('',10,"")

					cTexto += CRLF
					fWrite( nHdl, cTexto )

					/*
					pedido
					*/

					// codcliente
					if TGPE->R0_FILIAL == "010101"
						cTexPd += PADr("30126",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "020101"
						cTexPd += PADr("33159",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "030101"
						cTexPd += PADr("64015",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "040101"
						cTexPd += PADr("70043",5,"")
						cTexPd += " "
					ELSEif TGPE->R0_FILIAL == "050101"
						cTexPd += PADr("94915",5,"")
						cTexPd += " "
					ENDIF

					// data pede
					cTexPd += PADr(DTOC(DDATABASE),10,"")
					cTexPd += " "
					// matricula
					//cTexPd += PADL(TGPE->RA_MAT,8,"0")
					if alltrim(TGPE->RA_YMATANT) <> ""
						cTexPd += PADL(TGPE->RA_YMATANT,8,"0")
					else
						cTexPd += PADL(TGPE->RA_MAT,8,"0")
					endif
					cTexPd += " "
					// DIAS
					cTexPd += PADL(TGPE->R0_DIASPRO,3,"0")
					cTexPd += " "
					// NUMERO DE VALES DIA
					cTexPd += PADL(TGPE->R0_QDIAINF,3,"0")
					cTexPd += " "
					// TOTAL DE VALES
					cTexPd += PADL(alltrim(transform(TGPE->R0_VALCAL,"@e 999.99")),7,"0")
					cTexPd += " "

					/*
					// CATEGO PEDIDO
					cTexPd += PADR('2',1 + 1,"0")
					*/
					// sec
					cTexPd += PADL(CVALTOCHAR(nCautP),5,"0")

					cTexPd += CRLF

					fWrite( nHd2, cTexPd )

					TGPE->(DBSKIP())
				enddo
				//FINALISA CADASTRO METROPOLE
				fClose(nHdl)
				//FINALISA PEDIDO METROPOLE
				fClose(nHd2)

			endif

		endif

		TCOMP->(DBSKIP())
	ENDDO


Return
