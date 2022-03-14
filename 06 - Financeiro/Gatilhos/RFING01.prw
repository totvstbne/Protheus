#INCLUDE "rwmake.ch"

/*
*****************************************************************************
*****************************************************************************
** Programa: RFING01                                                       **
** Autor: Gerardo Araújo                                                   **
** Data:  30/05/2018                                                       **
*****************************************************************************
** Desc.  ** Converter linha digitável em código de barras.                **
*****************************************************************************
*****************************************************************************
*/

User Function RFING01()
Local cRet	:= M->E2_CODBAR
Local nValor:= 0      
Local cFgts := ""

cLinha:= Alltrim(&(ReadVar()))
cRet	:= calcula_barra(cLinha)

IF !Empty(cLinha) .and. len(cLinha)==47
	nValor := Val(SubStr(cLinha,Len(cLinha)-9,8)+"."+SubStr(cLinha,Len(cLinha)-1,2))
EndIF
Return(cRet)

Static function calcula_barra(linha)
barra  := Replace(Replace(linha,".","")," ","")

if (modulo11_banco('34191000000000000001753980229122525005423000') != "1")
	alert('Função "modulo11_banco" está com erro!')
EndIF

if (Len(barra) < 47 )
	barra += Replicate("0",47-Len(barra))
Endif

if (Len(barra) != 47) .and. (Len(barra) != 48)
	alert ('A linha do Código de Barras está incompleta! '+cValToChar(Len(barra)))
EndIF                                       

If Len(barra) == 48 .AND. SUBSTR(barra,1,1) <> "8"
    MsgBox("Documento inválido! Somente é aceito documento DARF/Agua/Luz/Telefone com Linha Digitável iniciando com '8'","Documento Inválido","Alert")
    Return(.F.)
EndIf

IF Len(barra) == 47
	barra  := substr(barra,1,4)+substr(barra,33,15)+substr(barra,5,5)+substr(barra,11,10)+substr(barra,22,10)  
	
ELSEIF Len(barra) == 48
	
	cFgts := Substr(barra,17,4)  //--- Posicao 17 - 4 caracteres igual a 0179 ou 0180 ou 0181 significa FGTS
    If cFgts == "0179" .or. cFgts == "0180" .or. cFgts == "0181"                 
        barra := barra+SPACE(48-LEN(barra)) 
    Else
        barra := SUBSTR(barra,1,11)+SUBSTR(barra,13,11)+SUBSTR(barra,25,11)+SUBSTR(barra,37,11)
	EndIf
ENDIF

if Len(barra) == 47
	if (modulo11_banco(substr(barra,1,4)+substr(barra,6,39)) != substr(barra,5,1))
		alert('Digito verificador '+substr(barra,5,1)+', o correto é '+modulo11_banco(substr(barra,1,4)+substr(barra,6,39))+Chr(13)+'O sistema não altera automaticamente o dígito correto na quinta casa!')
		Return(Space(Len(&(ReadVar()))))
	EndIF
endif

Return(barra)

Static function calcula_linha(barra)
linha = Replace(Replace(barra,".","")," ","")

IF (modulo10('399903512') != "8")
	alert('Função "modulo10" está com erro!')
EndIF
if (Len(linha) != 44)
	alert ('A linha do Código de Barras está incompleta!')
EndIF

campo1 := substr(linha,1,4)+substr(linha,20,1)+'.'+substr(linha,21,4)
campo2 := substr(linha,25,5)+'.'+substr(linha,25+5,5)
campo3 := substr(linha,35,5)+'.'+substr(linha,35+5,5)
campo4 := substr(linha,5,1)			// Digito verificador
campo5 := substr(linha,6,14)		// Vencimento + Valor

if Len(barra) == 47
	if (  modulo11_banco(  substr(linha,1,4)+substr(linha,6,99)  ) != campo4 )
		alert('Digito verificador '+campo4+', o correto é '+modulo11_banco(  substr(linha,1,4)+substr(linha,6,99)  )+Chr(13)+'O sistema não altera automaticamente o dígito correto na quinta casa!')
		Return(Space(Len(&(ReadVar()))))
	EndIF
ENDIF

if (campo5 == "0")
	campo5 	:= '000'
EndIF

linha 	:= campo1 + modulo10(Replace(Replace(campo1,".","")," ",""))+' '+campo2 + modulo10(Replace(Replace(campo2,".","")," ",""))+' '+campo3 + modulo10(Replace(Replace(campo3,".","")," ",""))+' '+campo4+' '+campo5

Return(linha)

Static Function Modulo10(_cCampo)

Local nCont   := 0
Local nVal    := 0
Local Peso    := 0
Local Dezena  := 0
Local Resto   := 0
Local _cResult := ""

//** Banco do Brasil **
nCont  := 0
Peso   := 2

For i := Len(_cCampo) to 1 Step -1
	
	If Peso == 3
		Peso := 1
	Endif
	
	If Val(SUBSTR(_cCampo,i,1)) * Peso >= 10
		nVal  := Val(SUBSTR(_cCampo,i,1)) * Peso
		nCont += Val(SUBSTR(Str(nVal,2),1,1)) + Val(SUBSTR(Str(nVal,2),2,1))
	Else
		nCont += Val(SUBSTR(_cCampo,i,1)) * M->Peso
	Endif
	
	Peso++
Next

Dezena  := Substr(Str(nCont,2),1,1)
Resto   := ((Val(Dezena)+1) * 10) - nCont
If Resto  == 10
	_cResult := "0"
Else
	_cResult := Str(Resto,1)
Endif

Return(_cResult)

Static Function modulo11_banco(_cBarCampo)

Local i     := 0
Local nCont := 0
Local cPeso := 0
Local Resto := 0
Local Result := 0
Local DV_BAR := Space(1)

nCont := 0
cPeso := 2
For i := 43 To 1 Step -1
	nCont += Val( SUBSTR( _cBarCampo,i,1 )) * cPeso
	cPeso++
	If cPeso >  9
		cPeso := 2
	Endif
Next
Resto  := nCont % 11
Result := 11 - Resto
Do Case
	Case Result == 10 .or. Result == 11
		DV_BAR := "1"
	OtherWise
		DV_BAR := Str(Result,1)
EndCase

Return(DV_BAR)