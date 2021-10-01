#Include 'Protheus.ch'
//*****************************************************************************
/*/{Protheus.doc} GP010VALPE
Ponto de Entrada para validar alterações em funcionarios que estão cumprindo aviso previo
@author edlardo neves - mconsult
@since 16/11/2020
@version 1.0
@return Lógico, .T. se pode alterar .F. caso contrário
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6079099
/*/
//*****************************************************************************
User Function GP010VALPE()
	Local aAreaAtual := GetArea()
    Local lRet       := .T.
    Local lBloqAviso := GetNewPar("MV_YGPM030", .F.)

    If lBloqAviso
        /*Verifica se o colaborador está cumprindo aviso previo*/
        DbselectArea("RFY")
        DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
        Dbseek(SRA->(RA_FILIAL+RA_MAT) )
        If FOUND()
            Help("ESPECIFICO",1,"HELP","Atenção - Aviso Prévio", "Atenção o colaborador está cumprindo aviso prévio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV),1,0)
            //lRet := .F.
        EndIf
    ENDIF

    RestArea(aAreaAtual)

Return lRet

