{*******************************************************************************
*           Monorail Hanger Traverse Movement 

* Company : Software Automation Concepts d.o.o.
* Author  : N.Zupcic 
* Date    : May, 2020.
* Version : 0.1                                                                     
********************************************************************************
* FG Name represents first 6 characters of the Function Group Name of Hangers
* FG_START is the number of the first FG of Hangers
*
* Visual elements that represent Hangers need to be:
*    1.) Named hanger1 ... hangern (n = 2,3,...) 
*    2.) In Event On Form Create called with function CreateHanger() 
*        (e.g. Create(hanger1);)
*    
* Visual elements that represent EMS system need to be:
*    1.) Named monorail1 ... monorailn (n = 1,2,3,...) in the correct order 
*        occording to path direction
*    2.) Tag Property of monorail element needs to have a number that 
*        describes direction (1-left, 2-right, 3-up, 4-down) 
*    3.) In Event On Form Create called with function SetupMonorail() 
*        (e.g. SetupMonorail(monorail1);) 
}

//Constants
const
    FG_NAME    = '302EHV';  //Hanger Function Group Name
    FG_START   = 301;       //Hanger Function Group Start Number
    NUM_OF_FG  = 13;        //Number of Hanger Function Groups 
    NUM_OF_MON = 6;         //Number of Monorail Elements
    NUM_OF_POS = 203200;    //Number of Bar Code Positions 
    RESOLUTION = 100000;
    
    REAL_PATH = 203200;     //Real monorail path in [mm]     
    
    //Hanger Template Name
    HANGER_NAME = 'HangerTemplate'; 
    
    //Directions
    LEFT_D  = 1;
    RIGHT_D = 2;
    UP_D    = 3;
    DOWN_D  = 4;
    
    //Roller Template Name
    HOR_R   = 'S_FT_OV_Foerderer_Horiz';
    HOR_REL = 'S_FT_OV_Foerderer_Horiz_End1';
    HOR_RER = 'S_FT_OV_Foerderer_Horiz_End2';
    VER_R   = 'S_FT_OV_Foerderer_Vert';
    VER_RET = 'S_FT_OV_Foerderer_Vert_End2';
    VER_REB = 'S_FT_OV_Foerderer_Vert_End1';
    
    //Monorail Template Names  
    HOR_L = 'S_EHB_OV_Strecke_Horizontal_L';
    HOR_M = 'S_EHB_OV_Strecke_Horizontal_M';
    HOR_K = 'S_EHB_OV_Strecke_Horizontal_K';
    VER_L = 'S_EHB_OV_Strecke_Vertikal_L';
    VER_M = 'S_EHB_OV_Strecke_Vertikal_M';
    VER_K = 'S_EHB_OV_Strecke_Vertikal_K';
    CUR_1 = 'S_EHB_OV_Kurve_1';
    CUR_2 = 'S_EHB_OV_Kurve_2';
    CUR_3 = 'S_EHB_OV_Kurve_3';
    CUR_4 = 'S_EHB_OV_Kurve_4';

    //Template Identifier
    I_HOR_L   = 1;
    I_HOR_M   = 2;
    I_HOR_K   = 3;
    I_VER_L   = 4;
    I_VER_M   = 5;
    I_VER_K   = 6;
    I_CUR_1   = 7;
    I_CUR_2   = 8;
    I_CUR_3   = 9;
    I_CUR_4   = 10;
    I_HOR_R   = 11;
    I_HOR_REL = 12;
    I_HOR_RER = 13;
    I_VER_R   = 14;
    I_VER_RET = 15;
    I_VER_REB = 16;

//Variables
var
    scaledPosition      : single = 1;
    scaledPath          : single = 1;
    
    tlHanger            : array[1..NUM_OF_FG] of TIsi_TagItemList;          //Hanger Tag Item Lists Array
    tiHanger            : array[1..NUM_OF_FG] of TIsi_TagItem;              //Hanger Tag Items Array
    fg_names            : array[1..NUM_OF_FG] of string;                    //Function Group Names Array
    S7DeviceLabel       : array[1..NUM_OF_FG] of TIsi_S7DeviceLabel;        //S7 Device Labels Array
    
    tcMonorail          : array[1..NUM_OF_MON] of TIsi_ImgTmplContainer;    //Monorail Elements     
    monorailIdentifier  : array[1..NUM_OF_MON] of UInt16;                   //Monorail Type Identifier
    monorailPath        : array[1..NUM_OF_MON] of UInt16;                   //Individaual Element Path
    totalPath           : UInt32 = 0;                                       //Total Monorail Path
    i_monorail          : UInt8 = 1;                                        //Interation of Monorail 
    
    rtHanger            : array[1..NUM_OF_FG] of TIsi_TmplContainer;        //Hangers Visual Representation
    i_hanger            : UInt8 = 1;                                        //Iteration of Hanger  

//Event : Form On Create
procedure isi_FormCreate(Sender: TObject);
begin
    NameHangerFGs();    
    SetupTagItemLists();
    SetupEvents(); 
    
    //Create Monorail Objects
    SetupMonorail(monorail1);
    SetupMonorail(monorail2);
    SetupMonorail(monorail3);
    SetupMonorail(monorail4); 
    SetupMonorail(monorail5);    
    SetupMonorail(monorail6); 
    CalculateMonorailPaths();
    
    //Create Hanger Objects
    CreateHanger(hanger1); 
    CreateHanger(hanger2);
    CreateHanger(hanger3);
    CreateHanger(hanger4);
    CreateHanger(hanger5);
    CreateHanger(hanger6); 
    CreateHanger(hanger7);
    CreateHanger(hanger8);
    CreateHanger(hanger9);
    CreateHanger(hanger10);
    CreateHanger(hanger11);
    CreateHanger(hanger12);
    CreateHanger(hanger13);
    SetupHangers();           
end;

//Create an Integer identifier to replace a String
function GetMonorailIdentifier(s : string) : integer;
begin
    if(s = HOR_L) then
    begin          
        Result := I_HOR_L;
    end;
    if(s = HOR_M) then
    begin   
        Result := I_HOR_M;
    end;
    if(s = HOR_K) then
    begin    
        Result := I_HOR_K;
    end;
    if(s = VER_L) then
    begin   
        Result := I_VER_L;
    end; 
    if(s = VER_M) then
    begin   
        Result := I_VER_M;
    end; 
    if(s = VER_K) then
    begin    
        Result := I_VER_K;
    end; 
    if(s = CUR_1) then
    begin    
        Result := I_CUR_1;
    end; 
    if(s = CUR_2) then
    begin    
        Result := I_CUR_2;
    end; 
    if(s = CUR_3) then
    begin   
        Result := I_CUR_3;
    end; 
    if(s = CUR_4) then
    begin     
        Result := I_CUR_4;
    end;
    if(s = HOR_R) then
    begin    
        Result := I_HOR_R;
    end; 
    if(s = HOR_REL) then
    begin    
        Result := I_HOR_REL;
    end; 
    if(s = HOR_RER) then
    begin     
        Result := I_HOR_RER;
    end; 
    if(s = VER_R) then
    begin    
        Result := I_VER_R;
    end;
    if(s = VER_RET) then
    begin   
        Result := I_VER_RET;
    end;
    if(s = VER_REB) then
    begin   
        Result := I_VER_REB;
    end;   
end;

//Setup Monorail
procedure SetupMonorail(monorailObject : TIsi_ImgTmplContainer);
begin
    tcMonorail[i_monorail] := TIsi_ImgTmplContainer.Create(self);
    tcMonorail[i_monorail] := monorailObject; 
    monorailIdentifier[i_monorail] := GetMonorailIdentifier(tcMonorail[i_monorail].TemplateName);
    inc(i_monorail);
end;

//Create Hanger
procedure CreateHanger(hangerObject : TIsi_TmplContainer);
begin
    rtHanger[i_hanger] := TIsi_TmplContainer.Create(self); 
    rtHanger[i_hanger] := hangerObject;
    rtHanger[i_hanger].Visible := FALSE;
    inc(i_hanger);     
end;

//Setup Hanger
procedure SetupHangers();
var
    i : UInt8;
begin
    for i := 1 to NUM_OF_FG do
    begin 
        rtHanger[i].AutoSize := FALSE;
        rtHanger[i].Width    := 70;
        rtHanger[i].Height   := 36;
        rtHanger[i].Visible  := TRUE;
    end;
end;

//Name Hanger FG's
procedure NameHangerFGs();
var
    i, j : UInt8;
begin
    //Function gruop name / e.g. '302EHV301'
    j := 1;
    for i := FG_START to (FG_START + NUM_OF_FG) do
    begin  
        fg_names[j] := Format('%s%d@AddOn', [FG_NAME, i]);
        inc(j);
    end;
    
end;

//Setup Tag Item Lists
procedure SetupTagItemLists();
var
    i : UInt8;
begin
    //Setup TagItemLists
    for i := 1 to NUM_OF_FG do
    begin
        //Setup S7DeviceLabels
        S7DeviceLabel[i]:= TIsi_S7DeviceLabel.Create(self);
        Main.InsertComponent(S7DeviceLabel[i]);
        S7DeviceLabel[i].FgName := fg_names[i];   
        
        //Activate Tag Item Lists
        tlHanger[i] := CreateTagItemListForLibrary(DEFAULTCONNECTION, self);
        if Assigned(tlHanger[i]) then
        begin
            SetupTagItems(tlHanger[i], 1);
            ActivateTagItemList (tlHanger[i], DEFAULTCONNECTION, DEFAULTPLANT, fg_names[i], false);
        end;
    end;
end;

//Setup Events
procedure SetupEvents();
var
    i : integer;
begin 
    for i := 1 to NUM_OF_FG do
    begin
        tiHanger[i].OnValueChange := isi_OnValueChange;
    end;    
end;

//Setup Tag Items
procedure SetupTagItems(tagItemList_h : TIsi_TagItemList; indexFg : integer);
var
    i : UInt8;
begin
    for i:=1 to NUM_OF_FG do
    begin
        tiHanger[i] := Tisi_TagItem.Create(self);
        tiHanger[i].CheckTagAccessLevel := false;
        tiHanger[i].TagItemList := tagItemList_h;
        tiHanger[i].TagName := '"FGDB_' + fg_names[i] + '".AddT.position';
        tiHanger[i].TagNameType := ttSymbol; 
    end;
end;

//Event : On Tag Item Value Changed      
procedure isi_OnValueChange(Sender : TObject; AValue : Variant; AValueValid : Boolean);
var
    position_t : integer;
    i          : UInt8;
begin
    try
    for i := 1 to NUM_OF_FG do
    begin
        position_t := Round(((tiHanger[i].Value) / REAL_PATH) * monorailPath[NUM_OF_MON]);
        try          
        except on E:Exception do ShowMessage(E.Message);
        end;
        if position_t >= monorailPath[NUM_OF_MON] then
        begin
            rtHanger[i].Visible := FALSE;
        end
        else if position_T <= 0 then
        begin
            rtHanger[i].Visible := FALSE;
        end
        else
        begin
            rtHanger[i].Visible := TRUE;
            MoveHanger(i, position_t); 
        end; 
    end;    
    
    except on E:exception do ShowMessage(E.Message + ' Tag on value change event failed!');   
    end;
end;

{*******************************************************************************
*       Movement of Elements
*******************************************************************************}
//Calculate Monorail Paths
procedure CalculateMonorailPaths();
var
    i         : UInt8;
    tempName  : UInt8;
begin
    for i := 1 to NUM_OF_MON do
    begin
        tempName  := monorailIdentifier[i];
        if ((tempName = I_HOR_R) OR (tempName = I_HOR_REL) OR (tempName = I_HOR_RER) OR (tempName = I_HOR_L) OR (tempName = I_HOR_M) OR (tempName = I_HOR_K)) then
        begin       
            monorailPath[i] := totalPath + tcMonorail[i].Width;  
            totalPath := totalPath + tcMonorail[i].Width;  
        end
        else if ((tempName = I_VER_R) OR (tempName = I_VER_RET) OR (tempName = I_VER_REB) OR (tempName = I_VER_L) OR (tempName = I_VER_M) OR (tempName = I_VER_K)) then
        begin
            monorailPath[i] := totalPath + tcMonorail[i].Height;
            totalPath := totalPath + tcMonorail[i].Height; 
        end
        else if ((tempName = I_CUR_1) OR (tempName = I_CUR_2) OR (tempName = I_CUR_3) OR (tempName = I_CUR_4)) then
        begin
            monorailPath[i] := totalPath + Round((tcMonorail[i].Width - (0.125 * tcMonorail[i].Width)) * 2);
            totalPath := 1 + totalPath + (Round((tcMonorail[i].Width - (0.125 * tcMonorail[i].Width)) * 2)); 
        end;    
    end;    
end;

//Hanger Movement
procedure MoveHanger(i_move : integer; position : integer);
var
    tempName          : UInt8;
    halfPath          : UInt32;
    currentMonorail   : UInt8;
    movementDirection : UInt8;
    hangerTop         : UInt16;
    hangerLeft        : UInt16;
    hangerWidth       : UInt16;
    hangerHeight      : UInt16;
    monorailTop       : UInt16;
    monorailLeft      : UInt16;
    monorailWidth     : UInt16;
    monorailHeight    : UInt16;
    curMonorailPath   : UInt32;
begin
    //Find Monorail Number On Which The Hanger Is Located
    currentMonorail := FindCurrentMonorail(i_move, position); 
    //Current Monorail Direction
    movementDirection := tcMonorail[currentMonorail].Tag; 
    //Template Name of Current Monorail
    tempName := monorailIdentifier[currentMonorail];    
    //store to local data
    hangerTop       := rtHanger[i_move].Top;
    hangerLeft      := rtHanger[i_move].Left;
    hangerWidth     := rtHanger[i_move].Width;
    hangerHeight    := rtHanger[i_move].Height;
    monorailTop     := tcMonorail[currentMonorail].Top;
    monorailLeft    := tcMonorail[currentMonorail].Left;
    monorailWidth   := tcMonorail[currentMonorail].Width;
    monorailHeight  := tcMonorail[currentMonorail].Height;
    curMonorailPath := monorailPath[currentMonorail];
    //Test Current Monorail Type 
    //Monorail type is a Curve
    if (tempName = I_CUR_1) then
    begin
        //Half Path of Current Monorail
        halfPath := Round(monorailWidth - (0.125 * monorailWidth));
        //Test Current Monorail Direction
        if (movementDirection = LEFT_D) then
        begin 
            //Last Half of Path
            if ((position <= monorailPath[currentMonorail]) AND (position >= (curMonorailPath - halfPath + 10))) then
            begin
                // X coordinate fixed, Y coordinate changes with position from DB
                hangerTop := monorailTop + Round(0.125 * monorailWidth) - Round(hangerHeight / 2);
                hangerLeft := monorailLeft + Abs(position - curMonorailPath + halfPath);
            end
            //First Half of Path
            else if (position < (monorailPath[currentMonorail] - halfpath - 10)) then  
            begin
                // Y coordinate fixed, X coordinate changes with position from DB
                hangerTop := monorailTop;
                hangerLeft := monorailLeft + Round(0.875 * monorailWidth) - Round(hangerWidth / 2);                     
            end
            //Center of Path
            else
            begin
                hangerTop := monorailTop + Round(0.125 * monorailWidth) - Round(hangerHeight / 2) + 8;
                hangerLeft := monorailLeft; 
            end;
        end
        else if (movementDirection = DOWN_D) then
        begin 
            if ((position <= curMonorailPath) AND (position >= (curMonorailPath - halfPath + 10))) then
            begin
                hangerTop := position;
                hangerLeft := monorailLeft + Round(0.875 * monorailWidth) - Round(hangerWidth / 2);
            end
            else if (position < (curMonorailPath - halfpath - 10)) then
            begin
                hangerTop := monorailTop + Round(0.125 * monorailWidth) - Round(hangerHeight / 2);
                hangerLeft := monorailLeft;
            end
            else
            begin
                hangerTop := monorailTop + Round(0.125 * monorailWidth) - Round(hangerHeight / 2) + 8;
                hangerLeft := monorailLeft; 
            end;
        end;
    end
    else if (tempName = I_CUR_2) then
    begin
        halfPath := Round(monorailWidth - (0.125 * monorailWidth));
        if (movementDirection = LEFT_D) then
        begin
            if ((position <= curMonorailPath) AND (position >= (curMonorailPath - halfPath + 10))) then
            begin
                hangerTop := monorailTop + Round(0.875 * monorailHeight) - Round(hangerHeight / 2);
                hangerLeft := monorailLeft + Abs(position - curMonorailPath + halfPath);
            end 
            else if (position < (curMonorailPath - halfpath - 10)) then
            begin
                hangerTop := monorailTop;
                hangerLeft := monorailLeft + Round(0.875 * monorailWidth) - Round(hangerWidth / 2);
            end
            else 
            begin  
                hangerTop := monorailTop + halfPath - Round(hangerHeight / 2) - 8;
                hangerLeft := monorailLeft + Round(0.875 * monorailWidth) - hangerWidth + 8;                 
            end; 
        end
        else if (movementDirection = UP_D) then
        begin
            if ((position <= curMonorailPath) AND (position >= (curMonorailPath - halfPath + 10))) then
            begin
                hangerTop := monorailTop;
                hangerLeft := tcMonorail[currentMonorail].Left + Round(0.875 * monorailWidth) - Round(hangerWidth / 2);
            end
            else if (position < (curMonorailPath - halfpath - 10)) then
            begin
                hangerTop := monorailTop + Round(0.875 * monorailHeight) - hangerHeight / 2);
                hangerLeft := monorailLeft;
            end
            else
            begin 
                hangerTop := monorailTop + halfPath - Round(hangerHeight / 2) - 8;
                hangerLeft := monorailLeft + Round(0.875 * monorailWidth) - hangerWidth + 8;  
            end;
        end;
    end 
    else if (tempName = I_CUR_3) then
    begin 
        halfPath := Round(monorailWidth - (0.125 * monorailWidth)); 
        if (movementDirection = RIGHT_D) then
        begin
            if ((position <= curMonorailPath) AND (position >= (curMonorailPath - (halfPath + 10)))) then
            begin
                hangerTop := monorailTop + Round(0.125 * monorailHeight) - Round(hangerHeight / 2) + 1;
                hangerLeft := monorailLeft - (curMonorailPath - halfPath - position) + Round(hangerWidth / 4) - 10;
            end
            else if (position < (curMonorailPath - halfpath - 25)) then 
            begin
                hangerTop := monorailTop + Abs(position - curMonorailPath + halfPath) - hangerHeight + 10;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2) - 1;                  
            end
            else
            begin
                hangerTop := monorailTop + Round(0.125 * monorailWidth) - Round(hangerHeight / 2) + 8;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2);
            end;
        end
        else if (movementDirection = DOWN_D) then
        begin
            if ((position <= curMonorailPath) AND (position >= (curMonorailPath - halfPath + 10))) then
            begin  
                hangerTop := monorailTop + Abs(position - curMonorailPath + halfPath);
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2); 
            end
            else if (position < (curMonorailPath - halfpath - 10)) then 
            begin
                hangerTop := monorailTop + Round(0.125 * monorailHeight) - Round(hangerHeight / 2) + 1;
                hangerLeft := monorailLeft + Abs(position - curMonorailPath - halfPath) - hangerWidth; 
            end
            else 
            begin
                hangerTop := monorailTop + Round(0.125 * monorailWidth) - Round(hangerHeight / 2) + 8;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2);
            end;
        end;
    end
    else if (tempName = I_CUR_4) then
    begin
        halfPath := Round(monorailWidth - (0.125 * monorailWidth));
        if (movementDirection = RIGHT_D) then
        begin
            if ((position <= curMonorailPath) AND (position >= (curMonorailPath - halfPath + 10))) then
            begin
                hangerTop := monorailTop + Round(0.875 * monorailHeight) - Round(hangerHeight / 2);
                hangerLeft := monorailLeft - (curMonorailPath - halfPath - position) + Round(hangerWidth / 4) - 10;
            end
            else if (position < (curMonorailPath - halfpath - 10)) then
            begin 
                hangerTop := monorailTop + halfPath - (curMonorailPath - position) + hangerHeight;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2) - 1;
            end
            else 
            begin
                hangerTop := monorailTop + halfPath - Round(hangerHeight / 2) - 8;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2);
            end;
        end
        else if (movementDirection = UP_D) then
        begin
            if ((position <= monorailPath[currentMonorail]) AND (position >= (curMonorailPath - halfPath))) then
            begin
                hangerTop := monorailTop + (curMonorailPath - position) - hangerHeight;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2) - 1;
            end
            else if (position < (monorailPath[currentMonorail] - halfpath - 14)) then
            begin
                hangerTop := monorailTop + Round(0.875 * monorailHeight) - Round(hangerHeight / 2) - 2;
                hangerLeft := monorailLeft + (curMonorailPath - halfPath - position) + Round(hangerWidth / 4) - 10;
            end
            else
            begin
                hangerTop := monorailTop + halfPath - Round(hangerHeight / 2) - 8;
                hangerLeft := monorailLeft + Round(0.125 * monorailWidth) - Round(hangerWidth / 2);
            end;
        end;
    end 
    //Monorail is not a Curve
    else
    begin 
        if (movementDirection = LEFT_D) then
        begin
            hangerLeft := monorailLeft + (curMonorailPath - position);
            if ((tempName = I_HOR_R) OR (tempName = I_HOR_REL) OR (tempName = I_HOR_RER)) then
            begin 
                hangerTop := Round(monorailTop + ((monorailHeight + hangerHeight) / 6)); 
            end
            else if ((tempName = I_HOR_L) OR (tempName = I_HOR_M) OR (tempName = I_HOR_K)) then
            begin 
                hangerTop := Round(monorailTop - ((monorailHeight + hangerHeight) / 6)) - 2;
            end;    
        end
        else if (movementDirection = RIGHT_D) then
        begin
            hangerLeft := monorailLeft + (monorailWidth - (curMonorailPath - position));
            if ((tempName = I_HOR_R) OR (tempName = I_HOR_REL) OR (tempName = I_HOR_RER)) then
            begin 
                hangerTop := Round(monorailTop + ((monorailHeight + hangerHeight) / 6)); 
            end
            else if ((tempName = I_HOR_L) OR (tempName = I_HOR_M) OR (tempName = I_HOR_K)) then
            begin 
                hangerTop := Round(monorailTop - ((monorailHeight + hangerHeight) / 6)) - 2;
            end;
        end
        else if (movementDirection = UP_D) then
        begin 
            hangerTop := monorailTop + (curMonorailPath - position - hangerHeight); 
            if ((tempName = I_VER_R) OR (tempName = I_VER_RET) OR (tempName = I_VER_REB)) then
            begin
                hangerLeft := Round(monorailLeft + ((monorailWidth + hangerWidth) / 3));
            end
            else if ((tempName = I_VER_L) OR (tempName = I_VER_M) OR (tempName = I_VER_K)) then
            begin
                hangerLeft := Round(monorailLeft - (monorailWidth + hangerWidth) / 3));
            end;
        end
        else if (movementDirection = DOWN_D) then
        begin
            hangerTop := monorailTop + (monorailHeight - (curMonorailPath - position)); 
            if ((tempName = I_VER_R) OR (tempName = I_VER_RET) OR (tempName = I_VER_REB)) then
            begin
                hangerLeft := Round(monorailLeft + ((monorailWidth + hangerWidth) / 3));
            end
            else if ((tempName = I_VER_L) OR (tempName = I_VER_M) OR (tempName = I_VER_K)) then
            begin
                hangerLeft := Round(monorailLeft - ((monorailWidth + hangerWidth) / 3));
            end;
        end; 
    end;    
    //Send the position to hanger Rectangle
    rtHanger[i_move].Top    := hangerTop;
    rtHanger[i_move].Left   := hangerLeft;
    rtHanger[i_move].Width  := hangerWidth;
    rtHanger[i_move].Height := hangerHeight;
end;

//Find Current Monorail
function FindCurrentMonorail(i_current : integer; position_m : integer) : integer;
var 
    i        : integer; 
    tempName : integer;
begin
    for i := 1 to NUM_OF_MON do
    begin
        //Monorail Template Name  
        tempName := monorailIdentifier[i]; 
        //Test Monorail Type 1.Vertical 2.Curves 3.Horizontal
        if ((tempName = I_VER_R) OR (tempName = I_VER_RET) OR (tempName = I_VER_REB) OR (tempName = I_VER_L) OR (tempName = I_VER_M) OR (tempName = I_VER_K)) then
        begin
            if ((position_m <= monorailPath[i]) AND (position_m >= (monorailPath[i] - tcMonorail[i].Height)))  then
            begin
                Result := i;         
                break;
            end;
        end
        else if ((tempName = I_CUR_1) OR (tempName = I_CUR_2) OR (tempName = I_CUR_3) OR (tempName = I_CUR_4)) then
        begin
            if ((position_m <= monorailPath[i]) AND (position_m >=  Round(monorailPath[i] - ((tcMonorail[i].Width - (0.125 * tcMonorail[i].Width)) * 2))))  then
            begin
                Result := i; 
                break;
            end;
        end
        else
        begin
            if ((position_m <= monorailPath[i]) AND (position_m >= (monorailPath[i] - tcMonorail[i].Width)))  then
            begin
                Result := i;
                break;
            end;
        end;
    end;
end;
