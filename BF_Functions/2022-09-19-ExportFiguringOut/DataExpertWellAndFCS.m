%% User Inputs
CellCountPlane=1;
OutputPerWell = false;
OutputFCS = true;
exportdir=char('D:\Dropbox (VU Basic Sciences)\Duvall Confocal\Duvall Lab\Jackey\2022-09-15-Gal8-ConjugatesChloroquine\Analysis\Outputs\FCSExport');

%% Code 

TestTable=Tablebig;
TestTable2=TestTable;
InputTable=TestTable2;


PreppedTable=removevars(InputTable,["Centroid","BoundingBox"]);
SumInt=(PreppedTable{:,"Area"}.*PreppedTable{:,"MeanIntensity"});
PreppedTable.SumIntensity=SumInt;
PreppedTable(ismember(PreppedTable.Cell,0),:)=[];



%% WholeWellDataPrep
if OutputPerWell

WellTimeAnaPlaneData=groupsummary(PreppedTable,["WellNum","TimeNum","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
WellTimeAnaData=unstack(WellTimeAnaPlaneData,[5:width(WellTimeAnaPlaneData)],{'ImgPlane'});
WellTimeData=unstack(WellTimeAnaData,[4:width(WellTimeAnaData)],{'AnaPass'});
writetable(WellTimeData,strcat(exportdir,'WellTimeData.xlsx'));
writetable(WellTimeAnaData,strcat(exportdir,'WellTimeAnaData.xlsx'));
writetable(WellTimeAnaPlaneData,strcat(exportdir,'WellTimeAnaPlaneData.xlsx'));
end

%% FlowCytometryDataPrep

if OutputFCS
PerCellData = groupsummary(PreppedTable,["WellNum","TimeNum","Cell","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
FlowbyCellAnaPlane=removevars(PerCellData,["GroupCount"]);
% FlowPrep(ismember(FlowPrep.Cell,0),:)=[];

FlowbyCellPlane=unstack(FlowbyCellAnaPlane,[6:width(FlowPrep)],{'AnaPass'});
FlowbyCell=unstack(FlowbyCellPlane,[5:width(FlowbyCellPlane)],{'ImgPlane'});

FlowbyCell2=convertvars(FlowbyCell,@isnumeric,'single');
% FlowbyCell2(~ismember(FlowbyCell2{:,CellCountPlane+3},1),:)=[];
FCSOutData=single(table2array(FlowbyCell2));
WellColumn=FCSOutData(:,1);
TimeColumn=FCSOutData(:,2);
TEXT.PnN = FlowbyCell2.Properties.VariableNames;
PleaseWork=groupsummary(FlowbyCell2,'WellNum','max');

%                FlowGroups=table2struct(PleaseWork);

    for i=1:max(FlowbyCell2.WellNum)
            
            WellPoint = num2str(i,'%03.f');
            CurrWell=FCSOutData(WellColumn==i,:);

        for j=1:max(FlowbyCell2.TimeNum)
                Timepoint = num2str(j,'%03.f'); %Creates a string so that the BioFormats can read it
                CurrTime=CurrWell(TimeColumn==j,:);
                
                FCSFileName=strcat(exportdir,'\','w',WellPoint,'t',Timepoint,'.fcs') ; 
     
                writeFCS(FCSFileName,CurrTime,TEXT); 

        end
    end
end



