#INCLUDE "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH" 

//*************************************************************************************
//** Programa   : MT103FIM   * Autora : Alana Oliveira	           * Data : 26/11/21 **
//*************************************************************************************
//** Descricao  : Operação após gravação da NFE									 	 **
//*************************************************************************************
//** Uso        : Exclusivo da SERVNAC                                               **
//*************************************************************************************


User function MT103FIM      


Local _aArea      := GetArea() 
Local _aAreaE2 := GetArea("SE2") 
Local _aAreaED := GetArea("SED")
Local _aAreaD1 := GetArea("SD1")
Local _aAreaC7 := GetArea("SC7")

_cOpc1 := PARAMIXB[1] // Opcao Escolhida no Menu
_cOpc2 := PARAMIXB[2] // Botao Clicado OK/Cancelar

If _cOpc2 == 1 // Clicado OK  

    If _cOpc1 == 3 .Or. _cOpc1 == 4 .AND. SD1->D1_PEDIDO <> ''// Menu Incluir/Classificar Documento de Entrada
		  
		DbSelectArea("SC7")
		DbSetOrder(1)	
		If SC7->(DBSEEK(xFilial("SC7")+SD1->D1_PEDIDO))
            	
          	If UPPER(SC7->C7_YCARTAO) == "S" .AND.  !Empty(SC7->C7_YBANDEI) 
          
           		cSql := " UPDATE "+RetSqlName("SE2")  "
           	   	cSql += "    SET E2_YBANDEI = '"+SC7->C7_YBANDEI+"',E2_YCARTAO= 'S' "
    	   	   	cSql += "       WHERE D_E_L_E_T_ = ' '     "
    	  	   	cSql += "      AND E2_FILIAL+E2_PREFIXO+E2_NUM+E2_TIPO+E2_FORNECE =    " 
    	  	   	cSql += "       '"+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_TIPO+E2_FORNECE)+"' " 
    	        cSql += "       AND E2_EMISSAO = '"+dtos(SE2->E2_EMISSAO)+"'
       
    	   		TCsqlexec(cSql)  
    	   			
    	  	Endif

		Endif

	Endif  
    	  
EndIf       

RestArea(_aAreaC7)
RestArea(_aAreaD1)
RestArea(_aAreaED)
RestArea(_aAreaE2)
RestArea(_aArea)
		
Return
