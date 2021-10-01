#include 'totvs.ch'
/*/{Protheus.doc} FI040ROT
Altera��o de Vencimento
@author Rodrigo Lucas
@since 12/03/21
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FI040ROT
	Local aRotinaNew	:= PARAMIXB

	if funname() <> "FINA740"
		aAdd( aRotinaNew,	{ "Intru��o de Baixa#" ,"u_RFINA05", 0 , 4, ,.F.})
	endif

Return aRotinaNew
