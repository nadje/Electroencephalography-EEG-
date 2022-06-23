function plotting2_avgWave(data1, data2, data3,data4,difference,stat_clu, stat_clu2, legnames,titl,makeitguapo,loc,stats, interaction,t)
%% Set colors
Analysis_folder_LargerEpochs = '/DATA2/BLB_EXP_201902_SGMem2/Analysis/MEEG/LargerEpochs/'

analysis_path = '/DATA2/BLB_EXP_201902_SGMem2/BLB_BackUp_files/Protocols/Analysis_Scripts/Pupillometry';
% add plugins needed
addpath([analysis_path '/Tools-master_AU/eye']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/boundedline']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/catuneven']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/Inpaint_nans']);
addpath([analysis_path '/Tools_Nadia/boundedline-pkg-master/boundedline-pkg-master/singlepatch']);

addpath([analysis_path '/Tools-master_AU/plotting']);
addpath([analysis_path '/Tools-master_AU/plotting/cbrewer'])
set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');
% data1=GA_R_retr_2T_EPR_obs; data2=GA_F_retr_2T_EPR_obs
% general graphics, this will apply to any figure you open (groot is the default figure object).
% I have this in my startup.m file, so I don't have to retype these things whenever plotting a new fig.
set(groot, ...
    'DefaultFigureColorMap', linspecer, ...
    'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 0.8, ...
    'DefaultAxesXColor', 'k', ...
    'DefaultAxesYColor', 'k', ...
    'DefaultAxesFontUnits', 'points', ...
    'DefaultAxesFontSize', 20, ...
    'DefaultAxesFontName', 'Helvetica', ...
    'DefaultLineLineWidth', 1, ...
    'DefaultTextFontUnits', 'Points', ...
    'DefaultTextFontSize', 20, ...
    'DefaultTextFontName', 'Helvetica', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.025]);
colors = cbrewer('qual', 'Set1', 8);

%% PLOT
% Time and fsample for deconvol
time =stat_clu.time;
%% PLOT
fsample = 500;
switch interaction
    case 0
        figure;
     %   enc = plot(time,  data1.avg, time, data2.avg)
        enc =boundedline(time, mean(data1.avg), 0,...
            time, mean(data2.avg),0, ...
            'cmap', colors, 'transparency', 1);
        ylims = get(gca, 'ylim');
        du=0.1; 
        if ~isempty(t)
        for i = 1:length(t)
            du=du-0.1;
            line([t{i}(1) t{i}(end)], [ylims(2)-du ylims(2)-du], 'LineWidth', 2, 'Color', 'k');
              end
     
        else
            disp('no sign');
        end
        hold on;
        i = 0.2
        
        lh = legend(enc);
        for i = 1:length(legnames),
            str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
        end
        set(gca,'Ydir','reverse')

        lh.String = str;
        lh.Box = 'off';
        lh.FontSize=12;
        if loc == 1
            lh.Location = 'NorthEast';
        else
            lh.Location = 'South';
            
        end
        lpos = lh.Position;
        
        lpos(1) = lpos(1)
        lh.Position = lpos
        ylims = get(gca, 'ylim');
        axis tight;
        ylim([min(ylims) max(ylims)]);
        xvals = time(1):.01:time(end);
        xt=time(1):.05:time(end);
        xlim([min(xvals) max(xvals)]); % some space at the sides
        xlabel('Time'); set(gca, 'xtick', xt);
        
        ylabel('mV');
        xlims = get(gca,'xlim')
        t = title(titl)
        t.FontSize = 14
      
           figure;
        topoplot_ERPs(stat_clu,difference,titl);
       
        % Case 1 for interactions between Memory and Sound for 2T seqs
    case 1
        colors = cbrewer('qual', 'Paired', 8);
        colors = colors([1:2,5:6],:)
        enc =boundedline(time, mean(data1.avg), 0,...
            time, mean(data2.avg), 0, ...
            time,mean(data3.avg),0,...
            time, mean(data4.avg),0,...
            'cmap', colors, 'transparency', 0.1); %eA)
        ylims = get(gca, 'ylim');
        hold on;
        i = 0.2
         du=0.1; 
        if ~isempty(t)
        for i = 1:length(t)
            
            %rectangle('Position',[t{i}(1) 0 diff(t{i}) 1],'EdgeColor',c(i))
            line([t{i}(1) t{i}(end)], [ylims(2)-du ylims(2)-du], 'LineWidth', 2, 'Color', 'k');
            du=du-0.1;
           % text(t{i}(1),(ylims(2)+du-0.1), 'p < .05', 'FontSize', 11);
        end
     
        else
            disp('no sign');
%              line([time(1) time(end)], [ylims(2)-du ylims(2)-du], 'LineWidth', 1, 'Color', 'k');
%            
%             text(time(1),(ylims(2)+du+0.2), 'n.s.', 'FontSize', 12);
        end
        lh = legend(enc);
        for i = 1:length(legnames),
            str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
        end
        set(gca,'Ydir','reverse')

        lh.String = str;
        lh.Box = 'off';
        lh.FontSize=12;
        if loc == 1
            lh.Location = 'NorthEast';
        else
            lh.Location = 'South';
            
        end
       lpos = lh.Position;
        
        lpos(1) = lpos(1)
        lh.Position = lpos
        ylims = get(gca, 'ylim');
        axis tight;
        ylim([min(ylims) max(ylims)]);
        xvals = time(1):.01:time(end);
        xt=time(1):.05:time(end);
        xlim([min(xvals) max(xvals)]); % some space at the sides
        xlabel('Time'); set(gca, 'xtick', xt);
        
        ylabel('mV');
        xlims = get(gca,'xlim')
        t = title(titl)
        t.FontSize = 14
      
           figure;
        topoplot_ERPs(stat_clu,difference,titl);
     
        % Case 2 is for ONE way anova
    case 2
        colors = cbrewer('qual', 'Set1', 8);
        %colors = colors([1:2,5:6],:)
       enc =boundedline(time, mean(data1.avg), 0,...
            time, mean(data2.avg), 0, ...
            time, mean(data3.avg),0,...
            'cmap', colors, 'transparency', 0.1); %eA)
        ylims = get(gca, 'ylim');
        hold on;
        i = 0.2
        i = 0.2
         du=0.1; 
        if ~isempty(t)
        for i = 1:length(t)
            
            %rectangle('Position',[t{i}(1) 0 diff(t{i}) 1],'EdgeColor',c(i))
            line([t{i}(1) t{i}(end)], [ylims(2)-du ylims(2)-du], 'LineWidth', 2, 'Color', 'k');
            du=du-0.1;
           % text(t{i}(1),(ylims(2)+du-0.1), 'p < .05', 'FontSize', 11);
        end
     
        else
            disp('no sign');
%              line([time(1) time(end)], [ylims(2)-du ylims(2)-du], 'LineWidth', 1, 'Color', 'k');
%            
%             text(time(1),(ylims(2)+du+0.2), 'n.s.', 'FontSize', 12);
        end
        lh = legend(enc);
        for i = 1:length(legnames),
            str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
        end
        set(gca,'Ydir','reverse')

        lh.String = str;
        lh.Box = 'off';
        lh.FontSize=12;
        if loc == 1
            lh.Location = 'NorthEast';
        else
            lh.Location = 'South';
            
        end
       lpos = lh.Position;
        
        lpos(1) = lpos(1)
        lh.Position = lpos
        ylims = get(gca, 'ylim');
        axis tight;
        ylim([min(ylims) max(ylims)]);
        xvals = time(1):.01:time(end);
        xt=time(1):.05:time(end);
        xlim([min(xvals) max(xvals)]); % some space at the sides
        xlabel('Time'); set(gca, 'xtick', xt);
        
        ylabel('mV');
        xlims = get(gca,'xlim')
        t = title(titl)
        t.FontSize = 14
    
        
end

  
end
%
% if stats ==1