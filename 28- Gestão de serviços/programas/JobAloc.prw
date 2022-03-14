#include "protheus.ch"
#include "dbtree.ch"
#include "ap5mail.ch"
#INCLUDE "TBICONN.CH"



User Function JobAloc(cParFil)
	Local dDataIni := date()
	Local dDataFim := date() // dDataIni + 5
	Local _CODTDX  := ""
	Local cStrSql  := ""
	Local lHelp    := .F.
	Local lJobAloc := .T.
	Local lLogAloc := .F.
	Local lDataExe := .F.
	Local cAliasQry



	ConOut('********************************')
	ConOut('********* INICIO ***************')
	ConOut('********************************')
	//RpcSetEnv("01", "010101")

	RPCCLEARENV()
	WSDLDBGLEVEL(2)
	RPCSetType(3)
	RpcSetEnv("01",cParFil,,,"FAT")



	lJobAloc := SuperGetMv( "MV_JOBALOC", lHelp, .F. )
	lLogAloc := SuperGetMv( "MV_LOGALOC", lHelp, .F. )

	IF cParFil == '010101'
		lDataExe := (IF(ALLTRIM(SuperGetMv( "MV_DTGSEXE", lHelp, .F. )) == "" , STOD("19990101") , STOD(ALLTRIM(SuperGetMv( "MV_DTGSEXE", lHelp, .F. ))) )  <> DATE())
	ELSEIF cParFil == '020101'
		lDataExe := (IF(ALLTRIM(SuperGetMv( "MV_DTGSEX2", lHelp, .F. )) == "" , STOD("19990101") , STOD(ALLTRIM(SuperGetMv( "MV_DTGSEX2", lHelp, .F. ))) )  <> DATE())
	ELSEIF cParFil == '030101'
		lDataExe := (IF(ALLTRIM(SuperGetMv( "MV_DTGSEX3", lHelp, .F. )) == "" , STOD("19990101") , STOD(ALLTRIM(SuperGetMv( "MV_DTGSEX3", lHelp, .F. ))) )  <> DATE())
	ELSEIF cParFil == '040101'
		lDataExe := (IF(ALLTRIM(SuperGetMv( "MV_DTGSEX4", lHelp, .F. )) == "" , STOD("19990101") , STOD(ALLTRIM(SuperGetMv( "MV_DTGSEX4", lHelp, .F. ))) )  <> DATE())
	ELSEIF cParFil == '050101'
		lDataExe := (IF(ALLTRIM(SuperGetMv( "MV_DTGSEX5", lHelp, .F. )) == "" , STOD("19990101") , STOD(ALLTRIM(SuperGetMv( "MV_DTGSEX5", lHelp, .F. ))) )  <> DATE())
	ENDIF

	If ((lJobAloc) .AND.  LockByName("JOBALOC",.T.,.T.) .and. TIME() >= "00:05:00"  .AND. lDataExe )


		dDataIni	:= IF(ALLTRIM(SuperGetMv( "MV_DTINIGS", lHelp, .F. )) == "" , date() , STOD(ALLTRIM(SuperGetMv( "MV_DTINIGS", lHelp, .F. ))) ) //date()
		dDataFim	:= DAYSUM(IF(ALLTRIM(SuperGetMv( "MV_DTINIGS", lHelp, .F. )) == "" , date() , STOD(ALLTRIM(SuperGetMv( "MV_DTINIGS", lHelp, .F. ))) ) , GETMV("MV_YDPROCE"))
		cStrSql := " SELECT  * "
		cStrSql += "   FROM " + RETSQLNAME("TFF") + " TFF "
		cStrSql += "  WHERE TFF_FILIAL='"+xFilial("TFF")+"' AND TFF.D_E_L_E_T_  = ' ' "
		//cStrSql += "  WHERE TFF.D_E_L_E_T_  = ' ' "
		cStrSql += "  AND TFF.TFF_PROCP = 'S' AND TFF_CODSUB=' '"

		cAliasQry	:= MPSysOpenQuery(cStrSql)


		While ( (cAliasQry)->(!Eof()) )
			ConOut('Passo 1')
			ConOut('TFF_PROCP ' + AllTrim((cAliasQry)->TFF_PROCP))

			if (cAliasQry)->TFF_PROCP == "S"
				ConOut('Passo 2')


				ConOut('Passo 3')

				ConOut('Passo 4')
				ConOut('TFF_COD = ' + (cAliasQry)->TFF_COD)



				ConOut( (cAliasQry)->TFF_ESCALA + ' ' + (cAliasQry)->TFF_ESCALA + ' ' + (cAliasQry)->TFF_CONTRT + ' ' + (cAliasQry)->TFF_CONTRT + ' ' + (cAliasQry)->TFF_LOCAL + ' ' + (cAliasQry)->TFF_LOCAL + ' ' + DTOS(dDataIni) + '_' + DTOS(dDataFim) + ' ' + (cAliasQry)->TFF_COD)

				// Efetuar o registro de agenda dos atendentes

				/*/ At330AloAut
				Efetua a alocação automatica dos atendentes
				@sample 	At330AloAut( cEscIni, cEscFim, cCntIni, cCntFim, cLocIni, cLocFim, dDataIni, dDataFim, cClienteDe, cLojaDe, cClienteAt, cLojaAte, cSupDe, cSupAte, cCodAtend, cCodigoTFF )
				/*/
				lRet := At330AloAut( (cAliasQry)->TFF_ESCALA, (cAliasQry)->TFF_ESCALA;	//Escala Inicial/Final para a alocação
				,(cAliasQry)->TFF_CONTRT, (cAliasQry)->TFF_CONTRT;	//Contrato Inicial/Final para a alocação
				,(cAliasQry)->TFF_LOCAL, (cAliasQry)->TFF_LOCAL;	//Local Inicial/Final para alocação
				,dDataIni , dDataFim ; //,STOD((cAliasQry)->TFF_PERINI), STOD((cAliasQry)->TFF_PERFIM);	//Data inicial/Final para a alocação
				,"      ","  ";										//Contrato Inicial/Final para a alocação
				,"ZZZZZZ","ZZ";										//Local Inicial/Final para alocação
				,"              ","ZZZZZZZZZZZZZZ";					//Supervisor de/Ate
				,"              ";									//Codigo do Atendente										 
				,(cAliasQry)->TFF_COD;								//Codigo da TFF
				)
				ConOut("saiu")
				ConOut(lRet)



				ConOut('PULAR')
				// Gera o log
				If ( lLogAloc )
					u_fCriaLog( "JOBALOC Integração" ,; //-- Descrição completa
					(cAliasQry)->TFF_ESCALA     ,; //-- Escala
					(cAliasQry)->TFF_CONTRT     ,; //-- Numero do Contrato da TFF
					(cAliasQry)->TFF_LOCAL      ,;  //-- Local
					dDataIni             ,;  //-- Data inicial agendada
					dDataFim             ,;  //-- data final agendada
					(cAliasQry)->TFF_COD)           //-- Codigo do TFF
				EndIf

			EndIf

			(cAliasQry)->(DBSKIP())
		EndDo


		(cAliasQry)->(DbClosearea())
		ConOut("Término: " + time())

		// ATUALIZO DIA DE EXECUÇÃO 
		

		IF cParFil == '010101'
			PUTMV("MV_DTGSEXE", DTOS(DATE()) )
		ELSEIF cParFil == '020101'
			PUTMV("MV_DTGSEX2", DTOS(DATE()) )
		ELSEIF cParFil == '030101'
			PUTMV("MV_DTGSEX3", DTOS(DATE()) )
		ELSEIF cParFil == '040101'
			PUTMV("MV_DTGSEX4", DTOS(DATE()) )
		ELSEIF cParFil == '050101'
			PUTMV("MV_DTGSEX5", DTOS(DATE()) )
		ENDIF
		
	EndIf

	ConOut('********************************')
	ConOut('************* FIM **************')
	ConOut('********************************')


	UnLockByName("JOBALOC",.F.,.F.)
	Return(.T.)

	//Bibliotecas
	#Include "Protheus.ch"

/*/{Protheus.doc} zCriaLog
Função parar criação de logs
@author Wilton Lima
@since 04/06/2019
@version 1.0
@param cDescri, Caracter, Descrição do Log
@param cEscala, Caracter, Tabela do Log
@param cContrt, Caracter, Campo do Log
@param cLocal, Caracter, Conteúdo antigo do campo do Log
@param dDtIni, Caracter, Conteúdo novo do campo do Log
@param dDtFim, Caracter, Chave da tabela do Log
@param cCodTFF, Caracter, Conteúdo da Chave do Log
@example u_zCriaLog()
/*/

User Function fCriaLog(cDescri, cEscala, cContrt, cLocal, dDtIni, dDtFim, cCodTFF)
	Local cSeq      := ""
	Default cDescri := ""
	Default cEscala := ""
	Default cContrt := ""
	Default cLocal  := ""
	Default dDtIni  := Date()
	Default dDtFim  := Date()
	Default cCodTFF := ""

	// Se não tiver descrição
	If !Empty(cDescri)
		// Pegando a próxima sequência
		cSeq := GetSXENum('ZB0', 'ZB0_SEQ')

		// Salvando o log
		ZB0->(RecLock("ZB0", .T.))
		ZB0->ZB0_FILIAL	:= xFilial("ZB0")
		ZB0->ZB0_SEQ	:= cSeq
		ZB0->ZB0_USRCOD	:= "000000"
		ZB0->ZB0_USRNOM	:= "JOB"
		ZB0->ZB0_DATA   := DATE()
		ZB0->ZB0_HORA   := Time()
		ZB0->ZB0_DESCRI := cDescri
		ZB0->ZB0_FUNC   := FunName()
		ZB0->ZB0_FILORI	:= cFilAnt
		ZB0->ZB0_AMB    := GetEnvServer()
		ZB0->ZB0_TAB	:= "ABB"
		ZB0->ZB0_ESCALA := cEscala
		ZB0->ZB0_CONTRT := cContrt
		ZB0->ZB0_LOCAL  := cLocal
		ZB0->ZB0_DTINI  := dDtIni
		ZB0->ZB0_DTFIM  := dDtFim
		ZB0->ZB0_CODTFF := cCodTFF
		ZB0->(MsUnlock())
		ConfirmSX8()
	EndIf

Return