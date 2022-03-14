#include "protheus.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  FC021FIL                                                                                              |
 | Autora: Alana Oliveira em 02.12.2021                                                                         |
 | Desc:  Ponto de Entrada para filtro no fluxo de caixa                                                        |
 | Link:  https://tdn.totvs.com.br/display/public/PROT/FC021FIL+-+Filtra+campos+das+tabelas+SE1+e+SE2           |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function FC021FIL()
    Local cFiltro := ""
    local cAlias := PARAMIXB[1]
    Local lExib  := GETMV("MV_YEXIBPR") 
    If cAlias == "SE1"
        If !lExib
            cFiltro := "Alltrim(SE1->E1_TIPO) <> 'PR'"
        Endif
    EndIf
Return cFiltro
