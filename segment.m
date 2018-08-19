v = VideoReader('OldMan_inpu.avi');
% v3 = VideoReader('OldMan_perframe.avi');
v2 = VideoWriter('interview_Bonneel.avi');

v2.FrameRate = 10;
open(v2);
for i = 1:91
    f = readFrame(v);
%     f3 = readFrame(v3);
    if i>41
        writeVideo(v2, f);
    end
end
close(v2);