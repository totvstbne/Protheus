#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
//*****************************************************************************
/*/{Protheus.doc} AT870NWMNU - TECA870
Ponto de Entrada Retorna os botões do Grid da Gestão de Cotratos
@author edlardo neves - mconsult
@since 12/01/2021
@version 1.0
@return lRet - Lógico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=445669209
/*/
//*****************************************************************************
User Function AT870NWMNU()
	Local aAreaAtual := GetArea()
	Local aRetMenu   := {}
    
    //Tratamento do parâmetro de entrada
	If ValType(PARAMIXB) == "A"
        aRetMenu := aClone(PARAMIXB)
	EndIf

    //Pode adicionar novos menus, substituindo o Ponto de Entrada AT870MNU, 
    //neste caso somente adiciona uma posição no array com valor 2 que se refere ao parameto nRealOpc do método AddButton do compomente FWFormBrowse
    aAdd( aRetMenu, {"#Transferencia Contrato", { || U_RTECF001()}, 2 } )

    RestArea(aAreaAtual)

Return aRetMenu
