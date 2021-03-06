#Include 'Protheus.ch'
//*****************************************************************************
/*/{Protheus.doc} MDTA6851
Ponto de Entrada para criar alerta para colaboradores que est�o cumprindo aviso previo
@author edlardo neves - mconsult
@since 16/11/2020
@version 1.0
@return lRet - L�gico - Indica se pode realizar a manuten��o
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6079912
/*/
//*****************************************************************************
User Function MDTA6851()
	Local aAreaAtual := GetArea()
    Local lBloqAviso := GetNewPar("MV_YGPM030", .F.)
    Local lRet       := .T. 

    If lBloqAviso
        /*Verifica se o colaborador est� cumprindo aviso previo*/
        DbselectArea("RFY")
        DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
        RFY->(Dbseek( TM0->TM0_FILIAL + TM0->TM0_MAT ))
        If FOUND()
            MSGINFO( "Aten��o o colaborador est� cumprindo aviso pr�vio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV), "Aten��o - Aviso Pr�vio" ) //Help("ESPECIFICO",1,"HELP","Aten��o - Aviso Pr�vio", "Aten��o o colaborador est� cumprindo aviso pr�vio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV),1,0)
        EndIf
    ENDIF

    RestArea(aAreaAtual)

Return lRet

