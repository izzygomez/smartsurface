function [ s,flag ] = setupSerial( comPort )
s=serial(comPort);
set(s,'DataBits',8);
set(s,'StopBits',1);
set(s,'BaudRate',115200);
set(s,'Parity','none');
fopen(s);
a='b';
while(a~='a')
    a=fread(s,1,'uchar');
end

if(a=='a')
    disp('serial read');
end
% 
% fprintf(s,'%c','a');
% flag=1;
% mbox=msgbox('Serial Communication Setup.'); uiwait(mbox);
% fscanf(s,'%u');


s.BytesAvailable
meas = fscanf(s)

end



