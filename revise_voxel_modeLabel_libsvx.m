v = VideoReader('input2.avi');
frames = read(v);

% parameters for optical flow
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

% supervoxels
v2 = VideoReader('Lily-voxel.avi');
labels = read(v2);

verb = '';
output = zeros(size(frames));
label2_revised = labels(:,:,:,1);
output(:,:,:,1) = labels(:,:,:,1);
numlabels = 0;
next_label = numlabels + 1;
threshold = 0.1;

for f = 2:size(frames,4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', f);
    fprintf(verb);
    
    f1 = frames(:,:,:,f-1);
    f2 = frames(:,:,:,f);
    label1 = label2_revised;
    label2 = labels(:,:,:,f);

    % optical flow
    [vx, vy, ~] = Coarse2FineTwoFrames(f2, f1, para);

    [x, y] = meshgrid(1:size(f2,2), 1:size(f2,1));
    label_propagate = interp2(double(label1), x + vx ,y + vy, 'nearest');

    label2_revised = label2;
    min_label = min(label2(:));
    max_label = max(label2(:));
    for i = min_label : max_label
        mode_label = mode(label_propagate(label2 == i));
		recall = sum(label_propagate(label2 == i) == mode_label) / sum(sum(label2 == i));
		precision = sum(label_propagate(label2 == i) == mode_label) / sum(sum(label_propagate == mode_label));
		f_measure = 2 * recall * precision / (recall + precision);
        if f_measure > threshold
            label2_revised(label2 == i) = mode_label;
        else
            label2_revised(label2 == i) = next_label;
            next_label = next_label + 1;
        end
    end

    output(:,:,1,f) = uint8(mod(label2_revised .* mod(label2_revised, 2) * 50, 256));
    output(:,:,2,f) = uint8(mod(label2_revised .* mod(label2_revised, 3) * 30, 256));
    output(:,:,3,f) = uint8(mod(label2_revised .* mod(label2_revised, 5) * 20, 256));
end
fprintf(repmat('\b',[1, length(verb)]))

v = VideoWriter('video2-test01.avi');
open(v);
for i = 1:size(output,4)
    writeVideo(v, uint8(output(:,:,:,i)));
end
close(v);