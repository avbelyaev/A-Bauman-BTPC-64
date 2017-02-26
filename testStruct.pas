program RTLWriteTest;

{const SigLen=7;

type TSignature = array[1..SigLen] of integer;

  struct=record
      A:integer;
      B:boolean;
      C:char;
     end;

var i:integer;
    arr:TSignature;

procedure arrayProc(sig: TSignature; x,y:integer);
var cur: char;
    jnt: integer;
begin
  sig[x]:=y;
end;
}
var a:array[1..3] of integer;
    i:integer;
begin
  a[1]:=5;
  
  i:=1;
  while i <= 3 do begin
    a[i]:=i;
    i:=i+1;
  end;
  {arrayProc(arr, 3, -3);
  arrayProc(arr, 4, -arr[3]);}
  i:=2*2;
  i:=i*5;

  a[2]:=3;

  i:=i*0+1;
  while i <= 3 do begin
    Write(a[i],' ');
    i:=i+1;
  end;
end.
