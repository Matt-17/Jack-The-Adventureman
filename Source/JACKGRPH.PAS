Unit JackGrph;

Interface

Uses
  JackTCV;

Procedure Graphic_Mode(Mode : Byte);

Procedure Clear_Screen;
Procedure Fill_Screen(Color : Byte);
Procedure Draw_Screen;
Procedure Wait_Retrace;

Procedure PutPixel(X, Y : Word; Color : Byte);
Function  GetPixel(X, Y : Word) : Byte;

Procedure Set_Palette;
Procedure Set_PaletteBW;
Procedure SetPalCol(Nr, R, G, B : Byte);
Procedure GetPalCol(Nr : Byte; var R, G, B : Byte);

Procedure Interpol(I : Byte);

Procedure Graph_Init;
Procedure Graph_Exit;

Implementation

Uses
  JackUtil;

Var
  ScreenBuf : ^TScreenBuf;

Procedure Graphic_Mode(Mode : Byte); Assembler;
Asm
  mov ah, 00
  mov al, Mode
  int 10h
End;

Procedure Clear_Screen;
Begin
  FillChar(ScreenBuf^, 64000, 0);
End;

Procedure Fill_Screen(Color : Byte);
Begin
  FillChar(ScreenBuf^, 64000, Color);
End;

Procedure Wait_Retrace; Assembler;
Asm
  mov dx, 3DAh
  @l1:
  in  al, dx
  and al, 08h
  jnz @l1
  @l2:
  in  al, dx
  and al, 08h
  jz  @l2
End;

Procedure PutPixel(X, Y : Word; Color : Byte);
Begin
  If (X >= 0) and (X < 320) and
     (Y >= 0) and (Y < 200) and
     (Color <> 0) then
   Byte(Ptr(Seg(ScreenBuf^),Ofs(ScreenBuf^)+X + Y SHL 8 + Y SHL 6)^) := Color;
End;

Function GetPixel(X, Y : Word) : Byte;
Begin
  GetPixel := Byte(Ptr(Seg(ScreenBuf^),Ofs(ScreenBuf^)+X + Y SHL 8 + Y SHL 6)^);
{  GetPixel := Byte(Ptr($A000, X + Y SHL 8 + Y SHL 6)^);}
End;

Procedure Set_PaletteBW;
Var
  I : Integer;
Begin
  For I := 0 to 255 do
  Begin
    SetPalCol(I, I div 4, I div 4, I div 4);
  End;
End;

Procedure Set_Palette;
Var
  I, J : Integer;
Begin
  For I := 0 to 15 do
  Begin
    J := I * 4;
    If I > 0 then
      SetPalCol(  I,    J-4,    J-4,  J-4);   { Schwarz Weiss Verlauf }
    SetPalCol( I+16,   47-J div 3,  47-J div 3*2,  0); { Hautfarben }
    SetPalCol( I+32,    J,    0,  0);         { Schwarz Rot }
    SetPalCol( I+48,   63,    J,  J);         { Rot Weiss   }
    SetPalCol( I+64,    0,    J,  0);         {  }
    SetPalCol( I+80,    J,   63,  J);         {  }
    SetPalCol( I+96,    0,    0,  J);         {  }
    SetPalCol(I+112,    J,    J,  63);        {  }
    SetPalCol(I+128,    J,    J,   0);        {  }
    SetPalCol(I+144,   63,   63,   J);        {  }
    SetPalCol(I+160,    J,    0,   J);        {  }
    SetPalCol(I+176,   63,    J,  63);        {  }
    SetPalCol(I+192,    0,    J,   J);        {  }
    SetPalCol(I+208,    J,   63,  63);        {  }

    SetPalCol(I+224,    16+I,    32-I,  0);
    SetPalCol(I+240,  32+I,    16-I,  0);
  End;
  SetPalCol(15, 63, 63, 63);
End;

Procedure SetPalCol(Nr, R, G, B : Byte);
Begin
  Port[$3c8] := Nr;
  Port[$3c9] := R;
  Port[$3c9] := G;
  Port[$3c9] := B;
End;

Procedure GetPalCol(Nr : Byte; var R, G, B : Byte);
Begin
  Port[$3c7] := Nr;
  R := Port[$3c9];
  G := Port[$3c9];
  B := Port[$3c9];
End;

Procedure Interpol(I : Byte);
Var
  Offs, Addr, C, Col : Word;
  Color, Loop	     : Byte;
Begin
  Addr 	:= Seg(ScreenBuf^);
  For Loop := 1 to I do
  Begin
    For Offs := 0 to 63999 do
    Begin
      Col := 0;
      If Offs > 320 then Inc(Col, MEM[Addr:Offs-320]);
      If Offs >   1 then Inc(Col, MEM[Addr:Offs-  1]);
      If Offs < 63999-  1 then Inc(Col, MEM[Addr:Offs+  1]);
      If Offs < 63999-320 then Inc(Col, MEM[Addr:Offs+320]);
{      If Offs > 321 then Inc(Col, MEM[Addr:Offs-321]);
      If Offs > 319 then Inc(Col, MEM[Addr:Offs-319]);
      If Offs < 63999-319 then Inc(Col, MEM[Addr:Offs+319]);
      If Offs < 63999-321 then Inc(Col, MEM[Addr:Offs+321]);
 }     Color := Col shr 2;
      MEM[Addr:Offs] := Color;
    End;
  End;
End;


Procedure Draw_Screen;
Var
  X, Y : Word;
  B    : Byte;
Begin
  Wait_Retrace;
  Move(ScreenBuf^, MEM[$A000:0000], 64000);
End;


Procedure Graph_Init;
Begin
  GetMem(ScreenBuf, 64000);
End;

Procedure Graph_Exit;
Begin
  FreeMem(ScreenBuf, 64000);
End;

End.