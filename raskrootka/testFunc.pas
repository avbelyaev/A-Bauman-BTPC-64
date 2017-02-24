program RTLWriteTest;

var a:integer;

procedure complexNestedProc(c:char;i:integer);
var b:integer;
begin
  Write('      complexNestedProc { ', c);
  c:='A';
  b:=i*2;
  WriteLn(' ',c,' ',b,' }');
end;

procedure nestedProc(s:integer);
begin
  WriteLn('    nestedProc { ',s+1);
  complexNestedProc('N', s);
  WriteLn('    }');
end;

procedure simpleProc(s:integer);
begin
  WriteLn('  simpleProc { ');
  nestedProc(s);
  WriteLn('  }');
end;

procedure writeOnly(c:char);
begin
  Write(c);
end;

function nestedFunc(var f:integer):char;
var x:integer;
    b:boolean;
begin
  Write('    nestedFunc {...} ');
  x:=f-1;
  if x > 10 then begin
    nestedFunc:='A';
  end else begin
    nestedFunc:='B';
  end;
end;

function simpleFunc:integer;
var x:integer;
    c:char;
begin
  x:=10;
  Write('  simpleFunc { ');
  c:='X';
  Write('cBefore: ', c);
  c:=nestedFunc(x);
  Write(', cAfter: ', c);
  simpleFunc:=5;
  WriteLn('  }');
end;

begin
  a:=3;
  WriteLn('main {');
  
  simpleProc(a+1);
  
  WriteLn('aBefore: ', a);
  a:=simpleFunc;
  WriteLn('aAfter: ',a);

  WriteLn('}');
end.
