function [fused_image, err] = fuse_patchMatch2(image_stack, ann_stack, n_stack)

%     n = size(image_stack,4);
    n = n_stack;
    fused_image = zeros(size(image_stack(:,:,:,1)));
    

%     error = 0;    
%     for i = 1 : n
%         diff = mean(mean(ann_stack(:,:,3,i)));
%         if (i == 1) || (diff < error)
%             idx = i;
%         end
%     end
%     
%     fused_image = votemex(image_stack(:,:,:,idx), ann_stack(:,:,:,idx));
%     err = double(ann_stack(:,:,3,idx));

    w_total = zeros(size(image_stack(:,:,1,1)));
    error = zeros(size(image_stack(:,:,1,1)));
    for i = 1 : n
        image_warp = im2double(votemex(image_stack(:,:,:,i), ann_stack(:,:,:,i)));
        w = 1 ./ (double(ann_stack(:,:,3,i)) + 1e-9);
%         w = exp(-double(ann_stack(:,:,3,i)));
        w_total = w_total + w;
        fused_image = fused_image + repmat(w, [1 1 3]) .* image_warp;
        error = error + double(ann_stack(:,:,3,i));
    end
    
    fused_image = fused_image ./ repmat(w_total, [1 1 3]);
    err = error ./ w_total;