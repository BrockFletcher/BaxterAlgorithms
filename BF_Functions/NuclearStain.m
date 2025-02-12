function [NucLabel,Nuc_bw4,NucPos,NucBrightEnough,NucMT1,NucOpen,Nuc_eq,NucTopHat,Nuc_bw4_perim,NucOverbright,NucQuant1,NucWeiner,NucArea] = NuclearStain(Nuc,NucTophatDisk,NucMax,NucOpenDisk,NucErodeDisk,NucLow,NucCloseDisk)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    NucWeiner=wiener2(Nuc);
    NucTopHat=imtophat(NucWeiner,NucTophatDisk); % Clean image with tophat filter for thresholding 
%     NucOpen=imerode(NucTopHat,NucOpenDisk);
%      NucOpen=imreconstruct(NucOpen,NucTopHat);
    Nuc_eq =imadjust(NucTopHat);   %Make it easy to see
    NucOpen=imopen(NucTopHat,NucOpenDisk);
    NucMaxValue= NucMax*intmax(class(Nuc));
    NucOverbright=NucTopHat>NucMaxValue;
    
    NucOpen(NucOverbright)=0;
%         NucMT1=multithresh(NucOpen,20); %Calculate 20 brightness thresholds for image 
%         NucQuant1=imquantize(NucOpen,NucMT1); %Divide Image into the 20 brightness baskets
        NucMT1=1;
        NucQuant1=1;
%         NucBrightEnough=NucQuant1>NucLow;
        NucBrightEnough=NucOpen>NucLow;
        NucPos=NucOpen;
        NucPos(~NucBrightEnough)=0;
%         NucPos=imadjust(NucPos);
          Nuc_bw2=imerode(NucPos,NucErodeDisk);
          Nuc_bw3 = bwareaopen(Nuc_bw2, 250); %%Be sure to check this threshold
          Nuc_bw4 = imclose(Nuc_bw3, NucCloseDisk);
          Nuc_bw4 = imfill(Nuc_bw4,'holes');
        Nuc_bw4_perim = imdilate(bwperim(Nuc_bw4),strel('disk',3));
       
       NucConn=bwconncomp(Nuc_bw4);
       NucLabel = labelmatrix(NucConn);
       NucArea = imoverlay(Nuc_eq, Nuc_bw4_perim, [.3 1 .3]);
       
end

