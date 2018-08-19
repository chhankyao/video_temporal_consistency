% Read Videos
v = VideoReader('interview.mp4');
frames = im2double(read(v, [41 90]));

v2 = VideoReader('interview_colorGrade_perframe.avi');
frames2 = im2double(read(v2, [41 90]));

output = zeros(size(frames));
prev_frame = frames(:,:,:,1);
prev_output = frames2(:,:,:,1);

verb = '';
for i = 1 : size(frames, 4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', i);
    fprintf(verb);
    current_frame = frames(:,:,:,i);
	ref = frames2(:,:,:,i);
	
    ann_i = nnmex(current_frame, prev_frame, 'cpu', [], [], [], [], [], [], 1);
    pmatch = votemex(prev_output, ann_i);
    error = double(ann_i(1:end-6, 1:end-6, 3));
    w = double(ann_i(:,:,3)) / (max(error(:))+1e-10);
    w(w > 1) = 1;
    w = repmat(w, [1,1,3]);
    trans = fuse_pyramid(current_frame, pmatch, ref, w);    
    
    if i > 5
        ann_i_5 = nnmex(current_frame, frames(:,:,:,i-5), 'cpu', [], [], [], [], [], [], 1);
        pmatch_5 = votemex(output(:,:,:,i-5), ann_i_5);
        error_5 = double(ann_i_5(1:end-6, 1:end-6, 3));
        w_5 = double(ann_i_5(:,:,3)) / (max(error_5(:))+1e-10);
        w_5(w_5 > 1) = 1;
        w_5 = repmat(w_5, [1,1,3]);
        trans_5 = fuse_pyramid(current_frame, pmatch_5, ref, w_5);
        weight = double(w ./ (w + w_5 + 1e-10));
        trans = (1-weight) .* trans + weight .* trans_5;
    end
    output(:,:,:,i) = trans;
    prev_frame = current_frame;
    prev_output = trans;
end
fprintf(repmat('\b',[1, length(verb)]))

v = VideoWriter('interview_temporal_warp_average.avi');
v.FrameRate = 10;
open(v);
writeVideo(v, output);
close(v);