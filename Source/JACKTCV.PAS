Unit JackTCV;

Interface

Const
  PL_X = 12;
  PL_Y = 24;

  BLS_X = 10;   { Breite der Blocks }
  BLS_Y = 10;

  SCR_X = 10;   { Anzahl der Bildschirme }
  SCR_Y = 1;

  BL_X = 32;    { Anzahl der Blocks pro Bildschirm }
  BL_Y = 20;

  LVL_X = BL_X * SCR_X;  { Anzahl der Blocks im Level }
  LVL_Y = BL_Y * SCR_Y;

  PX_X = BLS_X * LVL_X;  { Breite des Levels in Pixel }
  PX_Y = BLS_Y * LVL_Y;

  START_LIFE = 3;
  START_X    = 190;
  START_Y    = 90;

  GRAVITY    = 10 SHL 16 div 10;

  FONTS_FILE = 'Fonts.dat';
  PIECE_FILE = 'Pieces.dat';
  ITEM_FILE  = 'Items.dat';
  ENEMY_FILE = 'Enemies.dat';
  PLAYER_FILE = 'Player.dat';
  HIGHSCORE_FILE = 'HiScore.dat';


Type
  TPoint = Record
             X, Y : LongInt;
           End;
  TSpeed = Record
             X, Y : LongInt;
           End;
  TDir	= (Left, Right);

  TPlayer_Sprite      = Array[1..PL_X, 1..PL_Y] of Byte;
  TPlayer_Sprite_File = File of TPlayer_Sprite;
  TPlayer = Record
    Sprite   : Array[0..2] of TPlayer_Sprite;
    ActSprite : Byte;
    Life     : Byte;
    Pos      : TPoint;
    Speed    : TSpeed;
    Dir      : TDir;
    Move     : Boolean;
    Action   : (Walk, Stand, Duck, Fall);
    Score    : LongInt;
    Time     : LongInt;
    JTime    : LongInt;
    LevelDone : Boolean;
  End;

  TShoot = Record
             Pos : TPoint;
             Dir : TDir;
             Active : Boolean;
           End;

  TPlace  = Record
  	      Day, Month, Year : Word;
              Name : String[14];
              Points : LongInt;
            End;
  THighScore = Array[1..10] of TPlace;
  THigh_File = File of TPlace;


  TSprite       = Array[1..BLS_X, 1..BLS_Y] of Byte;
  TPiece        = Record
                    Sprite : TSprite;
                    Walk   : Boolean;
                    Death  : Boolean;
                  End;

  TPieces       = Array[0..255] of TPiece;
  TPiece_File   = File of TPiece;
  PPieces       = ^TPieces;

  TItem         = Record
  		    Sprite  : TSprite;
                    Collect : Boolean;
                    Use	    : Boolean;
                    Points  : Integer;
                    Visible : Boolean;
                  End;
  TAllItems     = Array[0..255] of TItem;
  TAllItem_File = File of TItem;
  PAllItems      = ^TAllItems;


  TLevel        = Array[1..LVL_X, 1..LVL_Y] of Byte;

  TItems        = Array[1..LVL_X, 1..LVL_Y] of Byte;
  TItem_File    = File of Byte;
  PItems        = ^TItems;

  TEnemy	= Record
                    Sprite : TSprite;
		    Points : Word;
  		  End;
  TEnemy_Pos    = Record
    		    X, Y : Word;
  		    Kind : Byte;
  		    OX, OY : Integer;
                    Tag  : LongInt;
		    Life : ShortInt;
                  end;
  TEnemy_Kind   = Array[0..15] of TEnemy;
  TEnemy_File	= File of TEnemy;
  PEnemy_Kind   = ^TEnemy_Kind;
  TEnemies      = Array[1..100] of TEnemy_Pos;
  TEnemies_File = File of TEnemy_Pos;
  PEnemies      = ^TEnemies;

  TLevel_File   = File of Byte;
  PLevel        = ^TLevel;

  TScreenBuf	= Array[0..319, 0..199] of Byte;

Procedure Level_Name(var Lvl, Itm, Enm : String; I : Byte);

Implementation

Uses
  JackUtil;

Procedure Level_Name(var Lvl, Itm, Enm : String; I : Byte);
Begin
  Lvl := 'Level' + IntToStr(I) + '.lvl';
  Itm := 'Level' + IntToStr(I) + '.itm';
  Enm := 'Level' + IntToStr(I) + '.enm';
end;


End.