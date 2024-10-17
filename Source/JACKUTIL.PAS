Unit JackUtil;

Interface

Uses
  JackTCV;


Var
  KeyB_Table : Array[1..128] of Boolean;
Function IntToStr(I : LongInt) : String;

Function File_Exist(Var S : String) : Boolean;


Function  Pow2(Exponent : Byte) : Byte;


Function LZ(S : String; N : Byte) : String;
Function LS(S : String; N : Byte) : String;



Function P2X(P : TPlayer) : LongInt;
Function P2Y(P : TPlayer) : LongInt;

Function P2XL(P : TPlayer) : LongInt;
Function P2XR(P : TPlayer) : LongInt;
Function P2XLB(P : TPlayer) : LongInt;
Function P2XRB(P : TPlayer) : LongInt;
Function P2YD(P : TPlayer) : LongInt;
Function P2YU(P : TPlayer) : LongInt;

Procedure Draw_Player(X, Y : Integer; Var P : TPlayer);
Procedure Draw_Piece(X, Y : Integer; Sp : TSprite);
Procedure Draw_World(P : TPlayer; S : TShoot);

Procedure Add_To_HighScore(Name : String; P : LongInt);
Procedure Del_HighScore;

Procedure Move_Player(Var P : TPlayer; Var S : TShoot; C : LongInt; Var Quit : Boolean);

Function Get_Number : Word;
Function Get_Name : String;

Procedure Create_Shoot(P : TPlayer; Var S : TShoot);
Procedure Move_Shot(Var S : TShoot; P : TPlayer);

Procedure Move_Enemies(P : TPlayer);

Procedure Enemy_Editor;
Procedure Item_Editor;
Procedure Sprite_Editor;
Procedure Player_Editor;
Procedure World_Editor;
Procedure Editors;


Procedure Text_out(X, Y : Word; Color : Byte; Text : String);

Procedure Init_Player(Var Player : TPlayer; Var Shot : TShoot);

Procedure FLoad_Items;
Procedure FLoad_Pieces;
Procedure FLoad_Enemies;

Procedure Check_KeyB; 

Procedure Save_World(Name : String);
Procedure Load_World(Name : String);
Procedure Save_Items(Name : String);
Procedure Load_Items(Name : String);
Procedure Load_Enemy(Name : String);


Procedure Check_Items(var P : TPlayer);
Procedure Check_Enemy(var P : TPlayer; Var S : TShoot);


Procedure Show_Enemy(Var P : TEnemy; I : Byte);
Procedure Get_Enemy(Var P : TEnemy; X : Word);
Procedure Set_Enemy(PNr : TEnemy_Pos; X : Word);

Procedure Show_Item(Var P :TItem; I : Byte);
Procedure Get_Item(Var P : TItem; X, Y : Word);
Procedure Set_Item(PNr : Byte; X, Y : Word);

Procedure Show_Piece(Var P :TPiece; I : Byte);
Procedure Get_Piece(Var P : TPiece; X, Y : Word);
Procedure Set_Piece(PNr : Byte; X, Y : Word);

Procedure Init_Util;
Procedure Exit_Util;


Implementation
Uses
  Dos, Crt, JackGrph, JackPing, JackScrs;

Type
  TFont = Array[1..8] of Byte;

Var
  Pieces    : PPieces;
  AllItems  : PAllItems;
  AllEnemy  : PEnemy_Kind;

  WorldBuf  : PLevel;
  ItemBuf   : PItems;
  EnemyBuf  : PEnemies;

  PlFile    : TPlayer_Sprite_File;

  Fonts     : Array[0..127] of TFont;

Function IntToStr(I : LongInt) : String;
Var
  S : string;
Begin
  Str(I, S);
  IntToStr := S;
End;
Procedure Check_KeyB; Interrupt;
Var
  Key : Byte;
Begin
  Key := Port[$60];
  If Key < 128 then
    KeyB_Table[Key] := True else
      KeyB_Table[Key - 128] := False;
  Port[$20] := $20;
End;

Function Pow2(Exponent : Byte) : Byte;
Begin
  Pow2 := 1 shl Exponent;
End;

Function File_Exist(Var S : String) : Boolean;
Var
  F : File;
Begin
  Assign(F, S);
  {$I-}
  Reset(F);
  {$I+}
  If IOResult = 0 then File_Exist := True else File_Exist := False;
  Close(F);
End;


Procedure Draw_Letter(X, Y : Word; Color : Byte; Text : TFont);
Var
  I, J, B : Byte;
Begin
  For I := 1 to 8 do
  Begin
    B := Text[I];
    For J := 0 to 7 do
      If (B and Pow2(J)) = Pow2(J) then PutPixel(X + (8-J), Y - (8-I), Color);
  End;
End;

Procedure Text_Out(X, Y : Word; Color : Byte; Text : String);
Var
  I : Byte;
  S : TFont;
Begin
  For I := 1 to Length(Text) do
  Begin
    If Ord(Text[I]) > 31 then
    Begin
      S := Fonts[Ord(Text[I])];
      Draw_Letter(X + I*8, Y, Color, S);
    End;
  End;
End;


Function P2X(P : TPlayer) : LongInt;
Begin
  P2X := P.Pos.X SHR 16 div BLS_X;
End;

Function P2Y(P : TPlayer) : LongInt;
Begin
  P2Y := P.Pos.Y SHR 16 div BLS_Y + 1;
End;

Function P2XL(P : TPlayer) : LongInt;
Begin
  P.Pos.X := P.Pos.X - 7 SHL 16;
  P2XL := P.Pos.X SHR 16 div 10;
End;
Function P2XR(P : TPlayer) : LongInt;
Begin
  P.Pos.X := P.Pos.X + 6 SHL 16;
  P2XR := P.Pos.X SHR 16 div 10;
End;

Function P2XLB(P : TPlayer) : LongInt;
Begin
  P.Pos.X := P.Pos.X - 6 SHL 16;
  P2XLB := P.Pos.X SHR 16 div 10;
End;
Function P2XRB(P : TPlayer) : LongInt;
Begin
  P.Pos.X := P.Pos.X + 5 SHL 16;
  P2XRB := P.Pos.X SHR 16 div 10;
End;

Function P2YD(P : TPlayer) : LongInt;
Begin
  P.Pos.Y := P.Pos.Y + 1 SHL 16;
  P2YD := P.Pos.Y SHR 16 div 10 + 1;
End;
Function P2YU(P : TPlayer) : LongInt;
Begin
  P.Pos.Y := P.Pos.Y - 23 SHL 16;
  P2YU := P.Pos.Y SHR 16 div 10 + 1;
End;

Procedure Add_To_HighScore(Name : String; P : LongInt);
Var
  Place : TPlace;
  High_File : THigh_File;
  HScore : THighScore;
  B : Word;
  I, J : Integer;
Begin
  Assign(High_File, HIGHSCORE_FILE);
  Reset(High_File);
  I := 1;
  While not EOF(High_File) do
  Begin
    Read(High_File, Place);
    HScore[I] := Place;
    Inc(I);
  End;
  Place.Name := Name;
  Place.Points := P;
  GetDate(Place.Year, Place.Month, Place.Day, B);
  HScore[10] := Place;

  For I := 1 to 9 do
   For J := I to 10 do
    If HScore[I].Points < HScore[J].Points then
    Begin
      Place := HScore[I];
      HScore[I] := HScore[J];
      HScore[J] := Place;
    End;
  Rewrite(High_File);
  For I := 1 to 10 do
    Write(High_File, HScore[I]);
  Close(High_File);
  Show_HighScore;
End;

Procedure Del_HighScore;
Var
  Place : TPlace;
  High_File : THigh_File;
  B : Word;
  I, J : Integer;
Begin
  Assign(High_File, HIGHSCORE_FILE);
  Reset(High_File);
  Place.Name := 'Jack';
  Place.Points := 0;
  GetDate(Place.Year, Place.Month, Place.Day, B);

  Rewrite(High_File);
  For I := 1 to 10 do
    Write(High_File, Place);
  Close(High_File);
  Show_HighScore;
End;




Procedure Draw_Player(X, Y : Integer; Var P : TPlayer);
Var
  I, J : Integer;
Begin
  For J := 1 to PL_Y do
    For I := 1 to PL_X do
      If P.Dir = Right then
        PutPixel(X + I - 7, Y + 1 - J, P.Sprite[P.ActSprite, I,J])
      else
        PutPixel(X - I + 7, Y + 1 - J, P.Sprite[P.ActSprite, I,J])

End;
Procedure Put_Rect(X, Y, R : Integer; Color : Byte);
Var
  I, J : Integer;
Begin
  For I := X - R to X + R do
   For J := Y - R to Y + R do
    PutPixel(I, J, Color);
End;


Procedure Put_Rect2(X, Y, R : Integer; Color : Byte);
Var
  I, J : Integer;
Begin
  For I := X - R + 1 to X + R do
   For J := Y - R to Y + R-1 do
    PutPixel(I, J, Color);
End;

Procedure Enemy_Editor;
Var
  Piece, T : TEnemy;
  Ch     : Char;
  I, J : Integer;
  Col : Byte;
  X, Y : Byte;
  Auswahl : Boolean;
  Select : Byte;
  Pfile : TEnemy_File;
Begin
  Assign(PFile, ENEMY_FILE);
  Reset(PFile);

  Auswahl := true;

  Select := 1;
  Seek(PFile, Select);
  Read(PFile, Piece);
  X := 1;
  Y := 1;
  Col := 0;
  Repeat
    Clear_Screen;
    If Auswahl then Put_Rect((Col mod 64)*4+20, (Col div 64) * 5+5, 2, 15);
    Put_Rect(50, 150, 10, Col);
    Text_Out(30, 170, 15, LZ(IntToStr(Col), 3));
    For I := 0 to 63 do
    Begin
      Put_Rect(I*4+20, 5, 1, I);
      Put_Rect(I*4+20, 10, 1, I+64);
      Put_Rect(I*4+20, 15, 1, I+128);
      Put_Rect(I*4+20, 20, 1, I+192);
    End;

    Put_Rect2(88, 35, 6, 15);
    For I := -4 to 4 do Begin
      Show_Enemy(T, (Select+16+I) mod 16);
      Draw_Piece(84+I*12, 40, T.Sprite);
    End;
    Text_Out(28, 50, 15, '<- Y '+LZ(IntToStr(Select), 3)+' C ->');

    Draw_Piece(50, 100, Piece.Sprite);
    Text_Out(10, 60, 15, '(P)unkte    : '+IntToStr(Piece.Points));
    If not Auswahl then Put_Rect(X*6+100, -Y*6+180, 3, 15);
    For I := 1 to 10 do
     for J := 1 to 10 do
        Put_Rect(I*6+100, -J*6+180, 2, Piece.Sprite[I, J]);
    Draw_Screen;
    CH := ReadKey;
    Case Ord(CH) of
      75 : If Auswahl then Dec(Col) else If X > 1 then Dec(X);
      77 : If Auswahl then Inc(Col) else If X < 10 then Inc(X);
      72 : If Auswahl then Dec(Col, 64) else If Y < 10 then Inc(Y);
      80 : If Auswahl then Inc(Col, 64) else If Y > 1 then Dec(Y);
      ord('c') : Begin
                   Inc(Select);
                   If Select = 16 then Select := 1;
		   Seek(PFile, Select);
	  	   Read(PFile, Piece);
      	         End;
      ord('y') : Begin
                   Dec(Select);
                   If Select = 0 then Select := 15;
		   Seek(PFile, Select);
	  	   Read(PFile, Piece);
      	         End;
      ord('p') : Piece.Points := Get_Number;
      32 : Auswahl := not Auswahl;
      13 : If not Auswahl then Piece.Sprite[X, Y] := Col else
            Auswahl := not Auswahl;
    End;
    Seek(Pfile, Select);
    Write(PFile, Piece);
    FLoad_Enemies;
  Until Ord(Ch) = 27;
  Close(PFile);
End;

Procedure Item_Editor;
Var
  Piece, T : TItem;
  Ch     : Char;
  I, J : Integer;
  Col : Byte;
  X, Y : Byte;
  Auswahl : Boolean;
  Select : Byte;
  Pfile : TAllItem_File;
Begin
  Assign(PFile, ITEM_FILE);
  Reset(PFile);

  Auswahl := true;

  Select := 1;
  Seek(PFile, Select);
  Read(PFile, Piece);
  X := 1;
  Y := 1;
  Col := 0;
  Repeat
    Clear_Screen;
    If Auswahl then Put_Rect((Col mod 64)*4+20, (Col div 64) * 5+5, 2, 15);
    Put_Rect(50, 150, 10, Col);
    Text_Out(30, 170, 15, LZ(IntToStr(Col), 3));
    For I := 0 to 63 do
    Begin
      Put_Rect(I*4+20, 5, 1, I);
      Put_Rect(I*4+20, 10, 1, I+64);
      Put_Rect(I*4+20, 15, 1, I+128);
      Put_Rect(I*4+20, 20, 1, I+192);
    End;

    Put_Rect2(88, 35, 6, 15);
    For I := -4 to 4 do Begin
      Show_Item(T, Select+I);
      Draw_Piece(84+I*12, 40, T.Sprite);
    End;
    Text_Out(28, 50, 15, '<- Y '+LZ(IntToStr(Select), 3)+' C ->');

    Draw_Piece(50, 100, Piece.Sprite);
    Text_Out(10, 60, 15, '(A)ufnehmbar: ');
    If Piece.Collect then Text_Out(122, 60, 15, 'J') else
      Text_Out(122, 60, 15, 'N');
    Text_Out(10, 70, 15, '(B)enutzbar : ');
    If Piece.Use then Text_Out(122, 70, 15, 'J') else
      Text_Out(122, 70, 15, 'N');
    Text_Out(10, 80, 15, '(P)unkte    : '+IntToStr(Piece.Points));
    If not Auswahl then Put_Rect(X*6+100, -Y*6+180, 3, 15);
    For I := 1 to 10 do
     for J := 1 to 10 do
        Put_Rect(I*6+100, -J*6+180, 2, Piece.Sprite[I, J]);
    Draw_Screen;
    CH := ReadKey;
    Case Ord(CH) of
      75 : If Auswahl then Dec(Col) else If X > 1 then Dec(X);
      77 : If Auswahl then Inc(Col) else If X < 10 then Inc(X);
      72 : If Auswahl then Dec(Col, 64) else If Y < 10 then Inc(Y);
      80 : If Auswahl then Inc(Col, 64) else If Y > 1 then Dec(Y);
      ord('c') : Begin
                   Inc(Select);
                   If Select = 0 then Select := 1;
		   Seek(PFile, Select);
	  	   Read(PFile, Piece);
      	         End;
      ord('y') : Begin
                   Dec(Select);
                   If Select = 0 then Select := 255;
		   Seek(PFile, Select);
	  	   Read(PFile, Piece);
      	         End;
      ord('a') : Piece.Collect := not Piece.Collect;
      ord('b') : Piece.Use := not Piece.Use;
      ord('p') : Piece.Points := Get_Number;
      32 : Auswahl := not Auswahl;
      13 : If not Auswahl then Piece.Sprite[X, Y] := Col else
            Auswahl := not Auswahl;
    End;
    Seek(Pfile, Select);
    Write(PFile, Piece);
    FLoad_Items;
  Until Ord(Ch) = 27;
  Close(PFile);
End;

Procedure Sprite_Editor;
Var
  Piece, P : TPiece;
  Ch     : Char;
  I, J : Integer;
  Col : Byte;
  X, Y : Byte;
  Auswahl : Boolean;
  Select : Byte;
  Pfile : TPiece_File;
Begin
  Assign(PFile, PIECE_FILE);
  Reset(PFile);

  Auswahl := true;

  Select := 1;
  Seek(PFile, Select);
  Read(PFile, Piece);
  X := 1;
  Y := 1;
  Col := 0;
  Repeat
    Clear_Screen;
    If Auswahl then Put_Rect((Col mod 64)*4+20, (Col div 64) * 5+5, 2, 15);
    Put_Rect(50, 150, 10, Col);
    Text_Out(30, 170, 15, LZ(IntToStr(Col), 3));
    For I := 0 to 63 do
    Begin
      Put_Rect(I*4+20, 5, 1, I);
      Put_Rect(I*4+20, 10, 1, I+64);
      Put_Rect(I*4+20, 15, 1, I+128);
      Put_Rect(I*4+20, 20, 1, I+192);
    End;

    Put_Rect2(88, 35, 6, 15);
    For I := -4 to 4 do Begin
      Show_Piece(P, Select+I);
      Draw_Piece(84+I*12, 40, P.Sprite);
    End;
    Text_Out(28, 50, 15, '<- Y '+LZ(IntToStr(Select), 3)+' C ->');

    Draw_Piece(50, 100, Piece.Sprite);
    Text_Out(10, 60, 15, '(D)urchgehbar: ');
    If Piece.Walk then Text_Out(150, 60, 15, 'J') else
      Text_Out(150, 60, 15, 'N');
    If not Auswahl then Put_Rect(X*6+100, -Y*6+180, 3, 15);
    For I := 1 to 10 do
     for J := 1 to 10 do
        Put_Rect(I*6+100, -J*6+180, 2, Piece.Sprite[I, J]);
    Draw_Screen;
    CH := ReadKey;
    Case Ord(CH) of
      75 : If Auswahl then Dec(Col) else If X > 1 then Dec(X);
      77 : If Auswahl then Inc(Col) else If X < 10 then Inc(X);
      72 : If Auswahl then Dec(Col, 64) else If Y < 10 then Inc(Y);
      80 : If Auswahl then Inc(Col, 64) else If Y > 1 then Dec(Y);
      ord('c') : Begin
                   Inc(Select);
                   If Select = 0 then Select := 1;
		   Seek(PFile, Select);
	  	   Read(PFile, Piece);
      	         End;
      ord('y') : Begin
                   Dec(Select);
                   If Select = 0 then Select := 255;
		   Seek(PFile, Select);
	  	   Read(PFile, Piece);
      	         End;
      ord('d') : Piece.Walk := not Piece.Walk;
      32 : Auswahl := not Auswahl;
      13 : If not Auswahl then Piece.Sprite[X, Y] := Col else
            Auswahl := not Auswahl;
    End;
    Seek(Pfile, Select);
    Write(PFile, Piece);
    FLoad_Pieces;
  Until Ord(Ch) = 27;
  Close(PFile);
End;

Procedure Player_Editor;
Var
  PlSprite : TPlayer_Sprite;
  Shot	   : TShoot;
  Ch       : Char;
  I, J     : Integer;
  Col      : Byte;
  X, Y     : Byte;
  Auswahl  : Boolean;
  Select   : Byte;
  Player   : TPlayer;
Begin
  Init_Player(Player, Shot);
  Auswahl := true;

  X := 1;
  Y := 1;
  Select := 0;
  Col := 0;
  Repeat
    Clear_Screen;
    If Auswahl then Put_Rect((Col mod 64)*4+20, (Col div 64) * 5+5, 2, 15);
    Put_Rect(50, 150, 10, Col);
    Text_Out(30, 170, 15, LZ(IntToStr(Col), 3));
    For I := 0 to 63 do
    Begin
      Put_Rect(I*4+20, 5, 1, I);
      Put_Rect(I*4+20, 10, 1, I+64);
      Put_Rect(I*4+20, 15, 1, I+128);
      Put_Rect(I*4+20, 20, 1, I+192);
    End;
    Put_Rect(Select * 31 + 20, 69, 13, 15);
    For I := 0 to 2 do
    Begin
      Player.ActSprite := I;
      Draw_Player(I*31 + 20, 80, Player);
    End;
    Text_Out(0, 90, 15, '<- Y | C ->');
    Player.ActSprite := Select;

    If not Auswahl then Put_Rect(X*6+100, -Y*6+180, 3, 15);
    For I := 1 to 12 do
     for J := 1 to 24 do
        Put_Rect(I*6+100, -J*6+180, 2, Player.Sprite[Select, I, J]);
    Draw_Screen;
    CH := ReadKey;
    Case Ord(CH) of
      75 : If Auswahl then Dec(Col) else If X > 1 then Dec(X);
      77 : If Auswahl then Inc(Col) else If X < 12 then Inc(X);
      72 : If Auswahl then Dec(Col, 64) else If Y < 24 then Inc(Y);
      80 : If Auswahl then Inc(Col, 64) else If Y > 1 then Dec(Y);
      ord('c') : Begin Inc(Select); If Select = 3 then Select := 0; end;
      ord('y') : Begin Dec(Select); If Select = 255 then Select := 2; end;
      32 : Auswahl := not Auswahl;
      13 : If not Auswahl then Player.Sprite[Select, X, Y] := Col else
            Auswahl := not Auswahl;
    End;
  Until Ord(Ch) = 27;
  Assign(PlFile, PLAYER_FILE);
  Rewrite(PlFile);
  For I := 0 to 2 do
  Begin
    Write(PlFile, Player.Sprite[I]);
  End;
  Close(PlFile);
End;


Procedure Draw_Piece(X, Y : Integer; Sp : TSprite);
Var
  I, J : Integer;
Begin
  For J := 1 to BLS_Y do
    For I := 1 to BLS_X do
      PutPixel(X + (I-1), Y - J, Sp[I,J]);
End;

Procedure World_Editor;
Var
  ch : Char;
  I, J : Integer;
  X, Y : Word;
  P : TPiece;
  T : TItem;
  Select, SelectT : Byte;
  FileLvl, FileItm, FileEnm : String;
Begin
  X := 20;
  Y := 10;
  Select := 0;
  SelectT := 0;
  Level_Name(FileLvl, FileItm, FileEnm, 1);
  Load_World(FileLvl);
  Load_Items(FileItm);
  Load_Enemy(FileEnm);
  Repeat
    Clear_Screen;
    For I := 1 to 16 do
     For J := 1 to 20 do
       Put_Rect2(I*11+4, J*10-5, 6, 212);

    If X < 8 then Put_Rect2(X * 11+4, Y * 10-5, 6, 15)
     else If X > 312 then Put_Rect2((X - 304) * 11+4, Y * 10-5, 6, 15)
      else Put_Rect2(8 * 11+4, Y * 10-5, 6, 15);
    For I := 1 to 16 do
     For J := 1 to 20 do
     Begin
       If X < 8 then Get_Piece(P, I, J)
        else If X > 312 then Get_Piece(P, 304 + I, J)
         else Get_Piece(P, I + X - 8, J);
       Draw_Piece(I * 11, J * 10, P.Sprite);

       If X < 8 then Get_Item(T, I, J)
        else If X > 312 then Get_Item(T, 304 + I, J)
         else Get_Item(T, I + X - 8, J);
       Draw_Piece(I * 11, J * 10, T.Sprite);
     End;

    Put_Rect2(258, 15, 6, 15);
    For I := -4 to 4 do Begin
      Show_Piece(P, Select+I);
      Draw_Piece(254+I*12, 20, P.Sprite);
    End;
    Text_Out(198, 30, 15, '<- A '+LZ(IntToStr(Select), 3)+' D ->');

    Put_Rect2(258, 45, 6, 15);
    For I := -4 to 4 do Begin
      Show_Item(T, SelectT+I);
      Draw_Piece(254+I*12, 50, T.Sprite);
    End;
    Text_Out(198, 60, 15, '<- Y '+LZ(IntToStr(SelectT), 3)+' C ->');

    Text_Out(220, 80, 15, 'X: '+IntToStr(X));
    Text_Out(220, 90, 15, 'Y: '+IntToStr(Y));

    Draw_Screen;
    Ch := Readkey;
    Case Ord(CH) of
      75 : If X > 1 then Dec(X);
      77 : If X < 320 then Inc(X);
      80 : If Y < 20 then Inc(Y);
      72 : If Y > 1 then Dec(Y);
      Ord('a') : Dec(Select);
      Ord('d') : Inc(Select);
      Ord('y') : Dec(SelectT);
      Ord('c') : Inc(SelectT);
      ord('s') : Set_Piece(Select, X, Y);
      ord('x') : Set_Item(SelectT, X, Y);
    End;
  Until Ord(Ch) = 27;
  Save_World(FileLvl);
  Save_Items(FileItm);
End;


Function LZ(S : String; N : Byte) : String;
Var
  B : Byte;
  T : String;
Begin
  T := S;
  For B := Length(S) to N-1 do
   T := '0' + T;
  LZ := T;
End;

Function LS(S : String; N : Byte) : String;
Var
  B : Byte;
  T : String;
Begin
  T := S;
  For B := Length(S) to N-1 do
   T := ' ' + T;
  LS := T;
End;

Procedure Editors;
Var
  Select, ActSel : Byte;
Begin
  ActSel := 1;
  Select := 1;
  Repeat
    Clear_Screen;
    If ActSel = 1 then Text_out(90, 80, 144, 'Sprite Editor') else
      Text_out(90, 80, 115, 'Sprite Editor');
    If ActSel = 2 then Text_out(90, 100, 144, 'Player Editor') else
      Text_out(90, 100, 115, 'Player Editor');
    If ActSel = 3 then Text_out(90, 120, 144, 'Item Editor') else
      Text_out(90, 120, 115, 'Item Editor');
    If ActSel = 4 then Text_out(90, 140, 144, 'Enemy Editor') else
      Text_out(90, 140, 115, 'Enemy Editor');
    If ActSel = 5 then Text_out(90, 160, 144, 'Hauptmenue') else
      Text_out(90, 160, 115, 'Hauptmenue');
    Draw_Screen;
    Case Ord(ReadKey) of
      72 : Begin Dec(ActSel); If ActSel = 0 then ActSel := 5; End;
      80 : Begin Inc(ActSel); If ActSel = 6 then ActSel := 1; End;
      13 : Case ActSel of
             1 : Sprite_Editor;
	     2 : Player_Editor;
	     3 : Item_Editor;
             4 : Enemy_Editor;
	     5 : Select := 0;
           End;
    End;
  Until Select = 0;
End;
Procedure Draw_Level(P : TPlayer);
Var
  I, J   : Integer;
  Piece    : TPiece;
Begin
  For I := P2X(P) - 16 to P2X(P) + 16 do
    For J := 1 to LVL_Y do
      Draw_Piece(I * 10 - P.Pos.X SHR 16 + 160, J * 10,
                 Pieces^[WorldBuf^[I, J]].Sprite);
End;

Procedure Draw_Items(P : TPlayer);
Var
  I, J   : Integer;
  Item   : TItem;
Begin
  For I := P2X(P) - 16 to P2X(P) + 16 do
    For J := 1 to LVL_Y do
      If ItemBuf^[I, J] <> 0 then
      Draw_Piece(I * 10 - P.Pos.X SHR 16 + 160, J * 10,
                 AllItems^[ItemBuf^[I, J]].Sprite);
End;
Procedure Draw_Enemies(P : TPlayer);
Var
  I : Integer;
Begin
  For I := 1 to 100 do
  Begin
    If (EnemyBuf^[I].X > P.Pos.X SHR 16 - 180) And (EnemyBuf^[I].X < P.Pos.X SHR 16 + 180) then
      Draw_Piece(EnemyBuf^[I].X - P.Pos.X SHR 16 + 160, EnemyBuf^[I].Y,
                 AllEnemy^[EnemyBuf^[I].Kind].Sprite);
  End;
End;

Procedure Draw_World(P : TPlayer; S : TShoot);
Var
  I : Integer;
Begin
  Fill_Screen(212);
  Draw_Level(P);
  Draw_Items(P);
  Draw_Enemies(P);
  Draw_Player(160, P.Pos.Y SHR 16, P);
  If S.Active then
    Draw_Piece(S.Pos.X SHR 16 - P.Pos.X SHR 16 + 160, S.Pos.Y SHR 16, AllItems^[254].Sprite);
  Text_Out(2, 8, 128, 'Punkte: '+IntToStr(P.Score));
  For I := P.Life downto 1 do Draw_Piece(320 - I *12, 10, AllItems^[255].Sprite);
End;

Procedure Move_Shot(Var S : TShoot; P : TPlayer);
Var
  XP : Word;
Begin
  If S.Active then
  Begin
    If S.Dir = Left then
     Dec(S.Pos.X, 5 SHL 16) else
     Inc(S.Pos.X, 5 SHL 16);
     If Abs(S.Pos.X SHR 16 - P.Pos.X SHR 16) > 180 then
        S.Active := False;

    If S.Dir = Right then
      XP := (S.Pos.X SHR 16 + 9) div BLS_X else
      XP := (S.Pos.X SHR 16 + 1) div BLS_X;

    If (not Pieces^[WorldBuf^[XP, (S.Pos.Y SHR 16 + 9) div BLS_Y]].Walk) or
       (not Pieces^[WorldBuf^[XP, (S.Pos.Y SHR 16 + 1) div BLS_Y]].Walk) then
       S.Active := False;
  End;
End;

Procedure Move_Enemies(P : TPlayer);
Var
  I : Integer;
Begin
  For I := 1 to 100 do
    If EnemyBuf^[I].Kind <> 0 then
    If (EnemyBuf^[I].X > P.Pos.X SHR 16 - 240) And
       (EnemyBuf^[I].X < P.Pos.X SHR 16 + 240) then
     with enemyBuf^[I] do
  begin
    If Life <= 0 then Kind := 0;
    Inc(Tag);
    Case Kind of
      1 : Begin
            X := OX;
            Y := OY - Abs(Tag mod 80 - 40);
          End;
      2 : Begin
            X := OX - Abs(Tag mod 160 - 80) + 40;
            Y := OY;
          End;
      3 : Begin
            X := OX;
            Y := OY;
          End;
    End;
  End;
End;



Procedure Init_Player(Var Player : TPlayer; Var Shot : TShoot);
Var
  X, Y : Integer;
  B : Byte;
Begin
  Reset(PlFile);
  With Player do
  Begin
    B := 0;
    While not EOF(PlFile) do
    Begin
      Read(PlFile, Sprite[B]);
      Inc(B);
    End;
    ActSprite := 0;
    Life     := START_LIFE;
    Pos.X    := START_X SHL 16;
    Pos.Y     := START_Y SHL 16;
    Speed.X := 0;
    Speed.Y := 0;
    Dir      := Right;
    Move     := False;
    Action   := Fall;
    Score    := 0;
    Time     := 0;
    Shot.Active := False;
    LevelDone := False;
  End;
  Close(PlFile);
End;


Procedure Check_Items(var P : TPlayer);
Var
  T : TItem;
  I : Byte;
  X, Y : Word;
Begin
  For I:= 1 to 8 do
  Begin
    Case I of
      1 : Begin X := P2XLB(P); Y := P2Y(P); End;
      2 : Begin X := P2XLB(P); Y := P2Y(P)-1; End;
      3 : Begin X := P2XLB(P); Y := P2Y(P)-2; End;
      4 : Begin X := P2XLB(P); Y := P2YU(P); End;
      5 : Begin X := P2XRB(P); Y := P2Y(P); End;
      6 : Begin X := P2XRB(P); Y := P2Y(P)-1; End;
      7 : Begin X := P2XRB(P); Y := P2Y(P)-2; End;
      8 : Begin X := P2XRB(P); Y := P2YU(P); End;
    End;
    If ItemBuf^[X, Y] <> 0 then
    Begin
      T := AllItems^[ItemBuf^[X, Y]];
      If T.Collect then
      Begin
        Inc(P.Score, T.Points);
        If ItemBuf^[X, Y] = 255 then Inc(P.Life);
        ItemBuf^[X, Y] := 0;
      End;
      If T.Use then
      Begin
        If (ItemBuf^[X, Y] = 2) then
	Begin
  	  If Start_Ping_Pong then
   	  Begin
            Inc(P.Life);
            Inc(P.Score, AllItems^[ItemBuf^[X, Y]].Points);
	  End;
          ItemBuf^[X, Y] := ItemBuf^[X, Y] + 1;
        End else
        If ItemBuf^[X, Y] = 253 then
        Begin
          Inc(P.Score, AllItems^[ItemBuf^[X, Y]].Points);
          P.LevelDone := True;
        End;
      End;
    End;
  End;
End;

Function Get_Number : Word;
Var
  S : String;
  N : WorD;
  ch : Char;
  code : Integer;
Begin
  S := '';
  Repeat
    Clear_Screen;
    Text_Out(10, 10, 15, 'Bitte neuen Wert eingeben: ');
    Text_Out(240, 10, 15, S);
    Draw_Screen;
    ch := ReadKey;
    case ch of
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' : s := s + ch;
    end;
  Until ord(ch) = 13;
  Val(S, N, Code);
  Get_Number := N;
End;
Function Get_Name : String;
Var
  S : String;
  ch : Char;
Begin
  S := '';
  Repeat
    Clear_Screen;
    Text_Out(10, 10, 15, 'Bitte Namen eingeben: ');
    Text_Out(200, 10, 15, S);
    Draw_Screen;
    ch := ReadKey;
    case ord(ch) of
      8 : If ord(S[0]) > 0 then S[0] := Chr(Ord(S[0]) - 1);
      13 : S := S;
      27 : S := '-UNNAMED-';
    else
      s := s + ch;
    End;
  Until (ord(ch) = 13) or (ord(ch) = 27);
  Get_Name := S;
End;
Procedure Create_Shoot(P : TPlayer; Var S : TShoot);
Begin
  If not S. Active then
  Begin
    S.Pos.X := P.Pos.X - 5;
    S.Pos.Y := P.Pos.Y - 12;
    S.Active := True;
    S.Dir := P.Dir;
  End;
End;

Procedure Check_Enemy(var P : TPlayer; Var S : TShoot);
Var
  T : TItem;
  I : Byte;
  X, Y : Word;
Begin
  For I := 1 to 100 do
    If EnemyBuf^[I].Kind <> 0 then
    Begin
    If ((EnemyBuf^[I].X > P.Pos.X SHR 16 - 16) And
       (EnemyBuf^[I].X < P.Pos.X SHR 16 + 6) And
       (EnemyBuf^[I].Y > P.Pos.Y SHR 16 - 20) And
       (EnemyBuf^[I].Y < P.Pos.Y SHR 16 + 15)) then
     with enemyBuf^[I] do
     Begin
       If (EnemyBuf^[I].Y < P.Pos.Y SHR 16 + 5) then Dec(P.Life) else
         P.Speed.Y := -10 SHL 16;
       Dec(Life, 20);
       Inc(P.Score, AllEnemy^[EnemyBuf^[I].Kind].Points);
     End;

     If S.Active and
       ((EnemyBuf^[I].X > S.Pos.X SHR 16 - 9) And
       (EnemyBuf^[I].X < S.Pos.X SHR 16 + 9) And
       (EnemyBuf^[I].Y > S.Pos.Y SHR 16 - 9) And
       (EnemyBuf^[I].Y < S.Pos.Y SHR 16 + 9)) Then
     with EnemyBuf^[I] do
     Begin
       Dec(Life, 20);
       S.Active := False;
       Inc(P.Score, AllEnemy^[EnemyBuf^[I].Kind].Points div 2);
     End;
    End;
End;

Procedure Save_World(Name : String);
Var
  I, J : Integer;
  B    : Byte;
  WC   : LongInt;
  W    : TLevel_File;
Begin
  Assign(W, Name);
  Rewrite(W);
  For  J := 1 to 20 do
   For I := 1 to 320 do
   Begin
    B := WorldBuf^[I, J];
    Write(W, B);
  end;
  Close(W);
End;


Procedure Load_World(Name : String);
Var
  I, J : Integer;
  B    : Byte;
  WC   : LongInt;
  W    : TLevel_File;
Begin
  Assign(W, Name);
  Reset(W);
  I := 1;
  J := 1;
  While not EOF(W) do Begin
    Read(W, B);
    WorldBuf^[I, J] := B;
    Inc(I);
    If I > 320 then Begin
      I := 1;
      Inc(J);
    End;
  end;
  Close(W);
End;

Procedure Save_Items(Name : String);
Var
  I, J : Integer;
  B    : Byte;
  WC   : LongInt;
  W    : TItem_File;
Begin
  Assign(W, Name);
  Rewrite(W);
  For  J := 1 to 20 do
   For I := 1 to 320 do
   Begin
    B := ItemBuf^[I, J];
    Write(W, B);
  end;
  Close(W);
End;

Procedure Load_Items(Name : String);
Var
  I, J : Integer;
  B    : Byte;
  WC   : LongInt;
  T    : TItem_File;
Begin
  Assign(T, Name);
  Reset(T);
  I := 1;
  J := 1;
  While not EOF(T) do Begin
    Read(T, B);
    ItemBuf^[I, J] := B;
    Inc(I);
    If I > 320 then Begin
      I := 1;
      Inc(J);
    End;
  end;
  Close(T);
End;

Procedure Load_Enemy(Name : String);
Var
  I, J : Integer;
  B    : TEnemy_Pos;
  T    : TEnemies_File;
Begin
  Assign(T, Name);
  Reset(T);
  I := 1;
  While not EOF(T) do Begin
    Read(T, B);
    EnemyBuf^[I] := B;
    Inc(I);
  end;
  Close(T);
End;

Procedure Show_Enemy(Var P : TEnemy; I : Byte);
Begin
  P := AllEnemy^[I];
End;

Procedure Get_Enemy(Var P : TEnemy; X : Word);
Begin
  P := AllEnemy^[EnemyBuf^[X].Kind];
End;

Procedure Set_Enemy(PNr : TEnemy_Pos; X : Word);
Begin
  EnemyBuf^[X] := PNr;
End;

Procedure Show_Item(Var P : TItem; I : Byte);
Begin
  P := AllItems^[I];
End;

Procedure Get_Item(Var P : TItem; X, Y : Word);
Begin
  P := AllItems^[ItemBuf^[X][Y]];
End;

Procedure Set_Item(PNr : Byte; X, Y : Word);
Begin
  ItemBuf^[X][Y] := PNr;
End;

Procedure Show_Piece(Var P :TPiece; I : Byte);
Begin
  P := Pieces^[I];
End;
Procedure Get_Piece(Var P : TPiece; X, Y : Word);
Begin
  If (Y <= 0) or (Y >= 21) then P := Pieces^[0] else
  P := Pieces^[WorldBuf^[X][Y]];
End;

Procedure Set_Piece(PNr : Byte; X, Y : Word);
Begin
  WorldBuf^[X][Y] := PNr;
End;

Procedure FLoad_Fonts;
Var
  FFonts : File of TFont;
  I : Byte;
  S : TFont;
Begin
  Assign(FFonts, FONTS_FILE);
  Reset(FFonts);
  I := 0;
  While not EOF(FFonts) do
  Begin
    Read(FFonts, S);
    Fonts[I] := S;
    Inc(I);
  End;
  Close(FFonts);
End;


Procedure FLoad_Pieces;
Var
  P : TPiece;
  I : Integer;
  PFile : TPiece_File;
Begin
  Assign(PFile, PIECE_FILE);
  Reset(PFile);
  I := 0;
  While not EOF(PFile) do Begin
    Read(PFile, P);
    Pieces^[I] := P;
    Inc(I);
  end;
  Close(PFile);
End;


Procedure FLoad_Items;
Var
  P : TItem;
  I : Integer;
  PFile : TAllItem_File;
Begin
  Assign(PFile, ITEM_FILE);
  Reset(PFile);
  I := 0;
  While not EOF(PFile) do Begin
    Read(PFile, P);
    AllItems^[I] := P;
    Inc(I);
  end;
  Close(PFile);
End;

Procedure FLoad_Enemies;
Var
  P : TEnemy;
  I : Integer;
  PFile : TEnemy_File;
Begin
  Assign(PFile, ENEMY_FILE);
  Reset(PFile);
  I := 0;
  While not EOF(PFile) do Begin
    Read(PFile, P);
    AllEnemy^[I] := P;
    Inc(I);
  end;
  Close(PFile);
End;

Procedure Init_Util;
Var
  I : Integer;
Begin
  Graph_Init;
  Assign(PlFile, PLAYER_FILE);
  GetMem(Pieces, SizeOf(TPieces));
  GetMem(AllItems, SizeOf(TAllItems));
  GetMem(WorldBuf, SizeOf(TLevel));
  GetMem(ItemBuf, SizeOf(TItems));
  GetMem(AllEnemy, SizeOf(TEnemy_Kind));
  GetMem(EnemyBuf, SizeOf(TEnemies));
  FLoad_Fonts;
  FLoad_Pieces;
  FLoad_Items;
  FLoad_Enemies;
End;

Procedure Exit_Util;
Var
  I : Integer;
Begin
  FreeMem(Pieces, SizeOf(TPieces));
  FreeMem(AllItems, SizeOf(TAllItems));
  FreeMem(WorldBuf, SizeOf(TLevel));
  FreeMem(ItemBuf, SizeOf(TItems));
  FreeMem(AllEnemy, SizeOf(TEnemy_Kind));
  FreeMem(EnemyBuf, SizeOf(TEnemies));
  Graph_Exit;
End;

Procedure Move_Player(Var P : TPlayer; Var S : TShoot; C : LongInt; Var Quit : Boolean);
Var
  Piece1, Piece2, Piece3, Piece4 : TPiece;
  TP    : TPlayer;
  KB_Left, KB_Right, KB_Up, KB_Down : Boolean;
  Shoot : Boolean;
Begin
  KB_Left  := KeyB_Table[75];
  KB_Right := KeyB_Table[77];
  KB_Up    := KeyB_Table[72];
  KB_Down  := KeyB_Table[80];
  Shoot    := KeyB_Table[57];

  If (P.Time mod 5 = 0) and P.Move then Inc(P.ActSprite);
  If P.ActSprite = 3 then P.ActSprite := 0;

  If Shoot then Create_Shoot(P, S);

  If (KB_Left and KB_Right) or
   not (KB_Left or KB_Right) then P.Move := False else
    P.Move := True;

  If P2XLB(P) = P2XRB(P) then
  Begin
    Get_Piece(Piece1, P2X(P), P2YD(P));
    If Piece1.Walk then P.Action := Fall else P.Action := Stand;
  End else
  Begin
    Get_Piece(Piece1, P2XLB(P), P2YD(P));
    Get_Piece(Piece2, P2XRB(P), P2YD(P));
    If Piece1.Walk and Piece2.Walk then P.Action := Fall else P.Action := Stand;
  End;

  If not (P.Action = Fall) and KB_Up then
  Begin
    P.Action := Fall;
    P.Speed.Y := -10 SHL 16;
  End;

  If KB_Left then
  Begin
    P.Dir := Left;
    Get_Piece(Piece1, P2XL(P), P2Y(P));
    Get_Piece(Piece2, P2XL(P), P2Y(P)-1);
    Get_Piece(Piece3, P2XL(P), P2Y(P)-2);
    Get_Piece(Piece4, P2XL(P), P2YU(P));
    If Piece1.Walk and Piece2.Walk and Piece3.Walk and Piece4.Walk then
      P.Speed.X := 2 SHL 16 else P.Speed.X := 0;
  End;
  If KB_Right then
  Begin
    P.Dir := Right;
    Get_Piece(Piece1, P2XR(P), P2Y(P));
    Get_Piece(Piece2, P2XR(P), P2Y(P)-1);
    Get_Piece(Piece3, P2XR(P), P2Y(P)-2);
    Get_Piece(Piece4, P2XR(P), P2YU(P));
    If Piece1.Walk and Piece2.Walk and Piece3.Walk and Piece4.Walk then
      P.Speed.X := 2 SHL 16 else P.Speed.X := 0;
  End;
  If P.Action = Fall then
  Begin
    Inc(P.Speed.Y, Gravity);
    If P2XRB(P) = P2XLB(P) then
    Begin
        Get_Piece(Piece1, P2X(P), P2YU(P));
      If not Piece1.Walk then
      Begin
        P.Speed.Y := Abs(P.Speed.Y);
      End;
    End else
    Begin
      Get_Piece(Piece1, P2XLB(P), P2YU(P));
      Get_Piece(Piece2, P2XRB(P), P2YU(P));
      If not Piece1.Walk or not Piece2.Walk then
      Begin
        P.Speed.Y := Abs(P.Speed.Y);
      End;
    End;
  End else
    P.Speed.Y := 0;

  Quit := KeyB_Table[1];

  If P.Dir = Left then P.Speed.X := -P.Speed.X;
  If P.Move then P.Pos.X := P.Pos.X + P.Speed.X;

  P.Pos.Y := P.Pos.Y + P.Speed.Y;
  If P.Action = Fall then
  If P2XRB(P) = P2XLB(P) then
  Begin
    Get_Piece(Piece1, P2X(P), P2Y(P));
    If not Piece1.Walk then
    Begin
      P.Pos.Y := P.Pos.Y - P.Speed.Y;
      P.Pos.Y := (P2Y(P) * 10 - 1) SHL 16;
    End;
  End else
  Begin
    Get_Piece(Piece1, P2XLB(P), P2Y(P));
    Get_Piece(Piece2, P2XRB(P), P2Y(P));
    If not Piece1.Walk or not Piece2.Walk then
    Begin
      P.Pos.Y := P.Pos.Y - P.Speed.Y;
      P.Pos.Y := (P2Y(P) * 10 - 1) SHL 16;
    End;
  End;
  If P2Y(P) > 23 then Dec(P.Life);
End;

End.
