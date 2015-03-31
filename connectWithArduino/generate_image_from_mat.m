function [ ] = generate_image_from_mat(mat, threshold)
    binary_mat = mat > threshold;
    imwrite(binary_mat, 'image.jpg');
end

