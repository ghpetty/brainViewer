%% inlinePercent_bv(i,I,di)
%  A function to be run in loops to display the percent completed.
%  Displays within a single line on the terminal
%
% Arguments:
% i:  the counting variable being used in the loop
% I:  the max value the counting variable will reach
% di: the minimum change in percent across steps reported. Defaults to 1.
%     This works best if set to 0.1,0.5,1, or 5

function inlinePercent_bv(i,I,di)
    percDone = floor(100*i/I/di)*di;
    percDoneLast = floor(100*(i-1)/I/di)*di;
    
    if ~isequal(percDone,percDoneLast)
        if percDone == di
            % Don't try and overwrite if nothing has been printed yet
            fprintf('%c',[num2str(percDone),'%']);
        else
            % Backspace several places:
            fprintf(repmat('\b',1,length(num2str(percDoneLast))+1));
            fprintf('%c',[num2str(percDone),'%']);
            if percDone == 100
                disp(newline)
            end
        end        
    end
    
 end