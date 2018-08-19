addpath(genpath('D:\gbh_stream\fish'));
addpath(genpath('C:\Users\hank\Downloads\OpticalFlow'));
clear all;

file = dir('fish\05\*ppm');
table_value = [];
for i = 86:160
	input = imread(file(i).name);
	temp_value = 2^16 * uint32(input(:,:,1)) + 2^8 * uint32(input(:,:,2)) + uint32(input(:,:,3));
	table_value = unique([table_value; temp_value(:)], 'stable');
end

inv_table_value = zeros([1 size(table_value)], 'uint32');
idx = 1:1:size(table_value,1);
inv_table_value(table_value) = idx;

labels = zeros([size(temp_value) 75], 'uint32');
	
for i = 86:160
	input = imread(file(i).name);
	temp_value = 2^16 * uint32(input(:,:,1)) + 2^8 * uint32(input(:,:,2)) + uint32(input(:,:,3));
	labels(:,:,i-85) = uint32(inv_table_value(temp_value));
end

% optical flow groundtruth
file = dir('fish\flows\*.mat');

verb = '';
label2_revised = labels(:,:,1);
output = zeros(size(labels,1), size(labels,2), 3, size(labels,3));
output(:,:,1,1) = uint8(mod(label2_revised .* mod(label2_revised, 2) * 50, 256));
output(:,:,2,1) = uint8(mod(label2_revised .* mod(label2_revised, 3) * 50, 256));
output(:,:,3,1) = uint8(mod(label2_revised .* mod(label2_revised, 5) * 50, 256));
numlabels = size(table_value,1);
next_label = numlabels + 1;
threshold = 0.6;

table2 = 1:1:numlabels;

for f = 2:size(labels,3)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', f);
    fprintf(verb);
        
    label1 = label2_revised;
    label2 = labels(:,:,f);

    % optical flow
    load(file(f-1).name);

    [x, y] = meshgrid(1:size(labels,2), 1:size(labels,1));
    label_propagate = interp2(double(label1), x + vx ,y + vy, 'nearest');

    label2_revised = label2;
    min_label = min(label2(:));
    max_label = max(label2(:));
	
	for i = min_label : max_label
        overlap = (label2 == i) & (label_propagate == table2(i));
		recall = sum(overlap(:)) / sum(sum(label2 == i));
 		precision = sum(overlap(:)) / sum(sum(label_propagate == table2(i)));
 		f_measure = 2 * recall * precision / (recall + precision);
        if f_measure > threshold
            label2_revised(label2 == i) = table2(i);
        else
            label2_revised(label2 == i) = next_label;
            table2(i) = next_label;
            next_label = next_label + 1;
        end
    end
%     output_frame = zeros(size(f2));
%     mask = repmat(label2_revised == table2(label2), [1,1,3]);
%     output_frame(mask) = f2(mask);
%     output(:,:,:,f) = uint8(output_frame);
    output(:,:,1,f) = uint8(mod(label2_revised .* mod(label2_revised, 2) * 50, 256));
    output(:,:,2,f) = uint8(mod(label2_revised .* mod(label2_revised, 3) * 30, 256));
    output(:,:,3,f) = uint8(mod(label2_revised .* mod(label2_revised, 5) * 20, 256));
end
fprintf(repmat('\b',[1, length(verb)]))

v = VideoWriter('fish-recall_06_groundtruth.avi');
open(v);
for i = 1:size(output,4)
    writeVideo(v, uint8(output(:,:,:,i)));
end
close(v);