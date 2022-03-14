//***************ATENCAO
//FONTE FEITO PELA MCONSULT, A TOTVS RN NÃO DARÁ SUPORTE A ESTE FONTE

#include 'protheus.ch'
#include 'parmtype.ch'
#Include "RwMake.CH"
#Include "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GQREENTR º Autor ³    RODRIGO LUCAS    º Data ³  25/02/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Complementa a Gravação dos Títulos Financeiros a Pagar.	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function GQREENTR()

	Local oDlg2, nOpca := 1
	Local oOk         := LoadBitmap( GetResources(), "LBOK" )
	Local oNo         := LoadBitmap( GetResources(), "LBNO" )
//	Local nAt,oLbx
	Local aButtons := {}
//	Local oBtn
//	Local _cSerNfe
//	Local _cNumNfe
//	Local _oLbx, _nList := 0, _oBtCanc, _oBtSchema
	Local nElem
	Private _oJanelasuporte
	Private aPedido := {}
	Private aPedido2 := {}
	IF ALLTRIM(SF1->F1_ESPECIE) <> "DPF"
		Cquery := 	"SELECT * FROM "+RetSqlName("SE2")+" WHERE E2_FILIAL = '"+SUBSTR(SF1->F1_FILIAL,1,2)+"' AND E2_FORNECE = '"+SF1->F1_FORNECE+"' AND E2_LOJA = '"+SF1->F1_LOJA+"' AND E2_TIPO = 'PR' AND D_E_L_E_T_ = ' ' AND E2_SALDO > 0 ORDER BY E2_VENCREA "

		cQuery := ChangeQuery( cQuery )

		If Select("T01") > 0
			dbSelectArea( "T01" )
			T01->(dbCloseArea())
		Endif

		dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),"T01",.T.,.T.)

		IF !T01->(Eof())
			IF Msgyesno("Deseja eliminar uma provisão com esse documento de entrada?")

				While !T01->(Eof())
					Aadd(aPedido,{"F",T01->E2_FILIAL,T01->E2_PREFIXO,T01->E2_NUM,T01->E2_PARCELA,T01->E2_FORNECE,Transform(T01->E2_VALOR,"@e 999,999,999.99"),STOD(T01->E2_VENCREA)})
					T01->(dbskip())
				Enddo

				DEFINE MSDIALOG oDlg2 FROM  170,19 TO 400,410 TITLE OemToAnsi("Títulos provisão") PIXEL

				@ 35,5 LISTBOX oLbx FIELDS HEADER "","Filial","Prefixo","Num","Parcela","Fornecedor","Valor","Data Vencto." SIZE 190,75 PIXEL OF oDlg2;
					ON DBLCLICK ( If( aPedido[oLbx:nAt,1] == "T" , aPedido[oLbx:nAt,1] := "F" , ;
					aPedido[oLbx:nAt,1] := "T" ) , oLbx:Refresh() )

				oLbx:SetArray( aPedido )

				oLbx:bLine := { || {If(aPedido[oLbx:nAt,1] == "T",oOk,oNo),aPedido[oLbx:nAt,2],aPedido[oLbx:nAt,3], aPedido[oLbx:nAt,4],aPedido[oLbx:nAt,5],aPedido[oLbx:nAt,6],aPedido[oLbx:nAt,7],aPedido[oLbx:nAt,8]}}

				oLbx:SetFocus()

				ACTIVATE MSDIALOG oDlg2 ON INIT  EnchoiceBar(oDlg2,{||(nOpca := 1, oDlg2:End())},{||(nOpca := 0,oDlg2:End())},,@aButtons)

				If (nOpca == 1)

					lAchouMarcado := .F.

					For nElem := 1 To Len(aPedido)

						If aPedido[nElem,1] == "T"

							cQuery := " UPDATE "+RETSQLNAME("SE2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE E2_FILIAL = '"+aPedido[nElem,2]+"' AND E2_PREFIXO = '"+aPedido[nElem,3]+"' AND E2_NUM = '"+aPedido[nElem,4]+"' AND E2_PARCELA = '"+aPedido[nElem,5]+"' AND E2_FORNECE = '"+aPedido[nElem,6]+"' "

							If tcSqlExec( cQuery ) < 0
								Alert(tcSqlError())
							ELSE
								lAchouMarcado := .T.
							Endif
						Endif

					Next
					If lAchouMarcado
						Alert("Título provisório substituido!")
					Endif
				EndIf
			Endif
		Endif
		T01->(DBCLOSEAREA())
	ENDIF
Return
