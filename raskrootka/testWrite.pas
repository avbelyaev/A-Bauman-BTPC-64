program RTLWriteTest;

const b=1337;

var a,i:integer;
	c:char;
begin
  a:=3+5;
  {WriteLn('====== RTL Write ======');}
  {Write}
  {int}
  Write(a);
  {const}
  Write(b);
  {after assign}
  c:='C';
  i:=1;
  Write(a, ' ');
  {after some calc}
  a:=a*(5-2)+1 div 2;
  Write(a, ' ');
  {char}
  Write(c);

  {writeln}
  {int}
  WriteLn(a);
  {hard string}
  WriteLn('hardcoded string');
  {char}
  WriteLn(c);
  {hard string + int}
  WriteLn('strInt:', a);
  {hard str + char}
  WriteLn('strChar:', c);
  {str + int + str}
  WriteLn('strInt:', a, ':afk');

end.
