function [fused_image, err] = fuse_opticalflow(ref, image_stack, ann_stack, n_stack)
    
    n = n_stack;
%     image_warp = zeros(size(image_stack(:,:,:,1)));
    fused_image = zeros(size(image_stack(:,:,:,1)));
%     w_total = zeros(size(image_stack(:,:,1,1)));
    error = zeros(size(image_stack(:,:,1,1)));
%     ref_r = ref(:,:,1);
%     ref_g = ref(:,:,2);
%     ref_b = ref(:,:,3);
    
    for i = 1 : n
%         vx = double(ann_stack(:,:,1,i));
%         vy = double(ann_stack(:,:,2,i));
%         key_r = image_stack(:,:,1,i);
%         key_g = image_stack(:,:,2,i);
%         key_b = image_stack(:,:,3,i);
%         [x, y] = meshgrid(1:size(image_stack,2), 1:size(image_stack,1));
%         image_warp_r = interp2(key_r, x + vx ,y + vy);
%         image_warp_g = interp2(key_g, x + vx ,y + vy);
%         image_warp_b = interp2(key_b, x + vx ,y + vy);
%         image_warp_r(isnan(image_warp_r)) = ref_r(isnan(image_warp_r));
%         image_warp_g(isnan(image_warp_g)) = ref_g(isnan(image_warp_g));
%         image_warp_b(isnan(image_warp_b)) = ref_b(isnan(image_warp_b));
%         image_warp(:,:,1) = image_warp_r;
%         image_warp(:,:,2) = image_warp_g;
%         image_warp(:,:,3) = image_warp_b;
        image_warp = double(ann_stack(:,:,:,i));
        dist = mean(ref - image_warp, 3);
%         w = exp(-double(dist));
%         w_total = w_total + w;
%         fused_image = fused_image + repmat(w, [1 1 3]) .* image_warp;
        fused_image = fused_image + image_warp;
        error = error + dist;
    end
    
    fused_image = fused_image / n; %./ repmat(w_total, [1 1 3]);
    err = error / n; %w_total;