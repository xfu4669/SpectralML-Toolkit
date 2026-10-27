function [d,accepted] = importDialog(owner,filename)
d=[]; accepted=false;
win=uifigure('Name','Import data','Position',[180 160 880 540],'WindowStyle','modal','Color',[0.97 0.98 0.99]);
win.CloseRequestFcn=@(~,~)delete(win);
g=uigridlayout(win,[9 2]); g.ColumnWidth={260,'1x'};
g.RowHeight={48,44,44,44,44,44,44,'1x',46}; g.Padding=[22 18 22 18]; g.RowSpacing=10;
label=uilabel(g,'Text',filename,'Interpreter','none','WordWrap','on'); label.Layout.Column=[1 2];
uilabel(g,'Text','Sample ID column'); id=uieditfield(g,'numeric','Value',1);
uilabel(g,'Text','Target column'); target=uieditfield(g,'numeric','Value',2);
uilabel(g,'Text','First spectral column'); start=uieditfield(g,'numeric','Value',3);
uilabel(g,'Text','Excel sheet'); sheet=uieditfield(g,'text','Value','1');
uilabel(g,'Text','Custom wavelengths'); wave=uieditfield(g,'text','Tooltip','Leave blank to read wavelength headers, or enter 400:20:1600.');
index=uicheckbox(g,'Text','Use band indices','Value',false); index.Layout.Column=[1 2];
cancel=uibutton(g,'Text','Cancel','BackgroundColor','w','ButtonPushedFcn',@(~,~)delete(win)); cancel.Layout.Row=9; cancel.Layout.Column=1;
confirmButton=uibutton(g,'Text','Import','BackgroundColor',[0.14 0.39 0.67],'FontColor','w', ...
    'FontWeight','bold','ButtonPushedFcn',@confirm); confirmButton.Layout.Row=9; confirmButton.Layout.Column=2;
applyUIFonts(win,18);
uiwait(win);
    function confirm(~,~)
        try
            sh=sheet.Value; numeric=str2double(sh); if isfinite(numeric), sh=numeric; end
            options=struct('idColumn',id.Value,'targetColumn',target.Value,'spectralStartColumn',start.Value, ...
                'sheet',sh,'indexMode',index.Value,'wavelengths',parseNumberList(wave.Value));
            d=importData(filename,options); accepted=true; delete(win);
        catch e
            uialert(win,e.message,'Import failed','Interpreter','none');
        end
    end
end
