unit crt2;
interface

uses crt,dos;
var mode_video,column,page_disp,attrib:byte;
const nbwindows =9;
var Winreftable:array [1..nbwindows,1..4] of byte;
const activewindow:byte=0;
xtextlimit:byte=80;
ytextlimit:byte=25;
frame:boolean=false;
var scrn_char:char;
const textwindowsize = 2000;
type azione=(save,load);
     obj=(win,background);
var windowbuffer:array[1..3,1..nbwindows,1..textwindowsize] of byte;
type filespec=string[40];
type notcarattertype=set of char;
type charok=set of char;
type coord = array[1..30] of byte;
type lunterm = array[1..30] of byte;

procedure getvideo;

Procedure setcursor(inizio,fine:integer);

Procedure CsrOn;

procedure CsrOff;

procedure Locate(n,colonna,riga:integer);

procedure writeat(ch:char;n,m:integer);

procedure Readscreen;

procedure Writeattribute(n:integer;ch:char;attr:byte);

procedure CopyPage(n1,n2:byte);

procedure DispPage(n:byte);

procedure Scroll(verso:boolean;linecount,attr,x1,y1,x2,y2:integer);

procedure deftextwindow(numero,x1,y1,x2,y2:byte);

procedure seltextwindow(numero:byte);

function textwindowselected(numero:byte):boolean;

procedure gonextwin;

procedure gopredwin;

procedure paintwindow(numero,colore:byte);

procedure keeptextwindow(scopo:azione;oggetto:obj);

procedure changetextwindow(oggetto:obj);

procedure movetextwindow(deltax,deltay:integer);

procedure frametextwindow(colore,tratto:byte);

procedure selframedwindow;

procedure scrollwindow(verso:boolean;linecount,attr:integer);

function spaces(n:byte):string;

function tab(n:byte):string;

function freememamount:longint;

procedure bsave(segmento,offset,lunghezza:word;userfile:filespec);

procedure bload(segmento,offset,lunghezza:word;userfile:filespec);

procedure bsavebas(segmento,offset,lunghezza:word;userfile:filespec);

procedure bloadbas(userfile:filespec);

procedure beep;

function inputctext(pos_x,pos_y,lunmax:integer;c,d:notcarattertype;e:charok;f:char):string;

function inputtab(x,y:coord;lunmax:lunterm;c,d:notcarattertype;e:charok;f:integer):string;

procedure fileinfo(nomefile:string;var filebytes:longint;
var anno,mese,giorno,ora,min,sec:byte;var attrlist:string);

function strings(n:integer;r:char):string;

function c_text(s:string;n:integer):string;

function c_instring(a:string):string;

function inkeys:char;

implementation


procedure getvideo;
var reg:registers;
begin
reg.AX:=$0F00;
intr($10,reg);
mode_video:=Lo(reg.AX);
column:=Hi(reg.AX);
page_disp:=Hi(reg.BX);
end;

procedure setcursor(inizio,fine:integer);
var reg:registers;
begin
reg.ax:=$0100;
reg.cx:=inizio shl 8 or fine;
intr($10,reg);
end;

procedure CsrOn;
var reg:registers;
line_set:integer;
begin
getvideo;
case mode_video of
0..3 :line_set:=$0607;
7:line_set:=$0C0D;
end;
reg.ax:=$0100;
reg.cx:=line_set;
intr($10,reg);
end;

procedure Csroff;
var reg:registers;
line_set:integer;
begin
getvideo;
case mode_video of
0..3:line_set:=$2007;
7:line_set:=$200D;
end;
reg.ax:=$0100;
reg.cx:=line_set;
intr($10,reg);
end;

procedure locate(n,colonna,riga:integer);
var reg:registers;
begin
getvideo;
if mode_video in [0..3] then
begin
reg.ax:=$0200;
reg.bx:=n shl 8;
colonna:=colonna-1;riga:=riga-1;
reg.dx:=riga shl 8 or colonna;
intr($10,reg);
end;
end;

procedure writeat(ch:char;n,m:integer);
var reg:registers;
begin
getvideo;
if mode_video in [0..3] then
begin
reg.ax:=$0a00 or ord(ch);
reg.bx:=n shl 8;
reg.cx:=m;
intr($10,reg);
end;
end;

procedure beep;
begin
sound(800);
delay(250);
nosound;
end;













procedure Readscreen;
var reg:registers;
begin
reg.ax:=$0800;
reg.bx:=0;
intr($10,reg);
scrn_char:=chr(Lo(reg.ax));
attrib:=Hi(reg.ax);
end;

procedure writeattribute(n:integer;ch:char;attr:byte);
var reg:registers;
begin
reg.ax:=$0900;
reg.bx:=(n shl 8) or attr;
reg.cx:=1;
intr($10,reg);
end;


procedure copypage(n1,n2:byte);
type buffervideo40 = array[0..7,1..2048] of byte;
     buffervideo80 = array[0..3,1..4096] of byte;
var display40:buffervideo40 absolute $B800:0;
    display80:buffervideo80 absolute $B800:0;
    begin
    getvideo;
    if mode_video in [0..3] then
    case column of
    40:begin
            display40[n2]:=display40[n1];
            end;
    80:begin
            display80[n2]:=display80[n2];
            end;
      end;
 end;

 procedure disppage(n:byte);
 var reg:registers;
 begin
 getvideo;
 if mode_video in[0..3] then
 begin
 reg.ax:=$0500 or n;
 intr($10,reg);
 end;
 end;


 procedure scroll(verso:boolean;linecount,attr,x1,y1,x2,y2:integer);
 var reg:registers;
 funzione:integer;
 begin
 if verso then funzione:=$0600
 else funzione:=$0700;
 reg.ax:=funzione or linecount;
 reg.bx:=attr shl 8;
 reg.cx:=(y1-1) shl 8 or(x1-1);
 reg.dx:=(y2-1) shl 8 or(x2-1);
 intr($10,reg);
 end;


 procedure deftextwindow(numero,x1,y1,x2,y2:byte);
 begin
 winreftable[numero,1]:=x1;
 winreftable[numero,2]:=y1;
 winreftable[numero,3]:=x2;
 winreftable[numero,4]:=y2;
 end;

 procedure paintwindow(numero,colore:byte);
 var n,s:integer;
 begin
 textbackground(colore);
 s:=winreftable[numero,4]-winreftable[numero,2];
 for n:=0 to (s-1) do
 writeln(spaces(winreftable[numero,3]-winreftable[numero,1]));
 end;




 procedure seltextwindow(numero:byte);
 begin
 getvideo;
 if numero=0 then
 begin
 window(1,1,column,25);
 xtextlimit:=column;
 ytextlimit:=25;
 end else
 begin
 window(winreftable[numero,1],winreftable[numero,2],
        winreftable[numero,3],winreftable[numero,4]);
 xtextlimit:=winreftable[numero,3]-winreftable[numero,1]+1;
 ytextlimit:=winreftable[numero,4]-winreftable[numero,2]+1;
 frame:=false;
 end;
 activewindow:=numero;
 end;

function textwindowselected(numero:byte):boolean;
begin
if numero in [0..nbwindows] then
textwindowselected:=(activewindow= numero)
else
textwindowselected:=false;
end;

procedure gonextwin;
begin
if not(wherex=xtextlimit) then
   gotoxy(wherex+1,wherey)
   else
   if (wherex=xtextlimit) and (wherey=ytextlimit) then
   gotoxy(1,1)
   else
   gotoxy(1,wherey+1);
   end;

procedure gopredwin;
   begin
if not(wherex=1) then
   gotoxy(wherex-1,wherey)
   else
   if (wherex=1) and (wherey=1) then
   gotoxy(xtextlimit,ytextlimit)
   else
   gotoxy(xtextlimit,wherey-1);
end;

procedure keeptextwindow(scopo:azione;oggetto:obj);
var bufindex,col,row:byte;
    contatore:integer;
begin
csroff;
seltextwindow(activewindow);
contatore:=1;
bufindex:=Ord(oggetto)+1;
case scopo of
save:
for row:=1 to ytextlimit do
for col:=1 to xtextlimit do
begin
gotoxy(col,row);
readscreen;
windowbuffer[bufindex,activewindow,contatore]:=ord(scrn_char);
windowbuffer[bufindex,activewindow,contatore+1]:=attrib;
contatore:=contatore+2;
end;
load:
for row:=1 to ytextlimit do
for col:=1 to xtextlimit do
begin
gotoxy(col,row);
writeattribute(0,chr(windowbuffer[bufindex,activewindow,contatore]),
               windowbuffer[bufindex,activewindow,contatore+1]);
               contatore:=contatore+2;
               end;
    end;{case}
 Csron;
 end;

 procedure changetextwindow(oggetto:obj);
 var bufindex,col,row,char_buffer,att_buffer:byte;
 contatore:integer;
 begin
 seltextwindow(activewindow);
 contatore:=1;
 bufindex:=Ord(oggetto)+1;
 for row:=1 to ytextlimit do
 for col:=1 to xtextlimit do

 begin
 gotoxy(col,row);
 readscreen;
 writeattribute(0,chr(windowbuffer[bufindex,activewindow,contatore]),
                      windowbuffer[bufindex,activewindow,contatore+1]);
 windowbuffer[bufindex,activewindow,contatore]:=ord(scrn_char);
 windowbuffer[bufindex,activewindow,contatore+1]:=attrib;
 contatore:=contatore+2;
 end;
 end;

procedure movetextwindow(deltax,deltay:integer);
begin
csroff;
seltextwindow(activewindow);
getvideo;
if (winreftable[activewindow,1]+deltax <1 ) then
deltax:=1-winreftable[activewindow,1];
if (winreftable[activewindow,2]+deltay <1) then
deltay:=1-winreftable[activewindow,2];
if (winreftable[activewindow,3]+deltax > column) then
deltax:=column-winreftable[activewindow,3];
if (winreftable[activewindow,4]+deltay >25 ) then
deltay:=25-winreftable[activewindow,4];
Changetextwindow(background);
deftextwindow(activewindow,winreftable[activewindow,1]+deltax,
winreftable[activewindow,2]+deltay,winreftable[activewindow,3]+deltax,
winreftable[activewindow,4]+deltay);
seltextwindow(activewindow);
changetextwindow(background);
csron;
end;

procedure frametextwindow(colore,tratto:byte);
const framechar:array[1..2,1..6] of char=
      ((#218,#191,#192,#217,#196,#179),
      (#201,#187,#200,#188,#205,#186));
var i,pos,offset:integer;
base:word;
begin
getvideo;
csroff;
seltextwindow(activewindow);
textcolor(colore);
gotoxy(1,1);
write(framechar[tratto,1]);
for i:=2 to xtextlimit-1 do
write(framechar[tratto,5]);
write(framechar[tratto,2]);
for i:=2 to ytextlimit-1 do
begin
gotoxy(1,i);
write(framechar[tratto,6]);
gotoxy(xtextlimit,i);
write(framechar[tratto,6]);
end;
gotoxy(1,ytextlimit);
write(framechar[tratto,3]);
for i:=2 to xtextlimit-1 do
write(framechar[tratto,5]);
pos:=winreftable[activewindow,3]+(winreftable[activewindow,4]-1)*column;
if mode_video=7 then
base:=$B000
else
base:=$b800;
mem[base:(2*pos)-2]:=ord(framechar[tratto,4]);
mem[base:((2*pos)-2)+1]:=mem[base:((2*pos)-2)-1];
csron;
end;

procedure selframedwindow;
begin
window(winreftable[activewindow,1]+1,winreftable[activewindow,2]+1,
       winreftable[activewindow,3]-1,winreftable[activewindow,4]-1);
xtextlimit:=xtextlimit-2;
ytextlimit:=ytextlimit-2;
frame:=true;
end;

Procedure scrollwindow(verso:boolean;linecount,attr:integer);
var protect:byte;
begin
if frame then protect:=1 else protect:=0;
scroll(verso,linecount,attr,winreftable[activewindow,1]+protect,
       winreftable[activewindow,2]+protect,winreftable[activewindow,3]-protect,
       winreftable[activewindow,4]-protect);
end;

function spaces(n:byte):string;
var i:integer;
buffer:string;
begin
buffer:='';
for i:=1 to n do buffer:=buffer+' ';
spaces:=buffer;
end;

function tab(n:byte):string;
var spazi:byte;
begin
getvideo;
if n<= column then begin
spazi:=n-wherex;
if spazi<0 then spazi:=spazi+column;
tab:=spaces(spazi);
end;
end;

function freememamount:longint;
var reg:registers;
begin
reg.ax:=$4800;
reg.bx:=$ffff;
msdos(reg);
freememamount:=reg.bx div 64;
end;

procedure bsave(segmento,offset,lunghezza:word;userfile:filespec);
var binfile:file;
    index:integer;
    buffer:array[0..127] of byte;
    begin
    assign(binfile,userfile);
    rewrite(binfile);
    index:=0;
    while not(lunghezza<128) do
    begin
    move(mem[segmento:offset+index*128],buffer,128);
    Blockwrite(binfile,buffer,1);
    index:=index+1;
    lunghezza:=lunghezza-128;
    end;
    if not(lunghezza=0) then
    begin
    Fillchar(buffer,sizeof(buffer),0);
    move(mem[segmento:offset+index*128],buffer,lunghezza);
    blockwrite(binfile,buffer,1);
    end;
    close(binfile);
    end;

    procedure bload(segmento,offset,lunghezza:word;userfile:filespec);
    var binfile:file;
    index:integer;
    buffer:array[0..127] of byte;
    begin
    {$I-}
    assign(binfile,userfile);
    reset(binfile);
    {$I+}
    if ioresult= 0 then
    begin
    index:=0;
    while not(lunghezza <128) do
    begin
    blockread(binfile,buffer,1);
    move(buffer,mem[segmento:offset+index*128],128);
    index:=index+1;
    lunghezza:=lunghezza-128;
    end;
    if not(lunghezza =0) then
    begin
    blockread(binfile,buffer,1);
    move(buffer,mem[segmento:offset+index*128],lunghezza);
    end;
    close(binfile);
    end;
    end;



    procedure bsavebas(segmento,offset,lunghezza:word;userfile:filespec);
    var binfile:file of byte;
    i:integer;
    mark:byte;
    begin
    assign(binfile,userfile);
    rewrite(binfile);

    mark:=$FD;write(binfile,mark);
    mark:=Lo(segmento);write(binfile,mark);
    mark:=Hi(segmento);write(binfile,mark);
    mark:=Lo(offset);write(binfile,mark);
    mark:=Hi(offset);write(binfile,mark);
    mark:=Lo(lunghezza);write(binfile,mark);
    mark:=Hi(lunghezza);write(binfile,mark);
    for i:=1 to lunghezza do
    write(binfile,mem[segmento:offset+i-1]);
    mark:=$1A;
    write(binfile,mark);
    close(binfile);
    end;


    Procedure bloadbas(userfile:filespec);
    var binfile:file of byte;
    segmento,offset,lunghezza:word;
    i:integer;
    unbyte:byte;
    begin
    {$I-}
    assign(binfile,userfile);
    reset(binfile);
    {$I+}
    if ioresult=0 then
    begin
    read(binfile,unbyte);
    if unbyte=$FD then
    begin
    read(binfile,unbyte);segmento:=unbyte;
    read(binfile,unbyte);segmento:=segmento+unbyte*256;
    read(binfile,unbyte);offset:=unbyte;
    read(binfile,unbyte);offset:=offset+unbyte*256;
    read(binfile,unbyte);lunghezza:=unbyte;
    read(binfile,unbyte);lunghezza:=lunghezza+unbyte*256;

    for i:=1 to lunghezza do
    read(binfile,mem[segmento:offset+i-1]);
    end;
    close(binfile);
    end;
    end;

{posx,posy:coordinate iniziali,lunmax:lunghezza massima della stringa,c,d:carattreri}
{di uscita ,e:caratteri ammessi,f:carattere di conferma}


function inputctext(pos_x,pos_y,lunmax:integer;c,d:notcarattertype;e:charok;f:char):string;
var
qw:integer;
str_out:string;
ch,ch2:char;
            begin
            ch:=chr(1);
            str_out:='';
            gotoxy(pos_x,pos_y);
            repeat
            if (ch=chr(8)) and (length(str_out)>=1) then
               begin
               delete(str_out,length(str_out),1);
               gotoxy(wherex-1,wherey);
               write(' ');
               gotoxy(wherex-1,wherey);
            end;
            if (length(str_out)<lunmax) and (ord(ch)>ord(chr(31))) and (ch in e) then
               begin
               str_out:=str_out+ch;
               write(ch );
            end;
            ch:=readkey;
            if (ch in c)  then
                  begin
                  ch2:='0';
                  inputctext:=ch+ch2;
                  exit;
            end;
            if ch=chr(0) then begin
               ch2:=readkey;   {e' un codice esteso?}
               if ch2 in d then    {il secondo carattere appartiene}
                              begin               {ai caratteri di uscita?}
                              inputctext:=ch+ch2;
                              exit;
               end;
            ch:=chr(1);
            end;
            until (ch=f);
            inputctext:=str_out;
           end;




{x,y:insiemi di coordinate,lunmax:insieme di lunghezze massime,f:numero di insiemi}

function inputtab(x,y:coord;lunmax:lunterm;c,d:notcarattertype;e:charok;f:integer):string;
var
qw,n:integer;
str_out,str_tmp:string;
ch,ch2:char;
            begin
            n:=1;
            ch:=chr(1);
            str_out:='';
            repeat
            gotoxy(x[n],y[n]);
            repeat
            if (ch=chr(8)) and (wherex > x[n]) then
               begin
               delete(str_out,length(str_out),1);
               gotoxy(wherex-1,wherey);
               write(' ');
               gotoxy(wherex-1,wherey);
               ch:=chr(1);
            end;
            if (ch=chr(8)) and  (n>1) and (wherex= x[n]) then
            begin
            n:=n-1;
            delete(str_out,length(str_out),1);
            gotoxy(x[n]+lunmax[n],y[n]);
            gotoxy(wherex-1,wherey);
            write(' ');
            gotoxy(wherex-1,wherey);
            end;
            if (wherex < lunmax[n]+x[n]) and (wherex>=x[n]) and (ch in e) then
               begin
               str_out:=str_out+ch;
               write(ch );
            end;
            ch:=readkey;
            if (ch in c)  then
                  begin
                  ch2:='0';
                  inputtab:=ch+ch2;
                  exit;
            end;
            if ch=chr(0) then begin
               ch2:=readkey;   {e' un codice esteso?}
               if ch2 in d then    {il secondo carattere appartiene}
                              begin               {ai caratteri di uscita?}
                              inputtab:=ch+ch2;
                              exit;
               end;
            ch:=chr(1);
            end;
            until (wherex=lunmax[n]+x[n]) and (n<>f-1) or (ch=chr(13)) and (wherex=lunmax[f-1]+x[f-1]);
            n:=n+1;
            until n=f ;
            inputtab:=str_out;
           end;




procedure fileinfo(nomefile:string;var filebytes:longint;
var anno,mese,giorno,ora,min,sec:byte;var attrlist:string);
var regs:registers;
type Filedata= record
riservati:array[1..21] of byte;
attr:byte;
time,Date,Sizelo,Sizehi:integer;
end;
var
DTA:array[1..43] of byte;
FDA: filedata absolute DTA;

begin
regs.dx:=ofs(DTA);
regs.ds:=seg(DTA);
regs.ax:=$1A00;
msdos(regs);
nomefile:=nomefile + chr(0);
regs.dx:=ofs(nomefile[1]);
regs.ds:=seg(nomefile[1]);
regs.cx:=$16;
regs.ax:=$4E00;
msdos(regs);
if lo(regs.ax) <> 0 then
   begin
   filebytes:=-1;
   exit;
end;
filebytes:=lo(FDA.sizelo)+256* hi(FDA.sizelo)+
65536 * lo(fda.sizehi)+16777216 * hi(fda.sizehi);
anno:=(hi(fda.date) shr 1) +80;
if anno>99 then anno:=anno-100;
mese:=lo(fda.date) shr 5 +(hi(fda.date) and $01 shl 3);
giorno:=lo(fda.date) and $1F;
ora:=hi(fda.time) shr 3;
min:=lo(fda.time) shr 5 + (hi(fda.time) and $07 shl 3);
sec:=(lo(fda.time) and $1F) shl 1;
attrlist:='     ';
if fda.attr and $20 = $20 then attrlist[1]:='A';
if fda.attr and $10 = $10 then attrlist[2]:='D';
if fda.attr and $02 = $02 then attrlist[3]:='H';
if fda.attr and $01 = $01 then attrlist[4]:='R';
if fda.attr and $04 = $04 then attrlist[5]:='S';
end;


function inkeys:char;
var reg:registers;
begin
reg.ax:=$0600;
reg.dx:=$00ff;
intr($21,reg);
inkeys:=char(lo(reg.ax));
end;



function c_instring(a:string):string;
var d,n_s,n_c,n_t:integer;
begin
d:=length(a)+1;
repeat
d:=d-1;
until (a[d] <> ' ');
n_t:=length(a)-d;
delete(a,d+1,n_t);
n_s:=n_t div 2;
n_c:=n_t-(n_s*2);
c_instring:=spaces(n_c)+spaces(n_s)+a+spaces(n_s);
end;



function c_text(s:string;n:integer):string;{funzione per il centraggio del}
var m,r,w,q:integer;
begin                                      {testo}
m:=length(s);r:=n-m;                                                                  {testo}
w:=r mod 2;
q:=r div 2;
c_text:=spaces(q)+s+spaces(q+w);
end;


function strings(n:integer;r:char):string;
var i:integer;
var sp:string;
begin
sp:='';
for i:=1 to n do sp:=sp+r;
strings:=sp;
end;


begin
end.