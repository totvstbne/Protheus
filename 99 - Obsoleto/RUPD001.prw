#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RUPD002
Executar Update
@author diogo
@since 08/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User function RUPD010()
Local aRea	 := GetArea()	
Local cSql	 := space(10000)
Local aPergs := {}
Local aRetOpc:= {}

	aAdd(aPergs,{11,"Sql - Separar com ;",cSql,".T.",".T.",.T.})
	If ParamBox(aPergs,"Update",aRetOpc,,,,,,,"_UPD01A",.F.,.F.)
		aUpd:= StrTokArr(aRetOpc[1],";")
		for nX:= 1 to len(aUpd)
			TcSqlExec(aUpd[nX])
		Next
	Endif
RestArea(aRea)
return
