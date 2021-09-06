
function malayalam_ocr(imagein)


% Algorithm
%-------------------------------------------------------------------------
%  Preprocessing
%   1.RGB to Grayscale conversion
%   2.Thresholding and binary conversion
%   3.Ensuring brighter foreground(text)
%-------------------------------------------------------------------------
%  Segmentation
%   4.Detecting Paragraph-changes using Image Dilation with vertical line
%     shaped structural element
%   5.Separating lines by vertical profiling
%   6.Detecting Word-changes using Image Dilation with horizontal line
%     shaped structural element
%   7.Separating characters by labelling connected components 
%-------------------------------------------------------------------------
%  Classification 
%   8.Extracting features- DCT coefficients and corner pixels
%   9.Building TestSet feature vector
%   10.

i= rgb2gray(imread(imagein));

%Thresholding using Otsu's Method
level = graythresh(i);
bw= im2bw(i,level);
%figure,imshow(bw);
count=0;l=0;
%=========================================================================
%Ensuring that text is in white and background is black 
[count,l]=imhist(bw);
[mxm,index]=max(count);
if l(index)==1
    bw = (ones(size(bw))-bw);
end
bw=logical(bw);
figure,imshow(bw);
%================================================================================

%==========================================================================
% Training Set feature vector generation
%---------------------------------------------------------



recog= struct('a','0D05','aa','0D06','e','0D07','ee','0D08','u','0D09','uu','0D0A','er','0D0B','ea','0D0E','eaa','0D0F','ai','0D10','O','0D12','oh','0D13','oau','0D14','aum','0D02','ah','0D03','ka','0D15','kha','0D16','ga','0D17','gha','0D18','inga','0D19','ta','0D1f','tta','0D66','da','0D21','dda','0D22','nda','0D23','pa','0D2A','ffa','0D2B','ba','0D2C','bha','0D2D','ma','0D2E','cha','0D1A','chha','0D1B','ja','0D1C','jha','0D1D','inha','0D1E','tha','0D24','thha','0D25','dha','0D26','dhha','0D27','na','0D28','ya','0D27','ra','0D30','la','0D32','va','0D35','sha','0D36','shha','0D37','sa','0D38','ha','0D39','lha','0D33','zha','0D34','rha','0D31','ilh','0D7E','ln','0D7E','lrr','0D7C','ill','0D7D','lnH','0D7A');


names=char(fieldnames(recog));
cd('./Malayalam_training_set');
TrainingSet=zeros(200,30);
GroupTrain=cell(200,1);
ts=1;
list= ls;
count=0;
if(size(list,1)>2)
    c=3;
    %j=16;
 for c=3:size(list,1)   
    for j=16:size(names,1)
        count=count+1;
        if strcmp(names(j,:),list(c,1:(size(list,2)-1)))
            cd(strcat('./',list(c,:)));
            pics=ls;
            %count=count+1;
            if(size(pics,1)>2)
             
                for k=3:size(pics,1)
                    
                imn= rgb2gray( imread(pics(k,:)));
                level = graythresh(imn);
                BW= im2bw(imn,level);
                [count,l]=imhist(BW);
                [mxm,index]=max(count);
                if l(index)==1
                    BW = (ones(size(BW))-BW);
                end
                BW=logical(BW);
                
                 DCT= dct2(BW);
                 corn=corner(BW);
                 selected_cr=zeros(1,20);
                if size(corn,1)<10 
                    lim=size(corn,1);
                else
                    lim=10;
                end
                 g=1;
                for f=1:lim
                selected_cr(g)= corn(f,1);
                selected_cr(g+1)= corn(f,2);
                g=g+2;
                end
                if size(selected_cr,2)<20
                selected_cr= cat(1,selected_cr,zeros(1,(20-size(selected_cr))));
                end
  
                 for v=1:10
                    selected_dct(1,v)=[DCT(randi(size(DCT,1)),randi(size(DCT,2)))] ;
                 end
    TrainingSet(ts,:)=[selected_dct selected_cr];
    GroupTrain(ts,1)=cellstr(names(j,:));
    ts=ts+1;
                end
            end
            cd('../');
        end
  
    end
end
end
TrainingSet=TrainingSet(1:(ts-1),:);
GroupTrain=GroupTrain(1:(ts-1),1);
cd('../');



%==========================================================================



%Segmentation continued...
%==========================================================================
   % Paragragh change detection using Vertical Dilation     
        se= strel('line',12,90);
        dil= imdilate(bw,se);
        num_filas=size(dil,2);
        for s=1:num_filas
            if sum(dil(:,s))==0
                vert=dil(:,1:s-1); 
                vert = clip(vert);
            end
        end
        para_indx=[];  
        [L Ne] = bwlabel(vert);    
        for n=1:Ne
        [r c]=find(L==n);
        para_indx(n)=max(r);
        end
%===============================================================================
 
out=fopen('output_text.txt','w+');
para_change=0;
word_change=0;




rem_image=bw;
%figure,imshow(rem_image)
while size(rem_image)~=0
    [line,rem_image,para_change]=line_crop(rem_image,[0]);
   % figure,imshow(line);
    %if para_change==1
     %   para_change=0;
      %  fprintf(out,'\n');
    %end
    word=[];
    
    se= strel('line',6,0);
    dil= imdilate(line,se);
    word_indx=[];  
    [L Ne] = bwlabel(dil);    
    for n=1:Ne
        [r c]=find(L==n);
        a=max(c);
        if(n~=Ne)
            [  cx]=find(L==(n+1));
            a=floor((max(c)+min(cx))/2);
        end
        word_indx(n) = a;
    end
    
    rem_line=line;
    while find(rem_line)
        [character,rem_line,word_change]= char_crop(rem_line,[0]);
    % Feature extraction and buiding test feature vector
     %figure,imshow(character);
     if isempty(character)
         continue;
     end
    DCT= dct2(character);
    corn=corner(character);
    selected_cr=zeros(1,20);
    selected_dct=zeros(1,10);
    TestSet=zeros(1,30);
                if size(corn,1)<10 
                    lim=size(corn,1);
                else
                    lim=10;
                end
                 g=1;
                for f=1:lim
                selected_cr(g)= corn(f,1);
                selected_cr(g+1)= corn(f,2);
                g=g+2;
                end
                if size(selected_cr,2)<20
                selected_cr= cat(1,selected_cr,zeros(1,(20-size(selected_cr))));
                end
  
                 for i=1:10
                    selected_dct(1,i)=[DCT(randi(size(DCT,1)),randi(size(DCT,2)))] ;
                 end
                 
    TestSet(1,:)=[selected_dct selected_cr];
   
    result=Cody_MSVM_trial(TrainingSet,GroupTrain,TestSet);
    
    b=find(ismember(names,result));
    
   X = sprintf('%c', hex2dec(char(recog.(names(b,1:(size(names,2)-1))))));
   fwrite(out, unicode2native(X,'UTF-8'), 'uint8');
   if(word_change)
       fprintf(out,'%c',' ');
   end
    end
end
    fclose(out);
    figure,imshow(imagein);
    winopen('output_text.txt');
    



























