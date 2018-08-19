v1 = VideoReader('input.avi');
v2 = VideoReader('temporal.avi');

f1 = im2double(read(v1));
f2 = im2double(read(v2));

dist = zeros(1, size(f1,4));
tcm = zeros(1, size(f1,4));
tcm2 = zeros(1, size(f1,4));
prev_frame = f1(:,:,:,1);
prev_output = f2(:,:,:,1);

verb = '';
for i = 2 : size(f1,4)
    fprintf(repmat('\b',[1, length(verb)]));
    verb = sprintf('frame %d', i);
    fprintf(verb);
    current_frame = f1(:,:,:,i);
	current_output = f2(:,:,:,i);
    
    ann1 = nnmex(current_frame, prev_frame, 'cpu', [], [], [], [], [], [], 1);
    ann2 = nnmex(current_output, prev_output, 'cpu', [], [], [], [], [], [], 1);
    dist(i) = dist(i) + sum(sum(((ann1(:,:,1) - ann2(:,:,1)).^2))); % ./ (ann1(:,:,1) + ann2(:,:,1))));
    dist(i) = dist(i) + sum(sum(((ann1(:,:,2) - ann2(:,:,2)).^2))); % ./ (ann1(:,:,2) + ann2(:,:,2))));
    temp1 = im2double(votemex(prev_frame, ann1));
    temp2 = im2double(votemex(prev_output, ann2));
    temp3 = im2double(votemex(prev_output, ann1));
    tcm(i) = sum(sum(sum((temp2(1:end-6,1:end-6,:) - current_output(1:end-6,1:end-6,:)).^2))) / (sum(sum(sum((temp1(1:end-6,1:end-6,:) - current_frame(1:end-6,1:end-6,:)).^2))) + 1e-9);
    tcm2(i) = sum(sum(sum((temp3(1:end-6,1:end-6,:) - current_output(1:end-6,1:end-6,:)).^2))) / (sum(sum(sum((temp1(1:end-6,1:end-6,:) - current_frame(1:end-6,1:end-6,:)).^2))) + 1e-9);
end
fprintf(repmat('\b',[1, length(verb)]));