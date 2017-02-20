(******************************************************************************
 *                                 BeRoTinyPascal                             *
 ******************************************************************************
 *   A self-hosting capable tiny pascal compiler for the Win32 x86 platform   *
 ******************************************************************************
 *                        Version 2016-06-22-18-07-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2006-2016, Benjamin Rosseaux (benjamin@rosseaux.com)         *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/berotinypascal .                             *
 * 4. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 3.0 *
 *    and even with BeRoTinyPascal itself, so don't use generics/templates,   *
 *    operator overloading and another newer syntax features than Delphi 7    *
 *    and BeRoTinyPascal have support for that.                               *
 * 5. Don't use any libraries/units except the RTL system unit functions      *
 * +. Make sure the code compiles with Delphi 7, FreePascal >= 3.0 and with   *
 *    BeRoTinyPascal itself.                                                  * 
 *                                                                            *
 ******************************************************************************)
program BTPC; { BeRoTinyPascalCompiler }
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef Win32}
 {$define Windows}
{$endif}
{$ifdef Win64}
 {$define Windows}
{$endif}
{$ifdef WinCE}
 {$define Windows}
{$endif}
{$ifdef Windows}
 {$apptype console}
{$endif}

const MaximalCodeSize=262144;
      MaximalIdentifiers=512;
      MaximalTypes=32;
      MaximalList=10;
      MaximalAlfa=20;
      MaximalStringLength=255;
      MaximalCases=256;

      OPNone=-1;
      OPAdd=0;
      OPNeg=1;
      OPMul=2;
      OPDivD=3;
      OPRemD=4;
      OPDiv2=5;
      OPRem2=6;
      OPEqlI=7;
      OPNEqI=8;
      OPLssI=9;
      OPLeqI=10;
      OPGtrI=11;
      OPGEqI=12;
      OPDupl=13;
      OPSwap=14;
      OPAndB=15;
      OPOrB=16;
      OPLoad=17;
      OPStore=18;
      OPHalt=19;
      OPWrI=20;
      OPWrC=21;
      OPWrL=22;
      OPRdI=23;
      OPRdC=24;
      OPRdL=25;
      OPEOF=26;
      OPEOL=27;
      OPLdC=28;
      OPLdA=29;
      OPLdLA=30;
      OPLdL=31;
      OPLdG=32;
      OPStL=33;
      OPStG=34;
      OPMove=35;
      OPCopy=36;
      OPAddC=37;
      OPMulC=38;
      OPJmp=39;
      OPJZ=40;
      OPCall=41;
      OPAdjS=42;
      OPExit=43;

      TokIdent=0;
      TokNumber=1;
      TokStrC=2;
      TokPlus=3;
      TokMinus=4;
      TokMul=5;
      TokLBracket=6;
      TokRBracket=7;
      TokColon=8;
      TokEql=9;
      TokNEq=10;
      TokLss=11;
      TokLEq=12;
      TokGtr=13;
      TokGEq=14;
      TokLParent=15;
      TokRParent=16;
      TokComma=17;
      TokSemi=18;
      TokPeriod=19;
      TokAssign=20;
      SymBEGIN=21;
      SymEND=22;
      SymIF=23;
      SymTHEN=24;
      SymELSE=25;
      SymWHILE=26;
      SymDO=27;
      SymCASE=28;
      SymREPEAT=29;
      SymUNTIL=30;
      SymFOR=31;
      SymTO=32;
      SymDOWNTO=33;
      SymNOT=34;
      SymDIV=35;
      SymMOD=36;
      SymAND=37;
      SymOR=38;
      SymCONST=39;
      SymVAR=40;
      SymTYPE=41;
      SymARRAY=42;
      SymOF=43;
      SymPACKED=44;
      SymRECORD=45;
      SymPROGRAM=46;
      SymFORWARD=47;
      SymHALT=48;
      SymFUNC=49;
      SymPROC=50;

      IdCONST=0;
      IdVAR=1;
      IdFIELD=2;
      IdTYPE=3;
      IdFUNC=4;

      KindSIMPLE=0;
      KindARRAY=1;
      KindRECORD=2;

      TypeINT=1;
      TypeBOOL=2;
      TypeCHAR=3;
      TypeSTR=4;

      FunCHR=0;
      FunORD=1;
      FunWRITE=2;
      FunWRITELN=3;
      FunREAD=4;
      FunREADLN=5;
      FunEOF=6;
      FunEOFLN=7;

type TAlfa=array[1..MaximalAlfa] of char;

     TIdent=record
      Name:TAlfa;
      Link:integer;
      TypeDefinition:integer;
      Kind:integer;
      Value:integer;
      VariableLevel:integer;
      VariableAddress:integer;
      ReferencedParameter:boolean;
      Offset:integer;
      FunctionLevel:integer;
      FunctionAddress:integer;
      LastParameter:integer;
      ReturnAddress:integer;
      Inside:boolean;
     end;

     TType=record
      Size:integer;
      Kind:integer;
      StartIndex:integer;
      EndIndex:integer;
      SubType:integer;
      Fields:integer;
     end;

var CurrentChar:char;
    CurrentColumn:integer;
    CurrentLine:integer;
    CurrentSymbol:integer;
    CurrentIdentifer:TAlfa;
    CurrentNumber:integer;
    CurrentString:array[1..255] of char;
    CurrentStringLength:integer;
    FunctionDeclarationIndex:integer;
    Keywords:array[SymBEGIN..SymPROC] of TAlfa;
    LastOpcode:integer;
    CurrentLevel:integer;
    IsLabeled:boolean;
    SymbolNameList:array[-1..MaximalList] of integer;
    IdentifierPosition:integer;
    TypePosition:integer;
    Identifiers:array[0..MaximalIdentifiers] of TIdent;
    Types:array[1..MaximalTypes] of TType;
    Code:array[0..MaximalCodeSize] of integer;
    CodePosition:integer;
    StackPosition:integer;

function StringCompare(var s1,s2:TAlfa):boolean;
var f:boolean;
    i:integer;
begin
 f:=true;
 i:=1;
 while f and (i<=MaximalAlfa) do begin
  f:=(s1[i]=s2[i]);
  i:=i+1;
 end;
 StringCompare:=f;
end;

procedure StringCopy(var Dest:TAlfa;Src:TAlfa);
begin
 Dest:=Src;
end;

procedure Error(n:integer);
begin
 Write('Error ',n:1,': ');
 case n of
  TokIdent:begin
   Write('Identifier expected');
  end;
  TokNumber:begin
   Write('Number expected');
  end;
  TokStrC:begin
   Write('String expected');
  end;
  TokPlus:begin
   Write('"+" expected');
  end;
  TokMinus:begin
   Write('"-" expected');
  end;
  TokMul:begin
   Write('"*" expected');
  end;
  TokLBracket:begin
   Write('"[" expected');
  end;
  TokRBracket:begin
   Write('"]" expected');
  end;
  TokColon:begin
   Write('":" expected');
  end;
  TokEql:begin
   Write('"=" expected');
  end;
  TokNEq:begin
   Write('"<>" expected');
  end;
  TokLss:begin
   Write('"<" expected');
  end;
  TokLEq:begin
   Write('"<=" expected');
  end;
  TokGtr:begin
   Write('">" expected');
  end;
  TokGEq:begin
   Write('">=" expected');
  end;
  TokLParent:begin
   Write('"(" expected');
  end;
  TokRParent:begin
   Write('")" expected');
  end;
  TokComma:begin
   Write('"," expected');
  end;
  TokSemi:begin
   Write('";" expected');
  end;
  TokPeriod:begin
   Write('"." expected');
  end;
  TokAssign:begin
   Write('":=" expected');
  end;
  SymBEGIN:begin
   Write('"begin" expected');
  end;
  SymEND:begin
   Write('"end" expected');
  end;
  SymIF:begin
   Write('"if" expected');
  end;
  SymTHEN:begin
   Write('"then" expected');
  end;
  SymELSE:begin
   Write('"else" expected');
  end;
  SymWHILE:begin
   Write('"else" expected');
  end;
  SymDO:begin
   Write('"do" expected');
  end;
  SymCASE:begin
   Write('"case" expected');
  end;
  SymREPEAT:begin
   Write('"repeat" expected');
  end;
  SymUNTIL:begin
   Write('"until" expected');
  end;
  SymFOR:begin
   Write('"for" expected');
  end;
  SymTO:begin
   Write('"to" expected');
  end;
  SymDOWNTO:begin
   Write('"downto" expected');
  end;
  SymNOT:begin
   Write('"not" expected');
  end;
  SymDIV:begin
   Write('"div" expected');
  end;
  SymMOD:begin
   Write('"mod" expected');
  end;
  SymAND:begin
   Write('"and" expected');
  end;
  SymOR:begin
   Write('"or" expected');
  end;
  SymCONST:begin
   Write('"const" expected');
  end;
  SymVAR:begin
   Write('"var" expected');
  end;
  SymTYPE:begin
   Write('"type" expected');
  end;
  SymARRAY:begin
   Write('"array" expected');
  end;
  SymOF:begin
   Write('"of" expected');
  end;
  SymPACKED:begin
   Write('"packed" expected');
  end;
  SymRECORD:begin
   Write('"record" expected');
  end;
  SymPROGRAM:begin
   Write('"program" expected');
  end;
  SymFORWARD:begin
   Write('"forward" expected');
  end;
  SymHALT:begin
   Write('"halt" expected');
  end;
  SymFUNC:begin
   Write('"function" expected');
  end;
  SymPROC:begin
   Write('"procedure" expected');
  end;
  100:begin
   Write('String literal must be closed');
  end;
  101:begin
   Write('String is empty');
  end;
  102:begin
   Write('Bad char');
  end;
  103:begin
   Write('Too many identifiers');
  end;
  104:begin
   Write('Duplicate identifier');
  end;
  105:begin
   Write('Duplicate procedure/function');
  end;
  106:begin
   Write('Unknown identifiers');
  end;
  107:begin
   Write('Invalid type');
  end;
  108:begin
   Write('Record type expected');
  end;
  109:begin
   Write('Unknown field');
  end;
  110:begin
   Write('Array type expected');
  end;
  111:begin
   Write('Non-writeable type');
  end;
  112:begin
   Write('Non-readable type');
  end;
  113:begin
   Write('Too many argumnts');
  end;
  114:begin
   Write('Passing string to var argument isn''t allowed');
  end;
  115:begin
   Write('Passing string to non-array argument isn''t allowed');
  end;
  116:begin
   Write('Passing string to non-char-array argument isn''t allowed');
  end;
  117:begin
   Write('Passing string to wrong sized char-array argument isn''t allowed');
  end;
  118:begin
   Write('Too few argumnts');
  end;
  119:begin
   Write('Procedure calls inside a expression aren''t allowed');
  end;
  120:begin
   Write('Type inside a expression isn''t allowed');
  end;
  121:begin
   Write('Expression expected');
  end;
  122:begin
   Write('Illegal assigning to function');
  end;
  123:begin
   Write('Illegal assigning to constant or type');
  end;
  124:begin
   Write('Case expression must be constant');
  end;
  125:begin
   Write('Case expression expected');
  end;
  126:begin
   Write('":" expected');
  end;
  127:begin
   Write('Variable after "FOR" expected');
  end;
  128:begin
   Write('Incorrect iterator type');
  end;
  129:begin
   Write('"TO" or "DOWNTO" expected');
  end;
  130:begin
   Write('Constant expected');
  end;
  131:begin
   Write('Identifier or number literal expected');
  end;
  132:begin
   Write('First index of array must be less or equal then last');
  end;
  133:begin
   Write('Type expected');
  end;
  134:begin
   Write('Too many types');
  end;
  135:begin
   Write('Too many nested records');
  end;
  136:begin
   Write('Too many nested procedures');
  end;
  137:begin
   Write('Invalid function return type');
  end;
  138:begin
   Write('Too many arguments then at forward declaration');
  end;
  139:begin
   Write('Argument name doesn''t match forward declaration');
  end;
  140:begin
   Write('Argument type doesn''t match forward declaration');
  end;
  141:begin
   Write('Argument var doesn''t match forward declaration');
  end;
  142:begin
   Write('Too less arguments then at forward declaration');
  end;
  143:begin
   Write('Already forward declared');
  end;
  144:begin
   Write('No definition for forward declared');
  end;
  145:begin
   Write('Internal negative retn');
  end;
  146:begin
   Write('Binary is too big');
  end;
  147:begin
   Write('String is too long');
  end;
  148:begin
   Write('Too many cases');
  end;
  149:begin
   Write('Too large code');
  end;
  150:begin
   Write('Incompatible types');
  end;
 end;
 WriteLn(' at line ',CurrentLine:1,' at column ',CurrentColumn:1);
 Halt;
end;

procedure ReadChar;
begin
 if not EOF then begin
  read(CurrentChar);
  CurrentColumn:=CurrentColumn+1;
  if CurrentChar=#10 then begin
   CurrentLine:=CurrentLine+1;
   CurrentColumn:=0;
  end;
 end else begin
  CurrentChar:=#0;
 end;
end;

function ReadNumber:integer;
var Num:integer;
begin
 Num:=0;
 if ('0'<=CurrentChar) and (CurrentChar<='9') then begin
  while ('0'<=CurrentChar) and (CurrentChar<='9') do begin
   Num:=(Num*10)+(ord(CurrentChar)-ord('0'));
   ReadChar;
  end;
 end else if CurrentChar='$' then begin
  ReadChar;
  while (('0'<=CurrentChar) and (CurrentChar<='9')) or
        (('a'<=CurrentChar) and (CurrentChar<='f')) or
        (('A'<=CurrentChar) and (CurrentChar<='F')) do begin
   if ('0'<=CurrentChar) and (CurrentChar<='9') then begin
    Num:=(Num*16)+(ord(CurrentChar)-ord('0'));
   end else if ('a'<=CurrentChar) and (CurrentChar<='f') then begin
    Num:=(Num*16)+(ord(CurrentChar)-ord('a')+10);
   end else if ('A'<=CurrentChar) and (CurrentChar<='F') then begin
    Num:=(Num*16)+(ord(CurrentChar)-ord('A')+10);
   end;
   ReadChar;
  end;
 end;
 ReadNumber:=Num;
end;

procedure GetSymbol;
var k,s:integer;
    StrEnd,InStr:boolean;
    LastChar:char;
begin
 while (CurrentChar>#0) and (CurrentChar<=' ') do begin
  ReadChar;
 end;
 if (('a'<=CurrentChar) and (CurrentChar<='z')) or (('A'<=CurrentChar) and (CurrentChar<='Z')) then begin
  k:=0;
  while ((('a'<=CurrentChar) and (CurrentChar<='z')) or (('A'<=CurrentChar) and (CurrentChar<='Z')) or (('0'<=CurrentChar) and (CurrentChar<='9'))) or (CurrentChar='_') do begin
   if k<>MaximalAlfa then begin
    k:=k+1;
    if ('a'<=CurrentChar) and (CurrentChar<='z') then begin
     CurrentChar:=chr(ord(CurrentChar)-32);
    end;
    CurrentIdentifer[k]:=CurrentChar;
   end;
   ReadChar;
  end;
  while k<>MaximalAlfa do begin
   k:=k+1;
   CurrentIdentifer[k]:=' ';
  end;
  CurrentSymbol:=TokIdent;
  s:=SymBEGIN;
  while s<=SymPROC do begin
   if StringCompare(Keywords[s],CurrentIdentifer) then begin
    CurrentSymbol:=s;
   end;
   s:=s+1;
  end;
 end else if (('0'<=CurrentChar) and (CurrentChar<='9')) or (CurrentChar='$') then begin
  CurrentSymbol:=TokNumber;
  CurrentNumber:=ReadNumber;
 end else if CurrentChar=':' then begin
  ReadChar;
  if CurrentChar='=' then begin
   ReadChar;
   CurrentSymbol:=TokAssign;
  end else begin
   CurrentSymbol:=TokColon;
  end;
 end else if CurrentChar='>' then begin
  ReadChar;
  if CurrentChar='=' then begin
   ReadChar;
   CurrentSymbol:=TokGEq;
  end else begin
   CurrentSymbol:=TokGtr;
  end;
 end else if CurrentChar='<' then begin
  ReadChar;
  if CurrentChar='=' then begin
   ReadChar;
   CurrentSymbol:=TokLEq;
  end else if CurrentChar='>' then begin
   ReadChar;
   CurrentSymbol:=TokNEq;
  end else begin
   CurrentSymbol:=TokLss;
  end;
 end else if CurrentChar='.' then begin
  ReadChar;
  if CurrentChar='.' then begin
   ReadChar;
   CurrentSymbol:=TokColon;
  end else begin
   CurrentSymbol:=TokPeriod
  end;
 end else if (CurrentChar='''') or (CurrentChar='#') then begin
  CurrentStringLength:=0;
  StrEnd:=false;
  InStr:=false;
  CurrentSymbol:=TokStrC;
  while not StrEnd do begin
   if InStr then begin
    if CurrentChar='''' then begin
     ReadChar;
     if CurrentChar='''' then begin
      if CurrentStringLength=MaximalStringLength then begin
       Error(147);
      end;
      CurrentStringLength:=CurrentStringLength+1;
      CurrentString[CurrentStringLength]:=CurrentChar;
      ReadChar;
     end else begin
      InStr:=false;
     end;
    end else if (CurrentChar=#13) or (CurrentChar=#10) then begin
     Error(100);
     StrEnd:=true;
    end else begin
      if CurrentStringLength=MaximalStringLength then begin
       Error(147);
      end;
     CurrentStringLength:=CurrentStringLength+1;
     CurrentString[CurrentStringLength]:=CurrentChar;
     ReadChar;
    end;
   end else begin
    if CurrentChar='''' then begin
     InStr:=true;
     ReadChar;
    end else if CurrentChar='#' then begin
     ReadChar;
     if CurrentStringLength=MaximalStringLength then begin
      Error(147);
     end;
     CurrentStringLength:=CurrentStringLength+1;
     CurrentString[CurrentStringLength]:=chr(ReadNumber);
    end else begin
     StrEnd:=true;
    end;
   end;
  end;
  if CurrentStringLength=0 then begin
   Error(101);
  end;
 end else if CurrentChar='+' then begin
  ReadChar;
  CurrentSymbol:=TokPlus;
 end else if CurrentChar='-' then begin
  ReadChar;
  CurrentSymbol:=TokMinus;
 end else if CurrentChar='*' then begin
  ReadChar;
  CurrentSymbol:=TokMul;
 end else if CurrentChar='(' then begin
  ReadChar;
  if CurrentChar='*' then begin
   ReadChar;
   LastChar:='-';
   while (CurrentChar<>#0) and not ((CurrentChar=')') and (LastChar='*')) do begin
    LastChar:=CurrentChar;
    ReadChar;
   end;
   ReadChar;
   GetSymbol;
  end else begin
   CurrentSymbol:=TokLParent;
  end;
 end else if CurrentChar=')' then begin
  ReadChar;
  CurrentSymbol:=TokRParent;
 end else if CurrentChar='[' then begin
  ReadChar;
  CurrentSymbol:=TokLBracket;
 end else if CurrentChar=']' then begin
  ReadChar;
  CurrentSymbol:=TokRBracket;
 end else if CurrentChar='=' then begin
  ReadChar;
  CurrentSymbol:=TokEql;
 end else if CurrentChar=',' then begin
  ReadChar;
  CurrentSymbol:=TokComma;
 end else if CurrentChar=';' then begin
  ReadChar;
  CurrentSymbol:=TokSemi;
 end else if CurrentChar='{' then begin
  while (CurrentChar<>'}') and (CurrentChar<>#0) do begin
   ReadChar;
  end;
  ReadChar;
  GetSymbol;
 end else if CurrentChar='/' then begin
  ReadChar;
  if CurrentChar='/' then begin
   repeat
    ReadChar;
   until (CurrentChar=#10) or (CurrentChar=#0);
   GetSymbol;
  end else begin
   Error(102);
  end;
 end else begin
  Error(102);
 end;
end;

procedure Check(s:integer);
begin
 if CurrentSymbol<>s then begin
  Error(s);
 end;
end;

procedure Expect(s:integer);
begin
 Check(s);
 GetSymbol;
end;

procedure EnterSymbol(CurrentIdentifer:TAlfa;k,t:integer);
var j:integer;
begin
 if IdentifierPosition=MaximalIdentifiers then begin
  Error(103);
 end;
 IdentifierPosition:=IdentifierPosition+1;
 Identifiers[0].Name:=CurrentIdentifer;
 j:=SymbolNameList[CurrentLevel];
 while not StringCompare(Identifiers[j].Name,CurrentIdentifer) do begin
  j:=Identifiers[j].Link;
 end;
 if j<>0 then begin
  if Identifiers[j].Kind<>IdFUNC then begin
   Error(104);
  end;
  if (Code[Identifiers[j].FunctionAddress]<>OPJmp) or (Code[Identifiers[j].FunctionAddress+1]>0) then begin
   Error(105);
  end;
  Identifiers[j].Name[1]:='$';
  Code[Identifiers[j].FunctionAddress+1]:=CodePosition;
  FunctionDeclarationIndex:=j;
 end;
 Identifiers[IdentifierPosition].Name:=CurrentIdentifer;
 Identifiers[IdentifierPosition].Link:=SymbolNameList[CurrentLevel];
 Identifiers[IdentifierPosition].TypeDefinition:=t;
 Identifiers[IdentifierPosition].Kind:=k;
 SymbolNameList[CurrentLevel]:=IdentifierPosition;
end;

function Position:integer;
var i,j:integer;
begin
 Identifiers[0].Name:=CurrentIdentifer;
 i:=CurrentLevel;
 repeat
  j:=SymbolNameList[i];
  while not StringCompare(Identifiers[j].Name,CurrentIdentifer) do begin
   j:=Identifiers[j].Link;
  end;
  i:=i-1;
 until (i<-1) or (j<>0);
 if j=0 then begin
  Error(106);
 end;
 Position:=j;
end;

procedure EmitCode(Value:integer);
begin
 if CodePosition>MaximalCodeSize then begin
  Error(149);
 end;
 Code[CodePosition]:=Value;
 CodePosition:=CodePosition+1;
end;

procedure EmitOpcode(Opcode,a:integer);
begin
 case Opcode of
  OPDupl,OPEOF,OPEOL,OPLdC,OPLdA,OPLdLA,OPLdL,OPLdG:begin
   StackPosition:=StackPosition-4;
  end;
  OPNeg,OPDiv2,OPRem2,OPSwap,OPLoad,OPHalt,OPWrL,OPRdL,OpAddC,OPMulC,
  OPJmp,OPCall,OPExit:begin
  end;
  OPAdd,OPMul,OPDivD,OPRemD,OPEqlI,OPNEqI,OPLssI,OPLeqI,OPGtrI,OPGEqI,OPAndB,
  OPOrB,OPWrC,OPRdI,OPRdC,OPStL,OPStG,OPJZ:begin
   StackPosition:=StackPosition+4;
  end;
  OPStore,OPWrI,OPMove:begin
   StackPosition:=StackPosition+8;
  end;
  OPCopy:begin
   StackPosition:=StackPosition-(a-4);
  end;
  OPAdjS:begin
   StackPosition:=StackPosition+a;
  end;
 end;
 if not ((((Opcode=OPAddC) or (Opcode=OPAdjS)) and (a=0)) or ((Opcode=OPMulC) and (a=1))) then begin
  if IsLabeled then begin
   Code[CodePosition]:=Opcode;
   CodePosition:=CodePosition+1;
   if Opcode>=OPLdC then begin
    Code[CodePosition]:=a;
    CodePosition:=CodePosition+1;
   end;
   IsLabeled:=false;
  end else if (LastOpcode=OPLdC) and (Opcode=OPAdd) then begin
   Code[CodePosition-2]:=OPAddC;
  end else if (LastOpcode=OPLdC) and (Opcode=OPMul) then begin
   Code[CodePosition-2]:=OPMulC;
  end else if (LastOpcode=OPLdC) and (Opcode=OPNeg) then begin
   Code[CodePosition-1]:=-Code[CodePosition-1];
   Opcode:=LastOpcode;
  end else if (LastOpcode=OPLdC) and (Code[CodePosition-1]=2) and (Opcode=OPDivD) then begin
   Code[CodePosition-2]:=OPDiv2;
   CodePosition:=CodePosition-1;
  end else if (LastOpcode=OPLdC) and (Code[CodePosition-1]=2) and (Opcode=OPRemD) then begin
   Code[CodePosition-2]:=OPRem2;
   CodePosition:=CodePosition-1;
  end else if (LastOpcode=OPLdA) and (Opcode=OPStore) then begin
   Code[CodePosition-2]:=OPStG;
  end else if (LastOpcode=OPLdA) and (Opcode=OPLoad) then begin
   Code[CodePosition-2]:=OPLdG;
  end else if (LastOpcode=OPLdLA) and (Opcode=OPStore) then begin
   Code[CodePosition-2]:=OPStL;
  end else if (LastOpcode=OPLdLA) and (Opcode=OPLoad) then begin
   Code[CodePosition-2]:=OPLdL;
  end else begin
   EmitCode(Opcode);
   if Opcode>=OPLdC then begin
    EmitCode(a);
   end;
  end;
  LastOpcode:=Opcode;
 end;
end;

procedure EmitOpcode2(Opcode:integer);
begin
 EmitOpcode(Opcode,0);
end;

function CodeLabel:integer;
begin
 CodeLabel:=CodePosition;
 IsLabeled:=true;
end;

procedure EmitAddress(Level,Address:integer);
begin
 if Level=0 then begin
  EmitOpcode(OPLdA,Address);
 end else if Level=CurrentLevel then begin
  EmitOpcode(OPLdLA,Address-StackPosition);
 end else begin
  EmitOpcode(OPLdL,-StackPosition);
  while Level+1<>CurrentLevel do begin
   EmitOpcode2(OPLoad);
   Level:=Level+1;
  end;
  EmitOpcode(OPAddC,Address);
 end;
end;

procedure EmitAddressVar(IdentifierIndex:integer);
begin
 EmitAddress(Identifiers[IdentifierIndex].VariableLevel,Identifiers[IdentifierIndex].VariableAddress);
 if Identifiers[IdentifierIndex].ReferencedParameter then begin
  EmitOpcode2(OPLoad);
 end;
end;

procedure MustBe(x,y:integer);
begin
 if x<>y then begin
  if (Types[x].Kind=KindARRAY) and (Types[y].Kind=KindARRAY) and (Types[x].StartIndex=Types[y].StartIndex) and (Types[x].EndIndex=Types[y].EndIndex) then begin
   MustBe(Types[x].SubType,Types[y].SubType);
  end else begin
   Error(107);
  end;
 end;
end;

procedure Expression(var x:integer); forward;

procedure Selector(var t,IdentifierIndex:integer);
var j,x:integer;
begin
 t:=Identifiers[IdentifierIndex].TypeDefinition;
 GetSymbol;
 if (CurrentSymbol=TokPeriod) or (CurrentSymbol=TokLBracket) then begin
  EmitAddressVar(IdentifierIndex);
  IdentifierIndex:=0;
  while (CurrentSymbol=TokPeriod) or (CurrentSymbol=TokLBracket) do begin
   case CurrentSymbol of
    TokPeriod:begin
     if Types[t].Kind<>KindRECORD then begin
      Error(108);
     end;
     GetSymbol;
     Check(TokIdent);
     j:=Types[t].Fields;
     Identifiers[0].Name:=CurrentIdentifer;
     while not StringCompare(Identifiers[j].Name,CurrentIdentifer) do begin
      j:=Identifiers[j].Link;
     end;
     if j=0 then begin
      Error(109);
     end;
     EmitOpcode(OPAddC,Identifiers[j].Offset);
     t:=Identifiers[j].TypeDefinition;
     GetSymbol;
    end;
    TokLBracket:begin
     repeat
      if Types[t].Kind<>KindARRAY then begin
       Error(110);
      end;
      GetSymbol;
      Expression(x);
      MustBe(TypeINT,x);
      EmitOpcode(OPAddC,-Types[t].StartIndex);
      t:=Types[t].SubType;
      EmitOpcode(OPMulC,Types[t].Size);
      EmitOpcode2(OPAdd);
     until CurrentSymbol<>TokComma;
     Expect(TokRBracket)
    end;
   end;
  end;
 end;
end;

procedure VarPar(var t:integer);
var j:integer;
begin
 Check(TokIdent);
 j:=Position;
 Selector(t,j);
 if j<>0 then begin
  EmitAddressVar(j);
 end;
end;

procedure InternalFunction(n:integer);
var x:integer;
begin
 case n of
  FunCHR:begin
   Expect(TokLParent);
   Expression(x);
   MustBe(TypeINT,x);
   Expect(TokRParent)
  end;
  FunORD:begin
   Expect(TokLParent);
   Expression(x);
   if x<>TypeBOOL then begin
    MustBe(TypeCHAR,x);
   end;
   Expect(TokRParent);
  end;
  FunWRITE,FunWRITELN:begin
   if n=FunWRITE then begin
    Check(TokLParent);
   end;
   if CurrentSymbol=TokLParent then begin
    repeat
     GetSymbol;
     if CurrentSymbol=TokStrC then begin
      x:=1;
      while x<=CurrentStringLength do begin
       EmitOpcode(OPLdC,ord(CurrentString[x])); {OPLdC == push byte/dword value}
       EmitOpcode2(OPWrC);                      {writeChar(arg = top_of_stack)}
       x:=x+1;
      end;
      GetSymbol;
     end else begin
      Expression(x);
      if CurrentSymbol=TokColon then begin
       MustBe(TypeINT,x);
       GetSymbol;
       Expression(x);
       MustBe(TypeINT,x);
       EmitOpcode2(OPWrI);
      end else if x=TypeINT then begin
       EmitOpcode(OPLdC,1);
       EmitOpcode2(OPWrI);
      end else if x=TypeCHAR then begin
       EmitOpcode2(OPWrC);
      end else begin
       Error(111);
      end;
     end;
    until CurrentSymbol<>TokComma;
    Expect(TokRParent)
   end;
   if n=FunWRITELN then begin
    EmitOpcode2(OPWrL);
   end; 
  end;
  FunREAD,FunREADLN:begin
   if n=FunREAD then begin
    Check(TokLParent);
   end;
   if CurrentSymbol=TokLParent then begin
    repeat
     GetSymbol;
     VarPar(x);
     if x=TypeINT then begin
      EmitOpcode2(OPRdI);            {there was a mistake in rtl. so this function is not used?}
     end else if x=TypeCHAR then begin
      EmitOpcode2(OPRdC);
     end else begin
      Error(112);
     end;
    until CurrentSymbol<>TokComma;
    Expect(TokRParent);
   end;
   if n=FunREADLN then begin
    EmitOpcode2(OPRdL);
   end;
  end;
  FunEOF:begin
   EmitOpcode2(OPEOF);
  end;
  FunEOFLN:begin
   EmitOpcode2(OPEOL);
  end;
 end;
end;

procedure FunctionCall(i:integer);
var OldStackPosition,p,x:integer;
begin
 GetSymbol;
 if Identifiers[i].FunctionLevel<0 then begin
  InternalFunction(Identifiers[i].FunctionAddress);
 end else begin
  if Identifiers[i].TypeDefinition<>0 then begin
   EmitOpcode(OPLdC,0);
  end;
  p:=i;
  OldStackPosition:=StackPosition;
  if CurrentSymbol=TokLParent then begin
   repeat
    GetSymbol;
    if p=Identifiers[i].LastParameter then begin
     Error(113);
    end;
    p:=p+1;
    if Identifiers[p].ReferencedParameter then begin
     VarPar(x);
    end else begin
     Expression(x);
     if Types[x].Kind<>KindSIMPLE then begin
      EmitOpcode(OPCopy,Types[x].Size);
     end;
    end;
    if x=TypeSTR then begin
     if Identifiers[p].ReferencedParameter then begin
      Error(114);
     end;
     if Types[Identifiers[p].TypeDefinition].Kind<>KindARRAY then begin
      Error(115);
     end;
     if Types[Identifiers[p].TypeDefinition].SubType<>TypeCHAR then begin
      Error(116);
     end;
     if ((Types[Identifiers[p].TypeDefinition].EndIndex-Types[Identifiers[p].TypeDefinition].StartIndex)+1)<>CurrentStringLength then begin
      Error(117);
     end;
    end else begin
     MustBe(Identifiers[p].TypeDefinition,x);
    end;
   until CurrentSymbol<>TokComma;
   Expect(TokRParent);
  end;
  if p<>Identifiers[i].LastParameter then begin
   Error(118);
  end;
  if Identifiers[i].FunctionLevel<>0 then begin
   EmitAddress(Identifiers[i].FunctionLevel,0);
  end;
  EmitOpcode(OPCall,Identifiers[i].FunctionAddress);
  StackPosition:=OldStackPosition;
 end;
end;

procedure Factor(var t:integer);
var i:integer;
begin
 if CurrentSymbol=TokIdent then begin
  i:=Position;
  t:=Identifiers[i].TypeDefinition;
  case Identifiers[i].Kind of
   IdCONST:begin
    GetSymbol;
    EmitOpcode(OPLdC,Identifiers[i].Value);
   end;
   IdVAR:begin
    Selector(t,i);
    if i<>0 then begin
     EmitAddressVar(i);
    end;
    if Types[t].Kind=KindSIMPLE then begin
     EmitOpcode2(OPLoad);
    end;
   end;
   IdFUNC:begin
    if t=0 then begin
     Error(119);
    end else begin
     FunctionCall(i);
    end;
   end;
   IdTYPE:begin
    Error(120);
   end;
  end;
 end else if CurrentSymbol=TokNumber then begin
  EmitOpcode(OPLdC,CurrentNumber);
  t:=TypeINT;
  GetSymbol;
 end  else if CurrentSymbol=TokStrC then begin
  i:=CurrentStringLength;
  while i>=1 do begin
   EmitOpcode(OPLdC,ord(CurrentString[i]));
   i:=i-1;
  end;
  t:=TypeCHAR;
  if CurrentStringLength<>1 then begin
   t:=TypeSTR;
  end;
  GetSymbol;
 end else if CurrentSymbol=TokLParent then begin
  GetSymbol;
  Expression(t);
  Expect(TokRParent);
 end else if CurrentSymbol=SymNOT then begin
  GetSymbol;
  Factor(t);
  MustBe(TypeBOOL,t);
  EmitOpcode2(OPNeg);
  EmitOpcode(OPAddC,1);
 end else begin
  Error(121);
 end;
end;

procedure Term(var x:integer);
var y:integer;
begin
 Factor(x);
 while (CurrentSymbol=SymAND) or (CurrentSymbol=TokMul) or (CurrentSymbol=SymDIV) or (CurrentSymbol=SymMOD) do begin
  if CurrentSymbol=SymAND then begin
   MustBe(TypeBOOL,x);
  end else begin
   MustBe(TypeINT,x);
  end;
  case CurrentSymbol of
   TokMul:begin
    GetSymbol;
    Factor(y);
    EmitOpcode2(OPMul);
   end;
   SymDIV:begin
    GetSymbol;
    Factor(y);
    EmitOpcode2(OPDivD);
   end;
   SymMOD:begin
    GetSymbol;
    Factor(y);
    EmitOpcode2(OPRemD);
   end;
   SymAND:begin
    GetSymbol;
    Factor(y);
    EmitOpcode2(OPAndB);
   end;
  end;
  MustBe(x,y);
 end;
end;

procedure SimpleExpression(var x:integer);
var y:integer;
begin
 if CurrentSymbol=TokPlus then begin
  GetSymbol;
  Term(x);
  MustBe(TypeINT,x);
 end else if CurrentSymbol=TokMinus then begin
  GetSymbol;
  Term(x);
  MustBe(TypeINT,x);
  EmitOpcode2(OPNeg);
 end else begin
  Term(x);
 end;
 while (CurrentSymbol=SymOR) or (CurrentSymbol=TokPlus) or (CurrentSymbol=TokMinus) do begin
  if CurrentSymbol=SymOR then begin
   MustBe(TypeBOOL,x);
  end else begin
   MustBe(TypeINT,x);
  end;
  case CurrentSymbol of
   TokPlus:begin
    GetSymbol;
    Term(y);
    EmitOpcode2(OPAdd);
   end;
   TokMinus:begin
    GetSymbol;
    Term(y);
    EmitOpcode2(OPNeg);
    EmitOpcode2(OPAdd);
   end;
   SymOR:begin
    GetSymbol;
    Term(y);
    EmitOpcode2(OPOrB);
   end;
  end;
  MustBe(x,y);
 end;
end;

procedure Expression(var x:integer);
var o,y:integer;
begin
 SimpleExpression(x);
 if (CurrentSymbol=TokEql) or (CurrentSymbol=TokNEq) or (CurrentSymbol=TokLss) or (CurrentSymbol=TokLEq) or (CurrentSymbol=TokGtr) or (CurrentSymbol=TokGEq) then begin
  if (x=TypeSTR) or (Types[x].Kind<>KindSIMPLE) then begin
   Error(150);
  end;
  o:=CurrentSymbol;
  GetSymbol;
  SimpleExpression(y);
  MustBe(x,y);
  case o of
   TokEql:begin
    EmitOpcode2(OPEqlI);
   end;
   TokNEq:begin
    EmitOpcode2(OPNEqI);
   end;
   TokLss:begin
    EmitOpcode2(OPLssI);
   end;
   TokLEq:begin
    EmitOpcode2(OPLeqI);
   end;
   TokGtr:begin
    EmitOpcode2(OPGtrI);
   end;
   TokGEq:begin
    EmitOpcode2(OPGEqI);
   end;
  end;
  x:=TypeBOOL;
 end;
end;

procedure Statement;
var L:array[1..MaximalCases] of integer;
    m,n,i,j,t,x,r,OldStackPosition:integer;
begin
 if CurrentSymbol=TokIdent then begin
  i:=Position;
  case Identifiers[i].Kind of
   IdVAR:begin
    Selector(t,i);
    Expect(TokAssign);
    Expression(x);
    MustBe(t,x);
    if i=0 then begin
     EmitOpcode2(OPSwap);
    end else begin
     EmitAddressVar(i);
    end;
    if Types[t].Kind=KindSIMPLE then begin
     EmitOpcode2(OPStore);
    end else begin
     EmitOpcode(OPMove,Types[t].Size);
    end;
   end;
   IdFUNC:begin
    if Identifiers[i].TypeDefinition=0 then begin
     FunctionCall(i);
    end else begin
     if not Identifiers[i].Inside then begin
      Error(122);
     end;
     GetSymbol;
     Expect(TokAssign);
     Expression(x);
     MustBe(Identifiers[i].TypeDefinition,x);
     EmitAddress(Identifiers[i].FunctionLevel+1,Identifiers[i].ReturnAddress);
     EmitOpcode2(OPStore);
    end;
   end;
   IdCONST,IdFIELD,IdTYPE:Error(123);
  end;
 end else if CurrentSymbol=SymIF then begin
  GetSymbol;
  Expression(t);
  MustBe(TypeBOOL,t);
  Expect(SymTHEN);
  i:=CodeLabel;
  EmitOpcode(OPJZ,0);
  Statement;
  if CurrentSymbol=SymELSE then begin
   GetSymbol;
   j:=CodeLabel;
   EmitOpcode(OPJmp,0);
   Code[i+1]:=CodeLabel;
   i:=j;
   Statement;
  end;
  Code[i+1]:=CodeLabel;
 end else if CurrentSymbol=SymCASE then begin
  GetSymbol;
  Expression(t);
  MustBe(TypeINT,t);
  Expect(SymOF);
  j:=0;
  m:=0;
  repeat
   if j<>0 then begin
    Code[j+1]:=CodeLabel;
   end;
   n:=m;
   repeat
    if n<>m then begin
     GetSymbol;
    end;
    EmitOpcode2(OPDupl);
    if CurrentSymbol=TokIdent then begin
     i:=Position;
     if Identifiers[i].Kind<>IdCONST then begin
      Error(124);
     end;
     EmitOpcode(OPLdC,Identifiers[i].Value);
    end else if CurrentSymbol=TokNumber then begin
     EmitOpcode(OPLdC,CurrentNumber);
    end else if (CurrentSymbol=TokStrC) and (CurrentStringLength=1) then begin
     EmitOpcode(OPLdC,ord(CurrentString[1]));
    end else begin
     Error(125);
    end;
    EmitOpcode2(OPNEqI);
    if n=MaximalCases then begin
     Error(148);
    end;
    n:=n+1;
    L[n]:=CodeLabel;
    EmitOpcode(OPJZ,0);
    GetSymbol;
   until CurrentSymbol<>TokComma;
   if CurrentSymbol<>TokColon then begin
    Error(126);
   end;
   j:=CodeLabel;
   EmitOpcode(OPJmp,0);
   repeat
    Code[L[n]+1]:=CodeLabel;
    n:=n-1;
   until n=m;
   GetSymbol;
   Statement;
   m:=m+1;
   L[m]:=CodeLabel;
   EmitOpcode(OPJmp,0);
   if CurrentSymbol=TokSemi then begin
    GetSymbol;
   end;
  until CurrentSymbol=SymEND;
  Code[j+1]:=CodeLabel;
  repeat
   Code[L[m]+1]:=CodeLabel;
   m:=m-1;
  until m=0;
  EmitOpcode(OPAdjS,4);
  GetSymbol;
 end else if CurrentSymbol=SymFOR then begin
  GetSymbol;
  if CurrentSymbol=TokIdent then begin
   OldStackPosition:=StackPosition;

   i:=Position;
   if Identifiers[i].Kind<>IdVAR then begin
    Error(127);
   end;
   Selector(t,i);
   Expect(TokAssign);
   Expression(x);
   MustBe(t,x);
   if i=0 then begin
    EmitOpcode2(OPSwap);
   end else begin
    EmitAddressVar(i);
   end;
   if Types[t].Kind<>KindSIMPLE then begin
    Error(128);
   end;
   EmitOpcode2(OPStore);

   r:=1;
   if CurrentSymbol=SymTO then begin
    Expect(SymTO);
   end else if CurrentSymbol=SymDOWNTO then begin
    Expect(SymDOWNTO);
    r:=-1;
   end else begin
    Error(129);
   end;

   j:=CodeLabel;
   if i=0 then begin
    EmitOpcode2(OPSwap);
   end else begin
    EmitAddressVar(i);
   end;
   EmitOpcode2(OPLoad);
   Expression(x);
   MustBe(t,x);
   if r>0 then begin
    EmitOpcode2(OPLeqI);
   end else begin
    EmitOpcode2(OPGeqI);
   end;
   n:=CodeLabel;
   EmitOpcode(OPJZ,0);

   Expect(SymDO);

   Statement;

   if i=0 then begin
    EmitOpcode2(OPSwap);
   end else begin
    EmitAddressVar(i);
   end;
   EmitOpcode2(OPLoad);

   EmitOpcode(OPAddC,r);

   if i=0 then begin
    EmitOpcode2(OPSwap);
   end else begin
    EmitAddressVar(i);
   end;
   EmitOpcode2(OPStore);

   EmitOpcode(OPJmp,j);
   Code[n+1]:=CodeLabel;

   EmitOpcode(OPAdjS,OldStackPosition-StackPosition);

  end else begin
   Expect(TokIdent);
  end;
 end else if CurrentSymbol=SymWHILE then begin
  GetSymbol;
  i:=CodeLabel;
  Expression(t);
  MustBe(TypeBOOL,t);
  Expect(SymDO);
  j:=CodeLabel;
  EmitOpcode(OPJZ,0);
  Statement;
  EmitOpcode(OPJmp,i);
  Code[j+1]:=CodeLabel;
 end else if CurrentSymbol=SymREPEAT then begin
  i:=CodeLabel;
  repeat
   GetSymbol;
   Statement;
  until CurrentSymbol<>TokSemi;
  Expect(SymUNTIL);
  Expression(t);
  MustBe(TypeBOOL,t);
  EmitOpcode(OPJZ,i);
 end else if CurrentSymbol=SymBEGIN then begin
  repeat
   GetSymbol;
   Statement;
  until CurrentSymbol<>TokSemi;
  Expect(SymEND);
 end else if CurrentSymbol=SymHALT then begin
  EmitOpcode2(OPHalt);
  GetSymbol;
 end;
end;

procedure Block(L:integer); forward;

procedure Constant(var c,t:integer);
var i,s:integer;
begin
 if (CurrentSymbol=TokStrC) and (CurrentStringLength=1) then begin
  c:=ord(CurrentString[1]);
  t:=TypeCHAR;
 end else begin
  if CurrentSymbol=TokPlus then begin
   GetSymbol;
   s:=1;
  end  else if CurrentSymbol=TokMinus then begin
   GetSymbol;
   s:=-1;
  end else begin
   s:=0;
  end;
  if CurrentSymbol=TokIdent then begin
   i:=Position;
   if Identifiers[i].Kind<>IdCONST then begin
    Error(130);
   end;
   c:=Identifiers[i].Value;
   t:=Identifiers[i].TypeDefinition;
  end else if CurrentSymbol=TokNumber then begin
   c:=CurrentNumber;
   t:=TypeINT;
  end else begin
   Error(131);
  end;
  if s<>0 then begin
   MustBe(t,TypeINT);
   c:=c*s;
  end;
 end;
 GetSymbol;
end;

procedure ConstDeclaration;
var a:TAlfa;
    t,c:integer;
begin
 a:=CurrentIdentifer;
 GetSymbol;
 Expect(TokEql);
 Constant(c,t);
 Expect(TokSemi);
 EnterSymbol(A,IdCONST,t);
 Identifiers[IdentifierPosition].Value:=c;
end;

procedure TypeDefinition(var t:integer); forward;

procedure ArrayType(var t:integer);
var x:integer;
begin
 Types[t].Kind:=KindARRAY;
 GetSymbol;
 Constant(Types[t].StartIndex,x);
 MustBe(TypeINT,x);
 Expect(TokColon);
 Constant(Types[t].EndIndex,x);
 MustBe(TypeINT,x);
 if Types[t].StartIndex>Types[t].EndIndex then begin
  Error(132);
 end;
 if CurrentSymbol=TokComma then begin
  ArrayType(Types[t].SubType);
 end else begin
  Expect(TokRBracket);
  Expect(SymOF);
  TypeDefinition(Types[t].SubType);
 end;
 Types[t].Size:=(Types[t].EndIndex-Types[t].StartIndex+1)*Types[Types[t].SubType].Size;
end;

procedure TypeDefinition(var t:integer);
var i,j,Size,FieldType:integer;
begin
 if CurrentSymbol=SymPACKED then begin
  GetSymbol;
 end; 
 if CurrentSymbol=TokIdent then begin
  i:=Position;
  if Identifiers[i].Kind<>IdTYPE then begin
   Error(133);
  end;
  t:=Identifiers[i].TypeDefinition;
  GetSymbol;
 end else begin
  if TypePosition=MaximalTypes then begin
   Error(134);
  end;
  TypePosition:=TypePosition+1;
  t:=TypePosition;
  if CurrentSymbol=SymARRAY then begin
   GetSymbol;
   Check(TokLBracket);
   ArrayType(t);
  end else begin
   Expect(SymRECORD);
   if CurrentLevel=MaximalList then begin
    Error(135);
   end;
   CurrentLevel:=CurrentLevel+1;
   SymbolNameList[CurrentLevel]:=0;
   Check(TokIdent);
   Size:=0;
   repeat
    EnterSymbol(CurrentIdentifer,IdFIELD,0);
    i:=IdentifierPosition;
    GetSymbol;
    while CurrentSymbol=TokComma do begin
     GetSymbol;
     Check(TokIdent);
     EnterSymbol(CurrentIdentifer,IdFIELD,0);
     GetSymbol;
    end;
    j:=IdentifierPosition;
    Expect(TokColon);
    TypeDefinition(FieldType);
    repeat
     Identifiers[i].TypeDefinition:=FieldType;
     Identifiers[i].Offset:=Size;
     Size:=Size+Types[FieldType].Size;
     i:=i+1;
    until i>j;
    if CurrentSymbol=TokSemi then begin
     GetSymbol;
    end else begin
     Check(SymEND);
    end;
   until CurrentSymbol<>TokIdent;
   Types[t].Size:=Size;
   Types[t].Kind:=KindRECORD;
   Types[t].Fields:=SymbolNameList[CurrentLevel];
   CurrentLevel:=CurrentLevel-1;
   Expect(SymEND);
  end;
 end;
end;

procedure TypeDeclaration;
var a:TAlfa;
    t:integer;
begin
 a:=CurrentIdentifer;
 GetSymbol;
 Expect(TokEql);
 TypeDefinition(t);
 Expect(TokSemi);
 EnterSymbol(a,IdTYPE,t);
end;

procedure VarDeclaration;
var p,q,t:integer;
begin
 EnterSymbol(CurrentIdentifer,IdVAR,0);
 p:=IdentifierPosition;
 GetSymbol;
 while CurrentSymbol=TokComma do begin
  GetSymbol;
  Check(TokIdent);
  EnterSymbol(CurrentIdentifer,IdVAR,0);
  GetSymbol;
 end;
 q:=IdentifierPosition;
 Expect(TokColon);
 TypeDefinition(t);
 Expect(TokSemi);
 repeat
  Identifiers[p].VariableLevel:=CurrentLevel;
  StackPosition:=StackPosition-Types[t].Size;
  Identifiers[p].TypeDefinition:=t;
  Identifiers[p].VariableAddress:=StackPosition;
  Identifiers[p].ReferencedParameter:=false;
  p:=p+1;
 until p>q;
end;

procedure NewParameter(var p,LocalStackPosition:integer);
var r:boolean;
    t:integer;
begin
 if CurrentSymbol=SymVAR then begin
  r:=true;
  GetSymbol;
 end else begin
  r:=false;
 end;
 Check(TokIdent);
 p:=IdentifierPosition;
 EnterSymbol(CurrentIdentifer,IdVAR,0);
 GetSymbol;
 while CurrentSymbol=TokComma do begin
  GetSymbol;
  Check(TokIdent);
  EnterSymbol(CurrentIdentifer,IdVAR,0);
  GetSymbol;
 end;
 Expect(TokColon);
 Check(TokIdent);
 TypeDefinition(t);
 while p<IdentifierPosition do begin
  p:=p+1;
  Identifiers[p].TypeDefinition:=t;
  Identifiers[p].ReferencedParameter:=r;
  if r then begin
   LocalStackPosition:=LocalStackPosition+4;
  end else begin
   LocalStackPosition:=LocalStackPosition+Types[t].Size;
  end;
 end;
end;

procedure FunctionDeclaration(IsFunction:boolean);
var f,p,LocalStackPosition,P1,P2,OldStackPosition:integer;
begin
 GetSymbol;
 Check(TokIdent);
 FunctionDeclarationIndex:=-1;
 EnterSymbol(CurrentIdentifer,IdFUNC,0);
 GetSymbol;
 f:=IdentifierPosition;
 Identifiers[f].FunctionLevel:=CurrentLevel;
 Identifiers[f].FunctionAddress:=CodeLabel;
 EmitOpcode(OPJmp,0);
 if CurrentLevel=MaximalList then begin
  Error(136);
 end;
 CurrentLevel:=CurrentLevel+1;
 SymbolNameList[CurrentLevel]:=0;
 LocalStackPosition:=4;
 OldStackPosition:=StackPosition;
 if CurrentSymbol=TokLParent then begin
  repeat
   GetSymbol;
   NewParameter(p,LocalStackPosition);
  until CurrentSymbol<>TokSemi;
  Expect(TokRParent);
 end;
 if CurrentLevel>1 then begin
  StackPosition:=-4;
 end else begin
  StackPosition:=0;
 end;
 Identifiers[f].ReturnAddress:=LocalStackPosition;
 p:=f;
 while p<IdentifierPosition do begin
  p:=p+1;
  if Identifiers[p].ReferencedParameter then begin
   LocalStackPosition:=LocalStackPosition-4;
  end else begin
   LocalStackPosition:=LocalStackPosition-Types[Identifiers[p].TypeDefinition].Size;
  end;
  Identifiers[p].VariableLevel:=CurrentLevel;
  Identifiers[p].VariableAddress:=LocalStackPosition;
 end;
 if IsFunction then begin
  Expect(TokColon);
  Check(TokIdent);
  TypeDefinition(Identifiers[f].TypeDefinition);
  if Types[Identifiers[f].TypeDefinition].Kind<>KindSIMPLE then begin
   Error(137);
  end;
 end;
 Expect(TokSemi);
 Identifiers[f].LastParameter:=IdentifierPosition;
 if CurrentSymbol<>SymFORWARD then begin
  if FunctionDeclarationIndex>=0 then begin
   P1:=FunctionDeclarationIndex+1;
   P2:=f+1;
   while P1<=Identifiers[FunctionDeclarationIndex].LastParameter do begin
    if P2>Identifiers[f].LastParameter then begin
     Error(138);
    end;
    if not StringCompare(Identifiers[P1].Name,Identifiers[P2].Name) then begin
     Error(139);
    end;
    if Identifiers[P1].TypeDefinition<>Identifiers[P2].TypeDefinition then begin
     Error(140);
    end;
    if Identifiers[P1].ReferencedParameter<>Identifiers[P2].ReferencedParameter then begin
     Error(141);
    end;
    P1:=P1+1;
    P2:=P2+1;
   end;
   if P2<=Identifiers[f].LastParameter then begin
    Error(142);
   end;
  end;
  Identifiers[f].Inside:=true;
  Block(Identifiers[f].FunctionAddress);
  Identifiers[f].Inside:=false;
  EmitOpcode(OPExit,Identifiers[f].ReturnAddress-StackPosition);
 end else begin
  if FunctionDeclarationIndex>=0 then begin
   Error(143);
  end;
  GetSymbol;
 end;
 CurrentLevel:=CurrentLevel-1;
 StackPosition:=OldStackPosition;
 Expect(TokSemi);
end;

procedure Block(L:integer);
var i,d,OldStackPosition,OldIdentPos:integer;
begin
 OldStackPosition:=StackPosition;
 OldIdentPos:=IdentifierPosition;
 while (CurrentSymbol=SymCONST) or (CurrentSymbol=SymTYPE) or (CurrentSymbol=SymVAR) or (CurrentSymbol=SymFUNC) or (CurrentSymbol=SymPROC) do begin
  if CurrentSymbol=SymCONST then begin
   GetSymbol;
   Check(TokIdent);
   while CurrentSymbol=TokIdent do begin
    ConstDeclaration;
   end;
  end else if CurrentSymbol=SymTYPE then begin
   GetSymbol;
   Check(TokIdent);
   while CurrentSymbol=TokIdent do begin
    TypeDeclaration;
   end;
  end else if CurrentSymbol=SymVAR then begin
   GetSymbol;
   Check(TokIdent);
   while CurrentSymbol=TokIdent do begin
    VarDeclaration;
   end;
  end else if (CurrentSymbol=SymFUNC) or (CurrentSymbol=SymPROC) then begin
   FunctionDeclaration(CurrentSymbol=SymFUNC);
  end;
 end;
 if L+1=CodeLabel then begin
  CodePosition:=CodePosition-1;
 end else begin
  Code[L+1]:=CodeLabel;
 end;
 if CurrentLevel=0 then begin
  EmitOpcode(OPAdjS,StackPosition);
 end else begin
  d:=StackPosition-OldStackPosition;
  StackPosition:=OldStackPosition;
  EmitOpcode(OPAdjS,d);
 end;
 Statement;
 if CurrentLevel<>0 then begin
  EmitOpcode(OPAdjS,OldStackPosition-StackPosition);
 end;
 i:=OldIdentPos+1;
 while i<=IdentifierPosition do begin
  if Identifiers[i].Kind=IdFUNC then begin
   if (Code[Identifiers[i].FunctionAddress]=OPJmp) and (Code[Identifiers[i].FunctionAddress+1]=0) then begin
    Error(144);
   end;
  end;
  i:=i+1;
 end;
 IdentifierPosition:=OldIdentPos;
end;

const OutputCodeDataMaximalSize=262144;

var OutputCodeData:array[1..OutputCodeDataMaximalSize] of char;
    OutputCodeDataSize:integer;

procedure EmitChar(c:char);
begin
 OutputCodeDataSize:=OutputCodeDataSize+1;
 if OutputCodeDataSize>OutputCodeDataMaximalSize then begin
  Error(146);
 end;
 OutputCodeData[OutputCodeDataSize]:=c;
end;

procedure EmitByte(B:integer);
begin
 EmitChar(chr(B));
end;

procedure EmitInt16(i:integer);
begin
 if i>=0 then begin
  EmitByte(i mod 256);
  EmitByte((i div 256) mod 256);
 end else begin
  i:=-(i+1);
  EmitByte(255-(i mod 256));
  EmitByte(255-((i div 256) mod 256));
 end;
end;

procedure EmitInt32(i:integer);
begin
 if i>=0 then begin
  EmitByte(i mod 256);
  EmitByte((i div 256) mod 256);
  EmitByte((i div 65536) mod 256);
  EmitByte(i div 16777216);
 end else begin
  i:=-(i+1);        
  EmitByte(255-(i mod 256));
  EmitByte(255-((i div 256) mod 256));
  EmitByte(255-((i div 65536) mod 256));
  EmitByte(255-(i div 16777216));
 end;
end;

function OutputCodeGetInt32(o:integer):integer;
begin
 if ord(OutputCodeData[o+3])<$80 then begin
  OutputCodeGetInt32:=ord(OutputCodeData[o])+(ord(OutputCodeData[o+1])*256)+(ord(OutputCodeData[o+2])*65536)+(ord(OutputCodeData[o+3])*16777216);
 end else begin
  OutputCodeGetInt32:=-(((255-ord(OutputCodeData[o]))+((255-ord(OutputCodeData[o+1]))*256)+((255-ord(OutputCodeData[o+2]))*65536)+((255-ord(OutputCodeData[o+3]))*16777216))+1);
 end;
end;

procedure OutputCodePutInt32(o,i:integer);
begin
 if i>=0 then begin
  OutputCodeData[o]:=chr(i mod 256);
  OutputCodeData[o+1]:=chr((i div 256) mod 256);
  OutputCodeData[o+2]:=chr((i div 65536) mod 256);
  OutputCodeData[o+3]:=chr(i div 16777216);
 end else begin
  i:=-(i+1);
  OutputCodeData[o]:=chr(255-(i mod 256));
  OutputCodeData[o+1]:=chr(255-((i div 256) mod 256));
  OutputCodeData[o+2]:=chr(255-((i div 65536) mod 256));
  OutputCodeData[o+3]:=chr(255-(i div 16777216));
 end;
end;

procedure WriteOutputCode;
var i:integer;
begin
 for i:=1 to OutputCodeDataSize do begin
  write(OutputCodeData[i]);
 end;
end;

type TOutputCodeString=array[1..255] of char;

procedure OutputCodeString(s:TOutputCodeString);
var i:integer;
begin
 for i:=1 to 255 do begin
  EmitChar(s[i]);
 end;
end;

{ab}
procedure EmitStubCode;
begin
  OutputCodeDataSize:=0;
  OutputCodeString(#127#69#76#70#2#1#1#0#0#0#0#0#0#0#0#0#2#0#62#0#1#0#0#0#240#0#160#0#0#0#0#0#64#0#0#0#0#0#0#0#248#4#0#0#0#0#0#0#0#0#0#0#64#0#56#0#2#0#64#0#6#0#3#0#1#0#0#0#6#0#0#0#0#0#0#0#0#0#0#0#0#0#96#0#0#0#0#0#0#0#96#0#0#0#0#0#235#0#0#0#0#0#0#0#235#0#0#0#0#0#0#0#0#0#32#0#0#0#0#0#1#0#0#0#5#0#0#0#240#0#0#0#0#0#0#0#240#0#160#0#0#0#0#0#240#0#160#0#0#0#0#0#225#3#0#0#0#0#0#0#225#3#0#0#0#0#0#0#0#0#32#0#0#0#0#0#60#61#62#0#60#61#62#0#60#61#62#0#61#0#0#85#3#160#0#245#0#160#0#39#1#160#0#211#1#160#0#60#2#160#0#81#2#160#0#213#2#160#0#62#3#160#0#73#3#160#0#60#61#61#61#61#61#62#0#0#0#0#0#0#233#189#3#0#0#87#86#85#84#82#81#83#80#72#137);
  OutputCodeString(#229#72#199#192#1#0#0#0#72#199#199#1#0#0#0#72#137#238#72#131#198#72#72#199#194#1#0#0#0#15#5#88#91#89#90#92#93#94#95#195#86#85#72#137#229#72#139#93#24#72#139#69#32#72#131#248#0#125#17#72#247#216#72#255#203#106#45#232#174#255#255#255#72#131#196#8#72#49#201#80#83#72#133#192#116#18#72#255#193#72#199#195#10#0#0#0#72#49#210#72#247#251#235#233#72#133#201#15#148#194#8#209#91#88#72#41#203#72#131#251#0#126#18#81#106#32#232#115#255#255#255#72#131#196#8#72#255#203#117#240#89#72#199#199#176#0#96#0#72#1#207#72#255#207#81#72#199#198#10#0#0#0#72#49#210#72#247#254#72#137#211#72#131#195#48#136#31#72#255#207#226#229#89#72#199#192#1#0#0#0#72#199#199#1#0#0#0#72#199#198#176#0#96#0#72#137#202#15#5#93#94#195#106#13#232#27#255#255#255#72#131#196#8#106#10#232#16#255#255#255#72#131#196#8#195#87#86#85#84#82#81#83#80#72#137#229#72#137#195#72#49#192#72#49#255);
  OutputCodeString(#72#199#198#188#0#96#0#72#199#194#1#0#0#0#15#5#72#133#219#15#148#195#8#28#37#190#0#96#0#88#91#89#90#92#93#94#95#195#128#60#37#189#0#96#0#0#117#13#232#183#255#255#255#198#4#37#189#0#96#0#1#195#232#227#255#255#255#72#49#192#138#4#37#188#0#96#0#232#154#255#255#255#195#232#206#255#255#255#87#86#85#84#82#81#83#80#72#137#229#72#199#193#1#0#0#0#128#60#37#190#0#96#0#1#117#83#128#60#37#188#0#96#0#0#116#17#128#60#37#188#0#96#0#32#119#7#232#95#255#255#255#235#219#128#60#37#188#0#96#0#45#117#8#72#247#217#232#75#255#255#255#72#49#219#138#28#37#188#0#96#0#128#251#48#114#23#128#251#57#119#18#72#107#192#10#72#131#235#48#72#1#216#232#39#255#255#255#235#218#72#247#233#72#137#4#36#88#91#89#90#92#93#94#95#195#232#74#255#255#255#106#123#232#20#254#255#255#72#131#196#8#72#49#219#138#28#37#188#0#96#0#83#106#1#232#48#254#255#255#72#131#196#16#106#32);
  OutputCodeString(#232#243#253#255#255#72#131#196#8#138#28#37#190#0#96#0#83#232#226#253#255#255#72#131#196#8#106#125#232#215#253#255#255#72#131#196#8#128#60#37#190#0#96#0#0#117#17#128#60#37#188#0#96#0#10#117#7#232#175#254#255#255#235#152#195#72#49#192#138#4#37#190#0#96#0#195#128#60#37#188#0#96#0#10#15#148#194#195#72#199#192#60#0#0#0#72#199#199#0#0#0#0#15#5#232#231#254#255#255#80#106#5#232#181#253#255#255#72#131#196#16#106#32#232#120#253#255#255#72#131#196#8#106#133#106#6#232#157#253#255#255#72#131#196#16#232#64#254#255#255#106#65#232#91#253#255#255#72#131#196#8#232#48#254#255#255#232#173#255#255#255#232#143#254#255#255#106#123#232#65#253#255#255#72#131#196#8#80#232#55#253#255#255#72#131#196#8#80#106#1#232#93#253#255#255#72#131#196#16#106#125#232#32#253#255#255#72#131#196#8#106#123#232#21#253#255#255#72#131#196#8#72#49#192#138#4#37#188#0#96#0#80#106#1#232#49#253#255#255#72#131#196#16#106#125);
  OutputCodeString(#232#244#252#255#255#72#131#196#8#72#49#210#232#60#255#255#255#106#123#232#225#252#255#255#72#131#196#8#82#106#1#232#7#253#255#255#72#131#196#16#106#125#232#202#252#255#255#72#131#196#8#232#10#255#255#255#106#123#232#186#252#255#255#72#131#196#8#80#232#176#252#255#255#72#131#196#8#80#106#1#232#214#252#255#255#72#131#196#16#106#125#232#153#252#255#255#72#131#196#8#232#240#254#255#255#72#199#192#1#0#0#0#232#100#254#255#255#232#198#253#255#255#106#123#232#120#252#255#255#72#131#196#8#80#232#110#252#255#255#72#131#196#8#106#32#232#99#252#255#255#72#131#196#8#80#106#1#232#137#252#255#255#72#131#196#16#106#125#232#76#252#255#255#72#131#196#8#232#163#254#255#255#72#199#192#249#255#255#255#80#106#4#232#102#252#255#255#72#131#196#16#232#0#0#0#0#72#199#198#191#0#96#0#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90);
  OutputCodeDataSize:=1233;
end;
 
{new}
procedure EmitEndingStub;
begin
  OutputCodeString(#0#46#115#121#109#116#97#98#0#46#115#116#114#116#97#98#0#46#115#104#115#116#114#116#97#98#0#46#100#97#116#97#0#46#116#101#120#116#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#27#0#0#0#1#0#0#0#3#0#0#0#0#0#0#0#176#0#96#0#0#0#0#0#176#0#0#0#0#0#0#0#59#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#33#0#0#0#1#0#0#0#6#0#0#0#0#0#0#0#240#0#160#0#0#0#0#0#240#0#0#0#0#0#0#0#225#3#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#17#0#0#0#3#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0);
  OutputCodeString(#209#4#0#0#0#0#0#0#39#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#2#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#120#6#0#0#0#0#0#0#104#4#0#0#0#0#0#0#5#0#0#0#41#0#0#0#8#0#0#0#0#0#0#0#24#0#0#0#0#0#0#0#9#0#0#0#3#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#224#10#0#0#0#0#0#0#109#2#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#3#0#1#0#176#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#3#0#2#0#240#0#160#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#4#0#241#255#0#0#0#0#0#0#0);
  OutputCodeString(#0#0#0#0#0#0#0#0#0#11#0#0#0#0#0#1#0#176#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#33#0#0#0#0#0#1#0#188#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#48#0#0#0#0#0#1#0#189#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#63#0#0#0#0#0#1#0#190#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#69#0#0#0#0#0#1#0#191#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#86#0#0#0#0#0#2#0#85#3#160#0#0#0#0#0#0#0#0#0#0#0#0#0#94#0#0#0#0#0#2#0#245#0#160#0#0#0#0#0#0#0#0#0#0#0#0#0#107#0#0#0#0#0#2#0#39#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#123#0#0#0#0#0#2#0#211#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#134#0#0#0#0#0#2#0#60#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#146#0#0#0#0#0);
  OutputCodeString(#2#0#81#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#161#0#0#0#0#0#2#0#213#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#171#0#0#0#0#0#2#0#62#3#160#0#0#0#0#0#0#0#0#0#0#0#0#0#178#0#0#0#0#0#2#0#73#3#160#0#0#0#0#0#0#0#0#0#0#0#0#0#186#0#0#0#0#0#1#0#227#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#195#0#0#0#0#0#2#0#178#4#160#0#0#0#0#0#0#0#0#0#0#0#0#0#210#0#0#0#0#0#2#0#75#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#235#0#0#0#0#0#2#0#80#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#7#1#0#0#0#0#2#0#103#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#39#1#0#0#0#0#2#0#140#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#65#1#0#0#0#0#2#0#123#1#160#0#0#0#0#0#0#0#0#0#0);
  OutputCodeString(#0#0#0#92#1#0#0#0#0#2#0#154#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#112#1#0#0#0#0#2#0#234#1#160#0#0#0#0#0#0#0#0#0#0#0#0#0#123#1#0#0#0#0#2#0#36#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#136#1#0#0#0#0#2#0#59#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#149#1#0#0#0#0#2#0#104#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#175#1#0#0#0#0#2#0#197#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#191#1#0#0#0#0#2#0#141#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#221#1#0#0#0#0#2#0#159#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#242#1#0#0#0#0#2#0#159#2#160#0#0#0#0#0#0#0#0#0#0#0#0#0#2#2#0#0#0#0#2#0#61#3#160#0#0#0#0#0#0#0#0#0#0#0#0#0#13#2#0#0#0#0#2#0#101#3#160#0);
  OutputCodeString(#0#0#0#0#0#0#0#0#0#0#0#0#19#2#0#0#0#0#2#0#168#3#160#0#0#0#0#0#0#0#0#0#0#0#0#0#25#2#0#0#0#0#2#0#101#4#160#0#0#0#0#0#0#0#0#0#0#0#0#0#31#2#0#0#0#0#2#0#202#4#160#0#0#0#0#0#0#0#0#0#0#0#0#0#39#2#0#0#0#0#2#0#209#4#160#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#4#0#241#255#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#57#2#0#0#16#0#241#255#0#1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#67#2#0#0#16#0#2#0#240#0#160#0#0#0#0#0#0#0#0#0#0#0#0#0#74#2#0#0#16#0#241#255#28#0#64#0#0#0#0#0#0#0#0#0#0#0#0#0#85#2#0#0#16#0#1#0#235#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#97#2#0#0#16#0#1#0#235#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#104#2#0);
  OutputCodeString(#0#16#0#1#0#240#0#96#0#0#0#0#0#0#0#0#0#0#0#0#0#0#98#101#114#111#110#101#119#46#111#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#66#117#102#102#101#114#0#82#101#97#100#67#104#97#114#66#117#102#102#101#114#0#82#101#97#100#67#104#97#114#73#110#105#116#101#100#0#73#115#69#79#70#0#82#84#76#70#117#110#99#116#105#111#110#84#97#98#108#101#0#82#84#76#72#97#108#116#0#82#84#76#87#114#105#116#101#67#104#97#114#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#0#82#84#76#87#114#105#116#101#76#110#0#82#84#76#82#101#97#100#67#104#97#114#0#82#84#76#82#101#97#100#73#110#116#101#103#101#114#0#82#84#76#82#101#97#100#76#110#0#82#84#76#69#79#70#0#82#84#76#69#79#76#78#0#79#108#100#83#116#97#99#107#0#83#116#117#98#69#110#116#114#121#80#111#105#110#116#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#78#111#116#83#105#103#110#101#100);
  OutputCodeString(#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#80#114#101#67#104#101#99#107#76#111#111#112#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#80#114#101#67#104#101#99#107#76#111#111#112#68#111#110#101#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#78#111#116#80#97#100#100#105#110#103#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#80#97#100#100#105#110#103#76#111#111#112#0#82#84#76#87#114#105#116#101#73#110#116#101#103#101#114#76#111#111#112#0#82#101#97#100#67#104#97#114#69#120#0#82#101#97#100#67#104#97#114#73#110#105#116#0#82#101#97#100#73#110#105#116#68#111#110#101#0#82#101#97#100#73#110#116#101#103#101#114#83#107#105#112#87#104#105#116#101#83#112#97#99#101#0#82#101#97#100#73#110#116#101#103#101#114#68#111#110#101#0#82#101#97#100#73#110#116#101#103#101#114#83#107#105#112#87#104#105#116#101#83#112#97#99#101#68#111#110#101#0#82#101#97#100#73#110#116#101#103#101#114#78);
  OutputCodeString(#111#116#83#105#103#110#101#100#0#82#101#97#100#73#110#116#101#103#101#114#76#111#111#112#0#82#101#97#100#76#110#68#111#110#101#0#84#101#115#116#49#0#84#101#115#116#50#0#84#101#115#116#51#0#80#114#101#112#97#114#101#0#80#114#111#103#114#97#109#69#110#116#114#121#80#111#105#110#116#0#104#101#97#112#95#115#105#122#101#0#95#115#116#97#114#116#0#115#116#97#99#107#95#115#105#122#101#0#95#95#98#115#115#95#115#116#97#114#116#0#95#101#100#97#116#97#0#95#101#110#100#0#255#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90#$90);
end;
 
{new}
const EndingStubSize=$2173;
        StartStubSize=$4fb;
        EndStubSize=$8f7;
        ElfHdrShoff_offs=$28;
        ElfHdrShoff_val0=$4f8;
        TextPhdrFilesz_offs=$7c;
        TextPhdrFilesz_val0=$3e1;
        TxtSectHdrSize_offs=$598;
        TxtSectHdrSize_val0=$3e1;
        ShSectHdrOffs_offs=$5d0;
        ShSectHdrOffs_val0=$4d1;
        SymSHdrOffs_val0=$678;
        StrSHdrOffs_val0=$ae0;        

	  locNone=0;

      locPushEAX=1;
      locPopEAX=2;
      locPopEBX=3;
      locIMulEBX=4;
      locXorEDXEDX=5;
      locIDivEBX=6;
      locPushEDX=7;
      locCmpEAXEBX=8;
      locMovzxEAXAL=9;
      locMovDWordPtrESPEAX=10;
      locJNZJNE0x03=11;
      locMovDWordPtrEBXEAX=12;
      locJmpDWordPtrESIOfs=13;
      locCallDWordPtrESIOfs=14;
      locXChgEDXESI=15;
      locPopESI=16;
      locMovECXImm=17;
      locCLD=18;
      locREPMOVSB=19;
      locTestEAXEAX=20;
      locNegDWordPtrESP=21;
      locMovEAXDWordPtrESP=22;
      locMovEBXDWordPtrFORStateCurrentValue=23;
      locCmpDWordPtrEBXEAX=24;
      locMovEAXDWordPtrFORStateDestValue=25;
      {new}
      locJNZJNE0x06=26;

var LastOutputCodeValue,PC:integer;

{=}
procedure OCPushEAX;
begin
 if LastOutputCodeValue=locPopEAX then begin
  if Code[PC]=OutputCodeDataSize then begin
   Code[PC]:=Code[PC]-1;
  end;
  if OutputCodeDataSize>0 then begin
   OutputCodeDataSize:=OutputCodeDataSize-1;
  end;
  LastOutputCodeValue:=locNone;
 end else begin
  EmitByte($50);
  LastOutputCodeValue:=locPushEAX;
 end;
end;

{=}
procedure OCPopEAX;
begin
 if LastOutputCodeValue=locPushEAX then begin
  if Code[PC]=OutputCodeDataSize then begin
   Code[PC]:=Code[PC]-1;
  end;
  if OutputCodeDataSize>0 then begin
   OutputCodeDataSize:=OutputCodeDataSize-1;
  end;
  LastOutputCodeValue:=locNone;
 end else begin
  EmitByte($58);
  LastOutputCodeValue:=locPopEAX;
 end;
end;

{=}
procedure OCPopEBX;
begin
 EmitByte($5b);
 LastOutputCodeValue:=locPopEBX;
end;

{ab}
procedure OCIMulEBX;
begin
 EmitByte($48); EmitByte($f7); EmitByte($eb);
 LastOutputCodeValue:=locIMulEBX;
end;

{ab}
procedure OCXorEDXEDX;
begin
 EmitByte($48); EmitByte($31); EmitByte($d2);
 LastOutputCodeValue:=locXorEDXEDX;
end;

{ab}
procedure OCIDIVEBX;
begin
 EmitByte($48); EmitByte($f7); EmitByte($fb);
 LastOutputCodeValue:=locIDivEBX;
end;

{=}
procedure OCPushEDX;
begin
 EmitByte($52);
 LastOutputCodeValue:=locPushEDX;
end;

{ab}
procedure OCCmpEAXEBX;
begin
 EmitByte($48); EmitByte($39); EmitByte($d8);
 LastOutputCodeValue:=locCmpEAXEBX;
end;

{ab}
procedure OCMovzxEAXAL;
begin
 EmitByte($48); EmitByte($0f); EmitByte($b6); EmitByte($c0);
 LastOutputCodeValue:=locMovzxEAXAL;
end;

{!}
procedure OCJNZJNE0x03;
begin
 EmitByte($75); EmitByte($03); {jnz $+0x5, not 0x03}
 LastOutputCodeValue:=locJNZJNE0x03;
end;

{new}
{http://stackoverflow.com/questions/20730731/syntax-of-short-jmp-instruction}
procedure OCJNZJNE0x06;
begin
 EmitByte($75); EmitByte($04); {jmp $+0x6}
 LastOutputCodeValue:=locJNZJNE0x06;
end;

{ab}
procedure OCMovDWordPtrESPEAX;
begin
 EmitByte($48); EmitByte($89); EmitByte($04); EmitByte($24);
 LastOutputCodeValue:=locMovDWordPtrESPEAX;
end;

{ab}
procedure OCMovDWordPtrEBXEAX;
begin
 EmitByte($48); EmitByte($89); EmitByte($03);
 LastOutputCodeValue:=locMovDWordPtrEBXEAX;
end;

{=}
procedure OCJmpDWordPtrESIOfs(Ofs:integer);
begin
 EmitByte($ff); EmitByte($66); EmitByte(Ofs);
 LastOutputCodeValue:=locJmpDWordPtrESIOfs;
end;

{=}
procedure OCCallDWordPtrESIOfs(Ofs:integer);
begin
 EmitByte($ff); EmitByte($56); EmitByte(Ofs);
 LastOutputCodeValue:=locCallDWordPtrESIOfs;
end;

{ab}
procedure OCXChgEDXESI;
begin
 EmitByte($48); EmitByte($87); EmitByte($f2);
 LastOutputCodeValue:=locXChgEDXESI;
end;

{=}
procedure OCPopESI;
begin
 EmitByte($5e);
 LastOutputCodeValue:=locPopESI;
end;

{ab}
procedure OCMovECXImm(Value:integer);
begin
 EmitByte($48); EmitByte($c7); EmitByte($c6); EmitInt32(Value);
 LastOutputCodeValue:=locMovECXImm;
end;

{=}
procedure OCCLD;
begin
 EmitByte($fc);
 LastOutputCodeValue:=locCLD;
end;

{=}
procedure OCREPMOVSB;
begin
 EmitByte($f3); EmitByte($a4);
 LastOutputCodeValue:=locREPMOVSB;
end;

{ab}
procedure OCTestEAXEAX;
begin
 EmitByte($48); EmitByte($85); EmitByte($c0); { TEST EAX,EAX }
 LastOutputCodeValue:=locTestEAXEAX;
end;

{ab}
procedure OCNegDWordPtrESP;
begin
 EmitByte($48); EmitByte($f7); EmitByte($1c); EmitByte($24); { NEG DWORD PTR [ESP] }
 LastOutputCodeValue:=locNegDWordPtrESP;
end;

{ab}
procedure OCMovEAXDWordPtrESP;
begin
 EmitByte($48); EmitByte($8b); EmitByte($04); EmitByte($24); { MOV EAX,DWORD PTR [ESP] }
 LastOutputCodeValue:=locMovEAXDWordPtrESP;
end;

{-}
procedure OCMovEBXDWordPtrFORStateCurrentValue;
begin
 EmitByte($8b); EmitByte($5d); EmitByte($04); {mov    eax,DWORD PTR [ebp+0x4]}
 LastOutputCodeValue:=locMovEBXDWordPtrFORStateCurrentValue;
end;

{ab}
procedure OCCmpDWordPtrEBXEAX;
begin
 EmitByte($48); EmitByte($39); EmitByte($03);
 LastOutputCodeValue:=locCmpDWordPtrEBXEAX;
end;

{-}
procedure OCMovEAXDWordPtrFORStateDestValue;
begin
 EmitByte($8b); EmitByte($45); EmitByte($08); {mov    eax,DWORD PTR [ebp+0x8]}
 LastOutputCodeValue:=locMovEAXDWordPtrFORStateDestValue;
end;

var JumpTable:array[1..MaximalCodeSize] of integer;

procedure AssembleAndLink;
var InjectionSize,CountJumps,Opcode,Value,Index,PEEXECodeSize,PEEXESectionVirtualSize,PEEXESectionAlignment,PEEXECodeStart:integer;
begin
 EmitStubCode;
 PEEXECodeStart:=OutputCodeDataSize;
 LastOutputCodeValue:=locNone;
 PC:=0;
 CountJumps:=0;

{new}
 EmitEndingStub;


  {new}
  InjectionSize:=OutputCodeDataSize-EndStubSize-PEEXECodeStart;

  {1}
  {ElfHdr.e_shoff, 8b}
  {patch high part with 4bytes of value. optmistically cuz of midlevel code in x32}
  OutputCodePutInt32($28 + $1, 		ElfHdrShoff_val0 + InjectionSize);
  {patch low 4bytes with nulls cuz of little endian}
  OutputCodePutInt32($28 + $1 + $4, 0);
  
  {2}
  {new}
  {TextPhdr.p_filesz, 4b}
  OutputCodePutInt32($98 + $1, TextPhdrFilesz_val0 + InjectionSize);

  {3}
  {new}
  {TextSectionHdr.size, 8b}
  {it flows forward as InjectionSize increases}
  OutputCodePutInt32($598 + $1 + InjectionSize, 	 TxtSectHdrSize_val0 + InjectionSize);
  OutputCodePutInt32($598 + $1 + InjectionSize + $4, 0);
  
  {4}
  {new}
  {ShstrtabSectionHdr.offs, 8b}
  OutputCodePutInt32($5d0 + $1 + InjectionSize, 	 ShSectHdrOffs_val0 + InjectionSize);
  OutputCodePutInt32($5d0 + $1 + InjectionSize + $4, 0);

  {4}
  {new}
  {SymtabSectionHdrOffs.offs, 8b}
  OutputCodePutInt32($610 + $1 + InjectionSize, 	 SymSHdrOffs_val0 + InjectionSize);
  OutputCodePutInt32($610 + $1 + InjectionSize + $4, 0);
  
 { Patch jumps + calls }
 {for Index:=1 to CountJumps do begin
  Value:=JumpTable[Index];
  OutputCodePutInt32(Value,((Code[OutputCodeGetInt32(Value)]-Value)-3));
 end;}

 { Size Of Code }
 {PEEXECodeSize:=OutputCodeGetInt32($29)+(OutputCodeDataSize-PEEXECodeStart);
 OutputCodePutInt32($29,PEEXECodeSize);}

 { Get section alignment }
 {PEEXESectionAlignment:=OutputCodeGetInt32($45);}

 { Calculate and patch section virtual size }
 {PEEXESectionVirtualSize:=PEEXECodeSize;
 if PEEXESectionAlignment<>0 then begin
  Value:=PEEXECodeSize mod PEEXESectionAlignment;
  if Value<>0 then begin
   PEEXESectionVirtualSize:=PEEXESectionVirtualSize+(PEEXESectionAlignment-Value);
  end;
 end;
 OutputCodePutInt32($10d,PEEXESectionVirtualSize);}

 { Calculate and patch image size }
 {OutputCodePutInt32($5d,PEEXESectionVirtualSize+OutputCodeGetInt32($39));}

 { Patch section raw size }
 {OutputCodePutInt32($115,OutputCodeGetInt32($115)+(OutputCodeDataSize-PEEXECodeStart));}

 WriteOutputCode;
end;

begin
 StringCopy(Keywords[SymBEGIN],'BEGIN               ');
 StringCopy(Keywords[SymEND],'END                 ');
 StringCopy(Keywords[SymIF],'IF                  ');
 StringCopy(Keywords[SymTHEN],'THEN                ');
 StringCopy(Keywords[SymELSE],'ELSE                ');
 StringCopy(Keywords[SymWHILE],'WHILE               ');
 StringCopy(Keywords[SymDO],'DO                  ');
 StringCopy(Keywords[SymCASE],'CASE                ');
 StringCopy(Keywords[SymREPEAT],'REPEAT              ');
 StringCopy(Keywords[SymUNTIL],'UNTIL               ');
 StringCopy(Keywords[SymFOR],'FOR                 ');
 StringCopy(Keywords[SymTO],'TO                  ');
 StringCopy(Keywords[SymDOWNTO],'DOWNTO              ');
 StringCopy(Keywords[SymNOT],'NOT                 ');
 StringCopy(Keywords[SymDIV],'DIV                 ');
 StringCopy(Keywords[SymMOD],'MOD                 ');
 StringCopy(Keywords[SymAND],'AND                 ');
 StringCopy(Keywords[SymOR],'OR                  ');
 StringCopy(Keywords[SymCONST],'CONST               ');
 StringCopy(Keywords[SymVAR],'VAR                 ');
 StringCopy(Keywords[SymTYPE],'TYPE                ');
 StringCopy(Keywords[SymARRAY],'ARRAY               ');
 StringCopy(Keywords[SymOF],'OF                  ');
 StringCopy(Keywords[SymPACKED],'PACKED              ');
 StringCopy(Keywords[SymRECORD],'RECORD              ');
 StringCopy(Keywords[SymPROGRAM],'PROGRAM             ');
 StringCopy(Keywords[SymFORWARD],'FORWARD             ');
 StringCopy(Keywords[SymHALT],'HALT                ');
 StringCopy(Keywords[SymFUNC],'FUNCTION            ');
 StringCopy(Keywords[SymPROC],'PROCEDURE           ');

 Types[TypeINT].Size:=4;
 Types[TypeINT].Kind:=KindSIMPLE;
 Types[TypeCHAR].Size:=4;
 Types[TypeCHAR].Kind:=KindSIMPLE;
 Types[TypeBOOL].Size:=4;
 Types[TypeBOOL].Kind:=KindSIMPLE;
 Types[TypeSTR].Size:=0;
 Types[TypeSTR].Kind:=KindSIMPLE;
 TypePosition:=4;

 SymbolNameList[-1]:=0;
 CurrentLevel:=-1;
 IdentifierPosition:=0;

 EnterSymbol('FALSE               ',IdCONST,TypeBOOL);
 Identifiers[IdentifierPosition].Value:=ord(false);

 EnterSymbol('TRUE                ',IdCONST,TypeBOOL);
 Identifiers[IdentifierPosition].Value:=ord(true);

 EnterSymbol('MAXINT              ',IdCONST,TypeINT);
 Identifiers[IdentifierPosition].Value:=2147483647;

 EnterSymbol('INTEGER             ',IdTYPE,TypeINT);
 EnterSymbol('CHAR                ',IdTYPE,TypeCHAR);
 EnterSymbol('BOOLEAN             ',IdTYPE,TypeBOOL);

 EnterSymbol('CHR                 ',IdFUNC,TypeCHAR);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunCHR;
 Identifiers[IdentifierPosition].Inside:=false;

 EnterSymbol('ORD                 ',IdFUNC,TypeINT);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunORD;
 Identifiers[IdentifierPosition].Inside:=false;

 EnterSymbol('WRITE               ',IdFUNC,0);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunWRITE;

 EnterSymbol('WRITELN             ',IdFUNC,0);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunWRITELN;

 EnterSymbol('READ                ',IdFUNC,0);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunREAD;

 EnterSymbol('READLN              ',IdFUNC,0);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunREADLN;

 EnterSymbol('EOF                 ',IdFUNC,TypeBOOL);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunEOF;
 Identifiers[IdentifierPosition].Inside:=false;

 EnterSymbol('EOLN                ',IdFUNC,TypeBOOL);
 Identifiers[IdentifierPosition].FunctionLevel:=-1;
 Identifiers[IdentifierPosition].FunctionAddress:=FunEOFLN;
 Identifiers[IdentifierPosition].Inside:=false;

 SymbolNameList[0]:=0;
 CurrentLevel:=0;

 CurrentLine:=1;
 CurrentColumn:=0;

 ReadChar;
 GetSymbol;
 IsLabeled:=true;
 CodePosition:=0;
 LastOpcode:=-1;
 StackPosition:=4;
 Expect(SymPROGRAM);
 Expect(TokIdent);
 Expect(TokSemi);
 EmitOpcode(OPJmp,0);
 Block(0);
 EmitOpcode2(OPHalt);
 Check(TokPeriod);
 AssembleAndLink;
end.
