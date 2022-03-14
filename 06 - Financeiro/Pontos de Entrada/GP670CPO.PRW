/*
*****************************************************************************
*****************************************************************************
** Programa: GP670CPO                                                      **
** Autor: Gerardo Araújo                                                   **
** Data:  08/07/2018                                                       **
*****************************************************************************
** Desc.  ** P.E. para alimentar campos na integração de títulos do GPE    **
**        ** com FIN (RC1 -> SE2).                                         **
*****************************************************************************
*****************************************************************************
*/

User Function GP670CPO() 

If !Empty(RC1->RC1_CC) .or. !Empty(RC1->RC1_DESCRI)

	Reclock("SE2",.F.)   
	
	SE2->E2_CCUSTO  := RC1->RC1_CC

	If !Empty(RC1->RC1_MAT)   
		
		SE2->E2_HIST := Posicione("SRA",1,RC1->RC1_FILTIT+RC1->RC1_MAT,"RA_NOME")	
	
	Else   
		
		SE2->E2_HIST := RC1->RC1_DESCRI                  
  	
  	Endif
	SE2->(MsUnlock())
Endif   

Return Nil
