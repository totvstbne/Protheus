#Include 'Protheus.ch'

/* 
AUTOR: RODRIGO LUCAS
DATA: 25/02/2022
OBJETIVO: FILTRAR REGISTROS QUE SER�O LISTADOS NA TELA DE LIBERA��O AUTOM�TICA COM BASE NO FILTRO PADR�O E ADICIONANDO O FILTRO PELA DATA DE PAGAMENTO PARA O DIA
*/

User Function F580FAUT()
    Local aArea      := GetArea()
    Local cFiltro	 := " "
    cFiltro:=ParamIXB[1]

    cFiltro	+= " AND E2_TIPO <> 'PR' "
    
    RestArea(aArea)
Return(cFiltro)
