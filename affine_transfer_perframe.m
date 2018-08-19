function output = affine_transfer_perframe(f, f_processed, label)

    f = im2double(f);
    f_processed = im2double(f_processed);
    r = f(:,:,1);
    g = f(:,:,2);
    b = f(:,:,3);
    r_processed = f_processed(:,:,1);
    g_processed = f_processed(:,:,2);
    b_processed = f_processed(:,:,3);
    output = zeros(size(f));
%     output_r = zeros(numel(output(:,:,1)),1);
%     output_g = zeros(numel(output(:,:,1)),1);
%     output_b = zeros(numel(output(:,:,1)),1);
    m11 = zeros(size(r));
    m12 = zeros(size(r));
    m13 = zeros(size(r));
    m14 = zeros(size(r));
    m21 = zeros(size(r));
    m22 = zeros(size(r));
    m23 = zeros(size(r));
    m24 = zeros(size(r));
    m31 = zeros(size(r));
    m32 = zeros(size(r));
    m33 = zeros(size(r));
    m34 = zeros(size(r));
    
    imin = min(label(:));
    imax = max(label(:));    
    for i = imin : imax
        if any(label(:) == i)
            m1 = [r(label == i), g(label == i), b(label == i), ones(sum(sum(label == i)),1)]';
            m2 = [r_processed(label == i), g_processed(label == i), b_processed(label == i)]';
            t = m2*pinv(m1);
            m1_transfered = t*m1;

%             output_r(label == i) = m1_transfered(1,:);
%             output_g(label == i) = m1_transfered(2,:);
%             output_b(label == i) = m1_transfered(3,:);
            m11(label == i) =  t(1,1);
            m12(label == i) =  t(1,2);
            m13(label == i) =  t(1,3);
            m14(label == i) =  t(1,4);
            m21(label == i) =  t(2,1);
            m22(label == i) =  t(2,2);
            m23(label == i) =  t(2,3);
            m24(label == i) =  t(2,4);
            m31(label == i) =  t(3,1);
            m32(label == i) =  t(3,2);
            m33(label == i) =  t(3,3);
            m34(label == i) =  t(3,4);
        end
    end
    m11_filtered = imguidedfilter(m11, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m12_filtered = imguidedfilter(m12, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m13_filtered = imguidedfilter(m13, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m14_filtered = imguidedfilter(m14, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m21_filtered = imguidedfilter(m21, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m22_filtered = imguidedfilter(m22, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m23_filtered = imguidedfilter(m23, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m24_filtered = imguidedfilter(m24, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m31_filtered = imguidedfilter(m31, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m32_filtered = imguidedfilter(m32, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m33_filtered = imguidedfilter(m33, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    m34_filtered = imguidedfilter(m34, f, 'NeighborhoodSize', [5 5], 'DegreeOfSmoothing', 0.01);
    output(:,:,1) = m11_filtered .* r + m12_filtered .* g + m13_filtered .* b + m14_filtered .* ones(size(r));
    output(:,:,2) = m21_filtered .* r + m22_filtered .* g + m23_filtered .* b + m24_filtered .* ones(size(r));
    output(:,:,3) = m31_filtered .* r + m32_filtered .* g + m33_filtered .* b + m34_filtered .* ones(size(r));
%     output(:,:,1) = reshape(output_r, size(output(:,:,1)));
%     output(:,:,2) = reshape(output_g, size(output(:,:,1))); 
%     output(:,:,3) = reshape(output_b, size(output(:,:,1)));
end