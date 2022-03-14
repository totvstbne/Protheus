#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'FWMVCDEF.CH'

/*/{Protheus.doc} FT300GRA
Oportunidade como ganha
@author Diogo
@since 12/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function FT300GRA()

Local oModel := PARAMIXB[1] 
Local oMdlAD1 := oModel:GetModel("AD1MASTER")
Local nOperation 	:= oModel:GetOperation()
Local cDe			:= "" 
Local cPara			:= ""

If nOperation == MODEL_OPERATION_UPDATE .And. oMdlAD1:GetValue("AD1_STATUS") == "9"

	//Select da ABS para identificar qual o local
	cQuery :="SELECT ABS_LOCAL FROM "+RetSqlName("ABS")+ " ABS "
	cQuery +="WHERE D_E_L_E_T_ = ' ' AND "
	cQuery +="ABS_FILIAL = '"+xFilial("ABS")+"' AND "
	cQuery +="ABS_CODIGO = '"+oMdlAD1:GetValue("AD1_CODCLI")+"' AND "
	cQuery +="ABS_LOJA = '"+oMdlAD1:GetValue("AD1_LOJCLI")+"' "
	If select("QABS") > 0
		QABS->(dbCloseArea())
	Endif
	TcQuery cQuery new Alias QABS

	while QABS->(!Eof())
	
		If substr(QABS->ABS_LOCAL,1,1) <> 'P' //Já é um cliente 
			QABS->(dbSkip())
			loop
		Endif
		cDe	 := QABS->ABS_LOCAL
		M->ABS_ENTIDA = '1'
		M->ABS_CODIGO:= oMdlAD1:GetValue("AD1_CODCLI")
		cPara:= u_RSVNG001()
		//alert(cPara)		
		aUpd:= {	{"AA3","AA3_CODLOC"},;
					{"AAT","AAT_LOCAL"},;
					{"ABB","ABB_LOCAL"},;
					{"ABS","ABS_LOCAL"},;
					{"ADY","ADY_LOCAL"},;
					{"ADZ","ADZ_LOCAL"},;
					{"TE4","TE4_LOCAL"},;
					{"TFF","TFF_LOCAL"},;
					{"TFG","TFG_LOCAL"},;
					{"TFH","TFH_LOCAL"},;
					{"TFI","TFI_LOCAL"},;
					{"TFL","TFL_LOCAL"},;
					{"TIT","TIT_CODABS"},;
					{"TIW","TIW_NLOCAL"},;
					{"TW2","TW2_LOCAL"},;
					{"TW9","TW9_LOCAL"}}
		For nX:=1 To len(aUpd)
			cUpdate:= " UPDATE "+RetSqlName(aUpd[nX][1])+" SET "+aUpd[nX][2]+" = '"+cPara+"' "
			cUpdate+= " WHERE "+aUpd[nX][2]+" = '"+cDe+"' AND D_E_L_E_T_ = ' ' "
			cUpdate+= " AND "+aUpd[nX][1]+"_FILIAL = '"+xFilial(aUpd[nX][1])+"' "
			tcSqlExec(cUpdate)
			tcRefresh(RetSqlName(aUpd[nX][1]))
		Next
		dbSelectArea("QABS")
		QABS->(dbSkip())
	Enddo
	QABS->(dbCloseArea())
Endif
Return