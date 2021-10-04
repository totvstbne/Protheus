#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} RSVNC001
Consulta padrão customizada
RHK_CODFOR: ZA1_CODFOR
RHK_PLANO: ZA1_PLANO
RHL_PLANO: ZA1_PLNDP  
@author Diogo
@since 05/12/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
user function RSVNC001()
Local cVar 		:= ReadVar()
Local cCons 	:= ""
Local cCpoRet 	:= ""
Local cConteud	:= ""
Local cTpPlano	:= ""
Local cTpForn	:= ""
Local cCodFor 	:= ""
Local cCodPlano	:= ""
Local cFilter 	:= ""
Local cSvAlias	:= ""
Local cTip		:= ""

Local nCPn		:= 0 // Variavel utilizada quando é aberta mais de uma getdados ao mesmo tempo
Local xRet
Local oModel
Local oStructZA1
Local oStructZADet
Local oStructRHK
Local oStructRHL
Local oStructRHM
Local oStructRHN
Local oStructRHO
Local oStructSJX
Local oStructSLE
Local oStructSL0
Local bFilterRCC := { || .T. }

	If FunName() = "GPER008" .or. FunName() = "U_GPER008"//-- Relatório de Calculo do Plano de Saúde
		cCons := "S016"
		//-- "Fornecedor Odontologico De ?" e "Fornecedor Odontologico Ate ? "
		If cVar == "MV_PAR16" .Or. cVar == "MV_PAR17"
			cCons := "S017"
		//-- "Código Plano de ?" e "Código Plano até ?"
		ElseIf cVar == "MV_PAR20" .Or. cVar == "MV_PAR21"
			cCons := "S008"
		EndIf
		cCpoRet := "CODIGO"
	ElseIf FunName() = "GPER014"
		If cVar == "MV_PAR09"
			cCons := "S016"
		ElseIf cVar == "MV_PAR10"
			cCons := "S017"
		EndIf
		cCpoRet := "CODIGO"
	ElseIf cVar == "M->RB_CODAMED" .or. cVar == "SRB->RB_CODAMED" // DEPENDENTES ASSISTENCIA MEDICA
		If(cVar == "M->RB_CODAMED", cTip := GdFieldGet("RB_TIPAMED"), cTip := M->RB_TIPAMED)
		If(cTip == "2",	cCons := "S009", cCons := "S008")
		cCpoRet := "CODIGO"
	ElseIf cVar == "M->RB_ASODONT" .or. cVar == "SRB->RB_ASODONT" // DEPENDENTES ASSISTENCIA ODONTOLOGICA
		If(cVar == "M->RB_ASODONT", cTip := GdFieldGet("RB_TPASODO"), cTip := M->RB_TPASODO)
		If(cTip == "2",	cCons := "S014", cCons := "S013")
		cCpoRet := "CODIGO"
	ElseIf __READVAR == "M->CODFOR"           //CONSULTA F3 A PARTIR DE UMA TABELA SNNN
		If cCodigo == "S008" .or. cCodigo == "S009"	.or. cCodigo == "S028" .or. cCodigo == "S029" .Or. cCodigo == "S059"		// FORNECEDOR ASSISTENCIA MEDICA
			cCons := "S016"
			cCpoRet := "CODIGO"
		ElseIf cCodigo == "S013" .or. cCodigo == "S014" .or. cCodigo == "S030" .or. cCodigo == "S031" .Or. cCodigo == "S060"		// FORNECEDOR ASSISTENCIA ODONTOLOGICA
			cCons := "S017"
			cCpoRet := "CODIGO"
		EndIf
	ElseIf cVar $ "M->ZA1_CODFOR/M->RHK_CODFOR*M->RHK_PLANO/M->ZA1_PLANO/M->RHL_PLANO/M->ZA3_PLNDP/M->RHM_PLANO*M->RHN_CODFOR*M->RHN_PLANO*M->RHO_CODFOR*M->JX_CODFORN*M->JX_PLANO*M->L0_PLANO*M->LE_PLANO"
		oModel 		:= FWModelActive()
	
		If !(cVar $ "M->RHN_CODFOR*M->RHN_PLANO*M->RHO_CODFOR")
			If (cVar $ "M->JX_CODFORN*M->JX_PLANO*M->L0_PLANO*M->LE_PLANO")
				oStructSJX	:= oModel:GetModel("GPEA063_MSJX")
				cTpForn := oStructSJX:GetValue("JX_TPFORN")
			Elseif !("ZA1" $ alltrim(cVar)) .and. !("ZA3" $ alltrim(cVar)) 
				oStructRHK	:= oModel:GetModel( "GPEA001_MRHK" )
				cTpForn		:= oStructRHK:GetValue("RHK_TPFORN")
			Else
				cTpForn:=  oModel:GetModel( "ZA1DETAIL" ):GetValue("ZA1_TPFORN")
			EndIf
		ElseIf cVar $ "M->RHN_CODFOR*M->RHN_PLANO"
			oStructRHN	:= oModel:GetModel( "GPEA002_MRHN" )
			cTpForn		:= oStructRHN:GetValue("RHN_TPFORN")
		ElseIf cVar $ "M->RHO_CODFOR*M->RHO_PLANO"
			oStructRHO	:= oModel:GetModel( "GPEA003_MRHO" )
			cTpForn		:= oStructRHO:GetValue("RHO_TPFORN")
		EndIf
		
		If cVar $ "M->ZA1_CODFOR/M->RHK_CODFOR*M->RHN_CODFOR*M->RHO_CODFOR*M->JX_CODFORN"
			If cTpForn == "1"
				cCons := "S016"
				cCpoRet := "CODIGO"
			Else
				cCons := "S017"
				cCpoRet := "CODIGO"
			EndIf
			If(cVar == "M->RHK_CODFOR", bFilterRCC := {|| RCC->RCC_FILIAL == xFilial("RCC", SRA->RA_FILIAL )}, Nil )
			If(cVar == "M->ZA1_CODFOR", bFilterRCC := {|| RCC->RCC_FILIAL == xFilial("RCC", SRA->RA_FILIAL )}, Nil )
			If cVar == "M->RHO_CODFOR"  // Filtrar somente os fornecedores vinculados ao funcionario 
				If FunName() == "GPEA003"
					cSvAlias := Alias()
					DbSelectArea("RHK")
					DbSetOrder( 1 )
					DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
					cCodFor := ""
					While !Eof() .and. RHK->RHK_FILIAL + RHK->RHK_MAT == SRA->RA_FILIAL + SRA->RA_MAT
						cCodFor += RHK->RHK_CODFOR + "*" 
						DbSkip()
					EndDo
					//Procurar Na RHN
					DbSelectArea("RHN")
					DbSetOrder( 1 )
					DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
					While !Eof() .and. RHN->RHN_FILIAL + RHN->RHN_MAT == SRA->RA_FILIAL + SRA->RA_MAT
						If (RHN->RHN_OPERAC + RHN->RHN_TPALT == "2" + "04") .AND. !(RHN->RHN_CODFOR $ cCodFor)
							cCodFor += RHN->RHN_CODFOR + "*"
						EndIf
					DbSkip()
					EndDo
					DbSelectArea( cSvAlias )
					cFilter := "{ || Substr(RCC->RCC_CONTEU,1,3) $ '" + cCodFor + "' }"
					bFilterRCC := &cFilter
					
				EndIf
			EndIf
			
		ElseIf cVar $ "M->ZA1_PLANO/M->RHK_PLANO*M->RHL_PLANO/M->ZA3_PLNDP/M->RHM_PLANO*M->RHN_PLANO*M->JX_PLANO*M->L0_PLANO*M->LE_PLANO"
		
			If !(cVar $ "M->RHN_PLANO")
				If(cVar $ "M->JX_PLANO*M->L0_PLANO*M->LE_PLANO")
					oStructSLE	:= oModel:GetModel( "GPEA063_MSLE" )
					oStructSL0	:= oModel:GetModel( "GPEA063_MSL0" )
					cCodPlano := oStructSJX:GetValue("JX_CODFORN")
				ElseIf !("ZA1" $ alltrim(cVar)) .and. !("ZA3" $ alltrim(cVar))
					oStructRHL	:= oModel:GetModel( "GPEA001_MRHL" )
					oStructRHM	:= oModel:GetModel( "GPEA001_MRHM" )
					cCodPlano	:= oStructRHK:GetValue("RHK_CODFOR")
				EndIf
			Else
				cCodPlano	:= oStructRHN:GetValue("RHN_CODFOR")
			EndIf
			If "ZA1" $ alltrim(cVar) .or. "ZA3" $ alltrim(cVar) 
				oStructZA1	:= oModel:GetModel( "ZA1DETAIL" )
				oStructZADet:= oModel:GetModel( "ZA1DEP" )
				cCodPlano	:= oModel:GetModel( "ZA1DETAIL" ):getValue("ZA1_CODFOR")
			Endif 
			
			If cVar == "M->RHK_PLANO"
				cTpPlano 	:= oStructRHK:GetValue("RHK_TPPLAN")
			ElseIf cVar == "M->ZA1_PLANO"
				cTpPlano 	:= oStructZA1:GetValue("ZA1_TPPLAN")
			ElseIf cVar == "M->RHL_PLANO"
				cTpPlano 	:= oStructRHL:GetValue("RHL_TPPLAN")
			ElseIf cVar == "M->ZA3_PLNDP"
				cTpPlano 	:= oStructZADet:GetValue("ZA3_TPLNDP")
			ElseIf cVar == "M->RHM_PLANO"
				cTpPlano 	:= oStructRHM:GetValue("RHM_TPPLAN")
			ElseIf cVar == "M->RHN_PLANO"
				cTpPlano 	:= oStructRHN:GetValue("RHN_TPPLAN")
			ElseIf cVar == "M->JX_PLANO"
				cTpPlano := oStructSJX:GetValue("JX_TPPLANO")
			ElseIf cVar == "M->L0_PLANO"
				cTpPlano := oStructSL0:GetValue("L0_TPPLANO")
			ElseIf cVar == "M->LE_PLANO"
				cTpPlano := oStructSLE:GetValue("LE_TPPLANO")
			EndIf
			
			If cTpForn == "1" .And. cTpPlano == "2"
				cCons := "S009"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,83,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "1" .And. cTpPlano == "1"
				cCons := "S008"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,92,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "1" .And. cTpPlano == "3"
				cCons := "S028"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,95,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "1" .And. cTpPlano == "4"
				cCons := "S029"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,113,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "1" .and. cTpPlano == "5"
				cCons := "S059"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,95,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			Elseif cTpForn == "2" .And. cTpPlano == "2"
				cCons := "S014"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,83,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "2" .And. cTpPlano == "1"
				cCons := "S013"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,92,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "2" .And. cTpPlano == "3"
				cCons := "S030"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,95,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "2" .And. cTpPlano == "4"
				cCons := "S031"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,110,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			ElseIf cTpForn == "2" .and. cTpPlano == "5"
				cCons := "S060"
				cFilter := "{ || Substr(RCC->RCC_CONTEU,95,3) ==  '" + cCodPlano + "' }"
				bFilterRCC := &cFilter
			EndIf
			cCpoRet := "CODIGO"
		EndIf
	EndIf
	
	// n - Variavel de posicionamento do objeto GetDados
	// O trecho abaixo controla para que não haja conflito entre 2 GetDados, caso seja 
	// disparada uma consulta F3 entre 2 tabelas. Ex.: S008 faz consulta em S016
	If Type('n') =="N"
		nCpn := n
	EndIf
	
	xRet := Gp310SXB(cCons, cCpoRet, bFilterRCC )
	
	If ValType(xRet)<> "L" .or. (ValType(xRet)== "L"  .and. !xRet)
		VAR_IXB := &__READVAR
	EndIf
	
	If nCpn > 0
		n := nCpn
	EndIf
	
	If ValType(xRet) <> "L"
		xRet := .F.
	EndIf
	
Return( xRet )