#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"
#include "topconn.ch"
#Define CRLF CHR(13)+CHR(10)

user function RSERV014()

	Local aPergs	:= {}
	Local aRetOpc	:= {}
	Local cFilde    := space(6)
	Local cFilate   := space(6)
	Local cPeriod   := space(6)
	Local cDiret    := space(240)
	Local cRoteiro  := space(3)
	Local aOpc      := {"","Cadastro","Pedido"}
	Local aOpc2     := {"","VA","CB"}
	Local aTipos	:= {"T=Todos","D=Dissídio","N=Normal"}
	Local cMat      := space(6)
	Local cMeioTr   := space(2)
	Local cNumPd    := space(10)
	Local cNumPate  := space(10)


	Local cMenComp  := ""

	aAdd( aPergs ,{1,"Filial",	cFilde	,GetSx3Cache("M0_CODFIL","X3_PICTURE") ,'.T.',"SM0" ,'.T.',6,.F.})
	aAdd( aPergs ,{1,"Período",	    cPeriod	,GetSx3Cache("RG2_ANOMES","X3_PICTURE") ,'.T.',"" ,'.T.',6,.T.})
	aAdd( aPergs ,{1,"Diretório",	cDiret	,GetSx3Cache("RA_NOME","X3_PICTURE") ,'.T.',"" ,'.T.',100,.T.})
	aAdd( aPergs ,{2,"Cadastro / Pedido", ,aOpc,100  ,'.T.',.T.})
	aAdd( aPergs ,{2,"VA / CB", ,aOpc2,100  ,'.T.',.T.})
	aAdd( aPergs ,{1,"Matricula de",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula ate",cMat	,GetSx3Cache("RA_MAT","X3_PICTURE") ,'.T.',"SRA" ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cod Beneficio",cMeioTr,GetSx3Cache("RN_COD","X3_PICTURE") ,'.T.',"" ,'.T.',30,.T.})
	aAdd( aPergs ,{1,"Roteiro",	    cRoteiro,GetSx3Cache("RR_ROTEIR","X3_PICTURE") ,'.T.',"" ,'.T.',3,.T.})

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
	Private cPeri1:= alltrim(aRetOpc[2])
	Private cSoli := alltrim(aRetOpc[4])
	Private cTipo := alltrim(aRetOpc[5])
	Private cMat1 := alltrim(aRetOpc[6])
	Private cMat2 := alltrim(aRetOpc[7])
	Private cCodB := alltrim(aRetOpc[8])
	Private cRote := alltrim(aRetOpc[9])

	Private cPedDe  := alltrim(aRetOpc[10])
	Private cPedAte := alltrim(aRetOpc[11])
	Private cTipoDis := alltrim(aRetOpc[12])


	Private cArqOut   := alltrim(aRetOpc[3])
	Private nHandle
	Private lErrorImp := .F.

	//nHandle := MsfCreate(cArqOut+".CSV",0)

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
	Local cCrLf    := Chr(13) + Chr(10)

	//1* verificar se o período informado ´é fechado (RG2) ou aberto (SR0)  RCH_PERSEL = '1'
	cQuery1 := " SELECT *
	cQuery1 += " FROM "+RetSqlName("RCH")+" RCH  "
	cQuery1 += " WHERE RCH_ROTEIR = '"+cRote+"'  "
	cQuery1 += " AND RCH_FILIAL = '"+ xfilial("RCH",cFil1) +"'
	cQuery1 += " AND RCH_MES = '"+ SUBSTR(cPeri1,1,2) +"'
	cQuery1 += " AND RCH_ANO = '"+ SUBSTR(cPeri1,3,4) +"'
	cQuery1 += " AND D_E_L_E_T_=''
	IF SELECT("TCOMP") > 0
		TCOMP->(DBCLOSEAREA())
	ENDIF
	TcQuery cQuery1 New Alias TCOMP



	WHILE !TCOMP->(EOF())
		nHandle := MsfCreate(cArqOut+"_processo"+ TCOMP->RCH_PROCES +".CSV",0)

		IF cSoli == "Cadastro"

			// FAZER SELECT NA SR0
			cQuery := " SELECT *
			cQuery += " FROM "+RetSqlName("SRA")+" SRA  "
			cQuery += " WHERE  SRA.D_E_L_E_T_ = ''  "
			cQuery += " AND    RA_FILIAL = '"+ xfilial("SRA",cFil1)+"'
			cQuery += " AND    RA_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
			// SO ATIVOS
			cQuery += " AND    RA_SITFOLH NOT IN ('D','T')
			cQuery += " ORDER BY RA_FILIAL , RA_MAT "

			IF SELECT("TGPE") > 0
				TGPE->(DBCLOSEAREA())
			ENDIF
			TcQuery cQuery New Alias TGPE

			fWrite(nHandle, "CPF;MATRICULA;NOME COMPLETO;DATA NASCIMENTO" +cCrLf)



			WHILE !TGPE->(EOF())
				fWrite(nHandle, ALLTRIM(TGPE->RA_CIC)+";"+ALLTRIM(TGPE->RA_MAT)+";"+ALLTRIM(TGPE->RA_NOME)+";"+ SUBSTR(TGPE->RA_NASC,7,2)+'/'+ SUBSTR(TGPE->RA_NASC,5,2) +'/'+ SUBSTR(TGPE->RA_NASC,1,4) + cCrLf)
				TGPE->(DBSKIP())
			ENDDO

			fWrite(nHandle, ""+cCrLf)
			fClose(nHandle)

			Return

		ELSEIF cSoli == "Pedido"
			IF cTipo == "VA"
				IF TCOMP->RCH_PERSEL == '1' // ATIVO

					// FAZER SELECT NA SR0
					cQuery := " SELECT R0_FILIAL , R0_MAT ,RA_MAT ,RA_YMATANT, RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,SUM(R0_DIASPRO) AS R0_DIASPRO,SUM(R0_VALCAL) AS R0_VALCAL ,CTT_DESC01 "
					cQuery += " FROM "+RetSqlName("SR0")+" SR0, "+RetSqlName("SRA")+" SRA , "+RetSqlName("CTT")+" CTT  "
					cQuery += " WHERE  SR0.D_E_L_E_T_ = '' AND SRA.D_E_L_E_T_ = '' "
					cQuery += " AND    R0_FILIAL = '"+ xfilial("SR0",cFil1 )+"'
					cQuery += " AND    R0_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
					cQuery += " AND    RA_FILIAL = R0_FILIAL
					cQuery += " AND    RA_MAT = R0_MAT
					cQuery += " AND    R0_CODIGO = '"+cCodB+"'
					cQuery += " AND    SUBSTRING(R0_FILIAL,1,2) = CTT_FILIAL
					cQuery += " AND    RA_CC = CTT_CUSTO
					cQuery += " AND    R0_PERIOD = '"+ALLTRIM(TCOMP->RCH_PER)+"'
					// TIPO VALE Alimentação
					cQuery += " AND    R0_TPVALE = '2'
					// SO ATIVOS
					cQuery += " AND    RA_SITFOLH NOT IN ('D','T')
					// PROCESSO
					cQuery += " AND    RA_PROCES = '"+ TCOMP->RCH_PROCES +"'
					// pedido
					if alltrim(cPedDe) + alltrim(cPedAte) <> ""
						cQuery += " AND    R0_NROPED BETWEEN '"+ cPedDe +"' and '"+ cPedAte +"'
					endif
					If cTipoDis=="D"
						cQuery += " AND R0_YDISSID = 'S'"
					ElseIf cTipoDis=="N"
						cQuery += " AND R0_YDISSID <> 'S'"
					EndIf
					cQuery += " GROUP BY  R0_FILIAL , R0_MAT ,RA_MAT ,RA_YMATANT, RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,CTT_DESC01
					cQuery += " ORDER BY R0_FILIAL , R0_MAT "

					IF SELECT("TGPE") > 0
						TGPE->(DBCLOSEAREA())
					ENDIF
					TcQuery cQuery New Alias TGPE

					fWrite(nHandle, "MATRICULA;NOME COMPLETO;VALOR;REFERENCIA" + cCrLf)

					WHILE !TGPE->(EOF())
						//fWrite(nHandle, ALLTRIM(TGPE->RA_MAT)+";"+ALLTRIM(TGPE->RA_NOME)+";"+"R$ "+ STRTRAN(TRANSFORM(TGPE->R0_VALCAL,"@! 999.99"),".",",") +";"+ ALLTRIM(TGPE->CTT_DESC01)  + cCrLf)
						fWrite(nHandle, IF(ALLTRIM(TGPE->RA_YMATANT)== "",ALLTRIM(TGPE->RA_MAT),ALLTRIM(TGPE->RA_YMATANT))+";"+ALLTRIM(TGPE->RA_NOME)+";"+"R$ "+ STRTRAN(TRANSFORM(TGPE->R0_VALCAL,"@! 999.99"),".",",") +";"+ ALLTRIM(TGPE->CTT_DESC01)  + cCrLf)
						TGPE->(DBSKIP())
					ENDDO

					fWrite(nHandle, ""+cCrLf)
					fClose(nHandle)

				ELSEIF  RCH_PERSEL == '2' // FECHADO

					// FAZER SELECT NA RG2
					cQuery := " SELECT RG2_FILIAL AS R0_FILIAL , RG2_MAT AS R0_MAT ,RA_MAT ,RA_YMATANT,RA_NOME,RA_NASC,RA_TELEFON,RA_CIC,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,SUM(RG2_DIAPRO) AS RG2_DIAPRO, SUM(RG2_VALCAL) AS RG2_VALCAL ,CTT_DESC01 "
					cQuery += " FROM "+RetSqlName("RG2")+" RG2, "+RetSqlName("SRA")+" SRA  , "+RetSqlName("CTT")+" CTT  "
					cQuery += " WHERE  RG2.D_E_L_E_T_ = '' AND SRA.D_E_L_E_T_ = ''  "
					cQuery += " AND    RG2_FILIAL = '"+ xfilial("RG2",cFil1) +"'
					cQuery += " AND    RG2_ROTEIR = '"+TCOMP->RCH_ROTEIR+"'
					cQuery += " AND    RG2_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
					cQuery += " AND    RA_FILIAL = RG2_FILIAL
					cQuery += " AND    RA_MAT = RG2_MAT
					cQuery += " AND    RG2_CODIGO = '"+cCodB+"'
					cQuery += " AND    SUBSTRING(RG2_FILIAL,1,2) = CTT_FILIAL
					cQuery += " AND    RA_CC = CTT_CUSTO
					cQuery += " AND    RG2_PERIOD = '"+ALLTRIM(TCOMP->RCH_PER)+"'
					// TIPO VALE Alimentação
					cQuery += " AND    RG2_TPVALE = '2'
					// SO ATIVOS
					cQuery += " AND    RA_SITFOLH NOT IN ('D','T')
					//PROCESSO
					cQuery += " AND    RA_PROCES = '"+ TCOMP->RCH_PROCES +"'
					//PEDIDO
					if alltrim(cPedDe) + alltrim(cPedAte) <> ""
						cQuery += " AND    RG2_NROPED BETWEEN '"+ cPedDe +"' and '"+ cPedAte +"'
					endif
					If cTipoDis=="D"
						cQuery += " AND RG2_YDISSI = 'S'"
					ElseIf cTipoDis=="N"
						cQuery += " AND RG2_YDISSI <> 'S'"
					EndIf
					cQuery += " GROUP BY  RG2_FILIAL , RG2_MAT ,RA_MAT,RA_YMATANT,RA_NOME,RA_NASC,RA_TELEFON,RA_CIC,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,CTT_DESC01
					cQuery += " ORDER BY RG2_FILIAL , RG2_MAT "

					IF SELECT("TGPE") > 0
						TGPE->(DBCLOSEAREA())
					ENDIF
					TcQuery cQuery New Alias TGPE

					fWrite(nHandle, "MATRICULA;NOME COMPLETO;VALOR;REFERENCIA" + cCrLf)

					WHILE !TGPE->(EOF())
						//fWrite(nHandle, ALLTRIM(TGPE->RA_MAT)+";"+ALLTRIM(TGPE->RA_NOME)+";"+"R$ "+ STRTRAN(TRANSFORM(TGPE->RG2_VALCAL,"@! 999.99"),".",",") +";"+ ALLTRIM(TGPE->CTT_DESC01) + cCrLf)
						fWrite(nHandle, IF(ALLTRIM(TGPE->RA_YMATANT)== "",ALLTRIM(TGPE->RA_MAT),ALLTRIM(TGPE->RA_YMATANT))+";"+ALLTRIM(TGPE->RA_NOME)+";"+"R$ "+ STRTRAN(TRANSFORM(TGPE->RG2_VALCAL,"@! 999.99"),".",",") +";"+ ALLTRIM(TGPE->CTT_DESC01) + cCrLf)

						TGPE->(DBSKIP())
					ENDDO

					fWrite(nHandle, ""+cCrLf)
					fClose(nHandle)

				ENDIF
			ELSEIF cTipo == "CB"


				// FAZER SELECT NA SR0
				cQuery := " SELECT RIQ_FILIAL , RIQ_MAT ,RA_MAT ,RA_YMATANT, RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,SUM(RIQ_DIAPRO) AS RIQ_DIAPRO,SUM(RIQ_VALBEN) AS RIQ_VALBEN ,CTT_DESC01 "
				cQuery += " FROM "+RetSqlName("RIQ")+" RIQ, "+RetSqlName("SRA")+" SRA  , "+RetSqlName("CTT")+" CTT  "
				cQuery += " WHERE  RIQ.D_E_L_E_T_ = ''  AND SRA.D_E_L_E_T_ = '' "
				cQuery += " AND    RIQ_FILIAL = '"+ xfilial("RIQ",cFil1 )+"'
				cQuery += " AND    RIQ_MAT BETWEEN '"+ cMat1 +"' and '"+ cMat2 +"'
				cQuery += " AND    RA_FILIAL = RIQ_FILIAL
				cQuery += " AND    RA_MAT = RIQ_MAT
				cQuery += " AND    RIQ_COD = '"+cCodB+"'
				cQuery += " AND    SUBSTRING(RIQ_FILIAL,1,2) = CTT_FILIAL
				cQuery += " AND    RA_CC = CTT_CUSTO
				cQuery += " AND    RIQ_PERIOD = '"+substr(cPeri1,3,4)+substr(cPeri1,1,2)+"'
				// TIPO VALE Alimentação
				cQuery += " AND    RIQ_TPBENE = '81'
				// SO ATIVOS
				cQuery += " AND    RA_SITFOLH NOT IN ('D','T')
				// PROCESSO
				cQuery += " AND    RA_PROCES = '"+ TCOMP->RCH_PROCES +"'
				cQuery += " GROUP BY  RIQ_FILIAL , RIQ_MAT ,RA_MAT ,RA_YMATANT, RA_NOME, RA_NASC,RA_TELEFON,RA_CIC,RA_RG,RA_ORGEMRG,RA_ENDEREC,RA_BAIRRO,RA_CEP,RA_MUNNASC,RA_ESTADO,RA_CODFUNC,RA_CC,CTT_DESC01
				cQuery += " ORDER BY RIQ_FILIAL , RIQ_MAT "

				IF SELECT("TGPE") > 0
					TGPE->(DBCLOSEAREA())
				ENDIF
				TcQuery cQuery New Alias TGPE

				fWrite(nHandle, "MATRICULA;NOME COMPLETO;VALOR;REFERENCIA" + cCrLf)

				WHILE !TGPE->(EOF())
					//fWrite(nHandle, ALLTRIM(TGPE->RA_MAT)+";"+ALLTRIM(TGPE->RA_NOME)+";"+"R$ "+ STRTRAN(TRANSFORM(TGPE->RIQ_VALBEN,"@! 999.99"),".",",") +";"+ ALLTRIM(TGPE->CTT_DESC01) + cCrLf)
					fWrite(nHandle, IF(ALLTRIM(TGPE->RA_YMATANT)== "",ALLTRIM(TGPE->RA_MAT),ALLTRIM(TGPE->RA_YMATANT))+";"+ALLTRIM(TGPE->RA_NOME)+";"+"R$ "+ STRTRAN(TRANSFORM(TGPE->RIQ_VALBEN,"@! 999.99"),".",",") +";"+ ALLTRIM(TGPE->CTT_DESC01) + cCrLf)

					TGPE->(DBSKIP())
				ENDDO

				fWrite(nHandle, ""+cCrLf)
				fClose(nHandle)

			ENDIF

		endif

		TCOMP->(DBSKIP())
	ENDDO

	// finaliza o arquivo

	//fWrite(nHandle, ""+cCrLf)
	//fClose(nHandle)


Return
