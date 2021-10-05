#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RPFA007
Gravação da alçada do Pedido Financeiro
@author Diogo
@since 06/01/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RPFA007(nOpert,oModel)
	Local aDocto 	:= {}
	Local cChave 	:= ZA7->ZA7_NUM + ZA7->ZA7_PARCEL
	Local aGetArea 	:= getArea()
	//[1] Numero do documento
	//[2] Tipo de Documento
	//[3] Valor do Documento
	//[4] Codigo do Aprovador
	//[5] Codigo do Usuario
	//[6] Grupo do Aprovador
	//[7] Aprovador Superior
	//[8] Moeda do Documento
	//[9] Taxa da Moeda
	//[10] Data de Emissao do Documento
	//[11] Grupo de Compras
	aDocto := { cChave ,;
	"PF"			,;
	ZA7->ZA7_VALOR	,;
	,;
	,;
	ZA7->ZA7_GPRAPV	,;
	,;
	1				,;
	,;
	ZA7->ZA7_EMISSA }

	If cValtochar(nOpert) == "3" //Inclusão
		MaAlcDoc(aDocto,,1,,)
	Elseif cValtochar(nOpert) == "4" //Alteração
		MaAlcDoc(aDocto,,3,,)
		MaAlcDoc(aDocto,,1,,)
	Elseif cValtochar(nOpert) == "5" //Exclusão
		MaAlcDoc(aDocto,,3,,)
	Endif
	If cValtochar(nOpert) $ "3/4"
		cUpd:= "UPDATE "+RetSqlName("SCR")+" SET CR_YNOMFOR = '"+alltrim(ZA7->ZA7_NOMFOR)+"', CR_YDESPFX = '"+alltrim(ZA7->ZA7_DESPFX)+"' "
		cUpd+= "WHERE CR_NUM = '"+alltrim(cChave)+"' AND CR_TIPO = 'PF' AND CR_FILIAL = '"+xFilial("SCR")+"' "
		tcSqlExec(cUpd)
		tcRefresh(RetSqlName("SCR"))
	Endif
	RestArea(aGetArea)
return