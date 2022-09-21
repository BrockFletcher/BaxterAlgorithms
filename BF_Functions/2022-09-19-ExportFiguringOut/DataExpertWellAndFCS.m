%User Inputs
CellCountPlane=1;

TestTable=Tablebig;
TestTable2=TestTable(1:1068,:);
InputTable=TestTable2;
PreppedTable=removevars(InputTable,["Centroid","BoundingBox"]);
SumInt=(PreppedTable{:,"Area"}.*PreppedTable{:,"MeanIntensity"});
PreppedTable.SumIntensity=SumInt;
 PreppedTable(ismember(PreppedTable.Cell,0),:)=[];

%% FlowCytometryDataPrep
PerCellData=groupsummary(PreppedTable,["WellNum","TimeNum","Cell","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
FlowPrep=unstack(PerCellData,[7:width(PerCellData)],{'ImgPlane'});
% FlowPrep2=unstack(FlowPrep,[6:width(FlowPrep)],{'AnaPass'});
% FlowPrepFlip=rows2vars(FlowPrep);
% FlowPrepFlip.Properties.RowNames=FlowPrepFlip.(1);
% FlowPrepFlip=removevars(FlowPrepFlip,"OriginalVariableNames");
% FlowReadyDataunique=unique(FlowPrepFlip,'stable');
% PerCellClean=rows2vars(FlowPrep);
% PerCellClean=removevars(PerCellClean,"OriginalVariableNames");
FlowPrep(ismember(FlowPrep.Cell,0),:)=[];
% PerCellClean(PerCellClean.c4>PerCellClean.c1,:)=[];
FlowbyCell=unstack(FlowPrep,[6:width(FlowPrep)],{'AnaPass'});
FlowbyCell2=convertvars(FlowbyCell,@isnumeric,'single');
FlowbyCell2(~ismember(FlowbyCell2{:,CellCountPlane+3},1),:)=[];
% FlowMax=max(FlowbyCell2)
% ColText=cell2struct([],FlowbyCell2.Properties.VariableNames,1)
FCSOutData=single(table2array(FlowbyCell2));
% FlowGroupNames=get(FlowbyCell2,'columnname');
   
test2=cell2struct(Test,'PnN',1);
% test2(1).BYTEORD = "1,2,3,4";
TEXT.PnN = FlowbyCell2.Properties.VariableNames;
PleaseWork=groupsummary(FlowbyCell2,'WellNum','max');
FlowGroups=table2struct(PleaseWork);
% writeFCS('test1.fcs',FCSOutData,FlowGroups);
writeFCS('test1.fcs',FCSOutData,TEXT);


%% WholeWellDataPrep
WellTimeAnaPlaneData=groupsummary(PreppedTable,["WellNum","TimeNum","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
WellTimeAnaData=unstack(WellTimeAnaPlaneData,[5:width(WellTimeAnaPlaneData)],{'ImgPlane'});
WellTimeData=unstack(WellTimeAnaData,[4:width(WellTimeAnaData)],{'AnaPass'});

