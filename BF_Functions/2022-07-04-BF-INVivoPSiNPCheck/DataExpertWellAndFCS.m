%User Inputs
CellCountPlane=3;


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
FlowPrepFlip=rows2vars(FlowPrep);
FlowPrepFlip.Properties.RowNames=FlowPrepFlip.(1);
FlowPrepFlip=removevars(FlowPrepFlip,"OriginalVariableNames");
FlowReadyDataunique=unique(FlowPrepFlip,'stable');
PerCellClean=rows2vars(FlowReadyDataunique);
PerCellClean=removevars(PerCellClean,"OriginalVariableNames");
PerCellClean(ismember(PerCellClean.Cell,0),:)=[];
% PerCellClean(PerCellClean.c4>PerCellClean.c1,:)=[];
FlowbyCell=unstack(PerCellClean,[5:width(PerCellClean)],{'AnaPass'});
FlowbyCell2=FlowbyCell;
FlowbyCell2(~ismember(FlowbyCell2{:,CellCountPlane+3},1),:)=[];
FCSOutData=single(table2array(FlowbyCell2));
% FlowGroupNames=get(FlowbyCell2,'columnname');
FlowGroups=table2struct(FlowbyCell2(1,:));
writeFCS('test1.fcs',FCSOutData,FlowGroups);


%% WholeWellDataPrep
WellTimeAnaPlaneData=groupsummary(PreppedTable,["WellNum","TimeNum","AnaPass","ImgPlane"],{"all"},["Area","EquivDiameter","Extent","MeanIntensity","SumIntensity"]);
WellTimeAnaData=unstack(WellTimeAnaPlaneData,[5:width(WellTimeAnaPlaneData)],{'ImgPlane'});
WellTimeData=unstack(WellTimeAnaData,[4:width(WellTimeAnaData)],{'AnaPass'});

