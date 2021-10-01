// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : F240TDOK.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 15/02/2021 | Rodrigo Lucas    | Gerado com auxílio do Assistente de Código do TDS.
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "Topconn.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F240TDOK
Manutenção de dados em SRA-Funcionarios.

@author    Rodrigo Lucas 
@version   11.3.1.201605301307
@since     15/02/2021
/*/
//------------------------------------------------------------------------------------------
user function F240TDOK()
	//-- variáveis -------------------------------------------------------------------------
	Local aArea 	:= GetArea()
	//Local cMsg 		:= ''
	Local cQuery 	:= ''
	Local lRetorno	:= .T.
	Local _atit := {}


	SE2TMP->(DbGoTop())


	While !SE2TMP->(Eof())

		IF !empty(SE2TMP->E2_OK)

			cQuery	:= "SELECT "
			cQuery	+= "E2_VALOR, E2_CODBAR,E2_NOMFOR, A2_BANCO, A2_AGENCIA, A2_NUMCON, A2_DVCTA, A2_DVAGE "
			cQuery	+= " FROM  " + RETSQLNAME("SE2") + " SE2, " + RETSQLNAME("SA2") + " SA2 "
			cQuery +=	" WHERE "
			cQuery += " SE2.D_E_L_E_T_ = ' ' "
			cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
			cQuery += "AND SA2.A2_FILIAL  = '"+XFILIAL("SA2")+"'  "
			cQuery += "AND SE2.E2_FILIAL  = '"+SE2TMP->E2_FILIAL+"' "
			cQuery += "AND SE2.E2_PREFIXO = '"+SE2TMP->E2_PREFIXO+"' "
			cQuery += "AND SE2.E2_NUM     = '"+SE2TMP->E2_NUM+"' "
			cQuery += "AND SE2.E2_PARCELA = '"+SE2TMP->E2_PARCELA+"' "
			cQuery += "AND SE2.E2_TIPO    = '"+SE2TMP->E2_TIPO+"' "
			cQuery += "AND SE2.E2_FORNECE = '"+SE2TMP->E2_FORNECE+"' "
			cQuery += "AND SE2.E2_LOJA    = '"+SE2TMP->E2_LOJA+"' "
			cQuery += "AND SE2.E2_FORNECE = SA2.A2_COD "
			cQuery += "AND SE2.E2_LOJA    = SA2.A2_LOJA    "
			if Select("T01") > 0
				T01->(DbCloseArea())
			Endif
			TcQuery cQuery new Alias T01


			if !T01->(eof())
				IF  EMPTY(T01->E2_CODBAR) .AND. (EMPTY(T01->A2_BANCO) .OR. EMPTY(T01->A2_AGENCIA) .OR.  EMPTY(T01->A2_NUMCON))
					aadd(_atit,{SE2TMP->E2_FILIAL,SE2TMP->E2_PREFIXO,SE2TMP->E2_NUM,SE2TMP->E2_PARCELA,SE2TMP->E2_TIPO,SE2TMP->E2_VALOR,SE2TMP->E2_FORNECE,SE2TMP->E2_LOJA,T01->E2_NOMFOR, iif(EMPTY(T01->E2_CODBAR),SPACE(48),T01->E2_CODBAR),T01->A2_BANCO,T01->A2_AGENCIA,T01->A2_DVAGE,T01->A2_NUMCON,T01->A2_DVCTA})
				ENDIF
			endif
			T01->(DbCloseArea())

		ENDIF

		SE2TMP->(DbSkip())
	EndDo
	IF !empty(_atit)
		lRetorno	:= .f.
		IF msgYesNo("Existem títulos não aptos a serem pagos pelo MultPag. Deseja informar os dados para prosseguir com pagamento?")
			U_AJUSTIT(_atit)
		Endif
	endif
	RestArea( aArea )
Return lRetorno
//-------------------------------------------------------------------------------------------
// Gerado pelo assistente de código do TDS tds_version em 02/09/2016 as 08:31:06
//-- fim de arquivo--------------------------------------------------------------------------
User Function AJUSTIT(_atit)


	Local aACampos  	:= {"E2_CCDBAR","A2_BANCO","A2_AGENCIA","A2_NUMCON","A2_DVCTA","A2_DVAGE"} //Variável contendo o campo editáveis no Grid
	Local aBotoes		:= {}         		   //Variável onde será¡ incluido o botão para a legenda
	Private oLista                    		   //Declarando o objeto do browser
	Private aCabecalho  := {}         		   //Variavel que montará„ o aHeader do grid
	Private aColsEx 	:= {}        		   //Variável que receberá„ os dados
	Private bFieldOk	:=  {|| .T.}

	DEFINE MSDIALOG oDlg TITLE "Títulos não aptos" FROM 000, 000  TO 480, 1150  PIXEL
	CriaCabec()
	oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)
	Carregar(_atit)
	oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oLista:oBrowse:SetFocus()
	aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})
	EnchoiceBar(oDlg, {||  Processa( {|| U_GRAVAR(oLista:aCols) }, "Aguarde...", "Carregando registros...",.F.) }, {|| oDlg:End() },,aBotoes)
	ACTIVATE MSDIALOG oDlg CENTERED

Return


Static Function CriaCabec()


	Aadd(aCabecalho, {"Filial","E2_FILIAL","@!"       ,6,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Prefixo","E2_PREFIXO","@!",3,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Número","E2_NUM","@!",09,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Parcela","E2_PARCELA","@!",2,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Tipo","E2_TIPO","@!",3,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Valor","E2_VALOR","@E 9,999,999.99",16,2,"","","N","","R","","",""})
	Aadd(aCabecalho, {"Cod. Fornec.","E2_FORNECE","",6,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Loja","E2_LOJA","@!",2,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Nome Fornec.","E2_NOMFOR","@!",30,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Código Barra","E2_CCDBAR","@!",48,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"Banco","A2_BANCO","@!",3,0,"","","C","SA6","R","","",""})
	Aadd(aCabecalho, {"Agencia","A2_AGENCIA","@!",4,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"DV Age","A2_DVAGE","@!",1,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"N. Conta","A2_NUMCON","@!",10,0,"","","C","","R","","",""})
	Aadd(aCabecalho, {"DV Cta","A2_DVCTA","@!",1,0,"","","C","","R","","",""})

Return


Static Function Carregar(_atit)
//	Local _aItens := {}
	Local i

	For i := 1 to len(_atit)
		// {SE2TMP->E2_FILIAL,SE2TMP->E2_PREFIXO,SE2TMP->E2_NUM,SE2TMP->E2_PARCELA,SE2TMP->E2_TIPO,SE2TMP->E2_VALOR,SE2TMP->E2_FORNECE,SE2TMP->E2_LOJA,T01->E2_NOMFOR, T01->E2_CODBAR,T01->A2_BANCO,T01->A2_AGENCIA,T01->A2_DVAGE,T01->A2_NUMCON,T01->A2_DVCTA}
		aadd(aColsEx,{_atit[i,1],_atit[i,2],_atit[i,3],_atit[i,4],_atit[i,5],_atit[i,6],_atit[i,7],_atit[i,8],_atit[i,9],_atit[i,10],_atit[i,11],_atit[i,12],_atit[i,13],_atit[i,14],_atit[i,15],.F.})
	Next

	oLista:SetArray(aColsEx,.T.)
	oLista:Refresh()

Return


User function GRAVAR(_aGrav)
	Local aAreaAnt := GetArea()
	Local x


	Begin Transaction
		FOR x:=1 To Len(_aGrav)
			If  ALLTRIM(_aGrav[x,10]) <> ""
				dbselectarea("SE2")
				DBSETORDER(1)
				IF DBSEEK(_aGrav[x,01]+_aGrav[x,02]+_aGrav[x,03]+_aGrav[x,04]+_aGrav[x,05]+_aGrav[x,07]+_aGrav[x,08])
					RECLOCK("SE2",.F.)
					_ccodbar := ""
					if len(alltrim(_aGrav[x,10])) == 47
						_ccodbar := u_cobbarlin(_aGrav[x,10])
					elseif len(alltrim(_aGrav[x,10])) == 44
						_ccodbar := alltrim(_aGrav[x,10])
					endif
					if !empty(_ccodbar)
						SE2->E2_CODBAR	:= _ccodbar
					endif
					SE2->(MsUnlock())

				endif
			ELSEIF ALLTRIM(_aGrav[x,11]) <> "" .AND. ALLTRIM(_aGrav[x,12]) <> "" .AND. ALLTRIM(_aGrav[x,14]) <> "" .AND. ALLTRIM(_aGrav[x,15]) <> ""
				dbselectarea("SA2")
				DBSETORDER(1)
				IF DBSEEK(XFILIAL("SA2")+_aGrav[x,07]+_aGrav[x,08])
					RECLOCK("SA2",.F.)
					SA2->A2_BANCO	:= _aGrav[x,11]
					SA2->A2_AGENCIA	:= _aGrav[x,12]
					SA2->A2_DVAGE	:= _aGrav[x,13]
					SA2->A2_NUMCON	:= _aGrav[x,14]
					SA2->A2_DVCTA	:= _aGrav[x,15]

					SA2->(MsUnlock())

				endif

			ENDIF
		NEXT
	END TRANSACTION


	RestArea(aAreaAnt)
	oDlg:End()
return

User function cobbarlin(_cbdig)

_codbcor := substr(_cbdig,1,4)+substr(_cbdig,33,15)+substr(_cbdig,5,5)+substr(_cbdig,11,6)+substr(_cbdig,17,4)+substr(_cbdig,22,10)

return(_codbcor)
