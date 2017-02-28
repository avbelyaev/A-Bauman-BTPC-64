program RTLWriteTest;

type TSignature = array[1..5] of integer;

var a,i:integer;
    m:TSignature;

begin

  i:=1;
  while i <= 3 do begin
    Read(a);
    WriteLn('->', a);
    m[i]:=a;
    i:=i+1;
  end;

  i:=1;
  while i <= 3 do begin
    WriteLn(m[i]);
    i:=i+1;
  end;
end.
