classdef proScanner < handle
    properties
        % Figures
        fig_gui = 0;
        im_gui = 0;
        
        fig_scan = 0;
        im_scan = 0;
        
        % Camera
        cam = 0;
        
        % Camera parameters
        PPc = [374.1, 534.3] - [0, 240]; % camera optical center [pixels]
        Fc = 0.95*1037; % camera focal length [pixels]
        height = 720; % Hardcoded. bad.
        width = 800; % Hardcoded. bad.
        
        % Projector parameters
        PPp = -15; % projector optical center [pixels]
        Fp = 71/26*100; % projector "focal length" [pixels]
        frames = 100; % [pixels]
        widthp = 140; % [pixels]
        brightness = 1; % range [0,1]
        
        % Camera/projector parameters
        Lx = -0.27; % baseline [m]
        Lz = -0.14; % projector backset [m]
        angle = 0; % [rad]
        
        % Scanner parameters
        diff_thresh = 0.9;
        step = 2;
        delay = 0;
        scan_runs = 0;
        
        % Data
        midlines;
        im_bright;
        im_dark;
        pts;
        colors;
        
        
        % Debugging
        ims;
        diffs;
        
    end
    
    methods
        function o = proScanner()
            % Create GUI figure
            o.fig_gui = figure(1);
            clf
            o.im_gui = imshow(zeros(o.height,o.width));
            set(gca,'Position',[0,0.2,1,0.7])
            
            scan_button = uicontrol(o.fig_gui, 'Style', 'Pushbutton', 'Position', [10,10,90,20], ...
                'String', 'Scan', 'callback', @o.scan);
            points_button = uicontrol(o.fig_gui, 'Style', 'Pushbutton', 'Position', [110,10,90,20], ...
                'String', 'Points', 'callback', @o.findPts);
            show_button = uicontrol(o.fig_gui, 'Style', 'Pushbutton', 'Position', [210,10,90,20], ...
                'String', 'Show', 'callback', @o.showPts);
            clear_button = uicontrol(o.fig_gui, 'Style', 'Pushbutton', 'Position', [310,10,90,20], ...
                'String', 'Clear', 'callback', @o.clearClouds);
            
            brightness_slider = uicontrol(o.fig_gui, 'Style', 'Slider', 'Position', [10,40,190,20], ...
                'Value',1,'Min',0,'Max',1);
            combine_button = uicontrol(o.fig_gui, 'Style', 'Pushbutton', 'Position', [210,40,90,20], ...
                'String', 'Combine', 'callback', @o.combine);
            
            % Create scanner figure
            o.fig_scan = figure(2);
            clf
            o.im_scan = imshow(zeros(o.frames,o.widthp));
            set(gca,'pos',[0,0.01,1,.98])
            set(gcf,'color',[1,0,0])
            set(gcf,'toolbar','none')
            
            % Open webcam
            o.cam = webcam;
            
            % Initialize variables
            o.ims = zeros(o.height,o.width,3,o.frames);
            
            while(1)
                im = snapshot(o.cam);
                set(o.im_gui, 'cdata', fliplr(im(:,241:1040,:)));
                drawnow
                pause(0.05);
                
                % Hack: set parameters
                o.brightness = get(brightness_slider, 'value');
            end
        end
        
        function [midlines, im_bright, im_dark] = scan(o,varargin)
            % Prepare scanner
            set(o.im_scan, 'cdata', zeros(o.frames, o.widthp));
            drawnow
            snapshot(o.cam);
            
            [xinds,~] = meshgrid(1:o.width, 1:o.height);
            
            o.midlines = zeros(o.height, o.frames-o.step);
            
            % Wait
            pause(o.delay)
            
            im = snapshot(o.cam);
            o.im_dark = im(:,241:1040,:);
            o.ims(:,:,:,1) = o.im_dark;
            
            % Scan
            for ii = 1:o.frames
                set(o.im_scan, 'cdata', [zeros(o.frames-ii,o.widthp); o.brightness * ones(ii,o.widthp)])
                drawnow
                im = snapshot(o.cam);
                o.ims(:,:,:,ii) = im(:,241:1040,:);
            end
            
            o.im_bright = o.ims(:,:,:,end);
            
            % Turn off scanner
            set(o.im_scan, 'cdata', zeros(o.frames, o.widthp))
            drawnow
            
            for ii = 1:(o.frames-o.step)
                scan_diff = (o.ims(:,:,:,ii+o.step) - o.ims(:,:,:,ii))/255;
                change = sum(scan_diff,3) > o.diff_thresh;
                coords = xinds.*change;
                coords(coords == 0) = NaN;
                o.midlines(:,ii) = median(coords, 2, 'omitnan');
            end
            
            o.midlines(isnan(o.midlines)) = 0;
            
            o.scan_runs = o.scan_runs+1;
            
            midlines = o.midlines;
            im_bright = o.im_bright;
            im_dark = o.im_dark;
            
            o.findPts();
        end
        
        function [pts, colors] = findPts(o,varargin)
            if isempty(o.midlines) || isempty(o.im_dark)
                disp('Run a scan before finding points.')
                return
            end
            
            xs = zeros(o.height,o.frames - o.step);
            ys = zeros(o.height,o.frames - o.step);
            zs = zeros(o.height,o.frames - o.step);
            colors = zeros(o.height,o.frames - o.step,3);

            im = o.im_dark;
            
            % Create point cloud
            for ii = 1:(o.frames - o.step)
                uc = o.midlines(:,ii) - o.PPc(2);
                up = -o.PPp + ii;

                zs(:,ii) = (-o.Lx + up/o.Fp*o.Lz)./(up/o.Fp - uc/o.Fc);
                xs(:,ii) = uc/o.Fc .* zs(:,ii);
                ys(:,ii) = (-o.PPc(1) + (1:o.height))/o.Fc .*zs(:,ii)';

                inds = sub2ind([o.height,o.width], 1:o.height, max(round(o.midlines(:,ii)),1)');
                colors(:,ii,:) = cat(3,im(inds),im(inds+o.height*o.width),im(inds+o.height*o.width*2));

                zs(o.midlines(:,ii)==0,ii) = NaN;
                xs(o.midlines(:,ii)==0,ii) = NaN;
                ys(o.midlines(:,ii)==0,ii) = NaN;
            end
            
            pts = [zs(:),-xs(:),-ys(:)];
                        
            o.pts{o.scan_runs} = pts;
            o.colors{o.scan_runs} = reshape(colors,[o.height*(o.frames - o.step),3])/255;
            
            assignin('base','pts',o.pts);
            assignin('base','colors',o.colors);
            
            o.showPts();
        end
        
        function showPts(o,varargin)
            figure(3)
            pcshow(o.pts{o.scan_runs},o.colors{o.scan_runs},'markersize',50);
            set(gca,'xlim',[0,3],'ylim',[-.8,.8],'zlim',[-1,1]);
            
            in_button = uicontrol(gcf, 'Style', 'Pushbutton', 'Position', [10,10,40,20],...
                'String', 'In', 'callback', ...
                ['set(gca,''xlim'',get(gca,''xlim'')*0.8),',...
                'set(gca,''ylim'',get(gca,''ylim'')*0.8),',...
                'set(gca,''zlim'',get(gca,''zlim'')*0.8)']);
            out_button = uicontrol(gcf, 'Style', 'Pushbutton', 'Position', [60,10,40,20], ...
                'String', 'Out', 'callback', ...
                ['set(gca,''xlim'',get(gca,''xlim'')*1.25),',...
                'set(gca,''ylim'',get(gca,''ylim'')*1.25),',...
                'set(gca,''zlim'',get(gca,''zlim'')*1.25)']);
            set(gcf,'toolbar','figure')
        end
        
        function clearClouds(o,varargin)
            o.pts = {};
            o.colors = {};
            o.scan_runs = 0;
            
            assignin('base','pts',o.pts);
            assignin('base','colors',o.colors);
        end
        
        function combine(o,varargin)
            combineTwoViews(o.pts{1},o.colors{1},o.pts{2},o.colors{2})
        end
    end
                
end
            
            