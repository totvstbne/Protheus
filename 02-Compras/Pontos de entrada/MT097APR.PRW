#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function MT097APR
   Ponto de entrada para verificar se PC é do tipo Pedido Financeiro e 
   gerar um documento de entrada automaticamente com base nos dados do pedido
    @type  Function
    @author MConsult - Phablo Iago
    @since 30/12/2021
    @version 
    @param 
    @return 
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MT097APR()
    Local aArea := getArea()
	
    If SC7->C7_YPCPF == 'PF' .AND. SC7->C7_CONAPRO == "L"
		u_EXEC103(SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_NUM, "000", "DPF   ")
	EndIf
    
    restArea(aArea)
Return nil
