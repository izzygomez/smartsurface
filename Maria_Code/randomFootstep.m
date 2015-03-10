function Matrix=randomFootsteps(matx, maty, i, j)

Matrix=zeros(matx,maty);

p=0;
x=round(rand()*(matx-i));
y=round(rand()*(maty-j));
for a=1:i
    for b=1:j
        p=p+1;
        Matrix(x+a,y+b+1)=1;
    end
end
for a=1:3
    for b=1:3
        p=p+1;
        Matrix(x+a+3,y+b+1)=0;
    end
end

imwrite(Matrix, 'randomFootstep.jpeg')
