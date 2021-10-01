#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} RTECR002
Função para criar alerta para colaboradores que estão cumprindo aviso previo, incluido chamada do fonte na validação do campo AA1_CODTEC
@author edlardo neves - mconsult
@since 19/11/2020
@version 1.0
/*/
//*****************************************************************************
User Function RTECR002()
//*****************************************************************************
    Local aAreaAtual := GetArea()
    Local lBloqAviso := GetNewPar("MV_YGPM030", .F.)
    Local lRet := .T.

    If lBloqAviso .AND. Alltrim(FUNNAME()) == "TECA190D"
        //Busca cadastro do tecnico na tabela AA1
        DbselectArea("AA1")
        DbSetOrder(1) //AA1_FILIAL+AA1_CODTEC
        AA1->(Dbseek( FwFldGet("AA1_FILIAL") + FwFldGet("AA1_CODTEC") ))
        If FOUND()
            If Alltrim(AA1->AA1_CDFUNC)<>""
                //Verifica se o colaborador está cumprindo aviso previo
                DbselectArea("RFY")
                DbSetOrder(1) //RFY_FILIAL, RFY_MAT, RFY_DTASVP
                RFY->(Dbseek( AA1->AA1_FILIAL + AA1->AA1_CDFUNC ))
                If FOUND()
                    MSGINFO( "Atenção o colaborador está cumprindo aviso prévio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV), "Atenção - Aviso Prévio" ) //Help("ESPECIFICO",1,"HELP","Atenção - Aviso Prévio", "Atenção o colaborador está cumprindo aviso prévio. Dt. Inicio Aviso: "+DtoC(RFY->RFY_DTASVP)+" - Dt. Fim Aviso: " +DtoC(RFY->RFY_DTPJAV),1,0)
                EndIf
            EndIf
        EndIf
    ENDIF

    RestArea(aAreaAtual)

Return lRet

