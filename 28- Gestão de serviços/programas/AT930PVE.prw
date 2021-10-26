User Function AT930PVE()
Local aCabec := PARAMIXB[1] //Recebe o primeiro parâmetro "Cabeçalho"
Local aItens := PARAMIXB[2] //Recebe o segundo parâmetro "Itens"

AADD(aCabec, {"C5_USER", RetCodUsr(), Nil})
AADD(aCabec, {"C5_MDCONTR", TFJ->TFJ_CONTRT, Nil})
AADD(aCabec, {"C5_MDPLANI", TFL->TFL_PLAN, Nil})
AADD(aCabec, {"C5_RECISS", Posicione('ABS',1,xFilial('ABS')+TFL->TFL_LOCAL,'ABS_RECISS'), Nil})
AADD(aCabec, {"C5_ESTPRES", Posicione('ABS',1,xFilial('ABS')+TFL->TFL_LOCAL,'ABS_ESTADO'), Nil})
AADD(aCabec, {"C5_MUNPRES", Posicione('ABS',1,xFilial('ABS')+TFL->TFL_LOCAL,'ABS_CODMUN'), Nil})
AADD(aCabec, {"C5_YCC", TFL->TFL_YCC, Nil})
AADD(aCabec, {"C5_YCOMPET", M->TFV_DTINI, Nil})
 
Return {aCabec, aItens}
