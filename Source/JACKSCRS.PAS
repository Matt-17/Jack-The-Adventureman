Unit JackScrs;

Interface

Procedure Show_Credits;
Procedure Show_Options;
Procedure Show_Help;
Procedure Show_HighScore;
Procedure Show_Welcome_Screen;
Procedure Show_Exit_Screen;
Function Menu : Byte;
Procedure Play_Game;



Implementation

Uses
  Dos, Crt, JackUtil, JackGrph, JackTCV;

Procedure Show_Credits;
Const
  T : Array[0..10]  of String =
    ('Dieses Spiel wurde',
     'programmiert von',
     'Matthias Voigt',
     '',
     '(C)opyright 2003',
     '',
     'Informatik 13/II',
     'Saengerstadt-Gymnasium',
     'Fachleher Bernd Schmidt',
     '',
     '');

var B,  I, J : Word;
    C : LongInt;
Begin
  Clear_Screen;
  Draw_Screen;
  Set_PaletteBW;
  C := 220;
  Repeat
  Repeat
    Dec(C,2);
    Clear_Screen;
    For I:= 0 to 10 do
      Text_Out(160 - (Length(T[I])*8) div 2, I*10+C,255, T[I]);
    For J:=0 to 199 do
     For I:= 0 to 319 do
     Begin
       B := GetPixel(I, J);
       If B = 255 then
       PutPixel(I, J, B - (255-(j*256)div 199));
     End;
    Draw_Screen;
    Delay(30);
  Until Keypressed;
  Until Ord(ReadKey)<>0;
  Set_Palette;
End;



Procedure Show_Options;
Begin
  Clear_Screen;
  Text_Out(0, 40, 15, 'Leider kann man nichts aendern');
  Text_Out(0, 90, 15, 'Taste druecken um zum Menue zu kommen');
  Draw_Screen;
  ReadKey;
End;


Procedure Show_Help;
Begin
  Clear_Screen;
  Text_Out(0, 40, 15, 'Jack wird mit den Pfeiltasten gesteuert');
  Text_Out(0, 50, 15, 'Mit Leertaste kann man schiessen');
  Text_Out(0, 60, 15, 'Aber Vorsicht! Das gibt weniger Punkte');
  Text_Out(0, 70, 15, 'Viel Spass beim spielen!');
  Text_Out(0, 90, 15, 'Taste druecken um zum Menue zu kommen');
  Draw_Screen;
  ReadKey;
End;


Procedure Show_HighScore;
Var
  Place : TPlace;
  High_File : THigh_File;
  I : Integer;
Begin
  Assign(High_File, HIGHSCORE_FILE);
  Reset(High_File);
  I := 1;
  Clear_Screen;
    Text_Out(10, 30, 145,
             'Nr.          Name   Punkte      Datum');
    Text_Out(10, 40, 145,
             '=====================================');
  While not EOF(High_File) do
  Begin
    Read(High_File, Place);
    Text_Out(10, I * 10 + 40, 145,
             LZ(IntToStr(I), 2)+' '+LS(Place.Name, 14)+' '+
             LZ(IntToStr(Place.Points), 8)+' '+
	     LZ(IntToStr(Place.Day),2)+'.'+LZ(IntToStr(Place.Month),2)+'.'+
	     LZ(IntToStr(Place.Year),2));
    Inc(I);
    Text_Out(10, 160, 140, 'Zum loeschen ''L'' druecken');
    Draw_Screen;
  End;
  Close(High_File);
  If ReadKey = 'l' then Del_Highscore;
End;


Procedure Show_Welcome_Screen;
Var
  I : Integer;
Begin
  I := 96;
  Repeat
    Clear_Screen;
    Text_Out(20, 40, I-32, 'Willkommen bei');
    Text_Out(40, 80, I, '''Jack The Adventureman''');
    Text_Out(30, 150, I div 112 * 15, 'created by Matthias Voigt');
    Draw_Screen;
    Delay(50);
    If I < 116 then Inc(I);
  Until Keypressed;
  ReadKey;
End;

Procedure Show_Exit_Screen;
Var
  I : Integer;
  Darken : Boolean;
Begin
  I := 110;
  Darken := True;
  Repeat
    Clear_Screen;
    if Darken then Dec(I) else Inc(I);
    If (I = 100) or (I = 120) then Darken := not Darken;
    Text_Out(30, 90, I, 'Viel Spass beim naechsten Mal');
    Draw_Screen;
    Delay(50);
  Until KeyPressed;
  ReadKey;
End;

Function Menu : Byte;
Var
  Select, I, J : Byte;
  Done : Boolean;
  ActSel : String;
  ActCnt : Byte;
  SelCol : Byte;
  Col : Byte;
Const
  AllSel : Array[1..9] of String =
          ('Spiel Starten',
           'Highscore-Liste zeigen',
           'Optionen',
           'Hilfe anzeigen',
           'Ping Pong Clone Spielen',
           'Paintbrush',
           'Welt-Editor',
           'Credits zeigen',
           'Spiel Beenden');
Begin
  Select := 1;
  ActCnt := 0;
  Col := 105;
  Done := False;
  Repeat
    Inc(ActCnt);
    Fill_Screen(abs((ActCnt div 8) mod 32 - 16)+234);
    If Keypressed then
    Case Ord(Readkey) of
      72 : Begin Dec(Select); If Select = 0 then Select := 9; end;
      80 : Begin Inc(Select); If Select = 10 then Select := 1; end;
      13 : Done := True;
    End;
    For I := 1 to 9 do
    Begin
      ActSel := AllSel[I];
      SelCol := col;
      For J := 1 to Length(ActSel) do
      Begin
        SelCol := abs(((ActCnt + J + I*I) mod 32) - 16) + 110;
        If I = Select then Inc(SelCol, 32);
        Text_Out(160-(Length(ActSel)*8) div 2 + 8 * (J-1)-8, I * 14 + 50, SelCol, ActSel[J]);
      End;
    End;
    Draw_Screen;
    Delay(30);
  Until Done;

  Menu := Select;
End;


Procedure Play_Game;
Var
  Player             : TPlayer;
  Shot		     : TShoot;
  Piece		     : TPiece;
  Count              : LongInt;
  Stop_Game          : Boolean;
  OldBKHandler       : Pointer;
  ActLevel : Byte;
  FileLvl, FileItm, FileEnm   : String;
  AllUp 	     : Boolean;
  I : Byte;
  Name : String;
Begin
  Init_Player(Player, Shot);
  ActLevel := 1;
  Level_Name(FileLvl, FileItm, FileEnm, ActLevel);
  Load_World(FileLvl);
  Load_Items(FileItm);
  Load_Enemy(FileEnm);

  GetIntVec(9, OldBKHandler);
  SetIntVec(9, @Check_KeyB);

  Stop_Game := False;
  Count := 0;
  Repeat
    Inc(Count);
    Inc(Player.Time);
    Move_Player(Player, Shot, Count, Stop_Game);
    Move_Enemies(Player);

    Move_Shot(Shot, Player);

    Check_Items(Player);
    Check_Enemy(Player, Shot);


    Draw_World(Player, Shot);

    Draw_Screen;
    Delay(10);
    If (Player.LevelDone) and (ActLevel = 1) then Stop_Game := True;
  Until Stop_Game or (Player.Life <= 0);
  Repeat
    AllUp := True;
    For I := 1 to 128 do If KeyB_Table[I] then AllUp := False;
  Until AllUp = True;
  SetIntVec(9, OldBkHandler);

  Clear_Screen;
  Text_Out(10, 100, 15, 'Du hast '+IntToStr(Player.Score)+' Punkte erreicht!');
  Draw_Screen;
  ReadKEy;

  Name := Get_Name;
  Add_To_HighScore(Name, Player.Score);
End;


End.