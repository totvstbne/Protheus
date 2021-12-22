#Include 'Protheus.ch'

/*--------------------------------------------------------------------------------------------------------------*
| P.E.:  MT094END                                                                                             |
| Autora: Alana Oliveira em 20.12.2021                                                                        |
| Desc:  Ponto de Entrada que permite lançar PCO na liberação de Pedidos de Compra                            |
| Link:  https://tdn.totvs.com/display/public/PROT/TUMXYE_DT_PONTO_ENTRADA_MT094END                           |
*--------------------------------------------------------------------------------------------------------------*/
 
User Function MT094END()

Local cDocto  := PARAMIXB[1] // Número do Documento
Local cTipo   := PARAMIXB[2] // Tipo do documento (PC, NF, SA, IP, AE)
Local nOpc    := PARAMIXB[3] //Operação a ser executada (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)
Local cFilDoc := PARAMIXB[4] // Filial do documento
Local cArea   := GetArea()

 If nOpc == 5 // Se for rejeição

 	While SC7->(!Eof()) .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
		
		//################################################################################
		//# Inicializa a gravacao dos lancamentos do SIGAPCO          					 #
		//################################################################################

		PcoIniLan("000055")

		Begin Transaction

		//################################################################################
		//# Grava os lancamentos nas contas orcamentarias SIGAPCO                        #
		//################################################################################

		PcoDetLan("000055","01","MATA097",.T.) // Indica Exclusao do Lançamento do PCO	

		End Transaction

		//################################################################################
		//# Finaliza a gravacao dos lancamentos do SIGAPCO                               #
		//################################################################################

		PcoFinLan("000055")

		dbSelectArea("SC7")
		dbSkip()
	EndDo



 Endif

RestArea(cArea)

Return

 