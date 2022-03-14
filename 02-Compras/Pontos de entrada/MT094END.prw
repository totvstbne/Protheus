#include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#include 'fivewin.ch'
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ MT094END º Autor ³ Rodrigo Lucas        º Data ³ 03/11/21 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³ Preenche hora de liberação                                 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±º   DATA   ³ Programador   ³ Manutencao Efetuada                        º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±º          ³               ³                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


User Function MT094END()

	Local Area        := GetArea()
	Private cDocto    := PARAMIXB[1]
	Private cTipoDoc  := PARAMIXB[2]  // (PC, NF, SA, IP, AE)
	Private nOpc      := PARAMIXB[3]  //(1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear
	Private cFilDoc   := PARAMIXB[4]

	If nOpc == 1
	//	_aArea:= getArea()
		Reclock("SCR",.F.)
			SCR->CR_YHORA := substr(time(),1,8)
		MsUnlock()
	//	RestArea(_aArea)
	Endif

	RestArea(Area)

Return



