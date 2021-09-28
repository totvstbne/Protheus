#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'FWMVCDEF.ch'

/*/{Protheus.doc} MATA360
PE MVC Grupo de produtos
@author Diogo
@since 14/03/2019
@version P12

@type function
/*/
user function MATA035()
	Local aParam		:= PARAMIXB
	Local xRet			:= .T.
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local lIsGrid		:= .F.
	Local nLinha		:= 0
	Local nQtdLinhas	:= 0
	Local cMsg			:= ''
	If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]
		lIsGrid    := "GRID" $ oObj:ClassName()
		cClasse := oObj:ClassName()
		If lIsGrid
			nQtdLinhas	:= oObj:GetQtdLine()
			nLinha		:= oObj:nLine
		EndIf
		If	cIdPonto == 'FORMCOMMITTTSPRE'
			If cIdModel=="MATA035_SBM"
				If oObj:GetOperation()==MODEL_OPERATION_UPDATE //oObj:GetOperation()==MODEL_OPERATION_INSERT
					If alltrim(oObj:getValue("BM_YITEMCC")) == "S" //Tem item contabil
						cQuery:= "SELECT B1_COD FROM "+RetSqlName("SB1")+" SB1 "
						cQuery+= "WHERE SB1.D_E_L_E_T_ = ' ' AND "
						cQuery+= "B1_FILIAL = '"+xFilial("SB1")+"' AND "
						cQuery+= "B1_GRUPO = '"+oObj:getValue("BM_GRUPO")+"' "
						tcQuery cQuery new Alias QRSB1X
						while QRSB1X->(!Eof())
							u_fSetCTD(substr(QRSB1X->B1_COD,3,len(QRSB1X->B1_COD)),QRSB1X->B1_COD) //Inclusão do item contábil
						QRSB1X->(dbSkip())
						Enddo
						QRSB1X->(dbCloseArea())
					Endif
				EndIf
			EndIf
		EndIf
	EndIf
return xRet