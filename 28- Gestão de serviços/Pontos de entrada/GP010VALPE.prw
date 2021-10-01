#Include 'Protheus.ch'
//*****************************************************************************
/*/{Protheus.doc} GP010VALPE
Ponto de Entrada para validar altera��es em funcionarios que est�o cumprindo aviso previo
@author edlardo neves - mconsult
@since 16/11/2020
@version 1.0
@return L�gico, .T. se pode alterar .F. caso contr�rio
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6079099
/*/
//*****************************************************************************
User Function GP010VALPE()
	Local aAreaAtual := GetArea()
    Local lRet       := .T.
    Local lBloqAviso := GetNewPar("MV_YGPM030", .F.)

    If lBloqAviso
        /*Verifica se o colaborador est� cumprindo aviso previo*/
        DbselectArea("RFY")
        DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
        Dbseek(SRA->(RA_FILIAL+RA_MAT) )
        If FOUND()
            Help("ESPECIFICO",1,"HELP","Aten��o - Aviso Pr�vio", "Aten��o o colaborador est� cumprindo aviso pr�vio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV),1,0)
            //lRet := .F.
        EndIf
    ENDIF

    RestArea(aAreaAtual)

Return lRet

