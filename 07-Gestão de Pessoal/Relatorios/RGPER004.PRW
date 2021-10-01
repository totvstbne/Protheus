#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} RGPER004
Função para calculo desconto periculosidade sobre DSR e Falta Servnac - DESCPERI
@author edlardo neves - mconsult
@since 20/11/2020
@version 1.0
@return Lógico, .T. se pode calcular .F. caso contrário
/*/
//*****************************************************************************
User Function RGPER004(cPdRot)
//*****************************************************************************
    Local aAreaAtual := GetArea()
    Local nPosPd     := 0
    //Local nVlrSalBase:= 0
    Local LTEMPERI := GetValType('L')
    Local cPdDescFalta := "201"
    Local cPdDescDSR   := "22A"
    Local nPosDescFalta:= 0
    Local nPosDescDSR  := 0
    Local cPdFalta     := "22N"
    Local cPdDSR       := "22O"

    DEFAULT cPdRot := ""

    cVerbaRot := cPdRot

    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf

        IF ( ( ( CTIPOROT == "2" .AND. P_SOMAINC ) .OR. (CTIPOROT # "2") ) )

            NPERIC := 0

            CBCALPER := FBUSCARG4("RCE_BCALPE",DDATAATE,.T.,.T.)

            IF ( SRA->RA_ADCPERI == "2" .OR. LDISSIDIO )

                LTEMPERI := IF(SRA->RA_ADCPERI == "2", .T., !EMPTY(GPRETSR9( "SRA", DDATAATE, "RA_PERICUL" )))

                IF ( CBCALPER  $ "1/3/4/5" .AND. LTEMPERI )

                    CCODPER := CVERBAROT

                    NHRSPERI := SRA->RA_PERICUL

                    NPERC_PERI := RCE->RCE_PERPE

                    IF ( EMPTY(CCODPER) )

                        IF ( CTIPOROT $ "1*2*4" )

                            CCODPER := FGETCODFOL('0036')

                        EndIF


                        IF ( CTIPOROT == "3" )

                            CCODPER := FGETCODFOL('1300')

                        EndIF

                        IF ( CTIPOROT $ "5*6" )

                            IF ( CTIPOROT == "5" )

                                CCODPER := FGETCODFOL('1632')

                                IF ( LVB13MAT2 )

                                    CCODPERM := FGETCODFOL('1643')

                                EndIF


                                IF ( !LVB13MAT2 )

                                    CCODPERM := FGETCODFOL('1440')

                                EndIF

                            EndIF

                            IF ( CTIPOROT == "6" )

                                CCODPER := FGETCODFOL('1290')

                                CCODPERM := FGETCODFOL('1440')

                            EndIF

                        EndIF

                    EndIF

                EndIF

                IF ( CBCALPER $ "2/6/7/8" .AND. LTEMPERI )

                    CCODPER := CVERBAROT

                    NHRSPERI := SRA->RA_PERICUL

                    NPERC_PERI := RCE->RCE_PERPE

                    LPROPDIA := !(CTIPOROT $ "3*5*6")

                    IF ( EMPTY(CCODPER) )

                        IF ( CTIPOROT $ "1*2*4" )

                            CCODPER := FGETCODFOL('1281')

                        EndIF

                        IF ( CTIPOROT == "3" )

                            CCODPER := FGETCODFOL('1302')

                        EndIF

                        IF ( CTIPOROT $ "5*6" )

                            IF ( CTIPOROT == "5" )

                                CCODPER := FGETCODFOL('1633')

                                IF ( LVB13MAT2 )

                                    CCODPERM := FGETCODFOL('1644')

                                EndIF

                                IF ( !LVB13MAT2 )

                                    CCODPERM := FGETCODFOL('1441')

                                EndIF

                            EndIF

                            IF ( CTIPOROT == "6" )

                                CCODPER := FGETCODFOL('1291')

                                CCODPERM := FGETCODFOL('1441')

                            EndIF

                        EndIF

                    EndIF

                EndIF

            EndIF

            If Alltrim(CCODPER) <> ""
                nPosPd     := fLocaliaPd(CCODPER)
                If NPERC_PERI > 0 .and. nPosPd > 0
                    nPosDescFalta    := fLocaliaPd(cPDDescFalta)
                    nPosDescDSR      := fLocaliaPd(cPDDescDSR)
                    IF nPosDescFalta > 0 
                        FGERAVERBA(cPdFalta, (aPd[nPosDescFalta,5] ) * (NPERC_PERI/100) , aPd[nPosDescFalta,4] )
                    ENDIF
                    IF nPosDescDSR > 0 
                        FGERAVERBA(cPdDSR, (aPd[nPosDescDSR,5] ) * (NPERC_PERI/100) , aPd[nPosDescDSR,4] )
                    ENDIF
                EndIf
            EndIf

        EndIF


    End Sequence

    RestArea(aAreaAtual)

Return

