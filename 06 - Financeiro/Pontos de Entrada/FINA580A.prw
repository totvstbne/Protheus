#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} FINA580A
Gravação da Hora na liberação de pagamento
@author Diogo
@since 23/04/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User function FINA580A()
	Local aArea:= getArea()
	Reclock("SE2",.F.)
		SE2->E2_YHORAPR := substr(time(),1,8)
	MsUnlock()
	RestArea(aArea)
Return