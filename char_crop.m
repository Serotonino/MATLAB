
function [fc re word_change]=char_crop(im_texto,word_indx)
% Extracts the first character from a single line of text
% im_texto->input image; fc->first character re->remain line
% Example:
% im_texto=imread('TEST_3.jpg');
% [fl re]=lines(im_texto);
% subplot(3,1,1);imshow(im_texto);title('INPUT IMAGE')
% subplot(3,1,2);imshow(fl);title('FIRST LINE')
% subplot(3,1,3);imshow(re);title('REMAIN LINES')

im_texto=bwareaopen(im_texto,15);%to remove noise
im_texto=clip(im_texto);% Trims the Image 
word_change=0;
%-----------------------------------------------------------------


[L N]= bwlabel(im_texto);    
        [r1 c1]=find(L==1);
        [r2 c2]=find(L==2);
        fc=im_texto(min(r1):max(r1),min(c1):max(c1));
        col=max(c1);
        re=im_texto(1:size(im_texto,1),max(c1):size(im_texto,2));
% Technique for segmenting disjoint characters like 'visarga' and 'Chandrabindu' 
        
        if N>1 && (min(c2) - max(c1))<=3                          
                if (min(r2)<=min(r1)) % Horizontal Skewness tolerated
                    fc=im_texto(min(r2):max(r1),min(c1):max(c2));
                    col=max(c2);
                    re=im_texto(1:size(im_texto,1),max(c2):size(im_texto,2));
                else 
                    fc=im_texto(min(r1):max(r2),min(c2):max(c1));
                    col=max(c1);
                    re=im_texto(1:size(im_texto,1),max(c1):size(im_texto,2));
                end
            end
        
            
        
        %figure,imshow(fc);
        
        fc=clip(fc);
        re=bwareaopen(re,15);
        re=clip(re);
        word_change=0;
        if size(word_indx)~=0
        for i=1:size(word_indx)
            if (word_indx(i)-col)<=7
                word_change=1; %Flags that the current character is the 
                break;          %last in the word and a new word begins after this
            end
        end
        end
        
        

    


        

