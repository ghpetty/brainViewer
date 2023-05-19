function inlineProgressBar_bv(i,I,L)
% Similar to printProgressBar, but overwrites on a single line rather than
% new lines. Does not work with parfor.
% i: Iterator value
% I: Max value for i, i.e. number of loops running
% L: Total length of the progress bar. Also determines how often it
% updates.


fracDone = floor(i/I*L);
fracDonePrev = floor((i-1)/I*L);
v = ['[',repmat(' ',1,L),']'];
if i == 1
    fprintf(v);
else
    if (fracDonePrev ~= fracDone)
        fprintf(repmat('\b',1,length(v)));
        v((1:fracDone)+1) = '|';
        fprintf(v);
        if i==I
            disp(newline);
        end
    end
end
% 
% 
% percDone = floor(100*i/I/di)*di;
%     percDoneLast = floor(100*(i-1)/I/di)*di;
%     
%     if ~isequal(percDone,percDoneLast)
%         if percDone == di
%             % Don't try and overwrite if nothing has been printed yet
%             fprintf('%c',[num2str(percDone),'%']);
%         else
%             % Backspace several places:
%             fprintf(repmat('\b',1,length(num2str(percDoneLast))+1));
%             fprintf('%c',[num2str(percDone),'%']);
%             if percDone == 100
%                 disp(newline)
%             end
%         end        
%     end
