#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDEF.CH"
//*****************************************************************************
/*/{Protheus.doc} AT19DCPO
Ponto de Entrada para criar alerta para colaboradores que estão cumprindo aviso previo
Ponto de Entrada para alteração da estrutura das tabelas do ModelDef no TECA190D.
@author edlardo neves - mconsult
@since 19/11/2020
@version 1.0
@return lRet - Lógico 
@see https://tdn.totvs.com/pages/releaseview.action?pageId=535857081
/*/
//*****************************************************************************
User Function AT19DCPO()
    Local aAreaAtual := GetArea()
    Local lRet := .T.
    Local aSubMdls := PARAMIXB[2] // Estrutura das tabelas, passado por referência
    Local nX   := 0
    Local nY   := 0

    For nX := 1 To Len(aSubMdls)
        If aSubMdls[nX,2] == "AA1"
            For nY := 1 To Len(aSubMdls[nX,1]:AFIELDS)
                If aSubMdls[nX,1]:AFIELDS[nY,3] == "AA1_CODTEC"
                    aSubMdls[nX,1]:AFIELDS[nY,7] := { || U_RTECR002() }
                    Exit
                Endif
            Next nX
            Exit
        Endif

    Next nX

    RestArea(aAreaAtual)
Return lRet