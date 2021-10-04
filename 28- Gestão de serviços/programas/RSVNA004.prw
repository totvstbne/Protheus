#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RSVNA004
Alteração da data de cancelamento
@author Diogo
@since 19/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSVNA004()
	Local dDataC	:= CN9->CN9_YDTCAN
	Local aRetOpc 	:= {}
	Local aPergs	:= {}
	Local aTipo		:= {}
	aadd(aTipo, "1=Sim")
	aadd(aTipo, "2=Não")

	If CN9->CN9_SITUAC <> '05'
		Alert("Permitido alteração de data do cancelamento somente para contratos vigentes")
		Return
	Endif
	aAdd( aPergs ,{1,"Data Cancelamento", dDataC,"@!",'.T.','','.T.',40,.F.})
	aAdd( aPergs ,{2,"Renovação",1, aTipo, 50,'.T.',.T.})
	If ParamBox(aPergs,"Informe Data Cancelamento",aRetOpc,,,,,,,"_RSVNA04A",.T.,.T.)
		RecLock("CN9",.F.)
			CN9->CN9_YDTCAN:= aRetOpc[1]
			CN9->CN9_YRENOV:= iif(substr(cValtochar(aRetOpc[2]),1,1) =="1","S","N") 
		MsUnlock()
		msgInfo("Alteração modificada com sucesso")
	Endif	
return