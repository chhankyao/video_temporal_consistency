addpath(genpath('D:\gbh_stream\fish'));
% addpath(genpath('E:\hank\hank\gbh_stream\interview\05'));
addpath(genpath('C:\Users\hank\Downloads\OpticalFlow'));
clear all;

file = dir('fish\05\*ppm');
% file = dir('interview\05\*ppm');
table_value = [];
for i = 1:length(file)
	input = imread(file(i).name);
	temp_value = 2^16 * uint32(input(:,:,1)) + 2^8 * uint32(input(:,:,2)) + uint32(input(:,:,3));
	table_value = unique([table_value; temp_value(:)], 'stable');
end

inv_table_value = zeros([1 size(table_value)], 'uint32');
idx = 1:1:size(table_value,1);
inv_table_value(table_value) = idx;

labels = zeros([size(temp_value) length(file)], 'uint32');
	
for i = 1:length(file)
	input = imread(file(i).name);
	temp_value = 2^16 * uint32(input(:,:,1)) + 2^8 * uint32(input(:,:,2)) + uint32(input(:,:,3));
	labels(:,:,i) = uint32(inv_table_value(temp_value));
end

v = VideoReader('fish.avi');
frames = read(v, [1,150]);

% parameters for optical flow
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

verb = '';
output = zeros(size(frames));
output(:,:,:,1) = frames(:,:,:,1);
label2_revised = labels(:,:,1);
output2 = zeros(size(labels,1), size(labels,2), 3, size(labels,3));
output2(:,:,1,1) = uint8(mod(label2_revised .* mod(label2_revised, 2) * 50, 256));
output2(:,:,2,1) = uint8(mod(label2_revised .* mod(label2_revised, 3) * 50, 256));
output2(:,:,3,1) = uint8(mod(label2_revised .* mod(label2_revised, 5) * 50, 256));
delta_E_arr = zeros(1, size(frames,4)-1);
delta_std_arr = zeros(1, size(frames,4)-1);
numlabels = size(table_value,1);
next_label = numlabels + 1;
threshold = 0.5;

table2 = 1:1:numlabels;

for f = 2:size(frames,4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', f);
    fprintf(verb);
    
    f1 = frames(:,:,:,f-1);
    f2 = frames(:,:,:,f);
    label1 = label2_revised;
    label2 = labels(:,:,f);

    % optical flow
    [vx, vy, ~] = Coarse2FineTwoFrames(f2, f1, para);

    [x, y] = meshgrid(1:size(f2,2), 1:size(f2,1));
    label_propagate = interp2(double(label1), x + vx ,y + vy, 'nearest');
%     label_propagate = label2;

    label2_revised = label2;
    min_label = min(label2(:));
    max_label = max(label2(:));
    
    output_frame = zeros(size(f2));
    delta_E = [];
    delta_std = [];
    
    for i = min_label : max_label
%         if any(label1(:) == i) && any(label2(:) == i)
            mode_label = mode(label_propagate(label2 == i));
            if ~isnan(mode_label)
            overlap = (label2 == i) & (label_propagate == mode_label);
            recall = sum(overlap(:)) / sum(sum(label2 == i));
            precision = sum(overlap(:)) / sum(sum(label_propagate == mode_label));
            f_measure = 2 * recall * precision / (recall + precision);
%             f_measure = recall;
            if f_measure > threshold
                label2_revised(label2 == i) = mode_label;
                mask = repmat(label2_revised == mode_label, [1,1,3]);
                output_frame(mask) = f2(mask);
                % calculate color distance
%                 spixel1 = f1(repmat(label1 == table2(i), [1,1,3]));
%                 spixel2 = f2(mask);
%                 spixel1 = reshape(spixel1, [], 1, 3);
%                 spixel2 = reshape(spixel2, [], 1, 3);
%                 cform = makecform('srgb2lab');
%                 im1_lab = applycform(im2double(spixel1),cform);
%                 im2_lab = applycform(im2double(spixel2),cform);
%                 l1 = im1_lab(:,:,1);
%                 l2 = im2_lab(:,:,1);
%                 a1 = im1_lab(:,:,2);
%                 a2 = im2_lab(:,:,2);
%                 b1 = im1_lab(:,:,3);
%                 b2 = im2_lab(:,:,3);
%                 delta_E = [delta_E, sqrt((mean(l1(:)) - mean(l2(:)))^2 + (mean(a1(:)) - mean(a2(:)))^2 + (mean(b1(:)) - mean(b2(:)))^2)];
%                 delta_std = [delta_std, sqrt((std(l1(:)) - std(l2(:)))^2 + (std(a1(:)) - std(a2(:)))^2 + (std(b1(:)) - std(b2(:)))^2)];
            else
                label2_revised(label2 == i) = next_label;
                table2(i) = next_label;
                next_label = next_label + 1;
            end
            end
%         end
    end
%     delta_E_arr(f-1) = mean(delta_E);
%     delta_std_arr(f-1) = mean(delta_std);
    
    output(:,:,:,f) = uint8(output_frame);
    
    output2(:,:,1,f) = uint8(mod(label2_revised .* mod(label2_revised, 2) * 50, 256));
    output2(:,:,2,f) = uint8(mod(label2_revised .* mod(label2_revised, 3) * 30, 256));
    output2(:,:,3,f) = uint8(mod(label2_revised .* mod(label2_revised, 5) * 20, 256));
end
fprintf(repmat('\b',[1, length(verb)]))

% v = VideoWriter('Japan-fmeasure05-mask.avi');
% open(v);
% for i = 1:size(output,4)
%     writeVideo(v, uint8(output(:,:,:,i)));
% end
% close(v);

v = VideoWriter('fish-voxel3.avi');
open(v);
for i = 1:size(output2,4)
    writeVideo(v, uint8(output2(:,:,:,i)));
end
close(v);