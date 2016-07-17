Program JumpinJack;

Uses
  Dos, Crt, JackUtil, JackTCV, JackGrph, JackPing, JackScrs;

Procedure Main_Proc;
Var
  Exit_Game : Boolean;
Begin
  Init_Util;
  Graphic_Mode(19);
  Set_Palette;

  Exit_Game := False;

  Show_Welcome_Screen;
  Repeat
    Case Menu of
      1 : Play_Game;
      2 : Show_HighScore;
      3 : Show_Options;
      4 : Show_Help;
      5 : Start_Ping_Pong;
      6 : Editors;
      7 : World_Editor;
      8 : Show_Credits;
      9 : Exit_Game := True;
    End;
  Until Exit_Game;

  Show_Exit_Screen;

  Graphic_Mode(3);
  Exit_Util;
End;

Begin
  Randomize;
  Main_Proc;
End.