
program gestione;
{dati pompe}
{versione del 10-09-92}

uses crt,dos,crt2,printer;

{t=file che contiene il numero di record precedentemente}
{convertiti}
{f=file da elaborare}
{fd=file convertito}


{gestione del file di dati,trasformazione in record}
{con aggiunta di campi}
{DESCRIZIONE DEL PROGRAMMA}
{il programma dato un file originale in forma ascii di nome cardself.dat deve}
{creare un'altro file in formato record sequenziale aggiungendovi inoltre due}
{campi rispetto all'originale: il campo prezzo e il campo dati anagrafici.}
{Ilsecondo file viene chiamato cardrec.dat}
{Inoltre viene creato un terzo file che si occupa di mantenere aggiornata la}
{configurazione del programma e di tenere conto delle eventuali variazioni avvenute}
{nel file di dati originale servendo a confronto per l'aggiornamento del}
{file di record sequenziale.Il programma e' suddiviso in due menu:}
{il menu principale e il menu di stampa.Ciascuno di essi ha le voci accessibili}
{tramite lo spostamento mediante frecce di un puntatore o piu' direttamente}
{tramite la digitazione di un numero associato ad ogni voce del menu'}
{Inizialmente il programma appena lanciato si occupa di chiamare la procedura di}
{aggancio dell'interrupt dell'orologio $1c e di chiamare la procedura }
{TRASFORMAFILE che si occupa di verificare l'esistenza di almeno uno dei due }
{file di dati e di reagire con un messaggio di errore se mancanti}
{in seguito la procedura si occupa di confrontare la lunghezza del file di dati}
{originale contenuta nel file di configurazione  con quella  del file di dati}
{chiamando la procedura AGGIORNAMENTO se la lunghezza del file di dati e'}
{maggiore di quella contenuta nel file di configurazione.}
{In questo modo si ha un controllo ,ogni volta che si lancia il programma}
{su eventuali modifiche apportate al file di dati e si procede ad aggiornare}
{di conseguenza il file di record}
{Il formato del file di configurazione e' :}
   { n.record                                           }
   { tipo di stampante ('80' o '132'colonne)            }
   { tipo di scheda monitor('H' bianco/nero 'C' colori}
{ogni elemento e' separato da un ritorno a capo (chr(13)}
{In seguito vi sono due procedure per l'inserimento dei dati: per numero tessera}
{e per intervallo fra date}
{il menu di stampa prevede tre opzioni:stampa totale dei dati,stampa con chiave}
{li numero di tessera e stampa con chiave l'intervallo tra date}
{vi sono poi la procedura di configurazione che si occupa di stabilire il tipo}
{ di hardware installato e di posizionare l'orologio di conseguenza in memoria}
{Infine la procedura di cancellazione che si occupa di cancellare il file }
{di record  dall' interno del programma e di aggiornare il primo campo del }
{file di configurazione }
{prova}


type datiaccettatore=record
numero_carta:string[4];
autista:string[4];
Km_percorsi:string[6];
pompa:string[1];
Litri:string[5];
prezzo:string[4];
ore:string[2];
minuti:string[2];
giorno:string[2];
mese:string[2];
end;
var accdati:datiaccettatore;
type
fa=file of datiaccettatore;
var fd:fa;
var
segmvideo:word;
base:integer;
Impulsitimer:byte;
ore:word;
minuti,secondi:longint;
var oldint:pointer;
type datitessera=record
numtessera:string[4];
datitessera:string[30];
end;
var datitess:datitessera;
type fs=file of datitessera;
var fz:fs;



function control:integer;
var  ct:text;
var sdc:string;
var n,count:integer;
var e:set of char;
var dt:datitessera;
type fx =file of datitessera;
var dx:fx;
begin
count:=1;
e:=['0'..'9',chr(13),chr(32)];
deftextwindow(1,20,5,60,10);
seltextwindow(1);
paintwindow(1,1);
frametextwindow(15,2);
gotoxy(2,2);
write(c_text('Controllo Generale',38));
gotoxy(2,3);
write(c_text('In Corso',38));
delay(500);
assign(dx,'dtes.dat');
{$I-}
reset(dx);
{$I+}
if ioresult <>0 then
begin
gotoxy(2,4);
textcolor(4);
write(c_text('File Dtes.dat assente',38));
beep;
delay(500);
textcolor(15);
gotoxy(2,5);
write(c_text('Ricostruisco....',38));
rewrite(dx);
dt.numtessera:='0000';
dt.datitessera:='00000000';
write(dx,dt);
close(dx);
delay(500);
end;
gotoxy(2,3);
write(c_text('Controllo dell''integrita'' dei dati',38));
delay(500);
assign(ct,'cardself.dat');
{$I-}
reset(ct);
{$I+}
if ioresult = 0 then
begin
repeat
readln(ct,sdc);
for n:=1 to length(sdc) do
begin
if not (sdc[n] in e) then
begin
gotoxy(2,3);
textcolor(4);
write(c_text('DATI ERRATI',38));
beep;
gotoxy(2,4);
write(c_text('Correggere con il programma apposito',38));
beep;
gotoxy(2,5);
write(c_text('Premere un tasto per uscire',38));
beep;
repeat until keypressed;
seltextwindow(0);
control:=1;
exit;
end;
end;
delay(50);
gotoxy(4,4);write('Record n.');
gotoxy(20,4);write(count);
count:=count+1;
until eof(ct);
gotoxy(2,3);
textcolor(15);
write(c_text('DATI O.K',38));
delay(500);
end;
seltextwindow(0);
control:=0;
end;



{procedura dell'orologio agganciata all'interrupt $1C}
procedure cheoresono(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word);
interrupt;
begin
inc(impulsitimer);
if impulsitimer =18 then
begin
impulsitimer:=0;
ore:=memw[$40:$6E] mod 24;
minuti:=memw[$40:$6c];
minuti:=((minuti*5)div 5461) mod 60;
Secondi:=memw[$40:$6c];
secondi:=((secondi*5) div 91) mod 60;
mem[Segmvideo:base]:=48+ore div 10;
mem[segmvideo:base+2]:=48+ore mod 10;
mem[segmvideo:base+4]:=ord(':');
mem[segmvideo:base+6]:=48+ minuti div 10;
mem[segmvideo:base+8]:=48+ minuti mod 10;
mem[segmvideo:base+10]:=ord(':');
mem[segmvideo:base+12]:=48+secondi div 10;
mem[segmvideo:base+14]:=48 + secondi mod 10;
end;
end;






{funzione per la gestione della data odierna}
{fornisce una stringa con giorno-mese-anno}
function gestdate:string;
var a,m,g,gs:word;
var anno,mese,giorno:string;
begin
getdate(a,m,g,gs);
str(a,anno);
str(m:2,mese);
str(g:2,giorno);
gestdate:=giorno+'-'+mese+'-'+anno;
end;



{si occupa dell'aggiornamento del file di record}

procedure aggiornamento(lun:integer);
var f,t:text;
var dati,numero,c_7,c_8,c_9,s:string;
var c_1,c_2,c_3,c_4,c_5,c_6,c1,c2:string;
var cl1:byte;
var ultimor,e,n:integer;
begin
cl1:=1;
assign(t,'accett.cnf');
reset(t);
readln(t,s);
readln(t,s);
readln(t,s);
close(t);
if s='H' then  cl1:=0;   {si occcupa di stabilire la colorazione del messaggio}
deftextwindow(1,15,4,65,8);   {di elaborazione i corso}
seltextwindow(1);
paintwindow(1,cl1);
frametextwindow(15,2);
delay(100);
gotoxy(10,2);write('ELABORAZIONE IN CORSO...ATTENDERE');
assign(f,'cardself.dat');
assign(fd,'cardrec.dat');
assign(t,'accett.cnf');
reset(f);
reset(t);
readln(t,numero);{legge il numero dei record dell'ultimo salvataggio}
val(numero,ultimor,e);
reset(fd);
seek(fd,filesize(fd));{sposta il puntatore del record alla posizione finale}
for n:=1 to ultimor do
readln(f,dati);       {sposta il puntatore del file di dati alla posizione}
for n:=(ultimor+1) to lun do  {letta nel file di configurazione e da qui}
begin                       {in poi aggiorna il file di record}
readln(f,dati);
c_1:=copy(dati,1,4);
c_2:=copy(dati,5,4);
c_3:=copy(dati,9,6);
c_4:=copy(dati,15,1);
c_5:=copy(dati,16,5);
c_6:=copy(dati,21,2);
c_7:=copy(dati,23,2);
c_8:=copy(dati,25,2);
c_9:=copy(dati,27,2);
with accdati do
begin
numero_carta:=c_1;
autista:=c_2;
km_percorsi:=c_3;
pompa:=c_4;
litri:=c_5;
prezzo:=spaces(5);
ore:=c_6;
minuti:=c_7;
giorno:=c_8;
mese:=c_9;
write(fd,accdati);
end;
end;
readln(t,c1);
readln(t,c2);
close(t);
rewrite(t);
writeln(t,lun); {aggiorna la lunghezza nel file di configurazione}
writeln(t,c1);
writeln(t,c2);
close(fd);
close(t);
close(f);
seltextwindow(0);
end;




function trasformafile:integer;
var f:text;
var t:text;
var lun,n,e,nodata,norec,col1,ior:integer;
var c1,c2,dati,s:string;
begin
nodata:=0;norec:=0;ior:=0;
assign(fd,'cardrec.dat');
assign(f,'cardself.dat');
assign(t,'accett.cnf');
{$I-}
reset(f); {controlla l'esistenza del file di dati}
{$I+}
if IOResult<>0 then {nel caso in cui il file f venga cancellato}
   begin            {se il file di configurazione
                   {esiste viene azzerato il numero di record}
   nodata:=1;      {in esso}
   {$I-}
   reset(t); {controlla che esista il file di configurazione}
   {$I+}
   if ioresult <> 0 then
      begin
      rewrite(t);
      writeln(t,0);
      writeln(t,'80');  {se non esiste viene scritto con i valori}
      writeln(t,'H');   { di default }
      close(t);
      end;
    end;
   if nodata=0 then close(f);  {se il file di dati esisteva viene chiuso}
   {$I-}
   reset(fd); {controllo dell'esistenza del file di record}
   {$I+}
   if IOResult <>0 then norec:=1 else close(fd);{se il file esiste viene chiuso}
   if (nodata=1) and (norec=1) then {se non esistono ne' il file di dati ne' }
      begin                         {il file di record viene segnalto l'errore}
      deftextwindow(3,10,10,50,12); { e si esce dal programma}
      seltextwindow(3);
      paintwindow(3,15);
      frametextwindow(0,2);
      gotoxy(4,2);
      textcolor(0);
      write('ERRORE: FILES DEI DATI NON PRESENTI ');
      DELAY(2000);
      beep;
      trasformafile:=0;
      exit;
  end;
  {$I-}
  reset(t); {se il file  di configurazione non esiste viene inizializzato}
  {$I+}     {coi valori di default e il primo campo a zero}
  if ioresult <>0 then
     begin
     rewrite(t);
     writeln(t,0);
     writeln(t,'80');
     writeln(t,'H');
  end;
  close(t);
  {$I-}
  reset(fd); {esiste il record?}
  {$I+}
  if IOResult <>0 then
     begin
     ior:=1;
     rewrite(fd); {nel caso il record venga cancellato esso viene inizializzato}
     close(fd);
     reset(t);  {e posto a 0 il file contatore di record}
     readln(t,c1); {e salvata la vecchia configurazione}
     readln(t,c1);
     readln(t,c2);
     close(t);
     rewrite(t);
     writeln(t,0);
     writeln(t,c1);
     writeln(t,c2);
     close(t);
     end;
     if ior = 0 then close(fd);
     lun:=0;
  if nodata=0 then { se esiste il file di dati ne viene calcolata la }
     begin         {lunghezza e confrontata con quella contenuta}
     reset(f);     {all'interno del file di configurazione}
     repeat
     readln(f,dati);
     lun:=lun+1;
     until seekeof(f); {calcola la lunghezza del file di testo in record}
     close(f);
     reset(t);
     read(t,s);
     val(s,n,e);
     if n< lun then aggiornamento(lun);{se il numero di record contenuti}
     close(t);                         {nel file di configurazione e' minore}
                                       {di quelli contenuti nel record si aggiorna}
     trasformafile:=1;
     clrscr;
  end;
  reset(t);
  readln(t,s);
  readln(t,s);
  readln(t,s);
  close(t);
  col1:=1;
  if s='H' then col1:=0; {stabilisce il colore della prima scritta di presentazione}
  textbackground(0);
  clrscr;
  textcolor(7);
  textbackground(col1);
  deftextwindow(1,1,1,78,3);
  deftextwindow(2,15,4,65,15);
  seltextwindow(1);
  frametextwindow(7,2);
  gotoxy(2,2);
  writeln(spaces(76));
  gotoxy(3,2);
  write(gestdate);
  gotoxy(26,2);
  writeln('GESTIONE DATI ACCETTATORE');
end;





function control2:integer;
var tx:text;
var sdc:string;
var n,count:integer;
var e:set of char;
begin
e:=['0'..'9',chr(13),chr(32)];
deftextwindow(1,20,5,60,10);
seltextwindow(1);
paintwindow(1,1);
frametextwindow(15,2);
textcolor(15);
gotoxy(2,3);
write(c_text('Controllo dell''integrita'' dei dati',38));
delay(500);
assign(tx,'cardself.dat');
{$I-}
reset(tx);
{$I+}
if ioresult = 0 then
begin
count:=1;
repeat
readln(tx,sdc);
for n:=1 to length(sdc) do
begin
if not (sdc[n] in e) then
begin
gotoxy(2,3);
textcolor(4);
write(c_text('DATI ERRATI',38));
beep;
gotoxy(2,4);
write(c_text('Correggere con il programma apposito',38));
beep;
gotoxy(2,5);
write(c_text('Premere un tasto per uscire',38));
beep;
repeat until keypressed;
seltextwindow(0);
control2:=1;
exit;
end;
end;
delay(100);
gotoxy(4,4);write('Record n.');
gotoxy(20,4);write(count);
count:=count+1;
until eof(tx);
gotoxy(2,3);
textcolor(15);
write(c_text('DATI O.K',38));
delay(500);
end;
seltextwindow(0);
control2:=0;
end;









procedure acquisizione(dm:string);
var n,d,r_s:integer;
var a:char;
var t,f,q:text;
var s,w,c,comp:string;
label loop,loop2;
begin
getdir(0,s);
loop2:
textbackground(0);textcolor(7);
clrscr;
gotoxy(2,2);write(c_text('ACQUISIZIONE DATI',76));
gotoxy(2,2);write(gestdate);
gotoxy(1,3);
for n:=0 to 79 do write(chr(205));
gotoxy(2,5);write(c_text('Inserire il disco dati nel drive A e premere enter',78));
gotoxy(2,6);write(c_text('Per uscire Escape',78));
gotoxy(2,20);write(c_text('Accertarsi che il file da acquisire non sia gia'' stato acquisito!!!!',78));
repeat
a:=readkey;
if a=chr(27) then exit;
until a=chr(13);
loop:
{$I-}
chdir('a:\');
{$I+}
if ioresult<>0 then
begin
Deftextwindow(1,10,5,70,8);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(7,2);
gotoxy(2,2);
write(c_text('ERRORE: disco non inserito riprova o annulla ? (R/A)',56));
chdir(s);
repeat
a:=readkey;
until (upcase(a)='R') or (upcase(a)='A');
if upcase(a)='R' then goto loop;
if upcase(a)='A' then exit;
end;
assign(f,'cardself.dat');
assign(q,'cardself.dat');
assign(t,'accett.cnf');
{$I-}
reset(f);
{$I+}
if ioresult<>0 then
begin
deftextwindow(1,10,5,70,9);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(7,2);
gotoxy(2,2);write(c_text('ERRORE: Il file Cercato non esiste nell''unita'' A.',56));
gotoxy(2,3);write(c_text('Inserire il disco coi dati e premere ENTER',56));
repeat
a:=readkey;
if a=chr(27) then
begin
chdir(s);
exit;
end;
until a=chr(13);
clrscr;
goto loop;
end;
clrscr;
r_s:=control2;
clrscr;
if r_s = 1 then
begin
close(f);
chdir(s);
exit;{10/09/92}
end;
deftextwindow(1,10,5,70,9);
seltextwindow(1);
frametextwindow(7,2);
gotoxy(2,2);write(c_text('TRASFERIMENTO IN CORSO...........',58));
readln(f,w);
chdir(s);
rewrite(q);
writeln(q,w);
repeat
chdir('a:\');
readln(f,w);
chdir(s);
writeln(q,w);
until eof(f);
close(q);
chdir('a:\');
close(f);
{$I-}
rename(f,'cardself.old');
{$I+}
if ioresult<>0 then
begin
clrscr;
deftextwindow(1,10,5,70,9);
seltextwindow(1);
frametextwindow(7,2);
gotoxy(2,2);write(c_text('TOGLIERE LA PROTEZIONE DAL DISCO !!!',58));
gotoxy(2,3);write(c_text('il File deve essere cancellato .',58));
chdir(s);
erase(q);
chdir('a:\');
delay(3000);
seltextwindow(0);
goto loop2;
end;
erase(f);
chdir(s);
reset(t);
readln(t,w);
readln(t,w);
readln(t,c);
close(t);
rewrite(t);
writeln(t,'0');
writeln(t,w);
writeln(t,c);
close(t);
clrscr;
deftextwindow(1,10,5,70,9);
seltextwindow(1);
frametextwindow(7,2);
gotoxy(2,2);
write(c_text('FILE TRASFERITO',58));
delay(1000);
d:=trasformafile
end;

{permette la scelta fra la configurazione e la gestione dati}

function presentazione:byte;
var anno,mese,giorno,giornosett:word;
var n1,n2,b1,b2,b3,b4,n3,n4,b5,n5,b6,n6,n7,b7:byte;
var c_1,c_2,c_3,c_4,c_5,c_6:byte;
var a:char;
var t:text;
var s:string;
begin
assign(t,'accett.cnf');
reset(t);
readln(t,s);
readln(t,s);
readln(t,s);
close(t);
c_1:=7;c_2:=2;c_3:=0;
c_4:=0;c_5:=7;c_6:=1;
if s='H' then
begin
c_1:=0;
c_2:=7;
c_3:=15;
c_4:=7;
c_5:=0;
c_6:=0;
end;
deftextwindow(1,1,20,80,25);
seltextwindow(1);
paintwindow(1,c_6);
frametextwindow(15,2);
gotoxy(3,2);write(c_text('ISTRUZIONI',74));
gotoxy(3,4);write(c_text('Per la Scelta Premere Enter  sull''argomento evidenziato',74));
gotoxy(3,5);write(c_text('o un numero che si riferisca all''argomento',74));
deftextwindow(2,10,4,70,19);
seltextwindow(2);
paintwindow(2,c_1);
frametextwindow(c_2,2);
gotoxy(2,2);
textcolor(c_3);
b1:=c_4;b2:=c_5;n1:=c_5;n2:=c_4;b3:=c_5;b4:=c_5;n3:=c_4;n4:=c_4;b5:=c_5;n5:=c_4;
b6:=c_5;n6:=c_4;
write(c_text('MENU PRINCIPALE',59));
csroff;
repeat
gotoxy(2,4);
textcolor(n1);textbackground(b1);
write(c_text('1.Gestione dati Tessere',59));
textcolor(n2);textbackground(b2);
gotoxy(2,6);
write(c_text('2.Inserimento Prezzo',59));
textcolor(n3);textbackground(b3);
gotoxy(2,8);
write(c_text('3.Stampa Dati',59));
textcolor(n4);textbackground(b4);
gotoxy(2,10);
write(c_text('4.Uscita dal Programma',59));
textcolor(n5);textbackground(b5);
gotoxy(2,12);
write(c_text('5.Cancellazione dati',59));
textcolor(n6);textbackground(b6);
gotoxy(2,14);
write(c_text('6.Configurazione',59));
a:=readkey;
if (a=chr(0)) then
begin
a:=readkey;
if (a='P')  and (n6<>c_5) then
begin
n7:=n6;n6:=n5;n5:=n4;n4:=n3;n3:=n2;n2:=n1;n1:=n7;
b7:=b6;b6:=b5;b5:=b4;b4:=b3;b3:=b2;b2:=b1;b1:=b7;
end;
if (a='H') and (n1<>c_5) then
begin
b1:=b2;b2:=b3;b3:=b4;b4:=b5;b5:=b6;b6:=b7;b7:=b1;
n1:=n2;n2:=n3;n3:=n4;n4:=n5;n5:=n6;n6:=n7;n7:=n1;
end;
end;
until (a= chr(13)) or (a in ['1'..'6']);
if ((b1=c_4) and (a=chr(13))) or (a='1') then presentazione:=1;
if ((b2=c_4) and (a=chr(13))) or (a='2') then presentazione:=2;
if ((b3=c_4) and (a=chr(13))) or (a='3') then presentazione:=3;
if ((b4=c_4) and (a=chr(13))) or (a='4') then presentazione:=4;
if ((b5=c_4) and (a=chr(13))) or (a='5') then presentazione:=5;
if ((b6=c_4) and (a=chr(13))) or (a='6') then presentazione:=6;
end;









function scanforint(a:string):integer;
var t_prezzo:string;
var ore_i,min_i,gio_i,mse_i,ore_f,min_f,gio_f,mse_f:string[2];
var v_mse_i,v_ore_i,v_min_i,v_gio_i:integer;
var v_mse_f,v_ore_f,v_min_f,v_gio_f:integer;
var er,c,oo,segnafile,vmse,vgio,vmin,vore:integer;
var t_i,t_f,t_1:boolean;
begin
t_1:=false;t_i:=false;t_f:=false;
t_prezzo:=copy(a,17,4);
ore_i:=copy(a,1,2);
ore_f:=copy(a,9,2);
min_i:=copy(a,3,2);
min_f:=copy(a,11,2);
gio_i:=copy(a,5,2);
gio_f:=copy(a,13,2);
mSe_i:=copy(a,7,2);
mSe_f:=copy(a,15,2);
er:=0;
if (ore_i=ore_f) and(min_i=min_f)
and(gio_i=gio_f) and (mse_i=mse_f)
then
begin
scanforint:=0;
exit;
end;
val(ore_i,v_ore_i,c);
val(ore_f,v_ore_f,c);
val(min_i,v_min_i,c);
val(min_f,v_min_f,c);
val(gio_i,v_gio_i,c);
val(gio_f,v_gio_f,c);
val(mse_i,v_mse_i,c);
val(mse_f,v_mse_f,c);
if v_mse_i>v_mse_f then oo:=1;
    if (v_mse_i = v_mse_f) then
       begin
          if (v_gio_i>v_gio_f) then oo:=1;
          if (v_gio_i=v_gio_f) then
          begin
               if(v_ore_i>v_ore_f) then oo:=1;
               if(v_ore_i = v_ore_f) then
                 begin
                      if (v_min_i>v_min_f) then oo:=1;
                 end;
          end;
       end;
if 00=1 then
begin
scanforint:=2;
exit;
end;
if (v_ore_i>24) or (v_ore_f>24)
or(v_min_i>59) or (v_min_f>59)
or(v_gio_i>31) or (v_gio_f>31)
or (v_mse_i>12) or (v_mse_f>12)
then
begin
scanforint:=1;
exit;
end;
assign(fd,'cardrec.dat');
reset(fd);
repeat
t_1:=false;t_i:=false;t_f:=false;
read(fd,accdati);
val(accdati.mese,vmse,c);
val(accdati.giorno,vgio,c);
val(accdati.ore,vore,c);
val(accdati.minuti,vmin,c);
if (vmse > v_mse_i) and (vmse < v_mse_f) then t_1:=true;
if (vmse > v_mse_i) then t_i:=true;{modifica del 10-09-92}
if (vmse < v_mse_f) then t_f:=true;
if vmse = v_mse_i then
begin
     if (vgio > v_gio_i)  then t_i:=true;
     if vgio = v_gio_i then
     begin
          if (vore > v_ore_i)  then t_i:=true;
          if vore = v_ore_i then
          begin
          if (vmin >= v_min_i) then t_1:=true;
          end;
          end;
          end;
          if (vmse = v_mse_f) then
          begin
               if (vgio < v_gio_f) then t_f:=true;
               if (vgio = v_gio_f) then
               begin
                    if(vore < v_ore_f) then t_f:=true;
                    if(vore = v_ore_f) then
                    begin
                         if (vmin <= v_min_f) then t_f:=true;
                    end;
               end;
          end;
         if (t_i) and (t_f) then t_1:=true;
if (t_1)  then
begin
accdati.prezzo:=t_prezzo;
segnafile:=filepos(fd)-1;
seek(fd,segnafile);
write(fd,accdati);
t_1:=false;
end;
until (eof(fd));
close(fd);
end;

procedure prepara_ricercaint(s:string);
var c1,c2,c3:byte;
begin
c1:=4;c2:=14;c3:=1;
if s='H' then
begin
c1:=0;
c2:=15;
c3:=0;
end;
textbackground(7);
textcolor(0);
gotoxy(3,9);write(spaces(24));
gotoxy(51,9);write(spaces(24));
textbackground(c1);
deftextwindow(1,28,15,50,20);
seltextwindow(1);
frametextwindow(c2,1);
seltextwindow(0);
gotoxy(36,16);write('Prezzo');
textbackground(7);
textcolor(0);
gotoxy(37,18);write(spaces(4));
{fine della presentazione}
textcolor(0);
gotoxy(6,9);write(':');
gotoxy(21,9);write('-');
gotoxy(54,9);write(':');
gotoxy(69,9);write('-');
deftextwindow(1,1,22,80,25);
seltextwindow(1);
paintwindow(1,c3);
frametextwindow(7,2);
seltextwindow(0);
gotoxy(25,24);write('PER CONFERMARE LE SCELTE PREMERE '+chr(17)+chr(196)+chr(217));
end;





procedure ricercaintervallo;
var int_tempo,s:string;
var n,m,e,res:integer;
var a,b:notcarattertype;
var c:charok;
var x:coord;var y:coord; var lun:lunterm;
var ca:char;
var c1,c2,c3,c4:byte;
var t:text;
begin
a:=[chr(27)];b:=[];c:=[chr(48)..chr(57)];
x[1]:=3;x[2]:=8;x[3]:=18;x[4]:=23;x[5]:=51;
x[6]:=56;x[7]:=66;x[8]:=71;x[9]:=37;
y[1]:=9;y[2]:=9;y[3]:=9;y[4]:=9;y[5]:=9;
y[6]:=9;y[7]:=9;y[8]:=9;y[9]:=18;
lun[1]:=2;lun[2]:=2;lun[3]:=2;lun[4]:=2;
lun[5]:=2;lun[6]:=2;lun[7]:=2;lun[8]:=2;
lun[9]:=4;
c1:=4;c2:=14;c3:=1;c4:=1;
assign(t,'accett.cnf');
reset(t);
readln(t,s);
readln(t,s);
readln(t,s);
close(t);
if s='H' then
begin
c1:=0;
c2:=15;
c3:=7;
c4:=0;
end;
seltextwindow(0);
textbackground(c1);
clrscr;
gotoxy(1,2);
textcolor(c3);
write(gestdate);
gotoxy(1,3);
for n:=0 to 79 do write(chr(205));
textcolor(c2);
gotoxy(30,2);
write('INSERIMENTO PREZZO ');
deftextwindow(1,1,5,32,11);
seltextwindow(1);
frametextwindow(c2,1);
textbackground(c3);
seltextwindow(0);
gotoxy(10,5);
write(' Data Iniziale ');
textbackground(c1);
gotoxy(3,7);
write('Ore');
gotoxy(7,7);
write('minuti');
gotoxy(15,7);
write('Giorno');
gotoxy(23,7);
write('Mese');
deftextwindow(1,48,5,80,11);
seltextwindow(1);
frametextwindow(c2,1);
textbackground(c3);
seltextwindow(0);
gotoxy(58,5);
write(' Data Finale ');
textbackground(c1);
gotoxy(51,7);write('Ore');
gotoxy(55,7);write('Minuti');
gotoxy(63,7);write('Giorno');
gotoxy(71,7);write('Mese');
e:=10;
prepara_ricercaint(s);
repeat
textcolor(0);
textbackground(7);
int_tempo:=inputtab(x,y,lun,a,b,c,e);
res:=scanforint(int_tempo);
if (res=0) or (res=2) then
begin
textbackground(c4);
textcolor(7);
seltextwindow(1);
clrscr;
frametextwindow(7,2);
seltextwindow(0);
gotoxy(25,24);
if res=0 then write('ERRORE: DATE UGUALI ');
if res=2 then write('ERRORE: LA DATA FINALE PRECEDE LA DATA INIZIALE');
beep;
delay(1000);
end;
if res =1 then
begin
textbackground(c4);
textcolor(7);
seltextwindow(1);
clrscr;
frametextwindow(7,2);
seltextwindow(0);
gotoxy(25,24);write('ERRORE : DATE NON ESISTENTI');
beep;
delay(1000);
end;
textcolor(0);
prepara_ricercaint(s);
until int_tempo=chr(27)+'0';
end;


procedure inserimento(i:string);
var n,nc:integer;
var c,d:notcarattertype;
var e:charok;
var a,f:char;
var co1,co2,co3,co4:integer;
var tessera,dati:string;
label init;
begin
c:=[chr(27)];d:=[];
e:=['0'..'9'];f:=chr(13);
assign(fz,'dtes.dat');
reset(fz);
seek(fz,filesize(fz));
co1:=14;co2:=4;co3:=1;
if i='H' then
begin
co1:=7;
co2:=0;
co3:=0;
end;
textcolor(co1);textbackground(co2);
clrscr;
gotoxy(2,2);write(c_text('INSERIMENTO DATI',78));
gotoxy(2,2);write(gestdate);
gotoxy(1,3);for n:=0 to 79 do write(chr(205));
gotoxy(2,5);write('N.Tessera');
gotoxy(30,5);write('Dati anagrafici');
gotoxy(25,9);write('Dati anagrafici precedenti');
init:
repeat
deftextwindow(1,1,20,80,25);
seltextwindow(1);
paintwindow(1,co3);
frametextwindow(15,2);
gotoxy(2,2);write(c_text('Per Uscire Escape,Confermare con Enter',76));
seltextwindow(0);
textcolor(0);textbackground(7);
gotoxy(58,5);write(spaces(15));
gotoxy(60,5);write('N.Record:',filepos(fz));
gotoxy(4,7);write(spaces(4));
gotoxy(23,7);write(spaces(30));
gotoxy(23,11);write(spaces(30));
repeat
e:=['0'..'9'];
tessera:=inputctext(4,7,4,c,d,e,f);
until (length(tessera)=4) or (tessera=chr(27)+'0');
if tessera=chr(27)+'0' then
begin
close(fz);
exit;
end;
if filesize(fz) >0 then
begin
reset(fz);
repeat
read(fz,datitess);
if datitess.numtessera=tessera then
begin
gotoxy(23,11);write(datitess.datitessera);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(15,2);
gotoxy(2,3);write(c_text('SOSTITUIRE IL CONTENUTO ? (S/N)',76));
repeat
a:=readkey;
until (upcase(a)='S') or (upcase(a)='N');
if upcase (a) ='N' then
begin
clrscr;
seltextwindow(0);
seek(fz,filesize(fz));
goto init;
end;
if (upcase(a)='S') then
begin
repeat
clrscr;
seltextwindow(0);
textbackground(7);textcolor(0);
e:=[chr(32)..chr(127)];
dati:=inputctext(23,7,30,c,d,e,f);
if dati=chr(27)+'0' then
begin
close(fz);
exit;
end;
until  (dati<>'');
seek(fz,filepos(fz)-1);
nc:=length(dati);
if nc< 30 then
begin
nc:=30-nc;
dati:=dati+spaces(nc);
end;
datitess.datitessera:=dati;
write(fz,datitess);
seek(fz,filesize(fz));
goto init;
end;
end;
until (datitess.numtessera=tessera) or eof(fz);
end;
repeat
textbackground(7);textcolor(0);
e:=[chr(32)..chr(127)];
dati:=inputctext(23,7,30,c,d,e,f);
if dati=chr(27)+'0' then
begin
close(fz);
exit;
end;
until  (dati<>'');
seek(fz,filesize(fz));
datitess.numtessera:=tessera;
nc:=length(dati);
if nc < 30 then dati:=dati+spaces(30-nc);
datitess.datitessera:=dati;
write(fz,datitess);
until 3>5;
end;



procedure stampadati(i:string);
var t:text;
var s:string;
var o:integer;
var a:char;
var co1,co2:integer;
label init1;
begin
co1:=1;co2:=14;
if i='H' then
begin
co1:=0;
co2:=7;
end;
textbackground(co1);textcolor(co2);
clrscr;
gotoxy(2,2);write(c_text('STAMPA DATI TESSERE',76));
gotoxy(2,2);write(gestdate);
gotoxy(1,3);
for o:=0 to 79 do write(chr(205));
gotoxy(1,8);write(c_text('Posizionare La carta nella stampante e Premere Enter',78));
assign(t,'accett.cnf');
init1:
reset(t);
readln(t,s);
readln(t,s);
close(t);
a:=readkey;
if a=chr(27) then
begin
exit;
end;
if a=chr(13) then
   begin
   {$I-}
   if s='80' then write(lst,chr(27)+chr(15));
   writeln(lst,spaces(132));
   {$I+}
   if ioresult<>0 then
      begin
      deftextwindow(1,10,10,70,13);
      seltextwindow(1);
      paintwindow(1,0);
      frametextwindow(7,2);
      gotoxy(2,2);write(c_text('STAMPANTE NON PRONTA RIPROVA O ANNULLA ? (R/A)',56));
      repeat
      a:=readkey;
      until (upcase(a)='R') or (upcase(a)='A');
      if upcase(a)='A' then exit;
      if upcase(a)='R' then
         begin
         clrscr;
         seltextwindow(0);
         goto init1;
         end;
     end;
     assign(fz,'dtes.dat');
     reset(fz);
     writeln(lst,c_text('DATI TESSERE',132));
     writeln(lst,strings(132,chr(205)));
     repeat
     read(fz,datitess);
     write(lst,datitess.numtessera);write(lst,spaces(30));
     writeln(lst,datitess.datitessera);
     until (eof(fz));
     end;
close(fz);
end;






procedure inizio_eliminazione(s:integer;i:string);
var o,p,n:integer;
var co1,co2:integer;
begin
co1:=7;co2:=1;
if i='H' then
begin
co1:=7;
co2:=0;
end;
textcolor(co1);textbackground(co2);
clrscr;
gotoxy(2,2);write(c_text('ELIMINAZIONE TESSERE',76));
gotoxy(2,2);write(gestdate);
gotoxy(1,3);
for o:=0 to 79 do write(chr(205));
gotoxy(2,25);write(chr(24),' ',chr(25),' per scegliere il campo da eliminare');
write(',Enter per confermare');
if filesize(fz)>0 then
begin
seek(fz,s-10);
n:=0;
repeat
read(fz,datitess);
gotoxy(2,5+n*2);write(datitess.numtessera);
gotoxy(23,5+n*2);write(datitess.datitessera);
n:=n+1;
p:=s-10+n;
until (p=s) or (eof(fz));
end;
end;






procedure eliminazione(e:string);
var n,s,i,r:integer;
var a:char;
var co1,co2,co3,co4:integer;
begin
n:=0;
s:=10;
co1:=1;co2:=7;co3:=4;co4:=14;
if e='H'then
begin
co1:=0;
co2:=7;
co3:=0;
co4:=7;
end;
inizio_eliminazione(s,e);
reset(fz);
read(fz,datitess);
textcolor(co1);textbackground(co2);
gotoxy(1,5);write(spaces(52));
gotoxy(2,5);write(datitess.numtessera);
gotoxy(23,5);write(datitess.datitessera);
textcolor(co2);textbackground(co1);
gotoxy(60,5);write(chr(17),chr(205));
repeat
csroff;
a:=readkey;
if a=chr(0) then
begin
a:=readkey;
if (a='P') and (n+s-10< filesize(fz)-1) then
begin
n:=n+1;
seek(fz,s-10+n-1);
read(fz,datitess);
textcolor(co2);textbackground(co1);
gotoxy(60,5+(n-1)*2);write(spaces(2));
gotoxy(1,5+(n-1)*2);write(spaces(52));
gotoxy(2,5+(n-1)*2);write(datitess.numtessera);
gotoxy(23,5+(n-1)*2);write(datitess.datitessera);
read(fz,datitess);
gotoxy(60,5+n*2);write(chr(17),chr(205));
textcolor(co1);textbackground(co2);
gotoxy(1,5+n*2);write(spaces(52));
gotoxy(2,5+n*2);write(datitess.numtessera);
gotoxy(23,5+n*2);write(datitess.datitessera);
end;
if ((a='H') and (n>0)) or ((a='H') and (n>=0) and (s>10)) then
begin
seek(fz,s-10+n-1);
read(fz,datitess);
textcolor(co2);textbackground(co1);
gotoxy(60,5+(n-1)*2);write(chr(17),chr(205));
textcolor(co1);textbackground(co2);
gotoxy(1,5+(n-1)*2);write(spaces(52));
gotoxy(2,5+(n-1)*2);write(datitess.numtessera);
gotoxy(23,5+(n-1)*2);write(datitess.datitessera);
read(fz,datitess);
textcolor(co2);textbackground(co1);
gotoxy(1,5+n*2);write(spaces(52));
gotoxy(2,5+n*2);write(datitess.numtessera);
gotoxy(23,5+n*2);write(datitess.datitessera);
gotoxy(60,5+n*2);write(spaces(2));
n:=n-1;
end;
if n+s-10 = s then
begin
s:=s+10;
n:=0;
inizio_eliminazione(s,e);
seek(fz,s-10);
read(fz,datitess);
textcolor(co1);textbackground(co2);
gotoxy(1,5);write(spaces(52));
gotoxy(2,5);write(datitess.numtessera);
gotoxy(23,5);write(datitess.datitessera);
textcolor(co2);textbackground(co1);
gotoxy(60,5);write(chr(17),chr(205));
end;
if (n < 0) and (a='H') then
begin
s:=s-10;
n:=0;
inizio_eliminazione(s,e);
n:=9;
seek(fz,9+s-10);
read(fz,datitess);
textcolor(co1);textbackground(co2);
gotoxy(1,23);write(spaces(52));
gotoxy(2,23);write(datitess.numtessera);
gotoxy(23,23);write(datitess.datitessera);
textcolor(co2);textbackground(co1);
gotoxy(60,23);write(chr(17),chr(205));
end;
end;
if (a=chr(13)) and (filesize(fz)>1) then
begin
deftextwindow(1,62,5+n*2-1,80,5+n*2+2);
seltextwindow(1);
paintwindow(1,co3);
frametextwindow(7,2);
textcolor(co4);
gotoxy(2,2);write(c_text('ELIMINARE ?',16));
gotoxy(2,3);write(c_text('(S/N)',16));
repeat
csroff;
a:=readkey;
until (upcase(a)='N') or (upcase(a)='S');
if upcase(a)='N' then
begin
paintwindow(1,co1);
clrscr;
seltextwindow(0);
end;
if upcase(a)='S'  then
begin
r:=0;
if (s-10+n)+1 <  filesize(fz) then
begin
clrscr;
seltextwindow(0);
repeat
seek(fz,s-10+n+1+r);
read(fz,datitess);
seek(fz,filepos(fz)-2);
write(fz,datitess);
r:=r+1;
until (filepos(fz)=filesize(fz)-1);
seek(fz,filesize(fz)-1);
truncate(fz);
inizio_eliminazione(s,e);
gotoxy(60,5+n*2);write(chr(17),chr(205));
textcolor(co1);textbackground(co2);
seek(fz,s-10+n);
read(fz,datitess);
gotoxy(1,5+n*2);write(spaces(52));
gotoxy(2,5+n*2);write(datitess.numtessera);
gotoxy(23,5+n*2);write(datitess.datitessera);
end;
if ((s-10+n)=(filesize(fz)-1)) and ((filepos(fz)> 1)) then
begin
seek(fz,filesize(fz)-1);
truncate(fz);
n:=n-1;
if n<0 then s:=s-10;
clrscr;
seltextwindow(0);
inizio_eliminazione(s,e);
if n<0 then n:=9;
gotoxy(60,5+n*2);write(chr(17),chr(205));
textcolor(co1);textbackground(co2);
seek(fz,filepos(fz)-1);
read(fz,datitess);
gotoxy(1,5+n*2);write(spaces(52));
gotoxy(2,5+n*2);write(datitess.numtessera);
gotoxy(23,5+n*2);write(datitess.datitessera);
end;
end;
end;
until a=chr(27);
close(fz);
end;






procedure presentadati(i:string);
var s,n:integer;
var b1,b2,b3,b4,b5,b6:integer;
var c1,c2,c3,c4,c5,c6:integer;
var co1,co2,co3,co4,co5,co6:integer;
var a:char;
label loop;
begin
loop:
assign(fz,'dtes.dat');
{$I-}
reset(fz);
{$I+}
if ioresult <> 0  then  rewrite(fz);
clrscr;
seltextwindow(0);
clrscr;
co1:=14;co2:=4;co3:=1;
co4:=14;co5:=1;co6:=7;
if i='H' then
begin
co1:=7;
co2:=0;
co3:=7;
co4:=0;
co5:=0;
co6:=0;
end;
textbackground(co6);
clrscr;
textcolor(co1);textbackground(co2);
for s:=1 to 24 do
begin
gotoxy(1,s);for n:=0 to 79 do write(chr(178));
end;
gotoxy(2,2);write(c_text('GESTIONE DATI TESSERE',76));
gotoxy(2,2);write(gestdate);
textcolor(co4);textbackground(co3);
reset(fz);
gotoxy(56,4);write('Lunghezza del file: ',filesize(fz));
deftextwindow(1,10,6,70,18);
seltextwindow(1);
paintwindow(1,co5);
frametextwindow(15,2);
seltextwindow(0);
b1:=7;c1:=co5;b2:=co5;c2:=7;b3:=co5;c3:=7;b4:=co5;c4:=7;
b5:=co5;c5:=7;b6:=co5;c6:=7;
repeat
csroff;
textcolor(c1);textbackground(b1);
gotoxy(12,8);write(c_text('1.Inserimento e correzione dati',57));
textcolor(c2);textbackground(b2);
gotoxy(12,10);write(c_text('2.Visione e Eliminazione dati',57));
textcolor(c3);textbackground(b3);
gotoxy(12,12);write(c_text('3.Acquisizione dati',57));
textcolor(c4);textbackground(b4);
gotoxy(12,14);write(c_text('4.Stampa Dati',57));
textcolor(c5);textbackground(b5);
gotoxy(12,16);write(c_text('5.Ritorno al Menu'' principale',57));
a:=readkey;
if a=chr(0) then
begin
a:=readkey;
if (a='P') and (c5<>co5) then
begin
c6:=c5;c5:=c4;c4:=c3;c3:=c2;c2:=c1;c1:=c6;
b6:=b5;b5:=b4;b4:=b3;b3:=b2;b2:=b1;b1:=b6;
end;
if (a='H') and (c1 <>co5) then
begin
c1:=c2;c2:=c3;c3:=c4;c4:=c5;c5:=c6;c6:=c1;
b1:=b2;b2:=b3;b3:=b4;b4:=b5;b5:=b6;b6:=b1;
end;
end;
until (a=chr(13)) or (a in['1'..'5']);
if ((b1=7) and (a=chr(13))) or (a='1') then
begin
close(fz);
inserimento(i);
goto loop;
end;
if (((b2=7) and (a=chr(13))) or (a='2')) and (filesize(fz)>0) then
begin
eliminazione(i);
goto loop;
end;
if (b3=7) and (a=chr(13)) or (a='3') then
begin
acquisizione(i);
goto loop;
end;
if (b4=7) and (a=chr(13)) or ( a='4') then
begin
close(fz);
stampadati(i);
goto loop;
end;
if (b5=7) and (a=chr(13)) or (a='5') then
begin
close(fz);
exit;
end;
end;


{ricerca}






procedure intestazioneintervallo(ore1,min1,gio1,mse1,ore2,min2,gio2,mse2,tes,ana:string);
var rt:integer;
begin
writeln(lst,c_text('STAMPA PER TESSERA IN UN INTERVALLO DI DATE',118));
    write(lst,'TESSERA N. ',tes+spaces(10));writeln(lst,'DATI: ',ana);
    write(lst,'Dalle '+ore1+':'+min1+' del '+gio1+'-'+mse1);
    writeln(lst,' Alle '+ore2+':'+min2+' del '+gio2+'-'+mse2);
    for rt:=1 to 131 do write(lst,chr(205));writeln(lst,chr(205));
    write(lst,'CODICE'+spaces(4));write(lst,'KM.PERCORSI'+spaces(4));
    write(lst,'N.POMPA'+spaces(4));write(lst,'LITRI'+spaces(4));
    write(lst,'PREZZO'+spaces(4));write(lst,'COSTO'+spaces(4));
    write(lst,'ORE'+spaces(4));write(lst,'MINUTI'+spaces(4));write(lst,'GIORNO'+spaces(4));
    writeln(lst,'MESE');
end;







function scan2int(a:string):integer;
var ore_i,min_i,gio_i,mse_i,ore_f,min_f,gio_f,mse_f:string[2];
var tessera:string[4];anagr:string[30];lit:string[5];
var v_mse_i,v_ore_i,v_min_i,v_gio_i:integer;
var v_mse_f,v_ore_f,v_min_f,v_gio_f:integer;
var oo,c,vmse,vgio,vmin,vore,prnook,lines,err:integer;
var liters,totlitri,totprezzo:real;
var price:longint;
var t_i,t_f,t_1,t_t:boolean;
var s:string;
var t:text;
var r:char;
begin
     t_1:=false;oo:=0;
     prnook:=0;
     ore_i:=copy(a,1,2);
     ore_f:=copy(a,9,2);
     min_i:=copy(a,3,2);
     min_f:=copy(a,11,2);
     gio_i:=copy(a,5,2);
     gio_f:=copy(a,13,2);
     mse_i:=copy(a,7,2);
     mse_f:=copy(a,15,2);
     tessera:=copy(a,17,4);
     if (ore_i =ore_f) and (min_i = min_f)
     and (gio_i =gio_f) and (mse_i = mse_f) then
         begin
         scan2int:=0; {date uguali}
         exit;
     end;
     val(ore_i,v_ore_i,c);
     val(ore_f,v_ore_f,c);
     val(min_i,v_min_i,c);
     val(min_f,v_min_f,c);
     val(gio_i,v_gio_i,c);
     val(gio_f,v_gio_f,c);
     val(mse_i,v_mse_i,c);
     val(mse_f,v_mse_f,c);
     if ((v_ore_i>24) or (v_ore_f>24)
     or(v_min_i>59) or (v_min_f>59)
     or (v_gio_i>31) or (v_gio_f>31)
     or (v_mse_i>12) or (v_mse_f>12)) then
        begin
           scan2int:=1;
              exit;
        end;
    if v_mse_i>v_mse_f then oo:=1;
    if (v_mse_i = v_mse_f) then
       begin
          if (v_gio_i>v_gio_f) then oo:=1;
          if (v_gio_i=v_gio_f) then
          begin
               if(v_ore_i>v_ore_f) then oo:=1;
               if(v_ore_i = v_ore_f) then
                 begin
                      if (v_min_i>v_min_f) then oo:=1;
                 end;
          end;
       end;
    if oo=1 then
    begin
         scan2int:=2;
         exit;
    end;
    assign(t,'accett.cnf');
    reset(t);
    readln(t,s);
    readln(t,s);
    close(t);
    {c'era un  resetstampante}
    {$I-}
    if s='80' then write(lst,chr(27)+chr(15));{stampa compressa}
    {$I+}
    if ioresult<>0 then prnook:=1;
    {$I-}
    write(lst,gestdate+spaces(4));
    {$I+}
    if ioresult<>0 then prnook:=1;
    if prnook=1 then
    begin
    scan2int:=3;
    exit;
    end;
    assign(fz,'dtes.dat');
    reset(fz);
    repeat
    read(fz,datitess);
    if datitess.numtessera = tessera then anagr:=datitess.datitessera;
    until (eof(fz)) or (datitess.numtessera = tessera);
    close(fz);
    intestazioneintervallo(ore_i,min_i,gio_i,mse_i,ore_f,min_f,gio_f,mse_f,tessera,anagr);
    assign(fd,'cardrec.dat');
    reset(fd);
    lines:=0;
    totprezzo:=0;totlitri:=0;
    repeat
    repeat
    t_1:=false;t_i:=false;t_f:=false;t_t:=false;
    read(fd,accdati);
    val(accdati.mese,vmse,c);
    val(accdati.giorno,vgio,c);
    val(accdati.ore,vore,c);
    val(accdati.minuti,vmin,c);
    if(vmse > v_mse_i) and (vmse < v_mse_f) then t_1:=true;
    if (vmse >v_mse_i) then t_i:=true;
    if (vmse < v_mse_f) then t_f:=true;{revisione del 8-9-1992}
    if (vmse = v_mse_i) then
    begin
    if (vgio > v_gio_i) then t_i:=true;
    if (vgio = v_gio_i) then
    begin
    if (vore > v_ore_i) then t_i:=true;
    if (vore = v_ore_i) then
    begin
    if (vmin >= v_min_i) then t_i:=true;
    end;
    end;
    end;
    if (vmse =v_mse_f) then
    begin
    if (vgio< v_gio_f)  then t_f:=true;
    if (vgio = v_gio_f) then
    begin
    if (vore < v_ore_f)  then t_f:=true;
    if (vore = v_ore_f) then
    begin
    if (vmin <= v_min_f)  then t_f:=true;
    end;
    end;
    end;
    if (t_i) and (t_f)  then t_1:=true;
    if tessera=accdati.numero_carta then t_t:=true;
       if (t_1) and (t_t) then
       begin
       lines:=lines+1;
       write(lst,accdati.autista+spaces(8));
       write(lst,accdati.km_percorsi+spaces(9));
       write(lst,accdati.pompa+spaces(8));
       val(accdati.litri,liters,err);
       liters:=liters/10;{litri riportati a decimali}
       totlitri:=totlitri+liters;
       str(liters:5:1,lit);
       write(lst,lit+spaces(4));
       write(lst,accdati.prezzo+spaces(4));
       val(accdati.prezzo,price,err);
       write(lst,price*liters:7:0);
       totprezzo:=totprezzo+liters * price;
       write(lst,spaces(4)+accdati.ore+'  :');
       write(lst,spaces(3));
       write(lst,accdati.minuti+spaces(7));
       write(lst,accdati.giorno+'    -'+spaces(4));
       writeln(lst,accdati.mese);
       if inkeys = chr(27) then
       begin
       csroff;
       deftextwindow(1,1,15,80,18);
       seltextwindow(1);
       paintwindow(1,0);
       frametextwindow(7,2);
       textcolor(7);textbackground(0);
       gotoxy(2,2);
       write(c_text('ABBANDONA LA STAMPA ? (S/N)',76));
       repeat
       r:=readkey;
       until (upcase(r)='S') or (upcase(r)='N');
       if upcase(r) = 'S' then
       begin
       scan2int:=5;
       exit;
       end;
       clrscr;
       seltextwindow(0);
       end;
       csron;
       t_1:=false;t_i:=false;t_f:=false;
       end;
       until (lines=60) or (eof(fd));
       if not(eof(fd)) then
       begin
       write(lst,chr(12));
       intestazioneintervallo(ore_i,min_i,gio_i,mse_i,ore_f,min_f,gio_f,mse_f,tessera,anagr);
       lines:=0;
       end;
       until eof(fd);
       writeln(lst, spaces(132));
       writeln(lst,c_text('PROSPETTO CONSUMI TESSERA N. '+tessera,132));
       for lines:=0 to 132 do write(lst,chr(205));
       writeln(lst,spaces(132));
       write(lst,'Nel periodo che va dal ');write(lst,ore_i+':'+min_i);
       write(lst,' Del ');write(lst,gio_i+'-'+mse_i);
       write(lst,' Alle ');write(lst,ore_f+':'+min_f);write(lst,' del ');
       writeln(lst,gio_f+'-'+mse_f);
       writeln(lst,'il consumo in litri e'' stato di ',totlitri:8:1);
       writeln(lst,'Per un costo totale di L.',totprezzo:8:0);
       if totlitri<>0 then
       writeln(lst,'Prefigurando un costo medio del carburante di ',(totprezzo/totlitri):8:0);
       scan2int:=10;
 close(fd);
 end;














procedure stampaintervallo(s:string);
var n,e,ris:integer;
var a,b:notcarattertype;
var c:charok;
var x,y:coord;var lun:lunterm;
var int_tempo:string;
var c1,c2,c3,c4,c5,c6:byte;
label riprova;
begin
clrscr;
c1:=4;c2:=1;c3:=0;c4:=7;c5:=4;c6:=0;
if s='H'then
begin
c1:=0;
c2:=0;
c3:=7;
c4:=0;
c5:=0;
c6:=7;
end;
x[1]:=7;x[2]:=12;x[3]:=20;x[4]:=27;
x[5]:=47;x[6]:=52;x[7]:=60;x[8]:=67;
x[9]:=37;
for n:=1 to 8 do
begin
y[n]:=9;
lun[n]:=2;
end;
y[9]:=17;lun[9]:=4;
c:=[chr(48)..chr(57)];a:=[chr(27)];b:=[];
gotoxy(2,2);write(gestdate);
gotoxy(12,2);write(c_text('STAMPA PER TESSERA IN UN INTERVALLO DI TEMPO',56));
gotoxy(1,3);for n:=1 to 79 do write(chr(205));
gotoxy(1,5);clreol;
deftextwindow(1,2,5,35,11);
seltextwindow(1);
frametextwindow(15,1);
deftextwindow(1,42,5,75,11);
seltextwindow(1);
frametextwindow(15,1);
seltextwindow(0);
textbackground(c1);
gotoxy(11,5);write(' Data Iniziale ');
gotoxy(53,5);write(' Data Finale ');
textbackground(c2);
gotoxy(7,7);write('Ore');
gotoxy(12,7);write('Minuti');
gotoxy(20,7);write('Giorno');
gotoxy(27,7);write('Mese');
gotoxy(47,7);write('Ore');
gotoxy(52,7);write('Minuti');
gotoxy(60,7);write('Giorno');
gotoxy(67,7);write('Mese');
deftextwindow(1,30,15,46,18);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(15,1);
textbackground(c2);
seltextwindow(0);
gotoxy(35,15);write('Tessera');
riprova:
deftextwindow(1,1,22,80,25);
seltextwindow(1);
paintwindow(1,c5);
frametextwindow(7,2);
seltextwindow(0);
gotoxy(2,23);
write(c_text('PER CONFERMARE LE SCELTE PREMERE '+chr(17)+chr(196)+chr(217),76));
gotoxy(2,24);write(c_text('ESC PER USCIRE',76));
repeat
textbackground(c3);
textcolor(c4);
gotoxy(7,9);write(spaces(24));
gotoxy(47,9);write(spaces(24));
gotoxy(37,17);write(spaces(4));
gotoxy(10,9);write(':');
gotoxy(26,9);write('-');
gotoxy(50,9);write(':');
gotoxy(66,9);write('-');
textcolor(c4);
textbackground(c3);
e:=10;
int_tempo:=inputtab(x,y,lun,a,b,c,e);
if int_tempo = chr(27)+'0' then exit;
ris:=scan2int(int_tempo);
if ris=5 then exit;
if ris=0 then
begin
textcolor(c6);
textbackground(c5);
gotoxy(2,24);write(c_text('ERRORE : DATE UGUALI',76));
delay(1000);
beep;
goto riprova;
end;
if ris =1 then
begin
textcolor(c6);
textbackground(c5);
gotoxy(2,24);write(c_text('ERRORE : DATE IMPOSSIBILI',76));
beep;
delay(1000);
goto riprova;
end;
if ris=2 then
begin
textcolor(c6);
textbackground(c5);
gotoxy(2,24);write(c_text('ERRORE : DATA INIZIALE MAGGIORE DI QUELLA FINALE',76));
beep;
delay(1000);
goto riprova;
end;
if ris=3 then
begin
textcolor(c6);
textbackground(c5);
gotoxy(2,24);write(c_text('ERRORE : STAMPAMTE NON PRONTA',76));
beep;
delay(1000);
goto riprova;
end;
until int_tempo = chr(27)+'0';
end;







function stpnonpronta:integer;
var a:char;
begin
deftextwindow(1,1,15,80,18);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(7,2);
repeat
beep;
gotoxy(2,2);write(c_text('STAMPANTE NON PRONTA  RIPROVA O ANNULLA ? (R\A)',76));
a:=readkey;
until  (upcase(a)='R') or (upcase(a)='A');
clrscr;
seltextwindow(0);
if upcase(a)='R' then  stpnonpronta:=1;
if upcase(a)='A' then  stpnonpronta:=0;
end;





function intestazionetotale:integer;
var err,rs:integer;
begin
rs:=0;err:=0;intestazionetotale:=0;
repeat
{$I-}
write(lst,gestdate+spaces(4));
{$I+}
err:=ioresult;
if err<>0 then
begin
rs:=stpnonpronta;
if rs = 0 then
begin
intestazionetotale:=1;
exit;
end;
end;
until err=0;
writeln(lst,c_text('DATI ACCETTATORE',118));
writeln(lst,strings(132,chr(205)));
writeln(lst,spaces(132));
write(lst,'TESSERA');
write(lst,spaces(4));
write(lst,'CODICE');
write(lst,spaces(9));
write(lst,'DATI ANAGRAFICI');
write(lst,spaces(9));
write(lst,'KM.PERCORSI');
write(lst,spaces(4));
write(lst,'N.POMPA');
write(lst,spaces(4));
write(lst,'LITRI');
write(lst,spaces(4));
write(lst,'PREZZO');
write(lst,spaces(4));
write(lst,'ORE');
write(lst,spaces(4));
write(lst,'MINUTI');
write(lst,spaces(4));
write(lst,'GIORNO');
write(lst,spaces(4));
writeln(lst,'MESE');
end;







procedure stampatotale(s:string);
var rs:integer;
var a,r:char;
var t:text;
var ltr:real;
var ready,sign:word;
var scnf,vcnf,dati_anagr:string;
var err:integer;
label riprova;
begin
sign:=0;
gotoxy(1,2);write(c_text('STAMPA TOTALE',80));
gotoxy(2,5);write(c_text('Posizionare la carta e premere invio',80));
gotoxy(2,2);write(gestdate);
gotoxy(2,24);write('PREMERE ESC PER USCIRE');
repeat
a:=readkey;
if a=chr(27) then exit;
until a=chr(13) ;
riprova:
assign(t,'accett.cnf');
reset(t);
readln(t,scnf);
readln(t,scnf);
close(t);
{c'era un resetstampante}
{$I-}
if scnf='80' then  write(lst,chr(27)+chr(15));{stampa in compresso}
{$I+}
if ioresult<>0 then
begin
rs:=stpnonpronta;
if rs=0 then exit;
if rs=1 then goto  riprova;
end;
if intestazionetotale = 1 then exit;
assign(fd,'cardrec.dat');
reset(fd);
repeat
repeat
read(fd,accdati);
sign:=sign+1;
with accdati do
begin
write(lst,numero_carta);
write(lst,spaces(7));
write(lst,autista);
write(lst,spaces(3));
dati_anagr:=c_instring(spaces(7)+ 'DATO NON PRESENTE'+spaces(6));{valore di default}
assign(fz,'dtes.dat');
reset(fz);
repeat
read(fz,datitess);
if datitess.numtessera  = numero_carta then dati_anagr:=c_instring(datitess.datitessera);
until (eof(fz)) or (datitess.numtessera = numero_carta);
close(fz);
write(lst,dati_anagr);
write(lst,spaces(4));
write(lst,km_percorsi);
write(lst,spaces(9));
write(lst,pompa);
write(lst,spaces(8));
val(litri,ltr,err);
ltr:=ltr/10;
write(lst,ltr:6:1);
write(lst,spaces(4));
write(lst,prezzo);
write(lst,spaces(6));
write(lst,ore+'  :');
write(lst,spaces(3));
write(lst,minuti);
write(lst,spaces(9));
write(lst,giorno+'    -');
write(lst,spaces(1));
writeln(lst,mese);
if inkeys = chr(27) then
begin
csroff;
deftextwindow(1,1,15,80,18);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(7,2);
textcolor(7);textbackground(0);
gotoxy(2,2);write(c_text('ABBANDONA LA STAMPA ? (S/N) ',76));
repeat
r:=readkey;
until (upcase(r)='S') or (upcase(r)='N');
if upcase(r) = 'S' then
begin
seltextwindow(0);
csron;
exit;
end;
clrscr;
seltextwindow(0);
end;
end;
until (sign=60) or (eof(fd));
if not (eof(fd)) then
begin
write(lst,chr(12));
if intestazionetotale =1 then exit;
end;
sign:=0;
until (eof(fd));
close(fd);
csron;
end;





procedure stampa;
var a:char;
var n:integer;
var z1,z2,z3,z4:byte;
var x1,x2,x3,x4:byte;
var c1,c2,c3,c4,c5:byte;
var s:string;
var t:text;
begin
repeat
c1:=1;c2:=0;c3:=4;c4:=7;c5:=1;
assign(t,'accett.cnf');
reset(t);
readln(t,s);
readln(t,s);
readln(t,s);
close(t);
if s='H' then
begin
c1:=0;
c2:=7;
c3:=15;
c4:=0;
c5:=0;
end;
seltextwindow(0);
textbackground(c1);
clrscr;
textcolor(7);
gotoxy(1,2);
write(c_text('STAMPA DEI DATI ACCETTATORE',80));
gotoxy(2,2);
write(gestdate);
gotoxy(1,3);
for n:=1 to 80 do write(chr(205));
deftextwindow(1,10,5,70,14);
seltextwindow(1);
paintwindow(1,c4);
frametextwindow(c3,2);
textcolor(c2);textbackground(c4);
gotoxy(2,2);write(c_text('MENU DI STAMPA',59));
z1:=c2;z2:=c4;z3:=c4;z4:=c4;
x1:=c4;x2:=c2;x3:=c2;x4:=c2;
repeat
textcolor(x1);textbackground(z1);
gotoxy(2,4);write(c_text('1.Stampa Per Tessera in un Intervallo Fra Date',59));
textcolor(x2);textbackground(z2);
gotoxy(2,6);write(c_text('2.Stampa totale dei dati',59));
textcolor(x3);textbackground(z3);
gotoxy(2,8);write(c_text('3.Ritorno al MENU PRINCIPALE',59));
csroff;
a:=readkey;
if a=chr(0) then
begin
a:=readkey;
if (a='P') and (x3<>c4) then
begin
z4:=z3;z3:=z2;z2:=z1;z1:=z4;
x4:=x3;x3:=x2;x2:=x1;x1:=x4;
end;
if (a='H')and (x1<>c4) then
begin
z1:=z2;z2:=z3;z3:=z4;z4:=z1;
x1:=x2;x2:=x3;x3:=x4;x4:=x1;
end;
end;
until (a=chr(13)) or (a in ['1'..'3']);
if (z1=c2) and (a=chr(13)) or (a='1') then
begin
deftextwindow(1,19,4,61,17);
seltextwindow(1);
paintwindow(1,c5);
seltextwindow(0);
textcolor(7);
stampaintervallo(s);
end;
if (z2=c2) and (a=chr(13)) or (a='2') then
begin
deftextwindow(1,9,4,71,15);
seltextwindow(1);
paintwindow(1,c5);
seltextwindow(0);
textcolor(7);
stampatotale(s);
end;
if (z3=c2) and (a=chr(13)) or (a='3') then
begin
seltextwindow(0);
textbackground(0);
clrscr;
exit;
end;
until (z4=c2);
end;






function cancellazione:integer;
var f,t:text;
var s,drive:string;
var c1,c2:byte;
rc:longint;
size:longint;
a,m,g,o,min,sec:byte;
attr,s1,s2,s3:string;
z,y:notcarattertype;
u:charok;
v:char;
ch:char;
num_s:string;
begin
cancellazione:=0;
assign(t,'accett.cnf');
assign(fd,'cardrec.dat');
assign(f,'cardself.dat');
reset(t);
readln(t,s3);
readln(t,s3);
readln(t,s3);
close(t);
c1:=4;c2:=1;
if s3='H' then
begin
c1:=0;
c2:=0;
end;
seltextwindow(0);
textbackground(c2);
clrscr;
deftextwindow(1,1,1,80,4);
seltextwindow(1);
paintwindow(1,c1);
frametextwindow(15,2);
gotoxy(3,2);write(c_text('CANCELLAZIONE FILE',74));
gotoxy(3,2);write(gestdate);
deftextwindow(2,40,5,80,10);
seltextwindow(2);
paintwindow(2,0);
frametextwindow(7,2);
getdir(0,s);
drive:=copy(s,1,1);
gotoxy(3,2);write('Il drive ');write(drive);write(' ha : ');write(diskfree(0));
write(' bytes liberi');
gotoxy(3,3);write('su un totale di ');write(disksize(0));writeln(' bytes');
gotoxy(3,4);writeln('la directory corrente e''');
gotoxy(18,5);write(s);
deftextwindow(3,1,12,80,21);
seltextwindow(3);
paintwindow(3,0);
frametextwindow(7,2);
gotoxy(3,2);
write('Il file di record e'' frutto dell''elaborazione fatta dal programma');
gotoxy(3,3);
write('sul file di dati originale.');
textcolor(15);textbackground(0);
gotoxy(3,4);
write('Cancellando questo file si provoca la perdita delle informazioni immesse.');
textcolor(7);textbackground(0);
gotoxy(3,5);
write('Cancellando il file di dati si puo'' continuare a lavorare su quello di');
gotoxy(3,6);write('record.');
gotoxy(3,7);
write('Cancellando entrambi i file si deve inserire un nuovo file di dati ');
gotoxy(3,8);
write('per una nuova elaborazione."Cardrec.dat" e'' il file di record mentre');
gotoxy(3,9);
write('"Cardself.dat" e'' il file di dati.');
seltextwindow(0);
textbackground(c2);
gotoxy(2,6);write('File da Cancellare : ');
gotoxy(2,8);write('CARDREC.DAT');
fileinfo('cardrec.dat',size,a,m,g,o,min,sec,attr);
if size <0 then size :=65536+size;
gotoxy(16,8);write(size);
gotoxy(24,8);write(attr);
fileinfo('cardself.dat',size,a,m,g,o,min,sec,attr);
if size <> -1 then
begin
gotoxy(2,10);write('CARDSELF.DAT');
if size <0 then size :=65536+size;
gotoxy(16,10);write(size);
gotoxy(24,10);write(attr);
end;
csroff;
deftextwindow(1,1,22,80,25);
seltextwindow(1);
paintwindow(1,0);
frametextwindow(15,2);
gotoxy(3,2);
write('PROCEDERE CON LA CANCELLAZIONE DEL RECORD CARDREC.DAT ? (S/N)');
repeat
ch:=readkey;
until (upcase(ch) ='S') or (upcase(ch) ='N');
if upcase(ch) = 'N' then
begin
seltextwindow(0);
cancellazione:=0;
end;
if upcase(ch) ='S' then
begin
repeat
textcolor(7);textbackground(0);
gotoxy(3,2);write('Inserire la Parola Riservata e Premere enter,per uscire Escape');
textcolor(0);textbackground(7);
gotoxy(38,3);write(spaces(4));
z:=[chr(27)];y:=[];u:=[chr(30)..chr(127)];
v:=chr(13);
num_s:=inputctext(38,3,4,z,y,u,v);
if num_s='1f7%' then
begin
erase(fd);
reset(t);
readln(t,s1);
readln(t,s1);
readln(t,s2);
rewrite(t);
writeln(t,0);
writeln(t,s1);
writeln(t,s2);
close(t);
deftextwindow(1,1,22,80,25);
paintwindow(1,0);
seltextwindow(1);
clrscr;
cancellazione:=1;
end;
if num_s=chr(27)+'0' then
begin
cancellazione:=0;
textbackground(0);textcolor(7);
clrscr;
end;
if (num_s <> chr(27)+'0') and (num_s<>'1f7%') then
begin
beep;
end;
until (num_s=chr(27)+'0') or (num_s='1f7%');
seltextwindow(0);
end;
if size<>-1 then
begin
gotoxy(3,24);textbackground(0);textcolor(7);
write('PROCEDERE CON LA CANCELLAZIONE DEI DATI ORIGINE  CARDSELF.DAT ? (S/N)');
repeat
ch:=readkey;
until(upcase(ch) ='S') or (upcase(ch)='N');
if upcase(ch)='N'  then  exit;
erase(f);
reset(t);
readln(t,s1);
readln(t,s1);
readln(t,s1);
rewrite(t);
writeln(t,0);
writeln(t,s1);
writeln(t,s2);
close(t);
end;
end;






procedure setorologio(s:string);
begin
impulsitimer:=0;
segmvideo:=$B000;
if s='C'then segmvideo:=$B800;
base:=288;
setintvec($1c,oldint);
getintvec($1c,oldint);
Setintvec($1C,@cheoresono);
end;






function configurazione:string;
var n,n1,n2,b1,b2:integer;
a:char;
s,c1,c2,s1,s2,s3,ris:string;
t:text;
begin
seltextwindow(0);
textbackground(0);
textcolor(7);
clrscr;
gotoxy(1,2);
write(c_text('CONFIGURAZIONE',80));
gotoxy(2,2);write(gestdate);
gotoxy(1,4);
for n:=1 to 80 do write(chr(205));
assign(t,'accett.cnf');
reset (t);
readln(t,s1);
readln(t,s2);
readln(t,s3);
close(t);
gotoxy(2,5);write(c_text('LA VOSTRA CONFIGURAZIONE ATTUALE E'' :',76));
gotoxy(2,7);write('Stampante :'+s2+' colonne ad aghi');
if s3='C'then ris:='a  Colori';
if s3='H'then ris:='in  Bianco e Nero';
gotoxy(2,9);write('Monitor '+ris);
gotoxy(2,11);write('Volete Modificare la Vostra Configurazione ? (S/N)');
repeat
a:=readkey;
until (upcase(a)='S') or (upcase(a)='N');
if upcase(a)='N' then
begin
configurazione:=s3;
exit;
end;
deftextwindow(1,1,5,80,25);
seltextwindow(1);
clrscr;
seltextwindow(0);
gotoxy(1,6);writeln(c_text('La stampante in vostro possesso e'' a 80 colonne o a 132 ?',80));
writeln;
write(c_text('scegliere uno dei due tipi',80));
gotoxy(2,20);write('Per scegliere  '+chr(24)+' '+chr(25));
gotoxy(2,21);write('Per memorizzare la scelta premere ''INVIO''');
n1:=0;b1:=7;n2:=7;b2:=0;
csroff;
repeat
gotoxy(27,12);textcolor(n1);textbackground(b1);
write(c_text('132 colonne',27));
gotoxy(27,14);textcolor(n2);textbackground(b2);
write(c_text('80 colonne',27));
a:=readkey;
if a =chr(0) then
begin
a:=readkey;
if (a='P') and (n1=0) then
begin
n1:=n2;b1:=b2;
n2:=0;b2:=7;
end;
if (a='H') and (n2=0) then
begin
n2:=n1;b2:=b1;
n1:=0;b1:=7;
end;
end;
until a=chr(13);
if n1=0 then c1:='132';
if n2=0 then c1:='80';
assign(t,'accett.cnf');
reset(t);
read(t,s);
close(t);
rewrite(t);
writeln(t,s);
writeln(t,c1);
textcolor(7);textbackground(0);
gotoxy(2,16);write('Il vostro video e'' hercules ? (S/N)');
repeat
a:=readkey;
until (upcase(a)='S') or (upcase(a)='N');
if upcase(a)='S' then c2:='H';
if upcase(a)='N' then c2:='C';
setorologio(c2);
writeln(t,c2);
close(t);
configurazione:=c2;
end;



{main}
var ss:byte;
var n:integer;
var s:string;
var t:text;
begin
if control<>0 then
begin
clrscr;
textmode(BW80);
exit;
end;
Impulsitimer:=0;
base:=288;
segmvideo:=$B000;
assign(t,'accett.cnf');
{$I-}
reset(t);
{$I+}
if ioresult =0 then
begin
readln(t,s);
readln(t,s);
readln(t,s);
close(t);
if s='C' then segmvideo:=$B800;
end;
Getintvec($1c,OldInt);
Setintvec($1c,@cheoresono);
n:=0;
repeat
if trasformafile=0 then
begin
setintvec($1c,Oldint);
textmode(BW80);
exit;
end;
ss:=presentazione;
if ss=0 then ss:=4;
if ss=1 then presentadati(s);
if ss=2 then ricercaintervallo;
if ss=3 then stampa;
if ss=5 then n:=cancellazione;
if ss=6 then s:=configurazione;
if n=1 then ss:=4;
until ss=4;
clrscr;
setintvec($1c,Oldint);
textmode(CO80);
end.
