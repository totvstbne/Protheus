#Include "Protheus.CH"
#Include "Topconn.CH"
#Include "Rwmake.CH"

/*
	@Autor Rodrigo Lucas
	@Descri��o Rotina de Gera��o de Instru��o
	@Data 12/03/2021
*/
User Function RFINA05()

IF !EMPTY(SE1->E1_IDCNAB)
	
	dbSelectArea("FI2")
	dbSetOrder(1)

	RecLock("FI2", .T.)

	FI2_FILIAL := xFilial("FI2")
	FI2_OCORR  := "02"
	FI2_DESCOC := "PEDIDO DE BAIXA"
	FI2_PREFIX := SE1->E1_PREFIXO
	FI2_TITULO := SE1->E1_NUM
	FI2_PARCEL := SE1->E1_PARCELA
	FI2_TIPO   := SE1->E1_TIPO
	FI2_CODCLI := SE1->E1_CLIENTE
	FI2_LOJCLI := SE1->E1_LOJA
	FI2_GERADO := "2" //1 - Sim -- 2 - N�o
	FI2_NUMBOR := SE1->E1_NUMBOR
	FI2_CARTEI := "1" //1 - Receber -- 2 - Pagar
	FI2_DTOCOR := dDataBase
	FI2_CAMPO  := "E1_SALDO"

	MsUnLock()

	RecLock("SE1", .F.)

	SE1->E1_OCORREN := "02"

	MsUnLock()
	Alert("Instru��o de baixa criada!")
ELSE
	Alert("T�tulo n�o enviado ao banco. N�o � poss�vel criar instru��o de baixa!")
ENDIF


Return()

