clear all;
addpath(genpath('E:\hank\hank\gbh_stream\interview'));
addpath(genpath('E:\hank\hank\Downloads\OpticalFlow'));
addpath(genpath('C:\Users\hank\Downloads\CPMFlow\cpm_exe\cpm_exe\interview'))

v = VideoReader('interview.mp4');
frames = read(v, [41 90]);

% parameters for optical flow
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
file = dir('C:\Users\hank\Downloads\CPMFlow\cpm_exe\cpm_exe\interview\output\*txt');

verb = '';
output = zeros(size(frames));

for f = 2:size(frames,4)
    fprintf(repmat('\b',[1, length(verb)]))
    verb = sprintf('frame %d', f);
    fprintf(verb);
    
    f1 = frames(:,:,:,f-1);
    f2 = frames(:,:,:,f);

    % optical flow
    [vx, vy, ~] = Coarse2FineTwoFrames(f2, f1, para);
    
%     arr = textread(file(f-1).name, '%d');
%     x1 = arr(1:4:end);
%     y1 = arr(2:4:end);
%     x2 = arr(3:4:end);
%     y2 = arr(4:4:end);
%     idx = x1 >= 0 & x1 < size(frames,2) & x2 >= 0 & x2 < size(frames,2) & y1 >= 0 & y1 < size(frames,1) & y2 >=0 & y2 < size(frames,1);
%     [fx, fy] = meshgrid(1:size(f2,2), 1:size(f2,1));
%     fx((y2(idx)+1) + size(frames,1)*x2(idx)) = x1(idx)+1;
%     fy((y2(idx)+1) + size(frames,1)*x2(idx)) = y1(idx)+1;
%     [x, y] = meshgrid(1:size(f2,2), 1:size(f2,1));
%     vx = fx - x;
%     vy = fy - y;
    
    vx(vx < -50) = -50;
    vy(vy < -50) = -50;
    vx(vx > 50) = 50;
    vy(vy > 50) = 50;
    output(:,:,1,f) = 0.5 + vx/50;
    output(:,:,2,f) = 0.5 + vy/50;
    output(:,:,3,f) = 0.5;
end
output(output > 1) = 1;
output(output < 0) = 0;
fprintf(repmat('\b',[1, length(verb)]))

v = VideoWriter('interview-flow-gray.avi');
v.FrameRate = 10;
open(v);
for i = 1:size(output,4)
    writeVideo(v, output(:,:,:,i));
end
close(v);