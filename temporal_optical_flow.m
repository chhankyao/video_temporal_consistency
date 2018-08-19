clear all;

addpath(genpath('E:\hank\gbh_stream\code'));
addpath(genpath('E:\hank\gbh_stream\results'));
addpath(genpath('E:\hank\Downloads\OpticalFlow'));
    
% parameters for optical flow
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
    
v = VideoReader('Bear_input.avi');
frames = im2double(read(v));

v2 = VideoReader('Bear_colorGrade_perframe.avi');
frames2 = im2double(read(v2));

d_stack = floor(size(frames,4)/10);
idx_stack = 1:d_stack;
ann_stack = zeros(size(frames(:,:,:,1:d_stack)));
image_stack = zeros(size(frames(:,:,:,1:d_stack)));
dist = zeros(1, d_stack);
m_dist = zeros(d_stack);
dist_for_plot = zeros(1, size(frames,4));

prev_frame = frames(:,:,:,1);
prev_output = frames2(:,:,:,1);
output = zeros(size(frames));
output(:,:,:,1) = prev_output;
image_stack(:,:,:,1) = prev_output;

verb = '';
for i = 2 : size(frames,4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', i);
    fprintf(verb);
    current_frame = frames(:,:,:,i);
	ref = frames2(:,:,:,i);       
    
    for j = 1 : min(i-1, d_stack)
        [vx, vy, imwarp] = Coarse2FineTwoFrames(ref, image_stack(:,:,:,j), para);
        ann_stack(:,:,:,j) = imwarp;
%         ann_stack(:,:,1,j) = vx;
%         ann_stack(:,:,2,j) = vy;
%         ann_stack(:,:,3,j) = mean(imwarp - current_frame, 3);
    end
    
    % warping and fusion
    [pmatch, err] = fuse_opticalflow(ref, image_stack, ann_stack, j);
    w = err / (max(max(err(1:end-6, 1:end-6)))+1e-10);
    w(w > 1) = 1;
    w = repmat(w, [1,1,3]);
    trans = fuse_pyramid(current_frame, pmatch, ref, w);    
    output(:,:,:,i) = trans;
    
    % Update key-frame stacks
    for j = 1 : min(i-1,d_stack)
        dist(j) = 0;
        for k = 1:3
            hist1 = imhist(current_frame(:,:,k));
            hist2 = imhist(frames(:,:,k,idx_stack(j)));
            dist(j) = dist(j) + 0.5 * sum(((hist1 - hist2).^2) ./ (hist1 + hist2 + 10e-9));
        end
    end
    [min_value, idx] = min(sum(m_dist));
    if i <= d_stack
        m_dist(i,:) = dist;
        m_dist(:,i) = dist;
        image_stack(:,:,:,i) = output(:,:,:,i);
    elseif sum(dist) >= min_value(1)
        m_dist(idx(1), :) = dist;
        m_dist(:, idx(1)) = dist;
        idx_stack(idx(1)) = i;
        image_stack(:,:,:,idx(1)) = output(:,:,:,i);
    end
    dist_for_plot(i) = sum(dist);    
    prev_frame = current_frame;
    prev_output = trans;
end
fprintf(repmat('\b',[1, length(verb)]))

output(output > 1) = 1;
output(output < 0) = 0;

v = VideoWriter('results\Bear_temporal2.avi');
% v.FrameRate = 10;
open(v);
writeVideo(v, output);
close(v);