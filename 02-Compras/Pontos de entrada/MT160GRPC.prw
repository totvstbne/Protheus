// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : MT160GRPC.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor RODRIGO LUCAS            | Descricao Utilizado para preencher CAMPOS NA SC7
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "vkey.ch"
#INCLUDE "topconn.ch"
#include "fileio.ch"
User Function MT160GRPC
	Local aArea := GetArea()
	
	SC7->C7_YPCPF   := nCombPCPF

	RestArea(aArea)
Return NIL
