Unit JackPing;

Interface

Function Start_Ping_Pong : Boolean;

Implementation

uses
  JackUTIL, JackGrph, Dos, Crt;

Procedure Draw_Ball(Bx, By : Integer);
Begin
  PutPixel(  Bx,   By, 50);
  PutPixel(Bx-1,   By, 50);
  PutPixel(Bx+1,   By, 50);
  PutPixel(  Bx, By-1, 50);
  PutPixel(  Bx, By+1, 50);
end;
Procedure Draw_PaddleP(Y : Word);
Var
  i, j : Integer;
Begin
  For I := 1 to 20 do
   For J := 1 to 5 do
    PutPixel(J, Y + I-10, 115);
End;
Procedure Draw_PaddleC(Y : Word);
var
  i, j : Integer;
Begin
  For I := 1 to 20 do
   For J := 1 to 5 do
    PutPixel(320-J, Y + I-10, 145);
End;
Procedure Draw_Cage;
var
  i : Integer;
Begin
  For I := 10 to 199 do
  Begin
    PutPixel(  0, I, 15);
    PutPixel(319, I, 15);
  End;
  For I := 0 to 319 do
  Begin
    PutPixel(I,  10, 15);
    PutPixel(I, 199, 15);
  End;
End;


Function Start_Ping_Pong : Boolean;
Var
  AllUp            : Boolean;
  Y_Player, Y_Comp : Byte;
  Ball_X, Ball_Y   : Word;
  Ball_XS, Ball_YS : Single;
  Ch 		   : Char;
  I, J             : Integer;
  Ball_Speed       : Single;
  Speed_X, Speed_Y : Single;
  OldBKHandler     : Pointer;
  CPoints, PPoints : Byte;

Begin
  Y_Player := 99;
  Y_Comp   := 99;

  PPoints  := 0;
  CPoints  := 0;

  Ball_XS  := 159;
  Ball_YS  := 99;

  Speed_X    := 10;
  Speed_Y    := 0;
  Ball_Speed := 10;

  GetIntVec(9, OldBKHandler);
  SetIntVec(9, @Check_KeyB);

  Repeat
    Ball_X := Round(Ball_XS);
    Ball_Y := Round(Ball_YS);
    Ball_Speed := Ball_Speed + 0.01;

    Clear_Screen;
    Draw_Cage;
    Draw_Ball(Ball_X, Ball_Y);
    Draw_PaddleP(Y_Player);
    Draw_PaddleC(Y_Comp);
    Text_out(1, 10, 15, IntToStr(PPoints));
    Text_out(300, 10, 15, IntToStr(CPoints));
    Draw_Screen;
    Delay(10);

    Ball_XS := Ball_XS + Speed_X/4;
    Ball_YS := Ball_YS + Speed_Y/4;

    If ((Ball_XS     >= 314) and
        (Y_Comp + 10 > Ball_YS) and
        (Y_Comp - 10 < Ball_YS)) then
    Begin
      Speed_Y := (Ball_YS - Y_Comp);
      Speed_X := -Sqrt(Sqr(Ball_Speed) - Sqr(Speed_Y));
    End;

    If ((Ball_XS       <= 6) and
        (Y_Player + 10 > Ball_YS) and
	(Y_Player - 10 < Ball_YS)) then
    Begin
      Speed_Y := (Ball_YS - Y_Player);
      Speed_X := Sqrt(Sqr(Ball_Speed) - Sqr(Speed_Y));
    end;

    If (Ball_YS < 12) or (Ball_YS > 196) then Speed_Y := -Speed_Y;
    If (Ball_XS < 310) then
    Begin
      If (Y_Comp > Ball_YS) Then
      Begin
        If Y_Comp > 20 then Dec(Y_Comp, 2);
      end else
      If Y_Comp < 188 then Inc(Y_Comp, 2);
    end else
      Y_Comp := Random(5)-2 + Y_Comp;

    If Ball_XS <   0 then Inc(CPoints);
    If Ball_XS > 320 then Inc(PPoints);
    If (Ball_XS < 0) or (Ball_XS > 320) then
    Begin
      If Ball_XS < 0 then Speed_X := -10 else Speed_X := 10;
      Speed_Y    := 0;
      Ball_XS    := 159;
      Ball_YS    := 99;
      Ball_Speed := 10;
    End;
    If Keyb_Table[72] then If Y_Player >  20 then Dec(Y_Player, 2);
    If Keyb_Table[80] then If Y_Player < 188 then Inc(Y_Player, 2);
  Until KeyB_Table[1] or (CPoints = 11) or (PPoints = 11);

  Repeat
    AllUp := True;
    For I := 1 to 128 do If Keyb_Table[I] then AllUp := False;
  Until AllUp = True;
  SetIntVec(9, OldBkHandler);

  If PPoints = 11 then
    Start_Ping_Pong := True
  else
    Start_Ping_Pong := False;
End;

End.