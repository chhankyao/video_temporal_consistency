clear all;
addpath(genpath('E:\hank\gbh_stream'));
addpath(genpath('E:\hank\Downloads\SLIC_mex'));

% Supervoxel labeling
% file = dir('interview\05\*ppm');
% table_value = [];
% for i = 41:90
% 	input = imread(file(i).name);
% 	temp_value = 2^16 * uint32(input(:,:,1)) + 2^8 * uint32(input(:,:,2)) + uint32(input(:,:,3));
% 	table_value = unique([table_value; temp_value(:)], 'stable');
% end
% 
% inv_table_value = zeros([1 size(table_value)], 'uint32');
% idx = 1:1:size(table_value,1);
% inv_table_value(table_value) = idx;
% 
% labels = zeros([size(temp_value), 50], 'uint32');
% 	
% for i = 41:90
% 	input = imread(file(i).name);
% 	temp_value = 2^16 * uint32(input(:,:,1)) + 2^8 * uint32(input(:,:,2)) + uint32(input(:,:,3));
% 	labels(:,:,i-40) = uint32(inv_table_value(temp_value));
% end

% Read videos
v1 = VideoReader('Bear_input.avi');
frames = read(v1);
v2 = VideoReader('Bear_temporal2.avi');
frames2 = read(v2);

% parameters for slic superpixel
reqdsupervoxelsize = 100;
dims = size(frames);
numreqiredsupervoxels = dims(1)*dims(2)/reqdsupervoxelsize;
compactness = 1.0;

verb = '';
% numlabels = size(table_value,1);
output = zeros(size(frames));
output(:,:,:,1) = im2double(frames2(:,:,:,1));

for f = 2:size(frames,4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', f);
    fprintf(verb);
    
    f1 = frames(:,:,:,f);
    f2 = frames2(:,:,:,f);
    
    [label, numlabels] = slicmex(f1, numreqiredsupervoxels, compactness);
%     label = labels(:,:,f);

    output_frame = affine_transfer_perframe(f1, f2, label);
    output(:,:,:,f) = output_frame;
end
fprintf(repmat('\b',[1, length(verb)]))

v = VideoWriter('E:\hank\gbh_stream\results\Bear_ours2.avi');
% v.FrameRate = 10;
open(v);
for i = 1:size(output,4)
    writeVideo(v, im2uint8(output(:,:,:,i)));
end
close(v);

% v = VideoWriter('E:\hank\gbh_stream\results\Japan_input.avi');
% v.FrameRate = 10;
% open(v);
% writeVideo(v, frames);
% close(v);
