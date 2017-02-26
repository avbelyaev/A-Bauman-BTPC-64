program RTLWriteTest;

const SigLen=5;

type TSignature = array[1..SigLen] of integer;
    struct=record
      A:integer;
      B:boolean;
      C:char;
     end;
      StructArr = array[1..SigLen] of struct;


var arr:TSignature;
    starr:StructArr;
    sigArr:TSignature;
    i,a,b:integer;

procedure structArrayProc(m:StructArr);
begin
  i:=1;
  while i <= 3 do begin
    WriteLn(m[i].A,' ',m[i].C);
    i:=i+1;
  end;
end;

procedure arrayProc(m:TSignature);
begin
  i:=1;
  while i <= 3 do begin
    Write(m[i],' ');
    i:=i+1;
  end;

  i:=1;
  while i <= 3 do begin
    m[i]:=i;
    i:=i+1;
  end;

  m[2]:=3;

  i:=1;
  while i <= 3 do begin
    Write(m[i],' ');
    i:=i+1;
  end;
end;


procedure x;
  procedure y;

  begin
    for a:=1 to 3 do begin
      for b:=3 downto 1 do begin
        WriteLn(a:5, b:5);
      end; 
    end;
  end;

  begin
  y;
end;

begin
  sigArr[1]:=1;
  sigArr[2]:=2;
  sigArr[3]:=1337;
  arrayProc(sigArr);

  starr[1].A:=1;
  starr[1].C:='X';
  starr[2].A:=2;
  starr[2].C:='Y';
  starr[3].A:=1337;
  starr[3].C:='Z';
  structArrayProc(starr);
  x;
end.
