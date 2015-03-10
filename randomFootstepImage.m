function randomTenByFiveFootstep();
matrix = zeros(64,64); % initialize 64x64 zeros matrix
% Get random x, y within appropriate bounds
x = randi(60,1,1);
y = randi(55,1,1);
% Let the 10x5 sub-matrix with upper-leftmost element found at x, y
% contain elements equal to one
matrix(y:y+9, x:x+4) = ones(10,5);
% Save this matrix to image named 'randomFootstep'
imwrite(matrix, 'randomFootstep.jpeg');
end
% some comment