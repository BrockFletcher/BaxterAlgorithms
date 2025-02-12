%% Gal8 Recruitment MATLAB Program
%% Image Folder Location
clc, clear all, close all
reader = bfGetReader('D:\Dropbox (VU Basic Sciences)\Duvall Confocal\Duvall Lab\Brock Fletcher\2021-06-29-PolymerScreen\PolyScreen004.nd2');
exportdir='D:\Dropbox (VU Basic Sciences)\Duvall Confocal\Duvall Lab\Brock Fletcher\2021-06-29-PolymerScreen\2022_02_04_SarahHelp';

%% Directory Code

run=char(datetime(clock),"yyyy-MM-dd-hh-mm-ss");    % The Run number is used to track multiple runs of the software, and is used in
          
readeromeMeta=reader.getMetadataStore();
RunDirectory= fullfile(exportdir,run);
mkdir(RunDirectory); 

destdirectory1 = fullfile(RunDirectory,'Overlaid');
mkdir(destdirectory1); 

BaxtDirectory = fullfile(RunDirectory,'Baxter');
mkdir(BaxtDirectory);

LogDirectory = fullfile(RunDirectory,'Log');
mkdir(LogDirectory);

SegDirectory = fullfile(RunDirectory,'Segmentation');
mkdir(SegDirectory);

exportbaseBAXTSegNuc=fullfile(SegDirectory,'Segmentation_Nuc');
mkdir(exportbaseBAXTSegNuc);

exportbaseBAXTSegCell=fullfile(SegDirectory,'Segmentation_Cell');
mkdir(exportbaseBAXTSegCell);
            %##Need to universalize the Segmentation stuff for whatever the
            %GUI needs, so that it can be arbitrarily named and assigned.
            %Might be a good idea to write this all into a function

%%Log Data
Version=run;
LogFile=strcat(LogDirectory,'\');
FileNameAndLocation=[mfilename('fullpath')];
newbackup=sprintf('%sbackup_%s.m',LogFile,Version);
Gitdir=fullfile(pwd,'RunLog');
GitLog=sprintf('%sbackup_%s.m',Gitdir,Version);
% GitLog=sprintf('%sbackup_%s.m',LogFolder,Version);
% mkdir(RunLog);
currentfile=strcat(FileNameAndLocation, '.m');
copyfile(currentfile,newbackup);
copyfile(currentfile,GitLog)
% A = exist(newbackup,'file');
% if (A~=0)
% warning('Backup already exists for the current version')
% end
%##This may not be the best way to be logging the data and directory, since
%it's in a new folder every time, but we can figure htis otu later. Also
%might be possible to write this all into a function


%% Structuring Elements
% For conveience, a number of sizes of disk shaped structural elements are
% generated for data exploration.
%## Can probably delete this section after checking on all of the functions
sr1=strel('square',1);
se1=strel('disk',1);
sr2=strel('square',2);
se2=strel('disk',2);
se3=strel('disk',3);
sr3=strel('square',3);
se4=strel('disk',4);
se5=strel('disk',5);
se6=strel('disk',6);
se7=strel('disk',7);
se8=strel('disk',8);
se9=strel('disk',9);
se10=strel('disk',10);
se12=strel('disk',12);
se20=strel('disk',20);
se25=strel('disk',25);
se100=strel('disk',100);
%% Sizing/Resolution Parameters EDIT HERE ADVANCED

        %NEED TO ADD microns per Pixel %NEED TO ADD Cell size (Small, Medium, Large)%Go through this and make all disks calculated on the microns per pixel and %the Cell Size

MiPerPix=0.34;        
CellSize=1; %Scale as needed for different Cells        
            %Disks
            NucTophatDisk=strel('disk',round(250*(0.34/MiPerPix)));
            NucOpenDisk= strel('disk',round(5*(0.34/MiPerPix)));
            NucErodeDisk=strel('disk',round(6*(0.34/MiPerPix)));
            NucCloseDisk=strel('disk',round(4*(0.34/MiPerPix)));

            CytTophatDisk=strel('disk',round(250*(0.34/MiPerPix))); % EditHere
            CytOpenDisk =strel('disk',round(5*(0.34/MiPerPix)));
            CytErodeDisk=strel('disk',round(5*(0.34/MiPerPix)));
            CytCloseDisk=strel('disk',round(5*(0.34/MiPerPix)));

            Gal8TophatDisk=strel('disk',round(6*(0.34/MiPerPix)));% EditHere
            Gal8OpenDisk =strel('square',round(2*(0.34/MiPerPix)));
            Gal8DilateDisk=strel('disk',round(1*(0.34/MiPerPix)));
            Gal8OutlineDisk=strel('disk',round(2*(0.34/MiPerPix)));
            
            %##Probabloy possible and better to integrate all of this into
            %a single function for the "round" section and then have ll of
            %the indivual disks just created in each function based on the
            %relative pixel size with a cell size correction
%% Analysis Functions
%Bit Depth    
    bitdepthin= 12; %Bit depth of original image, usually 8, 12, or 16
    bitConvert=(2^16/2^bitdepthin); %This assures that whatever the bit depth of the input image, the analyzed images are all 16 bit.
%Input Planes
    ImagePlanes=[1,2,3]; %Which image Planes to analyze ##Integrate with GUI 
    ImageAnalyses={{'cytgal'},{},{}}; %Which Image analysis/functions to call. ##NEed to solve problem of secondary analyses like watershed of Nuc and Cytosol or gal8 and cytosol
    MakeOverlayImage=0;%Logical Yes or no to make overlay image #Integrate with GUI
    % ##Add selection for what to overlay on the overlay image, for example,
    % showing the cytosol perimeter analysis or Not

    % ##Add selection for data of interest from each analysis, i.e. what to
    % export from each function
    %
    
%% Image Thresholding EDIT HERE BASIC 
    %##Need to make these into GUI, and make universal so that as we call
    %each function we can set the function parameters in the GUI. I believe
    %Baxter has a very good solution for doing this
    %Nuclear Stain
        NucMax=0.8;%Number 0-1, removes Cell Debris brighter than this value in order to allow low end to remain visible. 0.2 is usually a good start 
        NucLow=100;%
     %Cytosol    
        CytMax= 0.5; %Number 0-1, removes Cell Debris brighter than this value. 0.2 is usually a good start  
        CytLow=0; %Choose number 0-20, start at 0. Higher numbers remove more dim cells and background.
    %Gal8
        Gal8MinThreshold=0.2;%Number 0-1, removes Puncta Dimmer than this value. 0.05 is usually a good start 
    %Rhodamine
        Rhoda_threshold = 0.01; %Number 0-1, removes rhodamine signal dimmer than threshold
%         Rhoda_threshold_Big = 100;
%% Analysis Variables

Categories=[{'run'},{'well'},{'areacell'},{'CellSum'},{'areaGal8'},{'galsum'},{'areaRhod'},{'Rhodsum'},{'RhodAvgInCell'},{'RhodAvgOutCell'}]; 
%##Categories are manually typed out here, but it should integrate so that
%these are auto-populated or selectable within the GUI, might have to get
%clever for this to work

NumSeries=reader.getSeriesCount(); %The number of different wells you imaged
NumColors=reader.getEffectiveSizeC(); %The number of colors of each well you imaged
NumTimepoint=(reader.getImageCount())/NumColors; %The number of timepoints you imaged
NumImg=NumSeries*NumTimepoint*NumColors; %The total number of images, combining everything

C = cell(NumImg,length(Categories)); 
%##C is something that will probably have be edited to allow data output
%from this scale of the analysis. Don't even know if it's correct right now
%or even neccessary at all
%% Analysis Program 
for j=0:NumSeries-1% Number of wells in ND2 File  
    % Set Current Well and other important values
    %##Would be very useful to figure out how to make this work as a parfor
    %loop, but might be quite difficult
    CurrSeries=j; %The current well that we're looking at
    reader.setSeries(CurrSeries); %##uses BioFormats function, can be swapped with something else (i forget what) if it's buggy with the GUI
    fname = reader.getSeries; %gets the name of the series using BioFormats
    Well=num2str(fname,'%05.f'); %Formats the well name for up to 5 decimal places of different wells, could increase but 5 already feels like overkill 
    PositionX = readeromeMeta.getPlanePositionX(CurrSeries,1).value(); %May be useful someday, but not needed here
    PositionY = readeromeMeta.getPlanePositionY(CurrSeries,1).value(); %May be useful someday, but not needed yet. Get's the position of the actual image. Useful for checking stuff
    T_Value = reader.getSizeT()-1; %Very important, the timepoints of the images. Returns the total number of timepoints, the -1 is important.
    
    %CreateFolders for Baxter to read data
        %##Important work: generalize this folder creation and put into GUI, so
        %that whatever segmentations the user creates can be saved for baxter
        %analysis. The "BaxSegFolderCell" is probably the most important and
        %default, but this should be customizable
    
    BaxWellFolder=fullfile(BaxtDirectory,Well); %Creates a filename that's compatible with both PC and Mac (##Check and see if any of the strcat functions need to be replaced with fullfile functions) 
    mkdir(BaxWellFolder); %makes a new folder on your hard drive for the baxter stuff   
    
    BaxSegFolderNuc=fullfile(exportbaseBAXTSegNuc,Well); %Creates a filename that's compatible with both PC and Mac
    mkdir(BaxSegFolderNuc); %makes a new folder on your hard drive for the nuclear segmentaiton for Baxter
    
    BaxSegFolderCell=fullfile(exportbaseBAXTSegCell,Well); %Creates a filename that's compatible with both PC and Mac
    mkdir(BaxSegFolderCell);

    for i=0:T_Value %For all of the time points in the series, should start at zero if T_Value has -1 built in, which it should
            %Set up the particular timepoint image
        Timepoint = num2str(i,'%03.f'); %Creates a string so taht the BioFormats can read it
       iplane=reader.getIndex(0,0,i); %Gets the particular timepoint image, so now we're in a particular well at a particular timepoint
       WellTime = round(str2double(readeromeMeta.getPlaneDeltaT(CurrSeries,iplane).value())); %The time that the well image was taken. Very useful for sanity checks
       Img=[];%Creates an empty array for the image ##Check and see if this is necessary or if there's a more efficient way of doing this.
                         
                        BaxterName=strcat('w',Well,'t',Timepoint) ; %Very important, creates a name in the format that Baxter Algorithms prefers
                        
                        ImageName=fullfile(BaxWellFolder,BaxterName); %Creates a name for each particular image
                        
            for n=ImagePlanes             
                Img= bitConvert*bfGetPlane(reader,iplane+n);
                CurrPlane=ImageAnalyses{n};
              
             %Primary Analyses   
                if any(contains(CurrPlane,'Bax'))
                    my_field = strcat('c',num2str(n,'%02.f'));
                    imwrite(Img, strcat(ImageName,my_field,'.tif'),'tif');
                 
                end
                if any(contains(CurrPlane,'nuc'))
                [NucLabel,Nuc_bw4,NucPos,NucBrightEnough,NucMT1,NucOpen,Nuc_eq,NucTopHat,Nuc_bw4_perim,NucOverbright,NucQuant1,NucWeiner,NucArea] = NuclearStain(Img,NucTophatDisk,NucMax,NucOpenDisk,NucErodeDisk,NucLow,NucCloseDisk);  
                
                end
                                          
                if any(contains(CurrPlane,'cyt'))
                        [CytBright,CytArea,CytNucOverlay,cyt_bw4,CytPos,CytBrightEnough,CytMT1,CytOpen,cyt_eq,CytTopHat,cyt_bw4_perim] = Cytosol(Img,CytTophatDisk,CytMax,CytOpenDisk,CytErodeDisk,CytLow,CytCloseDisk);
                end           
                
                 if any(contains(CurrPlane,'drug'))
                [RhodBright,areaRhod, Rhodsum, RhodAvgInCell, RhodAvgOutCell,rhod_eq,RhodMask] = Rhoda(Img, Rhoda_threshold, cyt_bw4);
                 end

                 %Secondary Analyses
                     if any(contains(CurrPlane,'cytgal'))
                    [CytBright,CytArea,CytNucOverlay,cyt_bw4,CytPos,CytBrightEnough,CytMT1,CytOpen,cyt_eq,CytTopHat,cyt_bw4_perim] = Cytosol(Img,CytTophatDisk,CytMax,CytOpenDisk,CytErodeDisk,CytLow,CytCloseDisk);    
                    [GalPals,Gal8Signal,Gal8Quant5] = Gal8(Img,Gal8MinThreshold,CytPos,MiPerPix);  
                     end

                     if any(contains(CurrPlane,'nucWS'))
                      [NucLabel,Nuc_bw4,NucPos,NucBrightEnough,NucMT1,NucOpen,Nuc_eq,NucTopHat,Nuc_bw4_perim,NucOverbright,NucQuant1,NucWeiner,NucArea] = NuclearStain(Img,NucTophatDisk,NucMax,NucOpenDisk,NucErodeDisk,NucLow,NucCloseDisk); 
                     end
                    if any(contains(CurrPlane,'cytWS'))
                        [CytBright,CytArea,CytNucOverlay,cyt_bw4,CytPos,CytBrightEnough,CytMT1,CytOpen,cyt_eq,CytTopHat,cyt_bw4_perim] = Cytosol(Img,CytTophatDisk,CytMax,CytOpenDisk,CytErodeDisk,CytLow,CytCloseDisk);
                        [Cyt_WS,Cyt_WS_perim,L_n] = CytNucWaterShed(cyt,Nuc_bw4,CytTopHat,cyt_bw4);
                    end
                    
            %Make RGB Image
                    
                    if any(contains(CurrPlane,'blue'))
                 blue=imadjust(Img);
%                  else
%                      blue=zeros(size(Img),'like',Img);
                 end  
                 if any(contains(CurrPlane,'green'))
                 green=imadjust(Img);
%                  else
%                      green=zeros(size(Img),'like',Img);
                 end  
                 if any(contains(CurrPlane,'red'))
                 red=imadjust(Img);
%                   else
%                      red=zeros(size(Img),'like',Img);
                 end  
                 
            end
            
        %Make Overlay Image
            %#UNIVERSALIZE THIS CODE AND MAKE IT SO THAT WE FROM THE GUI 
            %CALL WHICH PERIMETER OF WHICH MASK WE WANT TO OVERLAY IN WHICH
            %COLOR
            
            if logical(MakeOverlayImage)
            if ~exist('blue','var')
                blue=zeros(size(Img),'like',Img);
            end
            if ~exist('green','var')
                green=zeros(size(Img),'like',Img);
            end
            if ~exist('red','var')
                red=zeros(size(Img),'like',Img);
            end
            RGBExportImage=cat(3,red,green,blue);
             if exist('cyt_bw4_perim','var')
               RGBExportImage=imoverlay(RGBExportImage,cyt_bw4_perim,[0.8500 0.3250 0.0980]);
             end
             imshow(RGBExportImage)
            end
                %% Measure Image Data
            %##Write Code here that uses parameters set in the GUI to take
            %all of the data we'd be interested in analyzing. Will probably
            %need to get clever with the analysis function output names in
            %order to make it all work with an arbitrary number of analyses
            %and image planes
    
    end   
    
end
%% Write Analysis Data to File
%  
% D=[Categories;C];
% WritingHere=strcat(exportdir,'\','Gal8','_',run);
%  writecell(D,strcat(WritingHere,'.xlsx')); % Exports an XLSX sheet of your data
% 
%% add code that writes the text of this code with the timestamp to a record every time it is run