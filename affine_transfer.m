function [output, table] = affine_transfer(f, f_processed, label2, score, table)
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
    
    imin = min(label2(:));
    imax = max(label2(:));    
    for i = imin : imax
        table_i = table(i,:,:);
        if any(label2(:) == i)
            m1 = [r(label2 == i), g(label2 == i), b(label2 == i), ones(sum(sum(label2 == i)),1)]';
%             m1 = [r(label2 == i), g(label2 == i), b(label2 == i)]';
            m2 = [r_processed(label2 == i), g_processed(label2 == i), b_processed(label2 == i)]';
            t = m2*pinv(m1);
            t2 = t;
            if any(table_i(:))
                t2(:) = table(i,:,:);
                m1_transfered = ((1-score(i))*t + score(i)*t2)*m1;
                table(i,:,:) = (1-score(i))*t + score(i)*t2;
%                m1_transfered = (0.1*t + 0.9*t2)*m1;
%                table(i,:,:) = 0.1*t + 0.9*t2;                
            else
                m1_transfered = t*m1;
                table(i,:,:) = t;
            end
%             output_r(label2 == i) = m1_transfered(1,:);
%             output_g(label2 == i) = m1_transfered(2,:);
%             output_b(label2 == i) = m1_transfered(3,:);
            m11(label2 == i) =  table(i,1,1);
            m12(label2 == i) =  table(i,1,2);
            m13(label2 == i) =  table(i,1,3);
            m14(label2 == i) =  table(i,1,4);
            m21(label2 == i) =  table(i,2,1);
            m22(label2 == i) =  table(i,2,2);
            m23(label2 == i) =  table(i,2,3);
            m24(label2 == i) =  table(i,2,4);
            m31(label2 == i) =  table(i,3,1);
            m32(label2 == i) =  table(i,3,2);
            m33(label2 == i) =  table(i,3,3);
            m34(label2 == i) =  table(i,3,4);
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