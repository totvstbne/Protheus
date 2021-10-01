#INCLUDE "PROTHEUS.CH"
#Include "TopConn.CH"

//*****************************************************************************
/*/{Protheus.doc} RGPER005
Função para calculo desconto insalubridade sobre DSR e Falta Servnac - DESCINSA
@author edlardo neves - mconsult
@since 09/11/2020
@version 1.0
@return Lógico, .T. se pode calcular .F. caso contrário
/*/
//*****************************************************************************
User Function RGPER005()
//*****************************************************************************
    Local aAreaAtual := GetArea()
    Local nPosPd     := 0 //fLocaliaPd("107")
    Local cPdDescFalta := "201"
    Local cPdDescDSR   := "22A"
    Local nPosDescFalta:= 0
    Local nPosDescDSR  := 0
    Local cPdFalta     := "22P"
    Local cPdDSR       := "22S"
    Local nVlrSalBase  := 0 

    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf

        IF ( ( ( CTIPOROT == "2" .AND. P_SOMAINC ) .OR. ( CTIPOROT # "2" ) ) )

            IF ( CTIPOINS <> "1" .AND. CBCALINS $ "3*4*7*8" )

                CCODINS := CVERBAROT

                IF ( EMPTY(CCODINS) )

                    IF ( CTIPOROT $ "1*2*4" )

                        CCODINS := FGETCODFOL('1282')

                    EndIF

                    IF ( CTIPOROT == "3" )

                        CCODINS := FGETCODFOL('1306')

                    EndIF

                    IF ( CTIPOROT $ "5*6" )

                        IF ( CTIPOROT == "5" )

                            CCODINS := FGETCODFOL('1635')

                            IF ( LVB13MAT2 )

                                CCODINSM := FGETCODFOL('1646')

                            EndIF

                            IF ( !LVB13MAT2 )

                                CCODINSM := FGETCODFOL('1443')

                            EndIF

                        EndIF

                        IF ( CTIPOROT == "6" )

                            CCODINS := FGETCODFOL('1293')

                            CCODINSM := FGETCODFOL('1443')

                        EndIF

                    EndIF

                EndIF
            ElseIF ( CTIPOINS == "2" .AND. CBCALINS $ "1256" )

                CCODINS := CVERBAROT

                IF ( EMPTY(CCODINS) )

                    IF ( CTIPOROT $ "1*2*4" )

                        CCODINS := FGETCODFOL('0037')

                    EndIF

                EndIF

            ElseIF ( CTIPOINS == "3" .AND. CBCALINS $ "1256" )

                CCODINS := CVERBAROT

                IF ( EMPTY(CCODINS) )

                    IF ( CTIPOROT $ "1*2*4" )

                        CCODINS := FGETCODFOL('0038')

                    EndIF

                EndIF

            ElseIF ( CTIPOINS == "4" .AND. CBCALINS $ "1256" )

                CCODINS := CVERBAROT

                IF ( EMPTY(CCODINS) )

                    IF ( CTIPOROT $ "1*2*4" )

                        CCODINS := FGETCODFOL('0039')

                    EndIF

                EndIF

            EndIF

            If Alltrim(CCODINS) <> ""
                nPosPd     := fLocaliaPd(CCODINS)
                If NPERC_INS > 0 .and. nPosPd > 0
                    nPosDescFalta    := fLocaliaPd(cPDDescFalta)
                    nPosDescDSR      := fLocaliaPd(cPDDescDSR)
                    IF nPosDescFalta > 0 
                        If CBCALINS <> "1"
                            FGERAVERBA(cPdFalta, (aPd[nPosDescFalta,5] ) * (NPERC_INS/100) , aPd[nPosDescFalta,4] )
                        else
                            nVlrSalBase := ( VAL_SALMIN / 30) *  aPd[nPosDescFalta,4] 
                            FGERAVERBA(cPdFalta, ( nVlrSalBase ) * (NPERC_INS/100) , aPd[nPosDescFalta,4] )
                        ENDIF
                    ENDIF
                    IF nPosDescDSR > 0 
                        If CBCALINS <> "1"
                            FGERAVERBA(cPdDSR, ( aPd[nPosDescDSR,5] ) * (NPERC_INS/100) , aPd[nPosDescDSR,4] )
                        else
                            FGERAVERBA(cPdDSR, ( aPd[nPosPd,5] / 30 ) * aPd[nPosDescDSR,4] , aPd[nPosDescDSR,4] )
                        ENDIF
                    ENDIF
                EndIf
            EndIf

        EndIF

    End Sequence

    RestArea(aAreaAtual)

Return

