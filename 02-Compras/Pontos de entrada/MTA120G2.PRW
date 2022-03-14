// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : MTA120G2.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor RODRIGO LUCAS            | Descricao Utilizado para preencher CAMPOS NA SC7
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "vkey.ch"
#INCLUDE "topconn.ch"
#include "fileio.ch"
User Function MTA120G2
	Local aArea := GetArea()

	SC7->C7_YPCPF   := nCombPCPF

	// dbSelectArea("SCR")
	// SCR->(dbsetorder(2)) //six - CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
	// SCR->(dbgotop())
	// IF SCR->(dbseek(xfilial("SCR") + "PC" + SC7->C7_NUM))
	// 	WHILE !(SCR->(EOF())) .AND. SCR->CR_FILIAL == xfilial("SCR") .AND. SCR->CR_TIPO == "PC" .AND. ALLTRIM(SCR->CR_NUM) == SC7->C7_NUM
	// 		RecLock("SCR",.F.)
	// 		    SCR->CR_YTIPOPC := SC7->C7_YPCPF    
	// 		SCR->(MsUnLock())
            
	// 		SCR->(DBSKIP())
	// 	ENDDO
	// ELSE
	// 	MsgInfo( 'Item não inserido na tabela SCR', 'Erro' )
	// EndIf

	RestArea(aArea)
Return NIL

