
function [fl re para_change]=line_crop(im_texto,para_indx)
% Divide text in lines
% im_texto->input image; fl->first line; re->remain line
% Example:
% im_texto=imread('TEST_3.jpg');
% [fl re]=lines(im_texto);
% subplot(3,1,1);imshow(im_texto);title('INPUT IMAGE')
% subplot(3,1,2);imshow(fl);title('FIRST LINE')
% subplot(3,1,3);imshow(re);title('REMAIN LINES')

        
        % Paragragh change detection using Vertical Dilation
        %------------------------------------------------------------------------------
        %Rule ===> If vertical distance between successive lines  
        %          is greater than 14 pixels, then paragraph has changed 
para_change=0;
%figure,imshow(im_texto);
im_texto=clip(im_texto);
%figure,imshow(im_texto);
num_filas=size(im_texto,1);
for s=1:num_filas
    if sum(im_texto(s,:))==0
        nm=im_texto(1:s-1, :); % First line matrix
        rm=im_texto(s:end, :);% Remain line matrix
        fl = clip(nm);
        re=clip(rm);
        %figure,imshow(fl);
        para_change=0;
        if size(para_indx)~=0
        for i=1:size(para_indx)
            if ((s-1)- para_indx(i))<=14
                para_change=1;
                break;
            end
        end
        end
        
        %*-*-*Uncomment lines below to see the result*-*-*-*-
        %         subplot(2,1,1);imshow(fl);
        %         subplot(2,1,2);imshow(re);
        break;
    else
        fl=im_texto;%Only one line.
        re=[ ];
    end
end
        


