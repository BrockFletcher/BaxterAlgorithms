%% User Inputs
CellCountPlane=1;
OutputPerWell = true;
OutputFCS = true;
exportdir=char('D:\Dropbox (VU Basic Sciences)\Duvall Confocal\Duvall Lab\Jackey\2022-09-15-Gal8-ConjugatesChloroquine\Analysis\Outputs\FCSExport');

%% Code 
% 
TestTable=Tablebig;
TestTable2=TestTable;
InputTable=TestTable2


PreppedTable=removevars(InputTable,["Centroid","BoundingBox"]);
PreppedTable=convertvars(PreppedTable,@isnumeric,'single');
SumInt=(PreppedTable{:,"Area"}.*PreppedTable{:,"MeanIntensity"});
PreppedTable.SumIntensity=SumInt;
PreppedTable(ismember(PreppedTable.Cell,0),:)=[];



%% WholeWellDataPrep
if OutputPerWell
WellTimeAnaPlaneData=groupsummary(PreppedTable,["WellNum","TimeNum","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
WellTimeAnaData=unstack(WellTimeAnaPlaneData,[5:width(WellTimeAnaPlaneData)],{'ImgPlane'});
WellTimeData=unstack(WellTimeAnaData,[4:width(WellTimeAnaData)],{'AnaPass'});

writetable(WellTimeData,strcat(exportdir,'\','WellTimeData.xlsx'));
writetable(WellTimeAnaData,strcat(exportdir,'\','WellTimeAnaData.xlsx'));
writetable(WellTimeAnaPlaneData,strcat(exportdir,'\','WellTimeAnaPlaneData.xlsx'));
end

%% FlowCytometryDataPrep

if OutputFCS
PerCellData = groupsummary(PreppedTable,["WellNum","TimeNum","Cell","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
FlowbyCellAnaPlane=removevars(PerCellData,["GroupCount"]);


FlowbyCellPlane=unstack(FlowbyCellAnaPlane,[6:width(FlowbyCellAnaPlane)],{'AnaPass'});
 FlowbyCell=unstack(FlowbyCellPlane,[5:width(FlowbyCellPlane)],{'ImgPlane'});

 FCSOutData=single(table2array(FlowbyCell));
FCSOutData(isnan(FCSOutData))=0;
 
 WellColumn=FCSOutData(:,1);
 TimeColumn=FCSOutData(:,2);
TEXT.PnN = FlowbyCell.Properties.VariableNames;



    for i=1:max(FlowbyCell.WellNum)
            
            WellPoint = num2str(i,'%03.f');
            CurrWell=FCSOutData(WellColumn==i,:);
            TimeColumn=CurrWell(:,2);
        for j=1:max(TimeColumn)
                Timepoint = num2str(j,'%03.f'); %Creates a string so that the BioFormats can read it
                CurrTime=CurrWell(TimeColumn==j,:);
                WellID=strcat('w',WellPoint,'t',Timepoint)
                FCSFileName=strcat(exportdir,'\',WellID,'.fcs') ; 
                TEXT.WELLID=WellID;
                TEXT.FIL=WellID;
                writeFCS(FCSFileName,CurrTime,TEXT); 

        end
    end
end



