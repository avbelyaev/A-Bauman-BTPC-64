program RTLWriteTest;

const b=1337;

var a,i:integer;
	c:char;
	isTrue:boolean;
begin
  a:=3+5;
  Write('<[');
  i:=0;
  {simple cycle}
  while i < 5 do begin
    write(i, ', ');
    i:=i+1;
  end;

  {more complex cond}
  while (i mod 10) <> 0 do begin
    write(i, '. ');
    i:=i+1;
  end;

  {simple branching}
  if (a <= 8) then begin
    a:=7;
  end else begin
    a:=8;
  end;

  {netsed if and assign}
  if a <> 0 then begin
    if i <> 0 then begin
      i:=1;
    end else begin
      i:=-1;
    end;
    a:=1;
    while i <> (4*4) do begin
      write(i, '_');
      i:=i*2;
    end;
  end;

  {cond nested into cycle}
  isTrue:=true;
  while (isTrue) do begin
    write(a, '-');
    a:=a+1;
    if a=4 then begin
      isTrue:=false;
    end;
  end;
  
  Write(' a: ',a,' i: ',i);
  WriteLn(']>');
end.
