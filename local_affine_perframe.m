% Read videos
v1 = VideoReader('input.avi');
frames = read(v1);
v2 = VideoReader('temporal.avi');
frames2 = read(v2);

% parameters for slic superpixel
reqdsupervoxelsize = 100;
dims = size(frames);
numreqiredsupervoxels = dims(1)*dims(2)/reqdsupervoxelsize;
compactness = 1.0;

verb = '';
output = zeros(size(frames));
output(:,:,:,1) = im2double(frames2(:,:,:,1));

for f = 2:size(frames,4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', f);
    fprintf(verb);
    
    f1 = frames(:,:,:,f);
    f2 = frames2(:,:,:,f);
    
    [label, numlabels] = slicmex(f1, numreqiredsupervoxels, compactness);

    output_frame = affine_transfer_perframe(f1, f2, label);
    output(:,:,:,f) = output_frame;
end
fprintf(repmat('\b',[1, length(verb)]))

v = VideoWriter('output.avi');
open(v);
for i = 1:size(output,4)
    writeVideo(v, im2uint8(output(:,:,:,i)));
end
close(v);
