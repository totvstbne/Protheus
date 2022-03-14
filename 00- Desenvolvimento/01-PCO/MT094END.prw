#Include 'Protheus.ch'
#Include "TopConn.CH"

/*--------------------------------------------------------------------------------------------------------------*
| P.E.:  MT094END                                                                                             |
| Autora: Alana Oliveira em 20.12.2021                                                                        |
| Desc:  Ponto de Entrada que permite lançar PCO na liberação de Pedidos de Compra                            |
| Link:  https://tdn.totvs.com/display/public/PROT/TUMXYE_DT_PONTO_ENTRADA_MT094END                           |
*--------------------------------------------------------------------------------------------------------------*/
 
User Function MT094END()

Local Area        := GetArea()
Local _nREC       := SC7->(RECNO())

Private cDocto    := PARAMIXB[1]
Private cTipoDoc  := PARAMIXB[2]  // (PC, NF, SA, IP, AE)
Private nOpc      := PARAMIXB[3]  //(1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear
Private cFilDoc   := PARAMIXB[4]

SC7->(dbSeek(xFilial("SC7")+AllTrim(SCR->CR_NUM)))
	
_nREC       := SC7->(RECNO())

If nOpc == 1

	Reclock("SCR",.F.)
		SCR->CR_YHORA := substr(time(),1,8)
	MsUnlock()
	
	If SCR->CR_NIVEL == "01"

		While SC7->(!Eof()) .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
			
			//################################################################################
			//# Inicializa a gravacao dos lancamentos do SIGAPCO          					 #
			//################################################################################

			PcoIniLan("000055")

			Begin Transaction

			//################################################################################
			//# Grava os lancamentos nas contas orcamentarias SIGAPCO                        #
			//################################################################################

			lRet:= PcoDetLan("000055","01","MATA097") 	

			End Transaction

			//################################################################################
			//# Finaliza a gravacao dos lancamentos do SIGAPCO                               #
			//################################################################################

			If !lRet
				PcoFreeBlq("000055")
			else
				PcoFinLan("000055")
			Endif

			dbSelectArea("SC7")
		
			SC7->(dbSkip())

		EndDo



	Endif
	
Endif

If nOpc == 2 .oR. nOpc == 5  // Se for estorno 

	//################################################################################
	//# Inicializa a gravacao dos lancamentos do SIGAPCO          					 #
	//################################################################################
	
	PcoIniLan("000055")		

 	While SC7->(!Eof()) .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
		
		Begin Transaction

		//################################################################################
		//# Grava os lancamentos nas contas orcamentarias SIGAPCO                        #
		//################################################################################

		lRet:= PcoDetLan("000055","01","MATA097",.T.) // Indica Exclusao do Lanamento do PCO	

		End Transaction

		dbSelectArea("SC7")
		
		SC7->(dbSkip())

	EndDo

	If !lRet
		PcoFreeBlq("000055")
	else
		PcoFinLan("000055")
	Endif

Endif 

SC7->(dbGoto(_nREC))

RestArea(Area)

Return
