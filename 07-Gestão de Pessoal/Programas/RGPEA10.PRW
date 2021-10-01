#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.CH'
#include "tbiconn.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  RGPEA10    ºAutor  ³Rodrigo Lucas        º Data ³  05/05/21  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para incluir os pedidos de compras dos benefícios º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function RGPEA10()
	local c_Perg    := "RGPEA10"

	if pergunte(c_Perg,.T.)
		Processa({|| RGPEA10G() },"Gerando pc...")
	endif

return()

static function RGPEA10G()
	local a_Cab     := {}
	local a_Itens   := {}
	local d_DataPed := dDataBase
	
	cfilold := cFilAnt
	cFilAnt := MV_PAR01

	c_filial  := MV_PAR01
	c_comp    := MV_PAR02
	C_NUMPED  := MV_PAR03
	C_TIPO  := MV_PAR04 // VAL(ALIMENTAÇÃO SR0)/BEN(CESTA RIQ)
	c_Forn    := MV_PAR05
	c_ForLoj  := MV_PAR06
	d_DataPed := DDATABASe
	c_Prod    := mv_par07
	c_cond    := mv_par08
	//QUANTIDADE = 1
	//VALOR = QUERY
//n_Preco   := mv_par05           
//c_CC      := mv_par07
//c_Item    := mv_par08
IF C_TIPO == 1 // VALE ALIMENTAÇÃO
	cquery:= " SELECT R0_FILIAL, R0_CC, R0_NROPED, SUM(R0_VALCAL) TOTAL  FROM "+RETSQLNAME("SR0")+" R0 WHERE R0_FILIAL = '"+c_filial+"' AND R0_TPVALE = '2' AND R0.D_E_L_E_T_ = ' ' AND R0_VALCAL>0 AND R0_PERIOD = '"+c_comp+"' AND R0_NROPED = '"+C_NUMPED+"' GROUP BY R0_FILIAL, R0_CC, R0_NROPED ORDER BY R0_CC"

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		a_Cab     := {}
		a_Itens   := {}
		c_Pedido := GETSXENUM("SC7","C7_NUM")

		incproc('Gerando pedido: '+c_Pedido)

		a_Cab:={{"C7_NUM"     ,c_Pedido  ,Nil},; // Numero do Pedido
		{"C7_EMISSAO" ,d_DataPed  ,Nil},; // Data de Emissao
		{"C7_FORNECE" ,c_Forn     ,Nil},; // Fornecedor
		{"C7_LOJA"    ,c_ForLoj   ,Nil},; // Loja do Fornecedor
		{"C7_CONTATO" ,"      "   ,Nil},; // Contato
		{"C7_COND"    ,c_cond     ,Nil},; // Condicao de pagamento
		{"C7_FILENT"  ,cFilAnt    ,Nil}} // Filial Entrega


		AADD(a_Itens,{{"C7_ITEM"    ,"0001"  ,Nil},; //Numero do Item
		{"C7_PRODUTO",c_Prod     ,Nil},; //Codigo do Produto
		{"C7_QUANT"  ,1          ,Nil},; //Quantidade
		{"C7_PRECO"  ,T01->TOTAL    ,Nil},; //Preco
		{"C7_TOTAL"  ,T01->TOTAL    ,Nil},; //TOTAL
		{"C7_DATPRF" ,dDataBase  ,Nil},; //Data De Entrega
		{"C7_CC"     ,T01->R0_CC       ,Nil},;
		{"C7_OBS"    ,"PC AUT BENEFICIO"  ,Nil},;
		{"C7_FLUXO"  ,"S"        ,Nil}}) //Fluxo de Caixa (S/N)

		lMsErroAuto := .f.
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,a_Cab,a_Itens,3)

		if lMsErroAuto
			MostraErro()
			RollBackSXE()
			lMsErroAuto := .F.
			AutoGrLog("Não foi possível gerar o pedido: ")
			DisarmTransaction()
			exit
		else
			ConfirmSX8()
		endif

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )
ELSEIF C_TIPO == 2 // CESTA

	cquery:= " SELECT RIQ_FILIAL, RA_CC,  SUM(RIQ_VALBEN) TOTAL  FROM "+RETSQLNAME("RIQ")+" RIQ "
	cquery+= " INNER JOIN "+RETSQLNAME("SRA")+" RA ON RA_FILIAL = RIQ_FILIAL AND RA_MAT = RIQ_MAT AND RA.D_E_L_E_T_ = ' ' "
	cquery+= " WHERE RIQ_FILIAL = '"+c_filial+"' AND RIQ_TPBENE = '81' AND RIQ.D_E_L_E_T_ = ' ' AND R0_VALBEN>0 AND RIQ_PERIOD = '"+c_comp+"' GROUP BY RIQ_FILIAL, RA_CC ORDER BY RA_CC"

	TcQuery cQuery New Alias T01
	DbSelectArea("T01")

	While !T01->(Eof())

		a_Cab     := {}
		a_Itens   := {}
		c_Pedido := GETSXENUM("SC7","C7_NUM")

		incproc('Gerando pedido: '+c_Pedido)

		a_Cab:={{"C7_NUM"     ,c_Pedido  ,Nil},; // Numero do Pedido
		{"C7_EMISSAO" ,d_DataPed  ,Nil},; // Data de Emissao
		{"C7_FORNECE" ,c_Forn     ,Nil},; // Fornecedor
		{"C7_LOJA"    ,c_ForLoj   ,Nil},; // Loja do Fornecedor
		{"C7_CONTATO" ,"      "   ,Nil},; // Contato
		{"C7_COND"    ,c_cond     ,Nil},; // Condicao de pagamento
		{"C7_FILENT"  ,cFilAnt    ,Nil}} // Filial Entrega


		AADD(a_Itens,{{"C7_ITEM"    ,"0001"  ,Nil},; //Numero do Item
		{"C7_PRODUTO",c_Prod     ,Nil},; //Codigo do Produto
		{"C7_QUANT"  ,1          ,Nil},; //Quantidade
		{"C7_PRECO"  ,T01->TOTAL    ,Nil},; //Preco
		{"C7_TOTAL"  ,T01->TOTAL    ,Nil},; //TOTAL
		{"C7_DATPRF" ,dDataBase  ,Nil},; //Data De Entrega
		{"C7_CC"     ,T01->RA_CC       ,Nil},;
		{"C7_OBS"    ,"PC AUT BENEFICIO"  ,Nil},;
		{"C7_FLUXO"  ,"S"        ,Nil}}) //Fluxo de Caixa (S/N)

		lMsErroAuto := .f.
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,a_Cab,a_Itens,3)

		if lMsErroAuto
			MostraErro()
			RollBackSXE()
			lMsErroAuto := .F.
			AutoGrLog("Não foi possível gerar o pedido: ")
			DisarmTransaction()
			exit
		else
			ConfirmSX8()
		endif

		T01->(DBSKIP())
	Enddo


	T01->( dbCloseArea() )
ENDIF
	cFilAnt := cfilold 
	Alert("Processo finalizado")
return()
