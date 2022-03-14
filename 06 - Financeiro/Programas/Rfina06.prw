#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"





/*/{Protheus.doc} RFINA06
Relatorio Contratos
@type function
@version 1.0
@author Rodrigo Lucas
@since 25/02/2022
@obs 
EXCLUIR TÍTULOS PROVISÓRIOS
/*/
User Function RFINA06
	Local aParam			:= {}
	Local aRet				:= {}
	Local bOk				:= {|| .T. }
	Local cFilIni
	Local cFilFim


	If TYPE("cFilAnt")=="U"
		OpenSm0()
		SM0->(DbGoTop())
		RpcSetEnv(SM0->M0_CODIGO,"060101")
		__cInterNet	:= Nil
	EndIf
	cFilIni		:= Space(FWSizeFilia())
	cFilFim		:= Space(FWSizeFilia())
	cContraIni	:= Space(GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cContraFim	:= Replicate("Z",GetSx3Cache("TFJ_CONTRT","X3_TAMANHO"))
	cFORIni		:= Space(GetSx3Cache("TFJ_CODENT","X3_TAMANHO"))
	cFORFim		:= Replicate("Z",GetSx3Cache("TFJ_CODENT","X3_TAMANHO"))
	cCCIni		:= Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO"))
	cCCFim		:= Replicate("Z",GetSx3Cache("CTT_CUSTO","X3_TAMANHO"))
	cPERIni		:= ddatabase
	cPERfim		:= ddatabase+7	
	aAdd(aParam,{1,"Empresa De"		,cFilIni	,"@!","","SM0",".T.",110,.F.})
//	aAdd(aParam,{1,"Empresa AtÃ©"	,cFilFim	,"@!","","SM0",".T.",110,.F.})
	aAdd(aParam,{1,"Fornecedor De"		,cFORIni	,"@!","","SA1",".T.",110,.F.})
	aAdd(aParam,{1,"Fornecedor AtÃ©"	,cFORFim	,"@!","","SA1",".T.",110,.F.})
//	aAdd(aParam,{1,"Contrato De"	,cContraIni	,"@!","","CN9",".T.",110,.F.})
//	aAdd(aParam,{1,"Contrato AtÃ©"	,cContraFim	,"@!","","CN9",".T.",110,.F.})
//	aAdd(aParam,{1,"CC De"		,cCCIni	,"@!","","CTT",".T.",110,.F.})
//	aAdd(aParam,{1,"CC AtÃ©"	,cCCFim	    ,"@!","","CTT",".T.",110,.F.})
	aAdd(aParam,{1,"Periodo Inicial"	,cPERIni	    ,"","","",".T.",110,.F.})
	aAdd(aParam,{1,"Periodo Inicial"	,cPERfim	    ,"","","",".T.",110,.F.})
	//aAdd(aParam,{2,"Extra"		    ,cExtra     ,	{"1=NÃ£o", "2=Sim"},80,".T.",.F.})
	//aAdd(aParam,{4,"ElaboraÃ§Ã£o"		,l02	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Vigente"		,l05	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Em revisÃ£o"		,l09	,""	,80,".T.",.F.})
	//aAdd(aParam,{4,"Revisado"		,l10	,""	,80,".T.",.F.})
	If !ParamBox(aParam,"Filtro",@aRet,bOk,,,,,,"RTECR05",.T.,.T.)
		Return
	EndIf
	cFilIni	:= aRet[1]
	//cFilFim	:= aRet[2]
	//cCliIni		:= aRet[3]
	//cCliFim		:= aRet[4]
	cFORIni	:= aRet[2]
	cFORFim	:= aRet[3]
	//cCCIni		:= aRet[7]
	//cCCFim		:= aRet[8]
	cPERIni		:= aRet[4]
	cPERfim		:= aRet[5]
	//cExtra		:= aRet[9]
	//l02			:= aRet[10]
	//l05			:= aRet[11]
	//l09			:= aRet[12]
	//l10			:= aRet[13]
	Processa({|lCancelar| RunProc(cFilIni,cFORIni,cFORFim,cPERIni,cPERfim,@lCancelar) },,,.T.)
Return

Static Function RunProc(cFilIni,cFORIni,cFORFim,cPERIni,cPERfim,lCancelar)

	cQuery(cFilIni,cFORIni,cFORFim,cPERIni,cPERfim)

	Alert("Processo concluído")
Return

Static Function cQuery(cFilIni,cFORIni,cFORFim,cPERIni,cPERfim)
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

	Cquery := 	"SELECT * FROM "+RetSqlName("SE2")+" WHERE E2_FILIAL = '"+SUBSTR(cFilIni,1,2)+"' AND E2_FORNECE BETWEEN '"+cFORIni+"' AND '"+cFORFIM+"' AND E2_VENCREA BETWEEN '"+DTOS(cPERINI)+"' AND '"+DTOS(cPERFIM)+"' AND E2_TIPO = 'PR' AND D_E_L_E_T_ = ' ' AND E2_SALDO > 0 ORDER BY E2_VENCREA "

	cQuery := ChangeQuery( cQuery )

	If Select("T01") > 0
		dbSelectArea( "T01" )
		T01->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),"T01",.T.,.T.)

	IF !T01->(Eof())
		

			While !T01->(Eof())
				Aadd(aPedido,{"F",T01->E2_FILIAL,T01->E2_PREFIXO,T01->E2_NUM,T01->E2_PARCELA,T01->E2_FORNECE,Transform(T01->E2_VALOR,"@e 999,999,999.99"),STOD(T01->E2_VENCREA)})
				T01->(dbskip())
			Enddo

			DEFINE MSDIALOG oDlg2 FROM  170,19 TO 800,810 TITLE OemToAnsi("Títulos provisão") PIXEL

			@ 35,5 LISTBOX oLbx FIELDS HEADER "","Filial","Prefixo","Num","Parcela","Fornecedor","Valor","Data Vencto." SIZE 590,405 PIXEL OF oDlg2;
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
	T01->(DBCLOSEAREA())


Return

