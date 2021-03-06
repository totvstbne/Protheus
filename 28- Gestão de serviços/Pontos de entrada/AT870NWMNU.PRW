#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
//*****************************************************************************
/*/{Protheus.doc} AT870NWMNU - TECA870
Ponto de Entrada Retorna os bot�es do Grid da Gest�o de Cotratos
@author edlardo neves - mconsult
@since 12/01/2021
@version 1.0
@return lRet - L�gico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=445669209
/*/
//*****************************************************************************
User Function AT870NWMNU()
	Local aAreaAtual := GetArea()
	Local aRetMenu   := {}
    
    //Tratamento do par�metro de entrada
	If ValType(PARAMIXB) == "A"
        aRetMenu := aClone(PARAMIXB)
	EndIf

    //Pode adicionar novos menus, substituindo o Ponto de Entrada AT870MNU, 
    //neste caso somente adiciona uma posi��o no array com valor 2 que se refere ao parameto nRealOpc do m�todo AddButton do compomente FWFormBrowse
    aAdd( aRetMenu, {"#Transferencia Contrato", { || U_RTECF001()}, 2 } )

    RestArea(aAreaAtual)

Return aRetMenu
