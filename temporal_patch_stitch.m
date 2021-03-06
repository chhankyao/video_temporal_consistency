v = VideoReader('input.avi');
frames = im2double(read(v));

v2 = VideoReader('processed.avi');
frames2 = im2double(read(v2));

d_stack = floor(size(frames,4)/10);
thres_keyframe = 10^4;

idx_stack = 1:d_stack;
ann_stack = zeros(size(frames(:,:,:,1:d_stack)), 'int32');
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
        ann_i = nnmex(current_frame, frames(:,:,:,idx_stack(j)), 'cpu', [], [], [], [], [], [], 1);
        ann_stack(:,:,:,j) = ann_i;
    end
    
    % warping and fusion
    [pmatch, err] = fuse_patchMatch2(image_stack, ann_stack, j);
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

v = VideoWriter('temporal.avi');
open(v);
writeVideo(v, output);
close(v);