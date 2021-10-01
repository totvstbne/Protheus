#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

//*****************************************************************************
/*/{Protheus.doc} a740GrdV - TECA740
Ponto de Entrada Adiciona grid a view do modelo de dados.
Objetivo - Utilizado para inclusão de rotina vacilitador no menu Outras Ações 
@author edlardo neves - mconsult
@since 14/01/2021
@version 1.0
@return null
@see https://tdn.totvs.com/pages/releaseview.action?pageId=393353521
/*/
//*****************************************************************************

User function a740GrdV()
	Local oView     :=   PARAMIXB[1] //Viewdef
    
    If !Empty(AD1->AD1_YFILOR)
        oView:AddUserButton("#Facilitador Orçamento","",{|oModel| U_RTECF002(oModel,oView)},,,) //"Aplica Config Planilha"
    EndIf

Return
