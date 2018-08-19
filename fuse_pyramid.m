function output = fuse_pyramid(input, pmatch, ref, w)

% input = im2double(input);
pmatch = im2double(pmatch);
ref = im2double(ref);

% input_hmatch = imhistmatch(input, ref);
nlev = 4;

% pyr_input_hmatch  = laplacian_pyramid(input_hmatch, nlev);
% pyr_input  = laplacian_pyramid(input, nlev);
pyr_pmatch = laplacian_pyramid(pmatch, nlev);
pyr_ref = laplacian_pyramid(ref, nlev);
pyr_w = laplacian_pyramid(w, nlev);

output_pyr = pyr_ref;
output_pyr{nlev} = pyr_w{nlev} .* pyr_ref{nlev} + (1-pyr_w{nlev}) .* pyr_pmatch{nlev};
output = reconstruct_laplacian_pyramid(output_pyr);