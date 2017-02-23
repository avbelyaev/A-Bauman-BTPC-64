program RTLWriteTest;

const CST=1337;

var a,b,c,d,e,f:integer;

begin
  Write('<[ ');

  {basic math}
  a:=3+5;
  b:=1+a;
  c:=a+b+0-1;
  Write(a,' ',b,' ',c,' ');

  {mul}
  d:=a*1;
  Write('d: ',d,' ');
  d:=a*a;
  Write(d,' ');
  d:=(((( a* ((1+2)*3) *2))));
  Write(d,' ');

  {div mod}
  e:=d div 3;
  Write('e: ',e,' ');
  e:=c mod 5;
  Write(e,' ');

  {complex}
  f:=a+b*((c-e) div (2 mod 3)) + (-e) + CST div 1000;
  Write('f: ', f);

  WriteLn(' ]>');
  {btpcwin.exe <testArifm.pas >testnorm.exe && type testnorm.exe && testnorm.exe}
  {/mnt/c/Users/anthony/Documents/Dropbox/berowin}
end.
