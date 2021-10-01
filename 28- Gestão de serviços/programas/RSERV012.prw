#INCLUDE "protheus.ch"
#INCLUDE "BenefArq.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"
#include "topconn.ch"
#include 'parmtype.ch'
#Define CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RSERV012
Geração do Vale Transporte/Vale Alimentação
@author Diogo
@since 20/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSERV012()
	Local cPerg 		:= "RSRVY012"
	Private cAliasTRB	:= nil
	Private oTmpTbl		:= nil
	Private _lafasa := .f.
	//	aHorario:= At580HorTur( "001", "01" )
	//	alert(varinfo("aHorario",aHorario,,.F.))

	AjustaSX1(cPerg)
	TNewProcess():New("RSERV012","Lançamento", {|oSelf| ProcessBnf(oSelf)}, "Lançamentos Vale Transporte/Vale Alimentação", cPerg, NIL, NIL, NIL, NIL, .T., .F.)
return


//perguntas
Static Function AjustaSX1(cPerg)
	u_PutSx1(cPerg, "01","Periodo (AAAMM)"  ,"Periodo (AAAMM)"	    ,"Periodo (AAAMM)","mv_ch01","C",06,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "02","Pagamento"		,"Pagamento"		    ,"Pagamento"	,"mv_ch02","C",06,0,0,"S","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "03","Filial De"		,"Filial De"			,"Filial De"	,"mv_ch03","C",06,0,0,"G","","SM0"   ,"","","mv_par03"," ","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "04","Filial até"		,"Filial até"		    ,"Filial até"	,"mv_ch04","C",06,0,0,"G","","SM0"   ,"","","mv_par04"," ","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "05","Local De"		    ,"Local De"		        ,"Local De"		,"mv_ch05","C",08,0,0,"G","","ABS","","","mv_par05","","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "06","Local até"		,"Local até"		    ,"Local até"	,"mv_ch06","C",08,0,0,"G","","ABS","","","mv_par06","","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "07","Matricula De"		,"Matricula"		    ,"Matricula De"	,"mv_ch07","C",06,0,0,"G","","SRA","","","mv_par07","","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg, "08","Matricula até"	,"Matricula até"		,"Matricula até","mv_ch08","C",06,0,0,"G","","SRA","","","mv_par08","","","","","","","","","","","","","","","","")
Return


Static Function ProcessBnf(oProcess)

	Local nCount, nCount2
	Local nOldSet   := SetVarNameLen(255)
	Local aArea     := GetArea()
	Local lCancel   := .F.

	Private aItems	:= {}
	Private nTotal  := 0
	Private nVlr    := 0
	Private nHdl    := 0
	Private nLin    := 0
	Private lErrorImp := .F.
	Private dPerDe	:= 	MonthSub(stod(alltrim(mv_par01)+"21"), 2)
	Private dPerate	:=  MonthSub(stod(alltrim(mv_par01)+"20"), 1)
	Private nQtAgen := 0
	Private nQtFtl  := 0
	Private nQtFer  := 0
	Private nDescAviso := 0
	Private adiasval := {}
	Private adiasvtr := {}
	Private _csind := ""

	Private nQtdAuse := 0

	cAliasTRB := GetNextAlias()
	oTmpTbl	:= FWTemporaryTable():New(cAliasTRB)
	fCriaTemp()

	AAdd(aItems, {"Processando", { || ProcINI(oProcess,cAliasTRB,oTmpTbl) } }) //"Lendo arquivo INI"

	oProcess:SetRegua1(Len(aItems))
	oProcess:SaveLog("Iniciando")

	For nCount:= 1 to Len(aItems)
		If (oProcess:lEnd)
			Break
		EndIf

		oProcess:IncRegua1(aItems[nCount, 1])
		Eval(aItems[nCount, 2])
	next

	SetVarNameLen(nOldSet)

	//Encerra o processamento
	If !oProcess:lEnd
		oProcess:SaveLog("Fim do processamento")

		If lErrorImp
			Alert("Existe dados inválidos. Verifique o Log de Processos desta rotina!")

		ElseIf nLin > 0
			Aviso("Processamento concluído", "Fim do processamento", {"ok"})
		EndIf
	Else
		nLin := 0
		Aviso("Processamento concluído", "Cancelado por usuário" , {"ok"})
	EndIf

	If	msgYesNo("Deseja imprimir relatório dos dados processados?")
		fImpRel()
	Endif

	///oTmpTbl:delete() //Apaga tabela temporária
	RestArea(aArea)

Return .T.


Static Function ProcINI(oProcess,cAliasTRB,oTmpTbl)

	Local cNomTab := oTmpTbl:GetRealName()
	//1*
	// PERCORRE SRA RETIRANDO DELETADOS E N DEMITIDOS
	cQuery1 := " SELECT *
	cQuery1 += " FROM "+RetSqlName("SRA")+" SRA  "
	cQuery1 += " WHERE
	cQuery1 += " RA_SITFOLH <> 'D'
	cQuery1 += " AND D_E_L_E_T_=''
	cQuery1 += " AND RA_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
	cQuery1 += " AND RA_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery1 += " ORDER BY RA_FILIAL , RA_MAT

	If SELECT("TFUNC") > 0
		TFUNC->(dbCloseArea())
	Endif
	TcQuery cQuery1 New Alias TFUNC

	//Vale alimentação
	while  !TFUNC->(EOF())
		//Carrega registros para o relatório
		_csind := TFUNC->RA_SINDICA
		Reclock(cAliasTRB,.t.)
		(cAliasTRB)->LOCAL		:= ""//Posicione("ABS",1,xFilial("ABS")+TABB->ABB_LOCAL,"ABS_DESCRI")
		(cAliasTRB)->FILIAL		:= TFUNC->RA_FILIAL
		(cAliasTRB)->MATRICULA	:= TFUNC->RA_MAT
		(cAliasTRB)->NOMEFUN	:= TFUNC->RA_NOME
		(cAliasTRB)->VA 		:= ""
		(cAliasTRB)->DESCVA 	:= ""
		(cAliasTRB)->QTVA 		:= 0
		(cAliasTRB)->VT 		:= ""
		(cAliasTRB)->DESCVT 	:= ""
		(cAliasTRB)->QTVT 		:= 0
		(cAliasTRB)->QTVTDIA 	:= 0
		(cAliasTRB)->QTDAVISO 	:= 0
		(cAliasTRB)->QTDAUSE 	:= 0
//		(cAliasTRB)->INSAL 		:= ""
//		(cAliasTRB)->PERIC 		:= ""
		MsUnlock()

		oProcess:IncRegua1(aItems[1, 1])
		//Vale Alimentação
		/*
		cQuery1 := " SELECT ABB_FILIAL , ZA2_FILIAL , ABB_CODTEC, ABB_LOCAL , ZA2_COD , ABB_IDCFAL , ZA2_CONTRA ,ZA2_VATIPO,COUNT(ZA2_VATIPO)  QUANT
		cQuery1 += " FROM (
		cQuery1 += " SELECT ABB_FILIAL , ZA2_FILIAL , ABB_CODTEC, ABB_DTINI , ABB_LOCAL , ZA2_COD , SUBSTRING(ABB_IDCFAL,1,15) ABB_IDCFAL , ZA2_CONTRA ,ZA2_VATIPO
		cQuery1 += " FROM "+RetSqlName("ABB")+"  ABB
		cQuery1 += " INNER JOIN "+RetSqlName("ZA2")+" ZA2 ON ABB_FILIAL = ZA2_FILIAL AND RTRIM(ABB_LOCAL) = RTRIM(ZA2_COD) AND SUBSTRING(ABB_IDCFAL,1,15) = ZA2_CONTRA
		cQuery1 += " INNER JOIN "+RetSqlName("CN9")+" CN9 ON CN9_FILIAL = ABB_FILIAL AND CN9_NUMERO =  SUBSTRING(ABB_IDCFAL,1,15) AND CN9_REVATU = ' ' AND CN9_SITUAC IN ('05','06','07','08')
		cQuery1 += " INNER JOIN "+RetSqlName("SM7")+" SM7 ON M7_FILIAL = ZA2_FILIAL AND M7_TPVALE='2' AND M7_MAT = '"+alltrim(TFUNC->RA_MAT)+"' AND M7_CODIGO = ZA2_VATIPO 
		cQuery1 += " WHERE ABB.D_E_L_E_T_=''
		cQuery1 += " AND ZA2.D_E_L_E_T_=''
		cQuery1 += " AND CN9.D_E_L_E_T_=''
		cQuery1 += " AND SUBSTRING(ABB_DTINI,1,6) = '"+alltrim(MV_PAR01)+"' "
		cQuery1 += " AND ABB_CODTEC  = '"+ alltrim(TFUNC->RA_FILIAL)+alltrim(TFUNC->RA_MAT) +"'
		cQuery1 += " AND ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' 
		cQuery1 += " GROUP BY ABB_FILIAL , ZA2_FILIAL , ABB_CODTEC, ABB_DTINI , ABB_LOCAL , ZA2_COD , ABB_IDCFAL , ZA2_CONTRA ,ZA2_VATIPO ) ABB2
		cQuery1 += " GROUP BY ABB_FILIAL , ZA2_FILIAL , ABB_CODTEC, ABB_LOCAL , ZA2_COD , ABB_IDCFAL , ZA2_CONTRA  ,ZA2_VATIPO
		*/

		cQuery1 := " SELECT ABB_FILIAL AS ZA2_FILIAL , ABB_FILIAL  , ABB_CODTEC, ABB_LOCAL , ABB_IDCFAL , M7_CODIGO " //,  COUNT(M7_CODIGO) QUANT
		cQuery1 += " FROM (
		cQuery1 += " SELECT ABB_FILIAL  , ABB_CODTEC, ABB_DTINI , ABB_LOCAL , SUBSTRING(ABB_IDCFAL,1,15) ABB_IDCFAL , M7_CODIGO
		cQuery1 += " FROM "+RetSqlName("ABB")+"  ABB
		cQuery1 += " INNER JOIN "+RetSqlName("SM7")+" SM7 ON M7_FILIAL = ABB_FILIAL AND M7_TPVALE='2' AND M7_MAT = '"+alltrim(TFUNC->RA_MAT)+"'
		cQuery1 += " WHERE ABB.D_E_L_E_T_=' ' AND SM7.D_E_L_E_T_ = ' ' "
		cQuery1 += " AND SUBSTRING(ABB_DTINI,1,6) = '"+alltrim(MV_PAR01)+"' "
		cQuery1 += " AND ABB_CODTEC  = '"+ alltrim(TFUNC->RA_FILIAL)+alltrim(TFUNC->RA_MAT) +"'
		cQuery1 += " AND ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		cQuery1 += " GROUP BY ABB_FILIAL  , ABB_CODTEC, ABB_DTINI , ABB_LOCAL  , ABB_IDCFAL , M7_CODIGO) ABB2
		cQuery1 += " GROUP BY ABB_FILIAL  , ABB_CODTEC, ABB_LOCAL , ABB_IDCFAL , M7_CODIGO

		If select("TABB") > 0
			TABB->(dbCloseArea())
		Endif
		TcQuery cQuery1 New Alias TABB

		//Carrega beneficio vale alimentação
		aValeAli := {}
		nQtAgen := 0
		nQtFtl  := 0
		nQtFer  := 0
		nDescAviso := 0
		nQtdAuse := 0

		while !TABB->(EOF())
			_lafasa := .f.
			_CTIPO := "VAL"
			adiasval := {}
			nDias:= fGetDias(TABB->ZA2_FILIAL,TABB->ABB_CODTEC,TABB->ABB_LOCAL,SUBSTR(TABB->ABB_IDCFAL,1,15),_CTIPO)
			nQtAgen += nDias //Quantidade agendada
			nDias -= nDescAviso //Desconta aviso previo
			nDias:= nDias - fGetFolh(TABB->ZA2_FILIAL,TABB->ABB_CODTEC,TABB->ABB_LOCAL,SUBSTR(TABB->ABB_IDCFAL,1,15),_CTIPO)
			IF nDias < 0
				nDias := 0
			EndIf
			If _lafasa
				nQtFtl := nQtAgen
				nDias := 0
			endif
			aadd(aValeAli, { TABB->ZA2_FILIAL,TABB->M7_CODIGO,nDias,TABB->ABB_LOCAL,nQtAgen,nQtFtl,nQtFer,nDescAviso,nQtdAuse } )
			TABB->(dbSkip())
		enddo
		TABB->(dbCloseArea())

		SM7->(dbSetOrder(1))
		// verificar se existe benefício
		if len(aValeAli) > 0
			For nAux := 1 to len(aValeAli)

				dbSelectArea("RFO")
				dbSetOrder(1)
				If !(RFO->(dbSeek(xFilial("RFO",aValeAli[nAux][1]) +"2"+ aValeAli[nAux][2])))
					loop
				Endif

				// Vale alimentação
				/*
				cQuery := " UPDATE " + retSqlName("SM7")
				cQuery += " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "
				cQuery += " WHERE M7_FILIAL = '"+aValeAli[nAux][1]+"'
				cQuery += " AND M7_MAT = '"+TFUNC->RA_MAT+"'
				cQuery += " AND M7_TPVALE = '2' 

				If tcSqlExec(cQuery) < 0
					Alert(tcSqlError())
				Endif
				*/

				// reclock de inclusão na SR0
				DbSelectArea("SM7")
				If !(SM7->(dbSeek(aValeAli[nAux][1]+TFUNC->RA_MAT+aValeAli[nAux][2]+'2')))
					loop
				Endif
				RecLock("SM7", .F.)
				SM7->M7_FILIAL   := aValeAli[nAux][1]
				SM7->M7_MAT      := TFUNC->RA_MAT
				SM7->M7_CODIGO   := aValeAli[nAux][2]
				SM7->M7_TPVALE   := '2'
				SM7->M7_DPROPIN  := iif(aValeAli[nAux][3]<0,0,aValeAli[nAux][3])
				SM7->M7_QDIAINF  := 1
				SM7->M7_TPCALC   := '1'
				SM7->M7_YDTPROC  := LastDate(stod(alltrim(mv_par01)+"01"))
				MsUnLock() // Confirma e finaliza a operação

				cQuery	:= "SELECT *  "
				cQuery	+=" FROM " + cNomTab + " "
				cQuery	+=" WHERE MATRICULA = '"+TFUNC->RA_MAT+"' "
				cQuery	+=" ORDER BY VA "
				tcQuery cQuery new Alias TINS

				If TINS->(!Eof())
					If empty(TINS->VA) //Edita o registro
						dbSelectArea(cAliasTRB)
						(cAliasTRB)->(dbSetOrder(1))
						(cAliasTRB)->(dbSeek(TFUNC->RA_MAT))
						dbSelectArea("RFO")
						dbSetOrder(1)
						If !(RFO->(dbSeek(XFILIAL("RFO",aValeAli[nAux][1]) +"2"+ aValeAli[nAux][2])))
							loop
						Endif

						Reclock(cAliasTRB,.F.)
						(cAliasTRB)->LOCAL		:= Posicione("ABS",1,xFilial("ABS")+aValeAli[nAux][4],"ABS_DESCRI")
						(cAliasTRB)->VA 		:= aValeAli[nAux][2]
						(cAliasTRB)->DESCVA 	:= posicione("RFO",1,XFILIAL("RFO",aValeAli[nAux][1]) +"2"+ aValeAli[nAux][2],"RFO_DESCR")
						(cAliasTRB)->QTVA 		:= aValeAli[nAux][3]
						(cAliasTRB)->QTAGEN 	:= aValeAli[nAux][5]
						(cAliasTRB)->QTFALT 	:= aValeAli[nAux][6]
						(cAliasTRB)->QTFERIAS 	:= aValeAli[nAux][7]
						(cAliasTRB)->QTDAVISO 	:= aValeAli[nAux][8]
						(cAliasTRB)->QTDAUSE 	:= aValeAli[nAux][9]
						MsUnlock()
					Else //Insere novo registro do vale alimentação
						Reclock(cAliasTRB,.t.)
						(cAliasTRB)->LOCAL		:= Posicione("ABS",1,xFilial("ABS")+aValeAli[nAux][4],"ABS_DESCRI")
						(cAliasTRB)->FILIAL		:= TFUNC->RA_FILIAL
						(cAliasTRB)->MATRICULA	:= TFUNC->RA_MAT
						(cAliasTRB)->NOMEFUN	:= TFUNC->RA_NOME
						(cAliasTRB)->VA 		:= aValeAli[nAux][2]
						(cAliasTRB)->DESCVA 	:= posicione("RFO",1,XFILIAL("RFO",aValeAli[nAux][1]) +"2"+ aValeAli[nAux][2],"RFO_DESCR")
						(cAliasTRB)->QTVA 		:= aValeAli[nAux][3]
						(cAliasTRB)->QTAGEN 	:= aValeAli[nAux][5]
						(cAliasTRB)->QTFALT 	:= aValeAli[nAux][6]
						(cAliasTRB)->QTDAVISO 	:= aValeAli[nAux][8]
						(cAliasTRB)->QTDAUSE 	:= aValeAli[nAux][9]
						MsUnlock()
					Endif
				Endif
				TINS->(dbCloseArea())
			next
		Endif
		TFUNC->(dbSkip())
	enddo

	cQuery1 := " SELECT *
	cQuery1 += " FROM "+RetSqlName("SRA")+" SRA  	"
	cQuery1 += " JOIN "+RetSqlName("SM7")+" SM7		"
	cQuery1 += " ON M7_FILIAL = RA_FILIAL AND "
	cQuery1 += " M7_MAT = RA_MAT AND 	"
	cQuery1 += " M7_TPVALE = '0' 		"
	cQuery1 += " WHERE 					"
	cQuery1 += " RA_SITFOLH <> 'D'		"
	cQuery1 += " AND SRA.D_E_L_E_T_=''	"
	cQuery1 += " AND SM7.D_E_L_E_T_=''	"
	cQuery1 += " AND RA_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'		"
	cQuery1 += " AND RA_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' 	"
	cQuery1 += " ORDER BY RA_FILIAL , RA_MAT "

	If select("TFUNC") > 0
		TFUNC->(dbCloseArea())
	Endif
	TcQuery cQuery1 New Alias TFUNC

	nQtAgen := 0
	nQtFtl  := 0
	nQtFer  := 0
	nDescAviso := 0
	nQtdAuse := 0

	//Vale transporte
	while !TFUNC->(EOF())
		oProcess:IncRegua1(aItems[1,1])
		// Vale Transporte
		cQuery1 := " SELECT ABB_FILIAL AS [ZA2_FILIAL] , ABB_FILIAL , ABB_CODTEC, MAX(ABB_LOCAL) ABB_LOCAL , ABB_IDCFAL , M7_CODIGO ,M7_QDIAINF , RN_DESC
		cQuery1 += " FROM (
		cQuery1 += " SELECT ABB_FILIAL , ABB_CODTEC, ABB_DTINI , ABB_LOCAL , SUBSTRING(ABB_IDCFAL,1,15) ABB_IDCFAL , M7_CODIGO ,M7_QDIAINF , RN_DESC
		cQuery1 += " FROM "+RetSqlName("ABB")+"  ABB
		cQuery1 += " INNER JOIN "+RetSqlName("SM7")+" SM7 ON M7_FILIAL = ABB_FILIAL AND M7_TPVALE='0' AND M7_MAT = '"+alltrim(TFUNC->RA_MAT)+"'
		cQuery1 += " INNER JOIN "+RetSqlName("SRN")+" SRN ON RN_FILIAL = SUBSTRING(ABB_FILIAL,1,2) AND RN_COD = M7_CODIGO
		cQuery1 += " WHERE ABB.D_E_L_E_T_=''
		cQuery1 += " AND SM7.D_E_L_E_T_=''
		cQuery1 += " AND SUBSTRING(ABB_DTINI,1,6) = '"+alltrim(MV_PAR01)+"'
		cQuery1 += " AND ABB_CODTEC  = '"+ alltrim(TFUNC->RA_FILIAL)+alltrim(TFUNC->RA_MAT) +"'
		cQuery1 += " AND ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		cQuery1 += " GROUP BY ABB_FILIAL , ABB_CODTEC, ABB_DTINI , ABB_LOCAL , ABB_IDCFAL , M7_CODIGO ,M7_QDIAINF , RN_DESC) ABB2
		cQuery1 += " GROUP BY ABB_FILIAL , ABB_CODTEC, ABB_IDCFAL , M7_CODIGO ,M7_QDIAINF , RN_DESC

		If select("TABB") > 0
			TABB->(dbCloseArea())
		Endif
		TcQuery cQuery1 New Alias TABB

		aValeTran 	:= {}
		nDias		:= 0
		nQtAgen 	:= 0
		nQtFtl  	:= 0
		nQtFer  	:= 0
		nDescAviso  := 0
		nQtdAuse 	:= 0

		while !TABB->(EOF())
			_lafasa := .f.
			_CTIPO := "VTR"
			adiasvtr := {}
			nDias+= fGetDias(TABB->ZA2_FILIAL,TABB->ABB_CODTEC,TABB->ABB_LOCAL,SUBSTR(TABB->ABB_IDCFAL,1,15),_CTIPO)
			nQtAgen += nDias //Quantidade agendada
			nDias -= nDescAviso //Desconta aviso previo
			nDias-= fGetFolh(TABB->ZA2_FILIAL,TABB->ABB_CODTEC,TABB->ABB_LOCAL,SUBSTR(TABB->ABB_IDCFAL,1,15),_CTIPO)
			IF nDias < 0
				nDias := 0
			EndIf
			If _lafasa
				nQtFtl := nQtAgen
				nDias := 0
			endif
			aadd(aValeTran,{TABB->ZA2_FILIAL,ALLTRIM(TABB->RN_DESC),nDias,TABB->M7_QDIAINF,TABB->ABB_LOCAL,TABB->M7_CODIGO,nQtAgen,nQtFtl,nQtFer,nDescAviso,nQtdAuse})

			// Vale Transporte - apaga registro para informar novamente com o vale transporte
			/*
			cQuery := " UPDATE " + retSqlName("SM7")
			cQuery += " SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "
			cQuery += " WHERE M7_FILIAL = '"+TABB->ZA2_FILIAL+"'
			cQuery += " AND   M7_MAT = '"+TFUNC->RA_MAT+"'
			cQuery += " AND   M7_TPVALE = '0'
			If tcSqlExec(cQuery) < 0
				Alert(tcSqlError())
			Endif
			*/
			TABB->(dbSkip())
		enddo
		TABB->(dbCloseArea())

		SM7->(dbSetOrder(1))
		// verificar se existe benefício
		if len(aValeTran) > 0
			For nAux := 1 to len(aValeTran)

				DbSelectArea("SM7")
				If !(SM7->(dbSeek(aValeTran[nAux][1]+TFUNC->RA_MAT+aValeTran[nAux][6]+'0')))
					loop
				Endif
				RecLock("SM7", .F.)
				SM7->M7_FILIAL   := aValeTran[nAux][1]
				SM7->M7_MAT      := TFUNC->RA_MAT
				SM7->M7_CODIGO   := aValeTran[nAux][6]
				SM7->M7_TPVALE   := '0'
				SM7->M7_DPROPIN  := iif(aValeTran[nAux][3]<0,0,aValeTran[nAux][3]) //Dias para o cálculo da folha conforme a agenda
				SM7->M7_QDIAINF  := aValeTran[nAux][4] //Quantidade de vales por dia
				SM7->M7_TPCALC   := '1'
				SM7->M7_YDTPROC  := LastDate(stod(alltrim(mv_par01)+"01"))
				MsUnLock() // Confirma e finaliza a operação

				cQuery	:= "SELECT *  "
				cQuery	+=" FROM " + cNomTab + " "
				cQuery	+=" WHERE MATRICULA = '"+TFUNC->RA_MAT+"' "
				cQuery	+=" ORDER BY VA "
				tcQuery cQuery new Alias TINS

				If TINS->(!Eof())
					If empty(TINS->VT) //Edita o registro
						dbSelectArea(cAliasTRB)
						(cAliasTRB)->(dbSetOrder(1))
						(cAliasTRB)->(dbSeek(TFUNC->RA_MAT))
						Reclock(cAliasTRB,.F.)
						(cAliasTRB)->LOCAL		:= Posicione("ABS",1,xFilial("ABS")+aValeTran[nAux][5],"ABS_DESCRI")
						(cAliasTRB)->DESCVT 	:= aValeTran[nAux][2]
						(cAliasTRB)->QTVT 		:= aValeTran[nAux][3]
						(cAliasTRB)->QTVTDIA	:= aValeTran[nAux][4]
						(cAliasTRB)->VT 		:= aValeTran[nAux][6]
						(cAliasTRB)->QTAGEN 	:= aValeTran[nAux][7]
						(cAliasTRB)->QTFALT 	:= aValeTran[nAux][8]
						(cAliasTRB)->QTFERIAS 	:= aValeTran[nAux][9]
						(cAliasTRB)->QTDAVISO 	:= aValeTran[nAux][10]
						(cAliasTRB)->QTDAUSE 	:= aValeTran[nAux][11]
						MsUnlock()
					Else //Insere novo registro do vale alimentação
						Reclock(cAliasTRB,.t.)
						(cAliasTRB)->LOCAL		:= Posicione("ABS",1,xFilial("ABS")+aValeTran[nAux][5],"ABS_DESCRI")
						(cAliasTRB)->FILIAL		:= TFUNC->RA_FILIAL
						(cAliasTRB)->MATRICULA	:= TFUNC->RA_MAT
						(cAliasTRB)->NOMEFUN	:= TFUNC->RA_NOME
						(cAliasTRB)->DESCVT 	:= aValeTran[nAux][2]
						(cAliasTRB)->QTVT 		:= aValeTran[nAux][3]
						(cAliasTRB)->QTVTDIA 	:= aValeTran[nAux][4]
						(cAliasTRB)->VT 		:= aValeTran[nAux][6]
						(cAliasTRB)->QTAGEN 	:= aValeTran[nAux][7]
						(cAliasTRB)->QTFALT 	:= aValeTran[nAux][8]
						(cAliasTRB)->QTFERIAS 	:= aValeTran[nAux][9]
						(cAliasTRB)->QTDAVISO 	:= aValeTran[nAux][10]
						(cAliasTRB)->QTDAUSE 	:= aValeTran[nAux][11]
						MsUnlock()
					Endif
				Endif
				TINS->(dbCloseArea())

			next
		endif
		TFUNC->(dbSkip())
	enddo
	TFUNC->(dbCloseArea())

	dbSelectArea("SRA")
//	//Insalubridade / Periculosidade
//	cQuery:= "SELECT SRA.R_E_C_N_O_ RECNO, TFF_GRAUIN,TFF_PERICU FROM "+retSqlName("SRA")+" SRA "
//	cQuery+= "INNER JOIN "+retSqlName("ABB")+" ABB ON ABB_FILIAL = RA_FILIAL AND ABB_CODTEC = RA_FILIAL+RA_MAT "
//	cQuery+= "INNER JOIN "+retSqlName("ABQ")+" ABQ ON SUBSTRING(ABB_FILIAL,1,4) = ABQ_FILIAL AND ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) "  
//	cQuery+= "INNER JOIN "+retSqlName("TFF")+" TFF ON TFF_FILIAL = ABB_FILIAL AND TFF_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND RTRIM(TFF_LOCAL) = RTRIM(ABB_LOCAL) AND ABQ_CODTFF = TFF_COD "
//	cQuery+= "INNER JOIN "+RetSqlName("CN9")+" CN9 ON CN9_FILIAL = ABB_FILIAL AND CN9_NUMERO =  SUBSTRING(ABB_IDCFAL,1,15) AND CN9_REVATU = ' ' AND CN9_SITUAC IN ('05','06','07','08') "
//	cQuery+= "AND TFF_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND RTRIM(TFF_LOCAL) = RTRIM(ABB_LOCAL) "
//	//cQuery+= "AND TFF_FUNCAO = RA_CODFUNC "
//	cQuery+= "WHERE SRA.D_E_L_E_T_ =' ' "
//	cQuery+= "AND ABQ.D_E_L_E_T_= ' ' 	"
//	cQuery+= "AND ABB.D_E_L_E_T_= ' ' 	"
//	cQuery+= "AND TFF.D_E_L_E_T_=' ' 	"
//	cQuery+= "AND SUBSTRING(ABB_DTINI,1,6) = '"+alltrim(MV_PAR01)+"' "
//	cQuery+= "AND RA_MAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' 		"
//	cQuery+= "AND RA_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'	"
//	cQuery+= "AND ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'	"
//	cQuery+= "GROUP BY SRA.R_E_C_N_O_, TFF_GRAUIN,TFF_PERICU "
//	tcQuery cQuery new Alias TINSA
//	while TINSA->(!Eof())
//		SRA->(dbGoto(TINSA->RECNO))
//		recLock("SRA",.F.)
//		//Periculosidade
//		SRA->RA_ADCPERI	:= iif(TINSA->TFF_PERICU $ "2/3","2","1") //1=Não;2=Sim
//		cVar			:= "SRA->RA_ADCPERI"
//		fGPEA010Vld()
//
//		//Insalubridade
//		SRA->RA_ADCINS	:= TINSA->TFF_GRAUIN
//		cVar			:= "SRA->RA_ADCINS"
//		fGPEA010Vld()
//		msUnlock()
//
//		//Atualiza dados do relatório
//		cUpd:= "UPDATE "+oTmpTbl:GetRealName()+" SET INSAL = '"+SRA->RA_ADCINS+"', PERIC = '"+SRA->RA_ADCPERI+"'"
//		cUpd+= "WHERE MATRICULA = '"+SRA->RA_MAT+"' AND FILIAL = '"+SRA->RA_FILIAL+"' "
//		tcSqlExec(cUpd)
//		TINSA->(dbSkip())
//	Enddo
//	TINSA->(dbCloseArea())


Return

/*/{Protheus.doc} fCriaTemp
Criação da temporária
@author Diogo
@since 24/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fCriaTemp
	Local aStru:= {}
	Aadd(aStru,{"FILIAL"	,"C"	,TamSx3("RA_FILIAL")[1],0})
	Aadd(aStru,{"LOCAL"		,"C"	,TamSx3("ABS_DESCRI")[1],0})
	Aadd(aStru,{"MATRICULA"	,"C"	,TamSx3("RA_MAT")[1],0})
	Aadd(aStru,{"NOMEFUN"	,"C"	,TamSx3("RA_NOME")[1],0})
	Aadd(aStru,{"VA"		,"C"	,TamSx3("ZA2_VATIPO")[1],0})
	Aadd(aStru,{"DESCVA"	,"C"	,TamSx3("RFO_DESCR")[1],0})
	Aadd(aStru,{"QTVA"		,"N"	,3,0})
	Aadd(aStru,{"VT"		,"C"	,TamSx3("ZA2_VTTIPO")[1],0})
	Aadd(aStru,{"DESCVT"	,"C"	,TamSx3("RFO_DESCR")[1],0})
	Aadd(aStru,{"QTVT"		,"N"	,3,0})
	Aadd(aStru,{"QTVTDIA"	,"N"	,3,0})
	Aadd(aStru,{"QTAGEN"	,"N"	,3,0})
	Aadd(aStru,{"QTFALT"	,"N"	,3,0})
	Aadd(aStru,{"QTFERIAS"	,"N"	,3,0})
	Aadd(aStru,{"QTDAVISO"	,"N"	,3,0})
	Aadd(aStru,{"QTDAUSE"	,"N"	,3,0})
//	Aadd(aStru,{"INSAL"		,"C"	,20,0})
//	Aadd(aStru,{"PERIC"		,"C"	,20,0})

	oTmpTbl:SetFields(aStru)
	oTmpTbl:AddIndex("indice1", {"MATRICULA"} )
	oTmpTbl:Create()

Return

	/*/{Protheus.doc} fCriaTemp
	Impressão do relatório
	@author Diogo
	@since 24/12/2018
	@version undefined
	@example
	(examples)
	@see (links_or_references)
	/*/
	Static Functio fImpRel
	local oReport
	oReport := reportDef()
	oReport:printDialog()
Return

Static function reportDef()
	local oReport
	Local oSection1
	local cTitulo := 'Relatório Processamento Beneficios'

	oReport := TReport():New('RSERV12', cTitulo,'', {|oReport| PrintReport(oReport)},"Relatório Processamento Benefícios")
	oReport:SetLandscape()

	oSection1 := TRSection():New(oReport,"Beneficios",{"QRY"})
	oSection1:SetTotalInLine(.T.)


	TRCell():New(oSection1, "FILIAL"	, "QRY", 'FILIAL' 				,,TamSX3("RA_FILIAL")[1]+1,,)
	TRCell():New(oSection1, "MATRICULA"	, "QRY", 'MATRICULA' 			,,TamSX3("RA_MAT")[1]+1,,)
	TRCell():New(oSection1, "NOME"		, "QRY", 'NOME' 				,,TamSX3("RA_NOME")[1]+1,,)
	TRCell():New(oSection1, "LOCAL"		, "QRY", 'LOCAL'	 			,,TamSX3("RFO_DESCR")[1]+1,,)
	TRCell():New(oSection1, "BENEF"		, "QRY", 'BENEFICIO'			,,10,,)
	TRCell():New(oSection1, "DESCR"		, "QRY", 'DESCRIÇÃO'			,,13,,)
	TRCell():New(oSection1, "QTDIA"		, "QRY", 'POR DIA'			,"@E 999",8,,)
	TRCell():New(oSection1, "QTAGEN"	, "QRY", 'AGENDADO(A)'		,"@E 999",8,,)
	TRCell():New(oSection1, "QTFALT"	, "QRY", 'FALTAS(B)'		,"@E 999",8,,)
	TRCell():New(oSection1, "QTFERIAS"	, "QRY", 'FÉRIAS(C)'		,"@E 999",8,,)
	TRCell():New(oSection1, "QTDAVISO"	, "QRY", 'DIAS APOS FIM DO AVISO(D)',"@E 999",8,,)
	TRCell():New(oSection1, "QTDAUSE"	, "QRY", 'AUSENCIAS(E)'		,"@E 999",8,,)
	TRCell():New(oSection1, "QTBENEF"	, "QRY", 'BENEF (A-B-C-D-E)',"@E 999",8,,)
//	TRCell():New(oSection1, "INSAL"		, "QRY", 'INSALUBRID.'			,,20,,)
//	TRCell():New(oSection1, "PERIC"		, "QRY", 'PERICUL.'				,,20,,)
Return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local cNomTab := oTmpTbl:GetRealName()

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	cQuery	:= "SELECT FILIAL, NOMEFUN, MATRICULA  "
	cQuery	+=" FROM " + cNomTab + " "
	cQuery	+=" WHERE (VA <>' ' OR VT <> ' ' )"
	cQuery	+=" GROUP BY FILIAL, NOMEFUN, MATRICULA  "
	tcQuery cQuery new Alias TREL

	while TREL->(!Eof())

		//Busca vale alimentação
		cQuery	:= "SELECT NOMEFUN,FILIAL,MATRICULA,LOCAL,VA,DESCVA,QTVA,QTAGEN,QTFALT,QTFERIAS,QTDAVISO,QTDAUSE  "
		cQuery	+=" FROM " + cNomTab + " "
		cQuery	+=" WHERE MATRICULA = '"+TREL->MATRICULA+"' "
		cQuery	+=" AND VA <>' ' "
		cQuery	+=" GROUP BY NOMEFUN,FILIAL,MATRICULA,LOCAL,VA,DESCVA,QTVA,QTAGEN,QTFALT,QTFERIAS,QTDAVISO,QTDAUSE "
		cQuery	+=" ORDER BY FILIAL,NOMEFUN,MATRICULA "
		tcQuery cQuery new Alias TALIM

		while TALIM->(!Eof())
			oSection1:Cell("NOME"):SetValue(TALIM->NOMEFUN)
			oSection1:Cell("FILIAL"):SetValue(TALIM->FILIAL)
			oSection1:Cell("MATRICULA"):SetValue(TALIM->MATRICULA)
			oSection1:Cell("LOCAL"):SetValue(TALIM->LOCAL)
			oSection1:Cell("BENEF"):SetValue(TALIM->VA)
			oSection1:Cell("DESCR"):SetValue(TALIM->DESCVA)
			oSection1:Cell("QTAGEN"):SetValue(TALIM->QTAGEN )
			oSection1:Cell("QTFALT"):SetValue(TALIM->QTFALT)
			oSection1:Cell("QTFERIAS"):SetValue(TALIM->QTFERIAS)
			oSection1:Cell("QTDAVISO"):SetValue(TALIM->QTDAVISO)
			oSection1:Cell("QTDAUSE"):SetValue(TALIM->QTDAUSE)
			oSection1:Cell("QTBENEF"):SetValue(TALIM->QTVA)
			oSection1:Cell("QTDIA"):SetValue(1)
//			If alltrim(TALIM->INSAL) == "1"
//				oSection1:Cell("INSAL"):SetValue("Nenhuma")
//			Elseif alltrim(TALIM->INSAL) ==  "2"
//				oSection1:Cell("INSAL"):SetValue("Minima")
//			Elseif alltrim(TALIM->INSAL) == "3"
//				oSection1:Cell("INSAL"):SetValue("Média")
//			Elseif alltrim(TALIM->INSAL) == "4"
//				oSection1:Cell("INSAL"):SetValue("Máxima")
//			Endif
//			If alltrim(TALIM->PERIC) == "2"
//				oSection1:Cell("PERIC"):SetValue("Sim")
//			Else
//				oSection1:Cell("PERIC"):SetValue("Não")
//			Endif
			oSection1:PrintLine()
			TALIM->(dbSkip())
		Enddo
		TALIM->(dbCloseArea())

		//Busca vale transporte
		cQuery	:= "SELECT NOMEFUN,FILIAL,MATRICULA,LOCAL,VT,DESCVT,QTVT,QTVTDIA,QTAGEN,QTFALT,QTFERIAS,QTDAVISO,QTDAUSE  "
		cQuery	+=" FROM " + cNomTab + " "
		cQuery	+=" WHERE MATRICULA = '"+TREL->MATRICULA+"' "
		cQuery	+=" AND VT <>' '  "
		cQuery	+=" GROUP BY NOMEFUN,FILIAL,MATRICULA,LOCAL,VT,DESCVT,QTVT,QTVTDIA,QTAGEN,QTFALT,QTFERIAS,QTDAVISO,QTDAUSE "
		cQuery	+=" ORDER BY FILIAL,NOMEFUN,MATRICULA "
		tcQuery cQuery new Alias TVT

		while TVT->(!Eof())
			oSection1:Cell("NOME"):SetValue(TVT->NOMEFUN)
			oSection1:Cell("FILIAL"):SetValue(TVT->FILIAL)
			oSection1:Cell("MATRICULA"):SetValue(TVT->MATRICULA)
			oSection1:Cell("LOCAL"):SetValue(TVT->LOCAL)
			oSection1:Cell("BENEF"):SetValue(TVT->VT)
			oSection1:Cell("DESCR"):SetValue(TVT->DESCVT)
			oSection1:Cell("QTAGEN"):SetValue(TVT->QTAGEN )
			oSection1:Cell("QTFALT"):SetValue(TVT->QTFALT)
			oSection1:Cell("QTFERIAS"):SetValue(TVT->QTFERIAS)
			oSection1:Cell("QTDAVISO"):SetValue(TVT->QTDAVISO)
			oSection1:Cell("QTDAUSE"):SetValue(TVT->QTDAUSE)
			oSection1:Cell("QTBENEF"):SetValue(TVT->QTVT)
			oSection1:Cell("QTDIA"):SetValue(TVT->QTVTDIA)
//			If alltrim(TVT->INSAL) == "1"
//				oSection1:Cell("INSAL"):SetValue("Nenhuma")
//			Elseif alltrim(TVT->INSAL) == "2"
//				oSection1:Cell("INSAL"):SetValue("Minima")
//			Elseif alltrim(TVT->INSAL) == "3"
//				oSection1:Cell("INSAL"):SetValue("Média")
//			Elseif alltrim(TVT->INSAL) == "4"
//				oSection1:Cell("INSAL"):SetValue("Máxima")
//			Endif
//			If alltrim(TVT->PERIC) == "2"
//				oSection1:Cell("PERIC"):SetValue("Sim")
//			Else
//				oSection1:Cell("PERIC"):SetValue("Não")
//			Endif

			oSection1:PrintLine()
			TVT->(dbSkip())
		Enddo
		TVT->(dbCloseArea())

		TREL->(dbSkip())
	Enddo
	TREL->(dbCloseArea())
	oSection1:Finish()
Return

Static Function fGPEA010Vld()
	Local lRet		:= .T.
	Local cConteudo := &( cVar )
	Local cValidos	:= ""
	If (;
			( cVar == "SRA->RA_CATFUNC" );
			.And.;
			( cPaisLoc <> "BRA" );
			)
		If ( cPaisLoc == "CHI" )
			cValidos	:=	"ACEGMT"
		ElseIf ( cPaisLoc == "PAR" )
			cValidos	:=	"AEGHMTS"
		ElseIf ( cPaisLoc == "DOM" ) .Or. ( cPaisLoc == "COS" )
			cValidos	:=	"DEGHMST"
		ElseIf ( cPaisLoc == "ARG" )
			cValidos	:=	"ACDEGHMST"
		ElseIf ( cPaisLoc == "VEN" )
			cValidos	:=	"12ACDEGHIJMPST"
		ElseIf ( cPaisLoc == "BOL" )
			cValidos	:=	"ACHMPST"
		ElseIf ( cPaisLoc == "PER" )
			cValidos	:=	"CDEGHMST"
		ElseIf ( cPaisLoc == "EQU" )
			cValidos	:=	"12ACEHMOPS"
		Else
			cValidos	:=	"ACDEGHMST"
		EndIf
		If !( lRet := ( cConteudo $ cValidos ) )
			Help('',1,'GPEA010001') // "Categoria nao disponivel para esta versao"
		EndIf
	ElseIf cPaisLoc == "BRA" .AND. cVar == "SRA->RA_CATFUNC" .AND. cConteudo $ "A|P" //SE AUTONOMO ATRIBUI CODIGO ZERADO PARA A CPTS(POIS OS CAMPOS SAO OBRIGATORIOS)
		SRA->RA_NUMCP := "0000000"
		SRA->RA_SERCP := "00000"
	EndIf

	If cVar == "SRA->RA_CARGO"
		lRet		:= 	Empty(cVar) .Or. SQ3->(DbSeek(xFilial("SQ3")+SRA->RA_CARGO+SRA->RA_CC))
		If !lRet
			cValidos:=	fDesc("SQ3",SRA->RA_CARGO,"Q3_CC")
			If !Empty(cValidos)
				Aviso(OemToAnsi("Atenção"),OemToAnsi("Não existe o cargo ")+SRA->RA_CARGO+OemToAnsi(" para o centro de custo ")+SRA->RA_CC+	;
					OemToAnsi(".Informe cargo valido. "),{OemToAnsi("ok")},,OemToAnsi("Cargo informado invalido"))
				lRet	:=	.F.
			Else
				lRet	:=	.T.
			EndIf
		EndIf
	EndIf


	If cVar == "SRA->RA_HRSMES"
		If SRA->RA_PERICUL > cConteudo .And. SRA->RA_ADCPERI == '2'
			SRA->RA_PERICUL := cConteudo
		EndIf
		If SRA->RA_INSMAX > cConteudo .And. SRA->RA_ADCINS == '2'
			SRA->RA_INSMAX := cConteudo
		EndIf
	EndIf
	/*Checagem dos dados de periculosidade*/
	If cModulo != "MNT"
		If  SRA->RA_HRSMES > 0 .And. SRA->RA_ADCPERI == '2'
			SRA->RA_PERICUL := SRA->RA_HRSMES
		Else
			SRA->RA_PERICUL := 0
		EndIf

		/*Checagem dos dados de insalubridade*/
		If  SRA->RA_HRSMES > 0 .And. IIF(IsmemVar("RA_ADCINS"),Val(SRA->RA_ADCINS) >= 2 , .t.)
			SRA->RA_INSMAX := SRA->RA_HRSMES
		Else
			SRA->RA_INSMAX := 0
		EndIf
	EndIf

Return( lRet )

/*/{Protheus.doc} fGetDias
Retorna a quantidade de dias locados
@author Diogo
@since 18/02/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetDias(cFilQ,cCodTecQ,cLocalQ,cContraQ,_CTIPO)
	Local aArea	:= getArea()
	Local nRet	:= 0
	Local lAviso := .F.
	Local lCalendRCG := .T.

	//Verifica se o funcionario está cumprindo aviso, caso esteja cumprindo aviso, calcula apenas proporcional
	DbselectArea("RFY")
	DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
	Dbseek(Alltrim(cCodTecQ))
	If FOUND() .AND. EMPTY(RFY->RFY_DTCAP)
		lAviso := .T.
	else
		lAviso := .F.
	EndIf

	cQuery:= "SELECT TDX_TURNO TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI FROM "+RetSqlName("ABB")+" ABB "

	cQuery+= "INNER JOIN "+RetSqlName("ABQ")+" ABQ "
	cQuery+= "ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "

	cQuery+= "INNER JOIN "+RetSqlName("TFF")+" TFF "
	cQuery+= "ON ABB_FILIAL = TFF_FILIAL "
	cQuery+= "AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT "
	cQuery+= "AND ABQ_CODTFF = TFF_COD "

	cQuery+= "INNER JOIN "+RetSqlName("TDX")+" TDX "
	cQuery+= "ON TDX_FILIAL = TFF_FILIAL "
	cQuery+= "AND TDX_CODTDW = TFF_ESCALA "

	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND  "
	cQuery+= "ABQ.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFF.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TDX.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFF_ESCALA <> ' ' AND "
	cQuery+= "TFF_FILIAL= '"+cFilQ+"' AND  "
	cQuery+= "ABB_CODTEC  = '"+cCodTecQ+"' AND "
	///cQuery+= "ABB_LOCAL = '"+cLocalQ+"' AND  "
	cQuery+= "TFF_CONTRT = '"+cContraQ+"' AND "
	cQuery+= "SUBSTRING(ABB_DTINI,1,6) = '"+alltrim(MV_PAR01)+"' AND "
	cQuery+= "ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery+= "GROUP BY TDX_TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI  "

	cQuery+= "UNION ALL "

	cQuery+= "SELECT TFF_TURNO TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI FROM "+RetSqlName("ABB")+" ABB "

	cQuery+= "INNER JOIN "+RetSqlName("ABQ")+" ABQ "
	cQuery+= "ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "

	cQuery+= "INNER JOIN "+RetSqlName("TFF")+" TFF "
	cQuery+= "ON ABB_FILIAL = TFF_FILIAL "
	cQuery+= "AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT "
	cQuery+= "AND ABQ_CODTFF = TFF_COD "

	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND  "
	cQuery+= "ABQ.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFF.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFF_ESCALA = ' ' AND "
	cQuery+= "TFF_FILIAL= '"+cFilQ+"' AND  "
	cQuery+= "ABB_CODTEC  = '"+cCodTecQ+"' AND "
	///cQuery+= "ABB_LOCAL = '"+cLocalQ+"' AND  "
	cQuery+= "TFF_CONTRT = '"+cContraQ+"' AND "
	cQuery+= "SUBSTRING(ABB_DTINI,1,6) = '"+alltrim(MV_PAR01)+"' AND "
	cQuery+= "ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery+= "GROUP BY TFF_TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI  "

	cQuery+= "ORDER BY ABB_DTINI "
	tcQuery cQuery new Alias QRQCOUNT

	while QRQCOUNT->(!Eof())
		//Busca na SPJ o dia da semana ativo
		cDTroc:= cvaltochar(dow(stod(QRQCOUNT->ABB_DTINI)))
		cQuery:= "SELECT PJ_ENTRA1 FROM "+RetSqlName("SPJ")+" SPJ "
		cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
		cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",cFilQ)+"' AND "
		cQuery+= "PJ_TURNO = '"+QRQCOUNT->TURNO+"' AND "
		cQuery+= "PJ_TPDIA = 'S' AND "
		cQuery+= "PJ_DIA = '"+cDTroc+"' "
		IF _CTIPO == "VAL" .AND. _csind <> "10"
			cQuery+= " AND PJ_HRTOTAL >= 6 "
		ELSEIF _CTIPO = "VTR" .OR. _csind == "10"
			cQuery+= " AND PJ_HRTOTAL >= 4 "
		ENDIF
		tcQuery cQuery new Alias QRTUR
		If QRTUR->(!Eof())
			If abs(QRTUR->PJ_ENTRA1 - val(replace(QRQCOUNT->ABB_HRINI,":","."))) < 1

				//abs(QRTUR->PJ_ENTRA1 - val(substr(QRQCOUNT->ABB_HRINI,1,2))) < 1 //Diferença pode ser em minutos
				/*
				//Valida calendario turno RCG
				lCalendRCG := .T.
				cQuery := " "
				cQuery += " SELECT RCG_VTRANS FROM "+RetSqlName("RCG")+" RCG "
				cQuery += " WHERE RCG.D_E_L_E_T_ = ' '  "
				cQuery += " AND RCG_FILIAL = '"+xFilial("RCG",cFilQ)+"' "
				cQuery += " AND RCG_TNOTRA = '"+QRQCOUNT->TURNO+"' "
				cQuery += " AND RCG_DIAMES = '"+QRQCOUNT->ABB_DTINI+"' "
				
				tcQuery cQuery new Alias QRRCG
				If QRRCG->(!Eof())
					If QRRCG->RCG_VTRANS == "2"
						lCalendRCG := .F.
					EndIf
				Endif
				QRRCG->(dbCloseArea())
				*/
				If lCalendRCG
					If lAviso
						IF QRQCOUNT->ABB_DTINI <= DtoS(RFY->RFY_DTPJAV )
							nRet += 1

							IF _CTIPO == "VAL"
								aAdd(adiasval,QRQCOUNT->ABB_DTINI)
							ELSEIF _CTIPO = "VTR"
								aAdd(adiasvtr,QRQCOUNT->ABB_DTINI)
							ENDIF

							//Considera como horário inicial de entrada
							/*
							//verifica se existe cadastro de ausencia na folha SR8
							cQuery:= " SELECT R8_MAT FROM "+RetSqlName("SR8")+" SR8 "
							cQuery+= " WHERE SR8.D_E_L_E_T_ = ' ' "
							cQuery+= " AND R8_FILIAL + R8_MAT  = '"+cCodTecQ+"'  "
							cQuery+= " AND R8_DATAINI <= '"+QRQCOUNT->ABB_DTINI+"' "
							cQuery+= " AND ( R8_DATAFIM >= '"+QRQCOUNT->ABB_DTINI+"' OR R8_DATAFIM = '' ) "
							If Select("TEMPSR8") > 0
								TEMPSR8->(dbCloseArea())
							EndIf
							tcQuery cQuery new Alias TEMPSR8
							If TEMPSR8->(!Eof())
								nQtdAuse += 1
							EndIf
							TEMPSR8->(dbCloseArea())
							*/
						else
							nRet += 1
							nDescAviso += 1
						EndIf
					else
						nRet+= 1 //Considera como horário inicial de entrada

						IF _CTIPO == "VAL"
							aAdd(adiasval,QRQCOUNT->ABB_DTINI)
						ELSEIF _CTIPO = "VTR"
							aAdd(adiasvtr,QRQCOUNT->ABB_DTINI)
						ENDIF
						/*
						//verifica se existe cadastro de ausencia na folha SR8
						cQuery:= " SELECT R8_MAT FROM "+RetSqlName("SR8")+" SR8 "
						cQuery+= " WHERE SR8.D_E_L_E_T_ = ' ' "
						cQuery+= " AND R8_FILIAL + R8_MAT  = '"+cCodTecQ+"'  "
						cQuery+= " AND R8_DATAINI <= '"+QRQCOUNT->ABB_DTINI+"' "
						cQuery+= " AND ( R8_DATAFIM >= '"+QRQCOUNT->ABB_DTINI+"' OR R8_DATAFIM = '' ) "
						If Select("TEMPSR8") > 0
							TEMPSR8->(dbCloseArea())
						EndIf
						tcQuery cQuery new Alias TEMPSR8
						If TEMPSR8->(!Eof())
							nQtdAuse += 1
						EndIf
						TEMPSR8->(dbCloseArea())
						*/
					EndIf
				EndIf
			Endif
		Endif
		QRTUR->(dbCloseArea())
		QRQCOUNT->(dbSkip())
	Enddo
	QRQCOUNT->(dbCloseArea())
	RestArea(aArea)
Return nRet


Static Function fGetFolh(cFilQ,cCodTecQ,cLocalQ,cContraQ,_CTIPO)
	Local nRetF:= 0
	Local aArea	:= getArea()
	Local lCalendRCG := .T.

	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	SRA->(dbSeek(TABB->ABB_CODTEC))
	_CTURNO := SRA->RA_TNOTRAB
	dPerDe11 := STOD(MV_PAR01+"01")
	dPerDe12 := LastDay(STOD(MV_PAR01+"01")) //STOD(MV_PAR01+"31")
	//ConOut('Iniciando calculo férias...')
	While dPerDe11 <=  dPerDe12
	//	ConOut('consulta férias data ...'+dtoc(dPerDe11))
		cQuery := "  SELECT R8_MAT "
		cQuery += "  FROM "+RetSqlName("SR8")+ " SR8 "
		cQuery += " INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM_TIPOAF = '4' AND RCM.D_E_L_E_T_ = '' "
		cQuery += "  WHERE SR8.D_E_L_E_T_='' "
		cQuery += "  AND R8_MAT = '"+ substr(cCodTecQ,7,6) +"' AND  R8_FILIAL ='"+ substr(cCodTecQ,1,6) +"' "
		cQuery += "  AND ( '"+dtos(dPerDe11)+"' BETWEEN R8_DATAINI AND R8_DATAFIM  ) "
		//cQuery += "  AND RCM_YCESTA = 'S' "

		If select("TEMPSR8") > 0
			TEMPSR8->(dbCloseArea())
		Endif
		TcQuery cQuery new Alias TEMPSR8

		If !TEMPSR8->(eof())
		//	ConOut('achou férias data ...'+dtoc(dPerDe11))
			cQuery:= " SELECT COUNT(*) CONT "
			cQuery+= " FROM "+RetSqlName("ABB")+" ABB "
			cQuery+= " INNER JOIN "+RetSqlName("ABQ")+" ABQ ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "
			cQuery+= " INNER JOIN "+RetSqlName("TFF")+" TFF ON ABB_FILIAL = TFF_FILIAL AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT AND ABQ_CODTFF = TFF_COD "
			cQuery+= " INNER JOIN "+RetSqlName("TDX")+" TDX ON TDX_FILIAL = TFF_FILIAL AND TDX_CODTDW = TFF_ESCALA "
			cQuery+= " WHERE ABB.D_E_L_E_T_=' ' AND "
			cQuery+= " TFF.D_E_L_E_T_=' ' AND TDX.D_E_L_E_T_=' ' AND "
			cQuery+= " TFF_FILIAL= '"+cFilQ+"' AND  "
			cQuery+= " ABB_CODTEC  = '"+cCodTecQ+"' AND "
			cQuery+= " TFF_CONTRT = '"+cContraQ+"' AND "
			cQuery+= " ABB_DTINI BETWEEN '"+dtos(dPerDe11)+"' AND '"+dtos(dPerDe11)+"' AND "
			//cQuery+= " RH_DATAINI >= '"+dtos(dPerDe)+"' AND RH_DATAFIM <=  '"+dtos(dPerAte)+"' AND "
			cQuery+= " ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "

			tcQuery cQuery new Alias T10

			If !T10->(eof()) .AND. T10->CONT > 0
			//	ConOut('achou agenda data ...'+dtoc(dPerDe11))
				_nncont := 1
				if _CTIPO == "VAL"
					while _nncont <= len(adiasval)
						if adiasval[_nncont] == dtos(dPerDe11)
							nRetF+= 1 //Considera como horário inicial de entrada
							nQtFer+= 1
							_nncont := len(adiasval)
							//ConOut('computou férias data ...'+dtoc(dPerDe11))
						endif
						_nncont++
					enddo
				elseif  _CTIPO == "VTR"
					while _nncont <= len(adiasVTR)
						if adiasVTR[_nncont] == dtos(dPerDe11)
							nRetF+= 1 //Considera como horário inicial de entrada
							nQtFer+= 1
							_nncont := len(adiasVTR)
						//	ConOut('computou férias data ...'+dtoc(dPerDe11))
						endif
						_nncont++
					enddo
				ENDIF
			ENDIF
			T10->(dbCloseArea())
		Endif
		TEMPSR8->(dbCloseArea())
		dPerDe11 := DaySum(dPerDe11,1)
	ENDDO

	//Férias - PERIODO ANTERIOR
	/*
	cQuery:= "SELECT TDX_TURNO TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI FROM "+RetSqlName("ABB")+" ABB "
	cQuery+= "INNER JOIN "+RetSqlName("ABQ")+" ABQ "
	cQuery+= "ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "
	cQuery+= "INNER JOIN "+RetSqlName("TFF")+" TFF "
	cQuery+= "ON ABB_FILIAL = TFF_FILIAL "
	cQuery+= "AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT "
	cQuery+= "AND ABQ_CODTFF = TFF_COD "
	cQuery+= "INNER JOIN "+RetSqlName("TDX")+" TDX "
	cQuery+= "ON TDX_FILIAL = TFF_FILIAL "
	cQuery+= "AND TDX_CODTDW = TFF_ESCALA "
	cQuery+= "INNER JOIN "+RetSqlName("SRH")+" SRH "
	cQuery+= "ON RH_FILIAL = ABB_FILIAL AND RH_FILIAL+RH_MAT = '"+cCodTecQ+"' "
	cQuery+= "WHERE ABB.D_E_L_E_T_ = ' ' AND  "
	cQuery+= "ABQ.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFF.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TDX.D_E_L_E_T_ = ' ' AND "
	cQuery+= "SRH.D_E_L_E_T_ = ' ' AND "
	cQuery+= "TFF_ESCALA <> ' ' AND "
	cQuery+= "TFF_FILIAL= '"+cFilQ+"' AND  "
	cQuery+= "ABB_CODTEC  = '"+cCodTecQ+"' AND "
	cQuery+= "TFF_CONTRT = '"+cContraQ+"' AND "
	//cQuery+= "ABB_DTINI BETWEEN '"+dtos(dPerDe)+"' AND '"+dtos(dPerAte)+"' AND "
	//cQuery+= "(RH_DATAINI >= '"+dtos(dPerDe)+"' OR RH_DATAFIM <= '"+dtos(dPerAte)+"') AND "
	cQuery+= "SUBSTRING(ABB_DTINI,1,6) = '"+MV_PAR01+"' AND "
	cQuery+= "(SUBSTRING(RH_DATAINI,1,6) = '"+MV_PAR01+"' OR SUBSTRING(RH_DATAFIM,1,6) = '"+MV_PAR01+"') AND "
	cQuery+= "ABB_DTINI <= RH_DATAFIM AND "
	cQuery+= "ABB_DTINI >= RH_DATAINI AND "
	cQuery+= "ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery+= "GROUP BY TDX_TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI  "
	tcQuery cQuery new Alias QRSRH
	while QRSRH->(!Eof())
		/*
		//Valida calendario turno RCG
		lCalendRCG := .T.
		cQuery := " "
		cQuery += " SELECT RCG_VTRANS FROM "+RetSqlName("RCG")+" RCG "
		cQuery += " WHERE RCG.D_E_L_E_T_ = ' '  "
		cQuery += " AND RCG_FILIAL = '"+xFilial("RCG",cFilQ)+"' "
		cQuery += " AND RCG_TNOTRA = '"+QRSRH->TURNO+"' "
		cQuery += " AND RCG_DIAMES = '"+QRSRH->ABB_DTINI+"' "

		tcQuery cQuery new Alias QRRCG
		If QRRCG->(!Eof())
			If QRRCG->RCG_VTRANS == "2"
				lCalendRCG := .F.
			EndIf
		Endif
		QRRCG->(dbCloseArea())
		*//*
		If lCalendRCG
			//Busca na SPJ o dia da semana ativo
			cDTroc:= cvaltochar(dow(stod(QRSRH->ABB_DTINI)))
			cQuery:= " SELECT PJ_ENTRA1 FROM "+RetSqlName("SPJ")+" SPJ "
			cQuery+= " WHERE SPJ.D_E_L_E_T_ = ' ' AND "
			cQuery+= " PJ_FILIAL = '"+xFilial("SPJ",cFilQ)+"' AND "
			cQuery+= " PJ_TURNO = '"+QRSRH->TURNO+"' AND "
			cQuery+= " PJ_TPDIA = 'S' AND "
			cQuery+= " PJ_DIA = '"+cDTroc+"' "
			cQuery+= " AND PJ_HRTOTAL >= 6 "
			tcQuery cQuery new Alias QRTUR
			If QRTUR->(!Eof())
				If abs(QRTUR->PJ_ENTRA1 - val(substr(QRSRH->ABB_HRINI,1,2))) < 1 //Diferença pode ser em minutos
					nRetF+= 1 //Considera como horário inicial de entrada
					nQtFer+= 1 //Soma quantidade de férias
				Endif
			Endif
			QRTUR->(dbCloseArea())
		EndIf
		QRSRH->(dbSkip())
	Enddo
	QRSRH->(dbCloseArea())
*/
	//Diminuir faltas - GS
	cQuery:= " SELECT RA_FILIAL,RA_MAT,RA_NOMECMP,ABB_HRINI,ABB_HRFIM,ABR_MOTIVO,ABB_DTINI,TFF_TURNO,TDX_TURNO TURNO "
	cQuery+= " FROM "+RetSqlName("ABB")+" ABB "
	cQuery+= " INNER JOIN "+RetSqlName("AA1")+" AA1 ON  ABB_CODTEC=AA1_CODTEC AND AA1_FILIAL=ABB_FILIAL "
	cQuery+= " INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL=ABB_FILIAL  AND AA1_CDFUNC=RA_MAT AND AA1_FILIAL=RA_FILIAL "
	cQuery+= " INNER JOIN "+RetSqlName("ABR")+" ABR ON ABB_FILIAL = ABR_FILIAL AND ABR_AGENDA=ABB_CODIGO "
	cQuery+= " INNER JOIN "+RetSqlName("ABN")+" ABN ON ABN_CODIGO = ABR_MOTIVO "
	cQuery+= " INNER JOIN "+RetSqlName("ABQ")+" ABQ ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "
	cQuery+= " INNER JOIN "+RetSqlName("TFF")+" TFF ON ABB_FILIAL = TFF_FILIAL AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT AND ABQ_CODTFF = TFF_COD "
	cQuery+= " INNER JOIN "+RetSqlName("TDX")+" TDX ON TDX_FILIAL = TFF_FILIAL AND TDX_CODTDW = TFF_ESCALA "
	cQuery+= " WHERE ABB.D_E_L_E_T_=' ' AND AA1.D_E_L_E_T_=' ' AND "
	cQuery+= " SRA.D_E_L_E_T_=' ' AND ABR.D_E_L_E_T_=' ' AND "
	cQuery+= " ABN.D_E_L_E_T_=' ' AND ABQ.D_E_L_E_T_=' ' AND "
	cQuery+= " TFF.D_E_L_E_T_=' ' AND TDX.D_E_L_E_T_=' ' AND "
	cQuery+= " ABN_YGRFAL = 'S' AND " //Campo criado para considerar falta
	//cQuery+= " ABN_CODIGO IN ("+alltrim(supergetMv("SV_ABNCOD",,"'000001','000013'"))+") AND " //Ocorrencias que representam falta
	cQuery+= " TFF_FILIAL= '"+cFilQ+"' AND  "
	cQuery+= " ABB_CODTEC  = '"+cCodTecQ+"' AND "
	cQuery+= " TFF_CONTRT = '"+cContraQ+"' AND "
	cQuery+= " ABB_DTINI BETWEEN '"+dtos(dPerDe)+"' AND '"+dtos(dPerAte)+"' AND "
	//cQuery+= " RH_DATAINI >= '"+dtos(dPerDe)+"' AND RH_DATAFIM <=  '"+dtos(dPerAte)+"' AND "
	cQuery+= " ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery+= " GROUP BY RA_FILIAL,RA_MAT,RA_NOMECMP,ABB_HRINI,ABB_HRFIM,ABR_MOTIVO,ABB_DTINI,TFF_TURNO,TDX_TURNO "
	tcQuery cQuery new Alias QRSRH
	//ConOut('iniciando faltas gs ')
	while QRSRH->(!Eof())
		/*
		//Valida calendario turno RCG
		lCalendRCG := .T.
		cQuery := " "
		cQuery += " SELECT RCG_VTRANS FROM "+RetSqlName("RCG")+" RCG "
		cQuery += " WHERE RCG.D_E_L_E_T_ = ' '  "
		cQuery += " AND RCG_FILIAL = '"+xFilial("RCG",cFilQ)+"' "
		cQuery += " AND RCG_TNOTRA = '"+QRSRH->TURNO+"' "
		cQuery += " AND RCG_DIAMES = '"+QRSRH->ABB_DTINI+"' "

		tcQuery cQuery new Alias QRRCG
		If QRRCG->(!Eof())
			If QRRCG->RCG_VTRANS == "2"
				lCalendRCG := .F.
			EndIf
		Endif
		QRRCG->(dbCloseArea())
		*/
		If lCalendRCG
			//Busca na SPJ o dia da semana ativo
			cDTroc:= cvaltochar(dow(stod(QRSRH->ABB_DTINI)))
			cQuery:= "SELECT PJ_ENTRA1 FROM "+RetSqlName("SPJ")+" SPJ "
			cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
			cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",cFilQ)+"' AND "
			cQuery+= "PJ_TURNO = '"+QRSRH->TURNO+"' AND "
			cQuery+= "PJ_TPDIA = 'S' AND "
			cQuery+= "PJ_DIA = '"+cDTroc+"' "
			cQuery+= " AND PJ_HRTOTAL >= 6 "
			tcQuery cQuery new Alias QRTUR
			If QRTUR->(!Eof())
				If abs(QRTUR->PJ_ENTRA1 - val(replace(QRSRH->ABB_HRINI,":","."))) < 1
					//abs(QRTUR->PJ_ENTRA1 - val(substr(QRSRH->ABB_HRINI,1,2))) < 1 //Diferença pode ser em minutos
					nRetF+= 1 //Considera como horário inicial de entrada
					nQtFtl+= 1 //Soma quantidade de férias
			//		ConOut('achou faltas gs ' +QRSRH->ABB_DTINI)
				Endif
			Endif
			QRTUR->(dbCloseArea())
		EndIf
		QRSRH->(dbSkip())
	Enddo
	QRSRH->(dbCloseArea())
	nDiasSR8 := 0
	dPerDe11 := dPerDe
		//ConOut('iniciando faltas afastamento ')
	While dPerDe11 <=  dPerAte
		_FLAG := .T.
		cQuery := "  SELECT R8_MAT, R8_DATAFIM "
		cQuery += "  FROM "+RetSqlName("SR8")+ " SR8 "
		cQuery += " INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM_TIPOAF <> '4' AND RCM.D_E_L_E_T_ = '' AND RCM_YAUSEN = 'S' "
		cQuery += "  WHERE SR8.D_E_L_E_T_='' "
		cQuery += "  AND R8_MAT = '"+ substr(cCodTecQ,7,6) +"' AND  R8_FILIAL ='"+ substr(cCodTecQ,1,6) +"' "
		cQuery += "  AND ( R8_DATAINI <= '"+dtos(dPerDe11)+"' AND (R8_DATAFIM >= '"+dtos(dPerDe11)+"' OR R8_DATAFIM = ' ' )  ) "
		//cQuery += "  AND RCM_YCESTA = 'S' "

		If select("TEMPSR8") > 0
			TEMPSR8->(dbCloseArea())
		Endif
		TcQuery cQuery new Alias TEMPSR8

		If !TEMPSR8->(eof())
			if empty(TEMPSR8->R8_DATAFIM) .OR. SUBSTR(TEMPSR8->R8_DATAFIM,1,6) > mv_par01
				_lafasa := .t.
			//	ConOut('afastado definitivo ')
			endif
			cQuery:= " SELECT * "
			cQuery+= " FROM "+RetSqlName("ABB")+" ABB "
			cQuery+= " INNER JOIN "+RetSqlName("ABQ")+" ABQ ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "
			cQuery+= " INNER JOIN "+RetSqlName("TFF")+" TFF ON ABB_FILIAL = TFF_FILIAL AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT AND ABQ_CODTFF = TFF_COD "
			cQuery+= " INNER JOIN "+RetSqlName("TDX")+" TDX ON TDX_FILIAL = TFF_FILIAL AND TDX_CODTDW = TFF_ESCALA "
			cQuery+= " WHERE ABB.D_E_L_E_T_=' ' AND "
			cQuery+= " TFF.D_E_L_E_T_=' ' AND TDX.D_E_L_E_T_=' ' AND "
			cQuery+= " TFF_FILIAL= '"+cFilQ+"' AND  "
			cQuery+= " ABB_CODTEC  = '"+cCodTecQ+"' AND "
			cQuery+= " TFF_CONTRT = '"+cContraQ+"' AND "
			cQuery+= " ABB_DTINI BETWEEN '"+dtos(dPerDe11)+"' AND '"+dtos(dPerDe11)+"' AND "
			//cQuery+= " RH_DATAINI >= '"+dtos(dPerDe)+"' AND RH_DATAFIM <=  '"+dtos(dPerAte)+"' AND "
			cQuery+= " ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "

			tcQuery cQuery new Alias T10

			while !T10->(eof()) //.AND. T10->CONT > 0


				cDTroc:= cvaltochar(dow(dPerDe11))
				cQuery:= "SELECT PJ_ENTRA1 FROM "+RetSqlName("SPJ")+" SPJ "
				cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
				cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",cFilQ)+"' AND "
				cQuery+= "PJ_TURNO = '"+T10->TDX_TURNO+"' AND PJ_SEMANA = '"+T10->TDX_SEQTUR+"' AND "
				cQuery+= "PJ_TPDIA = 'S' AND "
				cQuery+= "PJ_DIA = '"+cDTroc+"' "
				cQuery+= " AND PJ_HRTOTAL >= 6 "
				tcQuery cQuery new Alias QRTUR
				If QRTUR->(!Eof()) .AND. _FLAG 
					If abs(QRTUR->PJ_ENTRA1 - val(replace(T10->ABB_HRINI,":","."))) < 1
						//abs(QRTUR->PJ_ENTRA1 - val(substr(QRSRH->ABB_HRINI,1,2))) < 1 //Diferença pode ser em minutos
						nRetF+= 1 //Considera como horário inicial de entrada
						nQtFtl+= 1 //Soma quantidade de férias
					//	ConOut('achou faltas afastamento ' +dtoc(dPerDe11))
						_FLAG := .F.
					Endif
				Endif
				QRTUR->(dbCloseArea())

				//	nRetF+= 1 //Considera como horário inicial de entrada
				//	nQtFtl+= 1


				t10->(dbSkip())
			enddo
			T10->(dbCloseArea())

		Endif
		TEMPSR8->(dbCloseArea())
		dPerDe11 := DaySum(dPerDe11,1)
	ENDDO

/*rodrigo Lucas Mconsult - retirado o relacionamento com a agenda para calcular os dias de ausencias
	//Busca Ausencias da folha SR8 - PERIODO ANTERIOR
	cQuery:= " SELECT TDX_TURNO TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI FROM "+RetSqlName("ABB")+" ABB (NOLOCK) "
	cQuery+= " INNER JOIN "+RetSqlName("ABQ")+" ABQ (NOLOCK) "
	cQuery+= " ON ABQ_CONTRT = SUBSTRING(ABB_IDCFAL,1,15) AND ABQ_ITEM = SUBSTRING(ABB_IDCFAL,16,6) AND ABQ_FILIAL = SUBSTRING(ABB_FILIAL,1,4) "
	cQuery+= " INNER JOIN "+RetSqlName("TFF")+" TFF (NOLOCK) "
	cQuery+= " ON ABB_FILIAL = TFF_FILIAL "
	cQuery+= " AND SUBSTRING(ABB_IDCFAL,1,15) = TFF_CONTRT "
	cQuery+= " AND ABQ_CODTFF = TFF_COD "
	cQuery+= " INNER JOIN "+RetSqlName("TDX")+" TDX (NOLOCK) "
	cQuery+= " ON TDX_FILIAL = TFF_FILIAL "
	cQuery+= " AND TDX_CODTDW = TFF_ESCALA "
	cQuery+= " INNER JOIN "+RetSqlName("SR8")+" SR8 (NOLOCK) "
	cQuery+= " ON R8_FILIAL = ABB_FILIAL AND R8_FILIAL+R8_MAT = '"+Alltrim(cCodTecQ)+"' "
	cQuery+= " INNER JOIN "+RetSqlName("RCM")+" RCM (NOLOCK) ON RCM_FILIAL = SUBSTRING(R8_FILIAL, 1, 2) AND RCM_TIPO = R8_TIPOAFA AND RCM.D_E_L_E_T_ = '' "
	cQuery+= " WHERE ABB.D_E_L_E_T_ = ' ' AND  "
	cQuery+= " ABQ.D_E_L_E_T_ = ' ' AND "
	cQuery+= " TFF.D_E_L_E_T_ = ' ' AND "
	cQuery+= " TDX.D_E_L_E_T_ = ' ' AND "
	cQuery+= " SR8.D_E_L_E_T_ = ' ' AND "
	cQuery+= " TFF_ESCALA <> ' ' AND "
	cQuery+= " TFF_FILIAL= '"+cFilQ+"' AND  "
	cQuery+= " ABB_CODTEC  = '"+cCodTecQ+"' AND "
	cQuery+= " TFF_CONTRT = '"+cContraQ+"' AND "
	cQuery+= " ABB_DTINI BETWEEN '"+dtos(dPerDe)+"' AND '"+dtos(dPerAte)+"' AND "
	cQuery+= "  ( "
	cQuery+= "  ( R8_DATAINI BETWEEN '"+dtos(dPerDe)+"' AND  '"+dtos(dPerAte)+"' ) "
	cQuery+= "  OR "
	cQuery+= "  ( R8_DATAFIM BETWEEN '"+dtos(dPerDe)+"' AND  '"+dtos(dPerAte)+"' ) "
	cQuery+= "  OR "
	cQuery+= "  ( R8_DATAINI <= '"+dtos(dPerDe)+"' AND R8_DATAFIM >= '"+dtos(dPerDe)+"') "
	cQuery+= "  ) AND "
	cQuery+= " ABB_DTINI >= R8_DATAINI AND "
	cQuery+= " ABB_DTINI <= R8_DATAFIM AND "
	cQuery+= " ABB_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery+= " AND RCM_YAUSEN = 'S' "
	cQuery+= " GROUP BY TDX_TURNO,TFF_ESCALA,ABB_DTINI,ABB_HRINI  "
	tcQuery cQuery new Alias QRSR8
	while QRSR8->(!Eof())
		/*
		//Valida calendario turno RCG
		lCalendRCG := .T.
		cQuery := " "
		cQuery += " SELECT RCG_VTRANS FROM "+RetSqlName("RCG")+" RCG "
		cQuery += " WHERE RCG.D_E_L_E_T_ = ' '  "
		cQuery += " AND RCG_FILIAL = '"+xFilial("RCG",cFilQ)+"' "
		cQuery += " AND RCG_TNOTRA = '"+QRSR8->TURNO+"' "
		cQuery += " AND RCG_DIAMES = '"+QRSR8->ABB_DTINI+"' "

		tcQuery cQuery new Alias QRRCG
		If QRRCG->(!Eof())
			If QRRCG->RCG_VTRANS == "2"
				lCalendRCG := .F.
			EndIf
		Endif
		QRRCG->(dbCloseArea())
		*//* rodrigo lucas Mconsult - retirado o relacionamento com a agenda para calcular os dias de ausencias
		If lCalendRCG
			//Busca na SPJ o dia da semana ativo
			cDTroc:= cvaltochar(dow(stod(QRSR8->ABB_DTINI)))
			cQuery:= "SELECT PJ_ENTRA1 FROM "+RetSqlName("SPJ")+" SPJ (NOLOCK) "
			cQuery+= "WHERE SPJ.D_E_L_E_T_ = ' ' AND "
			cQuery+= "PJ_FILIAL = '"+xFilial("SPJ",cFilQ)+"' AND "
			cQuery+= "PJ_TURNO = '"+QRSR8->TURNO+"' AND "
			cQuery+= "PJ_TPDIA = 'S' AND "
			cQuery+= "PJ_DIA = '"+cDTroc+"' "
			cQuery+= " AND PJ_HRTOTAL >= 6 "
			tcQuery cQuery new Alias QRTUR
			If QRTUR->(!Eof())
				If abs(QRTUR->PJ_ENTRA1 - val(substr(QRSR8->ABB_HRINI,1,2))) < 1 //Diferença pode ser em minutos
					nRetF+= 1 //Considera como horário inicial de entrada
					nQtdAuse+= 1 //Soma quantidade de férias
				Endif
			Endif
			QRTUR->(dbCloseArea())
		EndIf
		QRSR8->(dbSkip())
	Enddo
	QRSR8->(dbCloseArea())
/*
	//Diminuir o pré-abono do ponto - SPC (PASSADO)
	cQuery:= "SELECT SUM(PC_QTABONO) QTDABONO FROM "+RetSqlName("SPC")+" SPC "
	cQuery+= "WHERE SPC.D_E_L_E_T_ = ' ' " 
	cQuery+= "AND PC_FILIAL = '"+xFilial("SPC",cFilQ)+"' "
	cQuery+= "AND PC_FILIAL+PC_MAT = '"+cCodTecQ+"' "
	cQuery+= "AND PC_DATA >= '"+dtos(dPerDe)+"' AND PC_DATA <= '"+dtos(dPerAte)+"' "
	tcQuery cQuery new Alias QABONO

	If QABONO->(!Eof())
		nRetF+= QABONO->QTDABONO
	Endif
	QABONO->(dbCloseArea())
*/
	RestArea(aArea)
	//nRetF += nDiasSR8
Return nRetF
