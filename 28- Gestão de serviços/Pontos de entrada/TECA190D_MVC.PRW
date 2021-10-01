#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDEF.ch'
#include "topconn.ch"
//*****************************************************************************
/*/{Protheus.doc} TECA190D
Ponto de Entrada para atualizar os dados do atendente no modulo SIGAGPE
Ponto de entrada padrão da rotina MVC TECA190D
@author edlardo neves - mconsult
@since 12/04/2021
@version 1.0
@return lRet - Lógico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=501478324
/*/
//*****************************************************************************
User Function TECA190D()
	Local aParam := PARAMIXB
	Local xRet   := .T.
    
    //Funcao para realizar atualização dados funcionario no modulo SIGAGPE
    xRet := YTECA190D(aParam)


Return xRet


Static Function YTECA190D(aParam)
	Local xRet   := .T.
    Local oObj   := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local lIsGrid  := .F.
	Local aAreaAtual := GetArea()

    If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]
		lIsGrid    := "GRID" $ oObj:ClassName()
		cClasse := oObj:ClassName()
		If lIsGrid
			nQtdLinhas	:= oObj:GetQtdLine()
			nLinha		:= oObj:nLine
		EndIf

		If cIdPonto == "FORMPOS" 
            If FwIsInCallStack("GRAVAALOC2")
                RSERV016()
            EndIf         
		EndIf

	EndIf

	RestArea(aAreaAtual)

Return xRet

//Copia da rotina de transferências CC e turno, RSERV016.prw
Static function RSERV016()
    Local oModel 	:= FwModelActive()
    Local oMdlDTA 	:= oModel:GetModel("DTAMASTER")
	Local aOpcao    := {"1=Ambos","2=C.Custo","3=Turno"}
	Local aPergs	:= {}
	Local cFilFuc   := SRA->RA_FILIAL
    Local cMatFuc   := SRA->RA_MAT
    Local dPerIni   := oMdlDTA:GetValue("DTA_DTINI")
    Local dPerFim   := oMdlDTA:GetValue("DTA_DTFIM")
    Local aMvPar    := {}
	Local nMv       := 0

    Private aRetOpc := {}

    //SALVA AS PERGUNTAS POSICIONADAS
	For nMv := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
	Next nMv
	
	aAdd( aPergs ,{1,"Filial de"	 	, cFilFuc ,"@!",'.T.','SM0','.F.',60,.T.})
	aAdd( aPergs ,{1,"Filial até"	 	, cFilFuc ,"@!",'.T.','SM0','.F.',60,.T.})
	aAdd( aPergs ,{1,"Matricula de" 	, cMatFuc ,"@!",'.T.','SRA','.F.',60,.T.})
	aAdd( aPergs ,{1,"Matricula até" 	, cMatFuc ,"@!",'.T.','SRA','.F.',60,.T.})
	aAdd( aPergs ,{1,"Periodo inic. de" , dPerIni ,"@!",'.T.',''   ,'.F.',60,.T.})
	aAdd( aPergs ,{1,"Periodo inic. até", dPerFim ,"@!",'.T.',''   ,'.F.',60,.T.})
	aAdd( aPergs ,{2,"Processa?"        ,"1"      , aOpcao ,65,"!Empty"     ,.T.})

	If ParamBox(aPergs,"Processamento transferências", aRetOpc)//ParamBox(aPergs,"Processamento transferências", aRetOpc,,,,,,,"_RSERV16",.T.,.T.)
		fGeraTransf()		
	Endif

    //RESTAURA AS PERGUNTAS
	For nMv := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv

Return


Static Function fGeraTransf()
	Private aDados	:= {}
	Private aTurnos	:= {}

	private cEol := chr(13)+chr(10)

	//Centro de Custo
	cQuery:= "SELECT RA_FILIAL,RA_CC,TFL_YCC,RA_MAT,RA_NOME,ABS_LOCAL,ABS_DESCRI,COUNT(*) QTDDIAS,MIN(ABB_DTINI) DATAFIM,MAX(ABB_DTFIM) ABB_DTFIM FROM "+RetSqlName("ABB")+" ABB "+cEol
	cQuery+= "INNER JOIN "+RetSqlName("ABQ")+" ABQ									"+cEol
	cQuery+= "ON ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4)								"+cEol
	cQuery+= "AND ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15)							"+cEol
	cQuery+= "AND ABQ_ORIGEM = 'CN9'						                    	"+cEol
	cQuery+= "AND ABQ_ITEM = RIGHT('000000'+SUBSTRING(ABB_IDCFAL,16,6) ,6)			"+cEol //Inclusão do item para relacionar a ABQ
	cQuery+= "INNER JOIN "+RetSqlName("TFL")+" TFL                                  "+cEol
	cQuery+= "ON TFL_FILIAL = ABB_FILIAL                                           	"+cEol
	cQuery+= "AND  TFL_CONTRT = SUBSTRING(ABB_IDCFAL,1,15)                         	"+cEol
	cQuery+= "AND  TFL_LOCAL =ABQ_LOCAL                                             "+cEol
	cQuery+= "INNER JOIN "+RetSqlName("SRA")+" SRA									"+cEol
	cQuery+= "ON RA_FILIAL = ABB_FILIAL                                            	"+cEol
	cQuery+= "AND RA_MAT = SUBSTRING(ABB_CODTEC,7,6)                               	"+cEol
	cQuery+= "INNER JOIN "+RetSqlName("ABS")+" ABS									"+cEol
	cQuery+= "ON ABS_LOCAL = ABQ_LOCAL	AND ABS_FILIAL = '"+XFILIAL("ABS")+"'   	"+cEol
	cQuery+= "INNER JOIN "+RetSqlName("TFF")+" TFF									"+cEol
	cQuery+= "ON TFF_FILIAL = TFL_FILIAL AND TFF_CODPAI = TFL_CODIGO AND TFF_COD = ABQ_CODTFF "+cEol
	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' '                                           	"+cEol
	cQuery+= "AND ABS.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABQ.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND TFL.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND TFF.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND SRA.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABB_FILIAL BETWEEN '"+aRetOpc[1]+"' AND '"+aRetOpc[2]+"'			"+cEol
	cQuery+= "AND RA_MAT BETWEEN '"+aRetOpc[3]+"' AND '"+aRetOpc[4]+"'				"+cEol
	cQuery+= "AND ABB_DTINI >= '"+dTos(aRetOpc[5])+"' "+cEol
	cQuery+= "AND ABB_DTINI <= '"+dTos(aRetOpc[6])+"' "+cEol
	cQuery+= "AND ABB_HRINI BETWEEN '00:00' AND '24:00'  "+cEol
	cQuery+= "AND ABB_HRFIM BETWEEN '00:00' AND '24:00'  "+cEol
	cQuery+= "AND RA_CC <> TFL_YCC                                                 	"+cEol
	cQuery+= "AND RA_SITFOLH <> 'D'                                                	"+cEol
	cQuery+= "GROUP BY RA_FILIAL,RA_CC,TFL_YCC,RA_MAT,RA_NOME,ABS_LOCAL,ABS_DESCRI  "+cEol
	cQuery+= "ORDER BY RA_FILIAL,RA_MAT                                             "+cEol
	tcQuery cQuery new Alias TQ0016

	while TQ0016->(!Eof())
		SRA->(dbSetOrder(1))
		SRA->(dbSeek(TQ0016->RA_FILIAL+TQ0016->RA_MAT))
		If empty(dtos(SRA->RA_YDTPROC)) .or. aRetOpc[6] > SRA->RA_YDTPROC  
			//Data do processamento
			aadd(aDados,{;
			TQ0016->RA_CC ,; 		//1
			TQ0016->TFL_YCC ,;		//2
			TQ0016->RA_MAT ,;		//3	
			TQ0016->RA_NOME ,;		//4
			TQ0016->ABS_LOCAL ,;	//5	
			TQ0016->ABS_DESCRI ,;	//6
			TQ0016->QTDDIAS ,;		//7
			TQ0016->RA_FILIAL ,;	//8
			TQ0016->DATAFIM ;		//9
			})
		Endif 
		TQ0016->(dbSkip())
	Enddo
	TQ0016->(dbCloseArea())

	//Mudança de turno
	cQuery:= "SELECT 'ABQ' TIPO,RA_FILIAL,RA_TNOTRAB,ABQ_TURNO TURNO,RA_MAT,RA_NOME,AA1_FUNCAO,ABS_LOCAL,ABS_DESCRI,MIN(ABB_DTINI) DATAFIM,' ' PERFIM FROM "+RetSqlName("ABB")+" ABB "+cEol

	cQuery+= "INNER JOIN "+RetSqlName("ABQ")+" ABQ									"+cEol
	cQuery+= "ON ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4)								"+cEol
	cQuery+= "AND ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15)							"+cEol
	cQuery+= "AND ABQ_ORIGEM = 'CN9'                                                "+cEol
	cQuery+= "AND ABQ_ITEM = RIGHT('000000'+SUBSTRING(ABB_IDCFAL,16,6) ,6) 							"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("TFL")+" TFL                                  "+cEol
	cQuery+= "ON  TFL_FILIAL  = ABB_FILIAL                                         	"+cEol
	cQuery+= "AND TFL_CONTRT  = SUBSTRING(ABB_IDCFAL,1,15)                         	"+cEol
	cQuery+= "AND TFL_LOCAL  = ABQ_LOCAL                                           	"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("TFF")+" TFF 									"+cEol
	cQuery+= "ON TFF_FILIAL = TFL_FILIAL											"+cEol
	cQuery+= "AND TFF_CODPAI = TFL_CODIGO 											"+cEol
	cQuery+= "AND ABQ_CODTFF = TFF_COD												"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("AA1")+" AA1									"+cEol
	cQuery+= "ON AA1_FILIAL = ABB_FILIAL 											"+cEol
	cQuery+= "AND AA1_CODTEC = ABB_CODTEC											" +cEol

	cQuery+= "INNER JOIN "+RetSqlName("SRA")+" SRA									"+cEol
	cQuery+= "ON RA_FILIAL = ABB_FILIAL                                            	"+cEol
	cQuery+= "AND RA_MAT = SUBSTRING(ABB_CODTEC,7,6)                               	"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("ABS")+" ABS									"+cEol
	cQuery+= "ON ABS_LOCAL = ABQ_LOCAL AND ABS_FILIAL = '"+XFILIAL("ABS")+"'	"+cEol

	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' '                                           	"+cEol
	cQuery+= "AND ABQ.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABS.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND AA1.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABQ.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND TFL.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND SRA.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABB_FILIAL BETWEEN '"+aRetOpc[1]+"' AND '"+aRetOpc[2]+"'			"+cEol
	cQuery+= "AND RA_MAT BETWEEN '"+aRetOpc[3]+"' AND '"+aRetOpc[4]+"'				"+cEol
	cQuery+= "AND ABB_DTINI >= '"+dTos(aRetOpc[5])+"' "+cEol
	cQuery+= "AND ABB_DTINI <= '"+dTos(aRetOpc[6])+"' "+cEol
	cQuery+= "AND ABB_HRINI BETWEEN '00:00' AND '24:00'  "+cEol
	cQuery+= "AND ABB_HRFIM BETWEEN '00:00' AND '24:00'  "+cEol
	cQuery+= "AND TFF_ESCALA= ' '													"+cEol
	cQuery+= "AND ABQ_TURNO <> ' '  	                                         	"+cEol
	cQuery+= "AND RA_SITFOLH <> 'D'                                                	"+cEol
	cQuery+= "GROUP BY RA_FILIAL,RA_TNOTRAB,ABQ_TURNO,RA_MAT,RA_NOME,AA1_FUNCAO,ABS_LOCAL,ABS_DESCRI,ABQ_PERINI "+cEol

	cQuery+= "UNION ALL "+cEol

	cQuery+= "SELECT 'ESCALA' TIPO,RA_FILIAL,RA_TNOTRAB,TDX_TURNO TURNO,RA_MAT,RA_NOME,AA1_FUNCAO,ABS_LOCAL,ABS_DESCRI,MIN(ABB_DTINI) DATAFIM,TFF_PERFIM PERFIM FROM "+RetSqlName("ABB")+" ABB "+cEol

	cQuery+= "INNER JOIN "+RetSqlName("ABQ")+" ABQ									"+cEol
	cQuery+= "ON ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4)								"+cEol
	cQuery+= "AND ABQ_ORIGEM = 'CN9'                                                "+cEol
	cQuery+= "AND ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15)							"+cEol
	cQuery+= "AND ABQ_ITEM = RIGHT('000000'+SUBSTRING(ABB_IDCFAL,16,6) ,6) 							"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("TFL")+" TFL                                  "+cEol
	cQuery+= "ON  TFL_FILIAL = ABB_FILIAL                                           	"+cEol
	cQuery+= "AND TFL_CONTRT = SUBSTRING(ABB_IDCFAL,1,15)                          	"+cEol
	cQuery+= "AND TFL_LOCAL  = ABQ_LOCAL                                           	"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("TFF")+" TFF 									"+cEol
	cQuery+= "ON TFF_FILIAL = TFL_FILIAL											"+cEol
	cQuery+= "AND TFF_CODPAI = TFL_CODIGO 											"+cEol
	cQuery+= "AND TFF_COD	= ABQ_CODTFF 										"+cEol
	cQuery+= "AND TFF_ESCALA<>' ' 													"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("TDX")+" TDX 									"+cEol
	cQuery+= "ON TDX_FILIAL = TFF_FILIAL											"+cEol
	cQuery+= "AND TDX_CODTDW = TFF_ESCALA 											"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("AA1")+" AA1									"+cEol
	cQuery+= "ON AA1_FILIAL = ABB_FILIAL 											"+cEol
	cQuery+= "AND AA1_CODTEC = ABB_CODTEC											"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("SRA")+" SRA									"+cEol
	cQuery+= "ON RA_FILIAL = ABB_FILIAL                                            	"+cEol
	cQuery+= "AND RA_MAT = SUBSTRING(ABB_CODTEC,7,6)                               	"+cEol

	cQuery+= "INNER JOIN "+RetSqlName("ABS")+" ABS									"+cEol
	cQuery+= "ON ABS_LOCAL = ABQ_LOCAL AND ABS_FILIAL = '"+XFILIAL("ABS")+"'												"+cEol

	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' '                                           	"+cEol
	cQuery+= "AND ABQ.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABS.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND AA1.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABQ.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND TFL.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND TFF.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND TDX.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND SRA.D_E_L_E_T_=' '                                               	"+cEol
	cQuery+= "AND ABB_FILIAL BETWEEN '"+aRetOpc[1]+"' AND '"+aRetOpc[2]+"'			"+cEol
	cQuery+= "AND RA_MAT BETWEEN '"+aRetOpc[3]+"' AND '"+aRetOpc[4]+"'				"+cEol
	cQuery+= "AND ABB_DTINI >= '"+dTos(aRetOpc[5])+"' "+cEol
	cQuery+= "AND ABB_DTINI <= '"+dTos(aRetOpc[6])+"' "+cEol
	cQuery+= "AND ABB_HRINI BETWEEN '00:00' AND '24:00'  "+cEol
	cQuery+= "AND ABB_HRFIM BETWEEN '00:00' AND '24:00'  "+cEol
    cQuery+= "AND RA_SITFOLH <> 'D'                                                	"+cEol
	cQuery+= "AND TFF_ESCALA<> ' '													"+cEol
	cQuery+= "GROUP BY RA_FILIAL,RA_TNOTRAB,TDX_TURNO,RA_MAT,RA_NOME,AA1_FUNCAO,ABS_LOCAL,ABS_DESCRI,TFF_PERINI,TFF_PERFIM "+cEol
	cQuery+= "ORDER BY RA_FILIAL,RA_MAT,DATAFIM,TIPO "+cEol

	tcQuery cQuery new Alias TQ0016

	cAliasTRB := GetNextAlias()
	oTmpTbl	:= FWTemporaryTable():New(cAliasTRB)
	aStru	:= {}
	aCpos	:= {}

	Aadd(aStru,{"FILIAL","C",TamSx3("B1_FILIAL")[1],0})
	Aadd(aCpos,{"Filial",aStru[len(aStru)][1],,,1,TamSx3("RA_FILIAL")[1]})

	Aadd(aStru,{"RA_MAT","C",TamSx3("RA_MAT")[1],0})
	Aadd(aCpos,{"Matricula",aStru[len(aStru)][1],,,1,TamSx3("RA_MAT")[1]})

	Aadd(aStru,{"RA_TNOTRAB","C",TamSx3("RA_TNOTRAB")[1],0})
	Aadd(aCpos,{"Turno",aStru[len(aStru)][1],,,1,TamSx3("RA_TNOTRAB")[1]})

	Aadd(aStru,{"RA_SEQTURN","C",TamSx3("RA_SEQTURN")[1],0})
	Aadd(aCpos,{"Seq",aStru[len(aStru)][1],,,1,TamSx3("RA_SEQTURN")[1]})
	
	oTmpTbl:SetFields(aStru)
	oTmpTbl:Create()
	cNomTab := oTmpTbl:GetRealName()

	while TQ0016->(!Eof())
		cTurnAtu:= ""
		cSeqAtu	:= ""

		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		SRA->(dbSeek(TQ0016->RA_FILIAL+TQ0016->RA_MAT))

		//Verifica se já existe a referencia da Matricula
		cQuery:= "SELECT * "
		cQuery +=" FROM " + cNomTab + " "
		cQuery +=" 	WHERE FILIAL ='" +TQ0016->RA_FILIAL+ "' AND "
		cQuery +=" 	RA_MAT ='" +TQ0016->RA_MAT+ "' "
		TcQuery cQuery new Alias TP01
		If TP01->(eof())
			Reclock(cAliasTRB,.t.)
			(cAliasTRB)->FILIAL		:= TQ0016->RA_FILIAL 
			(cAliasTRB)->RA_MAT		:= TQ0016->RA_MAT 
			(cAliasTRB)->RA_TNOTRAB	:= TQ0016->RA_TNOTRAB
			(cAliasTRB)->RA_SEQTURN	:= SRA->RA_SEQTURN
			MsUnlock()	
			cTurnAtu:= TQ0016->RA_TNOTRAB //Turno do cadastro do funcionário
			cSeqAtu	:= SRA->RA_SEQTURN
		Else
			cTurnAtu:= TP01->RA_TNOTRAB //Turno atual é da query
			cSeqAtu	:= TP01->RA_SEQTURN //Seq atual é da query
		Endif
		TP01->(dbCloseArea())
		cSqCont:= fGetSequenCont() //Sequencia no contrato
		If cTurnAtu == TQ0016->TURNO .and. cSeqAtu == cSqCont //Tem o mesmo turno
			TQ0016->(dbSkip())
			loop
		Else
			cUpd:="UPDATE "+cNomTab+" SET RA_TNOTRAB = '"+cvaltochar(TQ0016->TURNO)+"',RA_SEQTURN='"+cSqCont+"'  "
			cUpd+="WHERE FILIAL ='" +TQ0016->RA_FILIAL+ "' AND " 
			cUpd+="RA_MAT ='" +TQ0016->RA_MAT+ "' "
			tcSqlExec(cUpd)
		Endif

		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		SRA->(dbSeek(TQ0016->RA_FILIAL+TQ0016->RA_MAT))
		cSemSq:= SRA->RA_SEQTURN

		If TQ0016->TIPO == 'ABQ'
			cDTroc:= cvaltochar(dow(stod(TQ0016->DATAFIM)))
			cQuery:= "SELECT PJ_SEMANA FROM "+RetSqlName("SPJ")+" SPJ "
			cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
			cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",SRA->RA_FILIAL)+"' AND "
			cQuery+= "PJ_TURNO = '"+TQ0016->TURNO+"' AND "
			cQuery+= "PJ_TPDIA = 'S' AND "
			cQuery+= "PJ_DIA = '"+cDTroc+"' "
			tcQuery cQuery new Alias QRSPJ
			If QRSPJ->(!Eof())
				cSemSq:= QRSPJ->PJ_SEMANA
			Endif
			QRSPJ->(dbCloseArea())

			aadd(aTurnos,{;
			cTurnAtu ,; 			//1
			TQ0016->TURNO ,;		//2
			TQ0016->RA_MAT ,;		//3	
			TQ0016->RA_NOME ,;		//4
			TQ0016->ABS_LOCAL ,;	//5
			TQ0016->ABS_DESCRI ,;	//6
			Posicione("SRJ",1,xFilial("SRJ",TQ0016->RA_FILIAL)+TQ0016->AA1_FUNCAO,"RJ_DESC"),; //7
			TQ0016->RA_FILIAL ,;	//8
			TQ0016->DATAFIM,;		//9
			cSemSq,;				//10
			SRA->RA_SEQTURN;		//11
			})
		Else //Escala
			//Busca a data de inicio
			cQuery:= "SELECT MIN(ABB_DTINI) ABB_DTINI FROM "+RetSqlName("ABB")+" ABB "
			cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND "
			cQuery+= "ABB_FILIAL = '"+TQ0016->RA_FILIAL+"' AND "
			cQuery+= "ABB_CODTEC = '"+alltrim(TQ0016->RA_FILIAL)+alltrim(TQ0016->RA_MAT)+"' AND "
			cQuery+= "ABB_LOCAL = '"+TQ0016->ABS_LOCAL+"' AND "
			If TQ0016->PERFIM >= TQ0016->DATAFIM
				cQuery+= "ABB_DTINI BETWEEN '"+TQ0016->DATAFIM+"' AND '"+TQ0016->PERFIM+"' "
			Else
				cQuery+= "ABB_DTINI BETWEEN '"+TQ0016->DATAFIM+"' AND '"+TQ0016->DATAFIM+"' "
			Endif
			tcQuery cQuery new Alias QRABB
			If QRABB->(eof())
				QRABB->(dbCloseArea())
				TQ0016->(dbSkip())
				loop
			Endif

			cDTroc:= cvaltochar(dow(stod(QRABB->ABB_DTINI)))
			cQuery:= "SELECT PJ_SEMANA FROM "+RetSqlName("SPJ")+" SPJ "
			cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
			cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",SRA->RA_FILIAL)+"' AND "
			cQuery+= "PJ_TURNO = '"+TQ0016->TURNO+"' AND "
			cQuery+= "PJ_TPDIA = 'S' AND "
			cQuery+= "PJ_DIA = '"+cDTroc+"' "
			tcQuery cQuery new Alias QRSPJ
			If QRSPJ->(!Eof())
				cSemSq:= QRSPJ->PJ_SEMANA
			Endif
			QRSPJ->(dbCloseArea())

			aadd(aTurnos,{;
			cTurnAtu ,; 			//1
			TQ0016->TURNO ,;		//2
			TQ0016->RA_MAT ,;		//3	
			TQ0016->RA_NOME ,;		//4
			TQ0016->ABS_LOCAL ,;	//5	
			TQ0016->ABS_DESCRI ,;	//6
			Posicione("SRJ",1,xFilial("SRJ",TQ0016->RA_FILIAL)+TQ0016->AA1_FUNCAO,"RJ_DESC"),; //7
			TQ0016->RA_FILIAL ,;	//8
			QRABB->ABB_DTINI,;		//9
			cSemSq,;				//10
			SRA->RA_SEQTURN;		//11
			})
			//cDTroc:= cvaltochar(dow(stod(aTurnos[len(aTurnos)][9])))
			QRABB->(dbCloseArea())
		Endif		
		TQ0016->(dbSkip())
	Enddo
	TQ0016->(dbCloseArea())

	oTmpTbl:delete() //Apaga tabela temporária

	If len(aDados) = 0 .and. len(aTurnos) = 0
		msgAlert("Sem informação a ser processada")
		Return
	Elseif msgyesNo("Deseja imprimir relatório?")
		fImpressRel16()
	Endif 

	If msgyesNo("Deseja processar transferências?")
		fProcesTrf(aRetOpc[7]) //Processa as transferências
	Endif
Return

Static Function fImpressRel16()
	local oReport
	oReport := reportDef()
	oReport:printDialog()
Return

Static function reportDef()
	local oReport
	Local oSection1
	local cTitulo := 'Relatório Transferências'

	oReport := TReport():New('RSERVR16', cTitulo,'', {|oReport| PrintReport(oReport)},"Relatório Transferências")
	oReport:SetLandscape()

	oSection1 := TRSection():New(oReport)
	oSection1:SetTotalInLine(.T.)

	TRCell():New(oSection1, "RA_FILIAL"		, "", 'Unidade'					,,25,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "RA_MAT"		, "", 'Matric.'					,,TamSX3("RA_MAT")[1]+4,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "RA_NOME"		, "", 'Nome'					,,TamSX3("RA_NOME")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "DATAFIM"		, "", 'Dt. Modificação'			,,TamSX3("RA_ADMISSA")[1]+3,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "RA_CC"			, "", 'Centro Custo Atual'		,,TamSX3("RA_CC")[1]+1,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "CTT_DESC01"	, "", 'Nome CC'					,,TamSX3("CTT_DESC01")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "TFL_YCC"		, "", 'Modificação'				,,TamSX3("TFL_YCC")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "CTT_DESC02"	, "", 'Nome CC'					,,TamSX3("CTT_DESC01")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABS_LOCAL"		, "", 'Local'					,,TamSX3("ABS_LOCAL")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection1, "ABS_DESCRI"	, "", 'Descrição Local'			,,TamSX3("ABS_DESCRI")[1]+7,,,,.T.,,,,,,,.F.)

	oSection2 := TRSection():New(oReport)
	oSection2:SetTotalInLine(.T.)

	TRCell():New(oSection2, "RA_FILIAL"		, "", 'Unidade'					,,25,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "RA_MAT"		, "", 'Matric.'					,,TamSX3("RA_MAT")[1]+4,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "RA_NOME"		, "", 'Nome'					,,TamSX3("RA_NOME")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "DATAFIM"		, "", 'Dt. Modificação'			,,TamSX3("RA_ADMISSA")[1]+3,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "RJ_DESC"		, "", 'Função'					,,TamSX3("RJ_DESC")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "RA_TNOTRAB"	, "", 'Turno Ant.'				,,TamSX3("ABQ_TURNO")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "SEQUEANT"		, "", 'Seq Ant.'				,,TamSX3("PJ_SEMANA")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "DRA_TNOTRAB"	, "", 'D. Turno'				,,TamSX3("R6_DESC")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "ABQ_TURNO"		, "", 'Modificação'				,,TamSX3("ABQ_TURNO")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "SEQUEN"		, "", 'Sequencia'				,,TamSX3("PJ_SEMANA")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "DABQ_TURNO"	, "", 'D. Turno'				,,TamSX3("R6_DESC")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "ABS_LOCAL"		, "", 'Local'					,,TamSX3("ABS_LOCAL")[1]+7,,,,.T.,,,,,,,.F.)
	TRCell():New(oSection2, "ABS_DESCRI"	, "", 'Descrição Local'			,,TamSX3("ABS_DESCRI")[1]+7,,,,.T.,,,,,,,.F.)
Return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local i			:= 1

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	For i:=1 To len(aDados)
		oSection1:Cell("RA_FILIAL"):SetValue(substr(FWFilName(cEmpAnt,aDados[i][8]),1,22))
		oSection1:Cell("RA_MAT"):SetValue(aDados[i][3])
		oSection1:Cell("RA_NOME"):SetValue(aDados[i][4])
		oSection1:Cell("RA_CC"):SetValue(aDados[i][1])
		oSection1:Cell("CTT_DESC01"):SetValue(posicione("CTT",1,xFilial("CTT")+aDados[i][1],"CTT_DESC01"))
		oSection1:Cell("TFL_YCC"):SetValue(aDados[i][2])
		oSection1:Cell("CTT_DESC02"):SetValue(posicione("CTT",1,xFilial("CTT")+aDados[i][2],"CTT_DESC01"))
		oSection1:Cell("ABS_LOCAL"):SetValue(aDados[i][5])
		oSection1:Cell("ABS_DESCRI"):SetValue(aDados[i][6])
		oSection1:Cell("DATAFIM"):SetValue(stod(aDados[i][9]))
		oSection1:PrintLine()	
	Next
	oSection1:Finish()


	oSection2:Init()
	oSection2:SetHeaderSection(.T.)

	For i:=1 To len(aTurnos)
		oSection2:Cell("RA_FILIAL"):SetValue(substr(FWFilName(cEmpAnt,aTurnos[i][8]),1,22))
		oSection2:Cell("RA_MAT"):SetValue(aTurnos[i][3])
		oSection2:Cell("RA_NOME"):SetValue(aTurnos[i][4])
		oSection2:Cell("RJ_DESC"):SetValue(aTurnos[i][7])
		oSection2:Cell("RA_TNOTRAB"):SetValue(aTurnos[i][1])
		oSection2:Cell("DRA_TNOTRAB"):SetValue(posicione("SR6",1,xFilial("SR6")+aTurnos[i][1],"R6_DESC"))
		oSection2:Cell("ABQ_TURNO"):SetValue(aTurnos[i][2])
		oSection2:Cell("DABQ_TURNO"):SetValue(posicione("SR6",1,xFilial("SR6")+aTurnos[i][2],"R6_DESC"))
		oSection2:Cell("ABS_LOCAL"):SetValue(aTurnos[i][5])
		oSection2:Cell("ABS_DESCRI"):SetValue(aTurnos[i][6])
		oSection2:Cell("DATAFIM"):SetValue(stod(aTurnos[i][9]))
		oSection2:Cell("SEQUEN"):SetValue(aTurnos[i][10])
		oSection2:Cell("SEQUEANT"):SetValue(aTurnos[i][11])
		oSection2:PrintLine()	
	Next
	oSection2:Finish()

Return

Static Function fProcesTrf(cOpcao)
	Local aArea			:= getArea()
	Local aAutoItens    := {}
	Local aCampos       := {}
	Local dDataTransf   := date()
	Local cFilBkp		:= cFilAnt
	Local nModBak		:= nModulo
	Local cModBak		:= cModulo
	Local nX,nY

	Private lMsErroAuto := .F.
	
	If (cOpcao == "2") // Centro de Custo
		For nX:=1 To len(aDados)
			cEmpBk		:= cEmpAnt
			cFilAnt		:= aDados[nX][8]
			dDataTransf := stod(aDados[nX][9])
			lMsErroAuto := .F.
			aAutoItens	:= {}
			aCampos		:= {}
	
			dbSelectArea("SRA")
			dbSetOrder(1)
			SRA->(dbSeek(xFilial("SRA")+aDados[nX][3]))		
			
			aAdd( aCampos, { "RA_MAT"	, aDados[nX][3] } )
			aAdd( aCampos, { "RA_CC"	, aDados[nX][2] } )
			aAdd( aAutoItens, { aDados[nX][8], aDados[nX][3], aCampos } )
	
			MSExecAuto( {|x,y,z,w| GPEA180(x,y,z,w)}, 6, aAutoItens, dDataTransf, .T. )
	
			If !lMsErroAuto
				conout("Transferencia efetuada!")
				dbSelectArea("SRA")
				dbSetOrder(1)
				SRA->(dbSeek(xFilial("SRA")+aDados[nX][3]))
				Reclock("SRA",.F.)
					SRA->RA_YDTPROC := aRetOpc[6]
				MsUnlock()
	
				dbSelectArea("AA1")
				AA1->(dbSetOrder(1))
				If AA1->(dbSeek(SRA->(RA_FILIAL+RA_FILIAL+RA_MAT)))
					Reclock("AA1",.F.)
						AA1->AA1_CC:= SRA->RA_CC
					MsUnlock()
				Endif
	
			Else
				MostraErro()
				alert("Erro na Transferencia!")
			EndIf

		Next

	ElseIf (cOpcao == "3") // Turnos
		For nY:=1 to len(aTurnos)
			cFilAnt		:= aTurnos[nY][8]
			dbSelectArea("SRA")
			SRA->(dbSetOrder(1))
			SRA->(dbSeek(xFilial("SRA")+aTurnos[nY][3]))
	
			//Verifica se existe na SPF, caso sim exclui para reprocessar
			cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SPF")+" SPF "
			cQuery+= "WHERE SPF.D_E_L_E_T_ = ' ' AND "
			cQuery+= "PF_FILIAL = '"+xFilial("SPF")+"' AND "
			cQuery+= "PF_MAT = '"+SRA->RA_MAT+"' AND "
			cQuery+= "PF_DATA= '"+aTurnos[nY][9]+"' "
			tcQuery cQuery new Alias QRSPF
			while QRSPF->(!Eof())
				SPF->(dbGoto(QRSPF->RECNO))
				Reclock("SPF",.F.)
				SPF->(dbDelete())
				MsUnlock()
				QRSPF->(dbSkip())
			Enddo
			QRSPF->(dbCloseArea())
		
			RecLock("SPF",.T.)
			SPF->PF_FILIAL	:= xFilial("SPF")
			SPF->PF_MAT		:= SRA->RA_MAT
			SPF->PF_DATA	:= stod(aTurnos[nY][9])
			SPF->PF_TURNODE	:= SRA->RA_TNOTRAB
			SPF->PF_SEQUEDE	:= SRA->RA_SEQTURN
			SPF->PF_REGRADE	:= SRA->RA_REGRA
			SPF->PF_TURNOPA	:= aTurnos[nY][2]	
			SPF->PF_SEQUEPA	:= aTurnos[nY][10]
			SPF->PF_REGRAPA	:= SRA->RA_REGRA
			SPF->PF_RHEXP  	:=""
			SPF->PF_TRFOBS 	:= "TRANSFERENCIA"
			MsUnlock()
	
			reclock("SRA",.F.)
			SRA->RA_TNOTRAB := aTurnos[nY][2]
			SRA->RA_SEQTURN := aTurnos[nY][10]
			msUnlock()
	
			dbSelectArea("AA1")
			AA1->(dbSetOrder(1))
			If AA1->(dbSeek(SRA->(RA_FILIAL+RA_FILIAL+RA_MAT)))
				reclock("AA1",.F.)
				AA1->AA1_TURNO := SRA->RA_TNOTRAB
				AA1->AA1_SEQTUR:= SRA->RA_SEQTURN
				msUnlock()
			Endif
		Next	
	Else
		For nX:=1 To len(aDados)
			cEmpBk		:= cEmpAnt
			cFilAnt		:= aDados[nX][8]
			dDataTransf := stod(aDados[nX][9])
			lMsErroAuto := .F.
			aAutoItens	:= {}
			aCampos		:= {}
	
			dbSelectArea("SRA")
			dbSetOrder(1)
			SRA->(dbSeek(xFilial("SRA")+aDados[nX][3]))		

			//aAdd( aCampos, { "RA_FILIAL", aDados[nX][8] } )
			aAdd( aCampos, { "RA_MAT"	, aDados[nX][3] } )
			aAdd( aCampos, { "RA_CC"	, aDados[nX][2] } )
			aAdd( aAutoItens, { aDados[nX][8], aDados[nX][3], aCampos } )
	
			MSExecAuto( {|x,y,z,w| GPEA180(x,y,z,w)}, 6, aAutoItens, dDataTransf, .T. )

			If !lMsErroAuto
				conout("Transferencia efetuada!")
				dbSelectArea("SRA")
				dbSetOrder(1)
				SRA->(dbSeek(xFilial("SRA")+aDados[nX][3]))
				Reclock("SRA",.F.)
					SRA->RA_YDTPROC := aRetOpc[6]
				MsUnlock()
	
				dbSelectArea("AA1")
				AA1->(dbSetOrder(1))
				If AA1->(dbSeek(SRA->(RA_FILIAL+RA_FILIAL+RA_MAT)))
					Reclock("AA1",.F.)
						AA1->AA1_CC:= SRA->RA_CC
					MsUnlock()
				Endif
	
			Else
				MostraErro()
				alert("Erro na Transferencia!")
			EndIf

		Next

	
		For nY:=1 to len(aTurnos)
			cFilAnt		:= aTurnos[nY][8]
			dbSelectArea("SRA")
			SRA->(dbSetOrder(1))
			SRA->(dbSeek(xFilial("SRA")+aTurnos[nY][3]))
	
			//Verifica se existe na SPF, caso sim exclui para reprocessar
			cQuery:= "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("SPF")+" SPF "
			cQuery+= "WHERE SPF.D_E_L_E_T_ = ' ' AND "
			cQuery+= "PF_FILIAL = '"+xFilial("SPF")+"' AND "
			cQuery+= "PF_MAT = '"+SRA->RA_MAT+"' AND "
			cQuery+= "PF_DATA= '"+aTurnos[nY][9]+"' "
			tcQuery cQuery new Alias QRSPF
			while QRSPF->(!Eof())
				SPF->(dbGoto(QRSPF->RECNO))
				Reclock("SPF",.F.)
				SPF->(dbDelete())
				MsUnlock()
				QRSPF->(dbSkip())
			Enddo
			QRSPF->(dbCloseArea())
	
			RecLock("SPF",.T.)
			SPF->PF_FILIAL	:= xFilial("SPF")
			SPF->PF_MAT		:= SRA->RA_MAT
			SPF->PF_DATA	:= stod(aTurnos[nY][9])
			SPF->PF_TURNODE	:= SRA->RA_TNOTRAB
			SPF->PF_SEQUEDE	:= SRA->RA_SEQTURN
			SPF->PF_REGRADE	:= SRA->RA_REGRA
			SPF->PF_TURNOPA	:= aTurnos[nY][2]	
			SPF->PF_SEQUEPA	:= aTurnos[nY][10]
			SPF->PF_REGRAPA	:= SRA->RA_REGRA
			SPF->PF_RHEXP  	:=""
			SPF->PF_TRFOBS 	:= "TRANSFERENCIA"
			MsUnlock()
	
			reclock("SRA",.F.)
			SRA->RA_TNOTRAB := aTurnos[nY][2]
			SRA->RA_SEQTURN := aTurnos[nY][10]
			msUnlock()
	
			dbSelectArea("AA1")
			AA1->(dbSetOrder(1))
			If AA1->(dbSeek(SRA->(RA_FILIAL+RA_FILIAL+RA_MAT)))
				reclock("AA1",.F.)
				AA1->AA1_TURNO := SRA->RA_TNOTRAB
				AA1->AA1_SEQTUR:= SRA->RA_SEQTURN
				msUnlock()
			Endif
		Next	
	EndIf 
	

	nModulo:= nModBak 
	cModulo:= cModBak 
	cFilAnt:= cFilBkp
	RestArea(aArea)
Return


Static Function fGetSequenCont()
	Local aArea	:= getArea()
	Local cSemSq:= ""	
	If TQ0016->TIPO == 'ABQ'
		cDTroc:= cvaltochar(dow(stod(TQ0016->DATAFIM)))
		cQuery:= "SELECT PJ_SEMANA FROM "+RetSqlName("SPJ")+" SPJ "
		cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
		cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",SRA->RA_FILIAL)+"' AND "
		cQuery+= "PJ_TURNO = '"+TQ0016->TURNO+"' AND "
		cQuery+= "PJ_TPDIA = 'S' AND "
		cQuery+= "PJ_DIA = '"+cDTroc+"' "
		tcQuery cQuery new Alias QRSPJ
		If QRSPJ->(!Eof())
			cSemSq:= QRSPJ->PJ_SEMANA
		Endif
		QRSPJ->(dbCloseArea())

	Else //Escala
		//Busca a data de inicio
		cQuery:= "SELECT MIN(ABB_DTINI) ABB_DTINI FROM "+RetSqlName("ABB")+" ABB "
		cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND "
		cQuery+= "ABB_FILIAL = '"+TQ0016->RA_FILIAL+"' AND "
		cQuery+= "ABB_CODTEC = '"+alltrim(TQ0016->RA_FILIAL)+alltrim(TQ0016->RA_MAT)+"' AND "
		cQuery+= "ABB_LOCAL = '"+TQ0016->ABS_LOCAL+"' AND "
		If TQ0016->PERFIM >= TQ0016->DATAFIM
			cQuery+= "ABB_DTINI BETWEEN '"+TQ0016->DATAFIM+"' AND '"+TQ0016->PERFIM+"' "
		Else
			cQuery+= "ABB_DTINI BETWEEN '"+TQ0016->DATAFIM+"' AND '"+TQ0016->DATAFIM+"' "
		Endif
		tcQuery cQuery new Alias QRABB
		If QRABB->(eof())
			QRABB->(dbCloseArea())
			TQ0016->(dbSkip())
			Return ""
		Endif

		cDTroc:= cvaltochar(dow(stod(QRABB->ABB_DTINI)))
		cQuery:= "SELECT PJ_SEMANA FROM "+RetSqlName("SPJ")+" SPJ "
		cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
		cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",SRA->RA_FILIAL)+"' AND "
		cQuery+= "PJ_TURNO = '"+TQ0016->TURNO+"' AND "
		cQuery+= "PJ_TPDIA = 'S' AND "
		cQuery+= "PJ_DIA = '"+cDTroc+"' "
		tcQuery cQuery new Alias QRSPJ
		If QRSPJ->(!Eof())
			cSemSq:= QRSPJ->PJ_SEMANA
		Endif
		QRSPJ->(dbCloseArea())
		QRABB->(dbCloseArea())
	Endif	
	RestArea(aArea)
Return cSemSq
