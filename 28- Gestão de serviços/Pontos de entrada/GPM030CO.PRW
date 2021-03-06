#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} GPM030CO
Ponto de Entrada para definir se deve ou nao calcular ferias
@author edlardo neves - mconsult
@since 09/11/2020
@version 1.0
@return L�gico, .T. se pode calcular .F. caso contr�rio
@see http://tdn.totvs.com/pages/releaseview.action?pageId=75270832
/*/
//*****************************************************************************
User Function GPM030CO()
//*****************************************************************************
    Local aAreaAtual := GetArea()
    Local lRet       := .T.
    Local lBloqAviso := GetNewPar("MV_YGPM030", .F.)

    If lBloqAviso
        /*Verifica se o colaborador est� cumprindo aviso previo*/
        DbselectArea("RFY")
        DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
        Dbseek(SRA->(RA_FILIAL+RA_MAT) )
        If FOUND()
            Help("ESPECIFICO",1,"HELP","Bloqueio Aviso Pr�vio", "Ferias n�o pode ser calculada devido o colaborador est� cumprindo aviso pr�vio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV),1,0)
            lRet := .F.
        EndIf
    ENDIF

    RestArea(aAreaAtual)

Return lRet

