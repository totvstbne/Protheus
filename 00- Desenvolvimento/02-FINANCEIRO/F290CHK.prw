#include 'Protheus.ch'
	

user function F290CHK()

	Local cFiltro := PARAMIXB

    If funname() == "YFATAUT"

        cPesq:= 'AND E2_FORNECE ='    
        nIni:= AT( cPesq, cFiltro )
        If nIni > 0
            cTexto := substr(cFiltro,nIni,41)
            cFiltro:= REPLACE(cFiltro,cTexto,"")
        Endif

    Endif

Return cFiltro
