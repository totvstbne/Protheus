#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa ³ MT120TEL ³ Rodrigo Lucas 			      ³ Data ³ 27/10/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada p/ incluir campo no cabecalho do pedido ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe ³ Chamada padrao para programas em RDMake. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MT120TEL()
	Local aArea     := GetArea()
	Local oNewDialog 	:= PARAMIXB[1]
	Local aPosGet 		:= PARAMIXB[2]
	Local aObj			:= PARAMIXB[3]
	Local nOpcx 		:= PARAMIXB[4]
	Local oComboBox1
	Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9 .Or. nOpcx ==  6, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
	Public nCombPCPF := CriaVar("C7_YPCPF") //Adicionado por Rayanne Meneses
	
	If nOpcx == 3
		nCombPCPF 	:= ""
	Else
		nCombPCPF 	:= SC7->C7_YPCPF
	EndIf
				
	@ 060,aPosGet[1,3]+200 SAY "PC/PF:" OF oNewDialog PIXEL //SIZE 050, 008
	@ 061,aPosGet[1,4]+170 MSCOMBOBOX oComboBox1 VAR nCombPCPF ITEMS {"","PC=Pedido Compras","PF=Pedido Financeiro"} SIZE 55, 11 OF oNewDialog PIXEL SIZE 060, 006
	oComboBox1:bHelp := {|| ShowHelpCpo( "C7_YPCPF", {GetHlpSoluc("C7_YPCPF")[1]}, 5  )}

	If !lEdit
        oComboBox1:lActive := .F.
    EndIf
	RestArea(aArea)
Return
