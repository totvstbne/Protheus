#Include "TbiConn.CH"
#Include "TopConn.CH"
#INCLUDE "PROTHEUS.CH"

User Function UpdateTbl()
	Local cEmp
	Local cFil

	cEmp 	:= AllTrim(FWInputBox("Código da empresa", "01"))
	cFil 	:= AllTrim(FWInputBox("Código da filial", "01"))
	cAlias 	:= UPPER(AllTrim(FWInputBox("Alias da tabela. Ex.: SA1", "")))

	Prepare Environment EMPRESA cEmp FILIAL cFil

	IF !ChkFile( cAlias , lExclusivo := .T.)
		MsgInfo("Não foi possivel abrir o alias em modo exclusivo")
		Return
	EndIF

	(cAlias)->(DbCloseArea())

	__SetX31Mode(.F.)
	/*
	cQuery := "SELECT name FROM sysobjects sobjects where type='U' and name LIKE '%120'"
	TcQuery cQuery New Alias T01
	While !T01->(Eof())
		cAlias := SubStr(T01->name,1,3)
		IF cAlias $ "LEJ"
			T01->(DbSkip())
			Loop
		EndIF
	*/
		X31UPDTABLE(cAlias)

//Atualiza o Dicionário

//Se houve Erro na Rotina
		If __GetX31Error()
			MsgInfo(__GetX31Trace())
		Else
			MsgInfo(cAlias+" - Tabela atualizada com sucesso!")
		EndIf

//Abrindo a tabela para criar dados no sql
		DbSelectArea(cAlias)
//		(cAlias)->(DbCloseArea())
//		T01->(DbSkip())
//	EndDo
//Desbloqueando alterações no dicionário
		__SetX31Mode(.T.)

		Return



User Function AjustNumber()
	Local cEmp
	Local cFil

	cEmp 	:= AllTrim(FWInputBox("Código da empresa", "01"))
	cFil 	:= AllTrim(FWInputBox("Código da filial", "01"))
	cAlias 	:= UPPER(AllTrim(FWInputBox("Alias da tabela. Ex.: SA1", "")))

	Prepare Environment EMPRESA cEmp FILIAL cFil

	(cAlias)->(DbCloseArea())

	DbSelectArea("SX2")
	DbSetOrder(1)
	IF DbSeek(cAlias)
		cUnique := SX2->X2_UNICO

		cChave := GetSX8Num(cAlias)
		DbSelectArea(cAlias)
		DbSetOrder(1)
		While DbSeek(xFilial(cAlias)+cChave)
			ConfirmSX8()
			cChave := GetSX8Num(cAlias)
		EndDo
		RollBackSX8()
	EndIF


Return



User Function CCmenor()
	Local cEmp	:= "01"
	Local cFil	:= "01"
	Local cCampos	:= ""
	Prepare Environment EMPRESA cEmp FILIAL cFil

	DbSelectArea("SX3")
	DbSetOrder(3)
	DbGoTop()
	DbSeek("004")
	While !SX3->(Eof()) .And. SX3->X3_GRPSXG == "004"
		//cQuery := "SELECT name FROM sysobjects sobjects where type='U' and name LIKE '"+RetSqlName("CTT")+"'"
		cQuery := " SELECT cNmColuna = C.name
		cQuery += " ,cTpColuna = UPPER(TYPE_NAME(C.user_type_id))
		cQuery += " ,iMaxDigit = CASE
		cQuery += "                     WHEN T.precision = 0
		cQuery += "                     THEN C.max_length
		cQuery += "                     ELSE T.precision
		cQuery += "                  END
		cQuery += " FROM sys.all_columns C WITH(NOLOCK)
		cQuery += " INNER JOIN sys.types T WITH(NOLOCK) ON T.user_type_id = C.user_type_id
		cQuery += "     WHERE C.object_id = Object_Id('"+SX3->X3_ARQUIVO+"') AND C.name='"+SX3->X3_CAMPO+"'

		TcQuery cQuery New Alias T01
		IF !T01->(Eof())
			IF T01->iMaxDigit <> 13
				cCampos += AllTrim(SX3->X3_CAMPO)+", "
			EndIF
		EndIF
		T01->(DbCloseArea())
		SX3->(DbSkip())
	EndDo

	MsgInfo(cCampos)
Return
